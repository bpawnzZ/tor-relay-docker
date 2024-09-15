# Tor Guard Relay Docker Setup

This repository contains a Docker setup for running a Tor guard relay. It's designed to be easy to deploy and configure, allowing you to contribute to the Tor network with minimal hassle.

## 🚀 Features

- Runs a Tor guard relay in a Docker container
- Easy configuration through environment variables
- Uses the latest Tor version from Debian repositories
- Customizable bandwidth and ports

## 🛠 Prerequisites

- Docker
- Docker Compose

## 🏗 Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/tor-guard-relay-docker.git
   cd tor-guard-relay-docker
   ```

2. Customize the `docker-compose.yml` file with your preferred settings.

3. Build and start the container:
   ```
   docker-compose up -d
   ```

## ⚙️ Configuration

Edit the `docker-compose.yml` file to customize your relay. Here are the available environment variables:

- `TOR_NICKNAME`: Your relay's nickname
- `CONTACT_INFO`: Your contact email (use a throwaway if you want to stay anonymous)
- `RELAY_PORT`: ORPort for Tor traffic (default: 9001)
- `DIR_PORT`: DirPort for directory information (default: 9030)
- `RELAY_BANDWIDTH_RATE`: Bandwidth rate limit in KB/s
- `RELAY_BANDWIDTH_BURST`: Burst bandwidth limit in KB/s
- `TOR_SOCKS_PORT`: SOCKS port (default: 9050)

## 🔒 Security Considerations

- Ensure your server is properly secured
- Keep your Docker and Tor versions up to date
- Monitor your relay for any unusual activity

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you have any questions or run into issues, please open an issue in this repository.

Remember to stay safe and respect the privacy of Tor users. Happy relaying! 🌐
