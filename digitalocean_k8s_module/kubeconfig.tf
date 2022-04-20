module "kubeconfig" {
  source  = "gitlab.com/vkpr/terraform-kubernetes-kubeconfig/kubernetes"
  version = "~> 1.0.0"

  endpoint               = digitalocean_kubernetes_cluster.cluster.endpoint
  cluster_ca_certificate = digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  create_kubeconfig      = var.create_kubeconfig
  kubeconfig_name        = var.cluster_name
}
