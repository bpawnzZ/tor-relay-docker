#!/bin/bash

# Create a directory for the project
mkdir -p tor_relay_setup
cd tor_relay_setup

# Define generic variables
TOR_NICKNAME="your_tor_nickname"
CONTACT_INFO="your_contact_info@example.com"
RELAY_PORT=9101
DIR_PORT=9030
RELAY_BANDWIDTH_RATE=3072  # in KB/s
RELAY_BANDWIDTH_BURST=4096  # in KB/s
TOR_SOCKS_PORT="127.0.0.1:9050"
EXTERNAL_ADDRESS="your_external_ip_address"  # e.g., "74.50.126.91"
CONTROL_PORT="127.0.0.1:9051"

# Create Dockerfile
cat << EOF > Dockerfile
FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Add Tor repository and install Tor and Nyx
RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | tee /etc/apt/sources.list.d/tor.list && \
    apt-get update && apt-get install -y tor deb.torproject.org-keyring && rm -rf /var/lib/apt/lists/* 

RUN pip3 install nyx

# Create necessary directories and set permissions 
RUN mkdir -p /var/lib/tor /etc/tor && chown -R debian-tor:debian-tor /var/lib/tor /etc/tor && chmod 700 /var/lib/tor 

# Copy a script to run Tor with our custom config 
COPY run-tor.sh /run-tor.sh 
RUN chmod +x /run-tor.sh 

# Expose the necessary ports 
EXPOSE $RELAY_PORT $DIR_PORT 9050 9051 

# Switch to the debian-tor user 
USER debian-tor 

# Run Tor 
CMD ["/run-tor.sh"]
EOF

# Create docker-compose.yml using generic variables.
cat << EOF > docker-compose.yml
version: '3'
services:
  tor-guard-relay:
    build:
      context: .
      dockerfile: Dockerfile
    image: tor-guard-relay:latest
    container_name: tor-guard-relay
    restart: unless-stopped    
    network_mode: host    
    environment:
      - TOR_NICKNAME=${TOR_NICKNAME}
      - CONTACT_INFO=${CONTACT_INFO}
      - RELAY_PORT=${RELAY_PORT}
      - DIR_PORT=${DIR_PORT}
      - RELAY_BANDWIDTH_RATE=${RELAY_BANDWIDTH_RATE}
      - RELAY_BANDWIDTH_BURST=${RELAY_BANDWIDTH_BURST}
      - TOR_SOCKS_PORT=${TOR_SOCKS_PORT}
      - EXTERNAL_ADDRESS=${EXTERNAL_ADDRESS}
      - CONTROL_PORT=${CONTROL_PORT}      
      - USE_COOKIE_AUTH=1    
    volumes:
      	- ./tor-data:/var/lib/tor    
  	user: debian-tor  
EOF


