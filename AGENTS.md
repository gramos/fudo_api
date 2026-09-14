# Instrucciones de trabajo

## Objetivo

Resolver el challenge de Fudo con una aplicación Ruby + Rack, sin Rails, manteniendo una implementación pequeña y fácil de entender.

## Forma de trabajo

- Trabajar con ciclos cortos de TDD: test mínimo, implementación mínima y refactor solo cuando sea necesario.
- Usar Minitest, disponible en la biblioteca estándar de Ruby.
- Avanzar una funcionalidad por vez y ejecutar los tests después de cada cambio.
- No implementar funcionalidades que la consigna no requiera.
- Explicar las decisiones importantes antes de aplicarlas.
- No modificar archivos sin autorización explícita cuando el usuario haya pedido primero analizar o planificar.

## Estilo de implementación

- Preferir la solución más simple que funcione.
- Mantener métodos cortos, con una sola responsabilidad.
- Separar responsabilidades sin crear abstracciones prematuras.
- Usar nombres claros y estructuras directas.
- Evitar dependencias innecesarias.
- Conservar las decisiones registradas en `CONTEXTO.md` y actualizarlas cuando cambien.

## Alcance técnico acordado inicialmente

- API JSON implementada como aplicación Rack.
- Autenticación mediante token Bearer opaco, almacenado en memoria.
- Productos almacenados en memoria.
- Creación de productos asíncrona, con disponibilidad posterior a cinco segundos.
- Compresión negociada mediante Rack cuando el cliente la solicite.
- `AUTHORS` y `openapi.yaml` servidos como archivos estáticos con sus políticas de caché correspondientes.

Estas decisiones pueden revisarse antes de implementarlas si los tests o un análisis posterior muestran una alternativa más simple y adecuada.
