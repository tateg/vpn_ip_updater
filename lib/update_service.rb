#!/usr/bin/env ruby

# VPN IP Updater Service
# Written by Tate Galbraith
# June 2017

require './vpn_ip_updater.rb'
require 'colorize'
require 'optparse'

# Show the help screen if no arguments are provided
ARGV << "-h" if ARGV.empty?

options = {}

OptionParser.new do |parser|

  parser.banner = "
    ----------------------------------
    VPN IP Updater Service
    ----------------------------------

    Usage: update_service.rb [options]
    + If nothing is provided this help will be shown
    + If only API key is provided then a list of all associated organizations will be returned
    + If API key and org ID is provided a list of all third-party VPN peers will be returned
    + If API key, org ID and peer name is provided that peer public IP will be updated
    + If API key, org ID, peer name and interval is provided that peer will be updated on interval"
  parser.separator ""

  parser.on("-h", "--help", "Show this help message") do ||
    puts parser
  end
  parser.on("-k", "--api-key KEY", "Dashboard user API key") do |k|
    options[:key] = k
  end
  parser.on("-o", "--organization ID", "Organization ID string") do |o|
    options[:organization] = o
  end
  parser.on("-p", "--peer NAME", "VPN peer name to update") do |p|
    options[:peer] = p
  end
  parser.on("-i", "--update-interval SECONDS", Integer, "Number of seconds between IP checks") do |i|
    options[:interval] = i
  end
  parser.separator ""
  parser.on("-j", "--json", "Output results as raw JSON") do |j|
    options[:json] = j
  end

  parser.separator ""
end.parse!

# Instantiate updater if API key present
updater = Updater.new(options[:key]) if options.key?(:key)

# Return organization list if only API key is provided
if options.key?(:key) and !options.key?(:organization)
  puts "Organizations associated with that API key:".green
  if options.key?(:json)
    puts updater.get_organizations("GET_JSON")
  else
    updater.get_organizations.each do |a|
      puts "Name: \"#{a["name"]}\" => ID: #{a["id"]}"
    end
  end
end

# Return list of VPN peers if API key and org ID provided
if options.key?(:key) and options.key?(:organization) and !options.key?(:peer)
  puts "Third-party VPN peers in that organization:".green
  if options.key?(:json)
    puts updater.get_vpn_peers(options[:organization], "GET_JSON")
  else
    updater.get_vpn_peers(options[:organization]).each do |a|
      puts "Name: \"#{a["name"]}\" => IP: #{a["publicIp"]}"
    end
  end
end

# Update peer one time if all three arguments except interval are provided
if ([:key, :organization, :peer].all? {|k| options.key? k}) and !options.key?(:interval)
  puts "Updating named VPN peer public IP".yellow
  puts updater.update_vpn_peer_ip(options[:organization], options[:peer])
end

# Update peer on loop at interval if all four arguments provided
if ([:key, :organization, :peer, :interval].all? {|k| options.key? k})
  loop do
    puts "Updating named VPN peer public IP on #{options[:interval]} second interval".yellow
    puts @loop_update = updater.update_vpn_peer_ip(options[:organization], options[:peer])
    exit if @loop_update.include? "VPN peer not found"
    sleep options[:interval]
  end
end

