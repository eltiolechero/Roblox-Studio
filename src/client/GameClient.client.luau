-- LocalScript en StarterPlayer > StarterPlayerScripts. Crea toda la pantalla.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remotes = ReplicatedStorage:WaitForChild("MultiplicationRemotes")
local stateEvent = remotes:WaitForChild("State")
local answerEvent = remotes:WaitForChild("Answer")
local feedbackEvent = remotes:WaitForChild("Feedback")
local readyEvent = remotes:WaitForChild("Ready")
local gui = Instance.new("ScreenGui")
gui.Name = "MultiplicationGui"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.94, 0.9)
panel.Position = UDim2.fromScale(0.03, 0.05)
panel.BackgroundColor3 = Color3.fromRGB(235, 244, 255)
panel.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(760, 760)
constraint.Parent = panel
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
local function text(name, y, height, size)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.fromScale(0.94, height)
    label.Position = UDim2.fromScale(0.03, y)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(20, 40, 70)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = panel
    local limit = Instance.new("UITextSizeConstraint")
    limit.MaxTextSize = size
    limit.Parent = label
    return label
end
text("Title", 0.01, 0.07, 32).Text = "CARRERA DE MULTIPLICACIONES"
local teamLabel = text("Team", 0.09, 0.05, 23)
local score = text("Score", 0.15, 0.06, 28)
local counter = text("Counter", 0.22, 0.05, 20)
local question = text("Question", 0.28, 0.1, 48)
local timer = text("Timer", 0.39, 0.05, 23)
local message = text("Message", 0.45, 0.09, 22)
local answerLabel = text("SelectedAnswer", 0.55, 0.07, 32)
local state, selected, pending = nil, "", false
local function enabled()
    return state and state.phase == "Question" and not state.attempted and not pending
        and workspace:GetServerTimeNow() < state.deadline
end
local function displayAnswer() answerLabel.Text = "Tu respuesta: " .. (selected == "" and "___" or selected) end
local function button(caption, x, y, width, action)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromScale(width, 0.095)
    b.Position = UDim2.fromScale(x, y)
    b.BackgroundColor3 = Color3.fromRGB(35, 96, 185)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Text = caption
    b.Parent = panel
    b.Activated:Connect(action)
    return b
end
for digit = 0, 9 do
    local value = tostring(digit)
    button(value, 0.04 + (digit % 5) * 0.185, 0.64 + math.floor(digit / 5) * 0.11, 0.17, function()
        if enabled() and #selected < 2 then
            selected = selected == "0" and value or selected .. value
            displayAnswer()
        end
    end)
end
button("Borrar", 0.04, 0.87, 0.43, function()
    if enabled() then selected = ""; displayAnswer() end
end)
local send = button("Enviar", 0.51, 0.87, 0.43, function()
    if enabled() and selected ~= "" then
        pending = true
        answerEvent:FireServer(state.roundId, tonumber(selected))
    end
end)
stateEvent.OnClientEvent:Connect(function(nextState)
    if not state or nextState.roundId ~= state.roundId then selected = "" end
    state, pending = nextState, false
    teamLabel.Text = "Tu equipo: " .. state.team .. (state.practice and " • PRÁCTICA" or "")
    score.Text = string.format("AZUL: %d     |     ROJO: %d", state.blue, state.red)
    counter.Text = string.format("Pregunta %d de %d", state.number, state.total)
    question.Text = state.a and string.format("%d × %d = ?", state.a, state.b) or "¡Jugamos en equipo!"
    message.Text = state.message
    if state.phase == "Question" and state.attempted then message.Text = "Ya respondiste. Espera la próxima pregunta." end
    displayAnswer()
end)
feedbackEvent.OnClientEvent:Connect(function(id, feedback)
    if state and state.roundId == id then pending = false; message.Text = feedback end
end)
RunService.Heartbeat:Connect(function()
    if not state then timer.Text = "Conectando…"; return end
    local remaining = math.max(0, math.ceil(state.deadline - workspace:GetServerTimeNow()))
    timer.Text = state.deadline > 0 and ("Tiempo: " .. remaining .. " s") or "Esperando equipos…"
    send.BackgroundColor3 = enabled() and Color3.fromRGB(20, 135, 75) or Color3.fromRGB(110, 120, 130)
end)
displayAnswer()
readyEvent:FireServer()
