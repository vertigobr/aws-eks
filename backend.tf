terraform {
  backend "remote" {
    organization = "vtg"
    workspaces {
      name = "pipeline-test"
    }
  }
  cloud {
    organization = "vtg"

    workspaces {
      name = "pipeline-test"
    }
  }
}
