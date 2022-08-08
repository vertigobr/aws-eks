provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_certificate_authority_data
  token                  = module.cluster.kubeconfig_token
}
