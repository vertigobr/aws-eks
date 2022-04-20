provider "digitalocean" {
  token = var.do_token
}

module "digitalocean_k8s_cluster" {
  source = "./digitalocean_k8s_module"

  cluster_name          = local.config.cluster_name
  region                = local.config.region
  prefix_version        = local.config.prefix_version
  node_pool_default     = local.config.node_pool_default
  additional_node_pools = local.config.additional_node_pools
}
