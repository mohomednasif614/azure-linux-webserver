
#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-azure-linux-webserver"
VM_NAME="vm-ubuntu-web01"

echo "=================================="
echo " Azure Infrastructure Health Check"
echo "=================================="

if ! command -v az >/dev/null 2>&1; then
    echo "ERROR: Azure CLI is not installed."
    exit 1
fi

echo
echo "[1] Azure Subscription"
az account show \
  --query "{Name:name,State:state}" \
  --output table

echo
echo "[2] Resource Group"
az group show \
  --name "$RESOURCE_GROUP" \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table

echo
echo "[3] Virtual Machine Power State"
az vm get-instance-view \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" \
  --output tsv

echo
echo "[4] Azure Resources"
az resource list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name,Type:type}" \
  --output table

echo
echo "Infrastructure inspection completed."
  
