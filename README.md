# VPN IP Updater

June 2017
Written by Tate Galbraith

This is a utility for keeping the public IP of a third-party peer up-to-date in the Cisco Meraki Dashboard.

This utility will scrape the public IP of whatever device it is run on and push via API to specified Dashboard account. Currently the application will leverage Akamai for scraping the public IP, but can be changed to whatever you like.

There are two main components to the application - the core API functions and the update service.
- The core API functions leverage HTTParty to GET and PUT requests against https://dashboard.meraki.com/api/v0.
- The update service is a command-line utility designed to run the IP scrape and API calls persistently (on a server, for example). The service will periodically check if the scraped IP and peer IP are different and update accordingly. The interval at which this is checked can be controlled through switches.
