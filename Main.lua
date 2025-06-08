-- Define the Joker card using SMODS.Joker
SMODS.Joker {
    key = "lucky_turn",
    loc_txt = {
        name = "Lucky Turn",
        text = {
            "{C:green}#1# in #2# chance{} to gain {C:attention}+1 hand{}",
            "each time a hand is played",
            "Current Bonus: {C:attention}+#3# hand{}"
        }
    },
    config = { extra = { hands = 0, odds = 2 } }, -- Store hand count and odds (1 in 2)
    rarity = 2, -- Uncommon (1 = Common, 2 = Uncommon, 3 = Rare)
    cost = 7, -- Shop price
    unlocked = true,
    discovered = true,
    blueprint_compat = true, -- Compatible with Blueprint Joker
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not context.blueprint then
            -- Check for 1 in 2 chance using proper probability calculation
            if pseudorandom("lucky_turn") < G.GAME.probabilities.normal / card.ability.extra.odds then
                -- Increase hand count bonus
                card.ability.extra.hands = card.ability.extra.hands + 1
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                return {
                    message = "+1 Hand",
                    card = card,
                    colour = G.C.BLUE
                }
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        -- Update description with "1 in 2" and current hand count
        return { vars = { 1, card.ability.extra.odds, card.ability.extra.hands } }
    end
}

-- Optional: Localization file (e.g., localization/en-us.lua)
SMODS.current_mod.process_loc_text = function()
    G.localization.descriptions.Joker.lucky_turn = {
        name = "Lucky Turn",
        text = {
            "{C:green}#1# in #2# chance{} to gain {C:attention}+1 hand{}",
            "each time a hand is played",
            "Current Bonus: {C:attention}+#3# hand{}"
        }
    }
end
