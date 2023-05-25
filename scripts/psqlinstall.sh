#!/bin/bash
echo 'This instance was provisioned by Terraform.' | sudo tee /etc/motd

ps aux | grep -i apt

while fuser /var/lib/apt/lists/lock > /dev/null 2>&1 ; do
echo "Waiting for other apt instances to exit"
sleep 1
done

while fuser /var/lib/dpkg/lock-frontend > /dev/null 2>&1 ; do
echo "Waiting for other apt instances to exit"
sleep 1
done

sudo apt install apt-transport-https ca-certificates wget libjson-perl ssl-cert  libllvm14 sysstat -y
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-14  postgresql-common
sudo -u postgres createuser openproject
sudo -u postgres createdb openproject
sudo -u postgres psql -c "alter user openproject with encrypted password 'WelCome2021##';"
sudo -u postgres psql -c "grant all privileges on database openproject to openproject;"
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 5432 -j ACCEPT
sudo netfilter-persistent save
echo listen_addresses = \'*\' | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo 'host        all                    all                 0.0.0.0/0                           md5' | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
echo 'host        all                    all                 ::/0                                md5' | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
sudo service postgresql restart