terraform {
  required_version = ">= 0.13"
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.1"
    }
  }
}

provider "harvester" {
  # This is the kubeconfig file taken from your harvester UI.
  kubeconfig = "./harvester.yaml"
}