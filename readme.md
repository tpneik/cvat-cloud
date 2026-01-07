# CVAT in Cloud

## Introduction
This is my personal project to practice deploying applications to cloud environments. If this project helps you in any aspect, please let me know—I'd be happy to hear about it! Note: This project is currently in development.

**Contact:** +84 987305013 (WhatsApp) | tpneik@gmail.com

### About CVAT

**CVAT (Computer Vision Annotation Tool)** is an open-source, interactive platform for annotating images and videos for computer vision tasks. It is widely adopted by tens of thousands of users and companies worldwide, enabling developers and organizations to build high-quality datasets for machine learning and AI projects using a Data-centric AI approach.

### Infrastructure Overview

This infrastructure deployment leverages Azure cloud services with a focus on:
- **Primary Platform:** Azure Container Apps for serverless container orchestration
- **Architecture:** Microservices-based with enhanced security practices
- **Evolution:** Continuous security improvements and architectural enhancements

![Architecture Diagram](images/component.drawio-2.png)



## Run terraform to boostrap the infrastructure
```bash
cd Azure/terraform
terraform plan -var="bootstrap_mode=true"
terraform apply -var="bootstrap_mode=true"
terraform plan -var="bootstrap_mode=false"
terraform apply -var="bootstrap_mode=false"
```


## Remove the whole resource

```bash
# Step 1: Destroy all Container Apps first
terraform destroy \
  -target='azurerm_container_app.container_app["cvat-opa"]' \
  -target='azurerm_container_app.container_app["cvat_clickhouse"]' \
  -target='azurerm_container_app.container_app["cvat_redis_inmem"]' \
  -target='azurerm_container_app.container_app["cvat_redis_ondisk"]' \
  -target='azurerm_container_app.container_app["cvat_server"]' \
  -target='azurerm_container_app.container_app["cvat_ui"]' \
  -target='azurerm_container_app.container_app["cvat_vector"]' \
  -target='azurerm_container_app.container_app["cvat_worker_annotation"]' \
  -target='azurerm_container_app.container_app["cvat_worker_chunks"]' \
  -target='azurerm_container_app.container_app["cvat_worker_consensus"]' \
  -target='azurerm_container_app.container_app["cvat_worker_export"]' \
  -target='azurerm_container_app.container_app["cvat_worker_import"]' \
  -target='azurerm_container_app.container_app["cvat_worker_quality_reports"]' \
  -target='azurerm_container_app.container_app["cvat_worker_utils"]' \
  -target='azurerm_container_app.container_app["cvat_worker_webhooks"]' \
  -var="bootstrap_mode=false"

# Step 2: Destroy DNS A records
terraform destroy \
  -target='azurerm_private_dns_a_record.cvat-ui-app[0]' \
  -target='azurerm_private_dns_a_record.cvat-server-app[0]' \
  -var="bootstrap_mode=false"

# Step 3: Destroy Container App Environment Storage
terraform destroy \
  -target='azurerm_container_app_environment_storage.vector_file_shared' \
  -target='azurerm_container_app_environment_storage.redis_file_shared' \
  -target='azurerm_container_app_environment_storage.cvat_data_file_shared' \
  -target='azurerm_container_app_environment_storage.cvat_keys_file_shared' \
  -target='azurerm_container_app_environment_storage.cvat_logs_file_shared' \
  -target='azurerm_container_app_environment_storage.cvat_events_db_file_shared' \
  -var="bootstrap_mode=false"

# Step 4: Destroy Container App Environment
terraform destroy \
  -target='azurerm_container_app_environment.app_env' \
  -var="bootstrap_mode=false"

```


## Storage account testing
```bash
echo "hehe" > data.txt
export AZCOPY_SPA_CLIENT_SECRET='your-key'
curl -sL https://aka.ms/downloadazcopy-v10-linux | tar xz --strip-components=1 -C /tmp && sudo mv /tmp/azcopy /usr/local/bin/ && sudo chmod +x /usr/local bin/azcopy
azcopy login --service-principal --application-id 12954a9c-ce35-4d4f-aea5-74830842338e --tenant-id 5e3146a5-cd04-4899-b34c-bd21b10c91e3
ls
cat data.txt 
azcopy copy data.txt "https://mmccvatsa.file.core.windows.net/cvat-cache-db/data.txt"

azcopy copy vector.toml "https://mmccvatsa.file.core.windows.net/cvat-vector-component/vector.toml"

```

## PostgreSQL Testing

```bash
sudo apt-get update && sudo apt-get install -y postgresql-client

export PGHOST=10.28.16.8
export PGUSER=cvatAdmin
export PGPORT=5432
export PGDATABASE=postgres
export PGPASSWORD='H@Sh1CoR3!'

psql
```

## Backend server testing

```bash
curl cvat-server:8080
```

## Use when want to recreate specific resource 

```hcl
terraform apply -replace='module.traefik_vm.azurerm_linux_virtual_machine.this[0]'
```

## Check rule set of storage account

```hcl
az storage account show --name mmccvatsa --resource-group mmc-cvat-rg --query networkRuleSet
```

## Remove resource
```bash
# Delete all CVAT container apps
az containerapp delete --name cvat-worker-quality-reports --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-chunks --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-redis-inmem --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-webhooks --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-utils --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-redis-ondisk --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-ui --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-consensus --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-vector --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-server --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-import --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-clickhouse --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-annotation --resource-group mmc-cvat-rg --yes
az containerapp delete --name cvat-worker-export --resource-group mmc-cvat-rg --yes
az containerapp delete --name opa --resource-group mmc-cvat-rg --yes
```

