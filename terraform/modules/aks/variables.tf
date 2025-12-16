variable "aks_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "node_count" { default = 2 }
variable "node_size" { default = "Standard_D2s_v3" }
