# VPN IP Updater

June 2017
Written by Tate Galbraith

This is a utility for keeping the public IP of a third-party peer up-to-date in the Cisco Meraki Dashboard.

This utility will scrape the public IP of whatever device it is run on and push via API to specified Dashboard account. Currently the application will leverage Akamai for scraping the public IP, but can be changed to whatever you like.

There are two main components to the application - the core API functions and the update service.
- The core API functions leverage HTTParty to GET and PUT requests against https://dashboard.meraki.com/api/v0.
- The update service is a command-line utility designed to run the IP scrape and API calls persistently (on a server, for example). The service will periodically check if the scraped IP and peer IP are different and update accordingly. The interval at which this is checked can be controlled through switches.

There is additional functionality built into the service as well. You can get information on the organizations associated with an API key and a list of third-party VPN peers associated with each organization. The output of the service can also be modified to a JSON format for reuse in other applications. Available service arguments below:

-     Usage: update_service.rb [options]
    + If nothing is provided this help will be shown
    + If only API key is provided then a list of all associated organizations will be returned
    + If API key and org ID is provided a list of all third-party VPN peers will be returned
    + If API key, org ID and peer name is provided that peer public IP will be updated
    + If API key, org ID, peer name and interval is provided that peer will be updated on interval

    -h, --help                       Show this help message
    -k, --api-key KEY                Dashboard user API key
    -o, --organization ID            Organization ID string
    -p, --peer NAME                  VPN peer name to update
    -i, --update-interval SECONDS    Number of seconds between IP checks

    -j, --json                       Output results as raw JSON

