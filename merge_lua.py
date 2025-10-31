# merge_lua.py
file_order = [
    "cards.lua",
    "card_renderer.lua",
    "deck.lua",
    "energy.lua",
    "battlefield.lua",
    "main.lua"
]

with open("global.lua", "w", encoding="utf-8") as outfile:
    for filename in file_order:
        with open(filename, "r", encoding="utf-8") as infile:
            outfile.write(f"-- ===== {filename} =====\n")
            outfile.write(infile.read())
            outfile.write("\n\n")
