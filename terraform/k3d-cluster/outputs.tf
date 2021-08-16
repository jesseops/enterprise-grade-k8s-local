output "cluster_name" {
  value = k3d_cluster.cluster.name
}

output "kube_config" {
  value = k3d_cluster.cluster.credentials[0].raw
}

output "api_credentials" {
  value = k3d_cluster.cluster.credentials[0]
}

# Necessary so argocd can communicate since clusters are on isolated networks
output "external_api_port" {
  value = k3d_cluster.cluster.kube_api[0].host_port
}
