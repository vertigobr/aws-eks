variable "do_token" {
  type        = string
  description = "Digital Ocean API token"
  default = null
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes Cluster Name"
  default = "digitalocean_k8s_cluster"
}

variable "prefix_version" {
  type        = string
  description = "Define minor version for the Kubernetes cluster"
  default = "1.22."
}

variable "region" {
  type        = string
  description = "Region where the cluster will be deployed"
  default = "nyc1"
}
