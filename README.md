# Estud-IA · Arquitectura en la nube · Nivel intermedio

Repositorio de trabajo del curso **Capa 2 · Arquitectura en la nube, nivel intermedio** del programa Estud-IA. Aquí están el laboratorio de práctica, las guías de cada clase y las plantillas para tu proyecto.

**No necesitas experiencia previa con Docker.** Las clases van paso a paso: primero lo hace el profesor, luego lo haces con él y después en tu proyecto.

## Clases

| Clase | Semana | Tema | Material |
|---|---|---|---|
| 1 | 1 | Comunidad, pacto y repaso del nivel básico | En clase |
| 2 | 1 | Del negocio a la infraestructura: DDD, draft de arquitectura y atributos de calidad | En clase |
| 3 | 2 | Del draft al contenedor: Docker paso a paso | [Guía del estudiante](clases/clase-03/README.md) |
| 4 | 2 | Integración continua con GitHub Actions | Próximamente |
| 5–6 | 3 | Despliegue, reversión e infraestructura como código | Próximamente |
| 7–8 | 4 | Redes, exposición del servicio y observabilidad | Próximamente |
| 9–10 | 5 | Auditoría, portafolio y defensa | Próximamente |

## El laboratorio: Villa Nube

Villa Nube es una alcaldía ficticia. Su **API de Trámites** permite que un ciudadano radique una solicitud de certificado de residencia y la consulte. Es el caso que modelamos en la Clase 2. No tiene datos reales.

Cada clase le agrega una capa al laboratorio, y el resultado de cada una queda marcado con una etiqueta de Git:

| Etiqueta | Qué contiene |
|---|---|
| `clase-3-inicio` | La aplicación sin contenedor, con plantillas y ejemplos |
| `clase-3` | Dockerfile, Compose con PostgreSQL, pruebas de aceptación y fallas para practicar |

Si te atrasas, puedes arrancar desde la etiqueta de la clase: `git checkout clase-3`.

### ¿Primera vez con Docker?

1. Instala [Docker Desktop](https://www.docker.com/products/docker-desktop/) y ábrelo.
2. En una terminal (en Windows, Git Bash) escribe `docker run hello-world`. Debe aparecer «Hello from Docker!».
3. ¿No puedes instalar Docker? En esta página de GitHub: botón **Code** → **Codespaces** → **Create codespace on main**. Se abre un editor en el navegador que ya trae Docker.

### Encender Villa Nube (solo la API)

```bash
git clone https://github.com/dlemusg/Estud-IA-Nube-Int.git villa-nube
cd villa-nube
docker build -t villa-nube/tramites:1.0.0 .
docker run -d -p 8080:8080 --name vn villa-nube/tramites:1.0.0
```

Abre `http://localhost:8080/salud`. Debes ver `{"estado":"ok","version":"dev"}`. Para apagarla: `docker rm -f vn`.

### Encender Villa Nube con su base de datos (Compose)

```bash
cp .env.ejemplo .env                  # configuración local (no se sube a Git)
docker compose up -d --build          # construye y enciende la API y PostgreSQL
./scripts/verificar.sh                # pruebas de aceptación
./scripts/verificar.sh --persistencia # además comprueba que los datos sobreviven
docker compose down                   # apaga todo (los datos se conservan)
```

Resultado esperado de las pruebas: `Resultado: 5 pasaron, 0 fallaron`.

### Qué hace la API

| Método y ruta | Para qué sirve | Respuesta esperada |
|---|---|---|
| `GET /salud` | El proceso está vivo. Informa la versión | `200 {"estado":"ok","version":"1.0.0"}` |
| `GET /listo` | La base de datos responde | `200`, o `503` si la base no está disponible |
| `POST /solicitudes` | Radicar: `{"ciudadano":"Ana","fecha_documento":"AAAA-MM-DD"}` | `201` con el id; `422` si el documento tiene más de 90 días |
| `GET /solicitudes/<id>` | Consultar una solicitud | `200` o `404` |
| `GET /solicitudes` | Total radicado, versión y motor de base de datos | `200` |

### Configuración

Toda la configuración llega por variables de entorno; nada depende del computador de quien construyó la imagen.

| Variable | Dónde se define | Valor de ejemplo |
|---|---|---|
| `APP_VERSION` | Al construir (`--build-arg`) | `1.0.0` |
| `DB_HOST`, `DB_PORT` | `compose.yaml` | `db`, `5432` |
| `DB_NAME`, `DB_USER`, `DB_PASSWORD` | `.env` (fuera de Git y de la imagen) | ver `.env.ejemplo` |
| `DIAS_VIGENCIA_DOCUMENTO` | `.env` o `-e` | `90` |
| `DATA_DIR` | Imagen; solo sin `DB_HOST` (modo SQLite) | `/data` |

## Estructura del repositorio

```
clases/                      guías del estudiante, una carpeta por clase
app/                         código de la API (Flask + gunicorn)
Dockerfile                   imagen de la API, con comentarios línea por línea
compose.yaml                 API + PostgreSQL + volumen + red interna
.env.ejemplo                 plantilla de configuración
docs/Dockerfile.plantilla    Dockerfile con banco de palabras (práctica de la Clase 3)
docs/plantillas/             Dockerfiles para tu proyecto (Python, Node.js, web estática) y plantilla de README
docs/ejemplos/               CMD vs ENTRYPOINT y ARG vs ENV, para probar en diez segundos
scripts/verificar.sh         pruebas de aceptación
scripts/ensayo-profesor.sh   ensayo completo del laboratorio
fallas/                      errores frecuentes preparados para practicar el diagnóstico (retos)
tests/                       pruebas unitarias (pytest, sin Docker)
.devcontainer/               entorno para GitHub Codespaces
```

## Si algo falla

| Lo que pasa | Qué revisar |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop no está abierto |
| `port is already allocated` | Otro contenedor usa el puerto: `docker ps` y `docker rm -f` con su nombre, o usa `-p 9090:8080` |
| `/listo` responde 503 | `docker compose logs api` y `docker compose ps`: ¿la base está `healthy`? |
| No responde en `localhost:8080` | `docker ps`: ¿aparece `0.0.0.0:8080->8080/tcp`? |
| `permission denied` en un script | `bash scripts/verificar.sh` |
| Cambié el código y no se ve | Reconstruye: `docker compose up -d --build` |

> Material de apoyo generado con asistencia de IA y revisado por el profesor del curso.
