local Rules = dofile("src/server/Rules.luau")
local function fresh()
    return {open = true, deadline = 20, answer = 42, attempts = {}}
end
for a = 0, 9 do
    for b = 0, 9 do
        local sequence = {a, b}
        local i = 0
        local x, y, result = Rules.makeQuestion(function(low, high)
            i = i + 1
            assert(sequence[i] >= low and sequence[i] <= high)
            return sequence[i]
        end)
        assert(x == a and y == b and result == a * b)
    end
end
local r = fresh()
assert(Rules.submit(r, 1, "Azul", 42, 1))
assert(not Rules.submit(r, 2, "Rojo", 42, 1)) -- un solo ganador
r = fresh()
assert(not Rules.submit(r, 1, "Azul", 41, 1))
assert(not Rules.submit(r, 1, "Azul", 42, 2)) -- no repetir intento
assert(Rules.submit(r, 2, "Rojo", 42, 2)) -- otro jugador sí puede
for _, value in ipairs({"42", {}, -1, 82, 1.5, math.huge, -math.huge, 0/0}) do
    r = fresh()
    assert(not Rules.submit(r, 1, "Azul", value, 1))
    assert(not r.attempts[1]) -- entrada inválida no consume intento
end
assert(not Rules.validAnswer(nil))
r = fresh()
assert(not Rules.submit(r, 1, "Verde", 42, 1))
assert(not Rules.submit(r, 1, "Azul", 42, 20)) -- límite exacto
assert(not Rules.submit(r, 1, "Azul", 42, 21))
r = fresh(); r.answer = 0
assert(Rules.submit(r, 1, "Azul", 0, 1))
r = fresh(); r.answer = 81
assert(Rules.submit(r, 1, "Rojo", 81, 1))
print("OK: 100 productos, un solo ganador, intentos, equipos, plazo, cero y entradas inválidas")
