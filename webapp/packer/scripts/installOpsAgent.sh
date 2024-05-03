#!/bin/bash
set -e

sudo mkdir -p /tmp/myapp
sudo chown -R csye6225:csye6225 /tmp/myapp
sudo chmod -R 755 /tmp/myapp

# install ops agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# copy the configuration file 
sudo cp /opt/myapp/config.yaml /etc/google-cloud-ops-agent/config.yaml

# restart ops agent
sudo systemctl restart google-cloud-ops-agent