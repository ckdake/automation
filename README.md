# Automation

## Terraform for AWS plaground

This requires env vars with user credentials that can assume to adminstrator.
If `aws sts get-caller-identity` works, you are good, otherwise:

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Currently only works in `tenants/management` with `terraform apply`.

Run `prowler` to populate Security Hub with any breaking things it fines by:
`cd tools/prowler/ && ./install-prowler.sh && ./run-prowler.sh`

### TODO

- [ ] linters and formatters etc
- [ ] saml2aws for logging in, what to use for IdP?
- [ ] get test1 and test2 accounts working with `terraform apply`
- [ ] import everything in root account, test1 account, test2 account
- [ ] get prowler checks to 100% green
- [ ] setup github actions for terraform plan, terraform apply, prowler
- [ ] terraform plugin caching
- [ ] Setup AWS Config
- [ ] lots more
