
# Azure Linux Web Server — Troubleshooting Guide

## Overview

This document records real issues and troubleshooting observations encountered while deploying and managing an Ubuntu Linux web server on Microsoft Azure.

The objective is to demonstrate practical problem identification, investigation, resolution, and verification.

## Issue 1 — Azure VM Stop Operation Failed

**Problem:** Azure Portal initially displayed a failed virtual machine stop notification.

**Observed message:**
```text
Failed to stop virtual machine
Error: error
```

**Investigation:** The notification did not contain a specific root-cause error code.

**Resolution:** The normal Stop operation was retried from Azure Portal without selecting the force-deallocate option.

**Verification:** Azure Portal subsequently displayed `Stopped (deallocated)` and a successful stop notification.

**Lesson learned:** Check the VM power state after management operations. An SSH logout does not deallocate an Azure VM. If failures persist, inspect the Azure Activity Log for detailed error information.

## Issue 2 — SSH Private Key Not Found

**Problem:** An SSH connection command returned a private-key file error.

**Observed message:**
```text
Warning: Identity file /home/azureuser/.ssh/vm-ubuntu-web01_key.pem not accessible: No such file or directory.
```

**Cause:** The SSH client command was executed inside the remote Ubuntu VM instead of on the local MacBook.

The private key was stored on the MacBook, not on the Azure VM.

**Resolution:** Open a new local MacBook Terminal and run the SSH connection command from there.

```bash
ssh -i ~/.ssh/vm-ubuntu-web01_key.pem azureuser@<VM_PUBLIC_IP>
```

**Verification:** A fresh SSH connection succeeded.

**Lesson learned:** Distinguish local and remote terminal environments, and never copy a private SSH key to the server unnecessarily.

## Issue 3 — SSH Service Disabled but Running

**Problem:** The OpenSSH service was running, but `systemctl is-enabled ssh` returned `disabled`.

**Observed results:**
```text
ssh.service: active (running)
ssh.service: disabled
ssh.socket: enabled
ssh.socket: active
```

**Explanation:** Ubuntu 24.04 supports systemd socket activation for OpenSSH. An enabled SSH socket can activate the service for incoming connections.

**Verification commands:**
```bash
systemctl status ssh.socket --no-pager
systemctl is-enabled ssh.socket
systemctl is-active ssh.socket
```

**Resolution:** No unnecessary changes to the SSH service startup configuration were made.

**Lesson learned:** A disabled systemd service does not always indicate a service availability problem. Inspect related socket units and triggers.

## Issue 4 — GitHub Mermaid Diagram Failed to Render

**Problem:** GitHub initially displayed:
```text
Unable to render rich display
```

**Context:** The first architecture diagram contained several nested Mermaid subgraphs and detailed labels.

**Resolution:** The diagram was replaced with a simpler Mermaid flowchart with fewer structural and labeling complexities.

**Verification:** GitHub successfully rendered the updated diagram.

**Lesson learned:** Simplify the diagram to isolate renderer compatibility or syntax issues. The exact cause of the original rendering failure was not independently established.

## Issue 5 — Linux Firewall Activation and SSH Safety

**Risk:** Enabling UFW on a remote server without an SSH allow rule may block remote administration.

**Preventive actions:**

1. Confirm Azure NSG allows SSH from the trusted administrator IP.
2. Add host-level SSH and HTTP allow rules.
3. Review default UFW policies.
4. Enable UFW while keeping the existing SSH session open.
5. Verify UFW status.
6. Test a fresh SSH connection from the MacBook.
7. Test the public website after firewall activation.

**Commands used:**
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw show added
sudo ufw status verbose
```

**Verification:** UFW was active and both SSH and website access worked after activation.

**Lesson learned:** Validate remote access before and after firewall changes.

## Issue 6 — Nginx 404 Responses in Access Logs

**Observation:** Nginx access logs contained HTTP 404 responses for requests such as `/robots.txt`, `/favicon.ico`, and an unfamiliar validation path.

**Explanation:** HTTP 404 indicates the requested resource was not found. Some requests can originate from browsers, search crawlers, or automated internet scanners.

**Investigation commands:**
```bash
sudo tail -n 10 /var/log/nginx/access.log
sudo tail -n 10 /var/log/nginx/error.log
```

**Outcome:** The custom website continued to return HTTP 200 for valid homepage requests.

**Lesson learned:** A 404 response is not automatically evidence of a server failure or compromise. Investigate suspicious activity using appropriate logs and controls.

## Issue 7 — Git Repository Working Directory Mistake

**Problem:** A directory path was entered directly into the macOS Terminal and returned a permission-denied error.

**Cause:** A folder path was treated as a command rather than being opened or navigated to.

**Correct commands:**
```bash
cd ~/Projects/azure-linux-webserver/screenshots
open .
```

**Explanation:** `cd` changes directories. `open .` opens the current directory in Finder.

**Lesson learned:** Understand the difference between shell commands and filesystem paths.

## Issue 8 — Git Diff Whitespace Warning

**Problem:** Git detected an unnecessary blank line at the end of `website/index.html`.

**Observed message:**
```text
new blank line at EOF
```

**Explanation:** This was a formatting warning, not a security vulnerability or HTML execution error.

**Outcome:** The file was committed and successfully pushed to GitHub.

**Lesson learned:** Review `git diff --cached --check` warnings and maintain clean source formatting.

## Common Diagnostic Commands

| Command | Purpose |
|---|---|
| `systemctl status nginx --no-pager` | Check Nginx service |
| `systemctl status ssh --no-pager` | Check SSH service |
| `sudo nginx -t` | Validate Nginx configuration |
| `sudo sshd -t` | Validate SSH configuration |
| `sudo ufw status verbose` | Inspect UFW firewall |
| `sudo ss -tulnp` | Inspect listening sockets |
| `curl -I http://localhost` | Test local HTTP response |
| `free -h` | Review memory usage |
| `df -h /` | Review disk usage |
| `uptime` | Check uptime and system load |
| `git status` | Check Git working tree |
| `git diff --cached --check` | Check staged changes |

## Troubleshooting Methodology

A practical troubleshooting workflow:

1. Identify the observed symptom.
2. Collect relevant logs and status information.
3. Separate confirmed facts from possible causes.
4. Change one relevant variable at a time.
5. Verify the expected behavior after the change.
6. Document the outcome and preventive measures.

## Conclusion

This project provided practical experience with Azure VM lifecycle operations, OpenSSH, Linux service management, host firewall safety, Nginx logs, Git, and GitHub documentation.

The documented observations reflect a hands-on learning environment rather than a comprehensive production incident-response assessment.
  
