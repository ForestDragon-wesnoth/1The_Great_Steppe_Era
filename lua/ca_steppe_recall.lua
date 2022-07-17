local H = wesnoth.require "helper"
local AH = wesnoth.require("ai/lua/ai_helper.lua")
local LS = wesnoth.require "location_set"

local ca_steppe_recall = {}

function ca_steppe_recall:evaluation(cfg)
    -- Random recruiting from all the units the side has

    -- Check if leader is on keep
    local leader = wesnoth.units.find_on_map { side = wesnoth.current.side, canrecruit = 'yes' }[1]
    if (not leader) or (not wesnoth.terrain_types[wesnoth.current.map[leader]].keep) then
        return 0
    end

    -- Find all connected castle hexes
    local castle_map = LS.of_pairs({ { leader.x, leader.y } })
    local width, height, border = wesnoth.current.map.playable_width,wesnoth.current.map.playable_height,wesnoth.current.map.border_size
    local new_castle_hex_found = true

    while new_castle_hex_found do
        new_castle_hex_found = false
        local new_hexes = {}

        castle_map:iter(function(x, y)
            for xa,ya in H.adjacent_tiles(x, y) do
                if (not castle_map:get(xa, ya))
                    and (xa >= 1) and (xa <= width)
                    and (ya >= 1) and (ya <= height)
                then
                    local is_castle = wesnoth.terrain_types[wesnoth.current.map[{ x = xa, y = ya }]].castle

                    if is_castle then
                        table.insert(new_hexes, { xa, ya })
                        new_castle_hex_found = true
                    end
                end
            end
        end)

        for _,hex in ipairs(new_hexes) do
            castle_map:insert(hex[1], hex[2])
        end
    end

    -- Check if there is space left for recruiting
    local no_space = true
    castle_map:iter(function(x, y)
        local unit = wesnoth.units.get(x, y)
        if (not unit) then
            no_space = false
        end
    end)

    if no_space then return 0 end

    return 500000
end

function ca_steppe_recall:execution(cfg)
    -- Let this function blacklist itself if the chosen recruit is too expensive
    local recall_units = wesnoth.units.find_on_recall()

--    wesnoth.message("the recall ai is executed for side " .. wesnoth.current.side)
 
    if (#recall_units == 0) then return end
--        wesnoth.message(recall_units[1].id)
--        wesnoth.message(recall_units[1].recall_cost)

--this code seems to be kinda inconsistent, as the AI doesn't always recall units, even if it can afford them:
    if recall_units[1].recall_cost <= wesnoth.sides[wesnoth.current.side].gold then
        ai.recall(recall_units[1].id)
--        wesnoth.message("recall filter passed")
    end
end

return ca_steppe_recall