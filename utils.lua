-- utils.lua
-- 管理回调

local onLoadCallbacks = {}

function registerOnLoad(func)
    table.insert(onLoadCallbacks, func)
end

function onLoad()
    for _, func in ipairs(onLoadCallbacks) do
        func()
    end
end
