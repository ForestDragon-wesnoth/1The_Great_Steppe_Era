local H = wesnoth.require "helper"
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
    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }

    wesnoth.message("the ravenform ai is executed for side " .. wesnoth.current.side)


    for i,u in ipairs(units) do

        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "ravenform") and (u.moves > 0)
        then

        wesnoth.message("ravenform unit found")

        local command_data = { x = u.x, y = u.y }
        wesnoth.invoke_synced_command("ravenform_transform", command_data)

        else

--        wesnoth.message("ravenform unit not found")

       end
    end

end

return ca_ravenform
