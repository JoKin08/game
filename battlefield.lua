-- battlefield.lua

function spawnLeader(color, position)
    spawnObject({
        type = "BlockSquare",
        position = position,
        scale = {2.5, 0.4, 2.5},
        callback_function = function(obj)
            obj.setName("Zeus" .. color .. " (20 HP)")
            obj.setColorTint(stringColorToRGB(color))
            obj.setLock(true)
        end
    })
end

function spawnPreparationSlots(color, count, z)
    for i = 1, count do
        local x = -4 + (i - 1) * 2
        spawnObject({
            type = "BlockSquare",
            position = {x = x, y = 1, z = z},
            scale = {1.4, 0.2, 1.4},
            callback_function = function(obj)
                obj.setName(color .. "准备区 Slot " .. i)
                obj.setColorTint(stringColorToRGB(color))
                obj.setLock(true)
            end
        })
    end
end

function spawnBattleLanes()
    local lanes = {
        {name = "神道", x = -4},
        {name = "灵道", x = 0},
        {name = "人道", x = 4}
    }

    for _, lane in ipairs(lanes) do
        spawnObject({
            type = "BlockSquare",
            position = {x = lane.x, y = 1, z = 0},
            scale = {1.5, 0.1, 3},
            callback_function = function(obj)
                obj.setName(lane.name)
                obj.setColorTint({0.8, 0.8, 0.8}) -- 灰色
                obj.setLock(true)
            end
        })

        -- 文字标签（可选）
        spawnObject({
            type = "3DText",
            position = {x = lane.x, y = 1.3, z = 16.2},
            callback_function = function(obj)
                obj.TextTool.setValue(lane.name)
                obj.TextTool.setFontSize(200)
                obj.TextTool.setFontColor({1, 1, 1})
            end
        })
    end
end
