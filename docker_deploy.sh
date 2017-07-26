#!/bin/sh

if [ "$TRAVIS_BRANCH" == "development" ]; then
    docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
    export TAG="development"
    export REPO=$DOCKER_ID
fi

if [ "$TRAVIS_BRANCH" == "staging" ]; then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -b ~/bin/aws
    export PATH=~/bin:$PATH
    # add AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env vars
    eval $(aws ecr get-login --region us-east-1)
    export TAG="staging"
    export REPO=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
fi

# users
docker build $USERS_REPO -t $USERS:$COMMIT
docker tag $USERS:$COMMIT $REPO/$USERS:$TAG
docker push $REPO/$USERS:$TAG
# users db
docker build $USERS_DB_REPO -t $USERS_DB:$COMMIT
docker tag $USERS_DB:$COMMIT $REPO/$USERS_DB:$TAG
docker push $REPO/$USERS_DB:$TAG
# client
docker build $CLIENT_REPO -t $CLIENT:$COMMIT
docker tag $CLIENT:$COMMIT $REPO/$CLIENT:$TAG
docker push $REPO/$CLIENT:$TAG
# swagger
docker build $SWAGGER_REPO -t $SWAGGER:$COMMIT
docker tag $SWAGGER:$COMMIT $REPO/$SWAGGER:$TAG
docker push $REPO/$SWAGGER:$TAG
# nginx
docker build $NGINX_REPO -t $NGINX:$COMMIT
docker tag $NGINX:$COMMIT $REPO/$NGINX:$TAG
docker push $REPO/$NGINX:$TAG
