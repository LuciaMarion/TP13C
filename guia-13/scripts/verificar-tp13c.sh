#!/bin/bash
set -Eeuo pipefail

NS="devops-portfolio"
MON_NS="monitoring"

echo "    AUTOMATIZACIÓN DE RED Y ESTADO DEL CLUSTER    "
echo "                 POST DESPLIGUE                   "

echo "1. Estado de los Nodos K8s:"
kubectl get nodes

echo -e "\n2. Despliegue de Workloads (App & Monitoreo):"
kubectl rollout status deploy/postgres -n "$NS" --timeout=45s || true
kubectl rollout status deploy/backend -n "$NS" --timeout=45s || true
kubectl rollout status deploy/frontend -n "$NS" --timeout=45s || true
kubectl rollout status deploy/prometheus -n "$MON_NS" --timeout=45s || true
kubectl rollout status deploy/grafana -n "$MON_NS" --timeout=45s || true

echo -e "\n3. Infraestructura de Red y Almacenamiento:"
echo "-- [Ingress] --"
kubectl get ingress -n "$NS"
echo "-- [PVCs] --"
kubectl get pvc -n "$NS"

echo -e "\n4. Verificación de Endpoints HTTP:"
if curl -s -f http://notes.local/health > /dev/null; then
  echo "  [OK] /health responde 200"
else
  echo "  [ERROR] /health no responde (revisar /etc/hosts)"
fi

if curl -s -f http://notes.local/metrics > /dev/null; then
  echo "  [OK] /metrics expuesto correctamente"
else
  echo "  [ERROR] /metrics fuera de servicio"
fi

echo -e "\n5. Integridad de Telemetría (Observabilidad):"
if curl -s -f http://localhost:3000/api/health > /dev/null; then
  echo "  [OK] Grafana disponible en :3000"
else
  echo "  [ERROR] Grafana no accesible"
fi

if curl -s http://localhost:9090/api/v1/targets | grep -q '"health":"up"'; then
  echo "  [OK] Scraping Activo en Prometheus"
else
  echo "  [ERROR] Targets caídos en Prometheus"
fi

echo -e "\n6. Estado del Análisis Sec (ZAP Job):"
kubectl get job zap-security-scan -n "$NS" 2>/dev/null || echo "  [INFO] Job ZAP ausente o en espera"

echo "          ⋆⭒˚.⋆ DIAGNÓSTICO FINALIZADO ⋆⭒˚.⋆          "
