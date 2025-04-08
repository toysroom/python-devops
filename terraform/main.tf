provider "azurerm" {
  features {}

  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  subscription_id = ""
}


# Creazione del gruppo di risorse
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Creazione della rete virtuale
resource "azurerm_virtual_network" "vnet" {
  name                = "jenkins-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Creazione della subnet
resource "azurerm_subnet" "subnet" {
  name                 = "jenkins-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Crea il gruppo di sicurezza di rete (NSG) per consentire il traffico SSH (porta 22)
resource "azurerm_network_security_group" "nsg" {
  name                = "jenkins-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  # Regola per consentire il traffico sulla porta 8080 (per Jenkins)
  security_rule {
    name                       = "Allow-Jenkins"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "8080"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

# Creazione della scheda di rete
resource "azurerm_network_interface" "nic" {
  name                = "jenkins-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sga" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Creazione dell'IP pubblico
resource "azurerm_public_ip" "jenkins_ip" {
  name                = "jenkins-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Creazione della VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "jenkins-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = var.vm_admin_username

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "jenkinsosdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Creazione ACR (Azure Container Registry)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Creazione App Service
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "flask-appservice-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Creazione Web App Service
resource "azurerm_linux_web_app" "flask_web_app" {
  name                = "flask-app12345"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_app_service_plan.app_service_plan.id
  
  site_config {

  }
}