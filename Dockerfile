FROM alpine:latest
ENV KCPTUN_VER 20170525 
ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev.git \
    SS_DIR=shadowsocks-libev \
    CONF_DIR=/usr/local/conf \
    KCPTUN_URL="https://github.com/xtaci/kcptun/releases/download/v${KCPTUN_VER}/kcptun-linux-amd64-${KCPTUN_VER}.tar.gz" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN apk add --no-cache pcre bash openssl s6 lighttpd  && \
    apk add --no-cache --virtual  TMP autoconf automake build-base \
            wget curl tar gettext autoconf libtool \
            asciidoc xmlto libev-dev automake  \
            libsodium-dev libtool libsodium linux-headers \
            openssl-dev pcre-dev git  && \
    apk add --no-cache --virtual Dependent pcre-dev mbedtls-dev libsodium-dev udns-dev libev-dev && \
    git clone --recursive $SS_URL && \
    cd $SS_DIR && \
    git submodule update --init --recursive && \
    ./autogen.sh && ./configure && make && \
    make install && \
    cd .. && \
    rm -rf $SS_DIR && \
# Install kcptun
    mkdir -p ${CONF_DIR} && \
    mkdir -p ${KCPTUN_DIR} && cd ${KCPTUN_DIR} && \
    curl -sSL $KCPTUN_URL | tar xz -C ${KCPTUN_DIR}/ && \
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64 && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
# Install sshd
    apk add --no-cache openssh && \
    ssh-keygen -A && \
# Install nload
    apk add --no-cache nload && \
# Clean up
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache

ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN adduser www-data -G www-data -H -s /bin/false -D

# EXPOSE 80
COPY run.sh /run.sh
COPY s6.d /etc/s6.d
RUN chmod +x /run.sh /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
CMD ["/run.sh"]

