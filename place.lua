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
