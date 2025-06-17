SMODS.Atlas{
    key="jkr",
    path="jokers.png",
    px=71,
    py=95,





}
SMODS.DrawStep {
    key = 'hpr_card_shader',
    order = 21,
    func = function(self, layer)
        if self.area and self.config.center.mod and self.config.center.mod.id == "kxeine" then
            self.children.center:draw_shader('booster', nil, self.ARGS.send_to_shader)
        end
    end,
    --conditions = { vortex = false, facing = 'front' },
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
                    message = "+1",
                    card = card,
                    colour = G.C.BLUE
                }
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        -- Update description with "1 in 2" and current hand count
        return { vars = { G.GAME.probabilities.normal, card.ability.extra.odds, card.ability.extra.hands } }
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
    config = { extra = { type="Straight Flush" }},
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands[card.ability.extra.type]) then 
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
    end,
}
SMODS.Joker {
    key = "qr",
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "QR CODE",
        text = {
            "{C:blue}+#1# hand size{} every time a joker is {C:attention}sold",
            "{C:inactive}currently {C:blue}#2# {C:inactive}hand size",
            "{C:inactive}scan me",
            "{C:mult}reset if sold"
        }
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 15,
    pos = { x = 7, y = 0 },
    config = { extra = { h_size = 0, add = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.add, card.ability.extra.h_size } }
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
    calculate = function(self, card, context)
        if  context.selling_card and context.card.ability.set=="Joker" then
            card.ability.extra.h_size = card.ability.extra.h_size + card.ability.extra.add
            G.hand:change_size(card.ability.extra.add)
            return{message=localize('k_upgrade_ex')}
        end
    end,
}
SMODS.Joker {
    key = "job",
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "JOB APPLICATION",
        text = {"retrigger {C:attention}first{} and {C:attention}last",
    "scored card {C:attention}#1# additional times","{C:inactive}[sonic says you should get a job now]"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 4,
    pos = { x = 8, y = 0 },
    config = { extra = { repetitions = 5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] and context.other_card ~= context.scoring_hand[#context.scoring_hand] then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[#context.scoring_hand] and context.other_card == context.scoring_hand[#context.scoring_hand] then
            return{repetitions = card.ability.extra.repetitions}
        end
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[#context.scoring_hand] then
            return{repetitions = card.ability.extra.repetitions}
        end
    end,
}
SMODS.Joker {
    key = "wm",
    blueprint_compat = true,
    perishable_compat = false,
    atlas = "jkr",
    loc_txt = {
        name = "White monster",
        text = {"this joker gains {C:white,X:blue}+#1#{} chips ","each time the{C:attention} shop{} is{C:green} rerolled","{C:inactive}[currently {C:blue}+#2#{C:inactive} chips]"}
    },
    unlocked = true,
    discovered = true,
    rarity = 2,
    cost = 5,
    pos = { x = 9, y = 0 },
    config = { extra = { chip_gain = 7, chip = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.chip } }
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            card.ability.extra.chip = card.ability.extra.chip + card.ability.extra.chip_gain
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chip } },
                colour = G.C.CHIPS,
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chip}
        end
    end
}
SMODS.Joker {
    key = "sassystorm",
    unlocked = false,
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "sassystorm",
        text = {"{C:inactive}sassy sometimes","copies the ability of ","leftmost{C:attention} joker","{C:inactive}fuck you"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 8,
    pos = { x = 8, y = 1 },
    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local compatible = G.jokers.cards[1] and G.jokers.cards[1] ~= card and
                G.jokers.cards[1].config.center.blueprint_compat
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = card, align = "m", colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
            return { main_end = main_end }
        end
    end,
    calculate = function(self, card, context)
        local ret = SMODS.blueprint_effect(card, G.jokers.cards[1], context)
        if ret then
            ret.colour = G.C.RED
        end
        return ret
    end,
    check_for_unlock = function(self, args)
        if args.type == 'discard_custom' then
            local eval = evaluate_poker_hand(args.cards)
            if next(eval['Straight Flush']) then
                local min = 10
                for j = 1, #args.cards do
                    if args.cards[j]:get_id() < min then min = args.cards[j]:get_id() end
                end
                if min == 10 then
                    return true
                end
            end
        end
        return false
    end
}
SMODS.Joker {
    key = "blueprint",
    unlocked = false,
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "sassyprint",
        text = {"{C:inactive}sassy sometimes","copies the ability of {C:attention}joker","to the right","{C:inactive}fuck you"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 10,
    pos = { x = 2, y = 1 },
    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local other_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
            end
            local compatible = other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = card, align = "m", colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
            return { main_end = main_end }
        end
    end,
    calculate = function(self, card, context)
        local other_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
        end
        return SMODS.blueprint_effect(card, other_joker, context)
    end,
    check_for_unlock = function(self, args)
        return args.type == 'win_custom'
    end
}
SMODS.Joker {
    key = "oops",
    unlocked = false,
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "{C:edition}1 year anniversary",
        text = {"{C:attention}marks the 1 year of streaming","all {C:green}probabilities"," become {C:edition}guaranteed"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 4,
    pos = { x = 6, y = 1 },
    soul_pos={x=7,y=1},
    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v * 9999
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v / 9999
        end
    end,
    locked_loc_vars = function(self, info_queue, card)
        return { vars = { number_format(10000) } }
    end,
    check_for_unlock = function(self, args)                      -- equivalent to `unlock_condition = { type = 'chip_score', chips = 10000 }`
        return args.type == 'chip_score' and args.chips >= 10000 -- See note about Talisman at the bottom
    end
}
SMODS.Joker {
    key = "space",
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "fantastic",
        text = {"{C:attention}fantastic ain't it ?","{C:attention}sell {}this joker","to create up to {C:attention}#1# {C:white,X:mult}Rare{}jokers"}
    },
    unlocked = true,
    discovered = true,
    rarity = 1,
    cost = 5,
    pos = { x = 0, y = 1 },
    config = { extra = { creates = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.creates} }
    end,
    calculate = function(self, card, context)
        if context.selling_self and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local jokers_to_create = math.min(card.ability.extra.creates,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, jokers_to_create do
                        SMODS.add_card {
                            set = 'Joker',
                            rarity = 'Rare',
                            key_append = 'vremade_riff_raff' -- Optional, useful for manipulating the random seed and checking the source of the creation in `in_pool`.
                        }
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end
            }))
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end,
}
SMODS.Joker {
    key = "photo",
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "{C:edition}photomiku",
        text = {"{C:tarot}first{} and {C:tarot}last"," {C:attention}face cards give {C:white,X:blue}x#1#"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 8,
    pos = { x = 2, y = 13 },
    pixel_size = { h = 95 / 1.2 },
    config = { extra = { xmult = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            local is_first_face = false
            local last_face=false
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_face() then
                    is_first_face = context.scoring_hand[i] == context.other_card
                    break
                end
            end
            for i =#context.scoring_hand,1,-1 do
                if context.scoring_hand[i]:is_face() then
                    last_face = context.scoring_hand[i] == context.other_card
                    break
                end
            end
            
            if is_first_face  or last_face then
                return {
                    xchips = card.ability.extra.xmult
                }
            end
        end
    end
}
SMODS.Joker {
    key = "chad",
    blueprint_compat = true,
    atlas = "jkr",
    loc_txt = {
        name = "{C:edition}kasane chad",
        text = {"{C:tarot}first{} scored "," {C:attention}face card ","has {C:green}#2# in #3# {}chance to","{}gives {C:white,X:money}x#1# {C:money}$"}
    },
    unlocked = true,
    discovered = true,
    rarity = 3,
    cost = 8,
    pos = { x = 9, y = 6 },
    pixel_size = { h = 95 / 1.2 },
    config = { extra = { xmult = 2,odds=5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult ,G.GAME.probabilities.normal,card.ability.extra.odds} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            local is_first_face = false
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_face() then
                    is_first_face = context.scoring_hand[i] == context.other_card
                    break
                end
            end
            if is_first_face and pseudorandom('vremade_8_ball') < G.GAME.probabilities.normal / card.ability.extra.odds then
                return {
                    message="x2",
                    colour = G.C.MONEY,
                    dollars = G.GAME.dollars*card.ability.extra.xmult,
            

                }
            end
        end
    end
}
SMODS.Joker {
    key = "ss",
    atlas="jkr",
    loc_txt = {
        name = "sex note",
        text = {
            "{C:green}rerolling {}the {C:attention}shop","also {C:green}rerolls {C:tarot}packs {}and {C:tarot}vouchers"
        }
    },
    config = {},
    pos = { x = 3, y= 1 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
     calculate = function(self, card, context)
        if context.reroll_shop then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                func = function()
                    -- Reroll packs
                    local boosterno = math.max(#G.shop_booster.cards, G.GAME.starting_params.boosters_in_shop + (G.GAME.modifiers.extra_boosters or 0) )
                    for i = #G.shop_booster.cards,1, -1 do
                        local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                        c:remove()
                        c = nil
                    end
                    for i=1, boosterno do
                        SMODS.add_booster_to_shop()
                    end
                    -- Reroll vouchers
                    local voucherno = math.max(#G.shop_vouchers.cards, G.GAME.starting_params.vouchers_in_shop + (G.GAME.modifiers.extra_vouchers or 0))
                    for i = #G.shop_vouchers.cards,1, -1 do
                        local c = G.shop_vouchers:remove_card(G.shop_vouchers.cards[i])
                        c:remove()
                        c = nil
                    end
                    for i=1, voucherno do
                        SMODS.add_voucher_to_shop()
                    end
                    return true
                end
            }))
            return {
                message = "ez",
                card = card,
                colour = G.C.MONEY
            }
        end
    end
}
SMODS.Joker {
    key = "style",
    pos = { x = 1, y = 1 },
    rarity = 3,
    blueprint_compat = true,
    atlas="jkr",
    cost = 5,
    loc_txt={
        name="style meter",
        text={"if played hand ",
        "is a {C:attention}#1#","gain {C:attention}+#2# Style","if {c:attention}style {}reaches {C:attention}1000","sell this joker to","spawn {C:edition}the jackler","{C:inactive}currently {C:attention}#3# style"}
    },
    config = { extra = { type="Flush",add=50,style=0}},
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.selling_self and card.ability.extra.style>=100 then
            return {
                extra = {
                    message = localize('k_plus_tarot'),
                    message_card = card,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger="after",
                            func = (function()
                                new_card=SMODS.create_card({area=G.jokers,set="Joker",key="j_mvan_jackler"})
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                                return true
                            end)
                        }))
                    end
                },
                
            }
        elseif context.before and next(context.poker_hands[card.ability.extra.type]) then
            card.ability.extra.style=card.ability.extra.style+card.ability.extra.add
            return{
                message="+50",
                message_card=card,
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.type,card.ability.extra.add,card.ability.extra.style} }
    end,
}

SMODS.Joker {
    key = "jackler",
    pos = { x = 3, y = 8 },
    soul_pos={x=3,y=9},
    rarity = 4,
    blueprint_compat = false,
    atlas="jkr",
    cost = 20,
    loc_txt={
        name="the jackler",
        text={"at the start of round","add {C:attention}5 {C:green} random","{C:tarot}enhancement","{C:tarot}polychrome","cards to your hand"}
    },
    config = {},
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            for v=1,5 do
                local _card = SMODS.create_card { set = "Base", seal = SMODS.poll_seal({ guaranteed = true, type_key = 'vremade_certificate_seal' }),enhancement=SMODS.poll_enhancement({ guaranteed = true, type_key = 'vremade_certificate_seal' }),edition="e_polychrome",area = G.discard ,}
                G.E_MANAGER:add_event(Event({
                 func = function()
                      G.hand:emplace(_card)
                       _card:start_materialize()
                      G.GAME.blind:debuff_card(_card)
                      G.hand:sort()
                      if context.blueprint_card then
                         context.blueprint_card:juice_up()
                      else
                            card:juice_up()
                        end
                       return true
                   end
              }))
            end
            SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
}
SMODS.Joker {
    key = "gg",
    atlas = "jkr",
    pos = { x = 5, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    loc_txt = {
        name = "glock w no switch :(",
        text = {
            "this glock18 gives",
            "{X:mult,C:white}1x{}",
            "per{C:mult} bullet",
            "reloads when bullets reach 0",
            "{C:inactive}currently {X:mult,C:white}x#1#{C:inactive}/6 bullets"
        }
    },
    config = { extra = { bul = 6 } },
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.bul ~= 0 then
            card.ability.extra.bul = card.ability.extra.bul - 1
            return {
                xmult = card.ability.extra.bul
            }
        elseif context.joker_main and card.ability.extra.bul == 0 then
            card.ability.extra.bul = 6
            return {
                xmult = card.ability.extra.bul
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bul } }
    end,
}
