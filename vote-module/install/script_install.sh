#!/bin/bash

# Changer de répertoire
cd /mnt || { echo "Directory /mnt does not exist"; exit 1; }

# Créer un fichier .env pour Docker Compose avec les variables d'environnement
echo "Creating .env file..."
cat <<EOF > .env
MYSQL_HOST=mysqldb
DOCKER_NETWORK=vote-module-net
MYSQL_EXTERNAL_PORT=3306
MYSQL_INTERNAL_PORT=3306
MYSQL_DATABASE=voteDB
MYSQL_ROOT_PASSWORD=aV2lTubodbb589Motu
VOLUME_USER=/mnt/vote-module-data
VOLUME_MYSQL=/var/lib/mysql
API_EXTERNAL_PORT=8081
API_INTERNAL_PORT=8081
API_IMAGE=vote-module-api
IMAGE_TAG=prod
API_CONTAINER_NAME=vote-module-api
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
