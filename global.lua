local cardsData = {
  {
    name = "Hermes",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/01%E8%B5%AB%E5%B0%94%E5%A2%A8%E6%96%AF.png?raw=true",
    placement_cost = 1,
    action_cost = 0,
    damage = 1,
    hp = 2,
    skill_text = "God - Melee"
  },
  {
    name = "Aphrodite",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/02%E9%98%BF%E5%BC%97%E6%B4%9B%E7%8B%84%E5%BF%92.png?raw=true",
    placement_cost = 2,
    action_cost = 1,
    damage = 1,
    hp = 3,
    skill_text = "God - Ranged\\n Romantic Curse: The attacked unit takes 1 unit less damage"
  },
  {
    name = "Ares",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/03%E9%98%BF%E7%91%9E%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 1,
    damage = 3,
    hp = 5,
    skill_text = "God - Melee"
  },
  {
    name = "Artemis",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/04%E9%98%BF%E5%B0%94%E5%BF%92%E5%BC%A5%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 2,
    damage = 3,
    hp = 3,
    skill_text = "God - Ranged\\n Agility: When placed, deals 2 damage to each of two random enemy units."
  }
}


playerColors = {"White", "Green"}

local player1Deck = {}
local player2Deck = {}

for _, card in ipairs(cardsData) do
  table.insert(player1Deck, card)
  table.insert(player1Deck, card)
  table.insert(player2Deck, card)
  table.insert(player2Deck, card)
end

function dealAll()
  shuffle(player1Deck)
  shuffle(player2Deck)
  dealToPlayer(player1Deck, playerColors[1])
  dealToPlayer(player2Deck, playerColors[2])
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

function dealToPlayer(deck, color)
  local handPos = Player[color].getHandTransform().position
  for i = 1, 5 do
    local xOffset = (i - 3) * 2  
    local pos = {handPos.x + xOffset, handPos.y + 2, handPos.z}
    spawnCard(deck[i], pos)
  end
end

function wrapAndCenter(text, maxLineLength)
    local lines = {}
    local currentLine = ""
    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= maxLineLength then
            currentLine = currentLine .. (currentLine == "" and "" or " ") .. word
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end
    table.insert(lines, currentLine)

    for i, line in ipairs(lines) do
        local padding = math.floor((maxLineLength - #line) / 2) - 6
        lines[i] = string.rep(" ", padding) .. line
    end

    return table.concat(lines, "\n")
end

function spawnCard(data, position)
    local customCard = {
        Name = "Card",
        Transform = {
            posX = position[1], posY = position[2], posZ = position[3],
            rotX = 0, rotY = 180, rotZ = 0,
            scaleX = 1, scaleY = 1, scaleZ = 1
        },
        Nickname = data.name,
        Description = data.skill_text,
        CardID = 100,
        CustomDeck = {
            ["1"] = {
                FaceURL = data.image_url,
                BackURL = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E7%A5%9E.png?raw=true",
                NumWidth = 1,
                NumHeight = 1,
                BackIsHidden = true
            }
        },
        LuaScript = generateCardScript(data),
        LuaScriptState = ""
    }

    spawnObjectJSON({json = JSON.encode(customCard)})
end

function generateCardScript(data)
    local formattedSkillText = wrapAndCenter(data.skill_text, 32)

    local script = [[
        local stats = {
            placement_cost = ]] .. data.placement_cost .. [[,
            action_cost = ]] .. data.action_cost .. [[,
            damage = ]] .. data.damage .. [[,
            hp = ]] .. data.hp .. [[
        }

        function onLoad()
            self.createButton({
                label = "Cost: " .. stats.placement_cost .. "  Action: " .. stats.action_cost ..
                        "\nDamage: " .. stats.damage .. "  HP: " .. stats.hp,
                click_function = "noop", function_owner = self,
                position = {0, 0.3, -1.2}, height = 0, width = 0, font_size = 90
            })

            self.createButton({
                label = "]] .. formattedSkillText:gsub("\n", "\\n") .. [[",
                click_function = "noop", function_owner = self,
                position = {0, 0.3, 1.0}, height = 0, width = 0, font_size = 70
            })
        end

        function noop() end
    ]]
    return script
end


MAX_ENERGY = 15
roundCount = 1

playerEnergy = {
    White = 1,
    Green = 1
}
phase = "white"

function onLoad()
    broadcastToAll("游戏开始！白方先手。当前回合：" .. roundCount, {1,1,1})
    showAllEnergies()
end

function end1Turn(_, color)
    if phase ~= "white" then
        printToColor("现在不是你的回合！", color, {1, 0.2, 0.2})
        return
    end

    phase = "green"
    local greenEnergy = math.min(roundCount, MAX_ENERGY)
    playerEnergy["Green"] = greenEnergy
    broadcastToAll("轮到绿方行动，本回合为第 " .. roundCount .. " 回合", {0.2,1,0.2})
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
    broadcastToAll("进入第 " .. roundCount .. " 回合，轮到白方行动", {1,1,1})
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



-- 以下注释内容是由于White Energy方块上无法正常显示current/max，所以用广播代替
-- function spawnEnergyToken(color, position)
--     spawnObject({
--         type = "Custom_Token",
--         position = position,
--         callback_function = function(obj)
--             obj.setName(color .. " Energy")
--             obj.setLock(true)
--             obj.setColorTint(stringColorToRGB(color))
--             obj.setScale({1.5, 0.2, 1.5})
--             obj.setRotation({0, 0, 0})
--             energyTokens[color] = obj
--             updateEnergyDisplay(color)
--         end
--     })
-- end


-- function updateEnergyDisplay(color)
--     local token = energyTokens[color]
--     if not token then return end

--     local current = playerEnergy[color] or 0
--     local maxEnergy = math.min(currentTurn, MAX_ENERGY)

    -- token.clearButtons()
    -- token.createButton({
    --     label = current .. " / " .. maxEnergy,
    --     position = {0, 0.4, 0},
    --     font_size = 250,
    --     height = 200, width = 600,
    --     color = {1, 1, 1, 0}, -- 背景透明
    --     font_color = {1, 1, 1, 1},
    --     click_function = "noop",           
    --     function_owner = Global
    -- })
--      broadcastToAll(color .. " 能量更新为 " .. current .. " / " .. maxEnergy, {1,1,1})
-- end

-- function updateAllEnergyDisplays()
--     for _, color in ipairs(playerColors) do
--         updateEnergyDisplay(color)
--     end
-- end
