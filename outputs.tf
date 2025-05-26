# Outputs for Azure Terraform Import Template

# Subscription information
output "subscription_id" {
  description = "Current Azure subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Current Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

# Resource Group outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Virtual Network outputs
output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

# Subnet outputs
output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.main.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the subnet"
  value       = azurerm_subnet.main.address_prefixes
}

# Network Security Group outputs
output "nsg_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.main.name
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

# Storage Account outputs
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

# Key Vault outputs
output "key_vault_name" {
  description = "Name of the key vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "ID of the key vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the key vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Import information
output "import_summary" {
  description = "Summary of imported resources"
  value = {
    resource_group    = azurerm_resource_group.main.name
    virtual_network   = azurerm_virtual_network.main.name
    subnet           = azurerm_subnet.main.name
    nsg              = azurerm_network_security_group.main.name
    storage_account  = azurerm_storage_account.main.name
    key_vault        = azurerm_key_vault.main.name
    environment      = var.environment
    project          = var.project_name
  }
}
