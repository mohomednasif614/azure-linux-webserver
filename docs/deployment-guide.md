
# Azure Linux Web Server — Deployment Guide

## 1. Project Overview

This guide documents the deployment of an Ubuntu Linux virtual machine and Nginx web server on Microsoft Azure.

The project was implemented using Azure for Students, with an emphasis on networking, security, Linux administration, and cost awareness.

## 2. Azure Infrastructure

| Resource | Configuration |
|---|---|
| Subscription | Azure for Students |
| Region | India South Central |
| Resource Group | `rg-azure-linux-webserver` |
| Virtual Network | `vnet-linux-webserver` |
| VNet CIDR | `10.0.0.0/16` |
| Subnet | `snet-web` |
| Subnet CIDR | `10.0.1.0/24` |
| NSG | `nsg-linux-webserver` |
| Virtual Machine | `vm-ubuntu-web01` |
| VM Size | `Standard_B2ats_v2` |
| Image | Ubuntu Server 24.04 LTS |
| OS Disk | 64 GiB Premium SSD |
| Public IP | Standard, Static IPv4 |

## 3. Network Configuration

A virtual network and a dedicated web subnet were created. The NSG was associated with the subnet.

Custom inbound rules:

| Rule | Source | Port | Protocol |
|---|---|---|---|
| Allow-SSH-MyIP | Trusted administrator public IPv4 /32 | 22 | TCP |
| Allow-HTTP-Web | Any | 80 | TCP |

Azure's default NSG rules remain applicable.

## 4. VM Deployment

The Ubuntu virtual machine was created using Azure Portal with:

- SSH public-key authentication
- Administrator username: `azureuser`
- Ubuntu Server 24.04 LTS
- No additional NIC-level NSG
- Standard static public IPv4
- Delete OS disk, NIC and public IP when the VM is deleted

A private SSH key was downloaded and stored securely on the administrator's MacBook. The private key is not included in this repository.

## 5. SSH Connection

The private key was moved to the local `~/.ssh` directory and its permissions restricted:

```bash
chmod 700 ~/.ssh
chmod 400 ~/.ssh/vm-ubuntu-web01_key.pem
```

The administrator connected using:

```bash
ssh -i ~/.ssh/vm-ubuntu-web01_key.pem azureuser@<VM_PUBLIC_IP>
```

The SSH connection was verified successfully.

## 6. Ubuntu Administration and Updates

Initial system checks included:

```bash
whoami
hostname
pwd
ls -la
df -h
free -h
uname -r
cat /etc/os-release
```

Package metadata and installed packages were updated:

```bash
sudo apt update
sudo apt upgrade
```

19 packages were upgraded during the recorded maintenance session. Three updates were deferred due to Ubuntu phased updates, and no reboot was required.

## 7. Nginx Installation

Nginx was installed with:

```bash
sudo apt install nginx
```

The service and local HTTP response were verified:

```bash
nginx -v
systemctl status nginx --no-pager
systemctl is-enabled nginx
curl -I http://localhost
```

Nginx returned HTTP 200 OK.

## 8. Custom Website Deployment

The configured Nginx document root was:

```text
/var/www/html
```

A custom HTML/CSS page was created at:

```text
/var/www/html/index.html
```

The page was subsequently verified in a MacBook web browser via the Azure VM's public IPv4 address over HTTP.

The website source is maintained in `website/index.html` in this repository.

## 9. Firewall and SSH Hardening

The Ubuntu host-level firewall was configured with TCP 22 and TCP 80 allowed, and was enabled with an inbound deny policy.

SSH hardening settings:

```text
PermitRootLogin no
MaxAuthTries 3
PasswordAuthentication no
PubkeyAuthentication yes
```

Settings were validated using `sshd -t` and `sshd -T`. The SSH service configuration was reloaded, and a fresh SSH connection was successfully established.

Detailed security notes are documented separately.

## 10. Monitoring and Verification

The following tools were used:

```bash
uptime
free -h
df -h /
systemctl is-active nginx ssh
sudo ss -tulnp
sudo tail -n 10 /var/log/nginx/access.log
sudo tail -n 10 /var/log/nginx/error.log
```

The server showed low load, sufficient available memory, working Nginx and SSH services, and listening TCP ports 22 and 80.

## 11. Cost Management

The VM was stopped and deallocated after the learning session to avoid continued compute billing.

The managed OS disk and static public IP remain allocated and may incur charges even while the VM is deallocated.

## 12. Scope and Limitations

This is a single-VM learning deployment, not a production-certified architecture.

The website uses HTTP rather than HTTPS. There is no configured custom domain, load balancer, automated backup, deployment pipeline, or high-availability architecture.

Future work may include TLS, infrastructure automation, monitoring alerts, backup validation, and repeatable deployment workflows.
  
