#!/bin/bash
set -e
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo sh -eux <<EOF
# Install newuidmap & newgidmap binaries
apt-get install -y uidmap
EOF
# dockerd-rootless-setuptool.sh install
mkdir -p /etc/traefik/certs
sudo tee ./docker-compose.yml > /dev/null <<'EOF'
version: '3.8'

services:
  traefik:
    image: traefik:v3.6.5
    container_name: traefik
    restart: unless-stopped
    command:
      - --log.level=INFO
      - --accesslog=true
    networks:
      - traefik
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./dynamic.yml:/etc/traefik/dynamic.yml:ro
      - /etc/traefik/certs:/etc/traefik/certs

networks:
  traefik:
    external: true
    name: traefik
EOF
sudo tee ./traefik.yml > /dev/null <<'EOF'
api:
  dashboard: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /etc/traefik/dynamic.yml
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: tpneik@gmail.com # input your email is very important
      storage: /etc/traefik/certs/acme.json
      httpChallenge:
        entryPoint: web
EOF
sudo tee ./dynamic.yml > /dev/null <<EOF
http:
  routers:
    frontend-1:
      rule: "Host(`traefik.eastasia.cloudapp.azure.com`) && PathPrefix(`/`)"
      entryPoints:
        - websecure
      service: frontend
      priority: 1
      tls:
        certResolver: letsencrypt
    backend:
      rule: "Host(`traefik.eastasia.cloudapp.azure.com`) && (PathPrefix(`/api/`) || PathPrefix(`/static/`) || PathPrefix(`/admin`) || PathPrefix(`/django-rq`))"
      entryPoints:
        - websecure
      service: backend
      priority: 2
      tls:
        certResolver: letsencrypt
    
  services:
    frontend:
      loadBalancer:
        servers:
          - url: "http://cvat-ui.app:8000"
    backend:
      loadBalancer:
        servers:
          - url: "http://cvat-server.app:8080"
EOF

docker compose up -d