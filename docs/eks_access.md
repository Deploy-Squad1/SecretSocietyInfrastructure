# EKS Access (dev)

## 1) AWS profile

Add to ~/.aws/config:

[profile dev-eks-<your-name>]
role_arn = arn:aws:iam::983988120210:role/dev-eks-admin-<your-name>
source_profile = <your-source-profile>
region = eu-north-1

* <your-source-profile> - your AWS profile with access to the dev account (e.g. iac, default, etc)

Test:
AWS_PROFILE=dev-eks-<your-name> aws sts get-caller-identity

---

## 2) Start tunnel

./eks-tunnel.sh

(keep this terminal open, use another one for commands)

---

## 3) kubeconfig (first time)

AWS_PROFILE=dev-eks-<your-name> aws eks update-kubeconfig \
  --name secret-society-dev \
  --region eu-north-1 \
  --kubeconfig ~/.kube/dev-tunnel

Edit ~/.kube/dev-tunnel:

- server: https://127.0.0.1:9443
- insecure-skip-tls-verify: true
- remove certificate-authority-data

---

## 4) kubectl

KUBECONFIG=~/.kube/dev-tunnel kubectl get ns

Optional:
alias kdev='KUBECONFIG=~/.kube/dev-tunnel kubectl'

With the alias, you can use kubectl by running:
kdev get ns
kdev get pods

---

## Notes
- tunnel must stay open
- dev only (TLS disabled)
- IAM roles used for access
