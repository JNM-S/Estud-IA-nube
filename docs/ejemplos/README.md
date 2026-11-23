# Ejemplos cortos · CMD, ENTRYPOINT, ARG y ENV

Tres imágenes diminutas (basadas en `alpine`) para ver con tus ojos cómo se comportan estas instrucciones. Ejecuta los comandos desde la raíz del repositorio.

## CMD: el comando por defecto, que se puede reemplazar

```bash
docker build -t ejemplo-cmd docs/ejemplos/cmd
docker run --rm ejemplo-cmd                 # Hola desde CMD
docker run --rm ejemplo-cmd echo Adiós      # Adiós  (lo que escribiste REEMPLAZÓ al CMD)
```

## ENTRYPOINT: el programa fijo, al que se le agregan argumentos

```bash
docker build -t ejemplo-entrypoint docs/ejemplos/entrypoint
docker run --rm ejemplo-entrypoint          # Hola desde ENTRYPOINT
docker run --rm ejemplo-entrypoint Adiós    # Adiós  (se AGREGÓ al echo)
```

Regla corta: **CMD = lo que corre si no dices nada. ENTRYPOINT = lo que corre siempre.**

## ARG y ENV

```bash
docker build -t ejemplo-arg-env --build-arg VERSION=2.0.0 docs/ejemplos/arg-env
docker run --rm ejemplo-arg-env                     # Hola  y  VERSION al correr: []
docker run --rm -e SALUDO=Buenas ejemplo-arg-env    # Buenas
docker history ejemplo-arg-env                      # el valor del ARG queda escrito en el historial
```

Regla corta: **ARG vive solo mientras se construye. ENV vive también cuando corre.** Ninguno de los dos sirve para claves: ambos quedan guardados dentro de la imagen.

En Villa Nube se usan juntos: `ARG APP_VERSION` recibe la versión al construir y `ENV APP_VERSION=${APP_VERSION}` la deja disponible para que la API la muestre en `/salud`.
