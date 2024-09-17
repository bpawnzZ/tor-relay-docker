FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y     gnupg     wget     python3     python3-pip     && rm -rf /var/lib/apt/lists/*

# Add Tor repository
RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | tee /etc/apt/sources.list.d/tor.list

# Install Tor and Nyx
RUN apt-get update && apt-get install -y     tor     deb.torproject.org-keyring     && rm -rf /var/lib/apt/lists/*

RUN pip3 install nyx

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/tor /etc/tor
RUN chown -R debian-tor:debian-tor /var/lib/tor /etc/tor
RUN chmod 700 /var/lib/tor

# Copy a script to run Tor with our custom config
COPY run-tor.sh /run-tor.sh
RUN chmod +x /run-tor.sh

# Expose the necessary ports
EXPOSE 9001 9030 9050 9051

# Switch to the debian-tor user
USER debian-tor

# Run Tor
CMD ["/run-tor.sh"]
