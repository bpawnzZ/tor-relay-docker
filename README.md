# Tor Guard Relay Docker Setup with Nyx Monitoring

This repository contains scripts and configuration files to easily set up and run a Tor guard relay using Docker, with Nyx included for relay monitoring. Running a Tor relay helps improve the Tor network's capacity, speed, and resilience.

## Features

- Automated setup of a Tor guard relay in a Docker container
- Easy configuration through environment variables
- Includes Nyx for comprehensive relay monitoring
- Persistent data storage
- Secure default settings

## Prerequisites

- Docker
- Docker Compose
- Basic understanding of Tor relays and network configuration

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/tor-relay-docker.git
   cd tor-relay-docker
   ```

2. Run the setup script:
   ```
   ./setup.sh
   ```

3. Edit the `.env` file to customize your relay settings:
   ```
   nano .env
   ```

4. Build and start the Docker container:
   ```
   docker-compose build --no-cache
   docker-compose up -d
   ```

5. Monitor your relay:
   ```
   docker-compose exec tor-guard-relay nyx
   ```

## Configuration

You can customize your Tor relay by editing the following environment variables in the `.env` file:

- `TOR_NICKNAME`: The nickname for your relay (default: mydockerguard)
- `CONTACT_INFO`: Your contact information (default: anonymous@example.com)
- `RELAY_PORT`: The ORPort for your relay (default: 9001)
- `DIR_PORT`: The DirPort for your relay (default: 9030)
- `RELAY_BANDWIDTH_RATE`: The average rate of traffic your relay will allow (default: 3072 KB/s)
- `RELAY_BANDWIDTH_BURST`: The maximum burst of traffic your relay will allow (default: 4096 KB/s)
- `TOR_SOCKS_PORT`: The SOCKS port for Tor (default: 0.0.0.0:9050)
- `EXTERNAL_ADDRESS`: Your relay's public IP address (default: auto)
- `CONTROL_PORT`: The control port for Tor (default: 127.0.0.1:9051)
- `USE_COOKIE_AUTH`: Whether to use cookie authentication (default: 1)

## Security Considerations

- Ensure your server's firewall allows incoming connections on the relay port (default: 9001)
- Regularly update your Docker images and host system
- Monitor your relay for any suspicious activity
- Do not run an exit relay unless you fully understand the risks and legal implications

## Troubleshooting

- If your relay isn't connecting to the Tor network, check your firewall settings and ensure the relay port is open
- Verify that your `EXTERNAL_ADDRESS` is set correctly if your server is behind NAT
- Check the Docker logs for any error messages:
  ```
  docker-compose logs -f
  ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

Running a Tor relay may have legal implications depending on your jurisdiction. Make sure you understand the laws in your area before running a relay. This software is provided as-is, without any warranty. Use at your own risk.

## Acknowledgments

- The Tor Project for their invaluable work on online privacy and anonymity
- The Docker community for providing a robust containerization platform
