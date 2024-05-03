#!/bin/bash
set -e

SERVICE_FILE=webapp.service
# copy the service file to /etc/systemd/system
sudo cp /opt/myapp/${SERVICE_FILE} /etc/systemd/system/${SERVICE_FILE}

# reload the systemd manager configuration
sudo systemctl daemon-reload

# start the service
sudo systemctl enable ${SERVICE_FILE}

echo "Service start successfully!"



