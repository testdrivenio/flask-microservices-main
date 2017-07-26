#!/bin/sh

if [ "$TRAVIS_BRANCH" == "development" ]; then
    docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
    export TAG="latest"
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

if [ "$TRAVIS_BRANCH" == "staging" ]; then
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -b ~/bin/aws
    export PATH=~/bin:$PATH
    # add AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY env vars
    eval $(aws ecr get-login --region us-east-1)
    export TAG="latest"
    # users
    docker build $USERS_REPO -t $USERS:$COMMIT
    docker tag $USERS:$COMMIT $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$USERS:$TAG
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$USERS:$TAG
    # users db
    docker build $USERS_DB_REPO -t $USERS_DB:$COMMIT
    docker tag $USERS_DB:$COMMIT $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$USERS_DB:$TAG
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$USERS_DB:$TAG
    # client
    docker build $CLIENT_REPO -t $CLIENT:$COMMIT
    docker tag $CLIENT:$COMMIT $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$CLIENT:$TAG
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$CLIENT:$TAG
    # swagger
    docker build $SWAGGER_REPO -t $SWAGGER:$COMMIT
    docker tag $SWAGGER:$COMMIT $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$SWAGGER:$TAG
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$SWAGGER:$TAG
    # nginx
    docker build $NGINX_REPO -t $NGINX:$COMMIT
    docker tag $NGINX:$COMMIT $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NGINX:$TAG
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NGINX:$TAG
fi
