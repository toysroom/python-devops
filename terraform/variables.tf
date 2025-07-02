variable "resource_group_name" {
  type    = string
  default = "flask-rg-terraform"
}

variable "location" {
  type    = string
  default = "Italy north"
}

variable "acr_name" {
  type    = string
  default = "flaskacr123456789"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}
