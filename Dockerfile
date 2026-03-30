FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      iproute2 \
      dnsutils \
      sqlite3 \
      docker-cli \
      ca-certificates \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY update.sh /app/update.sh

CMD ["/app/update.sh"]
