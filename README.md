# Secret Society Infrastructure

Terraform configuration for provisioning infrastructure used by the Secret Society project.

## Architecture

Multi-account setup with isolated environments:

- dev
- stage
- prod

Each environment:

- uses a separate AWS account
- has its own remote state (S3)
- is deployed independently

## Managed resources

- networking: VPC, subnets, internet gateway, route tables, security groups, VPC endpoints
- compute: EKS cluster, managed node group
- data: RDS PostgreSQL, S3 media bucket
- containers: ECR repositories
- access and secrets: IAM users/policies, AWS Secrets Manager
- state: Terraform remote state (S3)

## Prerequisites

- Terraform >= 1.14
- AWS CLI configured
- access to taget AWS accounts
- (optional) pre-commit

## Usage

Always run Terraform from environment directories:

```bash
cd terraform/environments/<env>
export AWS_PROFILE=<profile>

terraform init
terraform plan
terraform apply
```

## S3 media bucket

Each environment has its own bucket:

- dev: `secret-society-media-ds`
- stage: `secret-society-media-ds-stage`
- prod: `secret-society-media-ds-prod`

Used by map-service for file uploads.

## Secrets

Secrets are stored in AWS Secrets Manager and are environment-specific:

`secret-society/map-service-<env>`

- dev: configured (map-service-dev)
- stage/prod: not iitialized yet

A Makefile helper is provided to retrieve secrets from AWS Secrets Manager.

Retrieve secret values (run from root repo):

```bash
make get-secret ENV=<env> AWS_PROFILE=<profile>
```

Generate a local .env file automatically:

```bash
make env ENV=<env> AWS_PROFILE=<profile>
```

## Notes

- AWS region: eu-north-1
- Secrets are not managed by Terraform values (only the secret container is managed)
- AWS credentials are currently used for development (IAM user)
- stage/prod access via TerraformDeployRole (configure in ~/.aws/config)
- Planned improvement: migrate to IAM roles
  