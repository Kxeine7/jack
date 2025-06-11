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
        text={"this joker gains ",
        "{X:blue,C:white}1x{}",
        "for each{C:tarot} sub{}",
        "{C:inactive}currently {X:blue,C:white}x#1# {}chips"}
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

SMODS.Joker {
    key = "spire",
    atlas="jkr",
    pos = { x = 2, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 6,
    loc_txt={
        name="what the spire ?",
        text={"{C:red}#1# {}mult {C:money}+#2#$",
        "for each hand played"
        }
    },
    config = { extra = { mult = -2 ,mon=2} },
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                dollars=card.ability.extra.mon
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult,card.ability.extra.mon } }
    end,
}

SMODS.Joker {
    key = "ball",
    atlas="jkr",
    pos = { x = 3, y = 0 },
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    loc_txt={
        name="baller",
        text={"creates a random {C:tarot}tarot",
        " if played hand ",
        "is a {C:attention}#1#"}
    },
    config = { extra = { type="Flush" }},
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands[card.ability.extra.type]) and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            return {
                extra = {
                    message = localize('k_plus_tarot'),
                    message_card = card,
                    func = function() -- This is for timing purposes, everything here runs after the message
                        G.E_MANAGER:add_event(Event({
                            func = (function()
                                SMODS.add_card {
                                    set = 'Tarot',
                                }
                                G.GAME.consumeable_buffer = 0
                                return true
                            end)
                        }))
                    end
                },
            }
        end 
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.type} }
    end,
}

SMODS.Joker{
    key = "miku",
    blueprint_compat = false,
    rarity = 2,
    cost = 1,
    atlas="jkr",
    unlocked = true,
    discovered = true,
    pos = { x = 4, y = 0 },
    loc_txt={
        name="miku the fixer",
        text={"go up to {C:money}-#1#$ {}in debt",
    "{C:inactive}i don't think miku can fix this boss"}
    },
    config = { extra = { bankrupt_at = 50 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bankrupt_at } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.bankrupt_at
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.bankrupt_at
    end
}

SMODS.Joker {
    key = "portal",
    blueprint_compat = true,
    eternal_compat = false,
    rarity = 2,
    cost = 3,
    atlas="jkr",
    loc_txt={
        name="portal",
        text={"sell this joker",
    "to create {C:dark_edition}negative","{C:spectral}#1# spectral{} and {C:attention}#2# tarot"}
    },
    unlocked = true,
    discovered = true,
    pos = { x = 5, y = 0 },
    config={extra={tar=1,spec=1}},
    loc_vars = function(self, info_queue, card)
        return {vars={card.ability.extra.tar,card.ability.extra.spec}}
    end,
    calculate = function(self, card, context)
        if context.selling_self  then
            return {
                func = function()
                    -- This is for retrigger purposes, Jokers need to return something to retrigger
                    -- You can also do this outside the return and `return nil, true` instead
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            new_card=SMODS.create_card({area=G.consumables,set="Spectral",edition="e_negative"})
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            new_card=SMODS.create_card({area=G.consumables,set="Tarot",edition="e_negative"})
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                            play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                            return true
                        end)
                    }))
                end
            }
        end
    end,
}
SMODS.Joker {
    key = "egypt",
    blueprint_compat = true,
    atlas="jkr",
    loc_txt={
        name="{C:edition}GOD DAMN THE SUN",
        text={"{C:attention,s:5}GOD DAMN THE SUN","{C:inactive}[oh btw {C:white,X:red}x#1#{C:inactive}]mult and only when hand contains #2#",
    "{C:inactive}search {}RECONSTRUCT WHAT{C:inactive} on youtube"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 7,
    pos = { x = 6, y = 0 },
    config = { extra = { t_mult = 3, type = 'Pair' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return {
                xmult = card.ability.extra.t_mult
            }
        end
    end
}
