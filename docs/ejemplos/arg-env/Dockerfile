# Ejemplo ARG y ENV
# ARG existe SOLO mientras se construye la imagen. ENV existe también cuando el contenedor corre.
#   docker build -t ejemplo-arg-env --build-arg VERSION=2.0.0 docs/ejemplos/arg-env
#        (durante el build se ve: Construyendo la versión 2.0.0)
#   docker run --rm ejemplo-arg-env                   -> Hola   /   VERSION al correr: []
#   docker run --rm -e SALUDO=Buenas ejemplo-arg-env  -> Buenas /   VERSION al correr: []
#   docker history ejemplo-arg-env                    -> el valor del ARG aparece en el historial
FROM alpine:3.20
ARG VERSION=1.0.0
ENV SALUDO="Hola"
RUN echo "Construyendo la versión $VERSION"
CMD ["sh", "-c", "echo $SALUDO; echo VERSION al correr: [$VERSION]"]
