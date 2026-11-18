#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
SITE_DIR="$HOME/coletacerta-site"
WEB_DIR="/var/www/coletacerta"
LOG_DIR="$PROJECT_DIR/logs"
CONFIG_FILE="$PROJECT_DIR/config/coletacerta"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/provisionamento.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Iniciando provisionamento em $(date)"

echo "Atualizando pacotes..."
sudo apt update

echo "Instalando dependências..."
sudo apt install -y nginx git curl htop

if [ ! -d "$SITE_DIR/.git" ]; then
    echo "Clonando aplicação..."
    git clone https://github.com/werbethnunes/coletaCerta.git "$SITE_DIR"
fi

if [ ! -f "$SITE_DIR/index.html" ]; then
    echo "Arquivo index.html não encontrado."
    exit 1
fi

echo "Preparando diretório da aplicação..."
sudo mkdir -p "$WEB_DIR"
sudo cp -r "$SITE_DIR"/. "$WEB_DIR"/
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuração do Nginx não encontrada."
    exit 1
fi

echo "Configurando Nginx..."
sudo cp "$CONFIG_FILE" /etc/nginx/sites-available/coletacerta
sudo ln -sf /etc/nginx/sites-available/coletacerta /etc/nginx/sites-enabled/coletacerta
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Verificando aplicação..."

if curl -fsS http://localhost > /dev/null; then
    echo "Aplicação disponível em http://localhost"
else
    echo "Falha ao acessar a aplicação."
    exit 1
fi

echo "Provisionamento concluído em $(date)"
