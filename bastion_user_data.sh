#!/bin/bash -v

export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y
apt install -y git mysql-client-core-5.7 iptables-persistent
iptables -t nat -I POSTROUTING -s "${cidr_block}" -j MASQUERADE
/sbin/iptables-save > /etc/iptables/rules.v4
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sed -i 's/#Port 22/Port 7272/' /etc/ssh/sshd_config
sudo sysctl -p
reboot