#!/usr/bin/env ruby

# VPN IP Updater Service
# Written by Tate Galbraith
# June 2017

require_relative 'vpn_ip_updater_refactor.rb'
require 'colorize'
require 'optparse'

options = {}

OptionParser.new do |parser|

  parser.separator "----------------------"
  parser.separator "VPN IP Updater Service"
  parser.separator "----------------------"
  parser.banner = "Usage: update_service.rb [options]"

  parser.on("-h", "--help", "Show this help message") do ||
    puts parser
  end
  parser.on("-k", "--api-key KEY", "Dashboard user API key (Required)") do |k|
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

  parser.on_tail("-h", "--help", "Show this help message") do
    puts parser
    exit
  end

end.parse!
