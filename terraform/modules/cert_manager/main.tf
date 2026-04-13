resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true

      extraArgs = ["--enable-gateway-api"]
    })
  ]
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = "initops.aws@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }

        solvers = [
          {
            http01 = {
              gatewayHTTPRoute = {
                parentRefs = [
                  {
                    name      = "main-gateway"
                    namespace = var.app_namespace
                    kind      = "Gateway"
                  }
                ]
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "app-tls"
      namespace = var.app_namespace
    }
    spec = {
      secretName = "app-tls"

      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }

      dnsNames = [var.app_domain]
    }
  }

  depends_on = [kubernetes_manifest.cluster_issuer]
}
