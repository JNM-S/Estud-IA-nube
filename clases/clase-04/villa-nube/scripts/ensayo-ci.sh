#!/usr/bin/env bash
# Ensayo local de la Clase 4: hace en tu equipo lo mismo que hace el workflow.
# Úsalo para comprobar el laboratorio antes de clase, o cuando no puedas usar GitHub.
# Requiere: Python 3.12 y Docker. Ejecútalo desde la carpeta villa-nube.
set -u
cd "$(dirname "$0")/.."
resumen=()
paso() { echo; echo "=== $1 ==="; }
anota() { if [ "$2" -eq 0 ]; then resumen+=("OK    $1"); else resumen+=("FALLA $1"); fi; }

paso "Job 1 · Pruebas del código"
python3 -m venv .venv-ensayo >/dev/null 2>&1 && . .venv-ensayo/bin/activate
pip install -q -r app/requirements.txt -r requirements-dev.txt
pytest -v; anota "pruebas del código" $?
deactivate 2>/dev/null; rm -rf .venv-ensayo .pytest_cache

paso "Job 2 · Imagen y prueba de humo"
docker rm -f vn-ensayo >/dev/null 2>&1
docker build --build-arg APP_VERSION=ensayo -t villa-nube/tramites:ensayo .; anota "construir la imagen" $?
docker run -d -p 8080:8080 --name vn-ensayo villa-nube/tramites:ensayo >/dev/null; anota "encender el contenedor" $?
bash scripts/verificar.sh; r=$?; anota "prueba de humo" $r
[ $r -ne 0 ] && docker logs vn-ensayo
docker rm -f vn-ensayo >/dev/null 2>&1

echo; echo "=== Resumen ==="; printf '%s\n' "${resumen[@]}"
