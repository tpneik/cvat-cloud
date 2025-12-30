# Vector failed resolve Clikchouse DNS name

When the log of Vector such as:
```log
Connecting to stream...
2025-12-30T02:04:03.61054  Connecting to the container 'cvat-vector'...
2025-12-30T02:04:03.63319  Successfully Connected to container: 'cvat-vector' [Revision: 'cvat-vector--0000002', Replica: 'cvat-vector--0000002-65b476b7f5-49rlg']
2025-12-30T01:59:23.2582321Z stderr F 2025-12-30T01:59:23.256945Z  INFO vector::app: Internal log rate limit configured. internal_log_rate_secs=10
2025-12-30T01:59:23.2589255Z stderr F 2025-12-30T01:59:23.258808Z  INFO vector::app: Log level is enabled. level="vector=info,codec=info,vrl=info,file_source=info,tower_limit=trace,rdkafka=info,buffers=info,lapin=info,kube=info"
2025-12-30T01:59:23.2634192Z stderr F 2025-12-30T01:59:23.263285Z  INFO vector::app: Loading configs. paths=["/etc/vector/vector.toml"]
2025-12-30T01:59:23.3160255Z stderr F 2025-12-30T01:59:23.315804Z  INFO vector::topology::running: Running healthchecks.
2025-12-30T01:59:23.3162562Z stderr F 2025-12-30T01:59:23.316031Z  INFO source{component_kind="source" component_id=http-events component_type=http_server component_name=http-events}: vector::sources::util::http::prelude: Building HTTP server. address=0.0.0.0:8282
2025-12-30T01:59:23.3166858Z stderr F 2025-12-30T01:59:23.316276Z  INFO vector: Vector has started. debug="false" version="0.26.0" arch="x86_64" revision="c6b5bc2 2022-12-05"
2025-12-30T01:59:23.3167052Z stderr F 2025-12-30T01:59:23.316314Z  INFO vector::app: API is disabled, enable by setting `api.enabled` to `true` and use commands like `vector top`.
2025-12-30T01:59:28.3244330Z stderr F 2025-12-30T01:59:28.324232Z  WARN http: vector::internal_events::http_client: HTTP error. error=error trying to connect: dns error: failed to lookup address information: Try again error_type="request_failed" stage="processing" internal_log_rate_limit=true
2025-12-30T01:59:28.3244708Z stderr F 2025-12-30T01:59:28.324299Z ERROR vector::topology::builder: msg="Healthcheck: Failed Reason." error=Failed to make HTTP(S) request: error trying to connect: dns error: failed to lookup address information: Try again component_kind="sink" component_type="clickhouse" component_id=clickhouse component_name=clickhouse
```


Here is its ARM data:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "containerapps_cvat_vector_name": {
            "defaultValue": "cvat-vector",
            "type": "String"
        },
        "managedEnvironments_cvat_app_env_externalid": {
            "defaultValue": "/subscriptions/bb79d671-6949-4663-854e-14424d667454/resourceGroups/cvat-prod-rg/providers/Microsoft.App/managedEnvironments/cvat-app-env",
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.App/containerapps",
            "apiVersion": "2025-02-02-preview",
            "name": "[parameters('containerapps_cvat_vector_name')]",
            "location": "Southeast Asia",
            "kind": "containerapps",
            "identity": {
                "type": "None"
            },
            "properties": {
                "managedEnvironmentId": "[parameters('managedEnvironments_cvat_app_env_externalid')]",
                "environmentId": "[parameters('managedEnvironments_cvat_app_env_externalid')]",
                "workloadProfileName": "Consumption",
                "configuration": {
                    "activeRevisionsMode": "Single",
                    "ingress": {
                        "external": false,
                        "targetPort": 8282,
                        "exposedPort": 8282,
                        "transport": "Tcp",
                        "traffic": [
                            {
                                "weight": 100,
                                "latestRevision": true
                            }
                        ],
                        "allowInsecure": false,
                        "stickySessions": {
                            "affinity": "none"
                        }
                    },
                    "identitySettings": [],
                    "maxInactiveRevisions": 100
                },
                "template": {
                    "containers": [
                        {
                            "image": "docker.io/timberio/vector:0.26.0-alpine",
                            "imageType": "ContainerImage",
                            "name": "[parameters('containerapps_cvat_vector_name')]",
                            "env": [
                                {
                                    "name": "CLICKHOUSE_HOST",
                                    "value": "cvat-clickhouse"
                                },
                                {
                                    "name": "CLICKHOUSE_PORT",
                                    "value": "8123"
                                },
                                {
                                    "name": "CLICKHOUSE_DB",
                                    "value": "cvat"
                                },
                                {
                                    "name": "CLICKHOUSE_USER",
                                    "value": "user"
                                },
                                {
                                    "name": "CLICKHOUSE_PASSWORD",
                                    "value": "user"
                                }
                            ],
                            "resources": {
                                "cpu": 0.25,
                                "memory": "0.5Gi"
                            },
                            "probes": [],
                            "volumeMounts": [
                                {
                                    "volumeName": "component",
                                    "mountPath": "/etc/vector"
                                }
                            ]
                        }
                    ],
                    "scale": {
                        "minReplicas": 1,
                        "maxReplicas": 1,
                        "cooldownPeriod": 300,
                        "pollingInterval": 30
                    },
                    "volumes": [
                        {
                            "name": "component",
                            "storageType": "AzureFile",
                            "storageName": "[concat(parameters('containerapps_cvat_vector_name'), '-component')]",
                            "mountOptions": "dir_mode=0777,file_mode=0777"
                        }
                    ]
                }
            }
        }
    ]
}
```

