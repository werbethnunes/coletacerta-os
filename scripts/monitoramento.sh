
#!/bin/bash

set -e

PROJECT_DIR="$HOME/coletacerta-os"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/monitoramento.log"
INTERVALO=30
LIMITE=80

mkdir -p "$LOG_DIR"

exec >> "$LOG_FILE" 2>&1

echo "Monitoramento iniciado em $(date)"

while true; do
    CPU_OCIOSA=$(LC_ALL=C top -bn1 | awk -F',' '/Cpu\(s\)/ {
        for (i=1; i<=NF; i++) {
            if ($i ~ / id/) {
                gsub(/[^0-9.]/, "", $i)
                print $i
                exit
            }
        }
    }')

    CPU=$(awk -v idle="$CPU_OCIOSA" 'BEGIN {
        printf "%.0f", 100 - idle
    }')

    MEMORIA=$(free | awk '/Mem:/ {
        printf "%.0f", ($3 / $2) * 100
    }')

    DISCO=$(df -P / | awk 'NR==2 {
        gsub("%", "", $5)
        print $5
    }')

    echo "$(date '+%d/%m/%Y %H:%M:%S') | CPU: ${CPU}% | Memória: ${MEMORIA}% | Disco: ${DISCO}%"

    if [ "$CPU" -ge "$LIMITE" ]; then
        echo "ALERTA: Uso de CPU acima de ${LIMITE}%"
    fi

    if [ "$MEMORIA" -ge "$LIMITE" ]; then
        echo "ALERTA: Uso de memória acima de ${LIMITE}%"
    fi

    if [ "$DISCO" -ge "$LIMITE" ]; then
        echo "ALERTA: Uso de disco acima de ${LIMITE}%"
    fi

    sleep "$INTERVALO"
done
