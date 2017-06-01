#!/usr/bin/env ruby

# VPN IP Updater Service
# Written by Tate Galbraith
# June 2017

require './vpn_ip_updater_refactor.rb'
require 'colorize'
require 'optparse'

# Show the help screen if no arguments are provided
ARGV << "-h" if ARGV.empty?

options = {}

OptionParser.new do |parser|

  parser.separator "----------------------"
  parser.separator "VPN IP Updater Service"
  parser.separator "----------------------"
  parser.banner = "Usage: update_service.rb [options]"

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
  parser.on("-i", "--update-interval SECONDS", "Number of seconds between IP checks") do |i|
    options[:interval] = i
  end

end.parse!

# Instantiate updater if API key present
updater = Updater.new(options[:key]) if options.key?(:key)

# Return organization list if only API key is provided
if options.key?(:key) and !options.key?(:organization)
  puts "Organizations associated with that API key:".green
  puts updater.get_organizations
end

# Return list of VPN peers if API key and org ID provided
if options.key?(:key) and options.key?(:organization) and !options.key?(:peer)
  puts "Third-party VPN peers in that organization:".green
  puts updater.get_vpn_peers(options[:organization])
end

# Update peer if all three arguments are provided
if ([:key, :organization, :peer].all? {|k| options.key? k})
  puts "Updating named VPN peer public IP".yellow
  updater.update_vpn_peer_ip(options[:organization], options[:peer])
end
