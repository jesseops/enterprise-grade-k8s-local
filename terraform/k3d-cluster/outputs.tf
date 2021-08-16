output "cluster_name" {
  value = k3d_cluster.cluster.name
}

output "kube_config" {
  value = k3d_cluster.cluster.credentials[0].raw
}
