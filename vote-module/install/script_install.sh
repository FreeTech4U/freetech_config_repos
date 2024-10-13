#!/bin/bash

# Changer de répertoire
cd /mnt || { echo "Directory /mnt does not exist"; exit 1; }

# Télécharger le fichier docker-compose.yml depuis GitHub
echo "Downloading docker-compose.yml from GitHub..."
wget -q --show-progress https://raw.githubusercontent.com/Jean741/ms-config-repo/main/docker/docker-compose.yml -O docker-compose.yml

# Vérifier si le téléchargement a réussi
if [ $? -eq 0 ]; then
  echo "docker-compose.yml downloaded successfully."
else
  echo "Failed to download docker-compose.yml. Exiting..."
  exit 1
fi

# Exécuter Docker Compose
echo "Starting Docker Compose..."
sudo docker-compose -f /mnt/docker-compose.yml up -d
