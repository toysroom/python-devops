variable "resource_group_name" {
  type        = string
  default     = "flask-rg-terraform-aws"
  description = "Nome per il gruppo di risorse AWS (usato per i tag del VPC)"
}

variable "region" {
  type        = string
  default     = "eu-south-1" # Corrisponde a "Italy North"
  description = "Regione AWS dove verranno create le risorse"
}

variable "acr_name" {
  type        = string
  default     = "flaskacr123456789-aws"
  description = "Nome per l'AWS Elastic Container Registry"
}

variable "vm_admin_username" {
  type        = string
  default     = "ubuntu" # Nome utente predefinito per Ubuntu AMIs
  description = "Nome utente amministratore per la VM EC2"
}