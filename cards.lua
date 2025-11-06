-- cards.lua
-- 卡牌信息

local cardsData = {
  {
    name = "Hermes",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/01%E8%B5%AB%E5%B0%94%E5%A2%A8%E6%96%AF.png?raw=true",
    placement_cost = 1,
    action_cost = 0,
    damage = 1,
    hp = 2,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God - Melee"
  },
  {
    name = "Aphrodite",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/02%E9%98%BF%E5%BC%97%E6%B4%9B%E7%8B%84%E5%BF%92.png?raw=true",
    placement_cost = 2,
    action_cost = 1,
    damage = 1,
    hp = 3,
    move = 1,
    type = "God",
    skill_type = "Ranged",
    skill_text = "God - Ranged\n Romantic Curse: The attacked unit takes 1 unit less damage",
    skill_func = function(targetCard)
      targetCard.damage = math.max(0, targetCard.damage - 1)
    end
  },
  {
    name = "Ares",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/03%E9%98%BF%E7%91%9E%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 1,
    damage = 3,
    hp = 5,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God - Melee"
  },
  {
    name = "Artemis",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/04%E9%98%BF%E5%B0%94%E5%BF%92%E5%BC%A5%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 2,
    damage = 3,
    hp = 3,
    move = 1,
    type = "God",
    skill_type = "Ranged",
    skill_text = "God - Ranged\n Agility: When placed, deals 2 damage to each of two random enemy units.",
    skill_func = function(targetCards)
      for _, card in ipairs(targetCards) do
        card.hp = card.hp - 2
      end
    end
  },
  {
    name = "Dionysus",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/05%E7%8B%84%E5%A5%A5%E5%B0%BC%E7%B4%A2%E6%96%AF.png?raw=true",
    placement_cost = 4,
    action_cost = 1,
    damage = 2,
    hp = 5,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God - Melee\n Feast: Grants all allied units +1 health.",
    skill_func = function(allyCards)
      for _, card in ipairs(allyCards) do
        card.hp = card.hp + 1
      end
    end
  },
  {
    name = "Athena",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/06%E9%9B%85%E5%85%B8%E5%A8%9C.png?raw=true",
    placement_cost = 6,
    action_cost = 3,
    damage = 4,
    hp = 6,
    move = 1,
    type = "God",
    skill_type = "Melee",
    skill_text = "God -Melee\n Justice from Above: Instantly deals 5 damage to a designated enemy unit.",
    skill_func = function(targetCard)
      targetCard.hp = targetCard.hp - 5
    end
  },
  {
    name = "Kerberos",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/11%E7%A7%91%E8%80%B3%E6%9F%8F%E6%B4%9B%E6%96%AF.png?raw=true",
    placement_cost = 2,
    action_cost = 1,
    damage = 2,
    hp = 2,
    move = 2,
    type = "Ghost",
    skill_type = "Melee",
    skill_text = "Ghost - Melee\n Monster: Act twice per turn."   
  },
  {
    name = "Heracles",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/12%E8%B5%AB%E6%8B%89%E5%85%8B%E5%8B%92%E6%96%AF.png?raw=true",
    placement_cost = 2,
    action_cost = 1,
    damage = 3,
    hp = 2,
    move = 1,
    type = "Ghost",
    skill_type = "Melee",
    skill_text = "Ghost - Melee\n Hero's Name: When placed, suppresses all enemy monsters for one turn; damage dealt to monsters +2.",
    skill_func = function(enemyMonsters)
      for _, card in ipairs(enemyMonsters) do
        card.suppressed = true
        card.damage = card.damage + 2
      end
    end
  },
  {
    name = "Chiron",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/13%E5%96%80%E6%88%8E.png?raw=true",
    placement_cost = 4,
    action_cost = 2,
    damage = 2,
    hp = 2,
    move = 1,
    type = "Ghost",
    skill_type = "Melee",
    skill_text = "Ghost - Melee\n Mentor's Guidance: When placing or leaving a unit, have it change lanes.",
    skill_func = function(card, newLane)
      card.lane = newLane
    end
  },
  {
    name = "Achilles",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/14%E9%98%BF%E5%96%80%E7%90%89%E6%96%AF.png?raw=true",
    placement_cost = 5,
    action_cost = 3,
    damage = 4,
    hp = 999,
    move = 1,
    type = "Ghost",
    skill_type = "Melee",
    skill_text = "Ghost - Melee\n Bathing in the Styx: No health remaining, dies after being hit twice.",
    skill_func = function(card)
      if card.hitCount == nil then
        card.hitCount = 0
      end
      card.hitCount = card.hitCount + 1
      if card.hitCount >= 2 then
        card.hp = 0
      end
    end
  },
  {
    name = "Medea",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/15%E7%BE%8E%E7%8B%84%E4%BA%9A.png?raw=true",
    placement_cost = 5,
    action_cost = 3,
    damage = 4,
    hp = 3,
    move = 1,
    type = "Ghost",
    skill_type = "Ranged",
    skill_text = "Ghost - Ranged\n The Witch's Wisdom: Ambush melee units; when attacked by melee, Medea's counterattack damage will be calculated first.",
    skill_func = function(attackerCard, defenderCard)
      if attackerCard.skill_type == "Melee" then
        attackerCard.hp = attackerCard.hp - defenderCard.damage
        if attackerCard.hp > 0 then
          defenderCard.hp = defenderCard.hp - attackerCard.damage
        end
      else
        defenderCard.hp = defenderCard.hp - attackerCard.damage
      end
    end
  },
  {
    name = "Typhon",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/16%E6%8F%90%E4%B8%B0.png?raw=true",
    placement_cost = 6,
    action_cost = 3,
    damage = 5,
    hp = 5,
    move = 2,
    type = "Ghost",
    skill_type = "Melee",
    skill_text = "Ghost - Melee\n Monster: Act twice per turn;\n Heavy Armor: -1 when attacked.",
    skill_func = function(card)
      card.damageTaken = (card.damageTaken or 0) - 1
    end
  },
  {
    name = "Agamemnon",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/21%E9%98%BF%E4%BC%BD%E9%97%A8%E5%86%9C.png?raw=true",
    placement_cost = 3,
    action_cost = 2,
    damage = 3,
    hp = 2,
    move = 1,
    type = "Human",
    skill_type = "Melee",
    skill_text = "Human - Melee\n Commander: For each additional friendly human unit on the field, damage increases by 1.",
    skill_func = function(card, allyHumans)
      card.damage = card.damage + #allyHumans
    end
  },
  {
    name = "Sisyphus",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/22%E8%A5%BF%E8%A5%BF%E5%BC%97%E6%96%AF.png?raw=true",
    placement_cost = 3,
    action_cost = 2,
    damage = 2,
    hp = 2,
    move = 1,
    type = "Human",
    skill_type = "Melee",
    skill_text = "Human - Melee\n Deceive Death: Take one card from the discard pile.",
    skill_func = function(discardPile)
      return table.remove(discardPile)
    end
  }
  {
    name = "Argonauts",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/23%E9%98%BF%E5%B0%94%E6%88%88%E5%8F%B7.png?raw=true",
    placement_cost = 4,
    action_cost = 3,
    damage = 4,
    hp = 3,
    move = 1,
    type = "Human",
    skill_type = "Melee",
    skill_text = "Human - Melee"
  }
  {
    name = "Tripp Tolemos",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/24%E7%89%B9%E9%87%8C%E6%99%AE%E6%89%98%E5%8B%92%E6%91%A9%E6%96%AF.png?raw=true",
    placement_cost = 4,
    action_cost = 2,
    damage = 2,
    hp = 2,
    move = 1,
    type = "Human",
    skill_type = "Melee",
    skill_text = "Human - Melee\n Eleusus's Ritual: Upon leaving the field, restores 3 health to the Leader.",
    skill_func = function(leader)
      leader.hp = leader.hp + 3
    end
  },
  {
    name = "Hippolytus",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/25%E5%B8%8C%E6%B3%A2%E5%90%95%E6%89%98%E6%96%AF.png?raw=true",
    placement_cost = 4,
    action_cost = 3,
    damage = 3,
    hp = 3,
    move = 1,
    type = "Human",
    skill_type = "Ranged",
    skill_text = "Human - Ranged\n Artemis Worship: Restores 1 HP to the friendly Artemis on the field.",
    skill_func = function(allyCards)
      for _, card in ipairs(allyCards) do
        if card.name == "Artemis" then
          card.hp = card.hp + 1
        end
      end
    end
  },
  {
    name = "Theseus",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/26%E5%BF%92%E4%BF%AE%E6%96%AF.png?raw=true",
    placement_cost = 5,
    action_cost = 3,
    damage = 4,
    hp = 3,
    move = 1,
    type = "Human",
    skill_type = "Melee",
    skill_text = "Human - Melee\n Aphrodite Worship: Restore 1 HP to the friendly Aphrodite on the field. \n Ship: Swap the positions of two designated cards of the same name on the field.",
    skill_func = function(card1, card2)
      local tempLane = card1.lane
      card1.lane = card2.lane
      card2.lane = tempLane
    end
  },
  {
    name = "Arrow of Apollo",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/31%E5%A4%AA%E9%98%B3%E4%B9%8B%E7%AE%AD.png?raw=true",
    placement_cost = 2,
    type = "Spell",
    skill_text = "Spell\n Heal or Plague: Grants a friendly unit +1 hp or an enemy unit -2 hp.",
    skill_func = function(targetCard, isAlly)
      if isAlly then
        targetCard.hp = targetCard.hp + 1
      else
        targetCard.hp = targetCard.hp - 2
      end
    end
  },
  {
    name = "Lotus-eaters",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/32%E9%A3%9F%E8%8E%B2%E4%BA%BA.png?raw=true",
    placement_cost = 3,
    type = "Spell",
    skill_text = "Spell\n Pleasant Sleep: Prevents one unit from acting next turn.",
    skill_func = function(targetCard)
      targetCard.suppressed = true
    end
  },
  {
    name = "Paris's referee",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/33%E5%B8%95%E9%87%8C%E6%96%AF%E7%9A%84%E8%A3%81%E5%88%A4.png?raw=true",
    placement_cost = 3,
    type = "Spell",
    skill_text = "Spell\n Divine Judgment: This allows one designated unit of our (or the enemy's) side to act immediately, at the cost of two random units losing 1 health point each.",
    skill_func = function(targetCard, randomCards)
      targetCard.move = targetCard.move + 1
      for _, card in ipairs(randomCards) do
        card.hp = card.hp - 1
      end
    end
  },
  {
    name = "Cassandra's prophecy",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/34%E5%8D%A1%E7%8F%8A%E5%BE%B7%E6%8B%89%E7%9A%84%E9%A2%84%E8%A8%80.png?raw=true",
    placement_cost = 4,
    type = "Spell",
    skill_text = "Spell\n Unfaithful Person: Swap the positions of all cards with the same name on the field."
  },
  {
    name = "Let's travel together!",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/35%E8%AE%A9%E6%88%91%E4%BB%AC%E4%B8%80%E5%90%8C%E6%97%85%E8%A1%8C%EF%BC%81.png?raw=true",
    placement_cost = 5,
    type = "Spell",
    skill_text = "Spell\n History: Draw three cards.",
    skill_func = function(playerDeck)
      local drawnCards = {}
      for i = 1, 3 do
        table.insert(drawnCards, table.remove(playerDeck))
      end
      return drawnCards
    end
  },
  {
    name = "Hammer of Hephaestus",
    image_url = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/36%E8%B5%AB%E8%8F%B2%E6%96%AF%E6%89%98%E6%96%AF%E4%B9%8B%E9%94%A4.png?raw=true",
    placement_cost = 5,
    type = "Spell",
    skill_text = "Spell\n Craftsmanship: Grants +2/+2 to the selected card, but if the target card is Ares, the action cost +1.",
    skill_func = function(targetCard)
      targetCard.damage = targetCard.damage + 2
      targetCard.hp = targetCard.hp + 2
      if targetCard.name == "Ares" then
        targetCard.action_cost = targetCard.action_cost + 1
      end
    end
  }
}

local BACK_URLS = {
    God = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E7%A5%9E.png?raw=true",
    Ghost = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E7%81%B5.png?raw=true",
    Human = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E4%BA%BA.png?raw=true",
    Spell = "https://github.com/JoKin08/game/blob/main/Assets/images_1.0/%E4%B8%BB%E5%B8%85_%E5%AE%99%E6%96%AF.png?raw=true"
}