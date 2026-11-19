#!/bin/bash

PROJECT_DIR="$HOME/coletacerta-os"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/diagnostico-rede.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

ERROS=0

verificar() {
    if [ "$1" = "OK" ]; then
        echo "OK: $2"
    else
        echo "FALHA: $2"
        ERROS=$((ERROS + 1))
    fi
}

echo "Diagnóstico de rede iniciado em $(date)"

echo ""
echo "Hostname:"
HOSTNAME_ATUAL=$(hostname)
echo "$HOSTNAME_ATUAL"
verificar "OK" "Hostname identificado"

echo ""
echo "Interfaces de rede:"
ip -brief address

if ip link show eth0 > /dev/null 2>&1; then
    IP=$(ip -4 addr show eth0 | awk '/inet / {print $2; exit}')
    if [ -n "$IP" ]; then
        verificar "OK" "Interface eth0 ativa com IP $IP"
    else
        verificar "FALHA" "Interface eth0 sem endereço IPv4"
    fi
else
    verificar "FALHA" "Interface eth0 não encontrada"
fi

echo ""
echo "Gateway padrão:"
GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

if [ -n "$GATEWAY" ]; then
    echo "$GATEWAY"
    verificar "OK" "Gateway identificado"
else
    verificar "FALHA" "Gateway padrão não encontrado"
fi

echo ""
echo "Configuração DNS:"
if [ -r /etc/resolv.conf ]; then
    DNS=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf)
    if [ -n "$DNS" ]; then
        echo "$DNS"
        verificar "OK" "Servidor DNS identificado"
    else
        verificar "FALHA" "Nenhum servidor DNS configurado"
    fi
else
    verificar "FALHA" "Arquivo resolv.conf indisponível"
fi

echo ""
echo "Teste de resolução DNS:"
if getent hosts google.com > /dev/null 2>&1; then
    verificar "OK" "Resolução DNS funcionando"
else
    verificar "FALHA" "Não foi possível resolver google.com"
fi

echo ""
echo "Teste de conectividade:"
if curl -fsS --connect-timeout 5 https://google.com -o /dev/null; then
    verificar "OK" "Conectividade externa funcionando"
else
    verificar "FALHA" "Conexão externa indisponível"
fi

echo ""
echo "Diagnóstico finalizado em $(date)"
echo "Total de falhas: $ERROS"

if [ "$ERROS" -gt 0 ]; then
    exit 1
fi

echo "Resultado: rede operacional"
