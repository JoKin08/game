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
