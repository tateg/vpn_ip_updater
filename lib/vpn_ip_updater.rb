# vpn_ip_updater.rb
# Written by Tate Galbraith
# Feb 2017

require 'open-uri'
require 'dashboard-api'

class VPNIPUpdater
	
	# Get current public IP of this machine against Akamai
	def get_current_ip
		@scrape = "http://whatismyip.akamai.com"
		@ip = open(@scrape).read
	end

	# Instantiate new API instance using API key passed in as argument
	def connect_api
		@api_key = ARGV.first
		@dash_api = DashboardAPI.new(@api_key)
	end

	# Get current list of organization third-party peers
	def get_peer_list
		@org_id = ARGV.second
		@peers = @dash_api.get_third_party_peers(@org_id)
	end

	# Filter peer list for specified peer and get current IP for that peer
	def get_peer_current_ip
		@peers.each do |peer|
			if peer["name"] == ARGV.third
				@current_peer_ip = peer["publicIp"]
			end
		end
	end

	def update_peer_ip

	end

end

VPNIPUpdater.get_current_ip
VPNIPUpdater.connect_api
VPNIPUpdater.get_peer_list
VPNIPUpdater.get_peer_current_ip