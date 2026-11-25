# Proyectos de práctica

¿Todavía no tienes un proyecto propio? Elige uno de estos y úsalo en las clases como si fuera tuyo.
Son pequeños, se entienden en 10 minutos y cada uno tiene un **problema de negocio**, una
**regla que se puede romper** y **pruebas** que la cuidan. Todos son casos ficticios.

| Proyecto | Tecnología | El negocio | Plantilla de CI |
| --- | --- | --- | --- |
| [Mercado Raíces](mercado-raices/README.md) | Python · Flask | Una cooperativa campesina recibe pedidos de tiendas de barrio | `ci-python.yml` |
| [BiciBarrio](bici-barrio/README.md) | Node.js · Express | Una junta de acción comunal presta bicicletas en tres estaciones | `ci-node.yml` |
| [Biblioteca La Esquina](biblioteca-barrio/README.md) | HTML, CSS y JavaScript (sitio estático) | Una biblioteca comunitaria publica su catálogo | `ci-docker.yml` |
| [Villa Nube](../clases/clase-04/villa-nube/README.md) | Python · Flask + PostgreSQL | La alcaldía recibe solicitudes de certificados (el caso de las clases) | ya trae su workflow |

## Cómo elegir

- **Elige por el lenguaje que quieres practicar,** no por el que parece más fácil: los tres tienen el mismo tamaño.
- **Si nunca has programado en ninguno,** Biblioteca La Esquina no tiene código de servidor: solo archivos que sirve nginx.
- **Si ya tienes un proyecto propio,** úsalo. Estos proyectos son para no quedarte sin práctica.

## Cómo usarlo

1. Haz **fork** del repositorio del curso (si no lo hiciste en la Clase 4).
2. En tu fork, entra a la carpeta del proyecto y lee su README.
3. Trabaja en esa carpeta como si fuera la raíz de tu proyecto. Cuando una plantilla diga
   «la carpeta donde está tu Dockerfile», escribe la ruta del proyecto, por ejemplo `proyectos/mercado-raices`.
4. Escribe en tu README o en tu evidencia: «Uso el proyecto de práctica Mercado Raíces del curso».
   Usar un proyecto del curso es válido; lo que se evalúa es lo que haces con él.

Cada proyecto se arranca igual:

```bash
cd proyectos/mercado-raices      # o bici-barrio, o biblioteca-barrio
docker build -t mi-proyecto:0.1.0 .
docker run -d -p 9000:8080 --name mi-proyecto mi-proyecto:0.1.0   # el puerto de adentro cambia según el proyecto
```

> Material de apoyo generado con asistencia de IA y revisado por el profesor del curso.
