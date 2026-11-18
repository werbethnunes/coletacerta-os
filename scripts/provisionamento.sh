
#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
SITE_DIR="$HOME/coletacerta-site"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/provisionamento.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Iniciando provisionamento..."
echo "Data: $(date)"

echo "Atualizando pacotes..."
sudo apt update

echo "Instalando dependências..."
sudo apt install -y nginx git curl htop

echo "Criando diretório da aplicação..."
sudo mkdir -p /var/www/coletacerta

echo "Copiando arquivos do site..."
sudo cp -r "$SITE_DIR"/. /var/www/coletacerta/

echo "Configurando permissões..."
sudo chown -R www-data:www-data /var/www/coletacerta
sudo chmod -R 755 /var/www/coletacerta

echo "Configurando Nginx..."
sudo ln -sf /etc/nginx/sites-available/coletacerta /etc/nginx/sites-enabled/coletacerta
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t

echo "Iniciando serviço Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Provisionamento concluído!"
echo "Data: $(date)"

