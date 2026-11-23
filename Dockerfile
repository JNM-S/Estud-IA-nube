# Villa Nube · API de Trámites
# Imagen base pequeña y con versión fija: la misma entrada produce la misma imagen.
FROM python:3.12-slim

# Metadatos: quién la mantiene y de dónde sale (se ven con docker inspect).
LABEL org.opencontainers.image.title="villa-nube-tramites" \
      org.opencontainers.image.source="repositorio del curso EstudIA · Nube Intermedio"

# Comportamiento de Python dentro de contenedores: sin .pyc y logs sin búfer.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    DATA_DIR=/data

WORKDIR /app

# 1) Primero solo las dependencias: esta capa se reutiliza mientras
#    requirements.txt no cambie, aunque cambie el código.
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2) Después el código. Un cambio aquí no vuelve a instalar dependencias.
COPY app/ .

# Usuario sin privilegios y carpeta de datos que puede montarse como volumen.
RUN useradd --create-home --uid 10001 tramites \
    && mkdir -p /data && chown tramites:tramites /data
USER tramites

# La versión se fija al construir: docker build --build-arg APP_VERSION=1.0.0
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

# Documenta el puerto; no lo publica. Publicar es decisión de quien ejecuta (-p).
EXPOSE 8080

# Docker marca el contenedor como healthy/unhealthy con esta comprobación.
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:%s/salud' % os.getenv('PORT', '8080'), timeout=2)" || exit 1

# 0.0.0.0: escuchar en todas las interfaces del contenedor, no solo en su loopback.
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} --workers 2 --access-logfile - app:app"]
