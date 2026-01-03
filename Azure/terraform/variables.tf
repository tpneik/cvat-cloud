variable "bootstrap_mode" {
    description = "Indicates whether to run in bootstrap mode."
    type        = bool
    default     = false
}

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

variable "private_endpoint_subnet" {
    description = "The name of the private endpoint subnet."
    type        = string
    default     = null
}

variable "private_endpoint_subnet_prefixes" {
    description = "The address prefixes for the private endpoint subnet."
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

variable "private_dns_zone_name" {
    description = "The name of the private DNS zone."
    type        = string
    default     = null
}

variable "storage_account_name" {
    description = "The name of the storage account."
    type        = string
    default     = null
}

variable "traefik_application_gateway_name" {
    description = "The name of the Traefik application gateway."
    type        = string
    default     = null
}

# variable "container_app_secrets" {
#   description = "Secrets for the container apps."
#   type = map(object({
#     identity            = optional(string)
#     key_vault_secret_id = optional(string)
#     value               = optional(string)
#   }))
#   default = {}
# }

variable "keyvault_name" {
    description = "The name of the Key Vault."
    type        = string
    default     = null 
}

variable "docker_hub_username" {
    description = "Docker Hub username for pulling container images."
    type = string
    default = null
}

variable "docker_hub_secret" {
    description = "Docker Hub secret for pulling container images."
    type = string
    sensitive   = true
    default = null
}

variable "generic_password" {
    description = "A generic password for various uses."
    type = string
    sensitive   = true
    default = null
}

variable "azure_portal_object_id" {
    description = "The object ID of the Azure portal administrator."
    type        = string
    default     = "null"
}    


#######
variable "container_apps" {
    description = "Configuration for the container apps to deploy."
    type = map(object({
        name                  = string
        revision_mode         = string

        template = object({
            containers = set(object({
                name    = string
                image   = string
                args    = optional(list(string))
                command = optional(list(string))
                cpu     = string
                memory  = string
                env = optional(set(object({
                    name        = string
                    secret_name = optional(string)
                    value       = optional(string)
                })))
                liveness_probe = optional(object({
                    failure_count_threshold = optional(number)
                    header = optional(object({
                        name  = string
                        value = string
                    }))
                    host             = optional(string)
                    initial_delay    = optional(number, 1)
                    interval_seconds = optional(number, 10)
                    path             = optional(string)
                    port             = number
                    timeout          = optional(number, 1)
                    transport        = string
                }))
                readiness_probe = optional(object({
                    failure_count_threshold = optional(number)
                    header = optional(object({
                        name  = string
                        value = string
                    }))
                    host                    = optional(string)
                    interval_seconds        = optional(number, 10)
                    path                    = optional(string)
                    port                    = number
                    success_count_threshold = optional(number, 3)
                    timeout                 = optional(number)
                    transport               = string
                }))
                startup_probe = optional(object({
                    failure_count_threshold = optional(number)
                    header = optional(object({
                        name  = string
                        value = string
                    }))
                    host             = optional(string)
                    interval_seconds = optional(number, 10)
                    path             = optional(string)
                    port             = number
                    timeout          = optional(number)
                    transport        = string
                }))
                volume_mounts = optional(list(object({
                    name = string
                    path = string
                })))
            }))
            max_replicas    = optional(number)
            min_replicas    = optional(number)
            revision_suffix = optional(string)
            custom_scale_rule = optional(list(object({
                custom_rule_type = string
                metadata         = map(string)
                name             = string
                authentication = optional(list(object({
                secret_name       = string
                trigger_parameter = string
                })))
            })))
            http_scale_rule = optional(list(object({
                concurrent_requests = string
                name                = string
                authentication = optional(list(object({
                secret_name       = string
                trigger_parameter = optional(string)
                })))
            })))
            volume = optional(set(object({
                name         = string
                storage_name = optional(string)
                storage_type = optional(string)
                mount_options = optional(string)
            })))
        })

        ingress = optional(object({
            allow_insecure_connections = optional(bool, false)
            external_enabled           = optional(bool, false)
            ip_security_restrictions = optional(list(object({
                action           = string
                ip_address_range = string
                name             = string
                description      = optional(string)
            })), [])
            target_port = number
            transport   = optional(string)
            traffic_weight = object({
                label           = optional(string)
                latest_revision = optional(string)
                revision_suffix = optional(string)
                percentage      = number
            })
        }))
        # identity = optional(object({
        #     type         = string
        #     identity_ids = optional(list(string))
        # }))

        registry = optional(list(object({
            server               = string
            username             = optional(string)
            password_secret_name = optional(string)
            identity             = optional(string)
        })))

    }))

    nullable    = false

    validation {
        condition     = length(var.container_apps) >= 1
        error_message = "At least one container should be provided."
    }
    validation {
        condition     = alltrue([for n, c in var.container_apps : c.ingress == null ? true : (c.ingress.ip_security_restrictions == null ? true : (length(distinct([for r in c.ingress.ip_security_restrictions : r.action])) <= 1))])
        error_message = "The `action` types in an all `ip_security_restriction` blocks must be the same for the `ingress`, mixing `Allow` and `Deny` rules is not currently supported by the service."
    }
    validation {
        condition     = alltrue([for n, c in var.container_apps : c.template.custom_scale_rule == null ? true : alltrue([for _, r in c.template.custom_scale_rule : can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", r.name))])])
        error_message = "The `name` in `custom_scale_rule` must consist of lower case alphanumeric characters, '-', or '.', and should start and end with an alphanumeric character."
    }
    validation {
        condition     = alltrue([for n, c in var.container_apps : c.template.http_scale_rule == null ? true : alltrue([for _, r in c.template.http_scale_rule : can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", r.name))])])
        error_message = "The `name` in `http_scale_rule` must consist of lower case alphanumeric characters, '-', or '.', and should start and end with an alphanumeric character."
    }
}