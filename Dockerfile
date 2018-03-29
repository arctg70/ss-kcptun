FROM alpine:3.7
ENV KCPTUN_VER 20180316 
ENV LIBEV_VER 3.1.3
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${LIBEV_VER}/shadowsocks-libev-${LIBEV_VER}.tar.gz
ENV OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev.git \
    SS_DIR=shadowsocks-libev \
    CONF_DIR=/usr/local/conf \
    KCPTUN_URL="https://github.com/xtaci/kcptun/releases/download/v${KCPTUN_VER}/kcptun-linux-amd64-${KCPTUN_VER}.tar.gz" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN apk upgrade --update && \
	apk add --no-cache pcre c-ares mbedtls \
		bash openssl libsodium s6 lighttpd  && \
    apk add --no-cache --virtual  TMP \
		autoconf automake asciidoc build-base \
		curl c-ares-dev gettext \
		libtool libsodium-dev libev-dev linux-headers \
		mbedtls-dev \
		openssl-dev \
		pcre-dev \
		udns-dev \
		wget \
		xmlto \
		tar \
		git && \

# Install Shadowsock-libev

# way 1
    curl -sSLO ${SS_DOWNLOAD_URL} && \
    tar -zxf shadowsocks-libev-${LIBEV_VER}.tar.gz && \
    (cd shadowsocks-libev-${LIBEV_VER} && \
    ./configure --prefix=/usr --disable-documentation && \
    make install) && \
	rm -rf shadowsocks-libev-${LIBEV_VER} && \

# way 2
#    git clone --recursive -b v${LIBEV_VER} $SS_URL && \
#    (cd $SS_DIR && \
#	git submodule update --init --recursive && \
#    ./autogen.sh && \
#	./configure  --prefix=/usr --disable-documentation && \
#	make && make install ) && \
#    rm -rf $SS_DIR && \

# Install OBFS
	git clone ${OBFS_DOWNLOAD_URL} && \
	(cd simple-obfs && \
    git submodule update --init --recursive && \
    ./autogen.sh && ./configure --disable-documentation && \
    make && make install) && \
	rm -rf simple-obfs && \

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
    apk del TMP && \
    rm -rf /var/cache/apk/* ~/.cache

ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN adduser www-data -G www-data -H -s /bin/false -D

# EXPOSE 80
COPY run.sh /run.sh
COPY s6.d /etc/s6.d
RUN chmod +x /run.sh /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
CMD ["/run.sh"]

