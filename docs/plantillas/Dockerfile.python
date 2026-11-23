# Plantilla · aplicación Python (Flask, FastAPI o un script con servidor web)
# Cópiala a la raíz de TU proyecto con el nombre Dockerfile y cambia lo que dice CAMBIA.
FROM python:3.12-slim

WORKDIR /app

# Si tu proyecto no tiene requirements.txt, créalo con: pip freeze > requirements.txt
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# CAMBIA: el puerto en el que escucha tu aplicación
EXPOSE 8080

# CAMBIA: el comando que arranca tu aplicación.
# Importante: tu app debe escuchar en 0.0.0.0, no en 127.0.0.1 ni en localhost.
#   Flask:    app.run(host="0.0.0.0", port=8080)
#   FastAPI:  CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
CMD ["python", "app.py"]
