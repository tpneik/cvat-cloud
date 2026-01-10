# Release Notes

## v1.0.0 (January 2026)

**Initial Release** - First stable version of CVAT infrastructure on Azure.

### Highlights

- Complete CVAT deployment on Azure Container Apps
- Two-phase Terraform deployment with bootstrap mode for proper resource ordering
- Microservices architecture with 15+ container apps

### Infrastructure Components

| Category | Components |
|----------|------------|
| **Core Services** | CVAT Server, CVAT UI |
| **Data Layer** | PostgreSQL (Azure Flexible Server), Redis (in-memory & on-disk), ClickHouse |
| **Workers** | Annotation, Chunks, Consensus, Export, Import, Quality Reports, Utils, Webhooks |
| **Supporting** | OPA (Policy Engine), Vector (Log Aggregation) |
| **Storage** | Azure File Shares for persistent data, logs, keys, and events |

### Key Features

- **Bootstrap Mode**: Solves resource dependency ordering (RBAC propagation delays)
- **KeyVault Integration**: Secure credential management for PostgreSQL and other secrets
- **Private DNS**: Internal service discovery via Azure Private DNS zones
- **Shared Storage**: Azure File Shares mounted to Container App Environment
