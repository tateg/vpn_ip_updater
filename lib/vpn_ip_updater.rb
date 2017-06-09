#!/usr/bin/env ruby

# AutoVPN IP Updater Core
# Written by Tate Galbraith
# June 2017

require 'httparty'
require 'json'
require 'colorize'
require 'ipaddress'

class Updater
  
  def initialize(api_key)
    @api_key = api_key
    @api_url = "https://dashboard.meraki.com/api/v0"
    @default_provider = "http://whatismyip.akamai.com"
  end

  # Setup GET and PUT API calls
  def api_call(endpoint_url, http_method, options_hash={})
    @req_headers = {"X-Cisco-Meraki-API-Key" => @api_key, "Content-Type" => "application/json"}
    @options = {:headers => @req_headers, :body => options_hash.to_json}
    # Setup HTTP request types
    case http_method
    when "GET"
      @response = HTTParty.get("#{@api_url}/#{endpoint_url}", @options)
      raise "Error 404 - Is the ID entered correct?" if @response.code == 404
      return JSON.parse(@response.body)
    when "GET_JSON"
      @response = HTTParty.get("#{@api_url}/#{endpoint_url}", @options)
      raise "Error 404 - Is the ID entered correct?" if @response.code == 404
      return @response.body
    when "PUT"
      @response = HTTParty.put("#{@api_url}/#{endpoint_url}", @options)
      raise "Error 404 - Is the ID entered correct?" if @response.code == 404
      return JSON.parse(@response.body)
    else
      raise "Invalid HTTP method passed - only GET, GET_JSON & PUT supported!"
    end
  end
  
  # Ensure scraped IP information is valid
  # Returns valid IP address if present
  def validate_and_extract_ip(address)
    @validation_err = "Provider Error (IP) - Bad IP or page does not contain valid IP"
    begin
      if IPAddress::valid_ipv4?(address)
        return address
      elsif IPAddress::valid_ipv4?(IPAddress::IPv4::extract(address).to_s)
        return IPAddress::IPv4::extract(address).to_s
      else
        raise @validation_err
      end
    rescue ArgumentError => e
      raise @validation_err
    end
  end

  # Return the current public IP this machine is using
  # Optional to change public IP provider to another site
  # Spoof desktop browser headers for consistency
  def get_current_ip(provider = @default_provider)
    begin
      @browser_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) 
                        AppleWebKit/537.36 (KHTML, like Gecko) 
                        Chrome/58.0.3029.110 Safari/537.36"
      @provider_response = HTTParty.get(provider, headers: {"User-Agent" => @browser_agent})
      @provider_body = @provider_response.body
      raise "Provider Error (Response) - #{provider} returned nothing." if @provider_body.nil?
      raise "Provider Error (403) - #{provider} does not allow scraping, try another." if @provider_response.code == 403
      raise "Provider Error (404) - #{provider} is not available!" if @provider_response.code == 404
      @current_ip = validate_and_extract_ip(@provider_body)
      return @current_ip
    rescue SocketError # Rescue if TCP connection to site fails outright
      raise "Provider Error (connect) - #{provider} connection failed or no response."
    end
  end

  # Return all organization names and IDs associated with this api key
  def get_organizations(format = "GET")
    @org_url = "/organizations"
    api_call(@org_url, format)
  end

  # Return array of hash containing all current VPN peers in an org
  def get_vpn_peers(org_id, format = "GET")
    @vpn_peers_url = "/organizations/#{org_id}/thirdPartyVPNPeers"
    api_call(@vpn_peers_url, format)
  end

  # Return the current public IP of a specific VPN peer in an org
  def get_vpn_peer_ip(org_id, peer_name)
    @peers = get_vpn_peers(org_id)
    @peers.each do |peer|
      if peer["name"] == peer_name
        return peer["publicIp"]
      end
    end
  end
  
  # Check updated VPN peer list against current IP to confirm PUT success
  def check_updated_peers(peers)
    peers.each do |peer|
      if peer["publicIp"] == @current_ip
        return "VPN peer IP successfully updated to (#{peer["publicIp"].green})"
      end
    end
  end

  # Update a specific VPN peer's public IP address with this machine's current public IP
  def update_vpn_peer_ip(org_id, name, provider = @default_provider)
    @vpn_peers_url = "/organizations/#{org_id}/thirdPartyVPNPeers"
    if get_current_ip(provider) != get_vpn_peer_ip(org_id, name)
      @peers = get_vpn_peers(org_id)
      # Catch if name not valid peer
      if !@peers.any? {|hash| hash["name"].include?(name)}
        return "VPN peer not found".red
      end
      @peers.each do |peer|
        if peer["name"] == name
          puts "VPN peer (#{name.red}) IP (#{peer["publicIp"].red}) out-of-date! Should be (#{@current_ip.green})"
          peer["publicIp"] = @current_ip
        end
      end
      @updated_peers = api_call(@vpn_peers_url, "PUT", @peers)
      check_updated_peers(@updated_peers)
    else
      return "VPN peer (#{name.green}) public IP (#{@current_ip.green}) already up-to-date!"
    end
  end

end
