provider "digitalocean" {
  token = var.do_token
}

module "digitalocean_k8s_cluster" {
  source = "./digitalocean_k8s_module"

  cluster_name          = local.config.cluster_name
  prefix_version        = local.config.prefix_version
  region                = local.config.region
  node_pool_default     = local.config.node_pool_default
  additional_node_pools = local.config.additional_node_pools
}

module "kubernetes" {
  source = "./kubernetes_module"

  root_access            = local.config.root_access
  cluster_name           = module.digitalocean_k8s_cluster.name
  cluster_endpoint       = module.digitalocean_k8s_cluster.endpoint
  cluster_ca_certificate = module.digitalocean_k8s_cluster.ca_certificate
  cluster_access_token   = module.digitalocean_k8s_cluster.kubeconfig_token

}

module "kubeconfig" {
  source  = "gitlab.com/vkpr/terraform-kubernetes-kubeconfig/kubernetes"
  version = "~> 1.0.0"

  create_kubeconfig      = true
  endpoint               = module.digitalocean_k8s_cluster.endpoint
  cluster_ca_certificate = module.digitalocean_k8s_cluster.ca_certificate
  token                  = local.config.root_access ? module.kubernetes.root_secret_token : module.kubernetes.admin_secret_token
  kubeconfig_name        = local.config.root_access ? "${local.config.cluster_name}-root" : "${local.config.cluster_name}-admin"
}
