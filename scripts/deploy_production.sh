#!/bin/bash

set -e

APP_NAME="myapp-production"
ECR_URI="<YOUR_ECR_URI>"
PORT_EXTERNAL=8080
PORT_INTERNAL=80

cd /home/ubuntu/devops-deployment-automation

LAST_VERSION=$(cat last_version_production.txt)
PREVIOUS_VERSION=$(cat last_version_production.txt 2>/dev/null || echo "none")

echo "$LAST_VERSION" > previous_version_production.txt

echo "Pulling new image..."
docker pull $ECR_URI:$LAST_VERSION

echo "Stopping old container..."
docker stop $APP_NAME || true
docker rm $APP_NAME || true

echo "Starting new container..."
docker run -d \
  -p $PORT_EXTERNAL:$PORT_INTERNAL \
  --name $APP_NAME \
  $ECR_URI:$LAST_VERSION

echo "Running health check..."
sleep 5
STATUS=$(curl -s http://localhost:$PORT_EXTERNAL/health | grep -o "ok" || true)

if [ "$STATUS" != "ok" ]; then
  echo "Health check failed. Rolling back..."
  docker stop $APP_NAME
  docker rm $APP_NAME

  if [ "$PREVIOUS_VERSION" != "none" ]; then
    docker run -d \
      -p $PORT_EXTERNAL:$PORT_INTERNAL \
      --name $APP_NAME \
      $ECR_URI:$PREVIOUS_VERSION
  fi

  exit 1
fi

echo "Deployment successful!"
echo "$LAST_VERSION" > last_version_production.txt
