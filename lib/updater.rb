# /lib/updater.rb
# vpn_ip_updater
# Example looped update checker
# Written by Tate Galbraith
# March 2017

require 'colorize'
require-relative '/vpn_ip_updater.rb'

# ARGV[0] = API KEY
# ARGV[1] = ORG ID
# ARGV[2] = NAME OF PEER

# Update checker loop
def updater
  @vpn = VPNIPUpdater.new(ARGV[0])
  loop do
    puts "Checking current IP..."
    @vpn.get_current_ip
    puts "Your current IP is: #{@vpn.ip}"
    puts "Checking peer IP..."
    @vpn.get_peer_list(ARGV[1])
    @vpn.get_peer_current_ip(ARGV[2])
    puts "Your peer IP is #{@vpn.current_peer_ip}"
    puts "Updating..."
    @vpn.update_peer_ip(ARGV[1], ARGV[2])
    puts "Sleeping..."
    sleep(10)
  end
end

updater
