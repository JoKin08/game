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

