# Automation

## Terraform for AWS plaground

The goal of this AWS setup is to have an automated AWS Organization set up that:

1. Is fully compliant with SOC2
1. Is fully compliant with AWS, CIS, and NIST security standards.
1. Has minimal AWS cost overhead
1. Facilitates easily testing out things in AWS test accounts

Things to have readily available to be able to test other things:

1. a docker container in ECR running as an ECS service
1. lambdas triggered by EventBridge

### Running locally

This requires env vars with user credentials that can assume to adminstrator.
If `aws sts get-caller-identity` works, you are good, otherwise:

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Currently only works in `tenants/management` with `terraform apply`.

Run `prowler` to populate Security Hub with any breaking things it fines by:
`cd tools/prowler/ && ./install-prowler.sh && ./run-prowler.sh`

Run `trivy` to scan for vulns:
`cd tenants/management/ && trivy config . --ignorefile ./.trivyignore.yaml`

### Bootstrapping a new account

1. Add the account in tenants/management/organization.tf and `terraform apply`
1. Log into the account's root user with "forgot password" and get some keys, set up profile
1. Create a  `tenants/tenantname` folder and copy data.tf, kms.tf, and main.tf,
   and update the account id in the `provider` block and the backend `key` block.
   (TODO(ckdake): move this to a terragrunt template)
1. Edit `scripts/bootstrap-tenant.sh` and run it.

### TODO

- [ ] Sample-app
  - [ ] automatic deploy on container push to ECR
  - [ ] talk to an AWS Serverless V2
  - [ ] talk to an ElasticCache
  - [ ] Use a Secret
- [ ] saml2aws for logging in, what to use for IdP?
- [ ] import everything in root account, test1 account, test2 account
- [ ] get prowler checks to 100% green
- [ ] setup github actions for terraform plan, terraform apply, prowler
- [ ] terraform plugin caching
- [ ] lots more
