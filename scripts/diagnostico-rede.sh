#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/diagnostico-rede.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "======================================"
echo " DIAGNÓSTICO DE REDE - COLETACERTA"
echo " Data: $(date)"
echo "======================================"

echo ""
echo "Hostname:"
hostname

echo ""
echo "Interfaces de rede:"
ip -brief address

echo ""
echo "Endereço IP da interface eth0:"
ip -4 addr show eth0 | awk '/inet / {print $2}'

echo ""
echo "Gateway padrão:"
ip route | awk '/default/ {print $3}'

echo ""
echo "Configuração DNS:"
grep "^nameserver" /etc/resolv.conf

echo ""
echo "Teste de resolução DNS:"
if getent hosts google.com; then
    echo "DNS funcionando corretamente."
else
    echo "ALERTA: Falha na resolução DNS."
fi

echo ""
echo "Teste de conectividade:"
if curl -Is --connect-timeout 5 https://google.com > /dev/null; then
    echo "Conectividade externa funcionando."
else
    echo "ALERTA: Falha na conexão externa."
fi

echo ""
echo "======================================"
echo " DIAGNÓSTICO FINALIZADO"
echo "======================================"
