#!/bin/bash

set -eou pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::"$ACCOUNT_ID":role/administrator --role-session-name prowler --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text)

AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | cut -f 1)
AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | cut -f 2)
AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | cut -f 3)
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

prowler aws --region us-east-1 \
    --allowlist-file allowlist.yaml \
    --output-modes html \
    --log-level WARNING \
    --excluded-checks ec2_elastic_ip_shodan \
    --security-hub
