-- deck.lua
-- 初始化，发牌

local deck = {}

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

local function generateDeck()
    local player1Deck = {}
    local player2Deck = {}

    for _, card in ipairs(cardsData) do
        table.insert(player1Deck, card)
        table.insert(player1Deck, card)
        table.insert(player2Deck, card)
        table.insert(player2Deck, card)
    end

    shuffle(player1Deck)
    shuffle(player2Deck)

    return {
        White = player1Deck,
        Green = player2Deck
    }
end

local function dealToPlayer(deck, color)
    local handPos = Player[color].getHandTransform().position
    for i = 1, 5 do
        local xOffset = (i - 3) * 2
        local pos = {handPos.x + xOffset, handPos.y + 2, handPos.z}
        spawnCard(deck[i], pos)
    end
end

local function dealAllPlayers(decks)
    for _, color in ipairs({"White", "Green"}) do
        dealToPlayer(decks[color], color)
    end
end
