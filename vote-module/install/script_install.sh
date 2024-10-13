#!/bin/bash

# Changer de répertoire
cd /mnt || { echo "Directory /mnt does not exist"; exit 1; }

# Créer un fichier .env pour Docker Compose avec les variables d'environnement
echo "Creating .env file..."
cat <<EOF > .env
MYSQL_HOST=${MYSQL_HOST}
DOCKER_NETWORK=${DOCKER_NETWORK}
MYSQL_EXTERNAL_PORT=${MYSQL_EXTERNAL_PORT}
MYSQL_INTERNAL_PORT=${MYSQL_INTERNAL_PORT}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
VOLUME_USER=${VOLUME_USER}
VOLUME_MYSQL=${VOLUME_MYSQL}
API_EXTERNAL_PORT=${API_EXTERNAL_PORT}
API_INTERNAL_PORT=${API_INTERNAL_PORT}
API_IMAGE=${API_IMAGE}
IMAGE_TAG=${IMAGE_TAG}
API_CONTAINER_NAME=${API_CONTAINER_NAME}
EOF

# Télécharger le fichier docker-compose.yml depuis GitHub
echo "Downloading docker-compose.yml from GitHub..."
wget -q --show-progress https://raw.githubusercontent.com/FreeTech4U/freetech_config_repos/refs/heads/main/vote-module/docker/docker-compose.yml -O docker-compose.yml

# Vérifier si le téléchargement a réussi
if [ $? -eq 0 ]; then
  echo "docker-compose.yml downloaded successfully."
else
  echo "Failed to download docker-compose.yml. Exiting..."
  exit 1
fi

# Exécuter Docker Compose avec le fichier .env
echo "Starting Docker Compose with .env file..."
sudo docker-compose --env-file .env -f /mnt/docker-compose.yml up 
