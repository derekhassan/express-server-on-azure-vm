variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "project" {
  type        = string
  default     = "expressserver"
  description = "Name of project (all lowercase and no special characters)"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "The application environment"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1ls"
  description = "The Azure VM Size"
}

variable "vm_username" {
  type        = string
  default     = "azureuser"
  description = "The username for the virtual machine"
}

variable "vm_computer_name" {
  type        = string
  default     = "expresswebserver"
  description = "The computer name for the virtual machine (not the resource name)"
}

variable "vm_source_image_publisher" {
  type        = string
  default     = "Canonical"
  description = "The VM image publisher"
}

variable "vm_source_image_offer" {
  type        = string
  default     = "UbuntuServer"
  description = "The VM image OS"
}

variable "vm_source_image_sku" {
  type        = string
  default     = "20.04-LTS"
  description = "The VM image OS version"
}
