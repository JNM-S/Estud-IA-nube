#!/usr/bin/env bash
# Ensayo completo del laboratorio de la Clase 3 (para el profesor, antes de la clase).
# Construye las imágenes, corre las pruebas de aceptación y reproduce las 4 fallas.
# Deja preparadas en caché las imágenes base, así en clase no se descarga nada grande.
#   ./scripts/ensayo-profesor.sh
# Duración aproximada: 3 a 6 minutos la primera vez (descarga de python:3.12-slim y postgres:16-alpine).
set -u
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.ejemplo .env

resumen=()
anotar() { resumen+=("$1"); echo; echo ">>> $1"; echo; }
esperar() { for _ in $(seq 1 40); do [ "$(curl -s -o /dev/null -w '%{http_code}' "$1")" = "$2" ] && return 0; sleep 1; done; return 1; }

echo "== 0. Descargar imágenes base"
for img in python:3.12-slim postgres:16-alpine alpine:3.20 nginx:1.27-alpine hello-world; do
  docker pull "$img" >/dev/null || { echo "No se pudo descargar $img"; exit 1; }
done
docker run --rm hello-world >/dev/null && anotar "OK  hello-world corre (primer comando de la clase)"

echo "== 1. Entorno bueno con Compose + pruebas de aceptación con persistencia"
docker compose up -d --build
if ./scripts/verificar.sh --persistencia; then anotar "OK  Entorno bueno: P1 a P5 pasan"; else anotar "ERROR  Entorno bueno: revisa docker compose logs"; fi
docker image ls villa-nube/tramites
docker compose ps

echo "== 2. Falla 01 · puerto en 127.0.0.1"
docker rm -f falla-puerto >/dev/null 2>&1
docker build -q -f fallas/01-puerto/Dockerfile -t villa-nube/tramites:falla-puerto . >/dev/null
docker run -d --name falla-puerto -p 8081:8080 villa-nube/tramites:falla-puerto >/dev/null
sleep 4
afuera=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://localhost:8081/salud)
adentro=$(docker exec falla-puerto python -c "import urllib.request;print(urllib.request.urlopen('http://127.0.0.1:8080/salud').status)" 2>/dev/null)
if [ "$afuera" != "200" ] && [ "$adentro" = "200" ]; then anotar "OK  Falla 01 se reproduce (afuera=$afuera, adentro=$adentro)"; else anotar "REVISAR  Falla 01 (afuera=$afuera, adentro=$adentro)"; fi
docker rm -f falla-puerto >/dev/null

echo "== 3. Falla 02 · datos sin volumen (SQLite)"
docker rm -f sin-volumen >/dev/null 2>&1
docker run -d --name sin-volumen -p 8083:8080 villa-nube/tramites:1.0.0 >/dev/null
esperar http://localhost:8083/listo 200
curl -s -X POST localhost:8083/solicitudes -H "Content-Type: application/json" \
  -d "{\"ciudadano\":\"Ana\",\"fecha_documento\":\"$(date +%F)\"}" >/dev/null
antes=$(curl -s localhost:8083/solicitudes | sed -n 's/.*"total":\([0-9]*\).*/\1/p')
docker rm -f sin-volumen >/dev/null
docker run -d --name sin-volumen -p 8083:8080 villa-nube/tramites:1.0.0 >/dev/null
esperar http://localhost:8083/listo 200
despues=$(curl -s localhost:8083/solicitudes | sed -n 's/.*"total":\([0-9]*\).*/\1/p')
docker rm -f sin-volumen >/dev/null
if [ "$antes" = "1" ] && [ "$despues" = "0" ]; then anotar "OK  Falla 02 se reproduce (antes=$antes, después=$despues)"; else anotar "REVISAR  Falla 02 (antes=$antes, después=$despues)"; fi

echo "== 4. Falla 03 · secreto dentro de la imagen"
docker build -q -f fallas/03-secreto/Dockerfile -t villa-nube/tramites:falla-secreto . >/dev/null
en_env=$(docker inspect villa-nube/tramites:falla-secreto --format '{{json .Config.Env}}' | grep -c DB_PASSWORD)
en_archivo=$(docker run --rm villa-nube/tramites:falla-secreto sh -c 'test -f /app/.env && echo 1 || echo 0')
buena=$(docker run --rm villa-nube/tramites:1.0.0 sh -c 'ls -a /app | grep -c "^.env$"')
if [ "$en_env" = "1" ] && [ "$en_archivo" = "1" ] && [ "$buena" = "0" ]; then anotar "OK  Falla 03 se reproduce y la imagen buena no trae .env"; else anotar "REVISAR  Falla 03 (env=$en_env archivo=$en_archivo buena=$buena)"; fi

echo "== 5. Falla 04 · DB_HOST=localhost"
F4="docker compose -f fallas/04-localhost/compose.yaml --project-directory ."
$F4 up -d --build >/dev/null 2>&1
sleep 8
codigo=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8082/listo)
$F4 down >/dev/null 2>&1
if [ "$codigo" = "503" ]; then anotar "OK  Falla 04 se reproduce (/listo=$codigo)"; else anotar "REVISAR  Falla 04 (/listo=$codigo)"; fi

echo "== 6. Ejemplos de CMD, ENTRYPOINT, ARG y ENV"
docker build -q -t ejemplo-cmd docs/ejemplos/cmd >/dev/null
docker build -q -t ejemplo-entrypoint docs/ejemplos/entrypoint >/dev/null
docker build -q -t ejemplo-arg-env --build-arg VERSION=2.0.0 docs/ejemplos/arg-env >/dev/null
c1=$(docker run --rm ejemplo-cmd echo Adiós)
c2=$(docker run --rm ejemplo-entrypoint Adiós)
c3=$(docker run --rm -e SALUDO=Buenas ejemplo-arg-env | tr '\n' ' ')
if [ "$c1" = "Adiós" ] && [ "$c2" = "Adiós" ] && [ "$c3" = "Buenas VERSION al correr: [] " ]; then anotar "OK  Ejemplos CMD/ENTRYPOINT/ARG/ENV"; else anotar "REVISAR  Ejemplos (cmd=$c1 entrypoint=$c2 arg-env=$c3)"; fi

echo "== 7. Plantilla del Dockerfile resuelta (la del banco de palabras)"
cat > /tmp/Dockerfile.resuelto <<'DOCKER'
FROM python:3.12-slim
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
DOCKER
docker rm -f plantilla >/dev/null 2>&1
docker build -q -f /tmp/Dockerfile.resuelto -t villa-nube/tramites:0.1.0 . >/dev/null
docker run -d --name plantilla -p 8084:8080 villa-nube/tramites:0.1.0 >/dev/null
if esperar http://localhost:8084/salud 200; then anotar "OK  La plantilla resuelta construye y responde"; else anotar "REVISAR  Plantilla resuelta"; fi
docker rm -f plantilla >/dev/null

echo "== 8. Tamaño y capas de la imagen buena"
docker image ls villa-nube/tramites
docker history villa-nube/tramites:1.0.0 | head -12

echo
echo "================ RESUMEN ================"
printf '%s\n' "${resumen[@]}"
echo "El entorno bueno queda arriba en http://localhost:8080 (docker compose down para bajarlo)."
