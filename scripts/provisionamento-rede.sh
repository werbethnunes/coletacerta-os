#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/provisionamento-rede.log"
USUARIO=$(id -un)

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Iniciando provisionamento de rede em $(date)"

if ! grep -qi microsoft /proc/sys/kernel/osrelease; then
    echo "Este script foi preparado para execução no WSL 2."
    exit 1
fi

echo "Configurando hostname e systemd..."

if [ -f /etc/wsl.conf ]; then
    sudo cp /etc/wsl.conf "/etc/wsl.conf.bak.$(date +%Y%m%d%H%M%S)"
fi

sudo tee /etc/wsl.conf > /dev/null <<CONFIG
[boot]
systemd=true

[user]
default=$USUARIO

[network]
hostname=coletacerta-server
CONFIG

echo "Configuração do WSL atualizada."

echo "Verificando interface de rede..."
ip link show eth0

IP=$(ip -4 addr show eth0 | awk '/inet / {print $2; exit}')
GATEWAY=$(ip route | awk '/default/ {print $3; exit}')
DNS=$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf)

if [ -z "$IP" ] || [ -z "$GATEWAY" ] || [ -z "$DNS" ]; then
    echo "Falha ao identificar IP, gateway ou DNS."
    exit 1
fi

echo "IP identificado: $IP"
echo "Gateway identificado: $GATEWAY"
echo "DNS identificado: $DNS"

if ! getent hosts google.com > /dev/null; then
    echo "Falha na resolução DNS."
    exit 1
fi

echo "Resolução DNS funcionando."

if ! curl -fsS --connect-timeout 5 https://google.com -o /dev/null; then
    echo "Falha na conectividade externa."
    exit 1
fi

echo "Conectividade externa funcionando."
echo "Provisionamento de rede concluído."
echo "Reinicie o WSL com wsl --shutdown para aplicar o hostname."
