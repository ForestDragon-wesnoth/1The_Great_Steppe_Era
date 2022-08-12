function table_contains(t, v)
    for key, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

function wrap(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1-#indent1
  return indent1..str:gsub("(%s+)()(%S+)()",
                          function(sp, st, word, fi)
                            if fi-here > limit then
                              here = st - #indent
                              return "\n"..indent..word
                            end
                          end)
end

function dump_table(o, depth)
  if depth < 0 then
    return "..."
  end
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
     if k == nil then
      s = s .. '[nil] = ' .. ORM.debug.dump_table(v, depth-1) .. ','
     else
      local r = dump_table(v, depth-1)
      if r == nil then
        s = s .. '['..k..'] = nil,'
      else
        s = s .. '['..k..'] = ' .. dump_table(v, depth-1) .. ','
      end
    end
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function dump(o)
  wesnoth.interface.add_chat_message(dump_table(o, 1)) -- try wml.tostring()
end

function inspect_value(value, key, parent)
  dump(key)
  dump(value)
  if type(value) == "string" then
    dump("inspecting string")
  else
    dump("inspect_value type "..type(value))
  end
end

function inspect_table(t, path)
  if type(t) ~= "table" then
    return helper.wml_error("inspect_table called with "..type(t))
  end
  
  local _ = wesnoth.textdomain "wesnoth"
  H = wesnoth.require "lua/helper.lua"
  helper = H
  T = helper.set_wml_tag_metatable {} -- TODO 1.13 wml.tag

  local n=0
  local s={}
  for k in pairs(t) do
    n=n+1 s[n]=k
  end
  pcall(function() table.sort(s) end) -- sort if possible
  -- dump(s)

  local options = {}
  local excluded = {"_G","debug","H","helper","math","os","string","T","table","wesnoth","","wml"}
  if t ~= _G then excluded = {} end

  for k,v in ipairs(s) do
    k = v
    v=t[v]
    if type(v)=="table" then
      if table_contains(excluded, k) then else
        -- wesnoth.interface.add_chat_message("there is table",k)
        table.insert(options, k)
      end
    else
      table.insert(options, k)
    end
  end
  -- dump(s)
  -- dump(options)

  -- wesnoth.wml_actions.message({
    -- speaker="narrator",
    -- scroll=false,
    -- highlight=false,
    -- helper.set_variable_array("option", options)
  -- })

  local dialog = {
    T.tooltip { id = "tooltip_large" },
    T.helptip { id = "tooltip_large" },
    T.grid { T.row {
    T.column { T.grid {
      T.row { T.column { horizontal_grow = true, T.listbox { id = "the_list",
      T.list_definition { T.row { T.column { horizontal_grow = true,
        T.toggle_panel { return_value = -1, T.grid { T.row {
        T.column { horizontal_alignment = "left", T.label { id = "the_label" } },
        T.column { horizontal_alignment = "left", T.label { id = "the_label_padding" } },
        T.column { horizontal_alignment = "left", T.label { id = "the_label_value" } }
        } } }
      } } }
      } } },
      T.row { T.column { T.grid { T.row {
      T.column { T.button { id = "ok", label = _"OK", return_value=-1 } },
      T.column { T.button { id = "cancel", label = _"Done", return_value=-2 } },
      T.column { T.button { id = "back", label = _"Back", return_value=-3 } }
      } } } }
    } },
    T.column { T.image { id = "the_image" } }
    } }
  }
  
  local function preshow()

    local function select()
      local i = wesnoth.get_dialog_value "the_list"
      wesnoth.set_dialog_value("misc/new-battle.png", "the_image")
    end
    wesnoth.set_dialog_callback(select, "the_list")
    -- local function on_back()
      -- dump("on_back()")
      -- return -3
    -- end
    -- wesnoth.set_dialog_callback(on_back, "back")
    for i,v in ipairs(options) do
      wesnoth.set_dialog_value(v, "the_list", i, "the_label")
      wesnoth.set_dialog_value(" -> ", "the_list", i, "the_label_padding")
      -- dump(i)
      -- dump(options[i])
      -- dump(_G[options[i]])
      wesnoth.set_dialog_value(wrap(dump_table(t[options[i]], 0)), "the_list", i, "the_label_value")
    end
    -- wesnoth.set_dialog_value(1, "the_list") -- default selection
    select()
  end
  
  local li = 0
  local function postshow()
    li = wesnoth.get_dialog_value "the_list"
  end
  
  local r = wesnoth.show_dialog(dialog, preshow, postshow)
  -- dump(r)
  -- dump(li)
  if r == -1 and li ~= 0 then
    local child_name = options[li]
    -- dump("inspect called on "..child_name)
    local child = t[child_name]
    
    if type(child) == "table" then
      table.insert(path, t)
      inspect_table(child, path)
    else
      inspect_value(child, child_name, t)
    end
  end
  if r == -3 then
    local previous = path[#path]
    table.remove(path, #path)
    inspect_table(previous, path)
  end
end