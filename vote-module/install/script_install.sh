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
DOCKER_USERNAME=${DOCKER_USERNAME}
DOCKER_PASSWORD=${DOCKER_PASSWORD}
EOF

# Se connecter à Docker Hub ou à un registre Docker privé
echo "Logging into Docker..."
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
if [ $? -ne 0 ]; then
  echo "Docker login failed. Exiting..."
  exit 1
fi

# Vérifier si le conteneur vote-module-api existe et le forcer à s'arrêter et à être supprimé
CONTAINER_NAME="vote-module-api"
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
  echo "Container $CONTAINER_NAME exists. Stopping and removing it..."
  docker stop $CONTAINER_NAME || { echo "Failed to stop container $CONTAINER_NAME"; exit 1; }
  docker rm $CONTAINER_NAME || { echo "Failed to remove container $CONTAINER_NAME"; exit 1; }
else
  echo "Container $CONTAINER_NAME does not exist, continuing..."
fi

# Télécharger le fichier docker-compose.yml depuis GitHub
echo "Downloading docker-compose.yml from GitHub..."
wget -q --show-progress https://raw.githubusercontent.com/FreeTech4U/freetech_config_repos/refs/heads/main/vote-module/docker/docker-compose.yml -O ./docker-compose.yml

# Vérifier si le téléchargement a réussi
if [ $? -eq 0 ]; then
  echo "docker-compose.yml downloaded successfully."
else
  echo "Failed to download docker-compose.yml. Exiting..."
  exit 1
fi

# Exécuter Docker Compose avec le fichier .env et redémarrer le conteneur
echo "Starting Docker Compose with .env file..."
sudo docker-compose --env-file .env -f ./docker-compose.yml up -d
if [ $? -eq 0 ]; then
  echo "Docker Compose started successfully."
else
  echo "Failed to start Docker Compose. Exiting..."
  exit 1
fi

# Se déconnecter de Docker après l'exécution
echo "Logging out from Docker..."
docker logout
if [ $? -eq 0 ]; then
  echo "Successfully logged out from Docker."
else
  echo "Failed to log out from Docker."
fi
