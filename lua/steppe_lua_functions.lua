--#textdomain wesnoth-gse
_ = wesnoth.textdomain "wesnoth-gse"
debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"


-- NOTE: this check the ability TAG, not ability id
function steppe_has_ability(unit, ability)
    -- Returns true/false depending on whether unit has the given ability
    local has_ability = false
    local abilities = wml.get_child(unit.__cfg, "abilities")
    if abilities then
        if wml.get_child(abilities, ability) then has_ability = true end
    end
    return has_ability
end

function steppe_attach_unit_status_renderer()
  local old_unit_weapons = wesnoth.interface.game_display.unit_weapons
  function wesnoth.interface.game_display.unit_weapons()
    local s = old_unit_weapons()
    local u = wesnoth.interface.get_displayed_unit()
    if u then
--        wesnoth.interface.add_chat_message("unit exists check passed")
      if steppe_has_ability(u, "devourer_of_souls") == true then
  
        table.insert(s, { "element", {
          text = _"Collected Souls: ".. (u.variables.collected_souls and (tostring(u.variables.collected_souls)) or "0").."\n",
          tooltip = _"The souls this unit collects are used for the 'devourer of souls' ability"
        } })
      end

      if steppe_has_ability(u, "birther_of_fiends") == true then
        if u.variables.birthturns and u.variables.birthturns > 0 then
  
         local birthtext_disabled = wml.variables["steppe_disable_birthturntext"]

          if birthtext_disabled ~= "yes" then
  
            table.insert(s, { "element", {
              text = _"Turns until birth: ".. (u.variables.birth_turns_left and (tostring(u.variables.birth_turns_left))).."\n",
              tooltip = _"Number of turns until a kanavar is birthed and added to the recall list"
            } })
          end
        end
      end

--not really needed at the moment, as adaptive strike is unused
--      if steppe_has_ability(u, "adaptive_armor") == true then
--  
--       local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")
--  
--        if russian_enabled then
--        table.insert(s, { "element", {
--          text = "Адаптивная Броня: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
--          tooltip = "Количество адаптивной брони которую этот юнит накопил. Важно для других способнотей как например 'апаптивный щит'"
--        } })
--        else
--        table.insert(s, { "element", {
--          text = "Adapative Armor: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
--          tooltip = "Amount of adaptive armor this unit currently has (used for other abilities like 'adaptive shield')"
--        } })
--        end
--      end

--      if steppe_has_ability(u, "duel") == true then
--        if u.variables.duel_turns_left and u.variables.duel_turns_left > 0 then
--  
--          table.insert(s, { "element", {
--            text = _"Inspiration turns left: ".. (u.variables.duel_turns_left and (tostring(u.variables.duel_turns_left)) or "0").."\n",
--            tooltip = _"Number of turns until the inspiration from the 'duel' ability wears off"
--          } })
--        end
--      end


      if steppe_has_ability(u, "idol_buff") == true then
        if u.variables.idolbuff_turns_left and u.variables.idolbuff_turns_left > 0 then
  
          table.insert(s, { "element", {
            text = _"Idol turns left: ".. (u.variables.idolbuff_turns_left and (tostring(u.variables.idolbuff_turns_left)) or "0").."\n",
            tooltip = _"Number of turns until the damage bonus from an idol wears off"
          } })
        end
      end

--faith is disabled for now
--      if steppe_has_ability(u, "kingdomfaction") == true or u.variables.faith then
--
--        local faith_name = {}
--        local heresy_name = {}
--
--        local faith = 0
----        local heresy = 0
--
--        local max_faith = 3
----        local max_heresy = 4
--
----        local is_heretic = false
--
--       if u.variables.faith then
--          faith = u.variables.faith
--       else
--          faith = "ERROR"
--       end
--
--       if u.variables.sermons_left then
--          sermons = u.variables.sermons_left
--       else
--          sermons = "ERROR"        
--       end
--
--
----for debugging
--       if 0 + faith > max_faith then
--          faith = 99
--       end
--
----       if u.variables.faith < 0 then
----          is_heretic=true
----          heresy = u.variables.faith * -1
----
----          faith = 99
----       end
---- 
----       if heresy > max_heresy then
----          heresy = 99
----       end
--
--          faith_name[0] = _"Godless"
--          faith_name[1] = _"Believer"
--          faith_name[2] = _"Faithful"
--          faith_name[3] = _"Pious"
----          faith_name[4] = "Fanatic"
--          faith_name[99] = _"ERROR: TOO HIGH FAITH"
--
----          heresy_name[1] = "Godless"
----          heresy_name[2] = "Sinner"
----          heresy_name[3] = "Apostate"
----          heresy_name[4] = "Heretic"
----          heresy_name[99] = "ERROR: TOO HIGH HERESY"
--
-- --         if heresy > 0 then
-- --         table.insert(s, { "element", {
-- --           text = "Heresy: ".. (heresy and (tostring(heresy)) or "0").." ("..heresy_name[heresy]..")".."\n",
-- --           tooltip = "The unit gains an invisuble backstab-like weapon special that deals 25% more damage per level of heresy. Also, at heresy 3 and higher, the unit becomes chaotic."
-- --         } })
-- --         else
--          table.insert(s, { "element", {
--            text = _"Faith: "..faith.." ("..faith_name[faith]..")".."\n",
--            tooltip = _"Gives different effects based on faith level:\n 1 - unit becomes lawful and fearless, but gets the pride 15% ability\n 2 - unit gains +1 damage, but gets the pride 25% ability\n 3 - unit gains the soul flame ability\n"
--          } })
----         end
--
--
--              if u.variables.faith < max_faith then
--    
--              table.insert(s, { "element", {
--                text = _"Sermons left: "..sermons.."\n",
--                tooltip = _"The amount of sermons until the unit's faith level increases by 1"
--              } })
--    
--              end
--
--      end

    end
    return s
  end
end


--example of how to use the find_special_by_tag function:
  --steppe_find_special_by_tag("second_weapon","enslave").enslave_level
  --this returns the enslave level of the second weapon's enslave tag

function steppe_find_special_by_tag(variable,special_tag)
--   wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/ravana_inspect_table.lua"
   local attack = wml.variables[variable]
--   inspect_table({attack}, {})
   local specials = wml.get_child(attack, "specials")
   local special = wml.get_child(specials, special_tag)
--   wesnoth.interface.add_chat_message("unit enslave level:",special.enslave_level)
   return special
end


function steppe_check_overlay_x1_y1(overlay_img)

--checks the variables of a unit at x1,y1

local overlayunit = wesnoth.units.get(wesnoth.current.event_context.x1, wesnoth.current.event_context.y1)

for overlay in overlayunit.__cfg.overlays:gmatch("[^,]+") do
    if overlay:match("^%s*(.-)%s*$") == overlay_img then
        --return a yes value, to show that the unit does have the overlay
        return true
    end
end

end



-- Force a gamestate change


--note: this won't be needed if/when I switch to 1.16, but it is necessary in 1.14
function steppe_force_gamestate_change(ai)
    -- Can be done using any unit of the AI side; works even if the unit already has 0 moves
    local unit = wesnoth.units.find_on_map { side = wesnoth.current.side }[1]
    local cfg_reset_moves = { id = unit.id, moves = unit.moves }
    ai.stopunit_moves(unit)
    wesnoth.sync.invoke_command('reset_moves', cfg_reset_moves)
end

function wesnoth.custom_synced_commands.reset_moves(cfg)
    local unit = wesnoth.units.find_on_map { id = cfg.id }[1]
    unit.moves = cfg.moves
end

--function steppe_simple_path(x1,y1,x2,y2)--x1,y1 is start, x2,y2 is destination
--   local destination_reached = false
--   local current_x,current_y = x1,y1
--   local path_table = {x = 0, y = 0}
--   local i = 1
--
--    debug_utils.dbms(current_x, true, "current x:", true)
--
--
--   while destination_reached == false do
--       
--    current_hex = wesnoth.map.get_direction (current_x,current_y,wesnoth.map.get_relative_dir(current_x,current_y,x2,y2))
--
--    debug_utils.dbms(current_hex, true, "current hex:", true)
--
--    current_x = current_hex[1]
--    current_y = current_hex[2]
--
--    path_table[i].x = current_hex[1]
--    path_table[i].y = current_hex[2]
--
--    i = i + 1
--
--
--    if current_x == x2 and current_y == y2 then
--        destination_reached = true
--    end
--
--   end
--
--    debug_utils.dbms(path_table, true, "path:", true)
--
--   return path_table
--
--end

function steppe_check_impassable_between(x1,y1,x2,y2)
    local found_wall = false

--    local path = steppe_simple_path(x1, y1, x2, y2)

--    local path = steppe_simple_path(x1, y1, x2, y2)


--using copy-pasted find path function with custom caclulate so that movescost is ignored
local max_moves = 99
local path = wesnoth.paths.find_path(x1, y1, x2, y2, {
    ignore_units = true,
    ignore_teleport = true,
    calculate = function(x, y, current_cost)
        local remaining_moves = max_moves - (current_cost % max_moves)
        if remaining_moves < 3 then current_cost = current_cost + remaining_moves end
        return current_cost + 3
    end })

    local tile_with_wall

--    debug_utils.dbms(path, true, "path:", true)

--    debug_utils.dbms(path, true, "path:", true)

    for i in ipairs(path) do

--        wesnoth.interface.add_chat_message(wesnoth.get_terrain(path[i][1], path[i][2]))

--        debug_utils.dbms(path, true, "path:", true)

        tile_with_wall = wesnoth.map.find {
            { "and", { x = path[i][1], y = path[i][2] }},
            { "and", { terrain = "_off^_usr,X*" } }
        }

--        debug_utils.dbms(tile_with_wall, true, "tile_with_wall:", true)


--if a hile with a wall exists, return true
        if tile_with_wall[1] then
            --return a yes value, to show that the unit does have the overlay
            found_wall = true
        end
    end

--    debug_utils.dbms(path, true, "path:", true)

--    debug_utils.dbms(found_wall, true, "found wall:", true)

    return found_wall
end

function steppe_longrange_filter(unit)
   local x,y = wml.variables["x1"],wml.variables["y1"]
--coordinates work flawlessly
--   wesnoth.interface.add_chat_message(unit.x)
--   wesnoth.interface.add_chat_message(unit.y)
--   wesnoth.interface.add_chat_message(x)
--   wesnoth.interface.add_chat_message(y)

--    debug_utils.dbms(unit, true, "unit:", true)

   local wall_found = steppe_check_impassable_between(unit.x,unit.y,x,y)
   if wall_found == true then
      return false
   else
      return true
   end
end

--used for longrange and aoe attacks. resistances, and various damage-affecting abilities/ToD are automatically calculated here
function steppe_calculate_undefended_attack_damage(attackerid,defenderid,weaponslot_wml)
    local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"

    local attacker = wesnoth.units.find_on_map { id = attackerid}
    local defender = wesnoth.units.find_on_map { id = defenderid}
    local weaponslot_lua = weaponslot_wml + 1--lua arrays start at 1 while wml ones start at 0

    local att_stats, def_stats, weapondata = wesnoth.simulate_combat(attacker[1], weaponslot_lua, defender[1], nil)

--    debug_utils.dbms(weapondata, true, "weapon data", true)

    return weapondata.damage

    --OLD UNUSED CODE:

                        --THIS teleports the unit to a new location instead of making a fake unit on those coordinates, not really what I want
                        --UPD: this code isn't even nedded

--                        attacker[1].x = args.fake_attacker_x
--                        attacker[1].y = args.fake_attacker_y

--                        debug_utils.dbms(attacker, true, "attacker", true)
--                        debug_utils.dbms(defender, true, "defender", true)

--code is no longer needed as weapondata variable has what I need
----                        debug_utils.dbms(att_stats, true, "attacker stats", true)
----                        debug_utils.dbms(def_stats, true, "defender stats", true)
--                        debug_utils.dbms(weapondata, true, "weapon data", true)
--
--                        local one_strike_damage = 0
--                        --interate through possible hp values to get
--
--                        --failsafe: if 0 hp is the only possibility where damage is dealt, kill the enemy
--                        if def_stats.hp_chance[0] > 0.0 then
--                            one_strike_damage = defender[1].hitpoints
--                        end
--
--                        for i in ipairs(def_stats.hp_chance) do
--                            --skip hp values that aren't possible 
--                            if def_stats.hp_chance[i] > 0.0 then
--                                if i < defender[1].hitpoints then
--                                    one_strike_damage = defender[1].hitpoints - i
--                                end
--                            end
--                        end

--                        wml.variables["tmp_longrange_strike_damage"] = one_strike_damage

--                        wml.variables["tmp_longrange_strike_damage"] = weapondata.damage

--                        debug_utils.dbms(att_stats.hp_chance, true, "attacker hp", true)
--                        debug_utils.dbms(def_stats.hp_chance, true, "defender hp", true)

end

function steppe_calculate_undefended_attack_chance_to_hit(attackerid,defenderid,weaponslot_wml)
    local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"

    local attacker = wesnoth.units.find_on_map { id = attackerid}
    local defender = wesnoth.units.find_on_map { id = defenderid}
    local weaponslot_lua = weaponslot_wml + 1--lua arrays start at 1 while wml ones start at 0

    local att_stats, def_stats, weapondata = wesnoth.simulate_combat(attacker[1], weaponslot_lua, defender[1], nil)

--    debug_utils.dbms(weapondata, true, "weapon data", true)

    return weapondata.chance_to_hit
end