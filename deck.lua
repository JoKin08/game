-- deck.lua
-- 这部分是初始化卡牌，选白绿是因为对桌

playerColors = {"White", "Green"}

local player1Deck = {}
local player2Deck = {}

for _, card in ipairs(cardsData) do
  table.insert(player1Deck, card)
  table.insert(player1Deck, card)
  table.insert(player2Deck, card)
  table.insert(player2Deck, card)
end

function dealAll()
  shuffle(player1Deck)
  shuffle(player2Deck)
  dealToPlayer(player1Deck, playerColors[1])
  dealToPlayer(player2Deck, playerColors[2])
end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

function dealToPlayer(deck, color)
  local handPos = Player[color].getHandTransform().position
  local counter = {}

  for i = 1, 5 do
    local xOffset = (i - 3) * 2  
    local pos = {handPos.x + xOffset, handPos.y + 2, handPos.z}
    
    local cardData = deck[i]
    counter[cardData.name] = (counter[cardData.name] or 0) + 1
    local uniqueName = cardData.name .. "_" .. counter[cardData.name]

    spawnCard(cardData, pos, uniqueName)
  end
end