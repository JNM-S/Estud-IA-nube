# Villa Nube · laboratorio de la Clase 4 · Integración continua

La misma API de Trámites de la Clase 3, ahora con un **workflow de GitHub Actions**
que la prueba sola cada vez que alguien la cambia.

El workflow está en la raíz del repositorio:
[`.github/workflows/clase-04-villa-nube.yml`](../../../.github/workflows/clase-04-villa-nube.yml).
Tiene dos jobs:

| Job | Qué hace | Cuándo corre |
| --- | --- | --- |
| Pruebas del código | Instala Python y las librerías, y corre `pytest -v` | En cada cambio dentro de esta carpeta |
| Imagen y prueba de humo | Construye la imagen, la enciende y corre `scripts/verificar.sh` (las pruebas de la Clase 3) | Solo si el job anterior terminó en verde |

## Empezar en 5 minutos (todo en el navegador)

1. Entra a <https://github.com/dlemusg/Estud-IA-Nube-Int> y pulsa **Fork** → **Create fork**.
2. En tu fork, abre la pestaña **Actions** y pulsa
   **I understand my workflows, go ahead and enable them**.
3. En la lista de la izquierda elige **Clase 4 · Villa Nube CI** → **Run workflow** → **Run workflow**.
4. Espera el círculo verde ✅. Haz clic en la ejecución, luego en un job, y abre el paso **Correr las pruebas**.

## Qué hay en esta carpeta

| Ruta | Para qué |
| --- | --- |
| `app/`, `tests/`, `Dockerfile`, `compose.yaml` | Villa Nube, igual que en la Clase 3 |
| `requirements-dev.txt` | Librerías que solo se usan para probar (pytest) |
| `scripts/verificar.sh` | Pruebas de aceptación de la Clase 3; el CI las corre contra el contenedor |
| `scripts/ensayo-ci.sh` | Hace en tu equipo lo mismo que el workflow (necesita Python y Docker) |
| `ci/plantilla-ci.yml` | Ejercicio 4: workflow con espacios en blanco y banco de palabras |
| `ci/plantillas/` | Plantillas de CI para tu proyecto: `ci-docker.yml`, `ci-python.yml`, `ci-node.yml` |
| `ci/logs/` | Ejecuciones guardadas (verde, rojas y una «verde engañosa») para leer sin GitHub |
| `fallas-ci/` | Cambios pequeños para provocar un rojo y aprender a leer el log |

## Correr las pruebas en tu equipo (opcional)

```bash
pip install -r app/requirements.txt -r requirements-dev.txt
pytest -v
```

Caso ficticio con fines educativos: no uses datos personales reales ni claves de tu trabajo.
