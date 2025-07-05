--- STEAMODDED HEADER
--- MOD_NAME: BalatrOverlay
--- MOD_ID: balover
--- MOD_AUTHOR: [cantlookback]
--- MOD_DESCRIPTION: Helpful game overlay
----------------------------------------------
------------MOD CODE -------------------------

local load_ref = love.resize
function love.resize(self, w, h)
    local desiredWidth = 1920
    local desiredHeight = 1080

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local scaleX = windowWidth / desiredWidth
    local scaleY = windowHeight / desiredHeight
    scale = math.min(scaleX, scaleY)

    xoffset = (windowWidth - desiredWidth * scale) / 2
    yoffset = (windowHeight - desiredHeight * scale) / 2
    quad = love.graphics.newQuad(72, 0, 72, 95, 497, 475)
    load_ref(self, w, h)
end

local test_ref = love.draw
function love.draw(self)
    test_ref(self)

    if (G.hand ~= nil and scale ~= nil) then
        -- Display overlay boxes and data

        if (not G.deck_preview and not G.OVERLAY_MENU and G.STATE == G.STATES.SELECTING_HAND or G.STATE ==
            G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT or G.STATE ==
            G.STATES.ROUND_EVAL) then

            -- DATA SECTION
            love.graphics.setColor(1, 1, 1, 1)

            -- Combos
            if (combos ~= nil) then
                for i = 1, #combos do
                    love.graphics.print(combos[i], 510 * scale + xoffset, (300 + 20 * i) * scale + yoffset, 0, scale,
                        scale)
                end
            end
        end
    end

end

function checkHand()
    if (G.STATE ~= G.STATES.MENU and G.hand.cards ~= nil) then
        -- Filter out flipped cards
        local valid_cards = {}
        for _, card in ipairs(G.hand.cards) do
            if card.facing == "front" or (card.ability and card.ability.effect ~= 'Stone Card') then
                table.insert(valid_cards, card)
            end
        end
        
        -- Process hand with only non-flipped cards
        hasFlush(valid_cards)
        hasStraight(valid_cards) -- Straight, Straight-Flush (No Royal Flush)
        hasPairs(valid_cards) -- Two pair, Set, Full House, Four+Five of a kind
        
    end
end

function hasPairs(hand)
    local counter = {
        ["Ace"] = 0,
        ["King"] = 0,
        ["Queen"] = 0,
        ["Jack"] = 0,
        ["10"] = 0,
        ["9"] = 0,
        ["8"] = 0,
        ["7"] = 0,
        ["6"] = 0,
        ["5"] = 0,
        ["4"] = 0,
        ["3"] = 0,
        ["2"] = 0
    }

    local suitsCounter = {
        ["Ace"] = {},
        ["King"] = {},
        ["Queen"] = {},
        ["Jack"] = {},
        ["10"] = {},
        ["9"] = {},
        ["8"] = {},
        ["7"] = {},
        ["6"] = {},
        ["5"] = {},
        ["4"] = {},
        ["3"] = {},
        ["2"] = {}
    }

    local comboCounter = {
        ["Pair"] = {},
        ["Set"] = {}
    }

    local suits = {"Hearts", "Diamonds", "Spades", "Clubs"}

    for i = 1, #hand do
        counter[hand[i].base.value] = counter[hand[i].base.value] + 1
        table.insert(suitsCounter[hand[i].base.value], hand[i].base.suit)
    end

    for value, count in pairs(counter) do
        repeat
            if (count >= 5) then
                local suitCounter = 0
                for i = 1, #suits do
                    for i = 1, #suitsCounter[value] do
                        if (suitsCounter[value][i] == suits[i]) then
                            suitCounter = suitCounter + 1
                        end
                    end
                    if (suitCounter == 5) then
                        break
                    else
                        suitCounter = 0
                    end
                end
                if (suitCounter >= 5) then
                    table.insert(combos, "Flush Five: " .. value .. 's')
                else
                    table.insert(combos, "Five of a Kind: " .. value .. 's')
                end
            end
            if (count >= 4) then
                table.insert(combos, "Four of a Kind: " .. value .. 's')
            end
            if (count >= 3) then
                table.insert(comboCounter["Set"], value)

            end
            if (count >= 2) then
                table.insert(comboCounter["Pair"], value)
            end
        until true
    end

    for i = 1, #comboCounter["Set"] do
        for j = 1, #comboCounter["Pair"] do
            if (comboCounter["Set"][i] ~= comboCounter["Pair"][j]) then
                table.insert(combos, "Full House: " .. "3x" .. comboCounter["Set"][i] .. " + " .. "2x" ..
                    comboCounter["Pair"][j])
            end
        end
    end
    for i = 1, #comboCounter["Set"] - 1 do
        if (#comboCounter["Set"][i] ~= #comboCounter["Set"][i + 1]) then
            table.insert(combos, "Full House: " .. "3x" .. comboCounter["Set"][i] .. " + " .. "2x" ..
                comboCounter["Set"][i + 1])
        end
    end

    for i = 1, #comboCounter["Set"] do
        table.insert(combos, "Three of a Kind: " .. "3x" .. comboCounter["Set"][i])
    end

    for i = 1, #comboCounter["Pair"] - 1 do
        if (comboCounter["Pair"][i] ~= comboCounter["Pair"][i + 1]) then
            table.insert(combos, "Two Pair: " .. "2x" .. comboCounter["Pair"][i] .. " + " .. "2x" ..
                comboCounter["Pair"][i + 1])
        end
    end

    if (#combos == 0 and #comboCounter["Pair"] > 0) then
        table.insert(combos, "Pair: " .. "2x" .. comboCounter["Pair"][1])
    end

end

function hasFlush(hand)
    local counter = {
        ["Spades"] = 0,
        ["Clubs"] = 0,
        ["Diamonds"] = 0,
        ["Hearts"] = 0
    }

    for i = 1, #hand do
        counter[hand[i].base.suit] = counter[hand[i].base.suit] + 1
    end

    for value, count in pairs(counter) do
        if (count >= 5) then
            table.insert(combos, "Flush: " .. value)
        end
    end
end

local cardRanks = {
    ["Ace"] = 13,
    ["King"] = 12,
    ["Queen"] = 11,
    ["Jack"] = 10,
    ["10"] = 9,
    ["9"] = 8,
    ["8"] = 7,
    ["7"] = 6,
    ["6"] = 5,
    ["5"] = 4,
    ["4"] = 3,
    ["3"] = 2,
    ["2"] = 1
}

local function sortByCardRank(a, b)
    return cardRanks[a] > cardRanks[b]
end

function hasStraight(hand)
    local counter = {
        ["Ace"] = 0,
        ["King"] = 0,
        ["Queen"] = 0,
        ["Jack"] = 0,
        ["10"] = 0,
        ["9"] = 0,
        ["8"] = 0,
        ["7"] = 0,
        ["6"] = 0,
        ["5"] = 0,
        ["4"] = 0,
        ["3"] = 0,
        ["2"] = 0
    }

    local counterSuits = {
        ["Ace"] = {},
        ["King"] = {},
        ["Queen"] = {},
        ["Jack"] = {},
        ["10"] = {},
        ["9"] = {},
        ["8"] = {},
        ["7"] = {},
        ["6"] = {},
        ["5"] = {},
        ["4"] = {},
        ["3"] = {},
        ["2"] = {}
    }

    local suits = {"Spades", "Hearts", "Clubs", "Diamonds"}

    local keys = {}
    for k in pairs(counter) do
        table.insert(keys, k)
    end

    table.sort(keys, sortByCardRank)

    for i = 1, #hand do
        counter[hand[i].base.value] = counter[hand[i].base.value] + 1
        table.insert(counterSuits[hand[i].base.value], hand[i].base.suit)
    end

    local straightLength = 0
    straight = {}
    local suitCount = 0

    for _, key in ipairs(keys) do
        if (straightLength == 5) then
            for i = 1, #suits do
                for j = 1, #straight do
                    for k = 1, #counterSuits[straight[j]] do
                        repeat
                            if (counterSuits[straight[j]][k] == suits[i]) then
                                suitCount = suitCount + 1
                                break
                            end
                        until true
                    end
                end
                if (suitCount >= 5) then
                    table.insert(combos,
                        "Straight-Flush: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                            straight[4] .. ',' .. straight[5])
                    table.remove(straight, 1)
                    straightLength = straightLength - 1
                    suitCount = 0
                else
                    suitCount = 0
                end
            end
            if (straightLength == 5) then
                table.insert(combos, "Straight: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                    straight[4] .. ',' .. straight[5])
                table.remove(straight, 1)
                straightLength = straightLength - 1
            end
        end
        if (counter[key] > 0) then
            straightLength = straightLength + 1
            table.insert(straight, key)
        else
            straightLength = 0
            straight = {}
        end
        if (straightLength == 4 and key == "2" and counter["Ace"] > 0) then
            table.insert(straight, "A")
            table.insert(combos, "Straight: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                straight[4] .. ',' .. straight[5])
        end
    end
end

function calculate()
    if (G.STATE ~= G.STATES.MENU and handCards ~= nil and deckCards ~= nil) then

    end
end

function pairProb()

end

local sec_ref = CardArea.align_cards
function CardArea.align_cards(self)
    sec_ref(self)

    -- local handCards = G.hand.cards
    -- local deckCards = G.deck.cards
    probabilities = {}
    combos = {}
    checkHand()
end

----------------------------------------------
------------MOD CODE END----------------------
