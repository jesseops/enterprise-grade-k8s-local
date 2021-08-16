# Per https://www.terraform.io/docs/language/modules/develop/providers.html
# providers must be defined in the root and passed explicitly to child modules
#

provider "k3d" {

}

provider "kubernetes" {
  config_path = "${path.root}/${module.k8s-cluster["infra"].cluster_name}.kubeconfig"
}

#provider "argocd" {
#
#}
