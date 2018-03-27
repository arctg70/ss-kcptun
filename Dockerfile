FROM alpine:latest
ENV KCPTUN_VER 20180316 
#ENV LIBEV_VER 3.1.3
#ENV OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev.git \
    SS_DIR=shadowsocks-libev \
    CONF_DIR=/usr/local/conf \
    KCPTUN_URL="https://github.com/xtaci/kcptun/releases/download/v${KCPTUN_VER}/kcptun-linux-amd64-${KCPTUN_VER}.tar.gz" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN apk upgrade --update && \
	apk add --no-cache pcre bash openssl libsodium s6 lighttpd  && \
    apk add --no-cache --virtual  TMP autoconf automake build-base \
            wget curl tar gettext  libtool \
            asciidoc xmlto c-ares-dev libev-dev \
            libsodium-dev   linux-headers \
			pcre-dev mbedtls-dev  udns-dev  \
            openssl-dev  git  && \
    git clone --recursive $SS_URL && \
    (cd $SS_DIR && \
    ./autogen.sh && 
	./configure --prefix=/usr --disable-documentation && \
	make && make install ) && \
#	git clone ${OBFS_DOWNLOAD_URL} && \
#	(cd simple-obfs && \
#    git submodule update --init --recursive && \
#    ./autogen.sh && ./configure --disable-documentation && \
#    make && make install) && \
#    git submodule update --init --recursive && \
#    ./autogen.sh && ./configure --disable-documentation && \
#	make && make install && \
#    cd .. && \
    rm -rf $SS_DIR && \
#	rm -rf simple-obfs && \
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

