# Per https://www.terraform.io/docs/language/modules/develop/providers.html
# providers must be defined in the root and passed explicitly to child modules
#

provider "k3d" {

}

provider "kubernetes" {

}

#provider "argocd" {
#
#}
