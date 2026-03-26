# EKS Access (dev)

The cluster is private (no public endpoint). Access is done via IAM roles + SSM.

## 1.  AWS profile

Add to ~/.aws/config:

[profile team]\
role_arn = arn:aws:iam::ACCOUNT_ID:role/team-access-dev\
source_profile = YOUR_SOURCE_PROFILE\
region = eu-north-1

[profile eks-admin]\
role_arn = arn:aws:iam::ACCOUNT_ID:role/eks-admin-dev\
source_profile = team\
region = eu-north-1

- ACCOUNT_ID - refers to the AWS accout ID (dev)
- YOUR_SOURCE_PROFILE - refers to your AWS profile with access to the dev account (e.g. iac, default, etc)

Verify:\
aws sts get-caller-identity --profile eks-admin

## 2. Access via admin host

Set profile:

export AWS_PROFILE=eks-admin

Start SSM session:

aws ssm start-session --target <admin_host_instance_id>

Inside EC2:

```bash
aws eks update-kubeconfig \
  --name secret-society-dev \
  --region eu-north-1

kubectl get nodes
```

## 3. Optional: access via SSM tunel

Start port-forwarding:

```bash
aws ssm start-session \
  --target <admin_host_instance_id> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["<EKS_ENDPOINT>"],"portNumber":["443"],"localPortNumber":["8443"]}'
```

Then configure kubeconfig to use:

https://localhost:8443

## Notes

- Access works only from inside VPC (via SSM)
- If access fails, check your AWS profile (eks-admin)
