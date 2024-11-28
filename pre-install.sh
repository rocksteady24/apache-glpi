#!/bin/bash

set -o allexport; source .env; set +o allexport;
mkdir -p ./storage/glpi-files
cd ./storage/glpi-files
wget https://github.com/glpi-project/glpi/releases/download/${SOFTWARE_VERSION_TAG}/glpi-${SOFTWARE_VERSION_TAG}.tgz
tar -xzf glpi-${SOFTWARE_VERSION_TAG}.tgz --strip-components=1
rm glpi-${SOFTWARE_VERSION_TAG}.tgz
chown -R www-data:www-data ../glpi-files
