# VPN IP Updater gemspec

@version = File.read('version.txt').chomp
Gem::Specification.new do |s|
    s.name        = 'vpn_ip_updater'
    s.version     = "#{@version}"
    s.date        = '2017-27-02'
    s.summary     = "VPN IP Updater"
    s.description = "Gem that provides the ability to automatically update public IP address of third-party VPN peers in Meraki Dashboard"
    s.authors     = ["Tate Galbraith"]
    s.email       = 'tate@dragonracks.com'
    s.files       = Dir['lib/*.rb']

    #s.add_runtime_dependency 'net-ssh', ["= 3.2.0"]
end
