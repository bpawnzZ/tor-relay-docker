#!/bin/bash

cat << EOT > /etc/tor/torrc
Nickname $TOR_NICKNAME
ContactInfo $CONTACT_INFO
ORPort $RELAY_PORT
DirPort $DIR_PORT
ExitRelay 0
SocksPort $TOR_SOCKS_PORT
ControlPort 9051
RelayBandwidthRate $RELAY_BANDWIDTH_RATE KB
RelayBandwidthBurst $RELAY_BANDWIDTH_BURST KB
Address $EXTERNAL_ADDRESS
IPv6Exit $IPV6_EXIT
ClientUseIPv4 1
ClientUseIPv6 0
ClientPreferIPv6ORPort 0
EOT

if [ "$RELAY_TYPE" = "GUARD" ]; then
    echo "GuardLifetime 2 months" >> /etc/tor/torrc
fi

exec tor -f /etc/tor/torrc 
