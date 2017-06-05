#!/usr/bin/env ruby

# AutoVPN IP Updater Test Suite
# Written by Tate Galbraith
# June 2017

require 'minitest/autorun'
require '../lib/vpn_ip_updater.rb'
require 'ipaddress'

class UpdaterTest < Minitest::Test
  
  def setup_tests
    @test_key = "123456"
    @updater = Updater.new(@test_key)
  end

  def test_get_current_ip_returns_ip
    setup_tests
    assert(IPAddress::valid?(@updater.get_current_ip), "get_current_ip did not return valid IP")
  end

end
