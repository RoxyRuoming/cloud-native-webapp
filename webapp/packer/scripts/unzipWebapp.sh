#!/bin/bash

sét -e

# install zip tool and unzip webapp.zip
sudo dnf install unzip -y

cd /opt/myapp
unzip webapp.zip