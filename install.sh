#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the current working directory
CURRENT_LOCATION=$(pwd)

# Load environment variables from .env file
set -o allexport; source .env; set +o allexport;

# Create necessary directories
mkdir -p ./storage/glpi-files

# Change to the glpi-files directory
cd ./storage/glpi-files

# Download the GLPI package
if ! wget https://github.com/glpi-project/glpi/releases/download/${SOFTWARE_VERSION_TAG}/glpi-${SOFTWARE_VERSION_TAG}.tgz; then
    echo "Error: Failed to download GLPI package."
    exit 1
fi

# Extract the downloaded package
if ! tar -xzf glpi-${SOFTWARE_VERSION_TAG}.tgz --strip-components=1; then
    echo "Error: Failed to extract GLPI package."
    exit 1
fi

# Remove the downloaded tarball
rm glpi-${SOFTWARE_VERSION_TAG}.tgz

# Change ownership of the files
chown -R www-data:www-data ../glpi-files

# Create the systemd service file
SERVICE_FILE="/etc/systemd/system/glpi.service"
echo "\
[Unit]
Description=GLPI Docker Compose Service
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=${CURRENT_LOCATION}
Restart=always
ExecStart=/usr/bin/docker compose -f glpi.yml up --build
ExecStop=/usr/bin/docker compose -f glpi.yml down

[Install]
WantedBy=multi-user.target
" > "$SERVICE_FILE"

# Reload systemd to recognize the new service
if ! systemctl daemon-reload; then
    echo "Error: Failed to reload systemd."
    exit 1
fi

# Start the GLPI service
if ! systemctl start glpi; then
    echo "Error: Failed to start GLPI service."
    exit 1
fi

# Enable the GLPI service to start on boot
if ! systemctl enable glpi; then
    echo "Error: Failed to enable GLPI service."
    exit 1
fi

echo "GLPI service has been successfully set up and started."
