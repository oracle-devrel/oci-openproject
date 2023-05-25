#!/bin/bash
while fuser /var/lib/apt/lists/lock > /dev/null 2>&1 ; do
echo "Waiting for other apt instances to exit"
ps aux | grep -i apt
sleep 1
done

while fuser /var/lib/dpkg/lock-frontend > /dev/null 2>&1 ; do
echo "Waiting for other apt instances to exit"
ps aux | grep -i apt
sleep 1
done

sudo apt update -y
sudo apt install apt-transport-https ca-certificates wget -y
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -
sudo wget -O /etc/apt/sources.list.d/openproject.list https://dl.packager.io/srv/opf/openproject/stable/12/installer/ubuntu/22.04.repo
sudo apt update -y
sudo apt install openproject -y
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo netfilter-persistent save
