#!/usr/bin/env python3

import os
import sys
import subprocess
import time
from pathlib import Path

# Colors for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

def print_status(message):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def print_success(message):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

def print_warning(message):
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

def print_error(message):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

def run_command(cmd, shell=False):
    """Run a command and return success status"""
    try:
        if shell:
            result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed: {e}")
        return False

def check_docker():
    """Check if Docker is installed and running"""
    print_status("Checking Docker installation...")
    if not run_command(["docker", "--version"]):
        print_error("Docker is not installed. Please install Docker first.")
        sys.exit(1)
    
    if not run_command(["docker", "info"]):
        print_error("Docker daemon is not running. Please start Docker first.")
        sys.exit(1)
    
    print_success("Docker is installed and running")

def check_dns_resolution(domain):
    """Check if domain resolves to this server"""
    print_status(f"Checking DNS resolution for {domain}...")
    
    try:
        # Get server's public IP using external service
        result = subprocess.run(["curl", "-4s", "https://api.ipify.org"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            server_ip = result.stdout.strip()
            print_warning(f"⚠️  Make sure {domain} DNS A record points to: {server_ip}")
            print_warning("If DNS is not configured, the test page won't be accessible")
            
            # Quick DNS check
            dns_check = subprocess.run(["nslookup", domain], capture_output=True, text=True)
            if dns_check.returncode != 0:
                print_warning(f"❌ DNS lookup failed for {domain}")
            else:
                print_success(f"✅ DNS lookup successful for {domain}")
                
    except Exception as e:
        print_warning(f"Could not determine server IP. Please ensure {domain} points to your server.")

def create_directories():
    """Create necessary directories"""
    directories = [
        "/opt/traefik",
        "/etc/traefik",
        "/etc/traefik/certs"
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
    
    print_success("Directories created")

def create_traefik_config(email):
    """Create Traefik configuration file"""
    config_content = f"""# Traefik Global Configuration
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
      email: {email or "admin@example.com"}
      storage: /etc/traefik/certs/acme.json
      httpChallenge:
        entryPoint: web
"""
    
    with open("/etc/traefik/traefik.yml", "w") as f:
        f.write(config_content)
    
    print_success("Traefik configuration created")

def create_dynamic_routing_config():
    """Create Traefik configuration file"""
    config_content = f"""# Traefik Global Configuration
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
"""
    
    with open("/etc/traefik/dynamic.yml", "w") as f:
        f.write(config_content)
    
    print_success("Traefik configuration created")

def create_traefik_compose():
    """Create Docker Compose file for Traefik"""
    compose_content = """version: '3.8'

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
      - /etc/traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - /etc/traefik/dynamic.yml:/etc/traefik/dynamic.yml:ro
      - /etc/traefik/certs:/etc/traefik/certs

networks:
  traefik:
    external: true
    name: traefik
"""
    
    with open("/opt/traefik/docker-compose.yml", "w") as f:
        f.write(compose_content)
    print_success("Docker Compose configuration created")

def setup_docker_network():
    """Create Docker network if it doesn't exist"""
    print_status("Setting up Docker network...")
    
    result = subprocess.run(["docker", "network", "ls", "--format", "{{.Name}}"], 
                          capture_output=True, text=True)
    
    if "traefik" not in result.stdout:
        if run_command(["docker", "network", "create", "traefik"]):
            print_success("Docker network 'traefik' created")
    else:
        print_warning("Docker network 'traefik' already exists")

def deploy_traefik():
    """Deploy Traefik"""
    print_status("Deploying Traefik...")
    
    os.chdir("/opt/traefik")
    
    # Start services
    if run_command("docker compose up -d", shell=True):
        print_success("Traefik deployed successfully")

def install_docker():
    """Install docker on this machine"""
    
    print_status("Installing docker.............")
    run_command("curl -fsSL https://get.docker.com -o /tmp/get-docker.sh", shell=True)
    print_status("Download convenient script ok.")
    os.chdir("/tmp")
    if run_command("sh get-docker.sh", shell=True):
        print_success(f"Successfully installed Docker")
    else 
        print_error("Not Successfully installed Docker")


def display_final_info(test_domain):
    """Display final setup information"""
    print_success("Traefik setup completed!")
    print("")
    print("Summary:")
    print("--------")
    print("• Traefik configuration: /etc/traefik/")
    print("• Docker Compose files: /opt/traefik/")
    print("• Docker network: traefik")
    print("")
    
    if test_domain:
        print("🎉 Your test page is available at:")
        print(f"  • https://{test_domain}")
        print("")
        print("⏰ Test page will auto-remove in 10 minutes")
    else:
        print("No test domain provided - only Traefik is running.")
        print("You can add services by:")
        print("1. Adding them to the 'traefik' network")
        print("2. Setting appropriate Traefik labels")
    
    print("")
    print("To manage Traefik:")
    print("  cd /opt/traefik && docker compose [logs|restart|down]")
    print("")
    
    if test_domain:
        print("To manually remove test page early:")
        print("  cd /opt/traefik && docker compose -f docker-compose-test.yml down")

def main():
    """Main setup function"""
    print_status("Starting Traefik automated setup...")

    # Install docker
    install_docker()
    
    # Check prerequisites
    check_docker()
    
    # Get user input
    emain = "tpneik@gmail.com
    domain = "traefik.eastasia.cloudapp.azure.com"
    
    # Check DNS if domain provided
    if test_domain:
        check_dns_resolution(domain)
    
    # Setup
    create_directories()
    create_traefik_compose()
    create_dynamic_routing_config()
    create_traefik_config(email)
    setup_docker_network()
    
    # Deploy
    deploy_traefik()
    
    # Final info
    display_final_info(domain)
    print_success("Setup complete! 🎉")

if __name__ == "__main__":
    main()