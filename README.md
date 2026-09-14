# fudo_api
[![CI](https://github.com/gramos/fudo_api/actions/workflows/ci.yml/badge.svg)](https://github.com/gramos/fudo_api/actions/workflows/ci.yml) ![Ruby](https://img.shields.io/badge/Ruby-3.4.10-red?logo=ruby)
# Technical Challenge - Backend Developer Sr.

1. Explicar en un archivo llamado fudo.md qué es lo que es Fudo, en sólo 2 o 3 párrafos, en no más de 100 palabras.
2. Explicar brevemente en un archivo llamado tcp.md qué es TCP, en español, en no más de 50 palabras.
3. Explicar brevemente en un archivo llamado http.md qué es HTTP, en español, en no más de 50 palabras.
4. Implementar una aplicación rack en Ruby, sin usar Rails, que exponga una API en json.

La API debe exponer:
====================

- Endpoint de autenticación, que reciba usuario y contraseña.
- Endpoint para creación de productos. Este endpoint debe ser asíncrono, es decir que la respuesta a esta llamada no debe indicar que el producto ya fue creado, sino que se creará de forma asíncrona. El producto creado debe estar disponible luego de 5 segundos.
- Endpoint para consulta de productos.
- Además de estos endpoints, se puede tener cualquier otro endpoint adicional que facilite el comportamiento asíncrono de la creación de productos.

Tener en cuenta:
================
- Los endpoints relacionados a la creación y consulta de productos deben validar que se haya autenticado antes.
- La respuesta de la api debe ser comprimida con gzip (siempre que el cliente lo solicite).
- La API debe estar especificada en un archivo llamado openapi.yaml que siga la especificación de OpenAPI. Este archivo debe ser expuesto como un archivo estático en la raíz y nunca debe ser cacheado por los clientes.
- Se debe exponer también en la raíz un archivo llamado AUTHORS, que indique tu nombre y apellido. Este archivo también debe ser estático y la respuesta debe indicar que se cachee por 24 hs.
- No hace falta tener acceso a una base de datos. La persistencia de los productos puede ser en memoria.
- Los atributos de los productos es suficiente que sean sólo id y nombre.
- Opcionalmente, poder levantar el proyecto en Docker.
- Agregar en el README la forma de levantar el proyecto.
- El proyecto debe estar hosteado en GitHub/GitLab o cualquier repo git, incluyendo los archivos .md de los 3 primeros puntos.
- Para cualquier cosa no indicada en los puntos anteriores, hay libertad en la decisión.
