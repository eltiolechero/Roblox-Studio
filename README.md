# Carrera de multiplicaciones · Roblox Studio

Prototipo educativo para primaria inspirado en dos equipos que forman resultados con tarjetas del 0 al 9. Todo el contenido de juego está en español.

## Cómo se juega

- Los jugadores se reparten automáticamente entre Azul y Rojo al entrar, procurando igualar cantidades.
- Se necesita al menos un jugador en cada equipo. Tras 5 segundos comienza la partida.
- Ambos equipos ven la misma multiplicación, con factores del 0 al 9.
- Pulsa las tarjetas para formar el resultado (por ejemplo, 6 × 7: pulsa 4 y después 2). Puedes repetir un dígito, como 8 × 8 = 64 o 1 × 0 = 0. Borrar permite empezar de nuevo antes de enviar.
- Cada estudiante tiene **un intento por pregunta**. El primer acierto recibido por el servidor da **1 punto** a su equipo y cierra la pregunta. No se restan puntos por fallar.
- Hay 20 segundos por pregunta. Se muestra la solución durante 3 segundos, incluso si nadie acierta.
- Después de 10 preguntas se anuncia el equipo ganador o el empate. Tras 8 segundos se reinician los puntos y empieza otra partida.
- Si queda un equipo vacío, se cancela la partida y se espera de nuevo. Los jugadores nuevos reciben el estado actual y pueden participar en la pregunta abierta.

La rapidez se mide por el orden de llegada al servidor: la conexión puede influir. Las tarjetas son botones individuales, no objetos sostenidos por avatares. Es una primera adaptación digital de la dinámica del aula.

## Inicio rápido: sin copiar scripts

1. En GitHub, abre `Multiplicaciones.rbxlx`, pulsa **Raw / Download raw file** y guarda el archivo. También puedes usar **Code > Download ZIP** y descomprimirlo.
2. Abre Roblox Studio e inicia sesión.
3. Usa **File > Open from File** y selecciona `Multiplicaciones.rbxlx`.
4. Prueba con **Server & Clients**, seleccionando **2 clientes**, y pulsa Play (F7). Verás un servidor y dos ventanas de jugador.
5. Responde desde las ventanas de jugador. El marcador debe ser idéntico en ambas.
6. Finaliza con **End Session**. Guarda el lugar con **File > Save to File** si lo modificas.

No necesitas instalar plugins, Rojo, activar HTTP ni habilitar acceso a API Services. Abrir un `.luau` por sí solo no crea un lugar de Roblox: usa el `.rbxlx` o el procedimiento manual siguiente.

## Instalación manual en una Baseplate

Abre una plantilla **Baseplate**. Muestra **Explorer / Explorador**, **Properties / Propiedades** y **Output / Salida** desde las herramientas de Studio; los nombres pueden variar según el idioma o versión.

Crea exactamente estos tres objetos con el botón **+** del Explorador. Abre cada archivo de `src` en un editor de texto, copia todo su contenido, borra el código de ejemplo del objeto y pega el contenido correspondiente:

| Archivo en GitHub | Dónde colocarlo en Studio | Tipo de objeto | Nombre exacto |
| --- | --- | --- | --- |
| `src/server/Rules.luau` | `ServerScriptService` | **ModuleScript** | `Rules` |
| `src/server/GameServer.server.luau` | `ServerScriptService` | **Script** | `GameServer` |
| `src/client/GameClient.client.luau` | `StarterPlayer > StarterPlayerScripts` | **LocalScript** | `GameClient` |

No pegues los tres archivos dentro de un solo Script. `Rules` debe estar junto a `GameServer`, no dentro de él. No hace falta crear Teams, ScreenGui ni RemoteEvents: aparecen automáticamente al jugar. Usa un lugar nuevo para evitar equipos o remotos anteriores con los mismos nombres.

Guarda el lugar, inicia la prueba de dos clientes descrita arriba y revisa que Salida no muestre errores rojos.

## Probar con un solo jugador

En `ServerScriptService > Rules`, cambia `PracticeSolo = false` por `PracticeSolo = true`. Usa **Test / Play**, no **Run** (Run no crea un jugador). La pantalla mostrará PRÁCTICA. Al terminar, detén la sesión y devuelve el valor a `false` para exigir los dos equipos.

## Cambiar dificultad

Edita `Rules.Config` **con la prueba detenida**:

| Opción | Valor inicial | Para qué sirve |
| --- | --- | --- |
| `MinFactor` | `0` | Menor factor |
| `MaxFactor` | `9` | Mayor factor |
| `RoundSeconds` | `20` | Segundos para responder |
| `RoundsPerMatch` | `10` | Preguntas por partida |
| `CountdownSeconds` | `5` | Preparación inicial |
| `RevealSeconds` | `3` | Tiempo para leer la solución |
| `ResultsSeconds` | `8` | Tiempo del resultado final |
| `PracticeSolo` | `false` | Permitir prueba con un jugador |

Ejemplo para empezar: factores de 1 a 5 y 30 segundos. Usa factores enteros entre 0 y 9: la interfaz admite como máximo dos cifras. Los tiempos y la cantidad de preguntas deben ser enteros positivos. El punto por acierto está fijado en `GameServer`.

## Organización del proyecto

- `src/server/Rules.luau`: configuración, preguntas y validación de intentos.
- `src/server/GameServer.server.luau`: equipos, rondas, reloj y puntos.
- `src/client/GameClient.client.luau`: pantalla, tarjetas y envío de respuestas.
- `Multiplicaciones.rbxlx`: lugar listo para abrir, con copias de esos tres scripts y una base sencilla.
- `docs/PRUEBAS.md`: comprobaciones para Studio.
- `tests/Rules.spec.lua`: pruebas automáticas de las reglas, sin motor Roblox.
- `tools/build_place.py`: reconstruye el `.rbxlx` desde `src` con Python 3.

Los cambios hechos en Studio no actualizan GitHub automáticamente. Copia las versiones finales de los scripts a `src`, ejecuta `python tools/build_place.py` y sube los archivos modificados juntos. Guarda escenas futuras como `.rbxlx`; un ZIP descargado desde GitHub tampoco sincroniza cambios automáticamente.

Para organizar mejoras, crea tareas en Issues con un objetivo pequeño, por ejemplo «añadir sonido al acertar». Usa ramas y Pull Requests para revisar cambios antes de integrarlos.

## Qué hace el servidor

El cliente solo envía el identificador de pregunta y el número elegido. El servidor verifica equipo, plazo, tipo y rango de respuesta, intento previo y pregunta vigente; limita la frecuencia de solicitudes y decide el punto. La solución no se envía durante la pregunta. Dos aciertos casi simultáneos no pueden sumar dos puntos en la misma ronda.

No hay guardado permanente: al cerrar el servidor se pierden los puntos. Tampoco hay selección manual de equipo, escenario elaborado ni publicación automática en Roblox. El prototipo funciona sobre una base sencilla con una interfaz en pantalla.

## Si algo no funciona

- **Se queda esperando:** necesitas dos clientes, uno por equipo, o activar `PracticeSolo`.
- **No aparece la pantalla:** confirma que `GameClient` sea LocalScript en StarterPlayerScripts y que uses Play, no Run.
- **Mensaje de espera por Rules:** revisa tipo ModuleScript, mayúsculas y ubicación junto a GameServer.
- **Dos pantallas o equipos duplicados:** deja una sola copia de cada script y vuelve a iniciar la prueba desde un lugar limpio.
- **No puedo volver a enviar:** hay un intento por estudiante y por pregunta; espera la siguiente.
- **Los cambios desaparecen al detener:** no edites scripts durante Play; detén la sesión antes de modificar.

## Verificación y fuentes

Se ejecutaron pruebas locales de reglas y comprobaciones de sintaxis Lua compatible y estructura del lugar. Roblox Studio no está disponible en el entorno de creación: la interfaz, replicación y pruebas multijugador deben comprobarse con la lista de `docs/PRUEBAS.md` antes de publicar.

Documentación oficial consultada:
- [Pruebas de Studio](https://create.roblox.com/docs/studio/testing-modes)
- [RemoteEvents y comunicación](https://create.roblox.com/docs/scripting/events/remote)
- [Validación del servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)
