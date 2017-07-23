#!/bin/sh

docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
docker pull $DOCKER_ID/$USERS
docker pull $DOCKER_ID/$USERS_DB
docker pull $DOCKER_ID/$CLIENT
docker pull $DOCKER_ID/$SWAGGER
docker pull $DOCKER_ID/$NGINX

docker-compose -f docker-compose-ci.yml up -d --build
