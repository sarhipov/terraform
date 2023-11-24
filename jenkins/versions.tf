terraform {
  required_version = "~> 1.6.0"
#  backend "s3" {
#    bucket         = "< s3-bucket-name >"
#    key            = "< state-name/terraform.tfstate >"
#    region         = "us-west-2"
#    dynamodb_table = "< state-lock-table >"
#  }
  required_providers {
    aws        = "~> 5.0"
    null       = "~> 3.0"
    kubernetes = "~> 2.0"
    random     = "~> 3.0"
    tls        = "~> 4.0"
    helm       = "~> 2.0"
    cloudinit  = "~> 2.0"
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "kubernetes" {
  config_path = "kubeconfig_eks-private"
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig_eks-private"
  }
}