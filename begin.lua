function onLoad()
    self.createButton({
        label = "Start",
        click_function = "dealAll",
        function_owner = Global,
        position = {0, 0.3, 0},
        width = 1600, height = 500, font_size = 250
    })
end

function dealAll()
    dealCardsTo("White", 5) 
    dealCardsTo("Red", 5)
end
