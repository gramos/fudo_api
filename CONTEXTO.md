# Contexto del challenge de Fudo

Este archivo conserva el contexto y las decisiones del proyecto. La referencia inicial fue la carpeta `prototype`, pero el proyecto entregable se reconstruirá paso a paso dentro de `fudo_api`.

## Forma de trabajo

- Resolver el challenge con Ruby y Rack, sin Rails.
- Usar Ruby `3.4.10` como versión objetivo.
- Trabajar con TDD usando Minitest de la biblioteca estándar de Ruby.
- Avanzar en ciclos pequeños: test mínimo, implementación mínima y refactor solo si hace falta.
- Mantener métodos cortos y responsabilidades separadas.
- Preferir estructuras simples y evitar abstracciones prematuras.
- Explicar las decisiones importantes antes de implementarlas.
- Ejecutar tests y chequeos de sintaxis después de cada incremento.

## Decisiones técnicas iniciales

1. La aplicación será una aplicación Rack que exponga una API JSON.
2. La autenticación usará un token opaco enviado como `Authorization: Bearer <token>`.
3. Las credenciales serán una única pareja configurada mediante variables de entorno.
4. Los tokens se guardarán en memoria y vencerán después de una hora.
5. No se usará JWT, base de datos, registro de usuarios, logout ni renovación de tokens porque la consigna no lo requiere.
6. Los productos se guardarán en memoria.
7. Los productos tendrán únicamente `id` y `name`.
8. La creación de productos será asíncrona: responderá `202 Accepted` y el producto estará disponible después de cinco segundos.
9. La solución inicial para la tarea asíncrona será un `Thread` por solicitud de creación.
10. Se evaluará el uso de un middleware para proteger `/products` y sus subrutas, manteniendo `/auth` y los archivos estáticos públicos.
11. Se usará `Rack::Deflater` para comprimir la respuesta cuando el cliente lo solicite.
12. `openapi.yaml` se servirá desde la raíz con `Cache-Control: no-store`.
13. `AUTHORS` se servirá desde la raíz con `Cache-Control: public, max-age=86400`.

## Arquitectura prevista

La aplicación tendrá una aplicación Rack principal y una cadena pequeña de middlewares:

```text
Servidor Rack
    ↓
Rack::Deflater
    ↓
Rack::Static
    ↓
AuthMiddleware
    ↓
App
```

`Rack::Deflater` se ocupará de comprimir las respuestas cuando el cliente anuncie que acepta gzip. `Rack::Static` servirá públicamente `AUTHORS` y `openapi.yaml`. `AuthMiddleware` validará el token Bearer únicamente para `/products` y sus subrutas. `App` resolverá las rutas y manejará las respuestas HTTP.

### Responsabilidades

- `app.rb`: aplicación Rack principal, routing, login, creación y consulta de productos, lectura de JSON y respuestas JSON.
- `auth.rb`: validación de credenciales, generación de tokens y validación de sesiones.
- `auth_middleware.rb`: extracción del token Bearer y protección de las rutas de productos.
- `config.ru`: composición de la aplicación y configuración de los middlewares.
- `test/`: tests unitarios y de integración con Minitest.
- `public/`: archivos estáticos `AUTHORS` y `openapi.yaml`.

El middleware de compresión será el provisto por Rack; no se implementará un middleware gzip propio. La autenticación será pública en `POST /auth`, mientras que la creación y consulta de productos requerirán autenticación.

### Flujo de endpoints

```text
POST /auth
→ Rack::Deflater
→ Rack::Static
→ AuthMiddleware deja pasar la ruta pública
→ App procesa el login mediante Auth

POST /products
→ Rack::Deflater
→ Rack::Static
→ AuthMiddleware valida el token
→ App valida el producto y programa su creación

GET /products
→ Rack::Deflater
→ Rack::Static
→ AuthMiddleware valida el token
→ App devuelve los productos disponibles
```

## Decisiones que deben revisarse

- La implementación final del middleware de autenticación.
- La necesidad de sincronización explícita para los hashes compartidos entre threads.
- El formato exacto de la respuesta `202` y la eventual necesidad de un endpoint de seguimiento.
- La estrategia para probar el paso de cinco segundos sin hacer lentos innecesariamente los tests.
- El nombre y apellido que se publicarán en `AUTHORS`.
- Si se agregará soporte opcional para Docker.

## Estado actual

- `README.md` contiene la consigna del challenge.
- `AGENTS.md` contiene las reglas permanentes de trabajo.
- `test/test_helper.rb` configura Minitest.
- `test/auth_test.rb` verifica credenciales válidas, identificación mediante token y rechazo de credenciales o tokens inválidos.
- `auth.rb` contiene la implementación mínima inicial de `Auth`, incluyendo almacenamiento, validación y expiración de tokens después de una hora.
- Los seis tests de `Auth` están en verde usando Ruby `3.4.10`.
- `test/app_test.rb` verifica `POST /auth` con credenciales válidas e inválidas y que una ruta inexistente responda `404` en JSON.
- `app.rb` contiene el routing inicial, el login y la respuesta `404`.
- Los tres tests de `App` y los seis tests de `Auth` están en verde.
- Todavía faltan `fudo.md`, `tcp.md`, `http.md`, `openapi.yaml` y `AUTHORS`.
- Todavía faltan las instrucciones para levantar el proyecto en `README.md`.
- El código existente en `prototype` se conservará como referencia, no como implementación final.

## Checklist de la consigna

- [ ] API JSON implementada con Rack y sin Rails.
- [ ] Endpoint `POST /auth` que reciba usuario y contraseña.
- [ ] Endpoint `POST /products` protegido y asíncrono.
- [ ] Respuesta inmediata `202 Accepted` para la creación.
- [ ] Producto disponible después de cinco segundos.
- [ ] Endpoint `GET /products` protegido.
- [ ] Respuestas comprimidas con gzip cuando el cliente lo solicite.
- [ ] `openapi.yaml` expuesto en la raíz y con `Cache-Control: no-store`.
- [ ] `AUTHORS` expuesto en la raíz y cacheado durante 24 horas.
- [ ] Productos con atributos `id` y `name`.
- [ ] `fudo.md` de hasta 100 palabras y 2 o 3 párrafos.
- [ ] `tcp.md` de hasta 50 palabras.
- [ ] `http.md` de hasta 50 palabras.
- [ ] Instrucciones para levantar el proyecto en `README.md`.
- [ ] Tests automatizados con Minitest.
- [ ] Docker, solo si se decide agregarlo; es opcional.
- [ ] Revisión final y publicación en un repositorio git.

## Orden previsto de implementación

1. Preparar la estructura mínima y la configuración de tests.
2. Implementar `Auth` con tests.
3. Implementar la aplicación Rack básica y el routing con tests.
4. Implementar el login.
5. Implementar la protección de productos.
6. Implementar la creación asíncrona.
7. Implementar la consulta de productos.
8. Agregar compresión y archivos estáticos.
9. Completar OpenAPI, documentación e instrucciones de ejecución.
10. Ejecutar una revisión final contra la consigna.
