resource "azurerm_resource_group" "main_rg" {
  name     = local.resource_group_name
  location = var.location
}



# module "random_password" {
#   source = "./modules/random_password"

#   length           = 20
#   lower            = true
#   upper            = true
#   min_lower        = 4
#   min_upper        = 2
#   min_numeric      = 3
#   min_special      = 3
#   numeric          = true
#   special          = true
# }