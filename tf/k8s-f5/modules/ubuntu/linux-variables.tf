##########################################
## Linux VM with Web Server - Variables ##
##########################################

# Azure virtual machine settings #
variable location {}
variable prefix {}
variable rg_name {}
variable tag {}
variable subnet_id {}
variable nsg_id {}
variable ip {}
variable password {}
variable username {}


variable "vm-size" {}

variable "web-linux-license-type" {
  type        = string
  description = "Specifies the BYOL type for the virtual machine."
  default     = null
}

# Azure virtual machine storage settings #

variable "web-linux-delete-os-disk-on-termination" {
  type        = string
  description = "Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed?"
  default     = "true"  # Update for your environment
}

variable "web-linux-delete-data-disks-on-termination" {
  description = "Should the Data Disks (either the Managed Disks / VHD Blobs) be deleted when the Virtual Machine is destroyed?"
  type        = string
  default     = "true"
}

variable "web-linux-vm-image" {
  type        = map(string)
  description = "Virtual machine source image information"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "18.04.202004290"
  }
}

