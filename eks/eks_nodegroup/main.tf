resource "random_pet" "random" {
  count = length(var.subnets_ids)
  keepers = {
    name = "${var.subnets_ids[count.index]}-${var.eks_cluster_version}-${join("-",var.cluster_node_instance_type)}-${var.cluster_min_node_count}"
  }
  length = 1
}

resource "aws_eks_node_group" "project-eks-cluster-nodegroup" {
  count = length(var.subnets_ids)
 # version = "3.74.3"
  cluster_name    = "${var.eks_cluster_name}-${var.env}"
  node_group_name = "node-group-${var.eks_cluster_name}-${var.nodegroup_usage}-${var.env}-${random_pet.random[count.index].id}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.subnets_ids[count.index]]
  instance_types = var.cluster_node_instance_type
  disk_size = var.cluster_node_disk_size
  capacity_type = var.cluster_node_billing_mode
  force_update_version = true
  scaling_config {
    desired_size = var.cluster_min_node_count+1
    max_size     = var.cluster_max_node_count
    min_size     = var.cluster_min_node_count
  }
  update_config {
    max_unavailable = 2
  }
  tags = var.tags
  #remote_access {
  #  ec2_ssh_key = aws_key_pair.bastion_key_pair.key_name
  #}

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

}