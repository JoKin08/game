-- main.lua

function onLoad()
    broadcastToAll("游戏开始！白方先手。当前回合：1", {1,1,1})
    showAllEnergies()

    spawnLeader("White", {x=0, y=1, z=10})
    spawnLeader("Green", {x=0, y=1, z=-10})

    spawnPreparationSlots("White", 5, 8)
    spawnPreparationSlots("Green", 5, -8)

    spawnBattleLanes()
end
