#!/bin/bash
set -euo pipefail

NAMESPACE="devops-portfolio"
OUTPUT_DIR="guia-13/reportes"
POD_NAME="zap-helper-pod"

echo "=== Iniciando extracción de reportes ZAP ==="

# 1. Crear carpeta de destino si no existe
mkdir -p "$OUTPUT_DIR"

# 2. Levantar pod temporal montando el PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  namespace: $NAMESPACE
spec:
  restartPolicy: Never
  containers:
  - name: helper
    image: alpine:latest
    command: ["sleep", "300"]
    volumeMounts:
    - name: vol-reports
      mountPath: /zap/wrk/reports
  volumes:
  - name: vol-reports
    persistentVolumeClaim:
      claimName: zap-reports
EOF

# 3. Esperar pod, copiar archivos y limpiar
kubectl wait --for=condition=ready pod/$POD_NAME -n $NAMESPACE --timeout=60s
kubectl cp $NAMESPACE/$POD_NAME:/zap/wrk/reports/. "$OUTPUT_DIR/"
kubectl delete pod $POD_NAME -n $NAMESPACE --now > /dev/null

echo "    Extracción completa..."
echo "Reporte disponible en: $OUTPUT_DIR"
