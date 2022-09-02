data "aws_ami" "amazon-linux-2-ami" {
 most_recent = true
 owners           = ["amazon"]
 filter {
  name   = "owner-alias"
  values = ["amazon"]
 }
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
     filter {
       name   = "architecture"
       values = ["x86_64"]
     }
}

data "aws_eks_cluster" "cluster" {
  name = module.project_eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.project_eks_cluster.cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals{

  vpc_id = var.vpc_id
  subnet_ids =  var.private_subnets_ids
  public_subnet_ids =  var.public_subnets_ids
  map_role = [{
    rolearn  = aws_iam_role.eks-autoscale-role.arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes", "system:masters"]
    },
    {
      rolearn  = aws_iam_role.eks-default-role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes", "system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"
      username = "AWSServiceRoleForAmazonEKS"
      groups   = ["system:masters"]
    },
    {
      rolearn = var.eks_master_role
      "username" : "AWSAdministratorAccess:{{SessionName}}"
      groups = ["system:masters"]
    },
    {
      rolearn = var.eks_dev_role
      "username" : "AWSReadOnlyAccess:{{SessionName}}"
      groups = ["ad-cluster-admins"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/project_eks_cluster-dev-K8sFullAdmin"
      username = "project_eks_cluster-dev-K8sFullAdmin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/project_eks_cluster-dev-K8sClusterAdmin"
      username = " adminuser:{{SessionName}}"
      groups   = ["ad-cluster-admins"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/project_eks_cluster-dev-K8sDeveloper"
      username = "devuser:{{SessionName}}"
      groups   = ["ad-cluster-devs"]
    }
  ]
}

module "project_eks_cluster" {
  depends_on = [
    aws_iam_group_policy_attachment.K8sClusterAdmin-group-policy-attach,
    aws_iam_group_policy_attachment.K8sFullAdmin-group-policy-attach,
    aws_iam_group_policy_attachment.K8sDeveloper-group-policy-attach
    ]
  source          = "terraform-aws-modules/eks/aws"
  version = "17.24.0"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "scheduler"]
  cluster_name    = "${var.eks_cluster_name}-${var.env}"
  cluster_version = var.eks_cluster_version
  subnets         = local.subnet_ids
  vpc_id          = local.vpc_id
  map_roles =   concat(var.map_roles, local.map_role)
  map_users    = var.map_users
  map_accounts = var.map_accounts
  enable_irsa               = true
  attach_worker_cni_policy   = var.cni_enabled
  cluster_endpoint_public_access =  var.cluster_public_access
  cluster_endpoint_private_access =  !var.cluster_public_access
  cluster_create_endpoint_private_access_sg_rule =  var.cluster_public_access
  cluster_endpoint_private_access_cidrs = var.cluster_public_access ? [] : ["10.0.0.0/8"]

  tags = var.tags
}

output "project_eks_cluster_id"{
  value = module.project_eks_cluster.cluster_id
}