#!/usr/bin/env ruby

# AutoVPN IP Updater (Refactor 1)
# Written by Tate Galbraith
# June 2017

require 'httparty'
require 'json'
require 'colorize'

class Updater
  
  def initialize(api_key)
    @api_key = api_key
    @api_url = "https://dashboard.meraki.com/api/v0"
  end

  # Setup GET and PUT API calls
  def api_call(endpoint_url, http_method, options_hash={})
    @req_headers = {"X-Cisco-Meraki-API-Key" => @api_key, "Content-Type" => "application/json"}
    @options = {:headers => @req_headers, :body => options_hash.to_json}
    case http_method
    when "GET"
      @response = HTTParty.get("#{@api_url}/#{endpoint_url}", @options)
      return JSON.parse(@response.body)
    when "GET_JSON"
      @response = HTTParty.get("#{@api_url}/#{endpoint_url}", @options)
      return @response.body
    when "PUT"
      @response = HTTParty.put("#{@api_url}/#{endpoint_url}", @options)
      return JSON.parse(@response.body)
    end
  end

  # Return the current public IP this machine is using
  def get_current_ip
    @provider = "http://whatismyip.akamai.com"
    @current_ip = HTTParty.get(@provider).body 
    return @current_ip
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
  def update_vpn_peer_ip(org_id, name)
    @vpn_peers_url = "/organizations/#{org_id}/thirdPartyVPNPeers"
    if get_current_ip != get_vpn_peer_ip(org_id, name)
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
