#!/bin/bash
sudo mkdir home/downloads
cd home/downloads
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key_id $AWS_ACCESS_KEY_ID
sudo yum install -y docker
sudo yum install -y git
sudo yum install -y java-1.8.0-openjdk
wget https://download.gocd.org/binaries/19.5.0-9272/rpm/go-agent-19.5.0-9272.noarch.rpm
sudo rpm -i go-agent-19.5.0-9272.noarch.rpm
sudo sed -i 's|127.0.0.1|${go-server-address}|g' /etc/default/go-agent
sudo /etc/init.d/go-agent start