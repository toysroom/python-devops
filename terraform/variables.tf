variable "resource_group_name" {
  type    = string
  default = "flask-rg"
}

variable "location" {
  type    = string
  default = "Italy north"
}

variable "acr_name" {
  type    = string
  default = "flaskacr12345"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}
