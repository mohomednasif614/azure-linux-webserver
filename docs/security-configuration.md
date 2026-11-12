
# Azure Linux Web Server — Security Configuration

## 1. Security Overview

This document describes the security controls implemented for an Ubuntu Linux web server hosted on Microsoft Azure.

The project follows a defense-in-depth approach using network access restrictions, host firewall rules, SSH public-key authentication, and service hardening.

This is a learning deployment and has not undergone a comprehensive production security audit.

## 2. Network Security Architecture

The deployment uses two firewall layers:

1. **Azure Network Security Group (NSG)** — Filters traffic at the Azure subnet level.
2. **Ubuntu UFW Firewall** — Applies host-level packet filtering within the Linux virtual machine.

The network security group `nsg-linux-webserver` is associated with the `snet-web` subnet.

### Azure NSG Rules

| Rule | Source | Protocol | Port | Action |
|---|---|---|---|---|
| Allow-SSH-MyIP | Trusted administrator IPv4 /32 | TCP | 22 | Allow |
| Allow-HTTP-Web | Any | TCP | 80 | Allow |

SSH access is restricted at the Azure NSG to the administrator's trusted public IPv4 address.

HTTP Port 80 is publicly accessible to support the demonstration website.

Azure's default NSG rules also apply.

## 3. Ubuntu UFW Firewall

UFW (Uncomplicated Firewall) was configured as an additional host-level security control.

### Configured Rules

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
```

### Firewall Activation

```bash
sudo ufw enable
```

### Verification

```bash
sudo ufw status verbose
```

Verified configuration:

- Firewall status: Active
- Default incoming policy: Deny
- Default outgoing policy: Allow
- TCP Port 22: Allow
- TCP Port 80: Allow
- Corresponding IPv6 rules: Configured

Although the UFW SSH rule allows connections from any source, the existing Azure NSG restricts incoming SSH traffic to a trusted public IPv4 address.

After UFW activation, a fresh SSH connection and public website access were successfully tested.

## 4. SSH Authentication

The Ubuntu VM uses OpenSSH for remote administration.

### Authentication Controls

- Public-key authentication enabled.
- Password authentication disabled.
- Private SSH key retained on the administrator's MacBook.
- Administrative operations performed using the `azureuser` account and `sudo`.

The SSH private key is never committed to this repository.

### Local Private Key Protection

```bash
chmod 700 ~/.ssh
chmod 400 ~/.ssh/vm-ubuntu-web01_key.pem
```

## 5. SSH Hardening

SSH daemon settings were reviewed using:

```bash
sudo sshd -T
```

The following effective security settings were established:

```text
PermitRootLogin no
MaxAuthTries 3
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
```

A dedicated SSH configuration drop-in was created:

```text
/etc/ssh/sshd_config.d/40-hardening.conf
```

The custom hardening file contains:

```text
PermitRootLogin no
MaxAuthTries 3
```

Password authentication was already disabled by Azure Ubuntu image configuration files and was preserved.

### Safe Configuration Workflow

1. Inspect existing SSH settings and drop-in files.
2. Back up the main SSH configuration.
3. Create a dedicated hardening drop-in.
4. Validate syntax with `sudo sshd -t`.
5. Verify effective values with `sudo sshd -T`.
6. Reload `ssh.service`.
7. Confirm the SSH daemon remains active.
8. Establish a fresh SSH connection from the administrator's MacBook.

### Reload Command

```bash
sudo systemctl reload ssh.service
```

The SSH service remained active, and a subsequent public-key login succeeded.

## 6. Service and Port Verification

Listening network sockets were inspected using:

```bash
sudo ss -tulnp
```

Relevant services included:

| Service | Port | Purpose |
|---|---|---|
| OpenSSH | TCP 22 | Remote administration |
| Nginx | TCP 80 | HTTP web hosting |
| systemd-resolved | TCP/UDP 53 on loopback | Local DNS resolution |

The presence of a listening port does not establish external reachability; NSG and UFW rules determine whether inbound traffic is permitted.

## 7. Web Server Security

Nginx 1.24.0 was installed using Ubuntu package repositories.

The custom demonstration website contains static HTML and CSS and does not collect passwords or other sensitive user information.

### Current Limitation

The website is accessible over HTTP rather than HTTPS. HTTP does not provide transport encryption.

For a production deployment, HTTPS with a validated TLS certificate and appropriate access controls would be required.

## 8. Logging and Monitoring

Nginx logs were inspected using:

```bash
sudo tail -n 10 /var/log/nginx/access.log
sudo tail -n 10 /var/log/nginx/error.log
```

The access log showed successful HTTP 200 responses, HTTP 404 responses for nonexistent resources, and requests from external clients.

External requests alone do not demonstrate successful intrusion. Public web servers may receive automated internet scanning traffic.

Sensitive client IP addresses and request details should not be published without review.

## 9. Security Limitations and Future Improvements

The current deployment provides a foundational security configuration but is not a fully hardened production environment.

Potential improvements include:

- Configure HTTPS with a trusted TLS certificate.
- Restrict host-level SSH rules to approved administrator addresses where operationally appropriate.
- Implement centralized security logging and monitoring.
- Configure alerting for suspicious activity.
- Evaluate host intrusion protection and rate limiting.
- Introduce automated patching and vulnerability review.
- Implement and test backup and recovery procedures.
- Review identity and role-based access permissions.

## 10. Security Summary

Implemented controls:

- [x] Azure subnet-level NSG
- [x] Trusted-IP restriction for SSH at the NSG
- [x] Ubuntu UFW host firewall
- [x] SSH public-key authentication
- [x] Password authentication disabled
- [x] Direct root SSH login disabled
- [x] Authentication attempt limit configured
- [x] SSH configuration tested before reloading
- [x] Fresh SSH connection verified
- [x] Nginx logs inspected
- [ ] HTTPS/TLS configured
- [ ] Centralized monitoring and security alerts
- [ ] Production security assessment
  
