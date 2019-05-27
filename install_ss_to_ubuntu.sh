#在ubuntu下安装shadowsocks
sudo apt-get update
sudo python --version
apt-get install python-gevent python-pip -y
pip install shadowsocks
cat <<EOF >/etc/shadowsocks.json
{
    "server":"0.0.0.0",
    "server_port":1234,
    "local_port":1080,
    "password":"4321",
    "timeout":60,
    "method":"aes-256-cfb"
}
EOF
sed -i 's\cleanup\reset\g' /usr/local/lib/python2.7/dist-packages/shadowsocks/crypto/openssl.py
nohup ssserver -c /etc/shadowsocks.json > /dev/null 2>&1 &


#ubuntu docker
#apt install docker.io
#docker pull shadowsocks/shadowsocks-libev
#docker run -e PASSWORD=4321 -e METHOD=aes-256-cfb -p 12345:8388 -p 12345:8388/udp -d --restart always shadowsocks/shadowsocks-libev
