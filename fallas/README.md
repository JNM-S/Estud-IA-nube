# Fallas preparadas · Clase 3

Cada falla reproduce un error frecuente al contenedorizar. Se usan en la práctica guiada y en las clínicas. **Primero se observa el síntoma, luego se formula una hipótesis y solo después se cambia una cosa.**

| # | Síntoma | Qué la causa | Cómo se corrige |
|---|---|---|---|
| 01 | `curl localhost:8081/salud` no responde, pero desde dentro del contenedor sí | gunicorn escucha en `127.0.0.1`, el loopback **del contenedor** | Escuchar en `0.0.0.0` |
| 02 | Las solicitudes desaparecen al recrear el contenedor | Los datos se escriben en la capa del contenedor, que se borra con él | Montar un volumen en la carpeta de datos |
| 03 | La clave de la base de datos se puede leer desde la imagen | `ENV` con el secreto y `COPY . .` sin `.dockerignore` | Configuración por `env_file` en ejecución y `.dockerignore` |
| 04 | `/listo` responde 503 para siempre | `DB_HOST=localhost`: dentro del contenedor `localhost` es el propio contenedor | Usar el nombre del servicio (`db`) como host |

## Falla 02 · «Los datos se pierden»

No necesita archivos propios: usa la imagen buena en modo SQLite (sin `DB_HOST`).

```bash
docker build -t villa-nube/tramites:1.0.0 --build-arg APP_VERSION=1.0.0 .

# Sin volumen
docker run -d --name sin-volumen -p 8083:8080 villa-nube/tramites:1.0.0
curl -X POST localhost:8083/solicitudes -H "Content-Type: application/json" \
  -d "{\"ciudadano\":\"Ana\",\"fecha_documento\":\"$(date +%F)\"}"
curl localhost:8083/solicitudes                 # total: 1
docker rm -f sin-volumen
docker run -d --name sin-volumen -p 8083:8080 villa-nube/tramites:1.0.0
curl localhost:8083/solicitudes                 # total: 0  ← se perdió
docker rm -f sin-volumen

# Con volumen
docker run -d --name con-volumen -p 8083:8080 -v datos-sqlite:/data villa-nube/tramites:1.0.0
# ...repite el POST, borra y vuelve a crear el contenedor con el mismo -v: total sigue en 1
docker rm -f con-volumen && docker volume rm datos-sqlite
```

## Limpieza general

```bash
docker rm -f falla-puerto sin-volumen con-volumen 2>/dev/null
docker compose -f fallas/04-localhost/compose.yaml --project-directory . down
```
