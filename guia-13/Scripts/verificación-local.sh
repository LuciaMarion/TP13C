#!/bin/bash
set -eo pipefail

HOST_INGRESS="notes.local"
URL_SALUD="http://${HOST_INGRESS}/health"
URL_GRAFANA="http://localhost:3000"

echo "･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･"
echo "          SCRIPT DE VERIFICACIÓN LOCAL          "
echo "･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･･ﾟ ･ﾟ·:｡･ﾟﾟ･"

# 1. Ping al host de Ingress (notes.local)
echo -n ">>> 1. Probando conexión (ping) a $HOST_INGRESS... "
if ping -c 1 -W 2 "$HOST_INGRESS" > /dev/null 2>&1; then
    echo "[OK]"
else
    echo "[FALLÓ] (Asegurate de tener '$HOST_INGRESS' mapeado en /etc/hosts)"
    exit 1
fi

# 2. Curl al endpoint de salud de la app
echo -n ">>> 2. Verificando endpoint de salud ($URL_SALUD)... "
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$URL_SALUD" || true)

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "[OK] (HTTP 200)"
else
    echo "[FALLÓ] (Código devuelto: $HTTP_STATUS)"
    exit 1
fi

# 3. Verificación de Grafana en el puerto 3000
echo -n ">>> 3. Verificando dashboard de Grafana ($URL_GRAFANA)... "
GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$URL_GRAFANA" || true)

# Aceptamos 200 (OK) o 302 (Redirección al Login)
if [ "$GRAFANA_STATUS" -eq 200 ] || [ "$GRAFANA_STATUS" -eq 302 ]; then
    echo "[OK] (HTTP $GRAFANA_STATUS)"
else
    echo "[FALLÓ] (Código devuelto: $GRAFANA_STATUS)"
    exit 1
fi

echo "   ¡TODAS LAS VERIFICACIONES PASARON CON ÉXITO!   "
