ARG VERSION
FROM --platform=linux/amd64 nethermind/nethermind:${VERSION}

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    ca-certificates \
    curl \
    nginx \
    openssl \
    supervisor \
    vim-tiny \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up nginx config
RUN useradd -s /bin/false nginx
RUN mkdir -p /etc/nginx/certs/
WORKDIR /etc/nginx/certs/
RUN wget http://iso.ava.do/my.ava.do.crt && wget http://iso.ava.do/my.ava.do.key
COPY nginx.conf /etc/nginx

COPY supervisord.conf /etc/supervisord.conf

# Startup script
COPY start.sh /opt/start.sh
COPY reload-certs.sh /opt/reload-certs.sh
RUN chmod +x /opt/start.sh /opt/reload-certs.sh

WORKDIR /opt
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]