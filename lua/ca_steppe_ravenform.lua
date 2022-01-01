local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag

local ca_ravenform = {}
local raven_unit

-- Move transport ships according to these rules:
-- 1. If transport can get to its designated landing site this move, find
--    close hex with the most unoccupied adjacent non-water hexes and move there
-- 2. If landing site is out of reach, move toward destination while
--    staying in deep water surrounded by deep water only
-- Also unload units onto best hexes adjacent to landing site

--VERY IMPORTANT NOTE:
-- synced commands are initialized in ai.cfg instead of the ca file, as initiatilizing them in the ca file causes OOS for some reason (perhaps the lua files aren't synced)


function ravenform_get_species(cfg)
    local abilities = wml.get_child(cfg.__cfg, "abilities")
    local ravenform_ability = wml.get_child(abilities, "ravenform")
    return ravenform_ability.species
end

function ca_ravenform:evaluation()
--        wesnoth.message("ravenform evaluation")


--    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }
    local units = wesnoth.get_units { side = wesnoth.current.side, ability = "steppe_ravenform"}

    for i,u in ipairs(units) do
--        wesnoth.message("ravenform unit detected")
        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "ravenform") and not steppe_has_ability(u, "ravenform_transformed") then

                local transform = false
            
                local filter_second = { { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } }
                local enemies = AH.get_live_units {
                    { "and", filter_second },
                    { "filter_location", { x = u.x, y = u.y, radius = 5 } },
                    { "filter_vision", { side = wesnoth.current.side, visible = 'yes' } }
                }
            
                local species = ravenform_get_species(u)
            
                local enemies_found = false
            
                if not enemies[1] then else
                    enemies_found = true
                end
            
            --    wesnoth.message(enemies_found)
            --    wesnoth.message(species)
            
            
            --transform human into raven if no enemies nearby
                if enemies_found == false and species == "human" then
                    transform = true
                end
            
            --transform raven into human with enemies nearby
                if enemies_found == true and species == "raven" then
                    transform = true
                end
            
            --transform human into raven if wounded
                if enemies_found == true and species == "human" and u.hitpoints < u.max_hitpoints * 0.5 then
                    transform = true
                end

            --do not transform into human form when wounded, as it's safer to flee instead
                if enemies_found == true and species == "raven" and u.hitpoints < u.max_hitpoints * 0.5 then
                    transform = false
                end


            if transform == true then
                raven_unit = u
                return 300000
            end
        end
    end

    return 0
end

function ca_ravenform:execution()
--        wesnoth.message("ravenform execution")

--    wesnoth.message("the ravenform ai is executed for side " .. wesnoth.current.side)

local orig_species = ravenform_get_species(raven_unit)


--        wesnoth.message("ravenform unit transformed")
            local command_data = { x = raven_unit.x, y = raven_unit.y }
            wesnoth.invoke_synced_command("ravenform_transform", command_data)

local new_species = ravenform_get_species(raven_unit)


--  check whether the unit did actually transform, and only then force the gamestate change, otherwise it can cause infinite loops
          if new_species ~= orig_species then
             steppe_force_gamestate_change(ai)
          end



--        wesnoth.message("ravenform unit not found")


end

return ca_ravenform
