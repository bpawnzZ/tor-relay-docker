FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    tor \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/tor

COPY run-tor.sh /run-tor.sh
RUN chmod +x /run-tor.sh

EXPOSE 9001 9030 9050

CMD ["/run-tor.sh"]
