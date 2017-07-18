#!/bin/sh

echo "test"

if [ $TRAVIS_BRANCH != "master" ]; then
    docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
    export TAG=`if [ "$TRAVIS_BRANCH" == "master" ]; then echo "latest"; else echo $TRAVIS_BRANCH ; fi`
    # users
    docker build $USERS_REPO -t $USERS:$COMMIT
    docker tag $USERS:$COMMIT $DOCKER_ID/$USERS:$TAG
    docker push $DOCKER_ID/$USERS
    # users db
    docker build $USERS_DB_REPO -t $USERS_DB:$COMMIT
    docker tag $USERS_DB:$COMMIT $DOCKER_ID/$USERS_DB:$TAG
    docker push $DOCKER_ID/$USERS_DB
    # client
    docker build $CLIENT_REPO -t $CLIENT:$COMMIT
    docker tag $CLIENT:$COMMIT $DOCKER_ID/$CLIENT:$TAG
    docker push $DOCKER_ID/$CLIENT
    # swagger
    docker build $SWAGGER_REPO -t $SWAGGER:$COMMIT
    docker tag $SWAGGER:$COMMIT $DOCKER_ID/$SWAGGER:$TAG
    docker push $DOCKER_ID/$SWAGGER
    # nginx
    docker build $NGINX_REPO -t $NGINX:$COMMIT
    docker tag $NGINX:$COMMIT $DOCKER_ID/$NGINX:$TAG
    docker push $DOCKER_ID/$NGINX
fi
