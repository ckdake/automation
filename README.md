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

### TODO

- [ ] Sample-app
  - [ ] get container image pulling from internet (resolve "CannotPullContainerError: pull image manifest has been retried 5 time(s): failed to resolve ref docker.io/library/latest:latest: failed to do request: Head "<https://registry-1.docker.io/v2/library/latest/manifests/latest>": dial tcp 44.205.64.79:443: i/o timeout")
  - [ ] get it booting
  - [ ] get it talking to the internet
  - [ ] move to test1 account
  - [ ] automatic deploy on container push to ECR
  - [ ] talk to an AWS Serverless V2
  - [ ] talk to an ElasticCache
  - [ ] Use a Secret
- [ ] linters and formatters etc
- [ ] saml2aws for logging in, what to use for IdP?
- [ ] get test1 and test2 accounts working with `terraform apply`
- [ ] import everything in root account, test1 account, test2 account
- [ ] get prowler checks to 100% green
- [ ] setup github actions for terraform plan, terraform apply, prowler
- [ ] terraform plugin caching
- [ ] Setup AWS Config
- [ ] lots more
