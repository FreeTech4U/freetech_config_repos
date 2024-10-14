#!/bin/bash

# Changer de répertoire
cd /mnt || { echo "Directory /mnt does not exist"; exit 1; }

# Liste des services définis dans docker-compose.yml (à mettre à jour si nécessaire)
services=("vote-module-api" "mysqldb" "promtail" "grafana" "loki")  # Ajoutez vos services ici

# Vérifier si le fichier docker-compose.yml existe et le supprimer
if [ -f "./docker-compose.yml" ]; then
  echo "docker-compose.yml exists. Deleting it..."
  rm -f ./docker-compose.yml
fi

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

echo MYSQL_HOST
echo DOCKER_NETWORK
echo API_IMAGE
echo IMAGE_TAG
echo API_CONTAINER_NAME
echo VOLUME_USER

# Se connecter à Docker Hub ou à un registre Docker privé
echo "Logging into Docker..."
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
if [ $? -ne 0 ]; then
  echo "Docker login failed. Exiting..."
  exit 1
fi

# Boucle sur chaque service de la liste
for service in "${services[@]}"; do
  echo "Checking container: $service"
  
  # Vérifier si le conteneur existe et est en cours d'exécution, puis le stopper et le supprimer
  if [ "$(docker ps -q -f name=$service)" ]; then
    echo "Container $service is running. Stopping and removing it..."
    docker stop $service || { echo "Failed to stop container $service"; exit 1; }
    docker rm $service || { echo "Failed to remove container $service"; exit 1; }
  elif [ "$(docker ps -a -q -f name=$service)" ]; then
    echo "Container $service exists but is not running. Removing it..."
    docker rm $service || { echo "Failed to remove container $service"; exit 1; }
  else
    echo "Container $service does not exist, proceeding..."
  fi
done

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

# Exécuter Docker Compose avec le fichier .env pour démarrer les services
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
