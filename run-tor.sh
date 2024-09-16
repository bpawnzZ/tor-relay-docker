#!/bin/bash

# Create the torrc file in a location where debian-tor has write access
cat << EOT > /tmp/torrc
Nickname $TOR_NICKNAME
ContactInfo $CONTACT_INFO
ORPort $RELAY_PORT
DirPort $DIR_PORT
ExitRelay 0
SocksPort $TOR_SOCKS_PORT
ControlPort $CONTROL_PORT
CookieAuthentication 1
CookieAuthFile /var/lib/tor/control_auth_cookie
RelayBandwidthRate $RELAY_BANDWIDTH_RATE KB
RelayBandwidthBurst $RELAY_BANDWIDTH_BURST KB
Address $EXTERNAL_ADDRESS
IPv6Exit 0
ClientUseIPv4 1
ClientUseIPv6 0
ClientPreferIPv6ORPort 0
DataDirectory /var/lib/tor
PublishServerDescriptor 1
AssumeReachable 1
EOT

# Run Tor with the temporary config file
exec tor -f /tmp/torrc
