resource "kubernetes_cluster_role" "kubernetes_role_dev" {
  depends_on = [module.project_eks_cluster]
  metadata {
    name = "ad-cluster-devs"
    labels = {
      test = "ad-cluster-devs"
    }
  }

  rule {
    api_groups  = [""]
    resources   = ["*"]
    verbs       = ["get", "list", "watch"]

  }
}

resource "kubernetes_cluster_role" "kubernetes_role_admin" {
  depends_on = [module.project_eks_cluster]
  metadata {
    name = "ad-cluster-admins"
    labels = {
      test = "ad-cluster-admins"
    }
  }

  rule {
    api_groups     = [""]
    resources      = ["*"]
    verbs        = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes_binding_role_dev" {
    metadata {
      name      = "ad-cluster-devs-ad-cluster-devs-role-binding"
    }

    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind      = "ClusterRole"
      name      = "ad-cluster-devs"
    }
    subject {
      kind      = "Group"
      name      = "ad-cluster-devs"
      api_group = "rbac.authorization.k8s.io"
    }
}


resource "kubernetes_cluster_role_binding" "new_role_binding" {
    metadata {
      name      = "ad-cluster-admins-ad-cluster-admins-role-binding"
    }

    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind      = "ClusterRole"
      name      = "ad-cluster-admins"
    }
    subject {
      kind      = "Group"
      name      = "ad-cluster-admins"
      api_group = "rbac.authorization.k8s.io"
    }
}