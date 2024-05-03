#!/bin/bash
set -e

# The application artifacts, configuration, etc. must be owned by user csye6225 and group csye6225.
sudo chown -R csye6225:csye6225 /opt/myapp
sudo chmod -R 755 /opt/myapp

# install openjdk
sudo dnf install java-17-openjdk-devel -y

