# FALLA 03 · «La clave viaja dentro de la imagen»
# Construir desde la raíz del repositorio, SIN .dockerignore efectivo:
#   docker build -f fallas/03-secreto/Dockerfile -t villa-nube/tramites:falla-secreto .
#   docker history --no-trunc villa-nube/tramites:falla-secreto | grep DB_PASSWORD
#   docker inspect villa-nube/tramites:falla-secreto --format '{{json .Config.Env}}'
#   docker run --rm villa-nube/tramites:falla-secreto ls -a /app      -> aparece .env, .git, tests...
# Pregunta: si esta imagen se publica en un registro, ¿quién puede leer la clave?
FROM python:3.12-slim
ENV DB_PASSWORD=clave-de-produccion-NO-HACER-ESTO
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r app/requirements.txt
CMD ["sh", "-c", "cd app && gunicorn --bind 0.0.0.0:8080 app:app"]
