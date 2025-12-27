# Check this config when working with Traefik

```
root@traefik-loadbalancer:/etc/traefik# ls -lta 
total 24
-rw-rw-r--   1 azureuser azureuser  957 Dec 27 04:03 dynamic.yml
-rw-rw-r--   1 azureuser azureuser  486 Dec 27 03:38 docker-compose.yml
drwxrwxrwx   3 root      root      4096 Dec 27 03:38 .
-rwxrwxrwx   1 root      root       520 Dec 27 03:27 traefik.yml
drwxrwxrwx   2 root      root      4096 Dec 27 01:59 certs
drwxr-xr-x 115 root      root      4096 Dec 27 01:59 ..
root@traefik-loadbalancer:/etc/traefik# 
root@traefik-loadbalancer:/etc/traefik# 
root@traefik-loadbalancer:/etc/traefik# ls -lta certs/
total 24
drwxrwxrwx 3 root root  4096 Dec 27 03:38 ..
-rw------- 1 root root 13344 Dec 27 02:52 acme.json
drwxrwxrwx 2 root root  4096 Dec 27 01:59 .
root@traefik-loadbalancer:/etc/traefik# 
```

The configuration file such as \*.yml, it can be placed anywhere, being granted to any user. 
But the cert/\*, it couldn't be allowed to have any permission other than root or specificly authorized persion.


```
sudo su 
mkdir /etc/traefik -p
mkdir /etc/traefik/certs

sudo chmod -R 700 /etc/traefik
sudo chmod -R 600 /etc/traefik/certs/*
```