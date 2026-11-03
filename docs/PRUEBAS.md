# Pruebas en Roblox Studio

Realizar primero en un lugar privado. Esta lista queda pendiente de ejecución real en Studio.

| Prueba | Pasos | Resultado esperado |
| --- | --- | --- |
| Espera | PracticeSolo=false; abre Play con un jugador | No empieza la partida |
| Equipos | Server & Clients con 2 clientes | Uno Azul, otro Rojo; misma pregunta |
| Tarjetas | Forma un número, pulsa Borrar, vuelve a formarlo | Se borra y permite corregir antes del envío |
| Cero | Cuando un factor sea 0, envía 0 | Acierto válido |
| Acierto | Envía el producto correcto | Un punto; misma puntuación en ambos clientes |
| Simultaneidad | Envía la solución desde ambas ventanas casi al mismo tiempo | Solo un equipo gana un punto |
| Error | Envía un resultado incorrecto y vuelve a pulsar Enviar | No suma; no permite un segundo intento en esa ronda |
| Tiempo | No respondas durante 20 segundos | Muestra solución sin sumar puntos |
| Reinicio | Completa las 10 preguntas | Ganador o empate; próxima partida empieza con 0–0 |
| Entrada tardía | Añade un cliente durante una pregunta | Recibe pregunta, reloj y marcador actuales |
| Salida | Con solo 2 jugadores, cierra un cliente | Cancela partida y vuelve a esperar equipos |
| Más jugadores | Prueba con 4 clientes | Distribución 2–2; cada estudiante puede intentar una vez |
| Reaparición | Reinicia el avatar | Una sola interfaz; el intento previo sigue consumido |
| Pantallas | Prueba un teléfono y una ventana pequeña con el emulador | Tarjetas, mensajes y Enviar legibles y pulsables |

Revisa Salida tanto en el servidor como en los clientes. Usa teclado/ratón y toque donde esté disponible. Si aparece un error, guarda el texto y la línea indicada.

## Pruebas de reglas sin Roblox

Con Lua 5.4 instalado, desde la raíz del proyecto:

```sh
lua tests/Rules.spec.lua
```

Estas pruebas cubren la lógica pura. No sustituyen las pruebas del motor, red ni interfaz.
