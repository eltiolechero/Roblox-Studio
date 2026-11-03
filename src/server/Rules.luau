-- ModuleScript: reglas sin interfaz ni servicios; fáciles de probar.
local Rules = {}
Rules.Config = {
    MinFactor = 0, MaxFactor = 9,
    RoundSeconds = 20, RoundsPerMatch = 10,
    CountdownSeconds = 5, RevealSeconds = 3, ResultsSeconds = 8,
    PracticeSolo = false, -- true permite probar con un solo jugador.
}

function Rules.makeQuestion(randomInteger)
    local a = randomInteger(Rules.Config.MinFactor, Rules.Config.MaxFactor)
    local b = randomInteger(Rules.Config.MinFactor, Rules.Config.MaxFactor)
    return a, b, a * b
end

function Rules.validAnswer(value)
    return type(value) == "number" and value == value
        and value >= 0 and value <= Rules.Config.MaxFactor ^ 2
        and value % 1 == 0
end

-- No cede ejecución: solo el primer acierto puede cerrar la ronda.
function Rules.submit(round, userId, teamName, answer, now)
    if not round.open or now >= round.deadline then return false, "La ronda terminó." end
    if teamName ~= "Azul" and teamName ~= "Rojo" then return false, "No tienes equipo." end
    if not Rules.validAnswer(answer) then return false, "Respuesta inválida." end
    if round.attempts[userId] then return false, "Ya respondiste en esta ronda." end
    round.attempts[userId] = true
    if answer ~= round.answer then return false, "Esta vez no. Espera la próxima pregunta." end
    round.open = false
    return true, "¡Correcto! Un punto para tu equipo."
end
return Rules
