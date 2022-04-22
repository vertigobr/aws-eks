resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.region
  version = data.digitalocean_kubernetes_versions.cluster_version.latest_version

  node_pool {
    name       = var.node_pool_default.name
    size       = var.node_pool_default.size
    node_count = var.node_pool_default.node_count
    auto_scale = var.node_pool_default.auto_scale
    min_nodes  = var.node_pool_default.min_nodes
    max_nodes  = var.node_pool_default.max_nodes
  }
}