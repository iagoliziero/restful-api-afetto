#!/bin/bash

# ============================================
# Afetto — VM Azure CLI
# FIAP 2026 — DevOps Tools & Cloud Computing
# ============================================

# --- Variáveis ---
RESOURCE_GROUP="rg-afetto-dev"
VM_NAME="vm-afetto-app"
LOCATION="spaincentral"
VM_SIZE="Standard_B2s_v2"
IMAGE="Ubuntu2404"
ADMIN_USER="admlnx"
ADMIN_PASS="Afetto@2tdsvms2026"
VNET_NAME="vnet-afetto"
NSG_NAME="nsg-afetto"
PUBLIC_IP_NAME="pip-afetto"

# --- 1. Resource Group ---
echo "[1/5] Criando Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# --- 2. Criar VM ---
echo "[2/5] Criando VM..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $VM_SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USER \
  --admin-password $ADMIN_PASS \
  --vnet-name $VNET_NAME \
  --nsg $NSG_NAME \
  --public-ip-address $PUBLIC_IP_NAME \
  --public-ip-sku Standard \
  --tags "projeto=afetto" "turma=2tds"

# --- 3. Abrir Portas ---
echo "[3/5] Abrindo portas..."
az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 22 --priority 1000

az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 8080 --priority 1001

az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 1521 --priority 1002

# --- 4. Monitoramento ---
echo "[4/5] Configurando alerta de CPU..."
az monitor metrics alert create \
  -n Alert-CPU-Afetto \
  -g $RESOURCE_GROUP \
  --scopes $(az vm show -g $RESOURCE_GROUP -n $VM_NAME --query id -o tsv) \
  --description "CPU acima de 90% por 5min" \
  --condition "avg Percentage CPU > 90" \
  --window-size 5m \
  --evaluation-frequency 1m

# --- 5. IP Público ---
echo "[5/5] Coletando IP publico..."
PUBLIC_IP=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "================================"
echo "  VM criada com sucesso!"
echo "  IP: $PUBLIC_IP"
echo "  SSH: ssh $ADMIN_USER@$PUBLIC_IP"
echo "================================"

# --- Para deletar ao final da apresentação ---
# az group delete -n rg-afetto-dev --yes --no-wait
