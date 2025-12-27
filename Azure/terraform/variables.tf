variable "subscription_id" {
    description = "The Azure subscription ID to deploy resources to."
    type        = string
    sensitive   = true
}

variable "application_name" {
    description = "The name of the application."
    type        = string
    default     = "cvat"
}

variable "client_name" {
    description = "The name of the client using the application."
    type        = string
    default     = "kienpt"
  
}

variable "location" {
    description = "The Azure region to deploy resources in."
    type        = string
    default     = "East US"
}

variable "resource_group_name" {
    description = "The name of the resource group. ** Not allowed to be changed **"
    type        = string
    default     = null
}

variable "container_app_environment_name" {
    description = "The name of the container app environment."
    type        = string
    default     = null
}

variable "application_subnet_name" {
    description = "The name of the application subnet."
    type        = string
    default     = null
}

variable "application_subnet_prefixes" {
    description = "The address prefixes for the application subnet."
    type        = list(string)
    default     = ["10.28.18.0/24"]
  
}

variable "database_subnet_name" {
    description = "The name of the database subnet."
    type        = string
    default     = null
}

variable "database_subnet_prefixes" {
    description = "The address prefixes for the database subnet."
    type        = list(string)
    default     = ["10.28.16.0/24"]
}

variable "traefik_application_gateway_subnet" {
    description = "The name of the Traefik application gateway subnet."
    type        = string
    default     = null
}

variable "traefik_application_gateway_subnet_prefixes" {
    description = "The address prefixes for the Traefik application gateway subnet."
    type        = list(string)
    default     = ["10.28.10.0/24"]
}

variable "virtual_network_name" {
    description = "The name of the virtual network."
    type        = string
    default     = null
}

variable "virtual_network_address_space" {
    description = "The address space for the virtual network."
    type        = list(string)
    default     = ["10.28.0.0/16"]
}