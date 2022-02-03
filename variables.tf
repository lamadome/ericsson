resource "random_string" "env" {
  length  = 4
  special = false
  upper   = false
  number  = false
}
variable "aws_ssh_key_name" {
  description = "SSH Key Name"
  type        = string
}

variable "dc_prefix" {
  description = "prefix for DC Server Name"
  type = string
  default = "dc"
}


variable "dc_name" {
  description = "Consul DC Name"
  type = string
}
variable "k8s_cluster_name" {
  description = "Name of the k8s cluster"
  type = string
}
