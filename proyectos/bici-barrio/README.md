# BiciBarrio · API de préstamo de bicicletas

**Tecnología:** Node.js 22 · Express · pruebas con `node --test` · puerto **3000**

## El negocio

La junta de acción comunal de un barrio de Medellín tiene 6 bicicletas en tres estaciones:
el parque, la biblioteca y la cancha. Los vecinos las piden prestadas para ir a la estación del
metro. Hoy el registro se lleva en un cuaderno, y nadie sabe en qué estación quedan bicicletas.

Esta API registra los préstamos y las devoluciones.

## Qué hace

| Ruta | Qué hace |
| --- | --- |
| `GET /salud` | Responde `{"estado":"ok"}` si el servicio está vivo |
| `GET /estaciones` | Lista las estaciones y cuántas bicicletas hay en cada una |
| `POST /prestamos` | Presta una bicicleta: `{"usuario":"ana","estacion":"parque"}` |
| `POST /prestamos/<id>/devolucion` | Devuelve la bicicleta |

**Reglas del negocio**

- Una persona solo puede tener **un préstamo activo**: el segundo responde `409`.
- Una estación sin bicicletas responde `409` con «No hay bicicletas». La cancha empieza vacía.
- La duración máxima se configura con la variable `MAX_MINUTOS` (por defecto 120).

## Arrancarlo

```bash
docker build -t bici-barrio:0.1.0 .
docker run -d -p 9000:3000 --name bici bici-barrio:0.1.0
curl http://localhost:9000/estaciones
```

Sin Docker: `npm install` y luego `npm test` para las pruebas, o `npm start` para encenderla.

## Dos pruebas para empezar

1. Si abro `/estaciones`, debo ver «Biblioteca».
2. Si pido una bicicleta en la cancha, debo ver «No hay bicicletas».

```bash
curl -s -X POST http://localhost:9000/prestamos -H "Content-Type: application/json" \
  -d '{"usuario":"luis","estacion":"cancha"}'
```

## Integración continua en tu fork (Clase 4)

Usa `clases/clase-04/villa-nube/ci/plantillas/ci-node.yml` y guárdalo como
`.github/workflows/bici-barrio.yml`. Cambia:

| CAMBIA | Valor |
| --- | --- |
| `working-directory` | `"proyectos/bici-barrio"` |
| `PUERTO_APP` | `"3000"` |
| Prueba 1 | `curl -s http://localhost:9000/estaciones` y el texto `Biblioteca` |

**Un rojo para provocar:** en `src/app.js` cambia `bicis: 0` de la cancha por `bicis: 1`. ¿Qué prueba falla?

## Lo que le falta (para las próximas clases)

- Los préstamos viven en memoria: se pierden al reiniciar.
- Nadie se entera si una bicicleta lleva más de `MAX_MINUTOS` prestada.
- No está publicado: los vecinos no lo pueden usar desde el celular.

Caso ficticio con fines educativos.
