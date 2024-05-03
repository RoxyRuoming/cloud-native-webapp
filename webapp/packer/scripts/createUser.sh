#!/bin/bash
set -e

# # check if user csye6225 exists
# if id "csye6225" &>/dev/null; then
#     echo "User 'csye6225' already exists. Skipping user creation."
# else
#     # create user csye6225
#     if ! getent group csye6225 >/dev/null; then
#         sudo groupadd csye6225
#     fi
#     sudo useradd -r -m -d /opt/csye6225 -s /usr/sbin/nologin -g csye6225 csye6225
#     echo "User 'csye6225' created successfully."
# fi

sudo groupadd csye6225
sudo useradd -g csye6225 -s /usr/sbin/nologin csye6225




