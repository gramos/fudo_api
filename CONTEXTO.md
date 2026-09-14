# Contexto del challenge de Fudo

Este archivo conserva el contexto y las decisiones del proyecto. La referencia inicial fue la carpeta `prototype`, pero el proyecto entregable se reconstruirá paso a paso dentro de `fudo_api`.

## Forma de trabajo

- Resolver el challenge con Ruby y Rack, sin Rails.
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
- Todavía no hay código ni tests en `fudo_api`.
- Todavía faltan `fudo.md`, `tcp.md`, `http.md`, `openapi.yaml` y `AUTHORS`.
- Todavía faltan las instrucciones para levantar el proyecto en `README.md`.
- El código existente en `prototype` se conservará como referencia, no como implementación final.

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
