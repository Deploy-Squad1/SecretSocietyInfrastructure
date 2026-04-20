# EKS Access (stage)

The cluster is private (no public endpoint). Access is done via IAM roles + SSM.

## 1. AWS profile

Ensure you have 'stage' and 'prod' profiles configured in  `~/.aws/config`:

```bash
[profile stage]
role_arn = arn:aws:iam::485141927994:role/TerraformDeployRole
source_profile = YOUR_SOURCE_PROFILE
region = eu-north-1

[profile prod]
role_arn = arn:aws:iam::963947738852:role/TerraformDeployRole
source_profile = YOUR_SOURCE_PROFILE
region = eu-north-1
```

- YOUR_SOURCE_PROFILE - refers to your AWS profile with access to the dev account (e.g. iac, default, etc)

Verify:

`aws sts get-caller-identity --profile <env>`

## 2. Update kubeconfig

```bash
aws eks update-kubeconfig \
  --name secret-society-<env> \
  --region eu-north-1
```

## 3. Fix TLS (hosts mapping)

To avoid TLS certificate mismatch, map the EKS endpoint to localhost:

```bash
sudo nano /etc/hosts
```

Add:

```bash
127.0.0.1 <EKS_ENDPOINT>
```

## 4. Start SSM tunnel to EKS API

```bash
export AWS_PROFILE=stage

aws ssm start-session \
  --target <admin_host_instance_id> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["<EKS_ENDPOINT>"],"portNumber":["443"],"localPortNumber":["8443"]}'
```

## 5. Verify access

```bash
kubectl get nodes
```

## Notes

- Tunnel must remain active while using kubectl (use another terminal)
- If connection fails, verify that SSM session is active and the correct cluster endpoint is used.
