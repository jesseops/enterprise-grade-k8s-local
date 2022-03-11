# Declare variables - must be defined by:
#   * Environment variables, eg "$varname=..."
#   * tfvars file
#   * tfvars.json
#   * CLI args, eg: "-var=$varname=..."
# Later declarations take precedence

variable "cluster_version" {
  type    = string
  default = "v1.21.3-k3s1"
}

variable "node_count" {
  type    = number
  default = 1
}

# Deprecated. Assuming we want to write the kubeconfig file
# variable "save_admin_kubeconfig" {
#   type    = bool
#   default = true
# }
