resource "digitalocean_kubernetes_node_pool" "additional_node_pools" {
  for_each = var.additional_node_pools

  cluster_id = digitalocean_kubernetes_cluster.cluster.id
  name       = each.value.name
  size       = each.value.size
  node_count = each.value.node_count
  auto_scale = each.value.auto_scale
  min_nodes  = each.value.min_nodes
  max_nodes  = each.value.max_nodes
}