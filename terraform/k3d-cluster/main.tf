terraform {
  required_providers {
    k3d = {
      source  = "3rein/k3d"
      version = "~> 0.0.4"
    }
  }
}

resource "k3d_cluster" "cluster" {
  name    = var.cluster_name
  servers = 1
  agents  = var.node_count

  kube_api {
    host      = "k8s.${var.cluster_env}.localhost"
    host_ip   = "127.0.0.1"
    host_port = var.cluster_api_port
  }

  image   = "rancher/k3s:${var.cluster_version}"
  network = "${var.cluster_env}-k3d-cluster"
  #token=???

  registries {}

  k3d {
    disable_load_balancer = true
  }

  k3s {
    extra_server_args = [
      "--tls-san=k8s.${var.cluster_env}.localhost",
      "--disable=servicelb",
      "--disable=traefik",
    ]
  }
}
