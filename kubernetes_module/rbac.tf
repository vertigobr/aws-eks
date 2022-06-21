provider "kubernetes" {
  host             = var.cluster_endpoint
  token            = var.cluster_access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "root" {
  metadata {
    name = "${var.cluster_name}-root-access"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${var.cluster_name}-root"
    api_group = ""
  }
}

resource "kubernetes_service_account" "root" {
  metadata {
    name = "${var.cluster_name}-root"
  }
}

resource "kubernetes_secret" "root" {
  metadata {
    name = "${var.cluster_name}-root"
    annotations = {
      "kubernetes.io/service-account.name" = "${var.cluster_name}-root"
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "admin-access"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin"
    api_group = ""
  }
}

resource "kubernetes_service_account" "admin" {
  metadata {
    name = "admin"
  }
}

resource "kubernetes_secret" "admin" {
  metadata {
    name = "admin"
    annotations = {
      "kubernetes.io/service-account.name" = "admin"
    }
  }
  type = "kubernetes.io/service-account-token"
}
