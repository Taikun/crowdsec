#!/bin/bash

# Configuración
URL="http://127.0.0.1:8080"
# Check your /etc/crowdsec/local_api_credentials.yaml
MACHINE_ID="your machineID"
PASSWORD="your password"

# Colores bonitos para la terminal 😄
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Autenticación
echo -e "${YELLOW}Obteniendo token de autenticación...${RESET}"
TOKEN=$(curl -s -X POST "$URL/v1/watchers/login" \
  -H "Content-Type: application/json" \
  -d "{\"machine_id\": \"$MACHINE_ID\", \"password\": \"$PASSWORD\"}" | jq -r .token)

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo -e "${RED}❌ Error: No se pudo obtener el token. Revisa las credenciales.${RESET}"
  exit 1
fi

echo -e "${GREEN}✅ Token obtenido correctamente.${RESET}"

# Funciones útiles
function show_decisions() {
  echo -e "\n${YELLOW}📋 Decisiones activas:${RESET}"
  curl -s "$URL/v1/decisions" -H "Authorization: Bearer $TOKEN" | jq .
}

function show_alerts() {
  echo -e "\n${YELLOW}🚨 Alertas registradas:${RESET}"
  curl -s "$URL/v1/alerts" -H "Authorization: Bearer $TOKEN" | jq .
}

function show_scenarios() {
  echo -e "\n${YELLOW}🎯 Escenarios activos:${RESET}"
  curl -s "$URL/v1/scenarios" -H "Authorization: Bearer $TOKEN" | jq .
}

# Menú interactivo
echo -e "\n${GREEN}¿Qué quieres consultar?${RESET}"
select opt in "Decisiones" "Alertas" "Escenarios" "Todo" "Salir"; do
  case $opt in
    "Decisiones")
      show_decisions
      ;;
    "Alertas")
      show_alerts
      ;;
    "Escenarios")
      show_scenarios
      ;;
    "Todo")
      show_decisions
      show_alerts
      show_scenarios
      ;;
    "Salir")
      echo "👋 ¡Hasta luego!"
      break
      ;;
    *)
      echo -e "${RED}Opción inválida${RESET}"
      ;;
  esac
done
