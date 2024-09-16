#!/bin/bash

# Create a directory for the project
mkdir -p tor_relay_setup
cd tor_relay_setup

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

# Add Tor repository
RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | tee /etc/apt/sources.list.d/tor.list

# Install Tor and Nyx
RUN apt-get update && apt-get install -y \
    tor \
    deb.torproject.org-keyring \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install nyx

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/tor /etc/tor
RUN chown -R debian-tor:debian-tor /var/lib/tor /etc/tor
RUN chmod 700 /var/lib/tor

# Copy a script to run Tor with our custom config
COPY run-tor.sh /run-tor.sh
RUN chmod +x /run-tor.sh

# Expose the necessary ports
EXPOSE 9101 9030 9050 9051

# Switch to the debian-tor user
USER debian-tor

# Run Tor
CMD ["/run-tor.sh"]
EOF

# Create docker-compose.yml with generic variables
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
      - TOR_NICKNAME=\${TOR_NICKNAME:-mydockerguard}
      - CONTACT_INFO=\${CONTACT_INFO:-anonymous@example.com}
      - RELAY_PORT=\${RELAY_PORT:-9101}
      - DIR_PORT=\${DIR_PORT:-9030}
      - RELAY_BANDWIDTH_RATE=\${RELAY_BANDWIDTH_RATE:-3072}
      - RELAY_BANDWIDTH_BURST=\${RELAY_BANDWIDTH_BURST:-4096}
      - TOR_SOCKS_PORT=\${TOR_SOCKS_PORT:-127.0.0.1:9050}
      - EXTERNAL_ADDRESS=\${EXTERNAL_ADDRESS:-auto}
      - CONTROL_PORT=\${CONTROL_PORT:-127.0.0.1:9051}
      - USE_COOKIE_AUTH=\${USE_COOKIE_AUTH:-1}
    volumes:
      - ./tor-data:/var/lib/tor
    user: debian-tor
EOF

# Create run-tor.sh
cat << EOF > run-tor.sh
#!/bin/bash

# Create the torrc file in a location where debian-tor has write access
cat << EOT > /tmp/torrc
Nickname \$TOR_NICKNAME
ContactInfo \$CONTACT_INFO
ORPort \$RELAY_PORT
DirPort \$DIR_PORT
ExitRelay 0
SocksPort \$TOR_SOCKS_PORT
ControlPort \$CONTROL_PORT
CookieAuthentication 1
CookieAuthFile /var/lib/tor/control_auth_cookie
RelayBandwidthRate \$RELAY_BANDWIDTH_RATE KB
RelayBandwidthBurst \$RELAY_BANDWIDTH_BURST KB
Address \$EXTERNAL_ADDRESS
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
EOF

chmod +x run-tor.sh

# Create tor-data directory and set permissions
mkdir -p ./tor-data
sudo chown -R 102:102 ./tor-data
sudo chmod 700 ./tor-data

# Create the cookie file and set its permissions
sudo dd if=/dev/urandom of=./tor-data/control_auth_cookie bs=32 count=1
sudo chown 102:102 ./tor-data/control_auth_cookie
sudo chmod 600 ./tor-data/control_auth_cookie

# Create Nyx config file
mkdir -p ~/.nyx
cat << EOF > ~/.nyx/config
# Nyx configuration file

[tor]
control_port = 127.0.0.1:9051
cookie_path = ./tor-data/control_auth_cookie

[features]
graph_stat = bandwidth,connections
log_showing = INFO,NOTICE,WARN,ERR
show_bits = False
show_config = True

[graph]
max_width = 100
interval = 1
bound = 10485760

[log]
max_lines = 1000
prepopulate = True

[scan]
consensus_download = True
EOF

# Create README.md
cat << EOF > README.md
# Tor Guard Relay Docker Setup

This repository contains scripts and configuration files to easily set up and run a Tor guard relay using Docker. Running a Tor relay helps improve the Tor network's capacity, speed, and resilience.

## Features

- Automated setup of a Tor guard relay in a Docker container
- Easy configuration through environment variables
- Includes Nyx for relay monitoring
- Persistent data storage
- Secure default settings

## Prerequisites

- Docker
- Docker Compose
- Basic understanding of Tor relays and network configuration

## Quick Start

1. Clone this repository:
   \`\`\`
   git clone https://github.com/yourusername/tor-relay-docker.git
   cd tor-relay-docker
   \`\`\`

2. Run the setup script:
   \`\`\`
   ./setup.sh
   \`\`\`

3. Edit the \`.env\` file to customize your relay settings:
   \`\`\`
   nano .env
   \`\`\`

4. Build and start the Docker container:
   \`\`\`
   docker-compose build --no-cache
   docker-compose up -d
   \`\`\`

5. Monitor your relay:
   \`\`\`
   docker-compose exec tor-guard-relay nyx
   \`\`\`

## Configuration

You can customize your Tor relay by editing the following environment variables in the \`.env\` file:

- \`TOR_NICKNAME\`: The nickname for your relay (default: mydockerguard)
- \`CONTACT_INFO\`: Your contact information (default: anonymous@example.com)
- \`RELAY_PORT\`: The ORPort for your relay (default: 9101)
- \`DIR_PORT\`: The DirPort for your relay (default: 9030)
- \`RELAY_BANDWIDTH_RATE\`: The average rate of traffic your relay will allow (default: 3072 KB/s)
- \`RELAY_BANDWIDTH_BURST\`: The maximum burst of traffic your relay will allow (default: 4096 KB/s)
- \`TOR_SOCKS_PORT\`: The SOCKS port for Tor (default: 127.0.0.1:9050)
- \`EXTERNAL_ADDRESS\`: Your relay's public IP address (default: auto)
- \`CONTROL_PORT\`: The control port for Tor (default: 127.0.0.1:9051)
- \`USE_COOKIE_AUTH\`: Whether to use cookie authentication (default: 1)

## Security Considerations

- Ensure your server's firewall allows incoming connections on the relay port (default: 9101)
- Regularly update your Docker images and host system
- Monitor your relay for any suspicious activity
- Do not run an exit relay unless you fully understand the risks and legal implications

## Troubleshooting

- If your relay isn't connecting to the Tor network, check your firewall settings and ensure the relay port is open
- Verify that your \`EXTERNAL_ADDRESS\` is set correctly if your server is behind NAT
- Check the Docker logs for any error messages:
  \`\`\`
  docker-compose logs -f
  \`\`\`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

Running a Tor relay may have legal implications depending on your jurisdiction. Make sure you understand the laws in your area before running a relay. This software is provided as-is, without any warranty. Use at your own risk.

## Acknowledgments

- The Tor Project for their invaluable work on online privacy and anonymity
- The Docker community for providing a robust containerization platform
EOF

# Create .env file with default values
cat << EOF > .env
TOR_NICKNAME=mydockerguard
CONTACT_INFO=anonymous@example.com
RELAY_PORT=9101
DIR_PORT=9030
RELAY_BANDWIDTH_RATE=3072
RELAY_BANDWIDTH_BURST=4096
TOR_SOCKS_PORT=127.0.0.1:9050
EXTERNAL_ADDRESS=auto
CONTROL_PORT=127.0.0.1:9051
USE_COOKIE_AUTH=1
EOF

echo "All files have been created successfully!"
echo "Permissions have been set for tor-data and control_auth_cookie."
echo "Nyx configuration file has been created at ~/.nyx/config"
echo "README.md and .env files have been created."
echo "Remember to update your firewall/router to forward port 9101 to your Docker host!"
echo ""
echo "To start your Tor relay, run the following commands:"
echo "docker-compose build --no-cache"
echo "docker-compose up -d"
echo ""
echo "To view the logs, use:"
echo "docker-compose logs -f"

