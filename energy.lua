-- energy.lua
-- 管理能量系统

MAX_ENERGY = 15
roundCount = 1
phase = "white"

playerColors = {"White", "Green"}
playerEnergy = {
    White = 1,
    Green = 1
}

function end1Turn(_, color)
    if phase ~= "white" then
        printToColor("现在不是你的回合！", color, {1, 0.2, 0.2})
        return
    end

    phase = "green"
    local greenEnergy = math.min(roundCount, MAX_ENERGY)
    playerEnergy["Green"] = greenEnergy
    broadcastToAll("轮到绿方行动，本回合为第 " .. roundCount .. " 回合", {0.2, 1, 0.2})
    showAllEnergies()
end

function end2Turn(_, color)
    if phase ~= "green" then
        printToColor("现在不是你的回合！", color, {1, 0.2, 0.2})
        return
    end

    roundCount = roundCount + 1
    phase = "white"
    local whiteEnergy = math.min(roundCount, MAX_ENERGY)
    playerEnergy["White"] = whiteEnergy
    broadcastToAll("进入第 " .. roundCount .. " 回合，轮到白方行动", {1, 1, 1})
    showAllEnergies()
end

function showAllEnergies()
    local currentColor = (phase == "white") and "White" or "Green"
    local current = playerEnergy[currentColor] or 0
    local max = math.min(roundCount, MAX_ENERGY)
    broadcastToAll(currentColor .. " 当前能量：" .. current .. " / " .. max, stringColorToRGB(currentColor))
end

function consumeEnergy(playerColor, amount)
    local energy = playerEnergy[playerColor] or 0
    if energy < amount then
        printToColor("能量不足，当前为 " .. energy .. "，需要 " .. amount, playerColor, {1, 0.2, 0.2})
        return false
    else
        playerEnergy[playerColor] = energy - amount
        printToColor("已消耗 " .. amount .. " 能量，剩余：" .. playerEnergy[playerColor], playerColor, {0.2, 1, 0.2})
        return true
    end
end
