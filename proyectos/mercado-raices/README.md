# Mercado Raíces · API de pedidos

**Tecnología:** Python 3.12 · Flask · gunicorn · pruebas con pytest · puerto **8080**

## El negocio

Mercado Raíces es una cooperativa de 40 familias campesinas del oriente antioqueño. Vende papa,
tomate, cebolla, aguacate y café a tiendas de barrio de Medellín. Hoy los pedidos llegan por
WhatsApp y se pierden entre mensajes; las familias no saben qué cosechar para el despacho del viernes.

Esta API recibe los pedidos y los valida antes de que lleguen a la cooperativa.

## Qué hace

| Ruta | Qué hace |
| --- | --- |
| `GET /salud` | Responde `{"estado":"ok"}` si el servicio está vivo |
| `GET /productos` | Lista los 5 productos con precio y existencias |
| `POST /pedidos` | Recibe un pedido: `{"cliente":"Tienda Don Luis","items":[{"producto":"cafe","cantidad":2}]}` |
| `GET /pedidos/<id>` | Consulta un pedido |

**Reglas del negocio**

- El pedido mínimo es de **20.000 pesos**: un pedido menor responde `422` con «Pedido mínimo». Se cambia con la variable `PEDIDO_MINIMO`.
- Un producto que no existe responde `404`; si no hay existencias suficientes, `409`.

## Arrancarlo

```bash
docker build -t mercado-raices:0.1.0 .
docker run -d -p 9000:8080 --name mercado mercado-raices:0.1.0
curl http://localhost:9000/productos
```

Sin Docker: `pip install -r requirements.txt pytest` y luego `pytest -v` para las pruebas.

## Dos pruebas para empezar

1. Si abro `/productos`, debo ver «Papa criolla».
2. Si pido una sola cebolla, debo ver «Pedido mínimo».

```bash
curl -s -X POST http://localhost:9000/pedidos -H "Content-Type: application/json" \
  -d '{"cliente":"Tienda","items":[{"producto":"cebolla","cantidad":1}]}'
```

## Integración continua en tu fork (Clase 4)

Usa `clases/clase-04/villa-nube/ci/plantillas/ci-python.yml` y guárdalo como
`.github/workflows/mercado-raices.yml`. Cambia:

| CAMBIA | Valor |
| --- | --- |
| `working-directory` | `"proyectos/mercado-raices"` |
| `PUERTO_APP` | `"8080"` |
| Prueba 1 | `curl -s http://localhost:9000/productos` y el texto `Papa criolla` |

**Un rojo para provocar:** en `app/app.py` cambia `"20000"` por `"2000"`. ¿Qué prueba falla?

## Lo que le falta (para las próximas clases)

- Los pedidos viven en memoria: se pierden al reiniciar. Necesita una base de datos.
- No hay forma de saber si el servicio está caído en la madrugada del viernes.
- No está publicado: las tiendas no lo pueden usar todavía.

Caso ficticio con fines educativos.
