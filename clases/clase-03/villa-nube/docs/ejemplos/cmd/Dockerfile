# Ejemplo CMD: es el comando POR DEFECTO. Si escribes algo después del nombre de la imagen, lo REEMPLAZA.
#   docker build -t ejemplo-cmd docs/ejemplos/cmd
#   docker run --rm ejemplo-cmd                  -> Hola desde CMD
#   docker run --rm ejemplo-cmd echo Adiós       -> Adiós
FROM alpine:3.20
CMD ["echo", "Hola desde CMD"]
