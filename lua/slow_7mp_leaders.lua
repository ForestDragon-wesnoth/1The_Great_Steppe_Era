local T = wml.tag

local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"

local res = {}

res.slow_7mp_leaders = function(args)
    local make_7mp_leaders_slow = wml.variables["make_7mp_leaders_slow"]
    if make_7mp_leaders_slow == nil then
        make_7mp_leaders_slow = wesnoth.scenario.mp_settings and (wesnoth.scenario.mp_settings.mp_campaign == "")
    end
    if not make_7mp_leaders_slow then
        return
    end

    local trait_slow = args[1][2]

--    debug_utils.dbms(args[1][2], true, "arguments", true)

--    for i, unit in ipairs(wesnoth.get_unit { canrecruit = true, T.filter_wml { max_moves = 7 } }) do
    for i, unit in ipairs(wesnoth.units.find_on_map { canrecruit = true, { "not", { trait = args[1][2].id} } }) do
        if unit.max_moves >= 7 and not unit.variables.dont_make_me_slow then
            wesnoth.units.add_modification(unit, "trait", trait_slow )
            unit.moves = unit.max_moves
            unit.hitpoints = unit.max_hitpoints
        end
    end
end
return res
