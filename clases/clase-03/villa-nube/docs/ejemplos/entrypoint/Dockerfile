# Ejemplo ENTRYPOINT: es el programa FIJO. Lo que escribes después del nombre de la imagen se le AGREGA.
# CMD, junto a un ENTRYPOINT, solo da los argumentos por defecto.
#   docker build -t ejemplo-entrypoint docs/ejemplos/entrypoint
#   docker run --rm ejemplo-entrypoint           -> Hola desde ENTRYPOINT
#   docker run --rm ejemplo-entrypoint Adiós     -> Adiós
FROM alpine:3.20
ENTRYPOINT ["echo"]
CMD ["Hola desde ENTRYPOINT"]
