resource "aws_iam_role" "K8sFullAdmin-role" {
  name               = "${var.eks_cluster_name}-${var.env}-K8sFullAdmin"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "K8sClusterAdmin-role" {
  name               = "${var.eks_cluster_name}-${var.env}-K8sClusterAdmin"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "K8sDeveloper-role" {
  name               = "${var.eks_cluster_name}-${var.env}-K8sDeveloper"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "eks-external-dns-role" {
  name = "${var.eks_cluster_name}-${var.env}-eks-external-dns-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        "Federated" : module.project_eks_cluster.oidc_provider_arn
        #Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy" "K8sFullAdmin-role-policy" {
  name = "${var.eks_cluster_name}-${var.env}-K8sFullAdmin-role-policy"
  role = aws_iam_role.K8sFullAdmin-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "sts:GetCallerIdentity",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "K8sClusterAdmin-role-policy" {
  name = "${var.eks_cluster_name}-${var.env}-K8sClusterAdmin-role-policy"
  role = aws_iam_role.K8sClusterAdmin-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "sts:GetCallerIdentity",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "K8sDeveloper-role-policy" {
  name = "${var.eks_cluster_name}-${var.env}-K8sDeveloper-role-policy"
  role = aws_iam_role.K8sDeveloper-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "sts:GetCallerIdentity",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group" "K8sFullAdmin-group" {
  name = "${var.eks_cluster_name}-${var.env}-K8sFullAdmin"
}

resource "aws_iam_policy" "K8sFullAdmin-group-policy" {
  name        = "${var.eks_cluster_name}-${var.env}-K8sFullAdmin-group-policy"
  description = "${var.eks_cluster_name}-${var.env}-K8sFullAdmin-group-policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-${var.env}-K8sFullAdmin"]
  }]
}
  EOF
}

resource "aws_iam_group_policy_attachment" "K8sFullAdmin-group-policy-attach" {
  group      = aws_iam_group.K8sFullAdmin-group.name
  policy_arn = aws_iam_policy.K8sFullAdmin-group-policy.arn
}



resource "aws_iam_group" "K8sClusterAdmin-group" {
  name = "${var.eks_cluster_name}-${var.env}-K8sClusterAdmin"
}

resource "aws_iam_policy" "eks-autoscale-policy" {
  name        = "${var.eks_cluster_name}-${var.env}-eks-autoscale-policy"
  path        = "/"
  description = "${var.eks_cluster_name}-${var.env}-eks-autoscale-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "eks-cert-route53-policy" {
  name        = "${var.eks_cluster_name}-${var.env}-eks-cert-route53-policy"
  path        = "/"
  description = "${var.eks_cluster_name}-${var.env}-eks-cert-route53-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets",
                "route53:ListHostedZonesByName"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "eks-autoscale-role" {
  name = "${var.eks_cluster_name}-${var.env}-eks-autoscale-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
       Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "eks-default-role" {
  name = "${var.eks_cluster_name}-${var.env}-eks-default-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "default-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks-default-role.name
}

resource "aws_iam_role_policy_attachment" "default-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-default-role.name
}

resource "aws_iam_role_policy_attachment" "default-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-default-role.name
}

resource "aws_iam_role_policy_attachment" "default-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-default-role.name
}

resource "aws_iam_role_policy_attachment" "default-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-default-role.name
}

resource "aws_iam_role_policy_attachment" "default-eks-autoscale-policy" {
  policy_arn = aws_iam_policy.eks-autoscale-policy.arn
  role       = aws_iam_role.eks-default-role.name
}


resource "aws_iam_role_policy_attachment" "autoscale-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-autoscale-role.name
}
resource "aws_iam_role_policy_attachment" "autoscale-eks-route53Policy" {
  policy_arn = aws_iam_policy.eks-cert-route53-policy.arn
  role       = aws_iam_role.eks-autoscale-role.name
}

resource "aws_iam_role_policy_attachment" "autoscale-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-autoscale-role.name
}

resource "aws_iam_role_policy_attachment" "autoscale-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-autoscale-role.name
}

resource "aws_iam_role_policy_attachment" "autoscale-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-autoscale-role.name
}

resource "aws_iam_role_policy_attachment" "autoscale-eks-autoscale-policy" {
  policy_arn = aws_iam_policy.eks-autoscale-policy.arn
  role       = aws_iam_role.eks-autoscale-role.name
}

resource "aws_iam_role_policy_attachment" "eks-route53Policy" {
  policy_arn = aws_iam_policy.eks-cert-route53-policy.arn
  role       = aws_iam_role.eks-external-dns-role.name
}

resource "aws_iam_policy" "K8sClusterAdmin-group-policy" {
  name        = "${var.eks_cluster_name}-${var.env}-K8sClusterAdmin-group-policy"
  description = "${var.eks_cluster_name}-${var.env}-K8sClusterAdmin-group-policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-${var.env}-K8sClusterAdmin"]
  }]
}
  EOF
}

resource "aws_iam_group_policy_attachment" "K8sClusterAdmin-group-policy-attach" {
  group      = aws_iam_group.K8sClusterAdmin-group.name
  policy_arn = aws_iam_policy.K8sClusterAdmin-group-policy.arn
}


resource "aws_iam_group" "K8sDeveloper-group" {
  name = "${var.eks_cluster_name}-${var.env}-K8sDeveloper"
}

resource "aws_iam_policy" "K8sDeveloper-group-policy" {
  name        = "${var.eks_cluster_name}-${var.env}-K8sDeveloper-group-policy"
  description = "${var.eks_cluster_name}-${var.env}-K8sDeveloper-group-policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-${var.env}-K8sDeveloper"]
  }]
}
  EOF
}

resource "aws_iam_group_policy_attachment" "K8sDeveloper-group-policy-attach" {
  group      = aws_iam_group.K8sDeveloper-group.name
  policy_arn = aws_iam_policy.K8sDeveloper-group-policy.arn
}


output "eks-autoscale-role" {
  value       = aws_iam_role.eks-autoscale-role.arn
}
