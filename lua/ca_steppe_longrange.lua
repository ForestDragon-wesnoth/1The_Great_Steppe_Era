local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag
local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"

--local AIVAR = wesnoth.require "ai/micro_ais/micro_ai_unit_variables.lua"

local ca_longrange = {}
local target
local rand

--VERY IMPORTANT NOTE:
-- synced commands are initialized in ai.cfg instead of the ca file, as initiatilizing them in the ca file causes OOS for some reason (perhaps the lua files aren't synced)


function longrange_get_range(cfg)
    local abilities = wml.get_child(cfg.__cfg, "abilities")
    local longrange_ability = wml.get_child(abilities, "longrange_range")
    return longrange_ability.range
end

--NOTE: the whole data part isn't even necessary to be honest (since, like with ravenform/repair, I can just define a variable outside the functions and use it)

function ca_longrange:evaluation(cfg, data)
--        wesnoth.message("longrange evaluation")


--    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }

    local units = wesnoth.get_units { side = wesnoth.current.side, { "has_attack", { special_id = "steppe_longrange" }} }

-- TODO: add a check so that longranged attacks can't be used on units adjacent to the longrange unit

    local tmp_unit
    local target_index

    for i,u in ipairs(units) do
--        wesnoth.message("longrange unit detected")
--        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "longrange") and not steppe_has_ability(u, "longrange_transformed") then
        if (u.side == wesnoth.current.side) and u.attacks_left > 0 then

                local will_attack = false
            
--                local filter_second = { lua_function = "steppe_longrange_filter", { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } }
                local filter_second = { { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } }
                local enemies_potential = AH.get_live_units {
                    { "and", filter_second },
--                    { "and", filter_not_adjacent },
                    { "filter_location", { x = u.x, y = u.y, radius = longrange_get_range(u) } },
                    { "filter_vision", { side = wesnoth.current.side, visible = 'yes' } },
                    { "not", { { "filter_adjacent", { x = u.x, y = u.y } } } }
                }
                        
                local enemies_found = false

                local enemies = {}

--checks which enemies aren't behind impassable terrain:

                if #enemies_potential > 0 then

                for e,current_enemy in ipairs(enemies_potential) do

--                    wesnoth.message(steppe_check_impassable_between(u.x,u.y,current_enemy.x,current_enemy.y))
                    if steppe_check_impassable_between(u.x,u.y,current_enemy.x,current_enemy.y) == false then
                        table.insert(enemies,current_enemy)
--                        debug_utils.dbms(current_enemy, true, "current enemy", true)
                    end
                end

                end

--                wesnoth.message(#enemies)

--                debug_utils.dbms(enemies, true, "enemies", true)
            
                if not enemies[1] then else
                    enemies_found = true
                end
            
            --    wesnoth.message(enemies_found)
            --    wesnoth.message(species)
            
            --transform raven into human with enemies nearby
                if enemies_found == true then
                    will_attack = true

                    local max_rating = - math.huge

                    local attack_index

--                    debug_utils.dbms(u.attacks, true, "longrange weapon", true)



                    for weapon_number,att in ipairs(u.attacks) do
                        for _,sp in ipairs(att.specials) do
                            if (sp[1] == "longrange") then
                                attack_index = weapon_number
                            end
                        end
                    end
                
--                    longrange_weapon = u:find_attack { special_id = "steppe_longrange" }

--                debug_utils.dbms(longrange_weapon, true, "longrange weapon", true)

                local resist_multiplier,rating
                
                    for i,enemy in ipairs(enemies) do

                        resist_multiplier = 1 - enemy:resistance_against(u.attacks[attack_index].type) / 100. or 1

                        chance_to_hit = 1 - enemy:defense_on(wesnoth.current.map[enemy]) / 100.

                        rating = enemy.cost * resist_multiplier * chance_to_hit

                        if rating > max_rating then
                            max_rating = rating
                            target_index = i
                        end

                    end

--                    rand = math.random(1, #enemies)
                end
            
            if will_attack == true then

--                debug_utils.dbms(u, true, "unit", true)

--                AIVAR.insert_mai_unit_variables(u, "steppe_longrange", {})

--                data.testvar = "testvalue"

                data.longrange_id = u.id
                data.longrange_target = enemies[target_index].id

--                steppe_synced_set_var("steppe_ca_longrange_id",u.id)

--                debug_utils.dbms(enemies, true, "target", true)

--                wesnoth.message(enemies[rand].id)

--                steppe_synced_set_var("steppe_ca_longrange_target",enemies[rand].id)

--                debug_utils.dbms(target, true, "tmp build loc", true)
--                if wesnoth.get_variable("steppe_ca_longrange_id") ~= nil then
                if data.longrange_id ~= nil and data.fuckingbullshitvartriggered ~= true then
                    return 300000
                end
            end
        end
    end

    return 0
end

function ca_longrange:execution(cfg, data)

--        debug_utils.dbms(data, true, "data", true)

--        wesnoth.message("longrange execution")

--    wesnoth.message("the longrange ai is executed for side " .. wesnoth.current.side)


--        local longrange_unit = wesnoth.get_unit(wesnoth.get_variable("steppe_ca_longrange_id"))

--        local target = wesnoth.get_unit(wesnoth.get_variable("steppe_ca_longrange_target"))

        local longrange_unit = wesnoth.get_unit(data.longrange_id) 

        local target = wesnoth.get_unit(data.longrange_target)

--        wesnoth.message(target.id)



--        debug_utils.dbms(target, true, "target", true)

--        for i,u in ipairs(units) do
--
--            if AIVAR.get_mai_unit_variables(u, "steppe_longrange") then
--                longrange_unit = u
--                AIVAR.delete_mai_unit_variables(u, "steppe_longrange")
--
--            end
--
--        end

        local orig_attacks_left = longrange_unit.attacks_left

--        wesnoth.message("longrange unit coordinates: "..longrange_unit.x.." "..longrange_unit.y)
--        wesnoth.message("target unit coordinates: "..target.x.." "..target.y)

--        wesnoth.message("longrange unit transformed")

            local command_data = { x = longrange_unit.x, y = longrange_unit.y, x2 = target.x, y2 = target.y}
            wesnoth.sync.invoke_command("longrange_attack", command_data)




--local new_species = longrange_get_species(longrange_unit)


--            if longrange_unit.attacks_left < orig_attacks_left then
--                steppe_force_gamestate_change(ai)
--            end

--        wesnoth.message("longrange unit not found")

--        steppe_synced_set_var("steppe_ca_longrange_id",nil)--clear the variable

--        steppe_synced_set_var("steppe_ca_longrange_target",nil)--clear the variable

end

return ca_longrange
