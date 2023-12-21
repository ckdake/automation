#!/bin/bash

set -eou pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

tenantname="${PWD##*/}"
tenantname="${tenantname:-/}"

echo "running as:"
aws sts get-caller-identity --profile "${tenantname}-root"

aws iam create-role --role-name terraform --path /service-role/ --assume-role-policy-document file://"${SCRIPT_DIR}"/terraform-role-policy.json --profile "${tenantname}-root"

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name terraform --profile "${tenantname}-root"

terraform init

terraform apply
