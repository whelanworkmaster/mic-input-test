#!/bin/sh

echo "=========== Building Frontend: Pull image from ECR to Dev server and start =============="

COMMIT_HASH=$(git log -1 --format=%H)
TAG=$DOCKER_ECR_REPO/$DOCKER_IMAGE_REPO:$COMMIT_HASH

#Note DEV_INSTANCE_LOGIN_ADDRESS currently points to direct instance ip, no elastic ip, so will need to change when box is bounced.

ssh -o StrictHostKeyChecking=no -i "$PEM_FILE_LOCATION"  -t $DEV_INSTANCE_LOGIN_ADDRESS << EOF
$(aws ecr get-login --no-include-email --region $AWS_REGION)
docker kill $DOCKER_IMAGE_REPO
docker rm $DOCKER_IMAGE_REPO
docker pull $TAG
docker run --name=$DOCKER_IMAGE_REPO -d -p 80:80 $TAG
EOF
