terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4"
    }
    k3d = {
      source  = "3rein/k3d"
      version = "~> 0.0.4"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 1.2"
    }
  }
}

locals {
  environments = {
    infra = {
      api_port  = 6445
    }
    test = {
      api_port  = 6450
    }
    prod = {
      api_port  = 6451
    }
  }
}

# Set a unique id per cluster
resource "random_id" "cluster_id" {
  for_each = local.environments
  byte_length = 5
}

# Build clusters per our configuration
module "k8s-cluster" {
  source = "./k3d-cluster"
  for_each = local.environments

  cluster_name      = "${each.key}-local-${random_id.cluster_id[each.key].hex}"
  cluster_env       = each.key
  cluster_api_port  = each.value.api_port
  cluster_version   = var.cluster_version

  node_count        = var.node_count
}

# Write Infra kubeconfig to disk (add to global kubeconfig optional)
resource "local_file" "kubeconfig" {
  count     = var.save_admin_kubeconfig ? 1 : 0
  content   = module.k8s-cluster["infra"].kube_config
  filename  = "${path.root}/${module.k8s-cluster["infra"].cluster_name}.kubeconfig"
  file_permission = "0660"
}


# Install ArgoCD w/ basic config
# Configure clusters in ArgoCD
# Add app-of-apps and trigger sync
