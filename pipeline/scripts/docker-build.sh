#!/bin/sh

$(aws ecr get-login --no-include-email --region $AWS_REGION)

COMMIT_HASH=$(git log -1 --format=%H)

TAG=$DOCKER_ECR_REPO/$DOCKER_IMAGE_REPO:$COMMIT_HASH

LATEST_TAG=$DOCKER_ECR_REPO/$DOCKER_IMAGE_REPO:latest

IMAGE=$(docker images $LATEST_TAG --format "{{.ID}}")

echo "=========== Building Frontend: Removing previous docker image =============="

docker rmi -f $IMAGE

echo "=========== Building Frontend: Building the docker image =============="

docker build -t $TAG ./frontend
docker tag $TAG $LATEST_TAG
docker tag $TAG frontend

echo "=========== Building Frontend: Building the docker test image =============="

docker build -t frontend -f ./frontend/Dockerfile.test .

echo "=========== Building Frontend: Running the docker test image =============="

docker run -rm frontend

echo "=========== Building Frontend: Pushing Image to AWS ECR Repo =============="

docker push $TAG
docker push $LATEST_TAG