#!/usr/bin/env bash
# ==============================================================================
# PathSeek — Script de Actualización y Despliegue en Servidor VPS (Contabo)
# ==============================================================================
# Uso:
#   cd ~/pathseek
#   chmod +x scripts/deploy-vps.sh
#   ./scripts/deploy-vps.sh
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

echo "========================================================"
echo "  PathSeek — Despliegue en Producción (VPS Contabo)"
echo "  Directorio: ${PROJECT_ROOT}"
echo "========================================================"

# 1. Verificar archivo de entorno
if [ ! -f .env ]; then
  echo "❌ Error: Archivo .env no encontrado en ${PROJECT_ROOT}." >&2
  echo "Copia .env.prod.example a .env y completa las credenciales antes de continuar." >&2
  exit 1
fi

# Cargar variables de entorno
set -a
source .env
set +a

# 2. Sincronizar repositorio si está gestionado con Git
if [ -d .git ]; then
  echo "📥 [1/6] Obteniendo últimos cambios de Git..."
  git fetch origin main
  git reset --hard origin/main
else
  echo "ℹ️  [1/6] No se detectó repositorio Git activo (.git no existe). Saltando git pull."
fi

# 3. Asegurar que PostgreSQL esté activo para ejecutar migraciones
echo "🐘 [2/6] Verificando estado de PostgreSQL..."
docker compose -f docker-compose.prod.yml up -d postgres

echo "⏳ Esperando que PostgreSQL esté listo..."
timeout 60 bash -c '
  until docker exec pathseek-postgres pg_isready -U "${DB_USER:-pathseek_prod}" -d "${DB_NAME:-pathseek_prod}" >/dev/null 2>&1; do
    sleep 2
  done
'
echo "✅ PostgreSQL operativo."

# 4. Aplicar migración aditiva de Sprint 3 de forma idempotente
echo "🔄 [3/6] Aplicando migración incremental de base de datos (Sprint 3)..."
if [ -f database/05_incremental_reoptimization.sql ]; then
  docker exec -i pathseek-postgres psql -U "${DB_USER:-pathseek_prod}" -d "${DB_NAME:-pathseek_prod}" < database/05_incremental_reoptimization.sql
  echo "✅ Migración database/05_incremental_reoptimization.sql aplicada con éxito."
else
  echo "⚠️ Advertencia: No se encontró database/05_incremental_reoptimization.sql. Saltando migración."
fi

# 5. Reconstruir imágenes y reiniciar servicios
echo "🏗️  [4/6] Reconstruyendo imágenes Docker (Backend + Frontend Web + APK) y levantando servicios..."
docker compose -f docker-compose.prod.yml up -d --build --remove-orphans

# 6. Esperar a que el backend esté healthy
echo "⏳ [5/6] Verificando salud del contenedor Backend..."
timeout 120 bash -c '
  until docker inspect --format="{{.State.Health.Status}}" pathseek-backend 2>/dev/null | grep -q "healthy"; do
    echo "  Backend aún inicializando... (esperando 5s)"
    sleep 5
  done
'
echo "✅ Contenedor Backend en estado healthy."

# 7. Validaciones de salud de la plataforma
echo "🩺 [6/6] Ejecutando pruebas de conectividad en producción..."
sleep 3

# Frontend en HTTPS (auto-firmado / Cloudflare)
FRONTEND_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/ || true)
echo "  Frontend HTTPS status: ${FRONTEND_STATUS}"
if [ "${FRONTEND_STATUS}" = "200" ]; then
  echo "  ✅ Frontend respondiendo con HTTP 200 OK."
else
  echo "  ⚠️ Frontend respondió con status ${FRONTEND_STATUS}."
fi

# Backend Health via Proxy Nginx
BACKEND_HEALTH=$(curl -k -s https://localhost/api/v1/health || true)
echo "  Backend Health API: ${BACKEND_HEALTH}"
if echo "${BACKEND_HEALTH}" | grep -q '"status":"UP"'; then
  echo "  ✅ Backend API operativo (UP)."
else
  echo "  ⚠️ Backend API no devolvió status UP. Revisa los logs con: docker logs pathseek-backend"
fi

# Limpieza de imágenes huérfanas
echo "🧹 Limpiando imágenes y capas residuales de Docker..."
docker image prune -f >/dev/null 2>&1 || true

echo "========================================================"
echo "  🎉 Despliegue de PathSeek completado exitosamente"
echo "  Web:      https://169.58.74.99/"
echo "  APK:      https://169.58.74.99/downloads/pathseek.apk"
echo "  Health:   https://169.58.74.99/api/v1/health"
echo "========================================================"
