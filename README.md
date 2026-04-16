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

- networking: VPC, subnets, internet gateway, route tables, security groups
- compute: EKS cluster, managed node group
- data: RDS PostgreSQL, S3 media bucket
- containers: ECR repositories
- access and secrets: IAM users/policies, AWS Secrets Manager
- ingress: Kubernetes Gateway API (NGINX Gateway Fabric)
- DNS (partial): Route53 hosted zone and records (currently stage environment)
- TLS: cert-manager with Let's Encrypt
- state: Terraform remote state (S3)
- monitoring: Splunk Cloud and Splunk Observability

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
terraform output
```

## S3 media bucket

Each environment has its own bucket:

- dev: `secret-society-media-ds`
- stage: `secret-society-media-ds-stage`
- prod: `secret-society-media-ds-prod`

Used by map-service for file uploads.

## Secrets

Secrets are stored in AWS Secrets Manager and are environment-specific.

### Application secrets

Managed via Terraform:

`secret-society/<service>-<env>`

Example: `secret-society/map-service`

Used for application configuration (e.g. API keys).

### RDS database secret

AWS automatically creates a secret for the RDS instance:

`rds!db-<random>`

- contains database credentials (username/password)
- managed by AWS
- rotated and maintained by RDS

A Makefile helper is provided to retrieve secrets from AWS Secrets Manager.

Retrieve secret values (run from root repo):

```bash
make get-secret ENV=<env> AWS_PROFILE=<profile>
```

Generate a local .env file automatically:

```bash
make env ENV=<env> AWS_PROFILE=<profile>
```

## Monitoring

Monitoring is implemented using Splunk.

### Logs

- collected via Splunk OTel Collector and sent to Splunk Cloud (HEC)
- available in Splunk, e.g.: `index=main`, `index=main k8s.namespace.name=secret-society-stage`, `index=main k8s.pod.name=frontend*`

### Metrics

- Kubernetes metrics enabled via metrics-server (`kubectl top`)
- CPU and other metrics available in Splunk Observability

## Notes

- AWS region: eu-north-1
- Secrets are not managed by Terraform values (only the secret container is managed)
- AWS credentials are currently used for development (IAM user)
- stage/prod access via TerraformDeployRole (configure in ~/.aws/config)
- Admin access to the cluster is provided via admid host (bastion EC2 using SSM). Documentation can be seen in docs/eks_access.md.
- DNS records must be updated if LoadBalancer is recreated.
  