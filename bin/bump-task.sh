#!/usr/bin/env bash
# Updates a ECS task definition by updating the container definition to the image received as parameter

set -eu

REGION=eu-west-1

SERVICE_NAME=web
TASK_DEFINITION_NAME=hoshinplan
CONTAINER_IMAGE=gabriprat/hoshinplan
CI_COMMIT_SHA=$1

TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$REGION" --profile hoshinplan)

NAME=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.family')

CONTAINER_DEFINITIONS=$(echo $TASK_DEFINITION \
                        | jq --arg IMAGE "$CONTAINER_IMAGE:$CI_COMMIT_SHA" '.taskDefinition.containerDefinitions[0].image=$IMAGE' \
                        | jq --arg VERSION $CI_COMMIT_SHA  '.taskDefinition.containerDefinitions[0].environment |= map((select(.name == "APP_VERSION") | .value) |= $VERSION)' \
                        | jq '.taskDefinition.containerDefinitions')

EXECUTION_ROLE_ARN=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.executionRoleArn')

echo "Registering new task definition <${TASK_DEFINITION_NAME}> with new Docker image <${CONTAINER_IMAGE}:${CI_COMMIT_SHA}>"

NEW_TASK_DEFINITION=$(aws ecs register-task-definition \
  --family "$TASK_DEFINITION_NAME" \
  --region "$REGION" \
  --container-definitions "$CONTAINER_DEFINITIONS" \
  --profile hoshinplan)

NEW_REVISION=$(echo $NEW_TASK_DEFINITION | jq -r '.taskDefinition.revision')

echo "Updating service <${SERVICE_NAME}> with new task definition <${TASK_DEFINITION_NAME}:${NEW_REVISION}>"

aws ecs update-service --cluster default --service $SERVICE_NAME --task-definition $TASK_DEFINITION_NAME:$NEW_REVISION --region eu-west-1 --profile hoshinplan > /dev/null