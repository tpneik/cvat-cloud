locals {
  # Compute resource names with dynamic values
  resource_group_name                     = coalesce(var.resource_group_name, "${var.client_name}-${var.application_name}-rg")
  application_subnet_name                 = coalesce(var.application_subnet_name, "${var.client_name}-${var.application_name}-app-subnet")
  private_endpoint_subnet                 = coalesce(var.private_endpoint_subnet, "${var.client_name}-${var.application_name}-private-endpoint-subnet")
  traefik_application_gateway_subnet      = coalesce(var.traefik_application_gateway_subnet, "${var.client_name}-${var.application_name}-traefik-app-gateway-subnet")
  virtual_network_name                    = coalesce(var.virtual_network_name, "${var.client_name}-${var.application_name}-app-vnet")
  container_app_environment_name          = coalesce(var.container_app_environment_name, "${var.client_name}-${var.application_name}-app-env")
  private_dns_zone_name                   = coalesce(var.private_dns_zone_name, "${var.client_name}-${var.application_name}.app")
  storage_account_name                    = coalesce(var.storage_account_name, "${var.client_name}${var.application_name}sa")
}
