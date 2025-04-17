#!/bin/bash

# Configuración
CSCLI="/usr/bin/cscli"
SEND_SCRIPT="/yourfolder/send_telegram.sh"
LOG="/var/log/crowdsec-telegram.log"
DURATION="14h"

# Obtener alertas recientes
ALERTS=$($CSCLI alerts list --since "$DURATION" -o json)

# Verificar si hay alertas válidas
if [ "$ALERTS" != "null" ] && [ -n "$ALERTS" ] && [ "$ALERTS" != "[]" ]; then

  # Construir resumen con jq
  SUMMARY=$(echo "$ALERTS" | jq -r '
    if type == "array" then
      .[] | select(.decisions != null and .decisions[0] != null) |
      "IP: \(.decisions[0].value) - \(.decisions[0].scenario)"
    else empty end
  ')

  if [ -n "$SUMMARY" ]; then
    COUNT=$(echo "$SUMMARY" | wc -l)
    FORMATTED=$(echo "$SUMMARY" | nl -w1 -s "️⃣ ")
    
    MSG="🛡️ CrowdSec reporta nuevas IPs bloqueadas:\n\n$FORMATTED\n\nTotal: $COUNT IP$( [ $COUNT -eq 1 ] || echo "s" ) bloqueada$( [ $COUNT -eq 1 ] || echo "s" )"
    
    echo "[$(date)] Enviando resumen:\n$MSG" >> "$LOG"
    $SEND_SCRIPT "$MSG"
  else
    echo "[$(date)] No hay decisiones nuevas con IP válida." >> "$LOG"
  fi
else
  echo "[$(date)] Sin alertas nuevas." >> "$LOG"
fi
