local AH = wesnoth.require "ai/lua/ai_helper.lua"

function wesnoth.micro_ais.slave_ai(cfg)
	if (cfg.action ~= 'delete') then
		if (not cfg.id) and (not wml.get_child(cfg, "filter")) then
			wml.error("Slave Ai [micro_ai] tag requires either id= key or [filter] tag")
		end
	end

--    wesnoth.message("the slave mai is executed for side " .. wesnoth.current.side)

	local required_keys = {}
--	local optional_keys = { "id", "enemy_death_chance", "[filter]", "[filter_second]", "invert_order", "messenger_death_chance", "waypoint_loc", "waypoint_x", "waypoint_y" }
--new optional param syntax in 1.18
	local optional_keys = { avoid = 'tag', id = 'string', enemy_death_chance = 'float', filter = 'tag', filter_second = 'tag',
		invert_order = 'boolean', messenger_death_chance = 'float', waypoint_loc = 'string', waypoint_x = 'integer_list', waypoint_y = 'integer_list'
	}

	local score = cfg.ca_score or 300000
	local CA_parms = {
		ai_id = 'mai_steppe_slave_ai',
		{ ca_id = 'attack', location = 'ca_messenger_attack.lua', score = score },
--temporarily commented out until I can find a way to set the location properly
--		{ ca_id = 'move_to_any_enemy', location="ca_move_to_any_enemy.lua", score = score -1 },
		{ ca_id = 'escort_move', location = 'ca_messenger_escort_move.lua', score = score - 2 }
	}
    return required_keys, optional_keys, CA_parms
end