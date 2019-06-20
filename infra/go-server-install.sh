#!/bin/bash
sudo mkdir home/downloads
cd home/downloads
sudo yum install -y git
sudo yum install -y java-1.8.0-openjdk
wget https://download.gocd.org/binaries/19.5.0-9272/rpm/go-server-19.5.0-9272.noarch.rpm
sudo rpm -i go-server-19.5.0-9272.noarch.rpm
/etc/init.d/go-server start