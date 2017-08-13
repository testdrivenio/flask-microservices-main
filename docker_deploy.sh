#!/bin/sh

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

  if [ "$TRAVIS_BRANCH" == "staging" ]
  then

    JQ="jq --raw-output --exit-status"

    configure_aws_cli() {
    	aws --version
    	aws configure set default.region us-east-1
    	aws configure set default.output json
    	echo "AWS Configured!"
    }

    make_task_definition() {
      task_template=$(cat "$template")
      task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $AWS_ACCOUNT_ID)
      echo "$task_def"
    }

    register_definition() {
      if revision=$(aws ecs register-task-definition --cli-input-json "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
      else
        echo "Failed to register task definition"
        return 1
      fi
    }

    update service() {
      if [[ $(aws ecs update-service --cluster $cluster --service $service --task-definition $revision | $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
      fi
    }

    deploy_cluster() {

      cluster="flask-microservices-staging-cluster"

      # users
      family="flask-microservices-users-td"
    	service="flask-microservices-users"
      template="ecs_users_taskdefinition.json"
      make_task_definition
      register_definition
      update_service

      # client
      family="flask-microservices-client-td"
    	service="flask-microservices-client"
      template="ecs_client_taskdefinition.json"
      make_task_definition
      register_definition
      update_service

      # swagger
      family="flask-microservices-swagger-td"
    	service="flask-microservices-swagger"
      template="ecs_swagger_taskdefinition.json"
      make_task_definition
      register_definition
      update_service

    }

    configure_aws_cli
    deploy_cluster

  fi

fi
