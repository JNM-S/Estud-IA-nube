# Villa Nube · Laboratorio de la Clase 3

API de Trámites de la alcaldía ficticia **Villa Nube**: un ciudadano radica una solicitud de certificado de residencia y puede consultarla. En esta clase la API queda dentro de un contenedor y se enciende junto a su base de datos con Compose.

Todos los comandos se ejecutan **dentro de esta carpeta** (`clases/clase-03/villa-nube`).

## Encender solo la API

```bash
docker build -t villa-nube/tramites:1.0.0 .
docker run -d -p 8080:8080 --name vn villa-nube/tramites:1.0.0
```

Abre `http://localhost:8080/salud`: debes ver `{"estado":"ok","version":"dev"}`. Para apagarla: `docker rm -f vn`.

## Encender la API con su base de datos (Compose)

```bash
cp .env.ejemplo .env                  # configuración local (no se sube a Git)
docker compose up -d --build          # construye y enciende la API y PostgreSQL
./scripts/verificar.sh                # pruebas de aceptación
./scripts/verificar.sh --persistencia # además comprueba que los datos sobreviven
docker compose down                   # apaga todo (los datos se conservan)
```

Resultado esperado de las pruebas: `Resultado: 5 pasaron, 0 fallaron`.

## Qué hace la API

| Método y ruta | Para qué sirve | Respuesta esperada |
|---|---|---|
| `GET /salud` | El proceso está vivo. Informa la versión | `200 {"estado":"ok","version":"1.0.0"}` |
| `GET /listo` | La base de datos responde | `200`, o `503` si la base no está disponible |
| `POST /solicitudes` | Radicar: `{"ciudadano":"Ana","fecha_documento":"AAAA-MM-DD"}` | `201` con el id; `422` si el documento tiene más de 90 días |
| `GET /solicitudes/<id>` | Consultar una solicitud | `200` o `404` |
| `GET /solicitudes` | Total radicado, versión y motor de base de datos | `200` |

## Configuración

Toda la configuración llega por variables de entorno; nada depende del computador de quien construyó la imagen.

| Variable | Dónde se define | Valor de ejemplo |
|---|---|---|
| `APP_VERSION` | Al construir (`--build-arg`) | `1.0.0` |
| `DB_HOST`, `DB_PORT` | `compose.yaml` | `db`, `5432` |
| `DB_NAME`, `DB_USER`, `DB_PASSWORD` | `.env` (fuera de Git y de la imagen) | ver `.env.ejemplo` |
| `DIAS_VIGENCIA_DOCUMENTO` | `.env` o `-e` | `90` |
| `DATA_DIR` | Imagen; solo sin `DB_HOST` (modo SQLite) | `/data` |

## Qué hay en esta carpeta

```
app/                         código de la API (Flask + gunicorn)
Dockerfile                   imagen de la API, con comentarios línea por línea
compose.yaml                 API + PostgreSQL + volumen + red interna
.env.ejemplo                 plantilla de configuración
docs/Dockerfile.plantilla    Dockerfile con banco de palabras (ejercicio 4)
docs/plantillas/             Dockerfiles para tu proyecto (Python, Node.js, web estática) y plantilla de README
docs/ejemplos/               CMD vs ENTRYPOINT y ARG vs ENV, para probar en diez segundos
scripts/verificar.sh         pruebas de aceptación
scripts/ensayo-profesor.sh   ensayo completo del laboratorio
fallas/                      errores frecuentes preparados para practicar el diagnóstico (retos)
tests/                       pruebas unitarias (pytest, sin Docker)
```

## Si algo falla

| Lo que pasa | Qué revisar |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop no está abierto |
| `port is already allocated` | Otro contenedor usa el puerto: `docker ps` y `docker rm -f` con su nombre, o usa `-p 9090:8080` |
| `COPY failed` o `no such file` al construir | ¿Estás dentro de `clases/clase-03/villa-nube`? |
| `/listo` responde 503 | `docker compose logs api` y `docker compose ps`: ¿la base está `healthy`? |
| No responde en `localhost:8080` | `docker ps`: ¿aparece `0.0.0.0:8080->8080/tcp`? |
| `permission denied` en un script | `bash scripts/verificar.sh` |
| Cambié el código y no se ve | Reconstruye: `docker compose up -d --build` |
