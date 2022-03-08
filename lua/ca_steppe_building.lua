local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag
local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"
wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/ravana_inspect_table.lua"

local ca_building = {}
local builder_unit
local build_x
local build_y
local build_id
local buildoptions
local buildoptions_usable
local usable_buildnumber
local build_locations
local buildloc_number

--VERY IMPORTANT NOTE:
-- synced commands are initialized in ai.cfg instead of the ca file, as initiatilizing them in the ca file causes OOS for some reason (perhaps the lua files aren't synced)


function ca_building:evaluation()
--        wesnoth.message("building evaluation")

--    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }
    local units = wesnoth.get_units { side = wesnoth.current.side, ability = "steppe_build"}

    for i,u in ipairs(units) do
--        wesnoth.message("building unit detected")


-- TODO: make different buildings have different ranges for building, instead of using the same range for all buildings

    local nearby_enemies = AH.get_live_units {
        { "and", { { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } } },
        { "filter_location", { x = u.x, y = u.y, radius = 12 } },
        { "filter_vision", { side = wesnoth.current.side, visible = 'yes' } }
    }


        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "build") and #nearby_enemies > 0 then

                local can_build = false
                local will_build = false

--                inspect_table({u}, {}) --debug function
--                buildoptions = wml.child_array(wml.get_child(u.__cfg, "abilities"), "build_option")[1].build_id
--               wesnoth.message(buildoptions)

           buildoptions_usable = {} --makes the variable a table instead of nill
           local buildoptions_usable_total = 0

--        debug_utils.dbms(u, true, "unit data", true)


           for e,buildoptions in ipairs(wml.child_array(wml.get_child(u.__cfg, "abilities"), "build_option")) do

--            wesnoth.message(buildoptions.build_id)


--            wesnoth.message("gold: "..wesnoth.sides[wesnoth.current.side].gold)


        --remove the specific builing from the array if the unit doesn't have enough moves and gold to build a specific building


--        wesnoth.message(buildoptions.build_cost)


--        debug_utils.dbms(buildoptions, true, "build option", true)


-- the "(buildoptions.build_movescost_name / 100)" is hacky workaround as the normal movescost is treated as a string by Lua for some reason

            local tmp_buildcost = buildoptions.build_cost

--            wesnoth.message(tmp_buildcost)

--wordaround to make the market's cost (and other costs that rely on a variable) work properly
            if type(tmp_buildcost) == "string" then

                tmp_buildcost = string.sub(tmp_buildcost,2,99) --cuts down the string to remove the first letter from it ($) so the variable can be accessed through Lua
                tmp_buildcost = wml.variables[tmp_buildcost]

--            wesnoth.message(tmp_buildcost)

            end


            if (u.moves / u.max_moves) >= (buildoptions.build_movescost_name / 100) and wesnoth.sides[wesnoth.current.side].gold >= tmp_buildcost then
--               buildoptions_usable = buildoptions
-- prevent the AI from building watchtowers, as clearlng fog does very little for AI, and the gold can be better spent elsewhere
                if buildoptions.build_unit ~= "Slav_Watchtower" then
                    table.insert(buildoptions_usable,buildoptions)
                    buildoptions_usable_total = buildoptions_usable_total + 1
                end
            end


--            if buildoptions.build_id == "spiketrap" then --adding a check for whether this can be succesfully cleared
--                table.remove(buildoptions, e)
--            end



--               wesnoth.message(buildoptions.build_id)


           end


-- checking hitpoints did work, but not the ability contents oddly enough

--                wesnoth.message(u.abilities.dummy[1].id)
--                wesnoth.message(u.abilities.build_option[1].build_id)
--                wesnoth.message(u.hitpoints)





-- check if there is at least one usable building before attempting to build

            if buildoptions_usable[1] then


                usable_buildnumber = math.random(1,buildoptions_usable_total) --randomly choose a building from the building option array
--                wesnoth.message(buildoptions_usable[usable_buildnumber].build_id)

                can_build = true

            end

-- if there is an option to build, do an additional check for available tiles (just in case a unit can afford to build but the adjacent tiles are occupied)
            if can_build == true then


        build_locations = wesnoth.get_locations {
            { "and", { x = u.x, y = u.y, radius = 1 }},
            { "not", { { "filter", {} } } },
            { "not", { terrain = "_off^_usr,Q*,*^X*,X*,Wo*^*" } }
        }

--        LS.of_pairs(
--        )

--            {
--            { "and", { x = u.x, y = u.y, radius = 1 }},
--            { "and", { 
--                { "not", { "filter" {} }}
--             }
--            }
--         }



--        debug_utils.dbms(build_locations, true, "build locations", true)

--            build_locations = build_locations:to_stable_pairs()

--        debug_utils.dbms(build_locations, true, "build locations", true)

            if #build_locations > 0 then

--            local enemies = Ah.get_attackable_enemies({}, wesnoth.current.side)


-- NOTE: THIS DOES NOT CHECK UNITS IN FOG

            local nearest_enemy, tmp_distance = AH.get_closest_enemy({u.x, u.y},wesnoth.current.side)

--            debug_utils.dbms(nearest_enemy, true, "nearest enemy", true)

            if nearest_enemy then
                local closest_distance, location = 9e99
                for l,tmp_build_loc in ipairs(build_locations) do

  --          debug_utils.dbms(tmp_build_loc, true, "tmp build loc", true)

                    enemy_distance = M.distance_between(tmp_build_loc[1], tmp_build_loc[2], nearest_enemy.x, nearest_enemy.y)
                    if (enemy_distance < closest_distance) then
                        closest_distance = enemy_distance
                        buildloc_number = l
                    end
                end
            end

--            debug_utils.dbms(buildloc_number, true, "buildloc number", true)

-- if there is no closest enemy, choose a random tile to build on
            if buildloc_number then else
                buildloc_number = math.random(1, #build_locations)
            end


                will_build = true
            end


            end


            if will_build == true and build_locations then
--                wesnoth.message(build_locations[rand][1])

                builder_unit = u
                build_x = build_locations[buildloc_number][1]
                build_y = build_locations[buildloc_number][2]
--                build_id = "spiketrap"
--                build_id = "woodwall"
                build_id = buildoptions_usable[usable_buildnumber].build_id
                return 300000
            end
        end
    end

    return 0
end

function ca_building:execution()
--        wesnoth.message("building execution")
        local build_successful = false

--    wesnoth.message("the building ai is executed for side " .. wesnoth.current.side)



--        wesnoth.message("building unit transformed")
            local command_data = { x = builder_unit.x, y = builder_unit.y, build_x = build_x, build_y = build_y, build_id = build_id }
            wesnoth.invoke_synced_command("building_build", command_data)


-- check if there has been a building built at the target coordinates
        local builtunit = wesnoth.get_unit(build_x,build_y)
        if builtunit and builtunit.type == buildoptions_usable[usable_buildnumber].build_unit then
            build_successful = true
        end


          if build_successful == true then
             steppe_force_gamestate_change(ai)
--             wesnoth.message("gamestate changed")
          end



--        wesnoth.message("building unit not found")


end

return ca_building
