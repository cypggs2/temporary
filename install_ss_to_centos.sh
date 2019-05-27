yum -y install docker
service docker start
docker pull shadowsocks/shadowsocks-libev
docker run -e PASSWORD=4321 -e METHOD=aes-256-cfb -p 1234:8388 -p 1234:8388/udp -d --restart always shadowsocks/shadowsocks-libev
