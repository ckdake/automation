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
1. Create a  `tenants/${TENANTNAME}` folder, copy a `main.tf` from another tenant,
   and update the account id in the `provider` block and the backend `key` block.
   (TODO(ckdake): move this to a terragrunt template)
1. cd into `tenants/${TENANTNAME}` and run `../../scripts/bootstrap-tenant.sh`

### Using the app-workspace tenant

This is a unique tenant, as a proof-of-concept for using Terraform workspaces and
persisting some state. This could be used to manage a "review-app" pattern.

Each workspace stores some output in it's state, in a way that is usable in future
`terraform apply` runs. The use case is for situations where different jobs in different
places need to make changes to the same terraform-managed application. One example is
separate pipelines for "frontend" and "backend" that both use a `terraform apply` to
update an ECS task definition, for either the frontent or the backend. We don't want
the frontend pipeline to know about the changes to the task defintion for the backend
task. Any time `terraform apply` is run, it will only change things that are passed in
via TF_VAR env vars, and all other things will persist. Defaults are set in the locals.tf.

```bash
cd tenants/app-workspace
terraform workspace select -or-create my-app-one
TF_VAR_config_value_one=test1 terraform apply
TF_VAR_config_value_two=test2 terraform apply
```

### TODO

- [ ] implement "automation:prod" pattern of docker container to run jobs
- [ ] implement Application/Environment tagging, including in modules
- [ ] implement SSO into AWS from somewhere
- [ ] Sample-app
  - [ ] automatic deploy on container push to ECR
  - [ ] talk to an AWS Serverless V2
  - [ ] talk to an ElasticCache
  - [ ] Use a Secret
  = [ ] Cloudwatch dashboard
- [ ] saml2aws for logging in, what to use for IdP?
- [ ] import everything in root account, test1 account, test2 account
  - dhcp options, internet gateway, org delegation config
- [ ] get prowler checks to 100% green
- [ ] setup github actions for terraform plan, terraform apply, prowler
- [ ] terraform plugin caching
- [ ] lots more
