#
# Dockerfile for Tor Relay Server
#
# This will build & install a Tor Debian package using
# the official instructions for installing Tor on Debian Jessie from source
# as detailed here https://www.torproject.org/docs/debian.html.en
#
# Usage:
#   docker run -d --restart=always -p 9001:9001 doudou34/tor-server

FROM debian:bullseye
LABEL MAINTAINER="Edouard COMTET<edouard.comtet@gmail.com>"

# If no Nickname is set, a random string will be added to 'Tor4'
ENV TOR_NICKNAME=Tor4
ENV TERM=xterm

RUN apt-get update \
    && apt-get install -y apt-transport-https wget gpg \
    && apt-get install -y unattended-upgrades apt-listchanges

# Copy docker-entrypoint
COPY ./scripts/ /usr/local/bin/
COPY tor.sources.list /etc/apt/sources.list.d/tor.list
COPY 50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
COPY 20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
RUN apt-get update \
    && apt-get install -y tor deb.torproject.org-keyring \
    && apt-get install -y pwgen \
    && apt-get -y purge --auto-remove \
    && apt-get clean

# Persist data
VOLUME /etc/tor /var/lib/tor

# ORPort, DirPort, ObfsproxyPort
EXPOSE 9001 9030 54444

ENTRYPOINT ["docker-entrypoint"]

CMD ["tor", "-f", "/etc/tor/torrc"]
