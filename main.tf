provider "aws" {
  region = var.region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

provider "aws" {
  alias = "alternate"
}

# # AWS Key Pair to generate
resource "aws_key_pair" "dark_watch_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_public_key_path)
}


terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}


provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}