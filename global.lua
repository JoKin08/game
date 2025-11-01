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
-- Buttons: 1数值 2卡面文字 3点击区域 4选择目标/ 4、5远程移动或攻击

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
            print("卡牌加载成功：" .. self.getName())

            self.setVar("stats", stats)

            if not self.getVar("cardInfo") then
                self.setVar("cardInfo", {
                    remaining_move = stats.move
                })
            end

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

            -- 点击按钮（初始是出牌）
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

        function onClicked(player_color)
            print("111")
        end

        function onClickPlay(_, player_color)
            Global.call("onCardClicked", {player_color, self})
        end

        function onClickMove(_, player_color)
            Global.call("onCardMoveAttempt", {player_color, self})
        end

        function onClickAction(_, player_color)
            local info = self.call("getCardInfo")
            if not info or info.owner ~= player_color then
                printToColor("只能操作你的单位", player_color, {1, 0.2, 0.2})
                return
            end
            Global.call("onBattleUnitClicked", {player_color, self})
        end

        function updateClickFunction(newFunc)
            local buttons = self.getButtons()
            if not buttons then
                print("no buttons found on the card")
                return
            end

            for _, btn in ipairs(buttons) do
                if btn.index == 2 then
                    self.editButton({
                        index = 2,
                        click_function = newFunc
                    })
                    print("have changed click function" .. newFunc)
                    return
                end
            end

            print("can't find button 2")
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

        function updateDisplay()
            self.editButton({
                index = 0,  -- 数值按钮是第一个 createButton 添加的，index = 0
                label = "Cost: " .. stats.placement_cost .. "  Action: " .. stats.action_cost ..
                        "\nDamage: " .. stats.damage .. "  HP: " .. stats.hp
            })
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

    Wait.time(function()
        card.call("updateClickFunction", "onClickMove")
    end, 0.5) 

    registerCard(card, player_color, "prep", nil, slot.getName())


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

    resetAllCardMovement("Green")

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

    resetAllCardMovement("White")
    
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


-- ===== turn.lua =====
-- turn.lua
-- 移动点重置

function resetAllCardMovement(player_color)
    for _, obj in ipairs(getAllObjects()) do
        if obj.tag == "Card" then
            local info = obj.call("getCardInfo")
            local stats = obj.getVar("stats")
            if info and stats and info.owner == player_color then
                info.remaining_move = stats.move or 0
                obj.call("setCardInfo", info)
                printToColor("卡牌 " .. obj.getName() .. " 移动点数已重置为 " .. info.remaining_move, player_color, {0.6, 0.9, 1})
            end
        end
    end
end



-- ===== action.lua =====
-- action.lua（完整重写版，支持近战/远程分离攻击逻辑）

-- 主入口：点击卡牌时调用
function onCardMoveAttempt(params)
    local player_color = params[1]
    local card = params[2]

    if cardRegistry[card].owner ~= player_color then
        printToColor("只能操作你的单位", player_color, {1, 0.2, 0.2})
        return
    end

    if (phase == "white" and player_color ~= "White") or
       (phase == "green" and player_color ~= "Green") then
        printToColor("不是你的回合", player_color, {1, 0.2, 0.2})
        return
    end

    local stats = card.getVar("stats")
    local info = card.call("getCardInfo")
    if not stats or not info then
        printToColor("卡牌数据未初始化", player_color, {1, 0.2, 0.2})
        return
    end

    if info.remaining_move <= 0 then
        printToColor("该单位本回合已无法行动", player_color, {1, 0.2, 0.2})
        return
    end

    local zone = getCardZone(card)

    -- 近战/远程分支
    if stats.skill_type == "Melee" then
        if zone == "prep" then
            attemptEnterBattle(card, player_color)
        elseif zone == "battle" then
            attemptAttack(card, player_color)
        else
            printToColor("当前区域无法行动", player_color, {1, 0.2, 0.2})
        end
    elseif stats.skill_type == "Ranged" then
        -- 选择移动还是攻击
        if zone == "prep" then
            showRangedActionChoice(card, player_color)
        elseif zone == "battle" then
            attemptAttack(card, player_color)
        else
            printToColor("当前区域无法行动", player_color, {1, 0.2, 0.2})
        end
    end

    clearAllSelectableButtons()

end

-- 从准备区进入战道
function attemptEnterBattle(card, player_color)
    local stats = card.getVar("stats")
    local info = card.call("getCardInfo")

    if not stats then
        printToColor("卡牌信息未初始化", player_color, {1, 0.2, 0.2})
        return
    end

    if info.remaining_move <= 0 then
        printToColor("该单位本回合已无法移动", player_color, {1, 0.2, 0.2})
        return
    end

    -- 确定目标战道
    local lane = findBattleLane(stats.type)
    if not lane then
        printToColor("未找到对应战道", player_color, {1, 0.2, 0.2})
        return
    end
    local laneName = lane.getName()

    -- 查找是否有我方单位，阻挡进入
    local friendlyUnits = getUnitsInZone(player_color, "battle", laneName)
    if #friendlyUnits > 0 then
        printToColor("该战道已有我方单位，无法进入", player_color, {1, 0.2, 0.2})
        return
    end

    -- 查找该战道是否已有敌人
    local enemyColor = (player_color == "White") and "Green" or "White"
    local enemyUnits = getUnitsInZone(enemyColor, "battle", laneName)

    if #enemyUnits > 0 then
        -- 相持，不能继续移动，但可以攻击
        updateCardZone(card, "battle", laneName, nil)
        moveCardToLane(card, lane, player_color)
        decrementMove(card)
        printToColor("你进入了战道，与敌方单位形成相持", player_color, {1, 1, 0})
        return
    end

    -- 无敌方单位：直接进入战道
    updateCardZone(card, "battle", laneName, nil)
    moveCardToLane(card, lane, player_color)
    decrementMove(card)
    printToColor("你成功进入战道并占领该路", player_color, {0.3, 1, 0.3})

    printToColor("战道单位数量：" .. tostring(#getUnitsInZone(enemyColor, "battle")), player_color, {1,1,1})
end


-- 战道攻击逻辑
function attemptAttack(card, player_color)
    local stats = card.getVar("stats")
    local info = card.call("getCardInfo")
    local lane = findBattleLane(stats.type)
    if not lane then return end

    local enemy = findEnemyInLane(lane, player_color)
    local enemyColor = (player_color == "White") and "Green" or "White"
    local prepTargets = findPrepUnits(enemyColor)

    if stats.skill_type == "Melee" then
        if enemy then
            print("战道内攻击")
            resolveCombat(card, enemy)
        elseif #prepTargets > 0 then
            print("准备区攻击")
            pendingAttackSource = card
            selectPrepTarget(prepTargets, player_color)
        else
            printToAll(card.getName() .. " 直接攻击敌方主帅！", {1,0,0})
            damageLeader(enemyColor, stats.damage)
        end
    elseif stats.skill_type == "Ranged" then
        if enemy or #prepTargets > 0 then
            pendingAttackSource = card
            selectAllEnemyTargets(player_color)
        else
            printToAll(card.getName() .. " 用远程攻击敌方主帅！", {1,0,0})
            damageLeader(enemyColor, stats.damage)
        end
    end

    info.remaining_move = info.remaining_move - 1
    card.call("setCardInfo", info)
end

-- 敌方准备区选择
function selectPrepTarget(prepTargets, player_color)
    printToColor("请选择一个敌方准备区单位进行攻击", player_color, {1, 1, 0})
    for _, target in ipairs(prepTargets) do
        target.setVar("isSelectableTarget", true)
        target.createButton({
            label = "choose", click_function = "onSelectedAsTarget",
            function_owner = Global,
            position = {0, 2, -1.2}, width = 1000, height = 1000,
            font_size = 200, color = {1, 0.2, 0.2}
        })
    end
end

-- 敌方所有单位选择（远程）
function selectAllEnemyTargets(player_color)
    local enemyColor = (player_color == "White") and "Green" or "White"
    local allTargets = getUnitsInZone(enemyColor, "battle")
    printToColor("战道单位数量：" .. tostring(#getUnitsInZone(enemyColor, "battle")), player_color, {1,1,1})

    for _, c in ipairs(getUnitsInZone(enemyColor, "prep")) do table.insert(allTargets, c) end

    if #allTargets == 0 then
        printToColor("敌方没有可攻击单位", player_color, {1,0.2,0.2})
        return
    end

    printToColor("请选择任意敌方单位作为远程攻击目标", player_color, {1, 1, 0})
    for _, target in ipairs(allTargets) do
        target.setVar("isSelectableTarget", true)
        target.createButton({
            label = "choose", click_function = "onSelectedAsTarget",
            function_owner = Global,
            position = {0, 5, -1.2}, width = 1000, height = 1000,
            font_size = 200, color = {0.2, 0.2, 1}
        })
    end
end

-- 战斗结算
function resolveCombat(attacker, defender)
    local atkStats = attacker.getVar("stats")
    local defStats = defender.getVar("stats")

    -- 只有近战单位会受到反击，远程单位则不会
    local atkDmg = atkStats.damage or 0
    local defDmg = (atkStats.skill_type == "Melee") and (defStats.damage or 0) or 0

    defStats.hp = defStats.hp - atkDmg
    atkStats.hp = atkStats.hp - defDmg

    attacker.setVar("stats", atkStats)
    defender.setVar("stats", defStats)
    attacker.call("updateDisplay")
    defender.call("updateDisplay")

    if defStats.hp <= 0 then
        printToAll(defender.getName() .. " 被击败", {1, 0.2, 0.2})
        moveToGraveyard(defender)
    end
    if atkStats.hp <= 0 then
        printToAll(attacker.getName() .. " 被反击击败", {0.2, 0.2, 1})
        moveToGraveyard(attacker)
    end
end

-- 主帅受到直接攻击
function damageLeader(player_color, dmg)
    local key = player_color .. "_leader_hp"
    print(key)
    local current = getVarGlobal(key) or 30
    setVarGlobal(key, current - dmg)
    printToAll(player_color .. " 主帅受到 " .. dmg .. " 点伤害！剩余血量" .. getVarGlobal(key) .. ".", {1,0.4,0.4})
end

-- 工具函数：卡牌在哪个区域
function getCardZone(card)
    local info = cardRegistry[card]
    return info and info.zone or nil
end

function findBattleLane(card_type)
    local mapping = {
        God = "战道_神道",
        Human = "战道_人道",
        Ghost = "战道_灵道"
    }
    local targetName = mapping[card_type]
    if not targetName then return nil end

    for _, obj in ipairs(getAllObjects()) do
        if obj.getName() == targetName then
            return obj
        end
    end
    return nil
end

function getCardTypeFromLaneObject(laneObject)
    if not laneObject or not laneObject.getName then return nil end
    local name = laneObject.getName()
    if name:find("神道") then return "God"
    elseif name:find("人道") then return "Human"
    elseif name:find("灵道") then return "Ghost"
    end
    return nil
end

function moveCardToLane(card, laneObj, player_color)
    local pos = laneObj.getPosition()
    pos.y = pos.y + 2  -- 避免穿模

    -- 若是白方，则z轴偏移负方向
    if player_color == "White" then
        pos.z = pos.z - 1.5
    else
        pos.z = pos.z + 1.5
    end

    card.setPositionSmooth(pos)
end

function decrementMove(card)
    local info = card.call("getCardInfo")
    if info and info.remaining_move then
        info.remaining_move = info.remaining_move - 1
        card.call("setCardInfo", info)
        card.call("updateDisplay")
    end
end

function findEnemyInLane(lane, player_color)
    -- local laneType = getCardTypeFromLaneObject(lane)
    local laneType = lane.getName()
    for card, info in pairs(cardRegistry) do
        if info.zone == "battle" and info.lane == laneType and info.owner ~= player_color then
            printToColor("发现敌方单位：" .. card.getName(), player_color, {1, 0.8, 0.2})
            return card
        end
    end
    return nil
end

function findPrepUnits(enemyColor)
    local results = {}
    for card, info in pairs(cardRegistry) do
        if info.zone == "prep" and info.owner == enemyColor then
            table.insert(results, card)
        end
    end
    return results
end

function moveToGraveyard(card)
    local pos = card.getPosition()
    -- 白方弃牌堆 z = -20，绿方 z = 20
    if cardRegistry[card].owner == "White" then
        pos.z = -20
    else
        pos.z = 20
    end
    pos.y = pos.y + 2
    card.setPositionSmooth(pos)
    unregisterCard(card)
end

function onSelectedAsTarget(target, player_color)

    local attacker = pendingAttackSource
    if not attacker then
        printToColor("未找到攻击来源", player_color, {1, 0.2, 0.2})
        return
    end

    resolveCombat(attacker, target)

    -- 清理选择状态
    target.setVar("isSelectableTarget", false)
    target.removeButton(3)  -- 我猜这是卡上的第四个按钮

    pendingAttackSource = nil
end

-- 提供远程单位在准备区的行动选择
function showRangedActionChoice(card, player_color)
    printToColor("move or attack", player_color, {1,1,0})

    card.createButton({
        label = "move",
        click_function = "onRangedMoveSelected",
        function_owner = Global,
        position = {0, 0.3, 0.8}, width = 1000, height = 500,
        font_size = 200, color = {0.3, 0.8, 0.3}
    })

    card.createButton({
        label = "attack",
        click_function = "onRangedAttackSelected",
        function_owner = Global,
        position = {0, 0.3, 0.1}, width = 1000, height = 500,
        font_size = 200, color = {0.8, 0.3, 0.3}
    })

    -- 设置标记用于点击按钮时识别
    card.setVar("awaitingRangedChoice", true)
end

function onRangedMoveSelected(card, player_color)
    if card.getVar("awaitingRangedChoice") then
        card.setVar("awaitingRangedChoice", nil)
        card.removeButton(3)
        card.removeButton(4)
        attemptEnterBattle(card, player_color)
    end
end

function onRangedAttackSelected(card, player_color)
    if card.getVar("awaitingRangedChoice") then
        card.setVar("awaitingRangedChoice", nil)
        card.removeButton(3)
        card.removeButton(4)
        selectAllEnemyTargets(player_color)
        pendingAttackSource = card
    end
end

-- 清除所有选择按钮（索引大于等于3的全部清掉）
function clearAllSelectableButtons()
    for card, info in pairs(cardRegistry) do
        if card.getVar("isSelectableTarget") then
            card.setVar("isSelectableTarget", false)
            local buttons = card.getButtons()
            if buttons then
                for i = #buttons, 1, -1 do
                    if i >= 3 then
                        card.removeButton(i)
                    end
                end
            end
        end
    end
end

-- ===== main.lua =====
-- main.lua

function onLoad()
    broadcastToAll("游戏开始！白方先手。当前回合：1", {1,1,1})
    showAllEnergies()

    setupBattlefield()

    setVarGlobal("White_leader_hp", 20)
    setVarGlobal("Green_leader_hp", 20)

end

cardRegistry = {}

-- 注册卡牌（首次上场）
function registerCard(card, owner, zone, lane, slot)
    cardRegistry[card] = {
        owner = owner,
        zone = zone,
        lane = lane,
        slot = slot
    }
    printToAll("注册卡牌：" .. card.getName() .. "，所属玩家：" .. owner, {0.5, 0.5, 1})
    debugPrintCardRegistry()
end

-- 更新卡牌位置（例如从准备区进入战道）
function updateCardZone(card, zone, lane, slot)
    if cardRegistry[card] then
        cardRegistry[card].zone = zone
        cardRegistry[card].lane = lane
        cardRegistry[card].slot = slot

        printToAll("更新卡牌位置：" .. card.getName() .. "，区域：" .. zone .. "，战道：" .. tostring(lane) .. "，槽位：" .. tostring(slot), {0.5, 1, 0.5})
    end
end

-- 移除卡牌（死亡进入弃牌堆）
function unregisterCard(card)
    cardRegistry[card] = nil
    printToAll("移除卡牌注册：" .. card.getName(), {1, 0.5, 0.5})
end

-- 查询某区域单位（如准备区、某战道）
function getUnitsInZone(owner, zone, lane)
    local results = {}
    for card, info in pairs(cardRegistry) do
        if info.owner == owner and info.zone == zone then
            -- 如果没有传 lane，则忽略 lane 检查
            if (not lane) or (info.lane == lane) then
                table.insert(results, card)
            end
        end
    end
    return results
end


function debugPrintCardRegistry()
    printToAll("==== 当前注册卡牌 ====", {1,1,0})
    for card, info in pairs(cardRegistry) do
        printToAll(card.getName() .. " | 所属: " .. info.owner .. " | 区域: " .. info.zone .. " | 战道: " .. tostring(info.lane), {1,1,1})
    end
end

function getVarGlobal(key)
    return Global.getVar(key)
end

function setVarGlobal(key, value)
    Global.setVar(key, value)
end


