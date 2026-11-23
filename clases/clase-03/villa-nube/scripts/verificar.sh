#!/usr/bin/env bash
# Villa Nube · pruebas de aceptación de la Clase 3
# Uso:
#   ./scripts/verificar.sh                 # P1 a P4 contra http://localhost:8080
#   ./scripts/verificar.sh --persistencia  # además P5: baja y sube el entorno y busca la solicitud
#   URL=http://localhost:9090 ./scripts/verificar.sh
# Requiere: bash y curl (en Windows: Git Bash o WSL; o usa Codespaces).

URL="${URL:-http://localhost:8080}"
PERSISTENCIA="no"
[ "${1:-}" = "--persistencia" ] && PERSISTENCIA="si"

pasaron=0; fallaron=0
ok()    { echo "  ✔ $1"; pasaron=$((pasaron+1)); }
falla() { echo "  ✘ $1"; fallaron=$((fallaron+1)); }

# código HTTP y cuerpo de una petición
pedir() { curl -s -o /tmp/vn_cuerpo -w "%{http_code}" "$@"; }
cuerpo() { cat /tmp/vn_cuerpo; }

echo "Verificando $URL"

# Esperar hasta 30 s a que el servicio esté listo (la BD puede tardar en arrancar)
for _ in $(seq 1 30); do
  [ "$(pedir "$URL/listo")" = "200" ] && break
  sleep 1
done

echo "P1 · El servicio está vivo e informa su versión"
codigo=$(pedir "$URL/salud")
if [ "$codigo" = "200" ] && grep -q '"version"' /tmp/vn_cuerpo; then ok "/salud → 200 $(cuerpo)"; else falla "/salud → $codigo $(cuerpo)"; fi

echo "P2 · El servicio está listo: su base de datos responde"
codigo=$(pedir "$URL/listo")
if [ "$codigo" = "200" ]; then ok "/listo → 200 $(cuerpo)"; else falla "/listo → $codigo $(cuerpo)"; fi

echo "P3 · Un ciudadano radica una solicitud y puede consultarla"
hoy=$(date +%F)
codigo=$(pedir -X POST "$URL/solicitudes" -H "Content-Type: application/json" \
  -d "{\"ciudadano\":\"Ciudadana de prueba\",\"tipo\":\"certificado_residencia\",\"fecha_documento\":\"$hoy\"}")
id=$(sed -n 's/.*"id":"\([^"]*\)".*/\1/p' /tmp/vn_cuerpo)
if [ "$codigo" = "201" ] && [ -n "$id" ]; then
  ok "POST /solicitudes → 201 (id $id)"
  codigo=$(pedir "$URL/solicitudes/$id")
  if [ "$codigo" = "200" ]; then ok "GET /solicitudes/$id → 200"; else falla "GET /solicitudes/$id → $codigo"; fi
else
  falla "POST /solicitudes → $codigo $(cuerpo)"
fi

echo "P4 · La regla del negocio se cumple: un documento vencido se rechaza"
codigo=$(pedir -X POST "$URL/solicitudes" -H "Content-Type: application/json" \
  -d '{"ciudadano":"Ciudadano de prueba","fecha_documento":"2020-01-01"}')
if [ "$codigo" = "422" ]; then ok "documento vencido → 422"; else falla "documento vencido → $codigo (se esperaba 422)"; fi

if [ "$PERSISTENCIA" = "si" ] && [ -n "${id:-}" ]; then
  echo "P5 · La solicitud sobrevive a reemplazar los contenedores"
  docker compose down >/dev/null 2>&1      # sin -v: el volumen se conserva
  docker compose up -d >/dev/null 2>&1
  for _ in $(seq 1 30); do [ "$(pedir "$URL/listo")" = "200" ] && break; sleep 1; done
  codigo=$(pedir "$URL/solicitudes/$id")
  if [ "$codigo" = "200" ]; then ok "después de down/up la solicitud $id sigue ahí"; else falla "después de down/up → $codigo (¿se perdió el volumen?)"; fi
fi

echo
echo "Resultado: $pasaron pasaron, $fallaron fallaron"
[ "$fallaron" -eq 0 ]
