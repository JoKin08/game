function onLoad()
    self.createButton({
        label = "End Turn",
        click_function = "endTurn",
        function_owner = Global,
        position = {0, 0.3, 0},
        width = 1600, height = 500,
        font_size = 250
    })
end
