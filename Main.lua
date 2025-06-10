SMODS.Atlas{
    key="jkr",
    path="jokers.png",
    px=71,
    py=95,





}
SMODS.Joker{
    key="maid",
    atlas="jkr",
    pos={x=0,y=0},
    rarity=1,
    cost=3,
    loc_txt = {
        name = "maid cosplay",
        text = {
            {"{C:green}#1# in #2# chance{} to gain {C:white,X:blue}+1 hand{}",
            "each time a {c:blue}hand {}is played",
        },{"{C:inactive}maid cosplay when ?"},
        }
    },
    config = { extra = { hands = 0, odds = 8 } }, -- Store hand count and odds (1 in 2)
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
                    message = "+1 hand",
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



SMODS.Joker {
    key = "twitch",
    atlas="jkr",
    pos = { x = 1, y = 0 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    loc_txt={
        name="twitch",
        text="this joker gains ",
        "{X:blue,C:white}1xchips{}",
        "for each{C:tarot}sub{}",
        "{C:inactive}currently{X:blue,C:white}x#1#",
    },
    config = { extra = { chips = 162 } },
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xchips = card.ability.extra.chips
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
}
