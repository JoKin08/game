function onLoad()
    self.createButton({
        label = "End White Turn",
        click_function = "end1Turn",
        function_owner = Global,
        position = {0, 2.0, 0},
        width = 1800, height = 500,
        font_size = 250
    })
end
