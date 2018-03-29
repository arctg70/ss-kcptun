� 版本
Forked from [cndocker/kcptun-socks5-ss-server](https://github.com/cndocker/kcptun-socks5-ss-server-docker)

| 软件 | 版本 |
| :--- | :--- |
| shadowsocks-libev |3.1.3 |
| kcptun | 20180316 |
oo
# 使用
## 启动命令 ����
```bash
docker run -d --name=ss-kcptun \
--restart=always \
-p 8388:8388 \
-p 8388:8388/udp \
-p 34567:34567/udp \
-p 8080:80 \
-e ROOT_PASSWORD=root \
-e SS_SERVER_ADDR=0.0.0.0 \
-e SS_SERVER_PORT=8388 \
-e SS_PASSWORD=password \
-e SS_METHOD=aes-256-gcm \
-e SS_DNS_ADDR=8.8.8.8 \
-e SS_UDP=faulse \
-e SS_FAST_OPEN=true \
-e KCPTUN_SS_LISTEN=34567 \
-e KCPTUN_KEY=password \
-e KCPTUN_CRYPT=aes \
-e KCPTUN_MODE=fast2 \
-e KCPTUN_MTU=1350 \
-e KCPTUN_SNDWND=512 \
-e KCPTUN_RCVWND=512 \
arctg70/ss-kcptun
```

## 变量说明（变量名区分大小写）
| 变量�| 默认� | 描述 |
| :----------------- |:--------------------:| :---------------------------------- |
| ROOT_PASSWORD      | root                 | root账户密码 |
| SS_SERVER_ADDR     | 0.0.0.0              | 提供服务的IP地址，建议使用默认的0.0.0.0  |
| SS_SERVER_PORT     | 8388                 | SS提供服务的端口，TCP和UDP协议�       |
| SS_PASSWORD        | password             | 服务密码                              |
| SS_METHOD          | aes-256-gcm          | 加密方式，可选参数：rc4-md5, aes-128-gcm, aes-192-gcm, aes-256-gcm, aes-128-cfb, aes-192-cfb, aes-256-cfb, aes-128-ctr, aes-192-ctr, aes-256-ctr, camellia-128-cfb, camellia-192-cfb, camellia-256-cfb, bf-cfb, chacha20-poly1305, chacha20-ietf-poly1305�salsa20, chacha20 and chacha20-ietf. |
| SS_TIMEOUT         | 600                  | 连接超时时间                          |
| SS_DNS_ADDR        | 8.8.8.8              | SS服务器的DNS地址                     |
| SS_UDP             | faulse                 | 关闭SS服务�UDP relay                |
| SS_FAST_OPEN       | true                 | 开启SS服务� TCP fast open.          |
| KCPTUN_SS_LISTEN   | 34567                | kcptun提供服务的端口，UDP协议           |
| KCPTUN_KEY         | password             | 服务密码                              |
| KCPTUN_CRYPT       | aes                  | 加密方式，可选参数：aes, aes-128, aes-192, salsa20, blowfish, twofish, cast5, 3des, tea, xtea, xor |
| KCPTUN_MODE        | fast2                | 加速模式，可选参数：fast3, fast2, fast, normal |
| KCPTUN_MTU         | 1350                 | MTU值，建议范围�00~1400              |
| KCPTUN_SNDWND      | 512                  | 服务器端发送参数，对应客户端rcvwnd       |
| KCPTUN_RCVWND      | 512                  | 服务器端接收参数，对应客户端sndwnd        |

### 备注1：kcp参数
    --crypt ${KCPTUN_CRYPT} --key ${KCPTUN_KEY} --mtu ${KCPTUN_MTU} --sndwnd ${KCPTUN_RCVWND} --rcvwnd ${KCPTUN_SNDWND} --mode ${KCPTUN_MODE}

### 备注2：带宽计算方�
    简单的计算带宽方法，以服务器发送带宽为例，其他类似�
    服务器发送带�SNDWND*MTU*8/1024/1024=1024*1350*8/1024/1024�0M
