-- Script en ServerScriptService. El servidor decide preguntas, tiempo y puntos.
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(script.Parent:WaitForChild("Rules"))
local C = Rules.Config
local rng = Random.new()

local folder = Instance.new("Folder")
folder.Name = "MultiplicationRemotes"
local function remote(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = folder
    return event
end
local stateEvent = remote("State")
local answerEvent = remote("Answer")
local feedbackEvent = remote("Feedback")
local readyEvent = remote("Ready")
local teamList = {}
for _, info in ipairs({{"Azul", "Bright blue"}, {"Rojo", "Bright red"}}) do
    local team = Instance.new("Team")
    team.Name = info[1]
    team.TeamColor = BrickColor.new(info[2])
    team.AutoAssignable = false
    team.Parent = Teams
    teamList[#teamList + 1] = team
end
local scores = {Azul = 0, Rojo = 0}
local phase, message, number, roundId = "Waiting", "Esperando un jugador en cada equipo…", 0, 0
local round, phaseDeadline = nil, 0
local lastAnswer, lastReady = {}, {}
local function clock() return workspace:GetServerTimeNow() end
local function snapshot(player)
    return {
        phase = phase, message = message, number = number, total = C.RoundsPerMatch,
        roundId = roundId, a = round and round.a, b = round and round.b,
        deadline = phaseDeadline, blue = scores.Azul, red = scores.Rojo,
        team = player.Team and player.Team.Name or "Sin equipo",
        attempted = round ~= nil and round.attempts[player.UserId] == true,
        practice = C.PracticeSolo,
    }
end
local function broadcast()
    for _, player in ipairs(Players:GetPlayers()) do
        stateEvent:FireClient(player, snapshot(player))
    end
end
local function enoughPlayers()
    if C.PracticeSolo then return #Players:GetPlayers() >= 1 end
    return #teamList[1]:GetPlayers() >= 1 and #teamList[2]:GetPlayers() >= 1
end
local function addPlayer(player)
    player.Team = #teamList[1]:GetPlayers() <= #teamList[2]:GetPlayers() and teamList[1] or teamList[2]
    player.Neutral = false
end
Players.PlayerAdded:Connect(addPlayer)
for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
    lastAnswer[player], lastReady[player] = nil, nil
end)
-- El cliente se suscribe antes de pedir el estado: funciona si entra a mitad de partida.
readyEvent.OnServerEvent:Connect(function(player)
    local now = clock()
    if now - (lastReady[player] or -math.huge) < 1 then return end
    lastReady[player] = now
    stateEvent:FireClient(player, snapshot(player))
end)
answerEvent.OnServerEvent:Connect(function(player, submittedId, answer)
    local now = clock()
    if now - (lastAnswer[player] or -math.huge) < 0.25 then return end
    lastAnswer[player] = now
    if phase ~= "Question" or not round or submittedId ~= roundId then return end
    if not enoughPlayers() then return end
    local team = player.Team
    if team ~= teamList[1] and team ~= teamList[2] then return end
    local won, feedback = Rules.submit(round, player.UserId, team.Name, answer, now)
    if won then
        scores[team.Name] = scores[team.Name] + 1
        phase = "Reveal"
        phaseDeadline = now + C.RevealSeconds
        message = string.format("¡Equipo %s gana un punto! %d × %d = %d", team.Name, round.a, round.b, round.answer)
    end
    broadcast()
    feedbackEvent:FireClient(player, roundId, feedback)
end)
-- Publicar remotos solo después de conectar sus receptores.
folder.Parent = ReplicatedStorage

local function enter(newPhase, text, seconds)
    phase, message = newPhase, text
    phaseDeadline = seconds and (clock() + seconds) or 0
    broadcast()
end
local function pause(seconds, requireTeams)
    local finish = clock() + seconds
    repeat
        if requireTeams and not enoughPlayers() then return false end
        task.wait(0.1)
    until clock() >= finish
    return not requireTeams or enoughPlayers()
end
local function startQuestion()
    local a, b, answer = Rules.makeQuestion(function(low, high) return rng:NextInteger(low, high) end)
    roundId = roundId + 1
    phaseDeadline = clock() + C.RoundSeconds
    round = {a = a, b = b, answer = answer, deadline = phaseDeadline, open = true, attempts = {}}
    phase, message = "Question", "Forma tu respuesta con las tarjetas y pulsa Enviar."
    broadcast()
end
while true do
    round, number = nil, 0
    scores.Azul, scores.Rojo = 0, 0
    enter("Waiting", "Esperando un jugador en cada equipo…")
    repeat task.wait(0.25) until enoughPlayers()
    enter("Countdown", "¡Prepárense! La partida va a comenzar.", C.CountdownSeconds)
    local completed = pause(C.CountdownSeconds, true)
    if completed then
        for index = 1, C.RoundsPerMatch do
            number = index
            startQuestion()
            while phase == "Question" and enoughPlayers() and clock() < round.deadline do task.wait(0.05) end
            if not enoughPlayers() then completed = false; break end
            if phase == "Question" then
                round.open = false
                enter("Reveal", string.format("Tiempo terminado. %d × %d = %d", round.a, round.b, round.answer), C.RevealSeconds)
            end
            -- El plazo también puede haberse fijado en el receptor de un acierto.
            if not pause(math.max(0, phaseDeadline - clock()), true) then completed = false; break end
        end
    end
    if completed then
        local result = "¡Empate!"
        if scores.Azul > scores.Rojo then result = "¡Ganó el equipo Azul!" end
        if scores.Rojo > scores.Azul then result = "¡Ganó el equipo Rojo!" end
        enter("Results", result .. " La siguiente partida comenzará pronto.", C.ResultsSeconds)
        pause(C.ResultsSeconds, false)
    else
        if round then round.open = false end
        enter("Waiting", "Falta un equipo. Se reiniciará la partida.", 3)
        pause(3, false)
    end
end
