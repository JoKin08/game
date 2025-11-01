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
        if info.owner == owner and info.zone == zone and info.lane == lane then
            table.insert(results, card)
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
