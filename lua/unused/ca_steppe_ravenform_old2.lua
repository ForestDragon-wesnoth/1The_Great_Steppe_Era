local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag

local ca_ravenform = {}

-- Move transport ships according to these rules:
-- 1. If transport can get to its designated landing site this move, find
--    close hex with the most unoccupied adjacent non-water hexes and move there
-- 2. If landing site is out of reach, move toward destination while
--    staying in deep water surrounded by deep water only
-- Also unload units onto best hexes adjacent to landing site

function ca_ravenform:evaluation()
    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }

    for i,u in ipairs(units) do
--        wesnoth.message("ravenform unit detected")
        if steppe_has_ability(u, "ravenform") then
            return 300000
        end
    end

    return 0
end

function ca_ravenform:execution()
    local units = wesnoth.get_units { side = wesnoth.current.side, ability="steppe_ravenform", formula = 'movement_left > 0' }

--    wesnoth.message("the ravenform ai is executed for side " .. wesnoth.current.side)


    for i,u in ipairs(units) do

        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "ravenform") and (u.moves > 0)
        then

        local reach = wesnoth.find_reach(u)

--        wesnoth.message("ravenform unit found")

        local transform = false

--        wesnoth.message(u.hitpoints, u.max_hitpoints)
--        wesnoth.message(u.max_hitpoints * 0.5)


    local filter_second = { { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } }
    local enemies = AH.get_live_units {
        { "and", filter_second },
        { "filter_location", { x = u.x, y = u.y, radius = 5 } },
        { "filter_vision", { side = wesnoth.current.side, visible = 'yes' } }
    }

    local abilities = wml.get_child(u.__cfg, "abilities")
    local ravenform_ability = wml.get_child(abilities, "ravenform")
    local species = ravenform_ability.species

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

        if transform == true then
--        wesnoth.message("ravenform unit transformed")
            local command_data = { x = u.x, y = u.y }
            wesnoth.invoke_synced_command("ravenform_transform", command_data)
        end


        else

--        wesnoth.message("ravenform unit not found")

       end
    end

end

return ca_ravenform
