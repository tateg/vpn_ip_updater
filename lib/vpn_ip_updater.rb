# vpn_ip_updater.rb
# Written by Tate Galbraith
# Feb 2017

# Open URI for the public IP scrape and Dashboard API for all the API calls
require 'open-uri'
require 'dashboard-api'

class VPNIPUpdater
	# Setup API connection on initialize
	def initialize(api_key)
		connect_api(api_key)
	end

	# Get current public IP of this machine against Akamai
	def get_current_ip
		@scrape = "http://whatismyip.akamai.com"
		@ip = open(@scrape).read
	end

	# Instantiate new API instance using API key passed in as argument
	def connect_api(api_key)
		@dash_api = DashboardAPI.new(api_key)
	end

	# Get current list of organization third-party peers
	def get_peer_list(org_id)
		@peers = []
		@peers = @dash_api.get_third_party_peers(org_id)
	end

	# Filter peer list for specified peer name and return current public IP for that peer
	def get_peer_current_ip(name)
		@peers.each do |peer|
			if peer["name"] == name
				@current_peer_ip = peer["publicIp"]
			end
		end
	end

	# Update public IP for that peer if it does not match the current one
	def update_peer_ip(org_id, name)
		if @current_peer_ip != @ip
			@peers.each do |peer|
				if peer["name"] == name
					peer["publicIp"] = @ip
					@dash_api.update_third_party_peers(org_id, @peers)
				end
			end
		end
	end
end