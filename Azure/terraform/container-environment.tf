## Container App Environment

resource "azurerm_container_app_environment" "app_env" {
  name                              = local.container_app_environment_name
  location                          = azurerm_resource_group.main_rg.location
  resource_group_name               = azurerm_resource_group.main_rg.name
  infrastructure_subnet_id          = azurerm_subnet.application_subnet.id
  public_network_access             = "Disabled"
  internal_load_balancer_enabled    = true
  
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  lifecycle {
    ignore_changes = [infrastructure_resource_group_name, workload_profile]
  }

  depends_on = [
    azurerm_subnet.application_subnet,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip,
    azurerm_postgresql_flexible_server.cvat_db,
    azurerm_storage_share.vector,
    azurerm_storage_share.redis,
    azurerm_storage_share.cvat_data,
    azurerm_storage_share.cvat_keys,
    azurerm_storage_share.cvat_logs,
    azurerm_storage_share.cvat_events_db
  ]
}

resource "azurerm_container_app_environment_storage" "vector_file_shared" {
  name                         = azurerm_storage_share.vector.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.vector.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.vector
  ]
}

resource "azurerm_container_app_environment_storage" "redis_file_shared" {
  name                         = azurerm_storage_share.redis.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.redis.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.redis
  ]
}

resource "azurerm_container_app_environment_storage" "cvat_data_file_shared" {
  name                         = azurerm_storage_share.cvat_data.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.cvat_data.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.cvat_data
  ]
}
resource "azurerm_container_app_environment_storage" "cvat_keys_file_shared" {
  name                         = azurerm_storage_share.cvat_keys.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.cvat_keys.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.cvat_keys
  ]
}

resource "azurerm_container_app_environment_storage" "cvat_logs_file_shared" {
  name                         = azurerm_storage_share.cvat_logs.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.cvat_logs.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.cvat_logs
  ]
}

resource "azurerm_container_app_environment_storage" "cvat_events_db_file_shared" {
  name                         = azurerm_storage_share.cvat_events_db.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.cvat_events_db.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]
  }

  depends_on = [
    azurerm_container_app_environment.app_env,
    azurerm_storage_share.cvat_events_db
  ]
}

## Container Apps

resource "azurerm_container_app" "container_app" {
    for_each = var.container_apps

    container_app_environment_id = azurerm_container_app_environment.app_env.id
    name                         = each.value.name
    resource_group_name          = azurerm_resource_group.main_rg.name
    revision_mode                = each.value.revision_mode

    identity {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this.id]
    }

    lifecycle {
      ignore_changes = [
        workload_profile_name
      ]
      # CRITICAL: Ensure container apps are destroyed before environment
      create_before_destroy = false
    }

    # CRITICAL: Ensure all dependencies including Key Vault are ready
    depends_on = [
      azurerm_container_app_environment.app_env,
      azurerm_container_app_environment_storage.vector_file_shared,
      azurerm_container_app_environment_storage.redis_file_shared,
      azurerm_container_app_environment_storage.cvat_data_file_shared,
      azurerm_container_app_environment_storage.cvat_keys_file_shared,
      azurerm_container_app_environment_storage.cvat_logs_file_shared,
      azurerm_container_app_environment_storage.cvat_events_db_file_shared,
      azurerm_user_assigned_identity.this,
      module.key_vault,
      azurerm_storage_share.vector,
      azurerm_storage_share.redis,
      azurerm_storage_share.cvat_data,
      azurerm_storage_share.cvat_keys,
      azurerm_storage_share.cvat_logs,
      azurerm_storage_share.cvat_events_db
    ]

    template {
        max_replicas    = each.value.template.max_replicas
        min_replicas    = each.value.template.min_replicas
        revision_suffix = each.value.template.revision_suffix

        dynamic "container" {
            for_each = each.value.template.containers

            content {
                cpu     = container.value.cpu
                image   = container.value.image
                memory  = container.value.memory
                name    = container.value.name
                args    = container.value.args
                command = container.value.command

                dynamic "env" {
                    for_each = container.value.env == null ? [] : container.value.env

                    content {
                        name        = env.value.name
                        secret_name = env.value.secret_name
                        value       = env.value.value
                    }
                }
                dynamic "liveness_probe" {
                    for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]

                    content {
                        port                    = liveness_probe.value.port
                        transport               = liveness_probe.value.transport
                        failure_count_threshold = liveness_probe.value.failure_count_threshold
                        host                    = liveness_probe.value.host
                        initial_delay           = liveness_probe.value.initial_delay
                        interval_seconds        = liveness_probe.value.interval_seconds
                        path                    = liveness_probe.value.path
                        timeout                 = liveness_probe.value.timeout

                        dynamic "header" {
                            for_each = liveness_probe.value.header == null ? [] : [liveness_probe.value.header]

                            content {
                                name  = header.value.name
                                value = header.value.value
                            }
                        }
                    }
                }
                dynamic "readiness_probe" {
                    for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]

                    content {
                        port                    = readiness_probe.value.port
                        transport               = readiness_probe.value.transport
                        failure_count_threshold = readiness_probe.value.failure_count_threshold
                        host                    = readiness_probe.value.host
                        interval_seconds        = readiness_probe.value.interval_seconds
                        path                    = readiness_probe.value.path
                        success_count_threshold = readiness_probe.value.success_count_threshold
                        timeout                 = readiness_probe.value.timeout

                        dynamic "header" {
                        for_each = readiness_probe.value.header == null ? [] : [readiness_probe.value.header]

                        content {
                            name  = header.value.name
                            value = header.value.value
                        }
                        }
                    }
                }
                dynamic "startup_probe" {
                    for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]

                    content {
                        port                    = startup_probe.value.port
                        transport               = startup_probe.value.transport
                        failure_count_threshold = startup_probe.value.failure_count_threshold
                        host                    = startup_probe.value.host
                        interval_seconds        = startup_probe.value.interval_seconds
                        path                    = startup_probe.value.path
                        timeout                 = startup_probe.value.timeout

                        dynamic "header" {
                            for_each = startup_probe.value.header == null ? [] : [startup_probe.value.header]

                            content {
                                name  = header.value.name
                                value = header.value.name
                            }
                        }
                    }
                }
                dynamic "volume_mounts" {
                    for_each = container.value.volume_mounts == null ? [] : container.value.volume_mounts

                    content {
                        name = volume_mounts.value.name
                        path = volume_mounts.value.path
                    }
                }
            }
        }
        dynamic "volume" {
            for_each = each.value.template.volume == null ? [] : each.value.template.volume

            content {
                name            = volume.value.name
                storage_name    = volume.value.storage_name
                storage_type    = volume.value.storage_type
                mount_options   = volume.value.mount_options
            }
        }
    }
    dynamic "ingress" {
        for_each = each.value.ingress == null ? [] : [each.value.ingress]

        content {
            target_port                = ingress.value.target_port
            allow_insecure_connections = ingress.value.allow_insecure_connections
            external_enabled           = ingress.value.external_enabled
            transport                  = ingress.value.transport

            dynamic "traffic_weight" {
                for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

                content {
                percentage      = traffic_weight.value.percentage
                label           = traffic_weight.value.label
                latest_revision = traffic_weight.value.latest_revision
                revision_suffix = traffic_weight.value.revision_suffix
                }
            }
            dynamic "ip_security_restriction" {
                for_each = ingress.value.ip_security_restrictions == null ? [] : ingress.value.ip_security_restrictions

                content {
                action           = ip_security_restriction.value.action
                ip_address_range = ip_security_restriction.value.ip_address_range
                name             = ip_security_restriction.value.name
                description      = ip_security_restriction.value.description
                }
            }
        }
    }

    dynamic "registry" {
      for_each = each.value.registry == null ? [] : each.value.registry

      content {
        server               = registry.value.server
        identity             = registry.value.identity
        password_secret_name = registry.value.password_secret_name
        username             = registry.value.username
      }
    }

    # Get things not from variables. Ref from Key Vault module.
    dynamic "secret" {
      for_each = module.key_vault.secrets

      content {
        name                = replace(secret.key, "_", "-")
        identity            = azurerm_user_assigned_identity.this.id
        key_vault_secret_id = secret.value.versionless_id
        # value               = secret.value.value
      }
    }
}
