# [Nombre del proyecto]

[Una frase: qué necesidad del negocio atiende este componente.]

## Qué necesitas
- Docker Desktop (o Docker Engine)

## Cómo arrancarlo
1. `git clone [url] && cd [carpeta]`
2. `docker build -t [nombre]:0.1.0 .`
3. `docker run -d -p [puerto]:[puerto] --name [nombre] [nombre]:0.1.0`
4. Abre `http://localhost:[puerto]/[ruta]`

Lo que debes ver: [qué aparece exactamente].

## Mis dos pruebas
1. Si hago [acción], debo ver [resultado].
2. Si hago [acción], debo ver [resultado].

## Cómo apagarlo
`docker rm -f [nombre]`

## Lo que falta o lo que simulé
- [Qué no está todavía en el contenedor, o qué es de ejemplo]
