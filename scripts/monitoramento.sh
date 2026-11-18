
#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/monitoramento.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Iniciando monitoramento..."
echo "Data: $(date)"

while true; do
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 2}')
    MEMORIA=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
    DISCO=$(df / | awk 'END {gsub("%","",$5); print $5}')

    echo "CPU: $CPU% | Memória: $MEMORIA% | Disco: $DISCO%"

    if [ "$CPU" -ge 80 ]; then
        echo "ALERTA: Uso elevado de CPU!"
    fi

    if [ "$MEMORIA" -ge 80 ]; then
        echo "ALERTA: Uso elevado de memória!"
    fi

    if [ "$DISCO" -ge 80 ]; then
        echo "ALERTA: Espaço em disco elevado!"
    fi

    sleep 30
done

