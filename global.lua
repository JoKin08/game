-- ===== cards.lua =====
-- cards.lua
-- 卡牌信息

local cardsData = {
  {
    name = "Hermes",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/01%E8%B5%AB%E5%B0%94%E5%A2%A8%E6%96%AF.png?raw=true",
    placement_cost = 1,
    action_cost = 0,
    damage = 1,
    hp = 2,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God - Melee"
  },
  {
    name = "Aphrodite",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/02%E9%98%BF%E5%BC%97%E6%B4%9B%E7%8B%84%E5%BF%92.png?raw=true",
    placement_cost = 2,
    action_cost = 1,
    damage = 1,
    hp = 3,
    move = 1,
    type = "God",
    skill_type = "Ranged",
    skill_text = "God - Ranged\n Romantic Curse: The attacked unit takes 1 unit less damage"
  },
  {
    name = "Ares",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/03%E9%98%BF%E7%91%9E%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 1,
    damage = 3,
    hp = 5,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God - Melee"
  },
  {
    name = "Artemis",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/04%E9%98%BF%E5%B0%94%E5%BF%92%E5%BC%A5%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 2,
    damage = 3,
    hp = 3,
    move = 1,
    type = "God",
    skill_type = "Ranged",
    skill_text = "God - Ranged\n Agility: When placed, deals 2 damage to each of two random enemy units."
  }
}


-- ===== card_renderer.lua =====
-- card_renderer.lua
-- 生成卡牌
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

function generateCardScript(data)
    local formattedSkillText = wrapAndCenter(data.skill_text, 32)
    local script = [[
        local stats = {
            placement_cost = ]] .. data.placement_cost .. [[,
            action_cost = ]] .. data.action_cost .. [[,
            damage = ]] .. data.damage .. [[,
            hp = ]] .. data.hp .. [[,
            move = ]] .. data.move .. [[,
            type = "]] .. data.type .. [[",
            skill_type = "]] .. data.skill_type .. [["
        }

        function onLoad()
            -- 显示基础数值
            print("卡牌加载成功：" .. self.getName())

            self.setVar("stats", stats)

            self.createButton({
                label = "Cost: " .. stats.placement_cost .. "  Action: " .. stats.action_cost ..
                        "\nDamage: " .. stats.damage .. "  HP: " .. stats.hp,
                click_function = "noop", function_owner = self,
                position = {0, 0.3, -1.2}, height = 0, width = 0, font_size = 90
            })

            -- 技能描述
            self.createButton({
                label = "]] .. formattedSkillText:gsub("\n", "\\n") .. [[",
                click_function = "noop", function_owner = self,
                position = {0, 0.3, 1.0}, height = 0, width = 0, font_size = 70
            })

            -- 出牌点击按钮（透明覆盖整张卡）
            self.createButton({
                click_function = "onClickPlay",
                function_owner = self,
                label = "",
                position = {0, 0.3, 0},
                width = 1600, height = 2200,
                color = {0,0,0,0}, font_color = {0,0,0,0},
                tooltip = "点击以出牌"
            })
        end

        function noop() end

        -- 点击测试
        function onClicked(player_color)
            print("111")
        end

        -- 真正的点击效果
        function onClickPlay(_, player_color)
            Global.call("onCardClicked", {player_color, self})
        end

        function getPlacementCost()
            return stats.placement_cost
        end

        function getActionCost()
            return stats.action_cost
        end

        function getDamage()
            return stats.damage
        end

        function getHP()
            return stats.hp
        end

        function getMove()
            return stats.move
        end

        function getType()
            return stats.type
        end

        function getSkillType()
            return stats.skill_type
        end

        function setCardInfo(info)
            self.setVar("cardInfo", info)
        end

        function getCardInfo()
            return self.getVar("cardInfo")
        end

    ]]
    return script
end

function spawnCard(data, position, uniqueName)
    local customCard = {
        Name = "Card",
        Transform = {
            posX = position[1], posY = position[2], posZ = position[3],
            rotX = 0, rotY = 180, rotZ = 0,
            scaleX = 1, scaleY = 1, scaleZ = 1
        },
        Nickname = uniqueName,
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


-- ===== place.lua =====
-- place.lua
-- 从手牌出到准备区

function onCardClicked(params)
    local player_color = params[1]
    local card = params[2]

    -- 1. 回合验证
    if (phase == "white" and player_color ~= "White") or (phase == "green" and player_color ~= "Green") then
        printToColor("不是你的回合！", player_color, {1, 0.2, 0.2})
        return
    end

    -- 2. 获取卡牌费用
    local ok, cost = pcall(function() return card.call("getPlacementCost") end)
    if not ok or not cost then
        printToColor("读取卡牌费用失败", player_color, {1, 0.2, 0.2})
        return
    end

    -- 3. 检查能量是否足够
    if not consumeEnergy(player_color, cost) then
        return
    end

    -- 4. 找一个空的准备区slot
    local slot = findEmptyPrepSlot(player_color)
    if not slot then
        printToColor("准备区已满，无法出牌", player_color, {1, 0.2, 0.2})
        return
    end

    -- 5. 移动卡牌到准备区（假设已手动从手牌拖出）
    local dest = slot.getPosition()
    dest.y = dest.y + 1.0
    card.setPositionSmooth(dest, false, true)
    card.setRotationSmooth({0, 180, 0}, false, true)

    -- 6. 设置卡牌状态信息（出牌算一次移动）
    local stats = card.getVar("stats")
    if not stats then
        printToColor("卡牌数据未初始化", player_color, {1, 0.2, 0.2})
        return
    end

    local remaining = math.max((stats.move or 0) - 1, 0)
    local info = {
        owner = player_color,
        remaining_move = remaining
    }

    -- 调用卡牌自己的 setCardInfo 方法
    card.call("setCardInfo", info)

    printToColor("已成功出牌：" .. card.getName(), player_color, {0.3, 1, 0.3})
end



-- === 找空的准备区 Slot ===
function findEmptyPrepSlot(player_color)
    local prefix = player_color .. "准备区 Slot"
    for _, obj in ipairs(getAllObjects()) do
        if obj.getName():find(prefix) then
            local pos = obj.getPosition()
            local occupied = false

            for _, o in ipairs(getAllObjects()) do
                local p = o.getPosition()
                if o.tag == "Card" and math.abs(p.x - pos.x) < 0.6 and math.abs(p.z - pos.z) < 0.6 then
                    occupied = true
                    break
                end
            end

            if not occupied then
                return obj
            end
        end
    end
    return nil
end


-- ===== deck.lua =====
-- deck.lua
-- 这部分是初始化卡牌，选白绿是因为对桌

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
  local counter = {}

  for i = 1, 5 do
    local xOffset = (i - 3) * 2  
    local pos = {handPos.x + xOffset, handPos.y + 2, handPos.z}
    
    local cardData = deck[i]
    counter[cardData.name] = (counter[cardData.name] or 0) + 1
    local uniqueName = cardData.name .. "_" .. counter[cardData.name]

    spawnCard(cardData, pos, uniqueName)
  end
end

-- ===== energy.lua =====
-- energy.lua
-- 管理能量系统

MAX_ENERGY = 15
roundCount = 1
phase = "white"

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


-- ===== battlefield.lua =====
-- battlefield.lua

local IMAGE_URLS = {
    zeusWhite = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E4%B8%BB%E5%B8%85_%E5%AE%99%E6%96%AF.png?raw=true",
    zeusGreen = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E4%B8%BB%E5%B8%85_%E5%AE%99%E6%96%AF.png?raw=true"
}

-- === 主帅贴图 ===
function spawnLeader(color, position)
    local image = color == "White" and IMAGE_URLS.zeusWhite or IMAGE_URLS.zeusGreen
    local rotation = color == "White" and {0, 0, 0} or {0, 180, 0}

    spawnObject({
        type = "Custom_Tile",
        position = position,
        rotation = rotation,
        scale = {1, 1, 1},
        callback_function = function(obj)
            obj.setLock(true)
            obj.setName("Zeus" .. color .. " (20 HP)")
            obj.setCustomObject({
                image = image,
                type = 0
            })
            obj.reload()
        end
    })
end

-- === 准备区锚点（透明方块占位） ===
function spawnPreparationSlots(color, count, z)
    for i = 1, count do
        local x = -4 + (i - 1) * 2
        spawnObject({
            type = "BlockSquare",
            position = {x = x, y = 1, z = z},
            scale = {1.2, 0.2, 1.2},
            callback_function = function(obj)
                obj.setLock(true)
                obj.setName(color .. "准备区 Slot " .. i)
                obj.setColorTint({1, 1, 1, 0}) -- 完全透明
                obj.setInvisibleTo({White = true, Green = true}) -- 双方不可见
            end
        })
    end
end

-- === 战道逻辑区域和 3D 文字 ===
function spawnBattleLanes()
    local lanes = {
        {name = "神道", x = -4},
        {name = "灵道", x = 0},
        {name = "人道", x = 4}
    }

    for _, lane in ipairs(lanes) do
        -- 战道逻辑区：不可见长方形
        spawnObject({
            type = "BlockSquare",
            position = {x = lane.x, y = 1, z = 0},
            scale = {2.5, 0.2, 3},
            callback_function = function(obj)
                obj.setLock(true)
                obj.setName("战道_" .. lane.name)
                obj.setColorTint({1, 1, 1, 0}) -- 完全透明
                obj.setInvisibleTo({White = true, Green = true})
            end
        })

        -- 白方视角文字
        spawnObject({
            type = "3DText",
            position = {x = lane.x, y = 3.5, z = -4.5},
            rotation = {0, 180, 0},
            callback_function = function(obj)
                obj.TextTool.setValue(lane.name)
                obj.TextTool.setFontSize(100)
                obj.TextTool.setFontColor({1, 1, 1})
            end
        })

        -- 绿方视角文字
        spawnObject({
            type = "3DText",
            position = {x = lane.x, y = 3.5, z = 4.5},
            rotation = {0, 0, 0},
            callback_function = function(obj)
                obj.TextTool.setValue(lane.name)
                obj.TextTool.setFontSize(100)
                obj.TextTool.setFontColor({1, 1, 1})
            end
        })
    end
end

-- === 总初始化 ===
function setupBattlefield()
    -- 白方主帅与准备区
    spawnLeader("White", {x = 0, y = 1, z = -10})
    spawnPreparationSlots("White", 5, -6)

    -- 战道
    spawnBattleLanes()

    -- 绿方准备区与主帅
    spawnPreparationSlots("Green", 5, 6)
    spawnLeader("Green", {x = 0, y = 1, z = 10})
end


-- ===== main.lua =====
-- main.lua

function onLoad()
    broadcastToAll("游戏开始！白方先手。当前回合：1", {1,1,1})
    showAllEnergies()

    spawnLeader("White", {x=0, y=1, z=10})
    spawnLeader("Green", {x=0, y=1, z=-10})

    spawnPreparationSlots("White", 5, 8)
    spawnPreparationSlots("Green", 5, -8)

    spawnBattleLanes()
end


