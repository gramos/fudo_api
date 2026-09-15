# fudo_api
[![CI](https://github.com/gramos/fudo_api/actions/workflows/ci.yml/badge.svg)](https://github.com/gramos/fudo_api/actions/workflows/ci.yml) ![Ruby](https://img.shields.io/badge/Ruby-3.4.10-lightgrey?logo=ruby)

## Cómo ejecutar la aplicación

Se requiere Ruby 3.4.10 y Bundler.

```sh
bundle install
AUTH_USERNAME=admin AUTH_PASSWORD=secret bundle exec rackup
```

El servidor queda disponible en `http://localhost:9292`. En otra terminal, obtené y guardá el token en la variable `TOKEN`:

```sh
export TOKEN="$(curl --fail --silent --show-error \
  -X POST http://localhost:9292/auth \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"secret"}' \
  | ruby -rjson -e 'puts JSON.parse(STDIN.read).fetch("token")')"
```

Usá esa variable para crear o listar productos:

```sh
curl -X POST http://localhost:9292/products \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Pizza"}'
```

El producto creado estará disponible en el listado después de cinco segundos. Para listar los productos:

```sh
curl http://localhost:9292/products -H "Authorization: Bearer $TOKEN"
```

La especificación OpenAPI está en `/openapi.yaml` y el archivo de autores en `/AUTHORS`.

### Ejecutar con Docker

```sh
docker build -t fudo-api .
docker run --rm -p 9292:9292 \
  -e AUTH_USERNAME=admin \
  -e AUTH_PASSWORD=secret \
  fudo-api
```

### Ejecutar los tests

```sh
ruby test/run.rb
```

Por defecto se omite el test que espera cinco segundos. Para ejecutarlo solo:

```sh
ruby test/run.rb --slow
```

Para ejecutar toda la suite, incluido el test lento (como en el CI):

```sh
ruby test/run.rb --all
```

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
