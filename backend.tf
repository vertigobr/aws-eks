terraform {
  cloud {
    organization = "vtg"

    workspaces {
      name = "pipeline-test"
    }
  }
}
