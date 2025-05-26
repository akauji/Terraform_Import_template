# Variables for Azure Terraform Import Template

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Japan East"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "azure-import"
}

# Virtual Network variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Subnet variables
variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Network Security Group variables
variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
}

# Storage Account variables
variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_account_tier" {
  description = "Performance tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
}

# Key Vault variables
variable "key_vault_name" {
  description = "Name of the key vault"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU name for the key vault"
  type        = string
  default     = "standard"
}

# Common tags
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment   = "dev"
    Project       = "azure-import"
    ManagedBy     = "terraform"
    ImportedFrom  = "existing-azure-resources"
  }
}

# Virtual Machine variables (if needed)
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

# App Service variables (if needed)
variable "app_service_plan_name" {
  description = "Name of the app service plan"
  type        = string
  default     = ""
}

variable "app_service_name" {
  description = "Name of the app service"
  type        = string
  default     = ""
}

# SQL Database variables (if needed)
variable "sql_server_name" {
  description = "Name of the SQL server"
  type        = string
  default     = ""
}

variable "sql_database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = ""
}
