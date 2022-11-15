/*terraform{
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.72.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}
*/
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
/*
provider "helm" {
  kubernetes {
    #    client_key             = tls_private_key.this.private_key_pem
    host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
provider "http" {
  # Configuration options
}
*/

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni", "coredns"])

  addon_name         = each.value
  kubernetes_version = data.aws_eks_cluster.cluster.version
  most_recent        = true
}

data "aws_eks_addon_version" "default" {
  for_each = toset(["kube-proxy"])

  addon_name         = each.value
  kubernetes_version = data.aws_eks_cluster.cluster.version
  most_recent        = false
}

module "eks_blueprints_kubernetes_addons" {

  source               = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"
  eks_cluster_id       = data.aws_eks_cluster.cluster.id #module.project_eks_cluster.cluster_id
  eks_cluster_endpoint = data.aws_eks_cluster.cluster.endpoint
  eks_oidc_provider    = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_version  = data.aws_eks_cluster.cluster.version

  # EKS Addons

  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_vpc_cni            = true
  enable_aws_efs_csi_driver            = false
  enable_aws_cloudwatch_metrics        = true
  enable_prometheus                    = true
  enable_amazon_prometheus             = false
  enable_app_2048                      = false
  #amazon_prometheus_workspace_endpoint = module.managed_prometheus.workspace_prometheus_endpoint

  #K8s Add-ons
  enable_argocd                       = false
  enable_aws_for_fluentbit            = false
  enable_aws_load_balancer_controller = false
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true
  enable_spark_k8s_operator           = false
  enable_external_dns                 = false



  #external_dns_route53_zone_arns = [
  #  aws_route53_zone.ens_hosted_zone.arn
  #]
  #eks_cluster_domain = aws_route53_zone.ens_hosted_zone.name
  #external_dns_helm_config = {
  #  name                       = "external-dns"
  #  chart                      = "external-dns"
  #  repository                 = "https://charts.bitnami.com/bitnami"
  #  version                    = "6.1.6"
  #  namespace                  = "external-dns"
  #  set = [
  #    {
  #      name = "sources[0]"
  #      value = "ingress"
  #    }
  #  ]
  #}
  #prometheus_helm_config = {
  #  name       = "prometheus"                                         # (Required) Release name.
  #  repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
  #  chart      = "prometheus"                                         # (Required) Chart name to be installed.
  #  version    = "15.10.1"                                            # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/prometheus/locals.tf
  #  namespace  = "prometheus"                                         # (Optional) The namespace to install the release into.
  #  #values = [templatefile("${path.module}/prometheus-values.yaml", {
  #  #  operating_system = "linux"
  #  #})]
  #}

  amazon_eks_kube_proxy_config = {
    addon_version     = data.aws_eks_addon_version.default["kube-proxy"].version
    resolve_conflicts = "OVERWRITE"
  }
  amazon_eks_coredns_config = {
    addon_version     = data.aws_eks_addon_version.latest["coredns"].version
    resolve_conflicts = "OVERWRITE"
  }
  amazon_eks_vpc_cni_config = {
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    resolve_conflicts = "OVERWRITE"
  }
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
                    100:
                      - .*-spot-2vcpu-8mem.*
                    90:
                      - .*-spot-4vcpu-16mem.*
                    10:
                      - .*
                  EOT
      }
    ]
  }

  #Name of the AWS Secrets manager parameter that holds the ArgoCD admin password
  #argocd_admin_password_secret_name = "argocd_admin_password"

  # Configuration for the ArgoCD install
  argocd_helm_config = {
    name       = "argo-cd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    #version = "5.5.8"
    #namespace = "argocd"
    timeout          = "1200"
    create_namespace = true
    #set_sensitive = [
    #  {
    #    name  = "configs.secret.argocdServerAdminPassword"
    #    value = bcrypt(data.aws_secretsmanager_secret_version.argocd_adminpw_version.secret_string)
    #  }
    #]
    set = [
      {
        name  = "server.service.type"
        value = "NodePort"
      },
      {
        name  = "server.extraArgs[0]"
        value = "--insecure"
      },
      {
        name  = "redis.affinity"
        value = "{}"
      },
      {
        name  = "configs.knownHosts.data.ssh_known_hosts"
        value = "something.com ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      },
      {
        name  = "server.ingress.enabled"
        value = true
      },
      {
        name  = "server.ingress.https"
        value = true
      },
      {
        name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
        value = "alb"
      },
      #          {
      #            name = "server.ingress.annotations.kubernetes\\.io/actions\\.ssl-redirect"
      #            value = "'{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}'"
      #          },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
        value = "internet-facing"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/healthcheck-protocol"
        value = "HTTPS"
      },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/healthcheck-port"
        value = "traffic-port"
      },
      # {
      #   name = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
      #   value = aws_acm_certificate.ens_cert.arn
      # },
      {
        name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
        value = "[{\"HTTP\": 80}\\,{\"HTTPS\": 443}]"
      },
      #{
      #  name = "server.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      #  value = "argocd.${aws_route53_zone.ens_hosted_zone.name}"
      #},
      #{
      #  name = "server.ingress.hosts[0]"
      #  value = "argocd.${aws_route53_zone.ens_hosted_zone.name}"
      #},
      {
        name  = "server.ingress.paths[0]"
        value = "/"
      }

    ]
  }

}