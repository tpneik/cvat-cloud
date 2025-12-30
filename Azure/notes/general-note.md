# General note

### In Azure Portal, Limitd to VNet is equal to external_enabled in terraform ingress option
If we also have VNet intergration for container app and want the container app to be published within VNet, remember to add this option in ingress.
```
external_enabled           = ingress.value.external_enabled
```
