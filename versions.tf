terraform {
  required_version = "~> 1.3"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
  }

  cloud {
    organization = "github-actions-pipelines"
    workspaces {
      name = "pipeline-test"
    }
  }
}
