--unused, as I can check whether a side is AI or not using syncronized choice

--local ca_check_if_ai = {}
--
--function wesnoth.custom_synced_commands.steppe_set_ai_var(cfg)
--    wesnoth.set_variable("steppe_is_ai"..wesnoth.current.side,"yes")
--end
--
--function ca_check_if_ai:evaluation(cfg)
--    -- CA that sets a variable if a side is AI-controlled, for now just used to check whether to show the vassal menu or to randomize vassals
--
--    local is_ai = wesnoth.get_variable("steppe_is_ai"..wesnoth.current.side)
--
----    debug_utils.dbms(is_ai, true, "is ai", true)
--
--    if is_ai == nil or is_ai == "no" then
--    return 700000
--    else
--    return 0
--    end
--end
--
--function ca_check_if_ai:execution(cfg)
--    if wesnoth.get_variable("steppe_is_ai"..wesnoth.current.side) == "yes" then else
--    wesnoth.invoke_synced_command("steppe_set_ai_var", {})
--    end
--end
--
--return ca_check_if_ai