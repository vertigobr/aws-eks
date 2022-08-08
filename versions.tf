terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 0.13.1"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
