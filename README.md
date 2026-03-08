# Secret Society Infrastructure

Terraform configuration for provisioning infrastructure used by the Secret Society project.

Currently managed resources:

- AWS ECR repositories for project microservices
- S3 bucket for media storage
- IAM user for map-service with S3 permissions
- Terraform remote state stored in S3

## Repositories created

- core-service
- frontend-service
- email-service
- map-service
- voting-service

## Prerequisites

- Terraform >= 1.14
- AWS credentials with required permissions.
- pre-commit (optional but recommended)

## Usage

Export AWS profile before running Terraform:

```bash
export AWS_PROFILE=<profile>
```

Initialize Terraform:

```bash
terraform init
```

Check the execution plan:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

## Notes

- AWS CLI credentials must be configured locally.
- AWS region: eu-north-1 (defined in Terraform provider configuration).
- S3 media storage bucket is used by map-service to generate presigned URLs for uploads.
