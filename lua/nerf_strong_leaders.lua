local T = wml.tag

local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"

local res = {}

res.nerf_strong_leaders = function(args)
    local nerf_strong_leaders = wml.variables["nerf_strong_leaders"]
    if nerf_strong_leaders == nil then
        nerf_strong_leaders = wesnoth.game_config.mp_settings and (wesnoth.game_config.mp_settings.mp_campaign == "")
    end
    if not nerf_strong_leaders then
        return
    end

    local trait_debuff = args[1][2]

--    debug_utils.dbms(args, true, "arguments", true)
    for i, unit in ipairs(wesnoth.get_units { canrecruit = true, type_adv_tree = args.unit_tree, { "not", { trait = args[1][2].id} } }) do
        if not unit.variables.dont_make_me_slow then
            wesnoth.add_modification(unit, "trait", trait_debuff )
            unit.moves = unit.max_moves
            unit.hitpoints = unit.max_hitpoints
        end
    end
end
return res
