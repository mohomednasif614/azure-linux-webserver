
# Azure Linux Web Server Architecture

```mermaid
flowchart TB
    USER["MacBook / Internet Client"]
    PIP["Standard Static Public IPv4"]
    subgraph AZ["Microsoft Azure — India South Central"]
        subgraph RG["Resource Group: rg-azure-linux-webserver"]
            subgraph VNET["VNet: vnet-linux-webserver — 10.0.0.0/16"]
                subgraph SUB["Subnet: snet-web — 10.0.1.0/24"]
                    NSG["Subnet NSG: nsg-linux-webserver"]
                    VM["Ubuntu VM: vm-ubuntu-web01 — 10.0.1.4"]
                    UFW["Ubuntu UFW Firewall"]
                    NGINX["Nginx Web Server"]
                    NSG --> VM
                    VM --> UFW
                    UFW --> NGINX
                end
            end
        end
    end
    USER -->|"SSH 22 — trusted IP / HTTP 80"| PIP
    PIP --> NSG
```

The diagram represents the logical traffic path. The Standard Static Public IP is associated with the VM's network interface, and the NSG is associated with the subnet.
  
