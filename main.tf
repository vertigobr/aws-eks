provider "digitalocean" {
  token = var.do_token
}

module "digitalocean_k8s_cluster" {
  source = "./digitalocean_k8s_module"

  cluster_name          = var.cluster_name == null ? local.config.cluster_name : var.cluster_name
  prefix_version        = var.prefix_version == null ? local.config.prefix_version : var.prefix_version
  region                = var.region == null ? local.config.region : var.region
  node_pool_default     = local.config.node_pool_default
  additional_node_pools = local.config.additional_node_pools
}
