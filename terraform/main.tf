terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8"
    }
    k3d = {
      source  = "pvotal-tech/k3d"
      version = "0.0.5"
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
resource "kubernetes_namespace" "argo_cluster" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_secret" "argo_cluster" {
  for_each = module.k8s-cluster
  metadata {
    name  = "${each.key}"
    namespace = "argocd"
    labels  = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }
  data = {
    name = "${each.key}"
    server = "https://host.k3d.internal:${each.value.external_api_port}"
    config = jsonencode({
      tlsClientConfig = {
        #insecure = true
        caData = base64encode("${each.value.api_credentials.cluster_ca_certificate}")
        certData = base64encode("${each.value.api_credentials.client_certificate}")
        keyData = base64encode("${each.value.api_credentials.client_key}")
      }
    })
  }

}

# Add app-of-apps and trigger sync

