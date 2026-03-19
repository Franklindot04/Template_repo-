#!/bin/bash
set -e

# Read staging version
STAGING_VERSION=$(cat last_version_staging.txt)

if [ "$STAGING_VERSION" = "none" ]; then
  echo "No staging version found. Deploy to staging first."
  exit 1
fi

echo "Promoting version: $STAGING_VERSION"

# Copy version to production version file
echo "$STAGING_VERSION" > last_version.txt

# Push the same image tag to production ECR
AWS_ACCOUNT_ID="787124622426"
AWS_REGION="us-east-1"

echo "Tagging image for production..."
docker tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp-staging:$STAGING_VERSION \
           $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp:$STAGING_VERSION

echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Pushing image to production ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp:$STAGING_VERSION

echo "Promoting to production environment..."
./scripts/deploy.sh
