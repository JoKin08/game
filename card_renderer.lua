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


