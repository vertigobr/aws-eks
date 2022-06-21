output "name" {
  value = digitalocean_kubernetes_cluster.cluster.name
}

output "endpoint" {
  value       = digitalocean_kubernetes_cluster.cluster.endpoint
  sensitive   = true
}

output "ca_certificate" {
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_token" {
  value       = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  sensitive   = true
}
