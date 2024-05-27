--- STEAMODDED HEADER
--- MOD_NAME: Betmma Jokers
--- MOD_ID: BetmmaJokers
--- PREFIX: betm_jokers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 5 More Jokers!

----------------------------------------------
------------MOD CODE -------------------------

local MOD_PREFIX="betm_jokers_"
function SMODS.current_mod.process_loc_text()
    G.localization.misc.dictionary.k_errorr = "Rank Changed!"
    G.localization.misc.challenge_names.c_mod_testjoker = "TestJoker"

end

-- you can disable joker here
jokerBlacklists={}


    
    local localization = {
        jjookkeerr = {
            name = "JJookkeerr",
            text = {
                "Jokers with \"Joker\"",
                "in their names",
                "each gives {X:mult,C:white} X#1# {} Mult",
                -- if I count right there are 24 common, 6 uncommon and 3 rare jokers that satisfy this condition
            }
        },
        ascension = {
            name = "Ascension",
            text = {
                "Increase the tier of",
                "played poker hand by 1 ",
                "(e.g. High Card counts as One Pair)",
                -- How the poker hand "contained" is calculated should be clarified:
                -- If you play a Straight Flush, originally it contains Straight Flush, Flush, Straight and High Card. After triggering ascension it is counted as 5oak and contains 5oak, Straight Flush, Flush, Straight and High Card. Though a real 5oak contains 4oak and 3oak, this 5oak from ascension doesn't contain them.
            }
        },
        hasty = {
            name = "Hasty Joker",
            text = {
                "Earn {C:money}$#1#{} if round",
            "ends after first hand",
            }
        },
        errorr = {
            name = "ERRORR",
            text = {
                "Discarded cards have",
            "{C:green}#1# in #2#{} chance to",
            "become random rank"
            }
        },
        piggy_bank = {
            name = " Piggy Bank ",
            text = {
                "Put half of earned dollars",
                "into it and gain {C:red}+#2#{} Mult",
                "for each dollar",
                "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
                -- dollar in it adds to its sold price
            }
        },
        housing_choice = {
            name = "Housing Choice",
            text = {
                "Get a random {C:attention}Voucher{}",
                "if played hand contains",
                "a {C:attention}Full House{}. This can",
                "only trigger #1# times",
                "{C:inactive}({C:attention}#2#{C:inactive} left)"
                -- dollar in it adds to its sold price
            }
        }
    }

    --[[SMODS.Joker:new(
        name, slug,
        config,
        spritePos, loc_txt,
        rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat
    )
    ]]

    local jokers = {
        jjookkeerr = SMODS.Joker{
            name="JJookkeerr", key="jjookkeerr",
            config={extra=1.5},
            spritePos={x=0,y=0}, loc_txt="",
            rarity=2, cost=6, unlocked=true, discovered=true, blueprint_compat=true, eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra}}
            end
        },
        ascension = SMODS.Joker{
            name="Ascension", key="ascension",
            config={},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=6, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true
        },
        hasty = SMODS.Joker{
            name="Hasty Joker", key="hasty",
            config={extra=8},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=1, 
            cost=5, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra}}
            end
        },
        errorr = SMODS.Joker{
            name="ERRORR", key="errorr",
            config={extra={odds=3}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=3, 
            cost=8, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={''..(G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds}}
            end
        },
        piggy_bank = SMODS.Joker{
            name=" Piggy Bank ", key="piggy_bank",
            config={extra={mults=0, mult_mod=1}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=1, 
            cost=5, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra.mults, center.ability.extra.mult_mod}}
            end
        },
        housing_choice = SMODS.Joker{
            name="Housing Choice", key="housing_choice",
            config={extra={value=8,remaining=8}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=3, 
            cost=8, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=false,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra.value,center.ability.extra.remaining}}
            end,
            calculate=function(self,card,context)
                if context.cardarea==G.jokers and context.before and not context.blueprint and next(context.poker_hands["Full House"])then
                    card.ability.extra.remaining=card.ability.extra.remaining-1
                    randomly_redeem_voucher()
                    if card.ability.extra.remaining<=0 then 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card.T.r = -0.2
                                card:juice_up(0.3, 0.4)
                                card.states.drag.is = true
                                card.children.center.pinch.x = true
                                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                    func = function()
                                            G.jokers:remove_card(card)
                                            card:remove()
                                            card = nil
                                        return true; end})) 
                                return true
                            end
                        })) 
                    end
                end
            end
        },
    }


    -- this challenge is only for test
    -- table.insert(G.CHALLENGES,1,{
    --     name = "TestJoker",
    --     id = 'c_mod_testjoker',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 10},
    --         }
    --     },
    --     jokers = {
    --         {id = MOD_PREFIX..'j_jjookkeerr'},
    --         {id = MOD_PREFIX..'j_ascension'},
    --         {id = MOD_PREFIX..'j_hasty'},
    --         {id = MOD_PREFIX..'j_errorr'},
    --         {id = MOD_PREFIX..'j_piggy_bank'},
    --         {id = MOD_PREFIX..'j_piggy_bank'},
    --         {id = MOD_PREFIX..'j_housing_choice'},
    --     },
    --     consumeables = {
    --         {id = 'c_temperance'},
    --     },
    --     vouchers = {
    --         {id = 'v_directors_cut'},
    --     },
    --     deck = {
    --         type = 'Challenge Deck',
    --         --cards = {{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},}
    --     },
    --     restrictions = {
    --         banned_cards = {
    --         },
    --         banned_tags = {
    --         },
    --         banned_other = {
    --         }
    --     }
    -- })
    -- Localization
    init_localization()

    -- Add Jokers to center
    for k, v in pairs(jokers) do
        if not jokerBlacklists[k] then
            v.loc_txt = localization[k]
            --v.spritePos = { x = 0, y = 0 }
            --v:register()
            v.key = "j_" .. k
            SMODS.Atlas{key=v.key, path=v.key..".png", px=71, py=95}
            v.key = MOD_PREFIX .. v.key
            v.atlas=v.key
        end
    end

    --- Joker abilities ---
    jokers.jjookkeerr.calculate = function(self, card, context)
        if context.other_joker and context.other_joker ~= card and not context.other_joker.debuff then
            if string.match(context.other_joker.ability.name, "Joker") then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
                    Xmult_mod = card.ability.extra
                }
            end
        end
    end

    jokers.errorr.calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and
        pseudorandom('errorr') < G.GAME.probabilities.normal/card.ability.extra.odds then -- the argument of pseudorandom is hashed and only for random seed, so every string is ok
            local card=context.other_card
            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
            local rank_suffix = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
            local rand = math.floor(pseudorandom('rank')*13+1)
            card:set_base(G.P_CARDS[suit_prefix..rank_suffix[rand]])
            return {
                message = localize('k_errorr'),
                card = card,
                colour = G.C.CHIPS
            }
        end
    end

    jokers.piggy_bank.calculate = function(self, card, context)
        if SMODS.end_calculate_context(context) and card.ability.extra.mults > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mults}},
                mult_mod = card.ability.extra.mults, 
                colour = G.C.MULT
            }
        end
        if context.selling_self then
            card.selling_self = true
        end
    end

    


local poker_hand_list = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card",
}

-- Ascension
local evaluate_poker_hand_ref = evaluate_poker_hand
function evaluate_poker_hand(hand)
    local ret = evaluate_poker_hand_ref(hand)
    local Ascension_number = #find_joker('Ascension')
    for i = 1, Ascension_number, 1 do
        if next(ret[poker_hand_list[1]]) then break end -- Already getting the biggest hand
        for poker_hand_index = 2, #poker_hand_list, 1 do
            if next(ret[poker_hand_list[poker_hand_index]]) then 
                ret[poker_hand_list[poker_hand_index-1]]=ret[poker_hand_list[poker_hand_index]] -- Increase the tier of maximum hand by 1
                break
            end
        end
    end
    return ret
end

-- Hasty Joker
local calculate_dollar_bonus_ref = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
    if self.debuff then return end
    if self.ability.set == "Joker" then
        if self.ability.name == 'Hasty Joker' and G.GAME.current_round.hands_played == 1 then
            return self.ability.extra
        end
    end
    return calculate_dollar_bonus_ref(self)
end

--  Piggy Bank 
local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    ease_dollars_ref(mod, instant)
    if mod > 0 then
        local Piggy_Banks = find_joker(' Piggy Bank ')
        -- local Piggy_Bank_number = #Piggy_Banks
        --local saved_dollars = 0
        for index, card in pairs(Piggy_Banks) do
            local half = math.floor(mod/2)
            if half > 0 and not card.selling_self then
                delay(1)
                ease_dollars_ref(-half, false) 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                mod = mod - half
                card.ability.extra.mults = card.ability.extra.mults + card.ability.extra.mult_mod * half
                card.ability.extra_value = card.ability.extra_value + half
                card:set_cost()
            end
        end
    end

end



function SMODS.end_calculate_context(c)
    if not c.after and not c.before and not c.other_joker and not c.repetition and not c.individual and
        not c.end_of_round and not c.discard and not c.pre_discard and not c.debuffed_hand and not c.using_consumeable and
        not c.remove_playing_cards and not c.cards_destroyed and not c.destroying_card and not c.setting_blind and
        not c.first_hand_drawn and not c.playing_card_added and not c.skipping_booster and not c.skip_blind and
        not c.ending_shop and not c.reroll_shop and not c.selling_card and not c.selling_self and not c.buying_card and
        not c.open_booster then
        return true
    end
    return false
end

function randomly_redeem_voucher(no_random_please) -- xD
    -- local voucher_key = time==0 and "v_voucher_bulk" or get_next_voucher_key(true)
    -- time=1
    local voucher_key = no_random_please or get_next_voucher_key(true)
    local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
    card:start_materialize()
    G.play:emplace(card)
    card.cost=0
    card.shop_voucher=false
    local current_round_voucher=G.GAME.current_round.voucher
    card:redeem()
    G.GAME.current_round.voucher=current_round_voucher -- keep the shop voucher unchanged since the voucher bulk may be from voucher pack or other non-shop source
    card.should_remove=true -- if this function is called when calculating hand, this voucher will go to the deck and cause problem. I could only think of removing these vouchers in draw_from_discard_to_deck
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        --blockable = false,
        --blocking = false,
        delay =  0,
        func = function() 
            card:start_dissolve()
            return true
        end}))   
end
local G_FUNCS_draw_from_discard_to_deck_ref=G.FUNCS.draw_from_discard_to_deck
    G.FUNCS.draw_from_discard_to_deck = function(e)
        for k, v in ipairs(G.discard.cards) do
            if v.ability.set=='Voucher' then
                -- print(k,'addad')
                --k.k()
                G.E_MANAGER:add_event(Event({
                    func = (function()     
                            v:remove()
                    return true end)
                }))
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()     
                G_FUNCS_draw_from_discard_to_deck_ref(e)
            return true end)
          }))
    end
----------------------------------------------
------------MOD CODE END----------------------