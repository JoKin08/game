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

    if zone == "prep" then
        attemptEnterBattle(card, player_color)
    elseif zone == "battle" then
        attemptAttack(card, player_color)
    else
        printToColor("当前区域无法行动", player_color, {1, 0.2, 0.2})
    end
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
            label = "被攻击", click_function = "onSelectedAsTarget",
            function_owner = Global,
            position = {0, 0.3, 0}, width = 1000, height = 1000,
            font_size = 200, color = {1, 0.2, 0.2}
        })
    end
end

-- 敌方所有单位选择（远程）
function selectAllEnemyTargets(player_color)
    local enemyColor = (player_color == "White") and "Green" or "White"
    local allTargets = getUnitsInZone(enemyColor, "battle")
    for _, c in ipairs(getUnitsInZone(enemyColor, "prep")) do table.insert(allTargets, c) end

    if #allTargets == 0 then
        printToColor("敌方没有可攻击单位", player_color, {1,0.2,0.2})
        return
    end

    printToColor("请选择任意敌方单位作为远程攻击目标", player_color, {1, 1, 0})
    for _, target in ipairs(allTargets) do
        target.setVar("isSelectableTarget", true)
        target.createButton({
            label = "被远程攻击", click_function = "onSelectedAsTarget",
            function_owner = Global,
            position = {0, 0.3, 0}, width = 1000, height = 1000,
            font_size = 200, color = {0.2, 0.2, 1}
        })
    end
end

-- 战斗结算
function resolveCombat(attacker, defender)
    local atkStats = attacker.getVar("stats")
    local defStats = defender.getVar("stats")

    local atkDmg = atkStats.damage or 0
    local defDmg = (defStats.skill_type == "Melee") and (defStats.damage or 0) or 0

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