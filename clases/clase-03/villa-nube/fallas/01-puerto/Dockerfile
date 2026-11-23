# FALLA 01 · «Responde adentro pero no afuera»
# Construir desde la raíz del repositorio:
#   docker build -f fallas/01-puerto/Dockerfile -t villa-nube/tramites:falla-puerto .
#   docker run -d --name falla-puerto -p 8081:8080 villa-nube/tramites:falla-puerto
#   curl http://localhost:8081/salud                       -> falla (conexión reiniciada o vacía)
#   docker exec falla-puerto python -c "import urllib.request;print(urllib.request.urlopen('http://127.0.0.1:8080/salud').read())"  -> responde
# Pista: ¿en qué interfaz escucha el proceso dentro del contenedor?
FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 DATA_DIR=/data
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
RUN useradd --create-home --uid 10001 tramites && mkdir -p /data && chown tramites:tramites /data
USER tramites
EXPOSE 8080
CMD ["gunicorn", "--bind", "127.0.0.1:8080", "app:app"]
