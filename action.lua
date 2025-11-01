-- action.lua
-- 卡牌从准备区移动到战道，并处理战斗逻辑（含近战）

function onCardMoveAttempt(params)
    local player_color = params[1]
    local card = params[2]

    -- ✅ 回合检查
    if (phase == "white" and player_color ~= "White") or
       (phase == "green" and player_color ~= "Green") then
        printToColor("不是你的回合", player_color, {1, 0.2, 0.2})
        return
    end

    -- ✅ 读取卡牌数据
    local stats = card.getVar("stats")
    local info = card.call("getCardInfo")
    if not stats or not info then
        printToColor("卡牌数据未初始化", player_color, {1, 0.2, 0.2})
        return
    end

    -- ✅ 检查剩余移动
    if info.remaining_move <= 0 then
        printToColor("该单位已无可用移动点", player_color, {1, 0.2, 0.2})
        return
    end

    -- ✅ 扣除行动能量
    local action_cost = stats.action_cost or 0
    if not consumeEnergy(player_color, action_cost) then return end

    -- ✅ 获取对应战道对象
    local lane = findBattleLane(stats.type)
    if not lane then
        printToColor("未找到对应战道", player_color, {1, 0.2, 0.2})
        return
    end

    -- ✅ 查找是否有敌方单位
    local existingEnemy = findEnemyInLane(lane, player_color)
    if existingEnemy then
        local canEnter = resolveCombat(card, existingEnemy)
        if not canEnter then
            printToColor("你未能击败敌人，无法进入该战道", player_color, {1, 0.2, 0.2})
            return
        end
    end

    -- ✅ 确认是否能进入战道
    if not canEnterLane(card, lane, player_color) then
        printToColor("该战道格子不可进入", player_color, {1, 0.2, 0.2})
        return
    end

    -- ✅ 执行移动
    local dest = lane.getPosition()
    dest.y = dest.y + 1.0
    card.setPositionSmooth(dest, false, true)
    card.setRotationSmooth({0, 180, 0})

    info.remaining_move = info.remaining_move - 1
    card.call("setCardInfo", info)

    updateCardZone(card, "battle", stats.type, nil)

    printToColor("已移动：" .. card.getName(), player_color, {0.3, 1, 0.3})
end

-- ✅ 将战道对象转换为字符串类型（God / Human / Ghost）
function getCardTypeFromLaneObject(laneObject)
    if not laneObject or not laneObject.getName then return nil end
    local name = laneObject.getName()
    if name:find("神道") then return "God"
    elseif name:find("人道") then return "Human"
    elseif name:find("灵道") then return "Ghost"
    end
    return nil
end

-- ✅ 根据类型找到战道对象
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

-- ✅ 使用 cardRegistry 判断是否能进入战道
function canEnterLane(card, lane, player_color)
    local laneType = getCardTypeFromLaneObject(lane)
    local friendly = 0
    local enemy = 0

    for otherCard, info in pairs(cardRegistry) do
        if info.zone == "battle" and info.lane == laneType then
            if info.owner == player_color then
                friendly = friendly + 1
            else
                enemy = enemy + 1
            end
        end
    end

    printToColor("战道检测: " .. laneType .. " | 友军:" .. friendly .. " 敌军:" .. enemy, player_color, {1,1,0})
    return friendly == 0 and enemy <= 1
end

-- ✅ 使用 cardRegistry 查找敌方单位
function findEnemyInLane(lane, player_color)
    local laneType = getCardTypeFromLaneObject(lane)
    for card, info in pairs(cardRegistry) do
        if info.zone == "battle" and info.lane == laneType and info.owner ~= player_color then
            printToColor("发现敌方单位：" .. card.getName(), player_color, {1, 0.8, 0.2})
            return card
        end
    end
    return nil
end

function resolveCombat(attacker, defender)
    local atkStats = attacker.getVar("stats")
    local defStats = defender.getVar("stats")

    local attackerName = attacker.getName()
    local defenderName = defender.getName()

    -- ✅ 1. 同步计算伤害
    local damageToDef = atkStats.damage or 0
    local damageToAtk = (defStats.skill_type == "Melee") and (defStats.damage or 0) or 0

    defStats.hp = defStats.hp - damageToDef
    atkStats.hp = atkStats.hp - damageToAtk

    printToAll(attackerName .. " 攻击 " .. defenderName .. "，造成 " .. damageToDef .. " 点伤害", {1,1,0})
    if damageToAtk > 0 then
        printToAll(defenderName .. " 反击 " .. attackerName .. "，造成 " .. damageToAtk .. " 点伤害", {1,0.6,0.6})
    end

    -- ✅ 2. 更新显示（即使死了也先更新一次）
    defender.setVar("stats", defStats)
    attacker.setVar("stats", atkStats)
    defender.call("updateDisplay")
    attacker.call("updateDisplay")

    -- ✅ 3. 计算死亡
    local defDead = defStats.hp <= 0
    local atkDead = atkStats.hp <= 0

    -- ✅ 4. 处理死亡（顺序无所谓，因为弃牌堆是安全位置）
    if defDead then
        printToAll(defenderName .. " 被击败", {1, 0.4, 0.4})
        moveToGraveyard(defender)
    end

    if atkDead then
        printToAll(attackerName .. " 被击败", {0.4, 0.4, 1})
        moveToGraveyard(attacker)
    end

    -- ✅ 5. 返回是否击败敌人（仅代表防守者死亡）
    return defDead
end


-- ✅ 将卡牌送入弃牌堆
function moveToGraveyard(card)
    local pos = card.getPosition()
    card.setPositionSmooth({x = pos.x, y = 2, z = pos.z + 5})
    unregisterCard(card)
end
