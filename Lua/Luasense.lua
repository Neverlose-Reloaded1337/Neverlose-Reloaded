--[[

      Leak provided by Rollmops
        discord.gg/rollmopss
     Join for more premium leaks

]]--
local l_pui_0 = (function()
    


-- perfect user interface
----- neverlose



--------------------------------------------------------------------------------
-- #region :: Header


--
-- #region : Definitions

local _PUIVERSION = 1

--#region: localization

local print, require, print_raw, print_error, color, next, vector, type, pairs, ipairs, getmetatable, setmetatable, assert, rawget, rawset, rawequal, rawlen, unpack, select, tonumber, tostring, error, pcall, xpcall, print_dev =
	  print, require, print_raw, print_error, color, next, vector, type, pairs, ipairs, getmetatable, setmetatable, assert, rawget, rawset, rawequal, rawlen, unpack, select, tonumber, tostring, error, pcall, xpcall, print_dev


local C = function (t) local c = {} for k, v in next, t do c[k] = v end return c end

local table, math, string, ui = C(table), C(math), C(string), C(ui)

--#endregion

--#region: global table

table.find = function (t, j)  for k, v in next, t do if v == j then return k end end return false  end
table.ifind = function (t, j)  for i = 1, table.maxn(t) do if t[i] == j then return i end end  end
table.ihas = function (t, ...) local arg = {...} for i = 1, table.maxn(t) do for j = 1, #arg do if t[i] == arg[j] then return true end end end return false end

table.filter = function (t)  local res = {} for i = 1, table.maxn(t) do if t[i] ~= nil then res[#res+1] = t[i] end end return res  end
table.append = function (t, ...)  for i, v in ipairs{...} do table.insert(t, v) end  end
table.appendf = function (t, ...)  local arg = {...} for i = 1, table.maxn(arg) do local v = arg[i] if v ~= nil then t[#t+1] = v end end  end
table.range = function (t, i, j)  local r = {} for l = i or 0, j or #t do r[#r+1] = t[l] end return r  end
table.copy = function (o) if type(o) ~= "table" then return o end local r = {} for k, v in next, o do r[table.copy(k)] = table.copy(v) end return r end

math.round = function (value)  return math.floor (value + 0.5)  end
math.lerp = function (a, b, w)  return a + (b - a) * w  end

local ternary = function (c, a, b)  if c then return a else return b end  end
local aserror = function (a, msg, level) if not a then error(msg, level and level + 1 or 4) end end
local contend = function (func, callback, ...)
	local t = { pcall(func, ...) }
	if not t[1] then if type(callback) == "function" then return callback(t[2]) else error(t[2], callback or 2) end end
	return unpack(t, 2)
end

local debug = setmetatable({
	warning = function (...)
		print_raw("[\ae09334ffpui", "] ", ...)
	end,
	error = function (...)
		print_raw("[\aef6060ffpui", "] ", ...)
		cvar.play:call("ui/menu_invalid.wav")
		error()
	end
}, {
	__call = function (self, ...)
		if _IS_MARKET then return end
		print_raw("\a74a6a9ffpui - ", ...)
		print_dev(...)
	end
})

--#endregion

--#region: directory tools

local dirs = {
	execute = function (t, path, func)
		local p, k for _, s in ipairs(path) do
			k, p, t = s, t, t[s]
			if t == nil then return end
		end
		if p[k] ~= nil then func(p[k], p) end
	end,
	replace = function (t, path, value)
		local p, k for _, s in ipairs(path) do
			k, p, t = s, t, t[s]
			if t == nil then return end
		end
		p[k] = value
	end,
	find = function (t, path)
		local p, k
		for _, s in ipairs(path) do
			k, p, t = s, t, t[s]
			if type(t) ~= "table" then break end
		end
		return p[k]
	end,
}

dirs.pave = function (t, place, path)
	local p = t for i, v in ipairs(path) do
		if type(p[v]) == "table" then p = p[v]
		else p[v] = (i < #path) and {} or place  p = p[v]  end
	end return t
end

dirs.extract = function (t, path)
	if not path or #path == 0 then return t end
	local j = dirs.find(t, path)
	return dirs.pave({}, j, path)
end

--#endregion

local pui, pui_mt, methods_mt = {}, {}, { element = {}, group = {} }
local tools, elemence = {}, {}
local config, is_setup = {}, false

local stringlist

--
local dpi = render.get_scale(1)

-- #endregion
--

--
-- #region : Elements

--#region: definitions

local elements = {
	switch					= { type = "boolean",	arg = 2 },
	slider					= { type = "number",	arg = 6 },
	combo					= { type = "string",	arg = 2, variable = true },
	language				= { type = "string",	arg = 2, variable = true },
	selectable				= { type = "table",		arg = 2, variable = true },
	button					= { type = "function",	arg = 3, unsavable = true },
    list					= { type = "number",	arg = 2, variable = true },
    listable				= { type = "table",		arg = 2, variable = true },
    label					= { type = "string",	arg = 1, unsavable = true },
    texture					= { type = "userdata",	arg = 5, unsavable = true },
    image					= { type = "userdata",	arg = 5, unsavable = true },
    hotkey					= { type = "number",	arg = 2 },
    input					= { type = "string",	arg = 2 },
    textbox					= { type = "string",	arg = 2 },
    color_picker			= { type = "userdata",	arg = 2 },
    value					= { type = "any",		arg = 2 },
	["sol.lua::LuaVarClr"]	= { type = "userdata",	arg = 2 },
	[""]					= { type = "any",		arg = 2 },
}

--#endregion

--#region: methods parsing

local __mt = {
	group = {}, wrp_group = {},
	element = {}, wrp_element = {},
	events = {}
} do
	local element = ui.find("Miscellaneous", "Main", "Movement", "Air Duck")
    local group = element:parent()

	local element_keys, group_keys = { "__eq", "__index", "__name", "__type", "color_picker", "create", "disabled", "export", "get", "get_override", "id", "import", "key", "list", "name", "new", "override", "parent", "reset", "set", "set_callback", "tooltip", "type", "unset_callback", "update", "visibility",
	}, { "__eq", "__index", "__name", "__type", "button", "color_picker", "combo", "create", "disabled", "export", "hotkey", "import", "input", "label", "list", "listable", "name", "parent", "selectable", "slider", "switch", "texture", "value", "visibility", }

	--

	for i = 1, #element_keys do
		local k = element_keys[i]
		local v = element[k]
		__mt.element[k], __mt.wrp_element[k] = v, function (self, ...) return v(self.ref, ...) end
	end

	for i = 1, #group_keys do
		local k = group_keys[i]
		local v = group[k]
		__mt.group[k], __mt.wrp_group[k] = v, function (self, ...) return v(self.ref, ...) end
	end
end

--#endregion

--#region: weak tables

local icons = setmetatable({}, {
    __mode = "k",
    __index = function (self, name)
        local icon = ui.get_icon(name)
		if #icon == 0 then
			debug.warning(icon, ("<%s> icon not found"):format(name))
			return "[?]"
		end
        self[name] = icon
        return self[name]
    end
})

local groups = setmetatable({}, {
	__mode = "k",
	__index = function (self, raw)
		local key, group
		local kind = type(raw)

		if kind == "table" then
			if raw.__name == "pui::group" then return raw.ref end
			for i = 1, #raw do  raw[i] = tools.format(raw[i])  end

			key, group = raw[1] .."-".. (raw[2] or ""), ui.create(unpack(raw))
		elseif kind == "userdata" and raw.__name == "sol.lua::LuaGroup" then
			key, group = tostring(raw), raw
		else
			raw = tools.format(raw)
			key, group = tostring(raw), ui.create(raw)
		end

		self[key] = group

		return self[key]
	end
})

--#endregion

-- #endregion
--

--
-- #region : Utils

--#region: tools

do
	local fmethods = {
		gradients = function (col, text)
			local colors = {}; for w in string.gmatch(col, "\b%x+") do
				colors[#colors+1] = color(string.sub(w, 2))
			end
			if #colors > 0 then return tools.gradient(text, colors) end
		end,
		colors = function (col)
			-- debug.warning("\ae09334ff\"\\a[...]\"\aDEFAULT is obsolete. Update to \ae09334ff\\b<...>\aDEFAULT and \ae09334ffpui.macros")
			return pui.colors[col] and ("\a".. pui.colors[col]:to_hex()) or "\aDEFAULT"
		end,
		macros = setmetatable({}, {
			__newindex = function (self, key, value)
				local kv = type(value)
		
				if kv == "string" then
				elseif kv == "userdata" and value.__name == "sol.ImColor" then
					value = "\a" .. value:to_hex()
				else
					value = tostring(value)
				end
		
				rawset(self, tostring(key), value)
			end,
			__index = function (self, key) return rawget(self, key) end
		})
	}

	pui.macros = fmethods.macros

	tools.format = function (s)
		if type(s) == "string" then
			if stringlist then stringlist[s] = true end
			s = string.gsub(s, "\b<(.-)>", fmethods.macros)
			s = string.gsub(s, "[\v\r]", { ["\v"] = "\a{Link Active}", ["\r"] = "\aDEFAULT" })
			s = string.gsub(s, "([\b%x]-)%[(.-)%]", fmethods.gradients)
			s = string.gsub(s, "\a%[(.-)%]", fmethods.colors)
			s = string.gsub(s, "\f<(.-)>", icons)
		end

		return s
	end

	tools.gradient = function (text, colors)
		local symbols, length = {}, #(text:gsub(".[\128-\191]*", "a"))
		local s = 1 / (#colors - 1)

		local i = 0
		for letter in string.gmatch(text, ".[\128-\191]*") do
			i = i + 1

			local weight = i / length
			local cw = weight / s
			local j = math.ceil(cw)
			local w = (cw / j)
			local L, R = colors[j], colors[j+1]

			local r = L.r + (R.r - L.r) * w
			local g = L.g + (R.g - L.g) * w
			local b = L.b + (R.b - L.b) * w
			local a = L.a + (R.a - L.a) * w

			symbols[#symbols+1] = ("\a%02x%02x%02x%02x%s"):format(r, g, b, a, letter)
		end

		symbols[#symbols+1] = "\aDEFAULT"

		return table.concat(symbols)
	end
end

--#endregion

--#region: elemence

do
	elemence.new = function (ref)
		local this = { ref = ref }
		--

		this.__depend = { {}, {} }
		this[0], this[1] = {
			type = __mt.element.type(this.ref),
			events = {}, callbacks = {},
		}, {}

		this[0].savable = not elements[this[0].type].unsavable == true
		--

		if this[0].type ~= "button" then
			local v1, v2 = __mt.element.get(this.ref)
			if v2 ~= nil then
				this.value = { v1, v2 }
				__mt.element.set_callback(this.ref, function (self)
					this.value = { __mt.element.get(self) }
				end)
			else
				this.value = v1
				__mt.element.set_callback(this.ref, function (self)
					this.value = __mt.element.get(self)
				end)
			end
		end

		return setmetatable(this, methods_mt.element)
	end

	elemence.group = function (ref)
		return setmetatable({
			ref = ref, par = ref:parent(),
			__depend = { {}, {} }
		}, methods_mt.group)
	end

	elemence.dispense = function (key, ...)
		local args, ctx = {...}, elements[key]

		args.n = table.maxn(args)

		local variable, counter = (ctx and ctx.variable) and type(args[2]) == "string", 1
		args.req, args.misc = (ctx and not variable) and ctx.arg or args.n, {}

		for i = 1, args.n do
            local v = args[i]
            local kind = type(v)

			if i == 2 and ctx.variable and not variable then
				for j = 1, #v do
					v[j] = tools.format(v[j])
				end
			else
				args[i] = tools.format(v)
			end

            if kind == "userdata" and v.__name == "sol.Vector" then  args[i] = v * dpi  end

			if i > args.req then
				args.misc[counter], counter = v, counter + 1
			end
		end

		return args
	end

	elemence.memorize = function (self, path, location)
		if type(self) ~= "table" or self.__name ~= "pui::element" or self[0].skipsave then return end

		location = location or config
		local main = false
		if self[0].savable then
			dirs.pave(location, self.ref, path)
			main = true
		end

		if rawget(self, "color") then
			local pathc = table.copy(path)
			pathc[#pathc] = (main and "*" or "") .. path[#path]
			dirs.pave(location, self.color.ref, pathc)
		elseif next(self[1]) then
			local pathc, gear = table.copy(path), {}
			pathc[#pathc] = (main and "~" or "") .. path[#path]
			for k, v in next, self[1] do
				if v[0].savable and not v[0].skipsave then
					gear[k] = v.ref
					if rawget(v, "color") then gear["*"..k] = v.color.ref end
				end
			end
			dirs.pave(location, gear, pathc)
		end
	end

	elemence.features = function (self, args)
		if self[0].type == "image" or self[0].type == "value" then return end

		local had_child, had_tooltip = false, false

		for i = 1, table.maxn(args) do
			local v = args[i]
			local t = type(v)

			if not had_child and t == "function" then
				local c
				methods_mt.element.create(self)
				self[1], c = v(self[0].gear, self)
				if c ~= nil then self[0].gear:depend{self, c} end
				had_child = true

			elseif not had_child and (t == "userdata" and v.__name == "sol.ImColor") or (t == "table" and (v[1] and v[1].__name == "sol.ImColor" or v[next(v)] and v[next(v)][1].__name == "sol.ImColor")) then
				local im = t == "table"
				local g = im and v[1] or v
				local d = v[2]

				methods_mt.element.color_picker(self, g)
				if d ~= nil then self.color:depend{self, d} end
				had_child = true

			elseif not had_tooltip and t == "string" or (t == "table" and type(v[1]) == "string") then
				__mt.element.tooltip(self.ref, tools.format(v))
				had_tooltip = true
			elseif i == 2 and v == false then
				self[0].skipsave = true
			end
		end
	end

	--#region: .depend

	local cases = {
		combo = function (v)
			if v[3] == true then
				return v[1].value ~= v[2]
			else
				for i = 2, #v do
					if v[1].value == v[i] then return true end
				end
			end
			return false
		end,
		list = function (v)
			if v[3] == true then
				return v[1].value ~= v[2]
			else
				for i = 2, #v do
					if v[1].value == v[i] then return true end
				end
			end
			return false
		end,
		selectable = function (v)
			if v[2] == true then
				return #v[1].value > 0
			elseif v[3] == true then
				return not table.ihas(v[1].value, unpack(v, 2))
			else
				return table.ihas(v[1].value, unpack(v, 2))
			end
		end,
		listable = function (v)
			if v[2] == true then
				return #v[1].value > 0
			elseif v[3] == true then
				return not table.ihas(v[1].value, unpack(v, 2))
			else
				return table.ihas(v[1].value, unpack(v, 2))
			end
		end,
		slider = function (v)
			return v[2] <= v[1].value and v[1].value <= (v[3] or v[2])
		end,
	}

	local depend = function (v)
		local condition = false

		if type(v[2]) == "function" then
			condition = v[2]( v[1] )
		else
			local f = cases[v[1][0].type]
			if f then condition = f(v)
			else condition = v[1].value == v[2] end
		end

		return condition and true or false
	end

	elemence.dependant = function (__depend, dependant, disabler)
		local count = 0

		for i = 1, #__depend do
			count = count + ( depend(__depend[i]) and 1 or 0 )
		end

		local eligible = count >= #__depend
		local kind = dependant.__name == "sol.lua::LuaGroup" and "group" or "element"
		__mt[kind][disabler and "disabled" or "visibility"](dependant, ternary(disabler, not eligible, eligible))
	end

	--#endregion
end

--#endregion

-- #endregion
--


-- #endregion ------------------------------------------------------------------
--



--------------------------------------------------------------------------------
-- #region :: PUI


--
-- #region : pui

--#region: variables

pui.version = _PUIVERSION

pui.colors = {}
pui.accent, pui.alpha = ui.get_style("Link Active"), ui.get_alpha()
pui.menu_position, pui.menu_size = ui.get_position(), ui.get_size()

events.render:set(function ()
	pui.accent, pui.alpha = ui.get_style("Link Active"), ui.get_alpha()
	pui.menu_position, pui.menu_size = ui.get_position(), ui.get_size()
end)

--#endregion

--#region: features

pui.string = tools.format

pui.create = function (tab, name, align)
	if type(name) == "table" then
		local collection = {}
		for k, v in ipairs(name) do
			collection[ v[1] or k ] = elemence.group( groups[{tab, v[2], v[3]}] )
		end
		return collection
	else
		return elemence.group( groups[name and {tab, name, align} or tab] )
	end
end

pui.find = function (...)
	local arg = {...}
	local children for i, v in ipairs(arg) do
		if type(v) == "table" then
			children, arg[i] = v, nil
		break end
	end

	local found = { ui.find( unpack(arg) ) }

	for i, v in ipairs(found) do
		found[i] = elemence[v.__name == "sol.lua::LuaGroup" and "group" or "new"](v)
	end

	if found[2] and found[2].ref.__name == "sol.lua::LuaVar" then
		found[1].color, found[2] = found[2], nil
	elseif children and found[1] then
		for k, v in next, children do
			local path = {...}
			path[#path] = v
			found[1][1][k] = pui.find( unpack(path) )
		end
	end


	return found[1]
end

pui.sidebar = function (name, icon)
	name, icon = tools.format(name), icon and tools.format(icon) or nil

	ui.sidebar(name, icon)
end

pui.get_icon = function (name)
	return icons[name]
end

pui.traverse = function (t, f, p)
	p = p or {}

	if type(t) == "table" and (t.__name ~= "pui::element" and t.__name ~= "pui::group") and t[#t] ~= "~" then
		for k, v in next, t do
			local np = table.copy(p); np[#np+1] = k
			pui.traverse(v, f, np)
		end
	else
		f(t, p)
	end
end

pui.translate = function (original, translations)
	original = tools.format(original)
	for k, v in next, translations or {} do
		ui.localize(k, original, tools.format(v))
	end
	return original
end

do -- categories
	local mt = {
		create = function (self, name, align)
			return elemence.group(__mt.group.create(self[1], tools.format(name), align))
		end
	}	mt.__index = mt

	local sidebar = ui.find("Aimbot", "Anti Aim"):parent():parent()
	local cats = {}

	pui.category = function (name, tab)
		name, tab = tostring(tools.format(name)), tostring(tools.format(tab))
		local ref = contend(ui.find, function () end, name, tab)

		if not cats[name] then
			cats[name] = {}
			if not ref then cats[name][0] = sidebar:create(name) end
		end
		if not cats[name][tab] then
			if ref then cats[name][tab] = ref
			else cats[name][tab] = cats[name][0]:create(tab) end
		end

		return setmetatable({cats[name][tab]}, mt)
	end
end

pui.string_recorder = {
	open = function () stringlist = {} end,
	close = function ()
		if stringlist then
			local list, count = {}, 0
			for k, v in next, stringlist do
				count = count + 1
				list[count] = k
			end
			stringlist = nil
			return list
		end
	end
}

--#endregion

--#region: config system

do
	pui.is_loading_config, pui.is_saving_config = false, false

	local function traverse_b (t, f, p)
		p = p or {}

		if type(t) == "table" and t._S == nil then
			for k, v in next, t do
				local np = table.copy(p); np[#np+1] = k
				traverse_b(v, f, np)
			end
		else
			f(t, p)
		end
	end

	local convert = function (t)
		local new = {}
		traverse_b(t, function (v, p)
			if type(v) == "table" and v._S ~= nil then
				if v._C then
					local col = table.copy(p)
					col[#col] = "*" .. col[#col]
					dirs.pave(new, v._C, col)
					dirs.pave(new, v._S, p)
				else
					local gear = table.copy(v)
					gear._S = nil
					for gk, gv in next, gear do
						if type(gv) == "table" and gv._C then
							gear["*"..gk], gear[gk] = gv._C, gv._S
						end
					end

					local gearpath = table.copy(p)
					gearpath[#gearpath] = "~" .. gearpath[#gearpath]
					dirs.pave(new, gear, gearpath)
					dirs.pave(new, v._S, p)
				end
			else
				dirs.pave(new, v, p)
			end
		end)
		return new
	end

	local locate = function (init, arg)
		if type(arg[1]) == "table" then
			local r = {}
			for i, v in ipairs(arg) do
				local d = dirs.find(init, v)
				dirs.pave(r, d, v)
			end
			
			return r
		else
			return dirs.extract(init, arg)
		end
	end

	local save = function (location, ...)
		pui.is_saving_config = true

		local arg, packed = {...}, {}

		pui.traverse(locate(location, arg), function (ref, path)
			local etype = __mt.element.type(ref)
			local value, value2 = __mt.element[etype == "hotkey" and "key" or "get"](ref)
			local vtype, v2type = type(value), type(value2)

			if etype == "color_picker" then
				if vtype == "table" then
					value2, v2type = value, vtype
					value, vtype = __mt.element.list(ref)[1], "string"
				end

				if value2 then
					value = { value }
					if v2type == "table" then
						for i = 1, #value2 do
							value[#value+1] = "#".. value2[i]:to_hex()
						end
					else
						value[2] = "#".. value2:to_hex()
					end
					value[#value+1] = "~"
				else
					value = "#".. value:to_hex()
				end
			elseif vtype == "table" then
				value[#value+1] = "~"
			end

			dirs.pave(packed, value, path)
		end)

		pui.is_saving_config = false
		return packed
	end
	local load = function (location, data, ...)
		if not data then return end

		local arg, reset = {...}, true
		if arg[1] == false then table.remove(arg, 1); reset = false end

		pui.is_loading_config = true

		local packed = convert(locate(data, arg))
		pui.traverse(locate(location, arg), function (ref, path)
			local value = dirs.find(packed, path)

			local multicolor
			local vtype, etype = type(value), __mt.element.type(ref)
			local object = elements[etype] or elements[ref.__name]

			if etype == "color_picker" then
				if vtype == "string" and value:sub(1, 1) == "#" then
					value = color(value)
					vtype = "userdata"
				elseif vtype == "table" then
					value[#value] = nil
					for i = 2, #value do value[i] = color(value[i]) end
					multicolor = true
					vtype = "userdata"
				end
			elseif vtype == "table" and value[#value] == "~" then
				value[#value] = nil
			end

			--
			if not object or (object.type ~= "any" and object.type ~= vtype) then
				return reset and __mt.element.reset(ref) or nil
			end

			pcall(function ()
				if etype == "hotkey" then
					__mt.element.key(ref, value)
				elseif etype == "color_picker" and multicolor then
					__mt.element.set(ref, value[1])
					__mt.element.set(ref, value[1], table.range(value, 2))
				else
					__mt.element.set(ref, value)
				end
			end)
		end)

		pui.is_loading_config = false
	end

	local package_mt = {
		__type = "pui::package", __metatable = false,
		__call = function (self, raw, ...)
			return (type(raw) == "table" and load or save)(self[0], raw, ...)
		end,
		save = function (self, ...) return save(self[0], ...) end,
		load = function (self, ...) load(self[0], ...) end,
	}	package_mt.__index = package_mt

	pui.setup = function (t, isolate)
		if isolate == true then
			local package = { [0] = {} }
			pui.traverse(t, function (r, p) elemence.memorize(r, p, package[0]) end)
			return setmetatable(package, package_mt)
		else
			if is_setup then return debug.warning("config is already setup by this or another script") end
			pui.traverse(t, elemence.memorize)
			is_setup = true
			return t
		end
	end

	pui.save = function (...) return save(config, ...) end
	pui.load = function (...) load(config, ...) end
end

--#endregion

-- #endregion
--

--
-- #region : methods

methods_mt.element = {
	__metatable = false,
	__type = "pui::element", __name = "pui::element",
	__tostring = function (self) return string.format("pui::element.%s \"%s\"", self[0].type, self.ref:name()) end,
	__eq = function (a, b) return __mt.element.__eq(a.ref, b.ref) end,
	__index = function (self, key)
		return rawget(methods_mt.element, key) or rawget(__mt.wrp_element, key) or rawget(self[1], key)
	end,
	__call = function (self, ...)
		return (#{...} == 0 and __mt.element.get or __mt.element.set)(self.ref, ...)
	end,

	--

	create = function (self)
		self[0].gear = self[0].gear or elemence.group(__mt.element.create(self.ref))
		return self[0].gear
	end,

	depend = function (self, ...)
		local arg = {...}
		local disabler = arg[1] == true

		local __depend = self.__depend[disabler and 2 or 1]
		for i = disabler and 2 or 1, table.maxn(arg) do
			local v = arg[i]
			if v then
				if v.__name == "pui::element" then v = {v, true} end

				v[0] = false
				__depend[#__depend+1] = v

				local check = function () elemence.dependant(__depend, self.ref, disabler) end
				check()

				__mt.element.set_callback(v[1].ref, check)
			end
		end

		return self
	end,

	--

	name = function (self, s)
		if s then	__mt.element.name(self.ref, tools.format(s))
		else		return __mt.element.name(self.ref) end
	end,
	set_name = function (self, s)
		__mt.element.name(self.ref, tools.format(s))
	end,
	get_name = function (self)
		return __mt.element.name(self.ref)
	end,

	type = function (self) return self[0].type end,
	get_type = function (self) return self[0].type end,

	list = function (self)
		return __mt.element.list(self.ref)
	end,
	get_list = function (self)
		return __mt.element.list(self.ref)
	end,
	update = function (self, ...)
		__mt.element.update(self.ref, ...)

		if self[0].type == "list" or self[0].type == "listable" then
			local value, list = __mt.element.get(self.ref), __mt.element.list(self.ref)
			if not list then return end
			local max = #list
	
			if type(value) == "number" then
				if value > max then
					__mt.element.set(self.ref, max)
					self.value = max
				end
			else
				local id = table.ifind(list, value)
	
				if id == nil or id > max then
					__mt.element.set(self.ref, list[max])
					self.value = list[max]
				end
			end
		end
	end,

	tooltip = function (self, t)
		if t then	__mt.element.tooltip(self.ref, tools.format(t))
		else		return __mt.element.tooltip(self.ref) end
	end,
	set_tooltip = function (self, t)
		__mt.element.tooltip(self.ref, tools.format(t))
	end,
	get_tooltip = function (self)
		return __mt.element.tooltip(self.ref)
	end,

	set_visible = function (self, v)
		__mt.element.visibility(self.ref, v)
	end,
	get_visible = function (self)
		__mt.element.visibility(self.ref)
	end,

	set_disabled = function (self, v)
		__mt.element.disabled(self.ref, v)
	end,
	get_disabled = function (self)
		__mt.element.disabled(self.ref)
	end,

	get_color = function (self)
		return rawget(self, "color") and self.color.value
	end,
	color_picker = function (self, default)
		self.color = elemence.new(__mt.element.color_picker(self.ref, default))

		return self.color
	end,

	set_event = function (self, event, fn, condition)
		if condition == nil then condition = true end
		local fncond, latest = type(condition) == "function", fn

		self[0].events[fn] = function ()
			local permission

			if fncond then permission = condition(self) and true or false
			else permission = self.value == condition end

			if latest ~= permission then
				events[event](fn, permission)
				latest = permission
			end
		end
		self[0].events[fn]()
		__mt.element.set_callback(self.ref, self[0].events[fn])
	end,
	unset_event = function (self, event, fn)
		events[event].unset(events[event], fn)
		__mt.element.unset_callback(self.ref, self[0].events[fn])
		self[0].events[fn] = nil
	end,

	set_callback = function (self, fn, once)
		self[0].callbacks[fn] = function () fn(self) end
		__mt.element.set_callback(self.ref, self[0].callbacks[fn], once)
	end,
	unset_callback = function (self, fn)
		if self[0].callbacks[fn] then
			__mt.element.unset_callback(self.ref, self[0].callbacks[fn])
			self[0].callbacks[fn] = nil
		end
	end,

	override = function (self, ...)
		__mt.element.override(self.ref, ...)
	end,
	get_override = function (self)
		return __mt.element.get_override(self.ref)
	end,
}

methods_mt.group = {
	__name = "pui::group", __metatable = false,
	__index = function (self, key)
		return methods_mt.group[key] or (elements[key] and pui_mt.__index(self, key) or __mt.wrp_group[key])
	end,

	name = function (self, s, t)
		local ref = t == true and self.par or self.ref
		if s then	__mt.group.name(ref, tools.format(s))
		else		return __mt.group.name(ref) end
	end,
	set_name = function (self, s, t)
		__mt.group.name(t == true and self.par or self.ref, tools.format(s))
	end,
	get_name = function (self, t)
		return __mt.group.name(t == true and self.par or self.ref)
	end,

	disabled = function (self, b, t)
		local ref = t == true and self.par or self.ref
		if b ~= nil then   __mt.group.disabled(ref, b)
		else		return __mt.group.disabled(ref) end
	end,
	set_disabled = function (self, b, t)
		__mt.group.disabled(t == true and self.par or self.ref, b and true or false)
	end,
	get_disabled = function (self, t)
		return __mt.group.disabled(t == true and self.par or self.ref)
	end,

	set_visible = function (self, b)
		__mt.group.visibility(self.ref, b and true or false)
	end,
	get_visible = function (self)
		return __mt.group.visibility(self.ref)
	end,

	depend = methods_mt.element.depend
}

-- #endregion
--

--
-- #region : pui_mt

do
	local cached = {} for key in next, elements do
		cached[key] = function (origin, ...)
			local is_child = origin.__name == "pui::group"
			local group = is_child and origin.ref or groups[origin]

			local args = elemence.dispense(key, ...)
			local this = elemence.new( __mt.group[key]( group, unpack(args, 1, args.n < args.req and args.n or args.req) ) )

			elemence.features(this, args.misc)

			return this
		end
	end

	pui_mt.__metatable = false
	pui_mt.__name = "pui::basement"
	pui_mt.__index = function (self, key)
		if not elements[key] then return ui[key] end
		return cached[key]
	end
end

-- #endregion
--


-- #endregion ------------------------------------------------------------------
--




return setmetatable(pui, pui_mt) ---------------------------<  enQ • 1927  >----
end)()
local l_base85_0 = {}
do
    local z85_alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
    local z85_index = {}
    for i = 1, #z85_alphabet do
        z85_index[z85_alphabet:sub(i, i)] = i - 1
    end

    local function z85_encode(bytes)
        local n = #bytes
        local pad = (4 - (n % 4)) % 4
        if pad > 0 then
            bytes = bytes .. string.rep("\0", pad)
            n = n + pad
        end
        local out = {}
        local k = 1
        while k <= n do
            local v = 0
            for i = 0, 3 do
                v = v * 256 + bytes:byte(k + i)
            end
            local block = {}
            for i = 5, 1, -1 do
                local idx = v % 85
                v = math.floor(v / 85)
                block[i] = z85_alphabet:sub(idx + 1, idx + 1)
            end
            out[#out + 1] = table.concat(block)
            k = k + 4
        end
        return table.concat(out), pad
    end

    local function z85_decode(str)
        local out = {}
        local n = #str
        local k = 1
        while k <= n do
            local v = 0
            for i = 0, 4 do
                local ch = str:sub(k + i, k + i)
                local idx = z85_index[ch]
                if not idx then
                    error("invalid z85 char: " .. ch)
                end
                v = v * 85 + idx
            end
            local bytes = {}
            for i = 3, 0, -1 do
                bytes[#bytes + 1] = string.char(math.floor(v / (256 ^ i)) % 256)
            end
            out[#out + 1] = table.concat(bytes)
            k = k + 5
        end
        return table.concat(out)
    end

    local WINDOW = 4095
    local LOOKAHEAD = 18
    local MIN_MATCH = 3

    local function find_longest_match(data, pos)
        local best_len, best_off = 0, 0
        local n = #data
        local max_back = (pos - 1 < WINDOW) and (pos - 1) or WINDOW
        if max_back <= 0 then
            return 0, 0
        end
        for off = 1, max_back do
            local start = pos - off
            local len = 0
            while len < LOOKAHEAD and pos + len <= n and data:byte(start + len) == data:byte(pos + len) do
                len = len + 1
            end
            if len >= MIN_MATCH and len > best_len then
                best_len = len
                best_off = off
                if best_len == LOOKAHEAD then
                    break
                end
            end
        end
        return best_off, best_len
    end

    local function lzss_compress(data)
        local n = #data
        local i = 1
        local out = {}
        while i <= n do
            local flag_pos = #out + 1
            out[#out + 1] = "\0"
            local flag = 0
            for bit = 0, 7 do
                if i > n then
                    break
                end
                local off, len = find_longest_match(data, i)
                if len >= MIN_MATCH then
                    local high = math.floor(off / 16)
                    local low = off % 16
                    local b1 = high
                    local b2 = (low * 16) + (len - MIN_MATCH)
                    out[#out + 1] = string.char(b1, b2)
                    i = i + len
                else
                    flag = flag + 2 ^ bit
                    out[#out + 1] = string.char(data:byte(i, i))
                    i = i + 1
                end
            end
            out[flag_pos] = string.char(flag)
        end
        return table.concat(out)
    end

    local function bit_check(value, mask)
        return math.floor(value / mask) % 2 == 1
    end

    local function lzss_decompress(comp)
        local i, n = 1, #comp
        local out_buf, out_len = {}, 0
        while i <= n do
            local flag = comp:byte(i, i)
            i = i + 1
            for bit = 0, 7 do
                if i > n then
                    break
                end
                if bit_check(flag, 2 ^ bit) then
                    local ch = comp:sub(i, i)
                    i = i + 1
                    out_buf[#out_buf + 1] = ch
                    out_len = out_len + 1
                else
                    if i + 1 > n then
                        break
                    end
                    local b1 = comp:byte(i, i)
                    local b2 = comp:byte(i + 1, i + 1)
                    i = i + 2
                    local off = b1 * 16 + math.floor(b2 / 16)
                    local len = (b2 % 16) + MIN_MATCH
                    local start = out_len - off + 1
                    for k = 1, len do
                        local idx = start + k - 1
                        local ch = idx <= 0 and "\0" or out_buf[idx]
                        out_buf[#out_buf + 1] = ch
                        out_len = out_len + 1
                    end
                end
            end
        end
        return table.concat(out_buf)
    end

    function l_base85_0.encode(text)
        local compressed = lzss_compress(text)
        local L = #text
        local prefix =
            string.char(math.floor(L / 16777216) % 256, math.floor(L / 65536) % 256, math.floor(L / 256) % 256, L % 256)
        local blob = prefix .. compressed
        local z85, pad = z85_encode(blob)
        return z85 .. tostring(pad)
    end

    function l_base85_0.decode(encoded)
        local pad = tonumber(encoded:sub(-1))
        local zstr = encoded:sub(1, -2)
        local blob = z85_decode(zstr)
        if pad > 0 then
            blob = blob:sub(1, -(pad + 1))
        end
        local b1, b2, b3, b4 = blob:byte(1, 4)
        local orig_len = ((b1 * 256 + b2) * 256 + b3) * 256 + b4
        local comp = blob:sub(5)
        local decompressed = lzss_decompress(comp)
        return decompressed:sub(1, orig_len)
    end
end
local l_clipboard_0 = (function()
    local char_array = ffi.typeof 'char[?]'

local native_GetClipboardTextCount = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 7, 'int(__thiscall*)(void*)')
local native_SetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 9, 'void(__thiscall*)(void*, const char*, int)')
local native_GetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 11, 'int(__thiscall*)(void*, int, const char*, int)')

local function get()
	local len = native_GetClipboardTextCount()

	if len > 0 then
		local char_arr = char_array(len)

		native_GetClipboardText(0, char_arr, len)
		return ffi.string(char_arr, len - 1)
	end
end

local function set(...)
	local text = tostring(table.concat({ ... }))

	native_SetClipboardText(text, string.len(text))
end

return {
	set = set,
	get = get
}
end)()

-- rest of your script here
math.randomseed(math.floor(globals.realtime * 1000) + globals.framecount)
ffi.cdef(
    "    typedef struct {\n        char pad_0000[20];\n        int m_nOrder;\n        int m_nSequence;\n        float m_flPrevCycle;\n        float m_flWeight;\n        float m_flWeightDeltaRate;\n        float m_flPlaybackRate;\n        float m_flCycle;\n        void* m_pOwner;\n        char pad_0038[4];\n    } CAnimationLayer;\n    \n    typedef struct {\n        float x, y, z;\n    } vec3_t;\n"
)
local v822 =
    new_class():struct("references")(
    {
        neverlose = {
            dormant_aimbot = l_pui_0.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
            dt = l_pui_0.find(
                "Aimbot",
                "Ragebot",
                "Main",
                "Double Tap",
                {
                    lag_options = "Lag Options"
                }
            ),
            hs = l_pui_0.find(
                "Aimbot",
                "Ragebot",
                "Main",
                "Hide Shots",
                {
                    options = "Options"
                }
            ),
            peek_assist = l_pui_0.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
            aa_enabled = l_pui_0.find("Aimbot", "Ragebot", "Main", "Enabled"),
            pitch = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
            yaw = l_pui_0.find(
                "Aimbot",
                "Anti Aim",
                "Angles",
                "Yaw",
                {
                    hidden = "Hidden",
                    base = "Base",
                    offset = "Offset"
                }
            ),
            modifier = l_pui_0.find(
                "Aimbot",
                "Anti Aim",
                "Angles",
                "Yaw Modifier",
                {
                    offset = "Offset"
                }
            ),
            body = l_pui_0.find(
                "Aimbot",
                "Anti Aim",
                "Angles",
                "Body Yaw",
                {
                    options = "Options",
                    right_limit = "Right Limit",
                    left_limit = "Left Limit",
                    inverter = "Inverter",
                    freestanding = "Freestanding"
                }
            ),
            freestanding = l_pui_0.find(
                "Aimbot",
                "Anti Aim",
                "Angles",
                "Freestanding",
                {
                    disable_modifiers = "Disable Yaw Modifiers",
                    body_freestanding = "Body Freestanding"
                }
            ),
            avoid_backstab = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"),
            roll = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Extended Angles"),
            fake_duck = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
            slowwalk = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
            leg_movement = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
            scope_overlay = l_pui_0.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"),
            fake_latency = l_pui_0.find("Miscellaneous", "Main", "Other", "Fake Latency"),
            air_duck = l_pui_0.find(
                "Miscellaneous",
                "Main",
                "Movement",
                "Air Duck",
                {
                    mode = "Mode"
                }
            ),
            hit_chance = l_pui_0.find("Aimbot", "Ragebot", "Selection", "Hit Chance"),
            body_aim = l_pui_0.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
            safe_points = l_pui_0.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
            ensure_hitbox_safety = l_pui_0.find("Aimbot", "Ragebot", "Safety", "Ensure Hitbox Safety"),
            auto_stop = l_pui_0.find("Aimbot", "Ragebot", "Accuracy", "Auto Stop", "Options"),
            dt_auto_stop = l_pui_0.find("Aimbot", "Ragebot", "Accuracy", "Auto Stop", "Double Tap"),
            head_scale = l_pui_0.find("Aimbot", "Ragebot", "Selection", "Multipoint", "Head Scale"),
            body_scale = l_pui_0.find("Aimbot", "Ragebot", "Selection", "Multipoint", "Body Scale"),
            log_events = l_pui_0.find("Miscellaneous", "Main", "Other", "Log Events"),
            clan_tag = l_pui_0.find("Miscellaneous", "Main", "In-Game", "Clan Tag")
        }
    }
):struct("sidebar")(
    {
        text_length = 0,
        lua_name = "LuaSense DEV",
        init = function(v3)
            v3.text_length = #v3.lua_name
            local function v4()
                -- upvalues: v3 (ref)
                v3:render()
            end
            events.render(v4)
        end,
        pulse = function(_, v6, v7)
            local v8 = globals.realtime * (v7 or 1) % math.pi
            local v9 = math.sin(v8 + (v6 or 0))
            return math.abs(v9)
        end,
        render = function(v10)
            -- upvalues: l_pui_0 (ref)
            if l_pui_0.get_alpha() == 0 then
                return
            else
                local v11 = l_pui_0.get_style("Active Text")
                local v12 = l_pui_0.get_style("Link Active")
                local v13 = ""
                for v14 = 1, v10.text_length do
                    local v15 = v10.lua_name:sub(v14, v14)
                    local v16 = v12:lerp(v11, v10:pulse((v14 - 1) / v10.text_length * 1.5, 1))
                    v13 = v13 .. string.format("\a%s%s", v16:to_hex(), v15)
                end
                l_pui_0.sidebar(v13, "link")
                return
            end
        end
    }
):struct("notifications")(
    {
        max_cache_size = 50,
        text_cache_size = 0,
        screen_y = 0,
        cfg = {
            fade_time = 0.3,
            base_y = 350,
            start_y = -80,
            shadow = 41,
            max_width = 840,
            spacing = 16,
            max_visible = 6,
            padding = vector(16, 6)
        },
        notifications = {},
        screen = render.screen_size(),
        text_cache = {},
        cached_colors = {
            text_hex = "",
            bg_hex = "",
            shadow_hex = ""
        },
        init = function(v17)
            v17.screen_y = v17.screen.y / 2 + v17.cfg.base_y
            local function v18()
                -- upvalues: v17 (ref)
                if globals.is_in_game then
                    v17:render()
                else
                    v17.notifications = {}
                    v17.text_cache = {}
                    v17.text_cache_size = 0
                    v17.cached_colors.shadow_hex = ""
                end
            end
            local function v20(v19)
                -- upvalues: v18 (ref)
                events.render(v18, v19:get())
            end
            v17.ui.elements.notifications:set_callback(v20, true)
        end,
        lerp = function(_, v22, v23, v24)
            return v22 + (v23 - v22) * math.min(v24, 1)
        end,
        get_hex = function(v25)
            return v25.ui.elements.notifications_main_accent:get():to_hex()
        end,
        get_text_size = function(v26, v27)
            if not v26.text_cache[v27] then
                if v26.text_cache_size >= v26.max_cache_size then
                    v26.text_cache = {}
                    v26.text_cache_size = 0
                end
                v26.text_cache[v27] = render.measure_text(1, nil, v27)
                v26.text_cache_size = v26.text_cache_size + 1
            end
            return v26.text_cache[v27]
        end,
        update_color_cache = function(v28)
            local v29 = v28.ui.elements.notifications_shadow_accent:get()
            local v30 = v28.ui.elements.notifications_bg_accent:get()
            local v31 = v28.ui.elements.notifications_text_accent:get()
            local v32 = v29:to_hex()
            local v33 = v30:to_hex()
            local v34 = v31:to_hex()
            if
                v32 ~= v28.cached_colors.shadow_hex or v33 ~= v28.cached_colors.bg_hex or
                    v34 ~= v28.cached_colors.text_hex
             then
                v28.cached_colors.shadow = v29
                v28.cached_colors.bg = v30
                v28.cached_colors.text = v31
                v28.cached_colors.shadow_hex = v32
                v28.cached_colors.bg_hex = v33
                v28.cached_colors.text_hex = v34
            end
        end,
        push_notify = function(v35, v36, v37, v38)
            if not globals.is_in_game or not v35.ui.elements.notifications:get() then
                return
            else
                local l_curtime_0 = globals.curtime
                local v40 = 0
                for v41 = 1, #v35.notifications do
                    if not v35.notifications[v41].removing then
                        v40 = v40 + 1
                    end
                end
                if v35.ui.elements.notifications_limit:get() <= v40 then
                    for v42 = 1, #v35.notifications do
                        local v43 = v35.notifications[v42]
                        if not v43.removing then
                            v43.removing = true
                            break
                        end
                    end
                end
                local v44 = v35:get_text_size(v36)
                local v45 = v44.y + v35.cfg.padding.y * 2
                table.insert(
                    v35.notifications,
                    {
                        alpha = 0,
                        offset = 0,
                        removing = false,
                        text = v36,
                        time = l_curtime_0,
                        duration = v37 or 3,
                        accent = v38 or v35.ui.elements.notifications_main_accent:get(),
                        y = v35.screen_y + v35.cfg.start_y,
                        height = v45,
                        text_width = v44.x,
                        width = math.min(v44.x + v35.cfg.padding.x * 2, v35.cfg.max_width)
                    }
                )
                return
            end
        end,
        render = function(v46)
            if #v46.notifications == 0 then
                return
            else
                local l_frametime_0 = globals.frametime
                local l_curtime_1 = globals.curtime
                local l_x_0 = v46.screen.x
                local v50 = v46.ui.elements.notifications_speed:get() / 10
                local v51 = v46.ui.elements.notifications_pos_speed:get() / 10
                local v52 = v46.ui.elements.notifications_rounding:get()
                v46:update_color_cache()
                local l_screen_y_0 = v46.screen_y
                local v54 = 0
                for v55 = #v46.notifications, 1, -1 do
                    local v56 = v46.notifications[v55]
                    local v57 = l_curtime_1 - v56.time
                    if not v56.removing then
                        if v56.duration - v46.cfg.fade_time < v57 or v46.cfg.max_visible <= v54 then
                            v56.removing = true
                        else
                            v56.target_y = l_screen_y_0
                            l_screen_y_0 = l_screen_y_0 + v56.height + v46.cfg.spacing
                            v54 = v54 + 1
                        end
                    end
                    if v56.removing then
                        v56.offset = v46:lerp(v56.offset, 100, l_frametime_0 * v50 * 2)
                        v56.alpha = v46:lerp(v56.alpha, 0, l_frametime_0 * v50 * 3)
                    else
                        v56.alpha = v46:lerp(v56.alpha, 1, l_frametime_0 * v50 * 3)
                        if v56.target_y then
                            v56.y = v46:lerp(v56.y, v56.target_y, l_frametime_0 * v51)
                        end
                    end
                    if v56.alpha < 0.01 and v56.removing then
                        table.remove(v46.notifications, v55)
                    elseif v56.alpha > 0.01 then
                        local v58 = math.floor((l_x_0 - v56.width) * 0.5 + 0.5)
                        local v59 = math.floor(v56.y + v56.offset + 0.5)
                        local v60 = vector(v58, v59)
                        local v61 = vector(v56.width, v56.height)
                        local l_alpha_0 = v56.alpha
                        local v63 = l_alpha_0 * 255
                        local v64 = v46.cached_colors.shadow * l_alpha_0
                        local v65 = v46.cached_colors.bg:alpha_modulate(v63)
                        local v66 = v46.cached_colors.text:alpha_modulate(v63)
                        render.shadow(v60, v60 + v61, v64, v46.cfg.shadow, 0, v52)
                        render.rect(v60, v60 + v61, v65, v52)
                        render.text(1, v60 + v46.cfg.padding, v66, nil, v56.text)
                    end
                end
                return
            end
        end
    }
):struct("presets")(
    {
        init = function(v67)
            -- upvalues: l_pui_0 (ref)
            v67.database = db.luasense_2025_recode or {}
            v67.system_presets = {
                l_pui_0.string("\v\226\128\162  \rBrandon"),
                l_pui_0.string("\v\226\128\162  \rRxdxyxz")
            }
            v67.separator =
                l_pui_0.string(
                "\a{Small Text}\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128"
            )
            if not v67.database[l_pui_0.string("\v\226\128\162  \rBrandon")] or #v67.database == 0 then
                v67.database[l_pui_0.string("\v\226\128\162  \rBrandon")] =
                    "001[E%b#jspPOIQw=D*.Bye:1Acqh5Sa6^QzE^WnzGA15x>g=Qk(Uwev{%E$A=.b{S@^xVx(!w1%fV]:z*b=6u*?JzCwWE-.(XaZx>qH9z!9A}%6GwRC0-rLwb*E^wNxw0wPDWAvr]+{0Q0)o?!vdsC(N<%Dkab@zdds8vf2!qZJampBhC9Z7IJ^OFofx^2yxcU%88P{l1t1JCk(c4&^^:Cap4{mmmGNyoJj{&x>Ia3S+u9*%7#g+yH}KcK]7&32]Eb&v-2FKB-82lv@2B-%6YXOuU<d)wUi<IDbD=^m/?2O%ex<zxk7<.yD(xQ.MWMV0mhp4F5wK1C5I891q7rzy*Nj(.(ExT@C@M&vpS[WA(8a^0S#}Jy.znj6Oa@PXDao?we3d{zR[@n2?Zy5=UmE{vpB3^kYf}sA@Q62v}---v@hfNzEmG]xj2.-Aa9Q220/K6[)}Yw43tNwwQm{f%7MsY.M4A<xA8sIC4CMkBcDjGcLy[wC0P?Vv/Hv*ax8@(BAv6bbM:OtMqzZAwb*jJB7GA^EYE%uCv+h#B6/M1kCRj%x(pTd@0y..wN//ZU{6*$ToffJb&ArD+^sRY/i!nXv}bH?SuTzS%2z[}lpKCOvC+%pzddI%[[A10By/GizYb=[zUE=zU{oV-xjk=l3BG)@A=hgFwN}pEViiZmwDp6V&jid}Ykp$<zu[fJ01$+!fAK{Vwff80mkjMr6TXa=wNPR3x.#^(7Y.EQzF%SHx>v[C9=.Jna(JXIXxVIyuVPY}UM#msm+$SSkv![S1CcV.=ilgxx(<@W4zVQ$GtU5nPEF!6Fcb=%V1iLj^8ir}Scrf2z2E(G-fm5%x(d?Xy?i&q4dMtAP)&ce1skz!gqZr$rx8*Xz^^<*l&)E3XDQ?B3tcOeXEFi?huj)vZ^XExvrBZ91U*6pk[z]hfFC%=XDj<4z}!/F7=T(x5[d}![/zgV2OxHQzGI^AN}lglfM:&xiVY!i%3O?3k@zb3UIGw<B98Xze8UITj94}nN@-mK3/zc3zmoNZvRk-?f/x1PK48QEdO#fWfC1F&:TO%gfdjdlm*?%Sil9ZsgZx9z2uK-ly4VYSZoXcTy?W:2Cxr$$19!:9BovxWmm4w91cbDtwN)[u4VyI90H1}u0H(TXcBiTYSDhGWwNxanwNPbk/=@)bl(9#ZUMCJ>g6g/N{&mIKclLVJ^Jzh2x*livfiR}fm)F9Y=VA-yBp:Ey9E5pUVTDz0n00*(uVQ5.n]O*{G%tA8wHzC7Bv+s?p&Y]-n*L!]Vh{*5<1LCQrP:y*(bd6PpoX!q[U!={?u47coHD9MI/SO%Ds+t41*?H}3B4A*vj83)00L7YWqY<OByO#wmX$irvzcI{aW!sFgAQ0]!!9jcwIBg9riQCD?Eoz)vpK6Ray-k.RuIR9c(37>>1MePQ7}pKtfN5R3dbT@x2BI90F7j&T88uV?/Jjzw[DII(zhY=0Mh0VB*g%nb^Es}[)uMGA+O@>E}-.kBA)>&0w<6AP-RIvUMk.0jGJY?QhK#<&/Zfho+M}^UP7v(aoZt1Sb#:.v@2K^KI^){P(WKEU(F!CnE}*92rVB#ap]-UqsB]a0jh+xVi<g6n8TH{U5>ZZw&B:Gz6:Zvz5uQ%u9QBkSTMfvK]RrUAT6T&0wTZVS0q=vV86jFeMVwaU(ULxdwLi+w[F7LA$Qk<UAf5(9X]R0hp2[rbNz(6wcsoG<gCHF1st>45{l2WhxRn=amBpKamyruPDARA)&R0iGDGr)al9[lamxgK)&R0u)&R0u)&R03amyrt0uZ+L)&R0u)&R0-8{YR{amyruamyru0ZD5Y<SC7QclJ*w4<hx94?{b%1KW-44g:M(ap/O20r<ORap/O9ap/O9ap*Z903z^{4<hx94<hx94<hx94>E&papUhC?YV&3=P/.Qai#4Pai#4Paj0f$ai#4P06!^K=MyEP=MyEP=MyE$=J26kai#4Pai#4Pai#4Paj1Q6ff^=E.VJcF^bb@/19umua0qTFa0qTF9%y0)2P$iia0qTFa0qTFa0qTtarIZD1%s#}arIZFarHOaa0qTA@#-yaa0qTFa0qT9ao9C.ao9C.ao9C.ao9C.03zj.@#.m.@#.m.@#.m.@@sevao9C.ao9C.ao9C.ao9D9@#.mzfcyio]Aq}jap!G7ap/O9ap/O9ap?&*ZOy&L4<hx94<hx94<hx94<hw!u>mI&ap/O9ap/O9ap!C>)&Sb-4<hx94<hx8)&R1Gamyruamyruamyrua8@4$amz]C)&R0u)&R0u)&Q##amyruamyruamyruamye{arQ4])&R0u)&R04ZPO:<k!<GB4<hx94<hw=^?s$m0W4%/ap/O9ap/O9ap/O93lP=!ap!-24<hx94<hw.ap/BWap/O9ap/O9ap/NX4D!&4Bsnm1amyruamxsO)/.6h%bQKkamyruamxgK)&R0u))3n9)&R0u)&Q##amyru8{YR{amyruamyruk)z?+ap*Z9ap/O99V$$sap!R67*(.O4J=/7ap0D1ap/O9ap/O9ap!QH5=%f^1T1r#4<hx94<hx4))50aap/O9ap[HkaiKl#=Jwn8ai#4Pai#4Pai$8r6&u6$3lNOmaj0f$ai#5K=MyEP=P/.$=itxpai%{e=MyEP=L%5f=MyEP=MyFFkHfN0=fltYBsegwPDB+L=MA-v4*pryapO.(ap!/44<h8Uap/O9ap!-24<hw=Q7nvSu^x&9ap!C{4<hx4)&Sb-4<hw=ff^+:aiTc}=Th.P=MyEP=MyEm1K{$iJBd-@K3y@j=MyEkai#4Paj0f$uYMqPai#4PFfi8RUoh7j=MyEoff^=]yH^Yn+(w<%Bo0A]2P%T24<hjwad}A=ac:It0W0<had<TEad<TEad<TEbP&SUASEnOad1Y7PbPJ+S8vhIwPz<60C0qvamye{amyruamyru0kzqK=MyEP=MyEP=MyEP=J7Ypai#4Pai#4Pai#4Paj5<!=MyEP=MyEP+bmTsuUi.?y&*=f03w$a8>Oj!ahn]j1tp>iaf=aLE{TqPu.nB$akZB$u.mFI0xJERawVvpawTaQawTaQ6D*f]o^Q#U3)ntMPfJ[!kO39<ayul#ayul#1tp)806?5W4)QTFkoJfkkoJfQE/HPQau{#kau{#kau{#kau]&>E)wGakoJgu=MzP$)&R0vamyruamyrualT5Y=KjZ[.xovi4<hx94}2[&Pi@ffad<TEad<TEad<TEad<TE03v*PPi@fKPc6WEPbSn4P8Y$9ad<TEkyT=8aaCwZaaBnjE&<dZE&<dZE&<dZE&<duaaCwZaaCwZaaCwZaaCwZ03uXjE&<dZE&<dZE&<dZC@k%]4EdphBsXJaad(vKPi&ao4*pri@/4ga4/)y/4<hx94<hx94<hx94fXHf4*To*uK[m&ap/O9Fe^@14<hx94<hx94<gfd1%rqQaS{d{)&R0u)&R0n@&vj5@&ZPTamyruamyr])&R0u))3m.)GK^4amxgK)&R0u)&fN{)&R0u)&R2$amDvAz/Pu0u&KOQwNPvYy?2F}2RMDpxw1BfuJKoGo(CgRf:9KuH?}0VCxWFiyUo%muW-5SlVN9/v}V1IC{&-j2i/XwclJxs}mV{50*Vb^A[I?#0Ukts1CNx%2pT80BRwh11KvcemJUehpy@@]vp<6[nm=ju]vUC(zVTJLwNPMTz/cW@CvtD:{KobM8(3+UzJ<XBa{h-=w>c(MzS+CswD/msnkJ(ehuw[XB1WJ!EGfuF3"
            end
            if not v67.database[l_pui_0.string("\v\226\128\162  \rRxdxyxz")] or #v67.database == 0 then
                v67.database[l_pui_0.string("\v\226\128\162  \rRxdxyxz")] =
                    "001@)%b#jspQjzDy5-3UBzkVhB6[@VvqG:]zF5$HVU<Y6x>z6?@SdaZAaJP>jH.:1tx1GYLQJ%yc#e=@BAz8muU<rxxlg#00#(o0B]c5!1(G($xM51!yH}+}[n-8KBnH5/0B&{Cy&r$^uUay(zGG@-%jF+8DRwc>yYtIyv@#BdwQTQrFtaee2sI2XmNp3Fr6+kn?^QICax5zJBj{vm0?PKWp<3!*xN:DiwPKL]U)ie^wnc9[vR/Q@?/B{NEZe#OzdiDZBZY8[D0$]zS6*W?wuHb+41Ov{vrcc<w]zO!BF?Jrw)]*#}/G1xCxm>Ky?rTAlU{gLB7]d:Tz&h>B7GD2%7Mv&B-:IdG5s$d^t1X5l#lPaB94X}1d9>ky2r/nvpJ^SPS6gmmGsd5xLz0*u&t3Pl8Wa<wNPx2awtei14JG#w[!@617<[Vl[[^LW0&CQuUaF7A:YndBor6-P%$i6z/Z15X./?xhzE8(^5z9^vp<7TxK$Q.cZJBg6KILPqYk=OUuz0flMJ%LxAzP<0=O5tw>^h!wGSrx-SBSxe=@iW3<ajqzVsA.wImj#B-WD/uKx}Lz*czly^hZeEX}jh6vmpRBe{=p7zv]Wl]CY4{QhL)0(ewTuU4=bCwXt*wgv4!A^!6aRf3oSzf3bo%1)24fHW-^m!^pVei<@yeMuq4AVn}q9GUut7Gh?q18b}Ge@lYL9*3X[BhN*Y2{fg#.)9#*w=3BN9BJ=aAa9!4wO#16.(Uzwvj?/2CxpUDfMXu<eypqT/=ZR25:9Tf0b??gEYW^cwP@1Wz!9A}eKjFxV!][yy&r/o0axWawNxlZpZfj+zdh)Cx>7H8AkF?&sZ.rS3DQb*1q+.W&pz382vvZpoL4*TEyPXjuW3BeyZ%oCB-G+b3AVRp.Wi<MvSb.)UWIY[uUK4Tv@B{cA@(%J.MT7Tvr=Hcu/#XCT]P)UAL/25?^ZOzwNu=HA+$+:D0+SbDs+rE:GtVfvQS+Z7.DBJ.)6nExjk-^JK}%fxKI:JhM4ZuWBLCHA=i4dwc)Zf[m/cjbugvz6CFx{1iZWe4[n&sT7C^YZcY5jwmPm(107@kweFXR8.-$R5<n%]@W6)uwEbIIy*(jsuVYZ?s].#Fkw:$L.R3am))A)?z/e](hSzP-8T7)RbqI(eUoH?]BT7oLu:vOK3Ay$I0TA2Ea9}Hux(ayY7aP}6[!Izuf)&#hN/JM)E*32Y2NH?CjZ!aI178<gQ/hkDzCz32DJ7ic83V89l09QT=A4h/h:z1!+^n?k2%w!Mv&]VdzswsB4A0e]vRk&WrUblN1S6=z.t$i}Bx.0C7C#gpyEU*QXm[BaAbN+fF]:/0kHs6^kH:C:1j/=<aRF6muUmi^0{:rlDT}y6{aOf/i1CGsVTBpQ4!6Y6uVQ3w4=zwNFAZ(Y0mln+E@5?ox(<G?bjBUS!D9czJT9E=RC)Ieze:r5SuTq2mkV$.f/.N]Esq!$Aa%A7xM%gGWfR1*vrcE6AOU:-PU=V?IY:1z@Twvvvrc6<vRF5yx([R2S1wFwqu9EFeMVwaUYMD+AB%lfzf7?:k?UxCo0p<:lluhrz/klG4t4}jKyrzmS+}$Lz!rO-ZYpwnLtb</5iM#[vf8RO10&wpx>Ia3jGFK6w=Ym=U(RfrnmX+3/S$:W3ExIwwPwqdRm3R(0I*gv.(Ks(zYJ^d5%xa:L#rMG0Z=>&x^oM#x>7{/C8/zoR2Wig5u#jQ.v=7p5CG}/BIAqoxrQUjxapNRUMk.0jG)/Ort8dk3V.!LQFCF{w#wLRRuKgg^6J)!^H^w13p/sM/:dTsh6T[ldStZVCzAg5.w.CmaX%mSaX%mSaX%mSaX%mS03LbYpA-HSpA-HSpA-HSpxhLlaX%mSaX%mSaX%mSaX$uDpA-HSpA-HSpA-jflA+[.zY%3xzY%3xzY%3xyt@hozVNl[a-vu7x-Gq{p:6:2wV]F:@@shu2{xnw6cNq^E<1+k((meE9SNt.aPAO:aPAO:aPAO:aOL)raM1s0aM1s0aM1s0aM0ew?YQ/0?YQ/0?YQ/0?YQ!RaM1s0aM0-WaM1s0aM1s0Ffr.(?YQ/0?YQ/0?YQnF{^9jG@#?uqgbyWwM(=?X4<8e9?YA{v-w5RWa0hy9a0hNr1%j{}pymk(nGS{5acf&aacldX0awVipALStJ#%A8J%Xb]J@Qn.ach2ma8-lta8-lta8.c3zY-)tzY-)tzY-)tzY-($a8-lta8-lta8-lta8-ltFfeXKzY-)tzY-)tzYnfHkTaSUJ#%A8J#%A8KlN*p&SlCraaEO+aaEZA3j[qeaaEQ7a8]atE&<dZBONg7E?!npA=l8g0CC!TacdI8acdI8acdI803vmzK3r1OzY-)tzY-)tzVy>$a8-lta8-lta8-lta8.c3zY-)tzY-)tzY-)tzY-[Fa8-lta8-lta8-lta7$*ykjoOOaci2dP1=B]0Wi5[5B{>=Dflt@9Wb?T]Dw.x(iXXTQ/hkDmq:n83N4:aE/[TMaK75(aKsO9PaBkUE&#GGZC3!BaIP5laISgeaIP5l03G3wa0vf#Pcf:GPcf:GPfKJ>aFf^GaFf^GaEirRP8Z1aaFf^GaFf^GaFf^GaFeSRPcf:GPcf:GPcf:GPcfQ720(3cZAyolZAyp2ZAyn%v.Vx!0KigUZHB@!ZU/4>aPHv0?#zQlaPAO:aPHv00n)/0@#?s:%ki&0@#?tcJ@QrWaM1s05n@YGaM1s0aLlX{aM0jdaM1s0aM1s0Go4G9og*v479MEbaX@Wr03Lc8koS/CpA-HSpA-I^E*vh[aX%mJ2spVcQ9jB#zWl]na-wJm3N6Biz^}#PyT>0Wz.-FIg9HnbqI>.bz6qmSaX$AD1oyQ/v?fZsllLd%uM!kG?^WfJaM1s0aM1s0C}{J1aM0ew?:ezcZAyolZAyolZAyn>aIP5laIP5laIP5laIP5l03G30ZAyo5uM^9aZAyolZKNDwaIP5laIP5laIP5b2NA.SLqaiif^bu@?YQ/=)/jG/v^+C%v^^^{v^^^{aPzN%ZHzK3aPHN6aPAO:aPzA:@#?s:@#?s:%6*E2@#?swl9zA*aM1s05n@YGaM1s003Hew?YQ/0?YQ/0?YQ/0?Va!RaM1s0aM1s0aM1s0aM2Bb?YQ/0?YQ/0?YQRVlc/LbT04A+@#?s:@#?s:@#?swaPAO:aPAO:Q{3O$a-wJx03Mn7zY%3xzY%3xzY%3xzVy@0a-wJxa-xXiaX%mSaX@7HzY}[1pA-HSpA-HSpA-HlaX%mSaX%mSaX%mSaX@Wr03LbYpA-HSpA-HSpA-HSpy5ataX%3q3pp{tzY%3xzZV=Ea-v>d1%ETXa-wJm0rBuZa-wJxa-wJxw1K[zu)bE(@#?s:@#?t-0u?vx10EQ^@#?s:@#?s:@#?swlo=QIaM1s05n@YGaM1s003Hew?YQ/0?YQ/0?YQ/0?Va!RaM1s0aM1s0aM1s0aM2Bb?YQ/0?YQ/0?YQUYlc/JN@#?s:@#?s:%6)Y(fjMVJaPAO:aPAO:v>P0zC$we4K0eyKa-v}Xa-y<zv>W:6zY@}}qE$2.ATcU%wfFYhZAHunZAHt$lxrpZa=[D5Pco*IPcoZN2o/YKa%4[}>olC#WpH:fPd.vWa!K2/a!F)7J%3QTaUK#(aUKyRaUJ*sfcI$(fg7Z^K09s5?YQ?yaM1r)S:(!6uVf&TLo9H4{^YvozEH>4w.wyipxB0Zw:K4fKAkEEp[-uv%7lg&v}x1RA@PYVyHp)/N+oXA1fR*7o(Cg=fCT6Q73PKMCxWFiyXcj80:=1flVN9/+vth*U{YV(2i/Xw+o!tk!4L)Q0*Vb^2xFGB0Ukts1CNx%2pVoNzGPx71Kvcem!!7D4O)U7vp<6[nfqzKwtaCL1"
            end
            utils.execute_after(
                0.1,
                function()
                    -- upvalues: v67 (ref)
                    v67.ui.elements.preset_input:set("")
                    v67:update()
                    v67.ui.elements.save:set_callback(
                        function()
                            -- upvalues: v67 (ref)
                            v67:save()
                        end
                    )
                    v67.ui.elements.load:set_callback(
                        function()
                            -- upvalues: v67 (ref)
                            v67:load()
                        end
                    )
                    v67.ui.elements.delete:set_callback(
                        function()
                            -- upvalues: v67 (ref)
                            v67:delete()
                        end
                    )
                    v67.ui.elements.export:set_callback(
                        function()
                            -- upvalues: v67 (ref)
                            v67:export()
                        end
                    )
                    v67.ui.elements.import:set_callback(
                        function()
                            -- upvalues: v67 (ref)
                            v67:import()
                        end
                    )
                    v67.ui.elements.preset_list:set_callback(
                        function(v68)
                            -- upvalues: v67 (ref)
                            v67:disabler()
                            cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                            local v69 = v68:get()
                            local v70 = v68:list()[v69]
                            if v70 and v70 ~= "" and not v67:is_separator(v70) then
                                local v71 = v67:clean_name(v70)
                                v67.ui.elements.preset_input:set(v71)
                            end
                        end
                    )
                end
            )
            events.shutdown(
                function()
                    -- upvalues: v67 (ref)
                    db.luasense_2025_recode = v67.database
                end
            )
        end,
        get_preset_names = function(v72)
            local v73 = {}
            for v74 = #v72.system_presets, 1, -1 do
                table.insert(v73, 1, v72.system_presets[v74])
            end
            for v75, _ in pairs(v72.database) do
                local v77 = false
                for _, v79 in ipairs(v72.system_presets) do
                    if v79 == v75 then
                        v77 = true
                        break
                    end
                end
                if not v77 then
                    table.insert(v73, v75)
                end
            end
            return v73
        end,
        utf8_len = function(_, v81)
            local _, v83 = v81:gsub("[^\128-\193]", "")
            return v83
        end,
        clean_name = function(_, v85)
            return (v85:gsub("[%z\001-\031]", ""):gsub("{.-}", ""):gsub("[\226\128\162\226\156\166]", ""):match(
                "^%s*(.-)%s*$"
            ) or ""):gsub("^DEFAULT", ""):match("^%s*(.-)%s*$") or ""
        end,
        update = function(v86)
            local v87 = {}
            for _, v89 in ipairs(v86.system_presets) do
                v87[v89] = v89
            end
            for v90, _ in pairs(v86.database) do
                if not v87[v90] then
                    v87[v90] = v90
                end
            end
            local v92 = {}
            for v93 in pairs(v87) do
                if not v86:is_system_preset(v93) then
                    table.insert(v92, v93)
                end
            end
            table.sort(v92)
            local v94 = {}
            for _, v96 in ipairs(v86.system_presets) do
                table.insert(v94, v96)
            end
            if #v92 > 0 then
                table.insert(v94, v86.separator)
            end
            for _, v98 in ipairs(v92) do
                table.insert(v94, v98)
            end
            v86.ui.elements.preset_list:update(v94)
        end,
        is_system_preset = function(v99, v100)
            for _, v102 in ipairs(v99.system_presets) do
                if v100 == v102 then
                    return true
                end
            end
            return false
        end,
        is_separator = function(v103, v104)
            return v104 == v103.separator
        end,
        save = function(v105)
            -- upvalues: l_pui_0 (ref), l_base85_0 (ref)
            local v106 = v105.ui.elements.preset_list:get()
            local v107 = v105.ui.elements.preset_list:list()[v106]
            local v108 = v105.ui.elements.preset_input:get()
            if not v108 or v108 == "" then
                v105.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTInvalid preset name"):format(v105.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            elseif v105:utf8_len(v108) < 2 or v105:utf8_len(v108) > 20 then
                v105.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTPreset name must be between 2 and 20 characters"):format(
                        v105.notifications:get_hex()
                    ),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            elseif not (v108 ~= (v107 and v105:clean_name(v107) or "")) and v105:is_system_preset(v107) then
                v105.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTCannot modify system preset"):format(v105.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            else
                local v109 =
                    l_pui_0.setup(
                    {
                        [1] = v105.ui.elements,
                        [2] = v105.ui.builder
                    },
                    true
                )
                local v110 = l_base85_0.encode(msgpack.pack(v109:save()))
                v105.database[v108] = v110
                db.luasense_2025_recode = v105.database
                v105.notifications:push_notify(
                    ("\a%s\238\145\178  \aDEFAULTPreset saved successfully"):format(v105.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\beepclear", 1)
                v105:update()
                return
            end
        end,
        load = function(v111)
            -- upvalues: l_pui_0 (ref), l_base85_0 (ref)
            local v112 = v111.ui.elements.preset_list:get()
            local v113 = v111.ui.elements.preset_list:list()[v112]
            if not v113 or not v111.database[v113] then
                v111.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTFailed to load"):format(v111.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            else
                local v114 =
                    l_pui_0.setup(
                    {
                        [1] = v111.ui.elements,
                        [2] = v111.ui.builder
                    },
                    true
                )
                local v115 = l_base85_0.decode(v111.database[v113])
                v114:load((msgpack.unpack(v115)))
                v111.notifications:push_notify(
                    ("\a%s\238\145\178  \aDEFAULTPreset loaded successfully"):format(v111.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\beepclear", 1)
                return
            end
        end,
        delete = function(v116)
            local v117 = v116.ui.elements.preset_list:get()
            local v118 = v116.ui.elements.preset_list:list()[v117]
            if not v118 or v118 == "" then
                v116.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTInvalid name"):format(v116.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            elseif not v116.database[v118] then
                v116.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTPreset doesnt exist"):format(v116.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            elseif v116:is_system_preset(v118) then
                v116.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTCannot delete system preset"):format(v116.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            else
                v116.database[v118] = nil
                db.luasense_2025_recode = v116.database
                v116.notifications:push_notify(
                    ("\a%s\238\145\178  \aDEFAULTPreset has been deleted"):format(v116.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\beepclear", 1)
                v116:update()
                return
            end
        end,
        export = function(v119)
            -- upvalues: l_clipboard_0 (ref)
            local v120 = v119.ui.elements.preset_list:get()
            local v121 = v119.ui.elements.preset_list:list()[v120]
            if not v121 or not v119.database[v121] then
                v119.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTPreset doesnt exist"):format(v119.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            else
                l_clipboard_0.set(v119.database[v121])
                v119.notifications:push_notify(
                    ("\a%s\238\145\178  \aDEFAULTPreset has been exported to clipboard"):format(
                        v119.notifications:get_hex()
                    ),
                    3.5
                )
                cvar.playvol:call("ui\\beepclear", 1)
                return
            end
        end,
        import = function(v122)
            -- upvalues: l_clipboard_0 (ref)
            if l_clipboard_0.get() == nil then
                v122.notifications:push_notify(
                    ("\a%s\239\129\177  \aDEFAULTClipboard is empty"):format(v122.notifications:get_hex()),
                    3.5
                )
                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                return
            else
                local v123 = v122.ui.elements.preset_list:get()
                local v124 = v122.ui.elements.preset_list:list()[v123]
                if v122:is_system_preset(v124) then
                    v122.notifications:push_notify(
                        ("\a%s\239\129\177  \aDEFAULTCannot import to system preset"):format(
                            v122.notifications:get_hex()
                        ),
                        3.5
                    )
                    cvar.playvol:call("ui\\weapon_cant_buy", 1)
                    return
                else
                    v122.database[v124] = l_clipboard_0.get()
                    db.luasense_2025_recode = v122.database
                    v122.notifications:push_notify(
                        ("\a%s\238\145\178  \aDEFAULTImported successfully"):format(v122.notifications:get_hex()),
                        3.5
                    )
                    cvar.playvol:call("ui\\beepclear", 1)
                    v122:update()
                    return
                end
            end
        end,
        disabler = function(v125)
            local v126 = v125.ui.elements.preset_list:list()[v125.ui.elements.preset_list:get()]
            local v127 = {}
            for _, v129 in ipairs(v125.system_presets) do
                v127[v129] = true
            end
            local v130 = v127[v126]
            local v131 = v126 == v125.separator
            local v132 = v130 or v131
            local l_v131_0 = v131
            local l_elements_0 = v125.ui.elements
            l_elements_0.save:disabled(false)
            l_elements_0.delete:disabled(v132)
            l_elements_0.import:disabled(v132)
            l_elements_0.export:disabled(v132)
            l_elements_0.load:disabled(l_v131_0)
        end
    }
):struct("ui")(
    {
        groups = {
            general = l_pui_0.create("\v\239\147\190", "General", 1),
            presets = l_pui_0.create("\v\239\147\190", "Presets", 2),
            other = l_pui_0.create("\v\239\147\190", ""),
            options = l_pui_0.create("\v\239\131\162", "General", 1),
            builder = l_pui_0.create("\v\239\131\162", "Builder", 2),
            defensive_builder = l_pui_0.create("\v\239\131\162", "Defensive Builder"),
            import_export = l_pui_0.create("\v\239\131\162", "Builder Configurator"),
            other_general = l_pui_0.create("\v\239\130\133", "Movement", 1),
            aimbot = l_pui_0.create("\v\239\130\133", "Aimbot", 2),
            visuals = l_pui_0.create("\v\239\130\133", "Visuals"),
            other_misc = l_pui_0.create("\v\239\130\133", "Other")
        },
        e_teams = {
            [1] = "\aD9534FFF\226\128\162  \rTerrorists",
            [2] = "\a4A90E2FF\226\128\162  \rCounter-Terrorists"
        },
        e_states = {
            [1] = "\v\226\128\162  \rStanding",
            [2] = "\v\226\128\162  \rMoving",
            [3] = "\v\226\128\162  \rSlowwalk",
            [4] = "\v\226\128\162  \rCrouching",
            [5] = "\v\226\128\162  \rMove & Crouch",
            [6] = "\v\226\128\162  \rAir",
            [7] = "\v\226\128\162  \rAir & Crouch",
            [8] = "\v\226\128\162  \rManual",
            [9] = "\v\226\128\162  \rFreestanding",
            [10] = "\v\226\128\162  \rSafe Head",
            [11] = "\v\226\128\162  \rWeapon Swap"
        },
        init = function(v135)
            -- upvalues: l_pui_0 (ref), l_base85_0 (ref), l_clipboard_0 (ref)
            local l_general_0 = v135.groups.general
            local l_presets_0 = v135.groups.presets
            local l_other_0 = v135.groups.other
            local l_options_0 = v135.groups.options
            local l_builder_0 = v135.groups.builder
            local l_defensive_builder_0 = v135.groups.defensive_builder
            local l_visuals_0 = v135.groups.visuals
            local l_import_export_0 = v135.groups.import_export
            local l_other_general_0 = v135.groups.other_general
            local l_aimbot_0 = v135.groups.aimbot
            local l_other_misc_0 = v135.groups.other_misc
            v135.elements = {
                username = l_general_0:label("\v\239\128\135  \r" .. 'gift from brandon for fans' .. " \aEB6161FF[Developer]"),
                config_name = l_general_0:label(
                    "\t\v\194\187  \rConfig name: \a{Small Text}" .. common.get_config_name() .. ""
                ),
                config_author = l_general_0:label(
                    "\t\v\194\187  \rConfig author: \a{Small Text}" .. common.get_config_author() .. ""
                ),
                author_username = l_general_0:label("\v\239\136\155  \rcutegirlgamer \a{Small Text}"),
                author_scripts = l_general_0:label("\t\v\194\187  \rScripts:"),
                luasense = l_general_0:button(
                    "Luasense",
                    function()
                        cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                        panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://market.neverlose.cc/luasense")
                    end,
                    true
                ),
                luasense_beta = l_general_0:button(
                    "Luasense Beta",
                    function()
                        cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                        panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://market.neverlose.cc/byAMx1")
                    end,
                    true
                ),
                author_configs = l_general_0:label("\t\v\194\187  \rGrenade helper:"),
                nade_locations = l_general_0:button(
                    "Locations",
                    function()
                        cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                        panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://market.neverlose.cc/2umdLR")
                    end,
                    true
                ),
                preset_list = l_presets_0:list("", {}),
                preset_input = l_presets_0:input("", "Config"),
                load = l_presets_0:button(
                    "    \v\239\128\140    ",
                    nil,
                    true,
                    "Load\n\n\a{Small Text}Loads the selected preset."
                ),
                import = l_presets_0:button(
                    "    \v\239\149\175    ",
                    nil,
                    true,
                    "Import\n\n\a{Small Text}Imports settings from the clipboard and immediately saves them to the selected preset \226\128\148 no need to press the save button afterward."
                ),
                export = l_presets_0:button(
                    "    \v\239\149\174    ",
                    nil,
                    true,
                    "Export\n\n\a{Small Text}Exports settings from the selected preset to the clipboard."
                ),
                save = l_presets_0:button(
                    "    \a4CAF50FF\239\131\135    ",
                    nil,
                    true,
                    "Save\n\n\a{Small Text}Saves the selected preset, or creates a new one if none is selected."
                ),
                delete = l_presets_0:button(
                    "     \226\128\138\aF44336FF\239\139\173\226\128\138     ",
                    nil,
                    true,
                    "Delete\n\n\a{Small Text}Deletes the selected preset permanently with no way to recover it."
                ),
                discord_label = l_other_0:label("Get help and chat with our community"),
                discord_button = l_other_0:button("\a5865F2FF\239\142\146", nil, true),
                hide_shots = l_options_0:combo(
                    "\v\226\128\162  \rHide Shots  \a{Small Text}\239\147\152",
                    v135.references.neverlose.hs.options:list()
                ),
                disable_extra_states = l_options_0:selectable(
                    "\v\226\128\162  \rDisable States",
                    "\v\226\128\162  \rManual",
                    "\v\226\128\162  \rFreestanding",
                    "\v\226\128\162  \rWeapon Swap"
                ),
                safe_head = l_options_0:selectable(
                    "\v\226\128\162  \rSafe Head  \a{Small Text}\239\160\172",
                    "\v\226\128\162  \rStanding",
                    "\v\226\128\162  \rMoving",
                    "\v\226\128\162  \rCrouching",
                    "\v\226\128\162  \rMove & Crouch",
                    "\v\226\128\162  \rAir & Crouch",
                    "\v\226\128\162  \rAir & Crouch Knife/Zeus",
                    "\v\226\128\162  \rCrouch & Knife/Zeus",
                    "\v\226\128\162  \rMove & Crouch & Knife/Zeus",
                    "\v\226\128\162  \rSlowwalk"
                ),
                tweaks = l_options_0:selectable(
                    "\v\226\128\162  \rTweaks  \a{Small Text}\239\130\133",
                    "\v\226\128\162  \rWarmup",
                    "\v\226\128\162  \rNo Enemies"
                ),
                avoid_backstab = l_options_0:switch("\v\226\128\162  \rAvoid Backstab  \a{Small Text}\239\156\156"),
                animations = l_options_0:label("\v\226\128\162  \rAnimations  \a{Small Text}\239\160\183"),
                hotkeys = l_options_0:label("\v\226\128\162  \rHotkeys  \a{Small Text}\239\131\134"),
                teams = l_builder_0:combo("\v\226\128\162  \rTeam  \a{Small Text}\239\148\128", v135.e_teams),
                states = l_builder_0:combo("\v\226\128\162  \rState  \a{Small Text}\239\131\128", v135.e_states),
                watermark = l_visuals_0:switch("\v\226\128\162  \rWatermark  \a{Small Text}\239\143\133"),
                notifications = l_visuals_0:switch("\v\226\128\162  \rNotifications  \a{Small Text}\239\148\191", true),
                side_indicators = l_visuals_0:switch("\v\226\128\162  \rSide Indicators  \a{Small Text}\238\144\180"),
                slowed_down_indicator = l_visuals_0:switch(
                    "\v\226\128\162  \rSlowed Down Indicator  \a{Small Text}\239\152\173"
                ),
                scope_overlay = l_visuals_0:switch("\v\226\128\162  \rCustom Scope Overlay  \a{Small Text}\238\128\190"),
                keep_transparency = l_visuals_0:switch(
                    "\v\226\128\162  \rKeep Model Transparency  \a{Small Text}\238\145\191"
                ),
                aspect_ratio = l_visuals_0:label("\v\226\128\162  \rAspect Ratio  \a{Small Text}\239\151\181"),
                viewmodel = l_visuals_0:label("\v\226\128\162  \rViewmodel  \a{Small Text}\239\137\150"),
                manual_arrows = l_visuals_0:switch("\v\226\128\162  \rManual Arrows  \a{Small Text}\238\146\186"),
                hitmarkers = l_aimbot_0:selectable(
                    "\v\226\128\162  \rHitmarkers  \a{Small Text}\239\150\161",
                    "\v\226\128\162  \rScreen",
                    "\v\226\128\162  \rWorld"
                ),
                unlock_fake_latency = l_aimbot_0:switch(
                    "\v\226\128\162  \rUnlock Fake Latency  \a{Small Text}\238\138\176"
                ),
                magic_key = l_aimbot_0:switch("\v\226\128\162  \rMagic Key  \a{Small Text}\239\162\144"),
                damage_indicator = l_aimbot_0:switch(
                    "\v\226\128\162  \rDamage Override Indicator  \a{Small Text}\238\144\156"
                ),
                avoid_fall_damage = l_other_general_0:switch(
                    "\v\226\128\162  \rAvoid Fall Damage  \a{Small Text}\238\149\135"
                ),
                fast_ladder = l_other_general_0:switch("\v\226\128\162  \rFast Ladder  \a{Small Text}\239\151\133"),
                avoid_collisions = l_other_general_0:switch(
                    "\v\226\128\162  \rAvoid Collisions  \a{Small Text}\238\143\155"
                ),
                fake_duck = l_aimbot_0:label("\v\226\128\162  \rFake Duck  \a{Small Text}\239\155\152"),
                log_events = l_other_misc_0:selectable(
                    "\v\226\128\162  \rLog Events  \a{Small Text}\238\145\178",
                    "\v\226\128\162  \rAimbot Shots",
                    "\v\226\128\162  \rPurchases"
                ),
                clan_tag_spammer = l_other_misc_0:switch(
                    "\v\226\128\162  \rClan Tag Spammer  \a{Small Text}\239\148\135"
                )
            }
            local l_elements_1 = v135.elements
            local v148 = l_elements_1.tweaks:create()
            l_elements_1.tweaks_pitch =
                v148:combo("\v\226\128\186  \rPitch", "Disabled", "Down", "Up"):depend(l_elements_1.tweaks)
            l_elements_1.tweaks_mode =
                v148:combo("\v\226\128\186  \rYaw", "Spin", "Distortion"):depend(l_elements_1.tweaks)
            l_elements_1.tweaks_range =
                v148:slider("\t\a{Small Text}\194\187  Range", 1, 180, 180, nil, "\194\176"):depend(l_elements_1.tweaks)
            l_elements_1.tweaks_speed =
                v148:slider("\t\a{Small Text}\194\187  Speed", 1, 10, 1, nil, "t"):depend(l_elements_1.tweaks)
            local v149 = l_elements_1.animations:create()
            l_elements_1.animations_interpolating =
                v149:slider(
                "\v\226\128\186  \rInterpolating  \a{Small Text}\239\135\139",
                0,
                14,
                0,
                nil,
                function(v150)
                    if v150 == 0 then
                        return "Default"
                    elseif v150 == 9 then
                        return "Medium"
                    elseif v150 == 14 then
                        return "High"
                    else
                        return v150 .. "t"
                    end
                end
            )
            l_elements_1.animations_leaning =
                v149:slider(
                "\v\226\128\186  \rLeaning  \a{Small Text}\239\134\131",
                0,
                100,
                0,
                0.01,
                function(v151)
                    if v151 == 0 then
                        return "Default"
                    elseif v151 == 35 then
                        return "Small"
                    elseif v151 == 50 then
                        return "Medium"
                    elseif v151 == 75 then
                        return "High"
                    elseif v151 == 100 then
                        return "Extreme"
                    else
                        return v151 .. "%"
                    end
                end
            )
            l_elements_1.animations_earthquake =
                v149:switch("\t\a{Small Text}\194\187  Earthquake"):depend(
                {
                    [1] = nil,
                    [2] = 1,
                    [3] = 100,
                    [1] = l_elements_1.animations_leaning
                }
            )
            l_elements_1.animations_falling =
                v149:slider(
                "\v\226\128\186  \rFalling  \a{Small Text}\238\149\134",
                0,
                100,
                0,
                0.01,
                function(v152)
                    if v152 == 0 then
                        return "Default"
                    elseif v152 == 50 then
                        return "Force"
                    elseif v152 == 100 then
                        return "Maximum"
                    else
                        return v152 .. "%"
                    end
                end
            )
            l_elements_1.animations_jitter_legs =
                v149:switch("\v\226\128\186  \rJitter Legs  \a{Small Text}\239\156\140")
            local v153 = l_elements_1.hotkeys:create()
            l_elements_1.hotkeys_freestanding = v153:switch("\v\226\128\186  \rFreestanding")
            l_elements_1.hotkeys_disablers =
                v153:selectable(
                "\t\a{Small Text}\194\187  Disablers",
                {
                    [1] = "\v\226\128\162  \rStanding",
                    [2] = "\v\226\128\162  \rMoving",
                    [3] = "\v\226\128\162  \rSlowwalk",
                    [4] = "\v\226\128\162  \rCrouching",
                    [5] = "\v\226\128\162  \rMove & Crouch",
                    [6] = "\v\226\128\162  \rAir",
                    [7] = "\v\226\128\162  \rAir & Crouch"
                }
            )
            l_elements_1.hotkeys_manual_yaw =
                v153:combo("\v\226\128\186  \rManuals", "Disabled", "Left", "Right", "Forward")
            local v154 = l_elements_1.watermark:create()
            l_elements_1.watermark_options = v154:label("\v\226\128\186  \rOptions"):depend(l_elements_1.watermark)
            l_elements_1.watermark_button =
                v154:button("  \aF44336FF\239\128\145  Reset Position  ", nil, true):depend(l_elements_1.watermark)
            l_elements_1.watermark_x =
                v154:slider("x", 0, render.screen_size().x, render.screen_size().x / 2):visibility(false)
            l_elements_1.watermark_y =
                v154:slider("y", 0, render.screen_size().y, render.screen_size().y - 20):visibility(false)
            l_elements_1.watermark_font =
                v154:combo("\t\a{Small Text}\194\187  Font", "Default", "Pixel", "Console", "Bold"):depend(
                l_elements_1.watermark
            )
            l_elements_1.watermark_style =
                v154:combo("\t\a{Small Text}\194\187  Style", "Classic", "Luasync", "Star"):depend(
                l_elements_1.watermark
            )
            l_elements_1.watermark_colors = v154:label("\v\226\128\186  \rColors"):depend(l_elements_1.watermark)
            l_elements_1.watermark_button2 =
                v154:button("  \aF44336FF\239\128\145  Reset  ", nil, true):depend(l_elements_1.watermark)
            l_elements_1.watermark_main_accent =
                v154:color_picker("\t\a{Small Text}\194\187  Label", color(255, 255, 255, 255)):depend(
                {
                    [1] = nil,
                    [2] = "Classic",
                    [3] = true,
                    [1] = l_elements_1.watermark_style
                },
                l_elements_1.watermark
            )
            l_elements_1.watermark_prefix_accent =
                v154:color_picker("\t\a{Small Text}\194\187  Prefix", color(150, 200, 60, 255)):depend(
                l_elements_1.watermark
            )
            l_elements_1.watermark_postfix_accent =
                v154:color_picker("\t\a{Small Text}\194\187  Postfix", color(235, 97, 97, 255)):depend(
                l_elements_1.watermark
            )
            l_elements_1.watermark_button:set_callback(
                function()
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.watermark_x:reset()
                    l_elements_1.watermark_y:reset()
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end
            )
            l_elements_1.watermark_button2:set_callback(
                function()
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.watermark_main_accent:reset()
                    l_elements_1.watermark_prefix_accent:reset()
                    l_elements_1.watermark_postfix_accent:reset()
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end
            )
            local v155 = l_elements_1.notifications:create()
            l_elements_1.notifications_options =
                v155:label("\v\226\128\186  \rOptions"):depend(l_elements_1.notifications)
            l_elements_1.notifications_button =
                v155:button("  \aF44336FF\239\128\145  Reset  ", nil, true):depend(l_elements_1.notifications)
            l_elements_1.notifications_speed =
                v155:slider("\t\a{Small Text}\194\187  Speed", 1, 100, 60, nil, "%"):depend(l_elements_1.notifications)
            l_elements_1.notifications_pos_speed =
                v155:slider("\t\a{Small Text}\194\187  Position Speed", 1, 100, 40, nil, "%"):depend(
                l_elements_1.notifications
            )
            l_elements_1.notifications_limit =
                v155:slider("\t\a{Small Text}\194\187  Limit", 1, 6, 4):depend(l_elements_1.notifications)
            l_elements_1.notifications_rounding =
                v155:slider("\t\a{Small Text}\194\187  Rounding", 0, 20, 14):depend(l_elements_1.notifications)
            l_elements_1.notifications_colors =
                v155:label("\v\226\128\186  \rColors"):depend(l_elements_1.notifications)
            l_elements_1.notifications_button2 =
                v155:button("  \aF44336FF\239\128\145  Reset  ", nil, true):depend(l_elements_1.notifications)
            l_elements_1.notifications_main_accent =
                v155:color_picker("\t\a{Small Text}\194\187  Accent", color(150, 200, 60, 255)):depend(
                l_elements_1.notifications
            )
            l_elements_1.notifications_bg_accent =
                v155:color_picker("\t\a{Small Text}\194\187  Background", color(22, 22, 22, 255)):depend(
                l_elements_1.notifications
            )
            l_elements_1.notifications_text_accent =
                v155:color_picker("\t\a{Small Text}\194\187  Text", color(245, 245, 245, 255)):depend(
                l_elements_1.notifications
            )
            l_elements_1.notifications_shadow_accent =
                v155:color_picker("\t\a{Small Text}\194\187  Shadow", color(150, 200, 60, 255)):depend(
                l_elements_1.notifications
            )
            l_elements_1.notifications_button:set_callback(
                function()
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.notifications_speed:reset()
                    l_elements_1.notifications_pos_speed:reset()
                    l_elements_1.notifications_limit:reset()
                    l_elements_1.notifications_rounding:reset()
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end
            )
            l_elements_1.notifications_button2:set_callback(
                function()
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.notifications_main_accent:reset()
                    l_elements_1.notifications_bg_accent:reset()
                    l_elements_1.notifications_text_accent:reset()
                    l_elements_1.notifications_shadow_accent:reset()
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end
            )
            local v156 = l_elements_1.aspect_ratio:create()
            l_elements_1.aspect_ratio_label = v156:label("\v\239\130\133  \rChoose a preset or set your ratio.")
            l_elements_1.aspect_ratio_slider =
                v156:slider(
                "",
                50,
                300,
                177,
                0.01,
                function(v157)
                    if v157 == 177 then
                        return "16:9"
                    elseif v157 == 161 then
                        return "16:10"
                    elseif v157 == 150 then
                        return "3:2"
                    elseif v157 == 133 then
                        return "4:3"
                    elseif v157 == 125 then
                        return "5:4"
                    else
                        return tostring(v157 / 100)
                    end
                end
            )
            l_elements_1.aspect_ratio_preset_16_10 = v156:button("  16:10  ", nil, true)
            l_elements_1.aspect_ratio_preset_16_9 = v156:button("  16:9  ", nil, true)
            l_elements_1.aspect_ratio_preset_5_4 = v156:button("  5:4  ", nil, true)
            l_elements_1.aspect_ratio_preset_4_3 = v156:button("  4:3  ", nil, true)
            l_elements_1.aspect_ratio_preset_3_2 = v156:button("  3:2  ", nil, true)
            l_elements_1.aspect_ratio_preset_16_10:set_callback(
                function(_)
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.aspect_ratio_slider:set(161)
                    cvar.playvol:call("ui\\beepclear", 1)
                end
            )
            l_elements_1.aspect_ratio_preset_16_9:set_callback(
                function(_)
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.aspect_ratio_slider:set(177)
                    cvar.playvol:call("ui\\beepclear", 1)
                end
            )
            l_elements_1.aspect_ratio_preset_5_4:set_callback(
                function(_)
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.aspect_ratio_slider:set(125)
                    cvar.playvol:call("ui\\beepclear", 1)
                end
            )
            l_elements_1.aspect_ratio_preset_4_3:set_callback(
                function(_)
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.aspect_ratio_slider:set(133)
                    cvar.playvol:call("ui\\beepclear", 1)
                end
            )
            l_elements_1.aspect_ratio_preset_3_2:set_callback(
                function(_)
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.aspect_ratio_slider:set(150)
                    cvar.playvol:call("ui\\beepclear", 1)
                end
            )
            l_elements_1.aspect_ratio_slider:set_callback(
                function(v163)
                    cvar.r_aspectratio:float(v163:get() / 100, true)
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end,
                true
            )
            cvar.r_aspectratio:set_callback(
                function(v164)
                    -- upvalues: l_elements_1 (ref)
                    if math.abs(v164:float() - l_elements_1.aspect_ratio_slider:get() / 100) < 1.0E-5 then
                        return
                    else
                        v164:float(l_elements_1.aspect_ratio_slider:get() / 100, true)
                        return
                    end
                end
            )
            local v165 = l_elements_1.viewmodel:create()
            l_elements_1.viewmodel_options = v165:label("\v\226\128\186  \rOptions")
            l_elements_1.viewmodel_button = v165:button("  \aF44336FF\239\128\145  Reset  ", nil, true)
            l_elements_1.viewmodel_fov = v165:slider("\t\a{Small Text}\194\187  Field of View", -100, 100, 68, 1)
            l_elements_1.viewmodel_axis_x = v165:slider("\t\a{Small Text}\194\187  X Axis", -150, 150, 0, 0.1)
            l_elements_1.viewmodel_axis_y = v165:slider("\t\a{Small Text}\194\187  Y Axis", -150, 150, 0, 0.1)
            l_elements_1.viewmodel_axis_z = v165:slider("\t\a{Small Text}\194\187  Z Axis", -150, 150, 0, 0.1)
            l_elements_1.viewmodel_hands =
                v165:combo("\v\226\128\186  \rType", "\v\226\128\162  \rRight", "\v\226\128\162  \rLeft")
            l_elements_1.viewmodel_bob = v165:switch("\v\226\128\186  \rCS:S Bob Animation")
            l_elements_1.viewmodel_lock = v165:switch("\v\226\128\186  \rLock Bob")
            l_elements_1.viewmodel_button:set_callback(
                function()
                    -- upvalues: l_elements_1 (ref)
                    l_elements_1.viewmodel_fov:reset()
                    l_elements_1.viewmodel_axis_x:reset()
                    l_elements_1.viewmodel_axis_y:reset()
                    l_elements_1.viewmodel_axis_z:reset()
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1)
                end
            )
            l_elements_1.viewmodel_fov:set_callback(
                function(v166)
                    cvar.viewmodel_fov:float(v166:get(), true)
                end,
                true
            )
            l_elements_1.viewmodel_axis_x:set_callback(
                function(v167)
                    cvar.viewmodel_offset_x:float(v167:get() / 10, true)
                end,
                true
            )
            l_elements_1.viewmodel_axis_y:set_callback(
                function(v168)
                    cvar.viewmodel_offset_y:float(v168:get() / 10, true)
                end,
                true
            )
            l_elements_1.viewmodel_axis_z:set_callback(
                function(v169)
                    cvar.viewmodel_offset_z:float(v169:get() / 10, true)
                end,
                true
            )
            l_elements_1.viewmodel_bob:set_callback(
                function(v170)
                    cvar.cl_use_new_headbob:int(v170:get() and 0 or 1)
                end,
                true
            )
            l_elements_1.viewmodel_lock:set_callback(
                function(v171)
                    cvar.cl_bob_lower_amt:float(v171:get() and 5 or 21)
                    cvar.cl_bobamt_lat:float(v171:get() and 0.1 or 0.4)
                    cvar.cl_bobamt_vert:float(v171:get() and 0.1 or 0.25)
                    cvar.cl_bobcycle:float(v171:get() and 2 or 0.98)
                end,
                true
            )
            l_elements_1.viewmodel_hands:set_callback(
                function(v172)
                    -- upvalues: l_pui_0 (ref)
                    cvar.cl_righthand:int(v172:get() == l_pui_0.string("\v\226\128\162  \rLeft") and 0 or 1)
                end,
                true
            )
            l_elements_1.viewmodel_bob:depend(
                {
                    [1] = nil,
                    [2] = false,
                    [1] = l_elements_1.viewmodel_lock
                }
            )
            l_elements_1.viewmodel_lock:depend(
                {
                    [1] = nil,
                    [2] = false,
                    [1] = l_elements_1.viewmodel_bob
                }
            )
            local v173 = l_elements_1.avoid_collisions:create()
            l_elements_1.avoid_collisions_distance =
                v173:slider("\v\226\128\186  \rDistance", 1, 16, 8):depend(l_elements_1.avoid_collisions)
            l_elements_1.avoid_collisions_disable_on_crouch =
                v173:switch("\v\226\128\186  \rDisable on Crouch"):depend(l_elements_1.avoid_collisions)
            local v174 = l_elements_1.fake_duck:create()
            l_elements_1.fake_duck_speed = v174:switch("\v\226\128\186  \rUnlock Speed")
            l_elements_1.fake_duck_freezetime = v174:switch("\v\226\128\186  \rOn Freeze Time")
            local v175 = l_elements_1.side_indicators:create()
            l_elements_1.side_indicators_indicators =
                v175:listable(
                "\v\f<gears>  \rChoose side indicators to be shown.",
                {
                    [1] = "PING",
                    [2] = "Double Tap",
                    [3] = "Hide Shots",
                    [4] = "Damage",
                    [5] = "Hitchance",
                    [6] = "Fake Duck",
                    [7] = "Body Aim",
                    [8] = "Safe Points",
                    [9] = "Dormant Aimbot",
                    [10] = "Freestanding",
                    [11] = "Bomb Info"
                }
            ):depend(l_elements_1.side_indicators)
            l_elements_1.side_indicators_spectator_list =
                v175:switch("\v\226\128\186  \rSpectator List"):depend(l_elements_1.side_indicators)
            l_elements_1.log_events_accent =
                l_elements_1.log_events:color_picker(color(150, 200, 60, 255)):depend(l_elements_1.log_events)
            local v176 = l_elements_1.scope_overlay:create()
            l_elements_1.scope_overlay_options =
                v176:label("\v\226\128\186  \rOptions"):depend(l_elements_1.scope_overlay)
            l_elements_1.scope_overlay_size =
                v176:slider("\t\a{Small Text}\194\187  Size", 10, 300, 200):depend(l_elements_1.scope_overlay)
            l_elements_1.scope_overlay_gap =
                v176:slider("\t\a{Small Text}\194\187  Gap", 1, 300, 10):depend(l_elements_1.scope_overlay)
            l_elements_1.scope_overlay_rotated =
                v176:switch("\t\a{Small Text}\194\187  Rotated"):depend(l_elements_1.scope_overlay)
            l_elements_1.scope_overlay_colors =
                v176:label("\v\226\128\186  \rColors"):depend(l_elements_1.scope_overlay)
            l_elements_1.scope_overlay_main_accent =
                v176:color_picker("\t\a{Small Text}\194\187  Main", color(255, 255, 255, 160)):depend(
                l_elements_1.scope_overlay
            )
            l_elements_1.scope_overlay_edge_accent =
                v176:color_picker("\t\a{Small Text}\194\187  Edge", color(0, 0, 0, 0)):depend(
                l_elements_1.scope_overlay
            )
            local v177 = l_elements_1.hitmarkers:create()
            l_elements_1.hitmarkers_screen_label =
                v177:label("\v\226\128\186  \rScreen"):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rScreen")
                }
            )
            l_elements_1.hitmarkers_screen_accent =
                v177:color_picker("\t\a{Small Text}\194\187  Accent", color()):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rScreen")
                }
            )
            l_elements_1.hitmarkers_screen_duration =
                v177:slider(
                "\t\a{Small Text}\194\187  Duration",
                1,
                20,
                1,
                nil,
                function(v178)
                    return v178 * 0.5 .. "s"
                end
            ):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rScreen")
                }
            )
            l_elements_1.hitmarkers_world_label =
                v177:label("\v\226\128\186  \rWorld"):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rWorld")
                }
            )
            l_elements_1.hitmarkers_world_accent =
                v177:color_picker(
                "\t\a{Small Text}\194\187  Accent ",
                {
                    Simple = {
                        color(255, 0, 0, 155)
                    },
                    Double = {
                        color(0, 255, 255, 255),
                        color(0, 255, 0, 255)
                    }
                }
            ):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rWorld")
                }
            )
            l_elements_1.hitmarkers_world_duration =
                v177:slider(
                "\t\a{Small Text}\194\187  Duration ",
                1,
                20,
                1,
                nil,
                function(v179)
                    return v179 * 0.5 .. "s"
                end
            ):depend(
                {
                    l_elements_1.hitmarkers,
                    l_pui_0.string("\v\226\128\162  \rWorld")
                }
            )
            local v180 = l_elements_1.slowed_down_indicator:create()
            l_elements_1.slowed_down_x =
                v180:slider("x", 0, render.screen_size().x, render.screen_size().x / 2):visibility(false)
            l_elements_1.slowed_down_y =
                v180:slider("y", 0, render.screen_size().y, render.screen_size().y * 0.25):visibility(false)
            l_elements_1.slowed_down_accent =
                l_elements_1.slowed_down_indicator:color_picker(color(150, 200, 60, 255)):depend(
                l_elements_1.slowed_down_indicator
            )
            local v181 = l_elements_1.manual_arrows:create()
            l_elements_1.manaul_arrows_yaw_accent =
                v181:color_picker("\v\226\128\186  \rYaw Accent", color(175, 255, 0, 255)):depend(
                l_elements_1.manual_arrows
            )
            l_elements_1.manaul_arrows_body_accent =
                v181:color_picker("\v\226\128\186  \rBody Accent", color(0, 200, 255, 255)):depend(
                l_elements_1.manual_arrows
            )
            l_elements_1.unlock_fake_latency:set_callback(
                function(v182)
                    cvar.sv_maxunlag:float(v182:get() and 0.4 or 0.2)
                end,
                true
            )
            l_elements_1.avoid_backstab:set_callback(
                function(v183)
                    -- upvalues: v135 (ref)
                    v135.references.neverlose.avoid_backstab:set(v183:get())
                end,
                true
            )
            v135.builder = {}
            v135.builder.force_break_lc = l_defensive_builder_0:selectable("\v\226\128\162  \rForce on", v135.e_states)
            for v184, v185 in ipairs(v135.e_states) do
                v135.builder[v184] = {}
                do
                    local l_v184_0 = v184
                    for v187, v188 in ipairs(v135.e_teams) do
                        v135.builder[l_v184_0][v187] = {}
                        local l_states_0 = l_elements_1.states
                        local l_teams_0 = l_elements_1.teams
                        v135.builder[l_v184_0][v187].yaw_mode =
                            l_builder_0:combo("\v\239\129\188  \rYaw", "1-Way", "2-Way"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = l_states_0,
                                [2] = function(v191)
                                    -- upvalues: l_pui_0 (ref)
                                    return v191.value ~= l_pui_0.string("\v\226\128\162  \rManual")
                                end
                            }
                        )
                        local v192 = v135.builder[l_v184_0][v187].yaw_mode:create()
                        v135.builder[l_v184_0][v187].yaw_offset =
                            v192:slider("\v\226\128\186  \rOffset", -180, 180, 0, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "1-Way",
                                [1] = v135.builder[l_v184_0][v187].yaw_mode
                            }
                        )
                        v135.builder[l_v184_0][v187].left_offset =
                            v192:slider("\v\226\128\186  \rLeft Offset", -180, 180, 0, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "2-Way",
                                [1] = v135.builder[l_v184_0][v187].yaw_mode
                            }
                        )
                        v135.builder[l_v184_0][v187].right_offset =
                            v192:slider("\v\226\128\186  \rRight Offset", -180, 180, 0, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "2-Way",
                                [1] = v135.builder[l_v184_0][v187].yaw_mode
                            }
                        )
                        v135.builder[l_v184_0][v187].variability =
                            v192:slider("\t\a{Small Text}\194\187  Variability", 0, 100, 0, nil, "%"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            }
                        )
                        v135.builder[l_v184_0][v187].delay =
                            v192:slider(
                            "\v\226\128\186  \rDelay",
                            1,
                            20,
                            1,
                            nil,
                            function(v193)
                                if v193 == 1 then
                                    return "Off"
                                else
                                    return v193 .. "t"
                                end
                            end
                        ):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "2-Way",
                                [1] = v135.builder[l_v184_0][v187].yaw_mode
                            }
                        )
                        v135.builder[l_v184_0][v187].delay_variability =
                            v192:slider("\t\a{Small Text}\194\187  Variability ", 0, 100, 0, nil, "%"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "2-Way",
                                [1] = v135.builder[l_v184_0][v187].yaw_mode
                            },
                            {
                                [1] = nil,
                                [2] = 2,
                                [3] = 20,
                                [1] = v135.builder[l_v184_0][v187].delay
                            }
                        )
                        v135.builder[l_v184_0][v187].variability:tooltip(
                            "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                        )
                        v135.builder[l_v184_0][v187].delay_variability:tooltip(
                            "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                        )
                        v135.builder[l_v184_0][v187].modifier =
                            l_builder_0:combo(
                            "\v\239\129\188  \rModifier",
                            "Disabled",
                            "Offset",
                            "Center",
                            "Random",
                            "Spin",
                            "3-Way",
                            "5-Way"
                        ):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            }
                        )
                        v192 = v135.builder[l_v184_0][v187].modifier:create()
                        v135.builder[l_v184_0][v187].modifier_offset =
                            v192:slider("\v\226\128\186  \rOffset", -180, 180, 0, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "Disabled",
                                [3] = true,
                                [1] = v135.builder[l_v184_0][v187].modifier
                            }
                        )
                        v135.builder[l_v184_0][v187].modifier_variability =
                            v192:slider("\t\a{Small Text}\194\187  Variability", 0, 100, 0, nil, "%"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = "Disabled",
                                [3] = true,
                                [1] = v135.builder[l_v184_0][v187].modifier
                            }
                        )
                        v135.builder[l_v184_0][v187].modifier_variability:tooltip(
                            "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                        )
                        v135.builder[l_v184_0][v187].body =
                            l_builder_0:switch("\v\239\129\188  \rBody"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            }
                        )
                        v192 = v135.builder[l_v184_0][v187].body:create()
                        v135.builder[l_v184_0][v187].body_label =
                            v192:label("\v\226\128\186  \rBody"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].body_delay =
                            v192:slider(
                            "\t\a{Small Text}\194\187  Switch Delay",
                            0,
                            20,
                            0,
                            nil,
                            function(v194)
                                if v194 == 0 then
                                    return "Off"
                                else
                                    return v194 .. "t"
                                end
                            end
                        ):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].body_variability =
                            v192:slider("\t\a{Small Text}\194\187  Variability", 0, 100, 0, nil, "%"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = 1,
                                [3] = 20,
                                [1] = v135.builder[l_v184_0][v187].body_delay
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].body_variability:tooltip(
                            "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                        )
                        v135.builder[l_v184_0][v187].body_freestanding =
                            v192:combo("\t\a{Small Text}\194\187  Freestanding", "Off", "Default", "Reversed"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_label =
                            v192:label("\v\226\128\186  \rLimit"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_delay =
                            v192:slider(
                            "\t\a{Small Text}\194\187  Delay",
                            0,
                            20,
                            0,
                            nil,
                            function(v195)
                                if v195 == 0 then
                                    return "Off"
                                else
                                    return v195 .. "t"
                                end
                            end
                        ):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_left =
                            v192:slider("\t\a{Small Text}\194\187  Left", 0, 60, 60, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = 0,
                                [1] = v135.builder[l_v184_0][v187].limit_delay
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_right =
                            v192:slider("\t\a{Small Text}\194\187  Right", 0, 60, 60, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = 0,
                                [1] = v135.builder[l_v184_0][v187].limit_delay
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_variability =
                            v192:slider("\t\a{Small Text}\194\187  Variability ", 0, 100, 0, nil, "%"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_variability:tooltip(
                            "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                        )
                        v135.builder[l_v184_0][v187].limit_leftright =
                            v192:slider("\t\a{Small Text}\194\187  L&R [1]", 0, 60, 30, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = 1,
                                [3] = 20,
                                [1] = v135.builder[l_v184_0][v187].limit_delay
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].limit_leftright2 =
                            v192:slider("\t\a{Small Text}\194\187  L&R [2]", 0, 60, 60, nil, "\194\176"):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = nil,
                                [2] = 1,
                                [3] = 20,
                                [1] = v135.builder[l_v184_0][v187].limit_delay
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].body_options =
                            v192:selectable("\v\226\128\186  \rOptions", v135.references.neverlose.body.options:list()):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            v135.builder[l_v184_0][v187].body
                        )
                        v135.builder[l_v184_0][v187].rotated =
                            l_builder_0:combo(
                            "\v\238\134\135  \rRotated",
                            {
                                [1] = "Static",
                                [2] = "Jitter"
                            }
                        ):depend(
                            {
                                [1] = l_states_0,
                                [2] = v185
                            },
                            {
                                [1] = l_teams_0,
                                [2] = v188
                            },
                            {
                                [1] = l_states_0,
                                [2] = function(v196)
                                    -- upvalues: l_pui_0 (ref)
                                    return v196.value == l_pui_0.string("\v\226\128\162  \rFreestanding")
                                end
                            }
                        )
                        v192 = v135.builder[l_v184_0][v187].rotated:create()
                        do
                            local l_v187_0 = v187
                            v135.builder[l_v184_0][l_v187_0].send =
                                l_builder_0:button(
                                "  \226\128\138\v\239\129\164 \rSend to the opposite side   ",
                                function()
                                    -- upvalues: l_v187_0 (ref), l_pui_0 (ref), v135 (ref), l_v184_0 (ref)
                                    local v198 = l_v187_0 == 1 and 2 or 1
                                    local v199 =
                                        l_pui_0.setup(
                                        {
                                            [1] = v135.ui.builder[l_v184_0][l_v187_0]
                                        },
                                        true
                                    ):save()
                                    l_pui_0.setup(
                                        {
                                            [1] = v135.ui.builder[l_v184_0][v198]
                                        },
                                        true
                                    ):load(v199)
                                    v135.notifications:push_notify(
                                        ("\a%s\238\145\178  \a%sSuccessfully \aDEFAULTsent settings to the \a%sopposite \aDEFAULTteam."):format(
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex()
                                        ),
                                        3.5
                                    )
                                    cvar.playvol:call("ui\\beepclear", 1)
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            ):tooltip("Sends builder and defensive settings to the opposite team.")
                            v135.builder[l_v184_0][l_v187_0].copy =
                                l_builder_0:button(
                                " \v\239\131\133 ",
                                function()
                                    -- upvalues: l_pui_0 (ref), v135 (ref), l_v184_0 (ref), l_v187_0 (ref), l_base85_0 (ref), l_clipboard_0 (ref)
                                    local v200 =
                                        l_pui_0.setup(
                                        {
                                            [1] = v135.ui.builder[l_v184_0][l_v187_0]
                                        },
                                        true
                                    )
                                    local v201 = l_base85_0.encode(msgpack.pack(v200:save()))
                                    l_clipboard_0.set(v201)
                                    v135.notifications:push_notify(
                                        ("\a%s\238\145\178  \aDEFAULTSettings \a%scopied \aDEFAULTto clipboard \a%ssuccessfully\aDEFAULT!"):format(
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex()
                                        ),
                                        3.5
                                    )
                                    cvar.playvol:call("ui\\beepclear", 1)
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            ):tooltip("Copies builder and defensive settings to the clipboard.")
                            v135.builder[l_v184_0][l_v187_0].paste =
                                l_builder_0:button(
                                " \v\239\131\170 ",
                                function()
                                    -- upvalues: l_pui_0 (ref), v135 (ref), l_v184_0 (ref), l_v187_0 (ref), l_base85_0 (ref), l_clipboard_0 (ref)
                                    local v202 =
                                        l_pui_0.setup(
                                        {
                                            [1] = v135.ui.builder[l_v184_0][l_v187_0]
                                        },
                                        true
                                    )
                                    local v203 = l_base85_0.decode(l_clipboard_0.get())
                                    v202:load((msgpack.unpack(v203)))
                                    v135.notifications:push_notify(
                                        ("\a%s\238\145\178  \aDEFAULTSettings \a%spasted \aDEFAULTfrom clipboard \a%ssuccessfully\aDEFAULT!"):format(
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex(),
                                            v135.notifications:get_hex()
                                        ),
                                        3.5
                                    )
                                    cvar.playvol:call("ui\\beepclear", 1)
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            ):tooltip("Pastes builder and defensive settings from the clipboard.")
                            v135.builder[l_v184_0][l_v187_0].preset_names = {}
                            v135.builder[l_v184_0][l_v187_0].take_from_preset =
                                l_import_export_0:combo(
                                "\v\226\128\162  \rFrom Preset",
                                v135.builder[l_v184_0][l_v187_0].preset_names
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].take_from_preset:set_callback(
                                function(v204)
                                    -- upvalues: v135 (ref), l_v184_0 (ref), l_v187_0 (ref)
                                    table.insert(
                                        v135.builder[l_v184_0][l_v187_0].preset_names,
                                        v135.presets:get_preset_names()
                                    )
                                    v204:update(v135.presets:get_preset_names())
                                end,
                                true
                            )
                            v135.builder[l_v184_0][l_v187_0].take_from_team =
                                l_import_export_0:combo("\v\226\128\162  \rFrom Team", v135.e_teams):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].take_from_state =
                                l_import_export_0:combo("\v\226\128\162  \rFrom State", v135.e_states):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].apply =
                                l_import_export_0:button(
                                "   \v\239\128\140  \rApply   ",
                                function()
                                    -- upvalues: v135 (ref), l_v184_0 (ref), l_v187_0 (ref), l_base85_0 (ref)
                                    local v205 = v135.builder[l_v184_0][l_v187_0].take_from_preset:get()
                                    local v206 = v135.builder[l_v184_0][l_v187_0].take_from_team:get()
                                    local v207 = v135.builder[l_v184_0][l_v187_0].take_from_state:get()
                                    if not v205 or not v135.presets.database[v205] then
                                        v135.notifications:push_notify(
                                            ("\a%s\239\129\177  \aDEFAULTPreset not found"):format(
                                                v135.notifications:get_hex()
                                            ),
                                            3.5
                                        )
                                        cvar.playvol:call("ui\\weapon_cant_buy", 1)
                                        return
                                    else
                                        local v208 = v135.builder[l_v184_0][l_v187_0]
                                        v135.builder[l_v184_0][l_v187_0].previous_settings = {
                                            yaw_mode = v208.yaw_mode:get(),
                                            yaw_offset = v208.yaw_offset:get(),
                                            left_offset = v208.left_offset:get(),
                                            right_offset = v208.right_offset:get(),
                                            variability = v208.variability:get(),
                                            delay = v208.delay:get(),
                                            delay_variability = v208.delay_variability:get(),
                                            modifier = v208.modifier:get(),
                                            modifier_offset = v208.modifier_offset:get(),
                                            modifier_variability = v208.modifier_variability:get(),
                                            body = v208.body:get(),
                                            body_delay = v208.body_delay:get(),
                                            body_variability = v208.body_variability:get(),
                                            body_freestanding = v208.body_freestanding:get(),
                                            body_options = v208.body_options:get(),
                                            limit_delay = v208.limit_delay:get(),
                                            limit_left = v208.limit_left:get(),
                                            limit_right = v208.limit_right:get(),
                                            limit_variability = v208.limit_variability:get(),
                                            limit_leftright = v208.limit_leftright:get(),
                                            limit_leftright2 = v208.limit_leftright2:get(),
                                            tickbase = v208.tickbase:get(),
                                            ticks = v208.ticks:get(),
                                            ticks_variability = v208.ticks_variability:get()
                                        }
                                        local v209 = v135.presets.database[v205]
                                        local v210 = l_base85_0.decode(v209)
                                        local v211 = msgpack.unpack(v210)
                                        local v212 = 1
                                        for v213, v214 in ipairs(v135.ui.e_teams) do
                                            if v214 == v206 then
                                                v212 = v213
                                                break
                                            end
                                        end
                                        local v215 = 1
                                        for v216, v217 in ipairs(v135.ui.e_states) do
                                            if v217 == v207 then
                                                v215 = v216
                                                break
                                            end
                                        end
                                        if not v211 or not v211[2] then
                                            v135.notifications:push_notify(
                                                ("\a%s\239\129\177  \aDEFAULTPreset data is corrupted"):format(
                                                    v135.notifications:get_hex()
                                                ),
                                                3.5
                                            )
                                            cvar.playvol:call("ui\\weapon_cant_buy", 1)
                                            return
                                        else
                                            local v218 = nil
                                            if v211[2][v215] and v211[2][v215][v212] then
                                                v218 = v211[2][v215][v212]
                                            elseif v211[2][v212] and v211[2][v212][v215] then
                                                v218 = v211[2][v212][v215]
                                            else
                                                v135.notifications:push_notify(
                                                    ("\a%s\239\129\177  \aDEFAULTNo data found"):format(
                                                        v135.notifications:get_hex()
                                                    ),
                                                    3.5
                                                )
                                                cvar.playvol:call("ui\\weapon_cant_buy", 1)
                                                return
                                            end
                                            local v219 = {
                                                [1] = "yaw_mode",
                                                [2] = "yaw_offset",
                                                [3] = "left_offset",
                                                [4] = "right_offset",
                                                [5] = "variability",
                                                [6] = "delay",
                                                [7] = "delay_variability",
                                                [8] = "modifier",
                                                [9] = "modifier_offset",
                                                [10] = "modifier_variability",
                                                [11] = "body",
                                                [12] = "body_delay",
                                                [13] = "body_variability",
                                                [14] = "body_freestanding",
                                                [15] = "body_options",
                                                [16] = "limit_delay",
                                                [17] = "limit_left",
                                                [18] = "limit_right",
                                                [19] = "limit_variability",
                                                [20] = "limit_leftright",
                                                [21] = "limit_leftright2",
                                                [22] = "tickbase",
                                                [23] = "ticks",
                                                [24] = "ticks_variability"
                                            }
                                            for _, v221 in ipairs(v219) do
                                                if
                                                    v218[v221] ~= nil and v208[v221] and
                                                        type(v208[v221].set) == "function"
                                                 then
                                                    v208[v221]:set(v218[v221])
                                                end
                                            end
                                            v135.notifications:push_notify(
                                                ("\a%s\238\145\178  \aDEFAULTSettings applied! \a%s(Undo available)"):format(
                                                    v135.notifications:get_hex(),
                                                    v135.notifications:get_hex()
                                                ),
                                                5
                                            )
                                            cvar.playvol:call("ui\\beepclear", 1)
                                            return
                                        end
                                    end
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].undo =
                                l_import_export_0:button(
                                "   \aF44336FF\239\162\149  \rUndo   ",
                                function()
                                    -- upvalues: v135 (ref), l_v184_0 (ref), l_v187_0 (ref)
                                    if not v135.builder[l_v184_0][l_v187_0].previous_settings then
                                        v135.notifications:push_notify(
                                            ("\a%s\239\129\177  \aDEFAULTNothing to undo"):format(
                                                v135.notifications:get_hex()
                                            ),
                                            2
                                        )
                                        cvar.playvol:call("ui\\weapon_cant_buy", 1)
                                        return
                                    else
                                        local v222 = v135.builder[l_v184_0][l_v187_0]
                                        local l_previous_settings_0 = v135.builder[l_v184_0][l_v187_0].previous_settings
                                        for v224, v225 in pairs(l_previous_settings_0) do
                                            if v222[v224] and type(v222[v224].set) == "function" then
                                                v222[v224]:set(v225)
                                            end
                                        end
                                        v135.builder[l_v184_0][l_v187_0].previous_settings = nil
                                        v135.notifications:push_notify(
                                            ("\a%s\238\145\178  \aDEFAULTSettings \a%sreverted \aDEFAULTsuccessfully!"):format(
                                                v135.notifications:get_hex(),
                                                v135.notifications:get_hex()
                                            ),
                                            3
                                        )
                                        cvar.playvol:call("ui\\beepclear", 1)
                                        return
                                    end
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].update =
                                l_import_export_0:button(
                                "   \v\239\128\161  \rRefresh   ",
                                function()
                                    -- upvalues: v135 (ref), l_v184_0 (ref), l_v187_0 (ref)
                                    v135.builder[l_v184_0][l_v187_0].take_from_preset:update(
                                        v135.presets:get_preset_names()
                                    )
                                    cvar.playvol:call("ui\\beepclear", 1)
                                end,
                                true
                            ):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                }
                            )
                            v135.builder[l_v184_0][l_v187_0].tickbase =
                                l_defensive_builder_0:switch("\v\226\128\162  \rCustom ticks"):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                },
                                {
                                    [1] = v135.builder.force_break_lc,
                                    [2] = v185
                                }
                            )
                            v192 = v135.builder[l_v184_0][l_v187_0].tickbase:create()
                            v135.builder[l_v184_0][l_v187_0].ticks =
                                v192:slider("\v\226\128\186  \rChoke", 3, 22, math.random(15, 16), nil, "t"):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                },
                                {
                                    [1] = v135.builder.force_break_lc,
                                    [2] = v185
                                },
                                v135.builder[l_v184_0][l_v187_0].tickbase
                            )
                            v135.builder[l_v184_0][l_v187_0].ticks_variability =
                                v192:slider("\t\a{Small Text}\194\187  Variability", 0, 100, 0, nil, "%"):depend(
                                {
                                    [1] = l_states_0,
                                    [2] = v185
                                },
                                {
                                    [1] = l_teams_0,
                                    [2] = v188
                                },
                                {
                                    [1] = v135.builder.force_break_lc,
                                    [2] = v185
                                },
                                v135.builder[l_v184_0][l_v187_0].tickbase
                            )
                            v135.builder[l_v184_0][l_v187_0].ticks_variability:tooltip(
                                "Automatically generates optimal patterns.\n\nHigher \226\128\148 more unpredictable.\n\n\a{Small Text}Replaces outdated multi slider config with smart distribution algorithm."
                            )
                        end
                    end
                end
            end
            v135.builder.disable_on =
                l_defensive_builder_0:selectable(
                "\v\226\128\162  \rDisable on",
                "\v\226\128\162  \rGrenade",
                "\v\226\128\162  \rPeek Assist"
            )
        end
    }
):struct("states")(
    {
        manual = 8,
        is_in_air = false,
        slowwalk = 3,
        post_fs = 12,
        swap = 11,
        safe = 10,
        freestand = 9,
        move = 2,
        air = 6,
        move_duck = 5,
        duck = 4,
        stand = 1,
        air_duck = 7,
        cache = {
            state = 1,
            tick = 0,
            team = 1
        },
        init = function(v226)
            events.createmove(
                function(v227)
                    -- upvalues: v226 (ref)
                    local v228 = entity.get_local_player()
                    if v228 then
                        v226.is_in_air = v227.in_jump or bit.band(v228.m_fFlags, 1) == 0
                    end
                end
            )
        end,
        get_sequence_activity = function(_)
            local v230 = entity.get_local_player():get_anim_overlay(1)
            local l_activity_0 = v230.activity
            local _ = v230.sequence
            return l_activity_0, v230.weight
        end,
        height = function(_)
            local v234 = entity.get_local_player()
            local v235 = entity.get_threat(false)
            if not v235 then
                return false
            else
                local v236 = v235:get_origin()
                return v234:get_origin().z - 35 > v236.z + 0
            end
        end,
        get_state = function(v237, v238)
            local v239, v240 = v237:get_sequence_activity()
            local l_elements_2 = v237.ui.elements
            if not l_elements_2.disable_extra_states:get(1) and l_elements_2.hotkeys_manual_yaw:get() ~= "Disabled" then
                return v237.manual
            elseif
                not l_elements_2.disable_extra_states:get(2) and l_elements_2.hotkeys_freestanding:get() and
                    v237.references.neverlose.freestanding:get()
             then
                if rage.antiaim:get_target(true) ~= nil then
                    return v237.post_fs
                else
                    return v237.freestand
                end
            elseif not l_elements_2.disable_extra_states:get(3) and v237.is_in_air and v239 == 972 and v240 > 0.1 then
                return v237.swap
            else
                local l_m_fFlags_0 = v238.m_fFlags
                local v243 = bit.band(l_m_fFlags_0, 4) == 4
                local v244 = v238.m_vecVelocity:length()
                local v245 = nil
                if v237.is_in_air then
                    v245 = v243 and v237.air_duck or v237.air
                elseif v244 > 3 then
                    if v243 then
                        v245 = v237.move_duck
                    else
                        v245 = v237.references.neverlose.slowwalk:get() and v237.slowwalk or v237.move
                    end
                else
                    v245 = v243 and v237.duck or v237.stand
                end
                local l_safe_head_0 = l_elements_2.safe_head
                if
                    not l_safe_head_0:get(1) and not l_safe_head_0:get(2) and not l_safe_head_0:get(3) and
                        not l_safe_head_0:get(4) and
                        not l_safe_head_0:get(5) and
                        not l_safe_head_0:get(6) and
                        not l_safe_head_0:get(7) and
                        not l_safe_head_0:get(8)
                 then
                    return v245
                else
                    local v247 = false
                    local v248 = v238:get_player_weapon()
                    if v248 then
                        local v249 = v248:get_classname()
                        v247 = v249 == "CKnife" or v249 == "CWeaponTaser"
                    end
                    if
                        l_safe_head_0:get(1) and v245 == v237.stand and v237:height() or
                            l_safe_head_0:get(2) and v245 == v237.move and v237:height() or
                            l_safe_head_0:get(3) and v245 == v237.duck and v237:height() or
                            l_safe_head_0:get(4) and v245 == v237.move_duck and v237:height() or
                            l_safe_head_0:get(9) and v245 == v237.slowwalk and v237:height()
                     then
                        return v237.safe
                    else
                        if v245 == v237.air_duck then
                            if l_safe_head_0:get(5) then
                                return v237.safe
                            elseif l_safe_head_0:get(6) and v247 then
                                return v237.safe
                            end
                        end
                        if l_safe_head_0:get(7) and v245 == v237.duck and v247 then
                            return v237.safe
                        elseif l_safe_head_0:get(8) and v245 == v237.move_duck and v247 then
                            return v237.safe
                        else
                            return v245
                        end
                    end
                end
            end
        end,
        default = function(v250, v251)
            local l_tickcount_0 = globals.tickcount
            if v250.cache.tick == l_tickcount_0 then
                return v250.cache.state, v250.cache.team
            else
                local v253 = v251.m_iTeamNum == 2 and 1 or 2
                local v254 = v250:get_state(v251) or v250.stand
                v250.cache.tick = l_tickcount_0
                v250.cache.state = v254
                v250.cache.team = v253
                return v254, v253
            end
        end,
        disablers = function(v255, v256)
            local v257 = v256.m_vecVelocity:length()
            local v258 = bit.band(v256.m_fFlags, 4) == 4
            local l_stand_0 = v255.stand
            if v255.is_in_air then
                l_stand_0 = v258 and v255.air_duck or v255.air
            elseif v257 > 3 then
                l_stand_0 =
                    v258 and v255.move_duck or v255.references.neverlose.slowwalk:get() and v255.slowwalk or v255.move
            else
                l_stand_0 = v258 and v255.duck or v255.stand
            end
            return l_stand_0
        end
    }
):struct("antiaim")(
    {
        state_cache_idx = 0,
        max_angle_variation = 15,
        flippers = {
            yaw = {
                state = false,
                packets = 0,
                last_flip = 0
            },
            body = {
                state = false,
                packets = 0,
                last_flip = 0
            },
            limit = {
                state = false,
                packets = 0,
                last_flip = 0
            }
        },
        discrete_delays = {
            [1] = 1,
            [2] = 3,
            [3] = 5,
            [4] = 7,
            [5] = 10,
            [6] = 15,
            [7] = 20
        },
        fs_map = {
            Off = "Off",
            Default = "Peek Fake",
            Reversed = "Peek Real"
        },
        init = function(v260)
            events.createmove(
                function(v261)
                    -- upvalues: v260 (ref)
                    v260:override(v261)
                end
            )
        end,
        find_closest = function(v262, v263)
            local v264 = 1
            local l_huge_0 = math.huge
            local l_discrete_delays_0 = v262.discrete_delays
            for v267 = 1, #l_discrete_delays_0 do
                local v268 = math.abs(v263 - l_discrete_delays_0[v267])
                if v268 < l_huge_0 then
                    local l_v267_0 = v267
                    l_huge_0 = v268
                    v264 = l_v267_0
                end
            end
            return v264
        end,
        get_random_delay = function(v270, v271, v272)
            if v271 <= 1 or v272 <= 0 then
                return v271
            else
                local v273 = v270:find_closest(v271)
                local v274 = #v270.discrete_delays
                local v275 = math.floor(v274 * v272 / 200 + 0.5)
                local v276 = math.max(1, v273 - v275)
                local v277 = math.min(v274, v273 + v275)
                return v270.discrete_delays[math.random(v276, v277)]
            end
        end,
        update_flipper = function(v278, v279, v280, v281)
            local v282 = v278.flippers[v279]
            if globals.choked_commands == 0 then
                v282.packets = v282.packets + 1
                local _ = nil
                if
                    (rage.exploit:get() < 1 and 1 or v281 and v278:get_random_delay(v280, v281) or v280) <=
                        v282.packets - v282.last_flip
                 then
                    v282.state = not v282.state
                    v282.last_flip = v282.packets
                end
            end
            return v282.state
        end,
        add_variation = function(v284, v285, v286, v287, v288)
            if v286 <= 0 then
                return v285
            else
                local v289 = v285 + (math.random() * 2 - 1) * v284.max_angle_variation * (v286 / 100)
                if v287 and v288 then
                    v289 = math.min(math.max(v289, v287), v288)
                end
                return v289
            end
        end,
        override = function(v290, _)
            local v292 = entity.get_local_player()
            if not v292 or not v292:is_alive() then
                return
            else
                local l_neverlose_0 = v290.references.neverlose
                if not l_neverlose_0.aa_enabled:get() then
                    return
                else
                    l_neverlose_0.pitch:override("Down")
                    l_neverlose_0.yaw:override("Backward")
                    l_neverlose_0.yaw.base:override("At Target")
                    l_neverlose_0.yaw.hidden:override(false)
                    l_neverlose_0.roll:override(false)
                    l_neverlose_0.freestanding.disable_modifiers:override(true)
                    l_neverlose_0.freestanding.body_freestanding:override(false)
                    local v294, v295 = v290.states:default(v292)
                    if v294 == 12 then
                        l_neverlose_0.yaw.offset:override(0)
                        l_neverlose_0.modifier:override("Disabled")
                        l_neverlose_0.modifier.offset:override(0)
                        l_neverlose_0.body:override(true)
                        l_neverlose_0.body.left_limit:override(60)
                        l_neverlose_0.body.right_limit:override(60)
                        if v290.ui.builder[9][v295].rotated:get() == "Jitter" then
                            l_neverlose_0.body.options:override("Jitter")
                        else
                            l_neverlose_0.body.options:override("")
                        end
                        l_neverlose_0.body.freestanding:override("Off")
                        return
                    else
                        if v294 ~= v290.state_cache_idx then
                            v290.state_cache = v290.ui.builder[v294][v295]
                            v290.state_cache_idx = v294
                        end
                        local l_state_cache_0 = v290.state_cache
                        local v297 = nil
                        if l_state_cache_0.yaw_mode:get() == "1-Way" then
                            v297 =
                                v290:add_variation(
                                l_state_cache_0.yaw_offset:get(),
                                l_state_cache_0.variability:get(),
                                -180,
                                180
                            )
                        else
                            local v298 =
                                v290:update_flipper(
                                "yaw",
                                l_state_cache_0.delay:get(),
                                l_state_cache_0.delay_variability:get()
                            )
                            rage.antiaim:inverter(v298)
                            v297 =
                                v290:add_variation(
                                v298 and l_state_cache_0.left_offset:get() or l_state_cache_0.right_offset:get(),
                                l_state_cache_0.variability:get(),
                                -180,
                                180
                            )
                        end
                        local v299 = l_state_cache_0.modifier:get()
                        local v300 =
                            v299 ~= "Disabled" and
                            v290:add_variation(
                                l_state_cache_0.modifier_offset:get(),
                                l_state_cache_0.modifier_variability:get(),
                                -180,
                                180
                            ) or
                            0
                        local v301 = false
                        local v302 = 0
                        local v303 = 0
                        if l_state_cache_0.body:get() then
                            local v304 = l_state_cache_0.body_delay:get()
                            v301 =
                                v304 == 0 or v290:update_flipper("body", v304, l_state_cache_0.body_variability:get())
                            if l_state_cache_0.limit_delay:get() == 0 then
                                v302 =
                                    v290:add_variation(
                                    l_state_cache_0.limit_left:get(),
                                    l_state_cache_0.limit_variability:get(),
                                    0,
                                    60
                                )
                                v303 =
                                    v290:add_variation(
                                    l_state_cache_0.limit_right:get(),
                                    l_state_cache_0.limit_variability:get(),
                                    0,
                                    60
                                )
                            else
                                local v305 =
                                    v290:update_flipper(
                                    "limit",
                                    l_state_cache_0.limit_delay:get(),
                                    l_state_cache_0.limit_variability:get()
                                )
                                v302 =
                                    v305 and l_state_cache_0.limit_leftright:get() or
                                    l_state_cache_0.limit_leftright2:get()
                                v303 =
                                    v305 and l_state_cache_0.limit_leftright:get() or
                                    l_state_cache_0.limit_leftright2:get()
                            end
                        end
                        if
                            v290.ui.elements.hotkeys_freestanding:get() and
                                not v290.ui.elements.hotkeys_disablers:get(v290.states:disablers(v292))
                         then
                            l_neverlose_0.freestanding:set(true)
                        else
                            l_neverlose_0.freestanding:set(false)
                        end
                        if v290.ui.elements.hotkeys_manual_yaw:get() ~= "Disabled" then
                            local v306 = {
                                Forward = 180,
                                Right = 90,
                                Left = -90
                            }
                            if v306[v290.ui.elements.hotkeys_manual_yaw:get()] then
                                v297 = v306[v290.ui.elements.hotkeys_manual_yaw:get()]
                                l_neverlose_0.yaw.base:override("Local View")
                                l_neverlose_0.freestanding:override(false)
                            end
                        end
                        l_neverlose_0.yaw.offset:override(v297)
                        l_neverlose_0.modifier:override(v299)
                        l_neverlose_0.modifier.offset:override(v300)
                        l_neverlose_0.body:override(v301)
                        l_neverlose_0.body.left_limit:override(v302)
                        l_neverlose_0.body.right_limit:override(v303)
                        l_neverlose_0.body.options:override(l_state_cache_0.body_options:get())
                        l_neverlose_0.body.freestanding:override(v290.fs_map[l_state_cache_0.body_freestanding:get()])
                        return
                    end
                end
            end
        end
    }
):struct("defensive")(
    {
        state_cache_idx = 0,
        discrete_ticks = {
            [1] = 2,
            [2] = 4,
            [3] = 6,
            [4] = 8,
            [5] = 10,
            [6] = 12,
            [7] = 14,
            [8] = 16,
            [9] = 18,
            [10] = 20,
            [11] = 22
        },
        init = function(v307)
            events.createmove(
                function(v308)
                    -- upvalues: v307 (ref)
                    v307:override(v308)
                end
            )
        end,
        find_closest_tick = function(v309, v310)
            local v311 = 1
            local l_huge_1 = math.huge
            local l_discrete_ticks_0 = v309.discrete_ticks
            for v314 = 1, #l_discrete_ticks_0 do
                local v315 = math.abs(v310 - l_discrete_ticks_0[v314])
                if v315 < l_huge_1 then
                    local l_v314_0 = v314
                    l_huge_1 = v315
                    v311 = l_v314_0
                end
            end
            return v311
        end,
        get_random_tick = function(v317, v318, v319)
            if v318 <= 2 or v319 <= 0 then
                return v318
            else
                local v320 = v317:find_closest_tick(v318)
                local v321 = #v317.discrete_ticks
                local v322 = math.floor(v321 * v319 / 200 + 0.5)
                local v323 = math.max(1, v320 - v322)
                local v324 = math.min(v321, v320 + v322)
                return v317.discrete_ticks[math.random(v323, v324)]
            end
        end,
        get_sequence_activity = function(_)
            local v326 = entity.get_local_player():get_anim_overlay(1)
            local l_activity_1 = v326.activity
            local _ = v326.sequence
            return l_activity_1, v326.weight
        end,
        override = function(v329, v330)
            local v331 = entity.get_local_player()
            if not v331 or not v331:is_alive() then
                return
            elseif v331:get_player_weapon() == nil then
                return
            else
                local v332, v333 = v329.states:default(v331)
                if v332 == 12 then
                    return
                else
                    if v332 ~= v329.state_cache_idx then
                        v329.state_cache = v329.ui.builder[v332][v333]
                        v329.state_cache_idx = v332
                    end
                    local l_state_cache_1 = v329.state_cache
                    local v335, _ = v329:get_sequence_activity()
                    if
                        v329.ui.builder.disable_on:get(1) and v335 == 961 or
                            v329.ui.builder.disable_on:get(2) and v329.references.neverlose.peek_assist:get() and
                                (v329.state_cache_idx == 2 or v329.state_cache_idx == 8 or v329.state_cache_idx == 9)
                     then
                        v330.force_defensive = false
                        v329.references.neverlose.dt.lag_options:override("On Peek")
                        return
                    else
                        v329.references.neverlose.hs.options:override(v329.ui.elements.hide_shots:get())
                        if v329.ui.builder.force_break_lc:get(v329.state_cache_idx) then
                            if l_state_cache_1.tickbase:get() then
                                v329.references.neverlose.dt.lag_options:override("On Peek")
                                local v337 =
                                    v329:get_random_tick(
                                    l_state_cache_1.ticks:get(),
                                    (l_state_cache_1.ticks_variability:get())
                                )
                                v330.force_defensive = v330.command_number % v337 == 0
                            else
                                v329.references.neverlose.dt.lag_options:override("Always On")
                            end
                        else
                            v329.references.neverlose.dt.lag_options:override("On Peek")
                        end
                        return
                    end
                end
            end
        end
    }
):struct("tweaks")(
    {
        tweak_warmup = l_pui_0.string("\v\226\128\162  \rWarmup"),
        tweak_no_enemies = l_pui_0.string("\v\226\128\162  \rNo Enemies"),
        pitch_map = {
            Down = "Down",
            Disabled = "Disabled",
            Up = "Fake Up"
        },
        init = function(v338)
            local function v340(v339)
                -- upvalues: v338 (ref)
                v338:override(v339)
            end
            local function v342(v341)
                -- upvalues: v340 (ref)
                if #v341:get() > 0 then
                    events.createmove:set(v340)
                else
                    events.createmove:unset(v340)
                end
            end
            v338.ui.elements.tweaks:set_callback(v342, true)
        end,
        get_aimbot_targets = function(_)
            local v344 = {}
            local v345 = entity.get_player_resource()
            for v346 = 1, globals.max_players do
                local v347 = entity.get(v346)
                if v347 and v345.m_bConnected[v346] and v347:is_enemy() and v347:is_alive() then
                    table.insert(v344, v347)
                end
            end
            return v344
        end,
        calculate_offset = function(_, v349, v350, v351)
            if v349 == "Spin" then
                return -math.fmod(globals.curtime * (v350 * 360), v351 * 2) + v351
            else
                return math.sin(globals.curtime * v350) * v351
            end
        end,
        override = function(v352, v353)
            local v354 = entity.get_local_player()
            if not v354 or not v354:is_alive() then
                return
            else
                local v355 = v352.ui.elements.tweaks:get()
                if #v355 == 0 then
                    return
                else
                    local v356 = false
                    local v357 = false
                    for _, v359 in ipairs(v355) do
                        if v359 == v352.tweak_warmup then
                            v356 = true
                        elseif v359 == v352.tweak_no_enemies then
                            v357 = true
                        end
                    end
                    local v360 = false
                    if v356 then
                        local v361 = entity.get_game_rules()
                        v360 = v361 and v361.m_bWarmupPeriod
                    end
                    if not v360 and v357 then
                        v360 = #v352:get_aimbot_targets() == 0
                    end
                    if v360 then
                        local l_neverlose_1 = v352.references.neverlose
                        l_neverlose_1.dt.lag_options:override("On Peek")
                        l_neverlose_1.hs.options:override("Favor Fire Rate")
                        v353.force_defensive = false
                        local v363 = v352.pitch_map[v352.ui.elements.tweaks_pitch:get()] or "Disabled"
                        l_neverlose_1.pitch:override(v363)
                        local v364 =
                            v352:calculate_offset(
                            v352.ui.elements.tweaks_mode:get(),
                            v352.ui.elements.tweaks_speed:get(),
                            (v352.ui.elements.tweaks_range:get())
                        )
                        l_neverlose_1.yaw.offset:override(v364)
                        l_neverlose_1.modifier:override("Disabled")
                        l_neverlose_1.body:override(false)
                        l_neverlose_1.freestanding:override(false)
                    end
                    return
                end
            end
        end
    }
):struct("csa")(
    {
        earthquake_counter = 0,
        earthquake_value = 0,
        smoothed_pose_p = {},
        smoothed_layers = {},
        init = function(v365)
            for v366 = 0, 12 do
                v365.smoothed_pose_p[v366] = 0
                v365.smoothed_layers[v366] = 0
            end
            events.post_update_clientside_animation(
                function()
                    -- upvalues: v365 (ref)
                    v365:update()
                end
            )
        end,
        get_anim_layers = function(v367, v368)
            local v369 = v368[0]
            if v369 ~= v367.last_player_ptr then
                v367.last_player_ptr = v369
                v367.anim_layers_ptr = ffi.cast("CAnimationLayer**", ffi.cast("uintptr_t", v369) + 10640)[0]
            end
            return v367.anim_layers_ptr
        end,
        update = function(v370)
            local v371 = entity.get_local_player()
            if not v371 or not v371:is_alive() then
                v370.last_player_ptr = nil
                for v372 = 0, 12 do
                    v370.smoothed_pose_p[v372] = 0
                    v370.smoothed_layers[v372] = 0
                end
                return
            else
                local l_elements_3 = v370.ui.elements
                local l_neverlose_2 = v370.references.neverlose
                local v375 = v370:get_anim_layers(v371)
                local v376 = l_elements_3.animations_interpolating:get()
                if v376 > 0 then
                    local v377 = globals.tickinterval * v376
                    local v378 = 1 - v377
                    local l_m_flPoseParameter_0 = v371.m_flPoseParameter
                    for v380 = 0, 12 do
                        local v381 = l_m_flPoseParameter_0[v380]
                        local v382 = v377 * (v370.smoothed_pose_p[v380] or 0) + v378 * v381
                        v370.smoothed_pose_p[v380] = v382
                        l_m_flPoseParameter_0[v380] = v382
                    end
                    for v383 = 0, 12 do
                        local v384 = v375[v383]
                        if v384 then
                            local l_m_flWeight_0 = v384.m_flWeight
                            local v386 = v377 * (v370.smoothed_layers[v383] or 0) + v378 * l_m_flWeight_0
                            v370.smoothed_layers[v383] = v386
                            v384.m_flWeight = v386
                        end
                    end
                end
                local v387 = l_elements_3.animations_leaning:get()
                if v387 ~= 0 then
                    local v388 = v375[12]
                    if v388 then
                        if l_elements_3.animations_earthquake:get() then
                            v370.earthquake_counter = v370.earthquake_counter + 1
                            if v370.earthquake_counter % 4 == 0 then
                                v370.earthquake_value = math.random()
                            end
                            v388.m_flWeight = v370.earthquake_value
                        else
                            v388.m_flWeight = v387 * 0.01
                        end
                    end
                end
                v371.m_flPoseParameter[6] = l_elements_3.animations_falling:get() * 0.01
                if l_elements_3.animations_jitter_legs:get() then
                    l_neverlose_2.leg_movement:override("Sliding")
                    if bit.band(globals.tickcount, 3) > 1 then
                        v371.m_flPoseParameter[0] = 1
                        v371.m_flPoseParameter[1] = 1
                    end
                else
                    l_neverlose_2.leg_movement:override()
                end
                return
            end
        end
    }
):struct("avoid_fall_damage")(
    {
        ground_check_distance = 15,
        fall_speed_threshold = -580,
        last_override_state = false,
        is_falling_fast = false,
        init = function(v389)
            local function v391(v390)
                -- upvalues: v389 (ref)
                v389:update(v390)
            end
            local function v393(v392)
                -- upvalues: v391 (ref), v389 (ref)
                if v392:get() then
                    events.createmove_run:set(v391)
                else
                    events.createmove_run:unset(v391)
                    v389:reset_overrides()
                end
            end
            v389.ui.elements.avoid_fall_damage:set_callback(v393, true)
        end,
        check_ground_below = function(_, v395, v396)
            local v397 = v395:get_origin()
            local v398 = v397 + vector(0, 0, -v396)
            return utils.trace_line(v397, v398, v395).fraction < 1
        end,
        reset_overrides = function(v399)
            local l_neverlose_3 = v399.references.neverlose
            l_neverlose_3.air_duck:override()
            l_neverlose_3.air_duck.mode:override()
            v399.last_override_state = false
        end,
        update = function(v401, _)
            local v403 = entity.get_local_player()
            if not v403 or not v403:is_alive() then
                if v401.last_override_state then
                    v401:reset_overrides()
                end
                return
            elseif v403.m_vecVelocity.z > v401.fall_speed_threshold then
                if v401.last_override_state then
                    v401:reset_overrides()
                end
                return
            else
                local v404 = not v401:check_ground_below(v403, v401.ground_check_distance)
                if v404 ~= v401.last_override_state then
                    local l_neverlose_4 = v401.references.neverlose
                    if v404 then
                        l_neverlose_4.air_duck:override(true)
                        l_neverlose_4.air_duck.mode:override("Default")
                    else
                        l_neverlose_4.air_duck:override(false)
                        l_neverlose_4.air_duck.mode:override()
                    end
                    v401.last_override_state = v404
                end
                return
            end
        end
    }
):struct("fast_ladder")(
    {
        init = function(v406)
            local function v408(v407)
                -- upvalues: v406 (ref)
                v406:update(v407)
            end
            local function v410(v409)
                -- upvalues: v408 (ref)
                events.createmove(v408, v409:get())
            end
            v406.ui.elements.fast_ladder:set_callback(v410, true)
        end,
        update = function(_, v412)
            local v413 = entity.get_local_player()
            if not v413 or not v413:is_alive() or v413.m_MoveType ~= 9 then
                return
            else
                v412.view_angles.y = math.floor(v412.view_angles.y + 0.5)
                v412.view_angles.z = 0
                local l_forwardmove_0 = v412.forwardmove
                local l_sidemove_0 = v412.sidemove
                if l_forwardmove_0 ~= 0 then
                    v412.view_angles.x = 89
                    local v416 =
                        l_forwardmove_0 > 0 and
                        {
                            [1] = 90,
                            [2] = 150,
                            [3] = 30
                        } or
                        {
                            [1] = 90,
                            [2] = 30,
                            [3] = 150
                        }
                    local v417 =
                        l_forwardmove_0 > 0 and
                        {
                            [1] = 1,
                            [2] = 0,
                            [3] = 0,
                            [4] = 1
                        } or
                        {
                            [1] = 0,
                            [2] = 1,
                            [3] = 1,
                            [4] = 0
                        }
                    v412.in_moveright = v417[1]
                    v412.in_moveleft = v417[2]
                    v412.in_forward = v417[3]
                    v412.in_back = v417[4]
                    v412.view_angles.y =
                        v412.view_angles.y + v416[l_sidemove_0 == 0 and 1 or l_sidemove_0 < 0 and 2 or 3]
                end
                return
            end
        end
    }
):struct("avoid_collisions")(
    {
        trace_mask = 33636363,
        hull_scale = 0.85,
        min_velocity = 150,
        movetype_walk = 2,
        max_angle_diff = 90,
        extrapolate_distance = 45,
        grate_contents = 536870912,
        rad2deg = 180 / math.pi,
        vec3_t = ffi.typeof("struct { float x, y, z; }"),
        native_getCollideable = utils.get_vfunc(3, "void*(__thiscall*)(void* ecx)"),
        native_getMins = utils.get_vfunc(1, "$*(__thiscall*)(void* ecx)", ffi.typeof("struct { float x, y, z; }")),
        native_getMaxs = utils.get_vfunc(2, "$*(__thiscall*)(void* ecx)", ffi.typeof("struct { float x, y, z; }")),
        init = function(v418)
            local function v420(v419)
                -- upvalues: v418 (ref)
                v418:handle(v419)
            end
            local function v422(v421)
                -- upvalues: v420 (ref)
                events.createmove(v420, v421:get())
            end
            v418.ui.elements.avoid_collisions:set_callback(v422, true)
        end,
        get_collideable_bounds = function(v423, v424)
            local v425 = v424[0]
            local v426 = v423.native_getCollideable(v425)
            if not v426 then
                return vector(-16, -16, 0) * v423.hull_scale, vector(16, 16, 72) * v423.hull_scale
            else
                local v427 = v423.native_getMins(v426)
                local v428 = v423.native_getMaxs(v426)
                return vector(v427.x, v427.y, v427.z) * v423.hull_scale, vector(v428.x, v428.y, v428.z) *
                    v423.hull_scale
            end
        end,
        normalize_yaw = function(_, v430)
            while v430 > 180 do
                v430 = v430 - 360
            end
            while v430 < -180 do
                v430 = v430 + 360
            end
            return v430
        end,
        calculate_avoidance_angle = function(v431, v432)
            local v433 = nil
            if v432.y < v432.x then
                v433 = math.atan2(v432.y, v432.x) * v431.rad2deg + 180
            else
                v433 = math.atan2(v432.y, v432.x) * v431.rad2deg - 180
            end
            return v433
        end,
        change_yaw = function(v434, v435, v436, v437)
            if math.abs(v437.plane.normal.z) > 0.1 or v437.plane.normal:length() < 0.1 then
                return
            else
                local v438 = v434:calculate_avoidance_angle(v437.plane.normal)
                local v439 = v434:normalize_yaw(v436 - v438)
                if math.abs(v439) > v434.max_angle_diff then
                    return
                else
                    if v435.sidemove < -10 and v439 < 0 then
                        v439 = 1
                    elseif v435.sidemove > 10 and v439 > 0 then
                        v439 = -1
                    end
                    v435.move_yaw = v434:normalize_yaw(90 - v434:normalize_yaw(90 - (v438 + (v439 > 0 and 90 or -90))))
                    v435.in_speed = 0
                    v435.in_moveleft = 0
                    v435.in_moveright = 0
                    v435.forwardmove = 450
                    v435.sidemove = 0
                    return
                end
            end
        end,
        should_avoid = function(v440, v441, v442)
            if not v441 or not v441:is_alive() then
                return false
            elseif v441.m_MoveType ~= v440.movetype_walk then
                return false
            elseif bit.band(v441.m_fFlags, 1) == 1 then
                return false
            elseif v442.forwardmove < 0 then
                return false
            elseif v441.m_vecVelocity:length2d() < v440.min_velocity then
                return false
            elseif v440.ui.elements.avoid_collisions_disable_on_crouch:get() and bit.band(v441.m_fFlags, 4) == 4 then
                return false
            else
                return true
            end
        end,
        handle = function(v443, v444)
            local v445 = entity.get_local_player()
            if not v443:should_avoid(v445, v444) then
                return
            else
                local v446, v447 = v443:get_collideable_bounds(v445)
                local v448 = render.camera_angles()
                v448.x = 0
                local v449 = v445:get_origin()
                local v450 = v445.m_vecVelocity:length2d()
                local v451 = vector():angles(v448.x, v448.y)
                local v452 = v443.ui.elements.avoid_collisions_distance:get()
                local v453 = v449 + v451 * (v450 * (globals.tickinterval * v452))
                local v454 =
                    utils.trace_hull(v449, v453, v446, v447, entity.get_players(false, false), v443.trace_mask, 0)
                if not v454.entity then
                    return
                elseif v454.entity:get_classname() == "CDynamicProp" then
                    return
                elseif bit.band(v454.contents, v443.grate_contents) ~= 0 then
                    return
                else
                    v443:change_yaw(v444, v448.y, v454)
                    return
                end
            end
        end
    }
):struct("watermark")(
    {
        screen = render.screen_size(),
        fonts = {
            Bold = 4,
            Default = 1,
            Console = 3,
            Pixel = 2
        },
        presets = {
            Classic = {
                gradient = true,
                prefix = "L U A",
                postfix = " [DEVELOPER]",
                text = " S E N S E"
            },
            Luasync = {
                gradient = false,
                prefix = "",
                postfix = ".max",
                text = "luasync"
            },
            Star = {
                gradient = false,
                prefix = "\239\128\133",
                postfix = "",
                text = " LUASENSE"
            }
        },
        config = {
            snap_visual_range = 60,
            snap_threshold = 25,
            animation = {
                hover_speed = 8,
                pulse_speed = 2,
                drag_speed = 6,
                snap_speed = 10
            },
            gradient = {
                min_brightness = 0.3,
                max_brightness = 1,
                speed = 2,
                wave_count = 1,
                enabled = false
            },
            positions = {
                top_left = vector(0.03, 0.02),
                top_right = vector(0.97, 0.02),
                center_left = vector(0.0333, 0.5),
                center_right = vector(0.9667, 0.5),
                bottom_center = vector(0.5, 0.98)
            },
            colors = {
                snap_point = color(255, 255, 255, 60),
                snap_point_active = color(255, 255, 255, 150),
                snap_line = color(255, 255, 255, 100),
                hover_bg = color(255, 255, 255, 20),
                drag_bg = color(255, 255, 255, 35)
            }
        },
        state = {
            hover = false,
            dragging = false,
            gradient_time = 0,
            drag_offset = vector(0, 0),
            text_size = vector(0, 0),
            animations = {
                pulse_time = 0,
                background_alpha = 0,
                drag_alpha = 0,
                hover_alpha = 0,
                snap_indicators = {}
            },
            cache = {
                snap_positions = {}
            }
        },
        init = function(v455)
            -- upvalues: l_pui_0 (ref)
            v455.state.position =
                vector(
                v455.screen.x * v455.config.positions.bottom_center.x,
                v455.screen.y * v455.config.positions.bottom_center.y
            )
            v455:precalculate_snap_positions()
            local function v456()
                -- upvalues: v455 (ref)
                v455:render()
            end
            local function v457()
                -- upvalues: l_pui_0 (ref), v455 (ref)
                if l_pui_0.get_alpha() > 0 and v455.state.hover or v455.state.dragging then
                    return false
                else
                    return
                end
            end
            local function v459(v458)
                -- upvalues: v457 (ref), v456 (ref)
                events.mouse_input(v457, v458:get())
                events.render(v456, v458:get())
            end
            v455.ui.elements.watermark:set_callback(v459, true)
        end,
        precalculate_snap_positions = function(v460)
            for v461, v462 in pairs(v460.config.positions) do
                v460.state.cache.snap_positions[v461] = vector(v460.screen.x * v462.x, v460.screen.y * v462.y)
            end
        end,
        lerp = function(_, v464, v465, v466)
            return v464 + (v465 - v464) * math.min(globals.frametime * v466, 1)
        end,
        calculate_gradient_color = function(v467, v468, v469)
            local v470 = globals.realtime * v467.config.gradient.speed
            local v471 = v468 / v469 * v467.config.gradient.wave_count * math.pi
            local v472 = math.sin(v470 + v471)
            local v473 =
                v467.config.gradient.min_brightness +
                (v467.config.gradient.max_brightness - v467.config.gradient.min_brightness) * ((v472 + 1) / 2)
            local v474 = math.floor(v473 * 255)
            return color(v474, v474, v474)
        end,
        split_utf8 = function(_, v476)
            local v477 = {}
            local v478 = 1
            while v478 <= #v476 do
                local v479 = string.byte(v476, v478)
                local v480 = 1
                if v479 >= 240 then
                    v480 = 4
                elseif v479 >= 224 then
                    v480 = 3
                elseif v479 >= 192 then
                    v480 = 2
                end
                table.insert(v477, v476:sub(v478, v478 + v480 - 1))
                v478 = v478 + v480
            end
            return v477
        end,
        get_snap_position = function(v481, v482)
            local v483 = nil
            local v484 = nil
            local l_snap_threshold_0 = v481.config.snap_threshold
            for v486, v487 in pairs(v481.state.cache.snap_positions) do
                local v488 = v482:dist(v487)
                if v488 < l_snap_threshold_0 then
                    l_snap_threshold_0 = v488
                    v483 = v487
                    v484 = v486
                end
            end
            return v483, v484
        end,
        render_snap_indicators = function(v489)
            v489.state.animations.pulse_time = v489.state.animations.pulse_time + globals.frametime
            for v490, v491 in pairs(v489.state.cache.snap_positions) do
                local v492 = v489.state.position:dist(v491)
                local v493 = v492 < v489.config.snap_visual_range
                if not v489.state.animations.snap_indicators[v490] then
                    v489.state.animations.snap_indicators[v490] = {
                        line_alpha = 0,
                        scale = 0,
                        alpha = 0
                    }
                end
                local v494 = v489.state.animations.snap_indicators[v490]
                local v495 = 0
                if v489.state.dragging and v493 then
                    v495 = math.max(0, 1 - v492 / v489.config.snap_visual_range)
                end
                v494.alpha = v489:lerp(v494.alpha, v495, v489.config.animation.snap_speed)
                if v494.alpha > 0.01 then
                    local v496 = 1
                    if v492 < v489.config.snap_threshold then
                        v496 = 1 + math.sin(v489.state.animations.pulse_time * v489.config.animation.pulse_speed) * 0.2
                        v494.line_alpha = v489:lerp(v494.line_alpha, 1, v489.config.animation.snap_speed)
                    else
                        v494.line_alpha = v489:lerp(v494.line_alpha, 0, v489.config.animation.snap_speed)
                    end
                    local v497 = v492 < v489.config.snap_threshold and 1.5 or 1
                    v494.scale = v489:lerp(v494.scale, v497, v489.config.animation.snap_speed)
                    local v498 = math.floor(v494.alpha * 100)
                    local v499 = color(255, 255, 255, v498)
                    local v500 = 3 * v494.scale * v496
                    if v492 < v489.config.snap_threshold then
                        local v501 = math.floor(v494.alpha * 30)
                        local v502 = color(255, 255, 255, v501)
                        render.circle(v491, v502, v500 * 3, 0, 1)
                    end
                    render.circle(v491, v499, v500, 0, 1)
                    render.circle_outline(v491, v499, v500, 0, 1, 1)
                    if v494.line_alpha > 0.01 then
                        local v503 = math.floor(v494.line_alpha * v494.alpha * 80)
                        local v504 = color(255, 255, 255, v503)
                        local v505 = 10
                        for v506 = 0, v505 - 1, 2 do
                            local v507 = v506 / v505
                            local v508 = math.min((v506 + 1) / v505, 1)
                            local v509 = v489.state.position:lerp(v491, v507)
                            local v510 = v489.state.position:lerp(v491, v508)
                            render.line(v509, v510, v504)
                        end
                    end
                    if v492 < v489.config.snap_threshold * 2 and v494.alpha > 0.5 then
                        local v511 = math.floor(v494.alpha * 150)
                        local v512 = color(255, 255, 255, v511)
                        local v513 = v491 + vector(0, -15)
                        local v514 = v490:gsub("_", " "):gsub("^%l", string.upper):upper()
                        render.text(2, v513, v512, "c", v514)
                    end
                end
            end
        end,
        handle_input = function(v515)
            -- upvalues: l_pui_0 (ref)
            if l_pui_0.get_alpha() == 0 then
                return
            else
                local v516 = l_pui_0.get_mouse_position()
                local v517 = common.is_button_down(1)
                local v518 = vector(v515.state.text_size.x / 2, v515.state.text_size.y / 2)
                local v519 = 6
                local v520 =
                    v516.x >= v515.state.position.x - v518.x - v519 and v516.x <= v515.state.position.x + v518.x + v519 and
                    v516.y >= v515.state.position.y - v518.y - v519 and
                    v516.y <= v515.state.position.y + v518.y + v519
                v515.state.hover = v520
                if v517 and v520 and not v515.state.dragging then
                    v515.state.dragging = true
                    v515.state.drag_offset = v516 - v515.state.position
                end
                if v515.state.dragging then
                    if v517 then
                        local v521 = v516 - v515.state.drag_offset
                        local v522 = v515:get_snap_position(v521)
                        if v522 then
                            v521 = v522
                        end
                        v521.x = math.max(v518.x, math.min(v515.screen.x - v518.x, v521.x))
                        v521.y = math.max(v518.y, math.min(v515.screen.y - v518.y, v521.y))
                        v515.state.position = v521
                        if v515.ui.elements.watermark_x then
                            v515.ui.elements.watermark_x:set(v521.x)
                        end
                        if v515.ui.elements.watermark_y then
                            v515.ui.elements.watermark_y:set(v521.y)
                        end
                    else
                        v515.state.dragging = false
                    end
                end
                return
            end
        end,
        get_text_parts = function(v523)
            local v524 = v523.ui.elements.watermark_style:get() or "Classic"
            if v523.state.cache.last_preset == v524 and v523.state.cache.text_parts then
                return unpack(v523.state.cache.text_parts)
            else
                local v525 = v523.presets[v524] or v523.presets.Classic
                v523.config.gradient.enabled = v525.gradient or false
                v523.state.cache.last_preset = v524
                v523.state.cache.text_parts = {
                    [1] = v525.prefix,
                    [2] = v525.text,
                    [3] = v525.postfix
                }
                return v525.prefix, v525.text, v525.postfix
            end
        end,
        render = function(v526)
            -- upvalues: l_pui_0 (ref)
            if not globals.is_in_game then
                return
            else
                local v527, v528, v529 = v526:get_text_parts()
                local v530 = v526.fonts[v526.ui.elements.watermark_font:get()]
                local v531 = "c"
                if v526.ui.elements.watermark_x and v526.ui.elements.watermark_y then
                    v526.state.position = vector(v526.ui.elements.watermark_x:get(), v526.ui.elements.watermark_y:get())
                end
                local v532 = v526.ui.elements.watermark_main_accent:get() or color(255, 255, 255)
                local v533 = v526.ui.elements.watermark_prefix_accent:get() or color(150, 150, 150)
                local v534 = v526.ui.elements.watermark_postfix_accent:get() or color(150, 150, 150)
                local v535 = v527 .. v528 .. v529
                v526.state.text_size = render.measure_text(v530, v531, v535)
                v526:handle_input()
                local v536 = 0
                if v526.state.hover and l_pui_0.get_alpha() > 0 then
                    v536 = 0.3
                end
                if v526.state.dragging then
                    v536 = 0.5
                end
                v526.state.animations.background_alpha =
                    v526:lerp(v526.state.animations.background_alpha, v536, v526.config.animation.hover_speed)
                if v526.state.animations.background_alpha > 0.01 then
                    local v537 = math.floor(v526.state.animations.background_alpha * 40)
                    local v538 = color(255, 255, 255, v537)
                    local v539 = 8
                    local v540 = math.floor(v526.state.animations.background_alpha * 20)
                    local v541 = color(0, 0, 0, v540)
                    render.shadow(
                        v526.state.position -
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v526.state.position +
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v541,
                        20,
                        2,
                        4
                    )
                    render.rect(
                        v526.state.position -
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v526.state.position +
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v538,
                        4
                    )
                    local v542 = math.floor(v526.state.animations.background_alpha * 60)
                    local v543 = color(255, 255, 255, v542)
                    render.rect_outline(
                        v526.state.position -
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v526.state.position +
                            vector(v526.state.text_size.x / 2 + v539, v526.state.text_size.y / 2 + v539),
                        v543,
                        1,
                        4
                    )
                end
                v526:render_snap_indicators()
                if v526.config.gradient.enabled then
                    local v544 = string.format("\a%s%s", v533:to_hex(), v527)
                    local v545 = string.format("\a%s%s", v534:to_hex(), v529)
                    local v546 = v526:split_utf8(v528)
                    local v547 = {}
                    for v548, v549 in ipairs(v546) do
                        local v550 = v526:calculate_gradient_color(v548, #v546)
                        table.insert(v547, string.format("\a%s%s", v550:to_hex(), v549))
                    end
                    local v551 = v544 .. table.concat(v547) .. v545
                    render.text(v530, v526.state.position, color(), v531, v551)
                else
                    local v552 =
                        string.format(
                        "\a%s%s\a%s%s\a%s%s",
                        v533:to_hex(),
                        v527,
                        v532:to_hex(),
                        v528,
                        v534:to_hex(),
                        v529
                    )
                    render.text(v530, v526.state.position, color(), v531, v552)
                end
                v526.state.gradient_time = v526.state.gradient_time + globals.frametime
                return
            end
        end
    }
):struct("magic_key")(
    {
        init = function(v553)
            local function v555(v554)
                -- upvalues: v553 (ref)
                v553.references.neverlose.hit_chance:override(v554:get() and 10 or nil)
                v553.references.neverlose.body_aim:override(v554:get() and "Default" or nil)
                v553.references.neverlose.safe_points:override(v554:get() and "Default" or nil)
                v553.references.neverlose.ensure_hitbox_safety:override(v554:get() and "" or nil)
                v553.references.neverlose.auto_stop:override(v554:get() and "" or nil)
                v553.references.neverlose.dt_auto_stop:override(v554:get() and "" or nil)
                v553.references.neverlose.head_scale:override(v554:get() and 100 or nil)
                v553.references.neverlose.body_scale:override(v554:get() and 100 or nil)
            end
            v553.ui.elements.magic_key:set_callback(v555, true)
        end
    }
):struct("fake_duck_speed")(
    {
        min_velocity = 10,
        speed_scale = 150,
        init = function(v556)
            local function v558(v557)
                -- upvalues: v556 (ref)
                v556:override(v557)
            end
            local function v560(v559)
                -- upvalues: v558 (ref)
                events.createmove_run(v558, v559:get())
            end
            v556.ui.elements.fake_duck_speed:set_callback(v560, true)
        end,
        override = function(v561, v562)
            local v563 = entity.get_local_player()
            if not v563 or not v563:is_alive() then
                return
            elseif not v561.references.neverlose.fake_duck:get() then
                return
            else
                local l_m_vecVelocity_0 = v563.m_vecVelocity
                if
                    math.abs(l_m_vecVelocity_0.x) > v561.min_velocity or
                        math.abs(l_m_vecVelocity_0.y) > v561.min_velocity
                 then
                    local v565 = vector(v562.forwardmove, v562.sidemove)
                    if v565:length() > 0 then
                        v565:normalize()
                        v562.forwardmove = v565.x * v561.speed_scale
                        v562.sidemove = v565.y * v561.speed_scale
                    end
                end
                return
            end
        end
    }
):struct("fake_duck_freezetime")(
    {
        duck_height = 64,
        duck_end = 7,
        send_packet_tick = 6,
        duck_start = 0,
        duck_cycle = 14,
        is_ducking = false,
        tick_counter = 0,
        init = function(v566)
            local function v568(v567)
                -- upvalues: v566 (ref)
                v566:override(v567)
            end
            local function v570(v569)
                -- upvalues: v566 (ref)
                v566:override_view(v569)
            end
            local function v573(v571)
                -- upvalues: v568 (ref), v570 (ref), v566 (ref)
                local v572 = v571:get()
                events.createmove(v568, v572)
                events.override_view(v570, v572)
                if not v572 then
                    v566.tick_counter = 0
                    v566.is_ducking = false
                    v566.references.neverlose.dt:override()
                    v566.references.neverlose.hs:override()
                end
            end
            v566.ui.elements.fake_duck_freezetime:set_callback(v573, true)
        end,
        override = function(v574, v575)
            local v576 = entity.get_local_player()
            if not v576 or not v576:is_alive() then
                return
            else
                local v577 = entity.get_game_rules()
                if not v577 then
                    return
                else
                    if v577.m_bFreezePeriod and v574.references.neverlose.fake_duck:get() then
                        v574.references.neverlose.dt:override(false)
                        v574.references.neverlose.hs:override(false)
                        local v578 = v574.tick_counter % v574.duck_cycle
                        if v578 == v574.duck_start then
                            v574.is_ducking = true
                            v575.send_packet = false
                        elseif v578 == v574.send_packet_tick then
                            v575.send_packet = true
                        elseif v578 == v574.duck_end then
                            v574.is_ducking = false
                            v575.send_packet = false
                        else
                            v575.send_packet = false
                        end
                        v575.in_duck = v574.is_ducking
                        v574.tick_counter = v574.tick_counter + 1
                    elseif v574.tick_counter > 0 then
                        v574.references.neverlose.dt:override()
                        v574.references.neverlose.hs:override()
                        v574.tick_counter = 0
                        v574.is_ducking = false
                    end
                    return
                end
            end
        end,
        override_view = function(v579, v580)
            local v581 = entity.get_local_player()
            if not v581 or not v581:is_alive() then
                return
            else
                local v582 = entity.get_game_rules()
                if not v582 then
                    return
                else
                    if v582.m_bFreezePeriod and v579.references.neverlose.fake_duck:get() then
                        v580.camera.z = v581:get_origin().z + v579.duck_height
                    end
                    return
                end
            end
        end
    }
):struct("side_indicators")(
    {
        indicator_offset = 2,
        indicator_height = 44,
        bomb_icon = render.load_image_from_file("materials/panorama/images/icons/ui/bomb_c4.svg", vector(30, 30)),
        screen_size = render.screen_size(),
        bomb_state = {
            planting_site = "",
            planting = false,
            plant_time = 0,
            fill = 0
        },
        init = function(v583)
            v583.font = render.load_font("Calibri", vector(25, 23.5, 0), "bda")
            local function v585(v584)
                -- upvalues: v583 (ref)
                v583:on_bomb_plant(v584)
            end
            local function v586()
                -- upvalues: v583 (ref)
                v583:reset_bomb()
            end
            local function v587()
                -- upvalues: v583 (ref)
                v583:render()
                if v583.ui.elements.side_indicators_spectator_list:get() then
                    v583:render_spectators()
                end
            end
            local function v589(v588)
                -- upvalues: v585 (ref), v586 (ref), v587 (ref)
                events.bomb_beginplant(v585, v588:get())
                events.bomb_planted(v586, v588:get())
                events.bomb_defused(v586, v588:get())
                events.bomb_abortplant(v586, v588:get())
                events.round_prestart(v586, v588:get())
                events.render(v587, v588:get())
            end
            v583.ui.elements.side_indicators:set_callback(v589, true)
        end,
        get_bind_state = function(_, v591)
            -- upvalues: l_pui_0 (ref)
            local v592 = l_pui_0.get_binds()
            for v593 = 1, #v592 do
                if v592[v593].name == v591 and v592[v593].active then
                    return true, v592[v593].value
                end
            end
            return false, 0
        end,
        get_indicators = function(v594)
            local v595 = entity.get_local_player()
            if not v595 or not v595:is_alive() then
                return {}
            else
                local l_neverlose_5 = v594.references.neverlose
                local v597 = {}
                if v594.ui.elements.side_indicators_indicators:get("PING") then
                    local l_m_iPing_0 = v595:get_resource().m_iPing
                    if l_neverlose_5.fake_latency:get() > 0 then
                        local v599 =
                            color(255, 0, 50, 255):lerp(
                            color(150, 200, 60, 255),
                            (math.min(l_m_iPing_0 / v594.references.neverlose.fake_latency:get(), 1))
                        )
                        table.insert(
                            v597,
                            {
                                active = true,
                                text = "PING",
                                color = v599
                            }
                        )
                    end
                end
                if
                    v594.ui.elements.side_indicators_indicators:get("Double Tap") and l_neverlose_5.dt:get() and
                        not l_neverlose_5.hs:get()
                 then
                    local v600 = rage.exploit:get() == 1
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "DT",
                            color = v600 and color(200, 207, 200, 255) or color(255, 0, 50, 255)
                        }
                    )
                end
                if v594.ui.elements.side_indicators_indicators:get("Hide Shots") and l_neverlose_5.hs:get() then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "OSAA",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if
                    v594.ui.elements.side_indicators_indicators:get("Dormant Aimbot") and
                        l_neverlose_5.dormant_aimbot:get()
                 then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "DA",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if v594.ui.elements.side_indicators_indicators:get("Fake Duck") and l_neverlose_5.fake_duck:get() then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "DUCK",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if
                    v594.ui.elements.side_indicators_indicators:get("Body Aim") and
                        l_neverlose_5.body_aim:get() == "Force"
                 then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "BODY",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if
                    v594.ui.elements.side_indicators_indicators:get("Safe Points") and
                        l_neverlose_5.safe_points:get() == "Force"
                 then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "SAFE",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if v594.ui.elements.side_indicators_indicators:get("Freestanding") and l_neverlose_5.freestanding:get() then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "FS",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                if v594.ui.elements.side_indicators_indicators:get("Hitchance") and v594:get_bind_state("Hit Chance") then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "H1TCHANCE",
                            color = color(255, 255, 255)
                        }
                    )
                end
                if v594.ui.elements.side_indicators_indicators:get("Damage") and v594:get_bind_state("Min. Damage") then
                    table.insert(
                        v597,
                        {
                            active = true,
                            text = "MD",
                            color = color(200, 207, 200, 255)
                        }
                    )
                end
                v594:add_bomb_indicators(v597)
                return v597
            end
        end,
        add_bomb_indicators = function(v601, v602)
            if not v601.ui.elements.side_indicators_indicators:get("Bomb Info") then
                return
            else
                local v603 = entity.get_local_player()
                if not v603 or not v603:is_alive() then
                    return
                else
                    local v604 = entity.get_entities("CPlantedC4", true)[1]
                    if v604 then
                        local v605 = v604.m_flC4Blow - globals.curtime
                        local l_m_bBombDefused_0 = v604.m_bBombDefused
                        if v605 > 0 and not l_m_bBombDefused_0 then
                            local v607 = v604.m_nBombSite == 0 and "A" or "B"
                            table.insert(
                                v602,
                                {
                                    active = true,
                                    text = string.format("%s - %.1fs", v607, v605),
                                    color = color(200, 207, 200, 255),
                                    icon = v601.bomb_icon
                                }
                            )
                            local v608 = v601:calculate_bomb_damage(v604, v603)
                            if v603.m_iHealth <= v608 then
                                table.insert(
                                    v602,
                                    {
                                        active = true,
                                        text = "FATAL",
                                        color = color(255, 0, 50, 255)
                                    }
                                )
                            elseif v608 > 0.5 then
                                table.insert(
                                    v602,
                                    {
                                        active = true,
                                        text = string.format("-%d HP", math.ceil(v608)),
                                        color = color(210, 216, 112)
                                    }
                                )
                            end
                        end
                    end
                    if v601.bomb_state.planting then
                        v601.bomb_state.fill =
                            math.min(3.125, 3.125 - (3.125 + v601.bomb_state.plant_time - globals.curtime))
                        table.insert(
                            v602,
                            {
                                active = true,
                                text = v601.bomb_state.planting_site,
                                color = color(210, 216, 112),
                                progress = v601.bomb_state.fill / 3.125,
                                icon = v601.bomb_icon
                            }
                        )
                    end
                    return
                end
            end
        end,
        calculate_bomb_damage = function(_, v610, v611)
            local v612 = v610.m_vecOrigin:dist(v611.m_vecOrigin)
            local v613 = 450.7 * math.exp(-((v612 - 75.68) / 789.2) ^ 2)
            local l_m_ArmorValue_0 = v611.m_ArmorValue
            if l_m_ArmorValue_0 > 0 then
                local v615 = v613 * 0.5
                local v616 = (v613 - v615) * 0.5
                if l_m_ArmorValue_0 < v616 then
                    l_m_ArmorValue_0 = l_m_ArmorValue_0 * 2
                    v615 = v613 - v616
                end
                v613 = v615
            end
            return v613
        end,
        render_indicator = function(v617, v618, v619, v620, v621, v622)
            local v623 = v617.screen_size.x / 100 + 2
            local v624 = v617.screen_size.y / 1.47 + v619
            local v625 = render.measure_text(v617.font, "bad", v618)
            local v626 = v625.x + (v622 and v622.width + 8 or 0)
            render.gradient(
                vector(v623 - 17, v624),
                vector(v623 + v626 / 2, v624 + v625.y + 8),
                color(0, 0, 0, 0),
                color(0, 0, 0, 55),
                color(0, 0, 0, 0),
                color(0, 0, 0, 55)
            )
            render.gradient(
                vector(v623 + v626 / 2, v624),
                vector(v623 + v626 + 17, v624 + v625.y + 8),
                color(0, 0, 0, 55),
                color(0, 0, 0, 0),
                color(0, 0, 0, 55),
                color(0, 0, 0, 0)
            )
            local l_v623_0 = v623
            if v622 then
                render.texture(v622, vector(v623 + 1, v624 + 3), color(0, 0, 0, 200))
                render.texture(v622, vector(v623, v624 + 2), v620)
                l_v623_0 = v623 + v622.width + 8
            end
            render.text(v617.font, vector(l_v623_0, v624 + 5), v620, "bad", v618)
            if v621 then
                local v628 = v623 + v626 + 18
                local v629 = v624 + v625.y / 2 + 2
                render.circle_outline(vector(v628, v629), color(0, 0, 0), 10.5, 90, 1, 4)
                render.circle_outline(vector(v628, v629), v620, 10, 90, v621, 3)
            end
        end,
        render = function(v630)
            if not v630.ui.elements.side_indicators:get() then
                return
            else
                local v631 = v630:get_indicators()
                local v632 = 1
                for v633 = 1, #v631 do
                    local v634 = v631[v633]
                    if v634.active then
                        v630:render_indicator(v634.text, v632, v634.color, v634.progress, v634.icon)
                        v632 = v632 - v630.indicator_height
                    end
                end
                return
            end
        end,
        render_spectators = function(v635)
            local v636 = entity.get_local_player()
            if not v636 then
                return
            else
                local v637 = v636.m_hObserverTarget or v636
                local v638 = {}
                local v639 = entity.get_players(false, false)
                for v640 = 1, #v639 do
                    local v641 = v639[v640]
                    if v641.m_hObserverTarget == v637 then
                        table.insert(v638, v641:get_name())
                    end
                end
                local v642 = 5
                for v643 = 1, #v638 do
                    local v644 = v638[v643]
                    local v645 = render.measure_text(1, nil, v644)
                    render.text(1, vector(v635.screen_size.x - v645.x - 2, v642), color(255, 255, 255), nil, v644)
                    v642 = v642 + 17
                end
                return
            end
        end,
        on_bomb_plant = function(v646, v647)
            local v648 = entity.get_player_resource()
            if not v648 then
                return
            else
                v646.bomb_state.plant_time = globals.curtime
                v646.bomb_state.planting = true
                local v649 = entity.get(v647.userid, true)
                if v649 then
                    local v650 = v649:get_origin()
                    local v651 = v650:dist(v648.m_bombsiteCenterA)
                    local v652 = v650:dist(v648.m_bombsiteCenterB)
                    v646.bomb_state.planting_site = v651 < v652 and "A" or "B"
                end
                return
            end
        end,
        reset_bomb = function(v653)
            v653.bomb_state.planting = false
            v653.bomb_state.fill = 0
            v653.bomb_state.plant_time = 0
            v653.bomb_state.planting_site = ""
        end
    }
):struct("damage_indicator")(
    {
        font = 1,
        screen = render.screen_size(),
        center = vector(0, 0),
        accent = color(),
        init = function(v654)
            v654.center = vector(v654.screen.x / 2 + 4, v654.screen.y / 2 - 15)
            local function v655()
                -- upvalues: v654 (ref)
                v654:render()
            end
            local function v657(v656)
                -- upvalues: v655 (ref)
                events.render(v655, v656:get())
            end
            v654.ui.elements.damage_indicator:set_callback(v657, true)
        end,
        render = function(v658)
            -- upvalues: l_pui_0 (ref)
            local v659 = entity.get_local_player()
            if not v659 or not v659:is_alive() then
                return
            else
                local v660 = l_pui_0.get_binds()
                for v661 = 1, #v660 do
                    local v662 = v660[v661]
                    if v662.name == "Min. Damage" and v662.active then
                        render.text(v658.font, v658.center, v658.accent, "", tostring(v662.value))
                        return
                    end
                end
                return
            end
        end
    }
):struct("scope_overlay")(
    {
        screen = render.screen_size(),
        center = vector(0, 0),
        init = function(v663)
            v663.center = vector(math.floor(v663.screen.x / 2 + 0.5), math.floor(v663.screen.y / 2 + 0.5))
            local function v664()
                -- upvalues: v663 (ref)
                v663:render()
            end
            local function v666(v665)
                -- upvalues: v663 (ref), v664 (ref)
                v663.references.neverlose.scope_overlay:override(v665:get() and "Remove All" or nil)
                events.render(v664, v665:get())
            end
            v663.ui.elements.scope_overlay:set_callback(v666, true)
        end,
        render = function(v667)
            v667.rotated = v667.ui.elements.scope_overlay_rotated:get()
            v667.size = v667.ui.elements.scope_overlay_size:get()
            v667.gap = v667.ui.elements.scope_overlay_gap:get()
            v667.color = {
                main = v667.ui.elements.scope_overlay_main_accent:get(),
                edge = v667.ui.elements.scope_overlay_edge_accent:get()
            }
            local v668 = entity.get_local_player()
            if not v668 or not v668:is_alive() or not v668.m_bIsScoped then
                return
            else
                local v669 = 1
                if v667.rotated then
                    render.push_rotation(45, v667.screen / 2 + 1)
                end
                render.gradient(
                    vector(v667.center.x, v667.center.y - v667.gap - v667.size),
                    vector(v667.center.x + v669, v667.center.y - v667.gap),
                    v667.color.edge,
                    v667.color.edge,
                    v667.color.main,
                    v667.color.main
                )
                render.gradient(
                    vector(v667.center.x, v667.center.y + v667.gap + 1),
                    vector(v667.center.x + v669, v667.center.y + v667.gap + v667.size),
                    v667.color.main,
                    v667.color.main,
                    v667.color.edge,
                    v667.color.edge
                )
                render.gradient(
                    vector(v667.center.x - v667.gap - v667.size, v667.center.y),
                    vector(v667.center.x - v667.gap, v667.center.y + v669),
                    v667.color.edge,
                    v667.color.main,
                    v667.color.edge,
                    v667.color.main
                )
                render.gradient(
                    vector(v667.center.x + v667.gap + 1, v667.center.y),
                    vector(v667.center.x + v667.gap + v667.size, v667.center.y + v669),
                    v667.color.main,
                    v667.color.edge,
                    v667.color.main,
                    v667.color.edge
                )
                if v667.rotated then
                    render.pop_rotation()
                end
                return
            end
        end
    }
):struct("log_events")(
    {
        hitgroups = {
            [0] = "generic",
            [1] = "head",
            [2] = "chest",
            [3] = "stomach",
            [4] = "left arm",
            [5] = "right arm",
            [6] = "left leg",
            [7] = "right leg",
            [8] = "neck",
            [9] = "generic",
            [10] = "gear"
        },
        nbk_map = {
            knife = "Knifed",
            inferno = "Burned",
            hegrenade = "Naded"
        },
        init = function(v670)
            v670.references.neverlose.log_events:override("")
            local function v672(v671)
                -- upvalues: v670 (ref)
                v670:aim_ack(v671)
            end
            local function v674(v673)
                -- upvalues: v670 (ref)
                v670:player_hurt(v673)
            end
            local function v676(v675)
                -- upvalues: v670 (ref)
                v670:item_purchase(v675)
            end
            local function v678(v677)
                -- upvalues: v672 (ref), v674 (ref), v676 (ref)
                events.aim_ack(v672, v677:get(1))
                events.player_hurt(v674, v677:get(1))
                events.item_purchase(v676, v677:get(2))
            end
            v670.ui.elements.log_events:set_callback(v678, true)
        end,
        branded_printing = function(v679, v680)
            local v681 = v679.ui.elements.log_events_accent:get()
            local v682 = string.format("[%s] %s", "\a" .. v681:to_hex() .. "Lua\aDEFAULTSense", v680)
            print_raw(v682)
            print_dev(v682)
        end,
        aim_ack = function(v683, v684)
            local l_target_0 = v684.target
            if l_target_0 == nil then
                return
            else
                local l_state_0 = v684.state
                local v687 = l_target_0:get_name()
                local l_m_iHealth_0 = l_target_0.m_iHealth
                local l_spread_0 = v684.spread
                local l_backtrack_0 = v684.backtrack
                local l_hitchance_0 = v684.hitchance
                local l_damage_0 = v684.damage
                local l_wanted_damage_0 = v684.wanted_damage
                local v694 = v683.hitgroups[v684.hitgroup]
                local v695 = v683.hitgroups[v684.wanted_hitgroup]
                local v696 = v683.ui.elements.log_events_accent:get():to_hex()
                if l_state_0 == nil then
                    v683:branded_printing(
                        (string.format(
                            "\a%sRegistered \aDEFAULTshot at %s\aDEFAULT's %s for \a%s%d(%d) \aDEFAULTdamage (hp: \a%s%d\aDEFAULT) (aimed: \a%s%s\aDEFAULT) (bt: \a%s%s\aDEFAULT) (spread: \a%s%.1f\194\176\aDEFAULT)",
                            v696,
                            v687,
                            v694,
                            v696,
                            l_damage_0,
                            l_wanted_damage_0,
                            v696,
                            l_m_iHealth_0,
                            v696,
                            v695,
                            v696,
                            l_backtrack_0,
                            v696,
                            l_spread_0
                        ))
                    )
                    v683.notifications:push_notify(
                        string.format(
                            "\a%s\238\145\178  \aDEFAULTHit \a%s%s\aDEFAULT's \a%s%s \aDEFAULTfor \a%s%d \aDEFAULTdamage (bt: \a%s%d\aDEFAULT)",
                            v696,
                            v696,
                            v687,
                            v696,
                            v694,
                            v696,
                            l_damage_0,
                            v696,
                            l_backtrack_0
                        ),
                        3.5
                    )
                    return
                else
                    text =
                        string.format(
                        "\a%sMissed \aDEFAULTshot at %s\aDEFAULT's %s due to \a%s%s \aDEFAULT(hc: \a%s%d%%\aDEFAULT) (damage: \a%s%d\aDEFAULT) (bt: \a%s%s\aDEFAULT)",
                        v696,
                        v687,
                        v695,
                        v696,
                        l_state_0,
                        v696,
                        l_hitchance_0,
                        v696,
                        l_wanted_damage_0,
                        v696,
                        l_backtrack_0
                    )
                    if l_spread_0 ~= nil then
                        text = string.format("%s (spread: \a%s%.1f\194\176\aDEFAULT)", text, v696, l_spread_0)
                    end
                    v683:branded_printing(text)
                    v683.notifications:push_notify(
                        string.format(
                            "\a%s\239\129\177  \aDEFAULTMissed \a%s%s\aDEFAULT's \a%s%s \aDEFAULTdue to \a%s%s \aDEFAULT(bt: \a%s%s\aDEFAULT)",
                            v696,
                            v696,
                            v687,
                            v696,
                            v695,
                            v696,
                            l_state_0,
                            v696,
                            l_backtrack_0
                        ),
                        3.5
                    )
                    return
                end
            end
        end,
        player_hurt = function(v697, v698)
            local v699 = entity.get_local_player()
            local v700 = entity.get(v698.userid, true)
            local v701 = entity.get(v698.attacker, true)
            if v699 == nil or v700 == nil or v701 == nil then
                return
            elseif v700 == v699 or v701 ~= v699 then
                return
            else
                local v702 = v697.nbk_map[v698.weapon]
                if v702 == nil then
                    return
                else
                    local v703 = v700:get_name()
                    local v704 = v697.ui.elements.log_events_accent:get():to_hex()
                    v697:branded_printing(
                        (string.format(
                            "%s \a%s%s \aDEFAULTfor \a%s%d \aDEFAULTdamage (%d health remaining)",
                            v702,
                            v704,
                            v703,
                            v704,
                            v698.dmg_health,
                            v698.health
                        ))
                    )
                    return
                end
            end
        end,
        item_purchase = function(v705, v706)
            local v707 = entity.get(v706.userid, true)
            if v707 == nil or not v707:is_enemy() then
                return
            else
                local l_weapon_0 = v706.weapon
                if l_weapon_0 == "weapon_unknown" then
                    return
                else
                    local v709 = v707:get_name()
                    local v710 = v705.ui.elements.log_events_accent:get():to_hex()
                    v705:branded_printing(
                        (string.format("\a%s%s \aDEFAULTbought \a%s%s\aDEFAULT", v710, v709, v710, l_weapon_0))
                    )
                    return
                end
            end
        end
    }
):struct("clan_tag_spammer")(
    {
        delay = 15,
        step = 1,
        list = {
            [1] = "lu ",
            [2] = "lua ",
            [3] = "luas ",
            [4] = "luase ",
            [5] = "luasen ",
            [6] = "luasens ",
            [7] = "luasense ",
            [8] = "luasense ",
            [9] = "luasense ",
            [10] = "luasense ",
            [11] = "luasense ",
            [12] = "luasense ",
            [13] = "luasense ",
            [14] = "luasense ",
            [15] = "luasense ",
            [16] = "luasense ",
            [17] = "luasense ",
            [18] = "luasense ",
            [19] = "luasense ",
            [20] = "asense ",
            [21] = "sense ",
            [22] = "ense ",
            [23] = "nse ",
            [24] = "se ",
            [25] = "e ",
            [26] = ""
        },
        init = function(v711)
            local function v712()
                -- upvalues: v711 (ref)
                v711:animation()
            end
            local function v714(v713)
                -- upvalues: v711 (ref), v712 (ref)
                if v713:get() then
                    v711.references.neverlose.clan_tag:override(false)
                    events.net_update_end(v712, true)
                else
                    v711.references.neverlose.clan_tag:override()
                    common.set_clan_tag("")
                    events.net_update_end(v712, false)
                end
            end
            v711.ui.elements.clan_tag_spammer:set_callback(v714, true)
        end,
        animation = function(v715)
            local v716 = math.floor(globals.tickcount / v715.delay) % #v715.list + 1
            if v716 == v715.step then
                return
            else
                v715.step = v716
                common.set_clan_tag(v715.list[v716])
                return
            end
        end
    }
):struct("hitmarkers")(
    {
        center_y = 0,
        center_x = 0,
        world_fade_time = 0.25,
        screen_duration = 1,
        screen_fade_time = 0.25,
        screen_wait_time = 0.25,
        screen_active = false,
        hit_markers = {},
        screen_vectors = {},
        screen_offsets = {
            [1] = {
                [1] = 5,
                [2] = 5,
                [3] = 10,
                [4] = 10
            },
            [2] = {
                [1] = -5,
                [2] = 5,
                [3] = -10,
                [4] = 10
            },
            [3] = {
                [1] = -5,
                [2] = -5,
                [3] = -10,
                [4] = -10
            },
            [4] = {
                [1] = 5,
                [2] = -5,
                [3] = 10,
                [4] = -10
            }
        },
        init = function(v717)
            local v718 = render.screen_size()
            v717.center_x = v718.x * 0.5
            v717.center_y = v718.y * 0.5
            for v719 = 1, 4 do
                v717.screen_vectors[v719] = {
                    v1 = vector(0, 0),
                    v2 = vector(0, 0)
                }
            end
            local function v727()
                -- upvalues: v717 (ref)
                if not v717.screen_active or not globals.is_in_game then
                    return
                else
                    local l_frametime_1 = globals.frametime
                    v717.screen_wait_time = v717.screen_wait_time - l_frametime_1
                    if v717.screen_wait_time <= 0 then
                        v717.screen_duration = v717.screen_duration - l_frametime_1 / v717.screen_fade_time
                        if v717.screen_duration <= 0 then
                            v717.screen_active = false
                            return
                        end
                    end
                    local v721 = v717.ui.elements.hitmarkers_screen_accent:get() * v717.screen_duration
                    local l_center_x_0 = v717.center_x
                    local l_center_y_0 = v717.center_y
                    for v724 = 1, 4 do
                        local v725 = v717.screen_offsets[v724]
                        local v726 = v717.screen_vectors[v724]
                        v726.v1.x = l_center_x_0 + v725[1]
                        v726.v1.y = l_center_y_0 + v725[2]
                        v726.v2.x = l_center_x_0 + v725[3]
                        v726.v2.y = l_center_y_0 + v725[4]
                        render.line(v726.v1, v726.v2, v721)
                    end
                    return
                end
            end
            local function v742()
                -- upvalues: v717 (ref)
                local l_hit_markers_0 = v717.hit_markers
                local v729 = #l_hit_markers_0
                if v729 == 0 then
                    return
                else
                    local l_frametime_2 = globals.frametime
                    local v731 = l_frametime_2 / v717.world_fade_time
                    local l_v729_0 = v729
                    while l_v729_0 > 0 do
                        local v733 = l_hit_markers_0[l_v729_0]
                        if v733.wait_time > 0 then
                            v733.wait_time = v733.wait_time - l_frametime_2
                        else
                            v733.fade_time = v733.fade_time - v731
                        end
                        if v733.fade_time <= 0 then
                            l_hit_markers_0[l_v729_0] = l_hit_markers_0[v729]
                            l_hit_markers_0[v729] = nil
                            v729 = v729 - 1
                        elseif v733.position and not v733.reason then
                            local v734 = render.world_to_screen(v733.position)
                            if v734 then
                                local v735, v736 = v717.ui.elements.hitmarkers_world_accent:get()
                                local v737 = nil
                                local v738 = nil
                                if v735 == "Double" then
                                    v737 = v736[1]
                                    v738 = v736[2]
                                else
                                    v737 = v717.ui.elements.hitmarkers_world_accent:get("Simple")[1]
                                    v738 = v737
                                end
                                local v739 = v733.fade_time * 255
                                local l_x_1 = v734.x
                                local l_y_0 = v734.y
                                render.rect(
                                    vector(l_x_1 - 1, l_y_0 - 5),
                                    vector(l_x_1 + 1, l_y_0 + 5),
                                    color(v738.r, v738.g, v738.b, v739),
                                    0,
                                    true
                                )
                                render.rect(
                                    vector(l_x_1 - 5, l_y_0 - 1),
                                    vector(l_x_1 + 5, l_y_0 + 1),
                                    color(v737.r, v737.g, v737.b, v739),
                                    0,
                                    true
                                )
                            end
                        end
                        l_v729_0 = l_v729_0 - 1
                    end
                    return
                end
            end
            local function v744()
                -- upvalues: v717 (ref)
                for v743 in pairs(v717.hit_markers) do
                    v717.hit_markers[v743] = nil
                end
                v717.screen_active = false
            end
            local function v746(v745)
                -- upvalues: v717 (ref)
                if entity.get_local_player() == entity.get(v745.userid, true) then
                    v717.screen_active = false
                end
            end
            local function v748(v747)
                -- upvalues: v717 (ref)
                v717.hit_markers[#v717.hit_markers + 1] = {
                    fade_time = 1,
                    position = v747.aim,
                    wait_time = v717.ui.elements.hitmarkers_world_duration:get() * 0.5,
                    reason = v747.state
                }
            end
            local function v750(v749)
                -- upvalues: v717 (ref)
                if entity.get_local_player() == entity.get(v749.attacker, true) then
                    v717.screen_active = true
                    v717.screen_duration = 1
                    v717.screen_wait_time = v717.ui.elements.hitmarkers_screen_duration:get() * 0.5
                end
            end
            local function v755(v751)
                -- upvalues: v727 (ref), v742 (ref), v744 (ref), v746 (ref), v748 (ref), v750 (ref)
                local v752 = v751:get(1)
                local v753 = v751:get(2)
                local v754 = v752 or v753
                events.render(v727, v752)
                events.render(v742, v753)
                events.round_start(v744, v754)
                events.player_spawned(v746, v752)
                events.aim_ack(v748, v753)
                events.player_hurt(v750, v752)
            end
            v717.ui.elements.hitmarkers:set_callback(v755, true)
        end
    }
):struct("keep_model_transparency")(
    {
        fade_speed = 10,
        transparency = 255,
        init = function(v756)
            local function v758(v757)
                -- upvalues: v756 (ref)
                return v756:override(v757)
            end
            local function v760(v759)
                -- upvalues: v758 (ref)
                events.localplayer_transparency(v758, v759:get())
            end
            v756.ui.elements.keep_transparency:set_callback(v760, true)
        end,
        override = function(v761, v762)
            local v763 = entity.get_local_player()
            if not v763 or not v763:is_alive() then
                return v762
            else
                local v764 = v763:get_player_weapon()
                if not v764 then
                    return v762
                else
                    local v765 = v764:get_classname()
                    if v765:match("[Gg]renade") or v765:match("[Ff]lashbang") then
                        return v762
                    else
                        local v766 = (v763.m_bIsScoped or v763.m_bResumeZoom) and 59 or 255
                        if v761.transparency ~= v766 then
                            local v767 = v766 - v761.transparency
                            if v767 > 0 then
                                v761.transparency = v761.transparency + math.min(v767, v761.fade_speed)
                            else
                                v761.transparency = v761.transparency + math.max(v767, -v761.fade_speed)
                            end
                        end
                        return v761.transparency
                    end
                end
            end
        end
    }
):struct("slowed_down_indicator")(
    {
        screen = render.screen_size(),
        config = {
            bar_width = 150,
            animation = {
                hover_speed = 8,
                fade_speed = 10,
                drag_speed = 6
            }
        },
        state = {
            hover = false,
            dragging = false,
            drag_offset = vector(0, 0),
            animations = {
                base_alpha = 0,
                background_alpha = 0,
                death_fade = 1,
                hover_alpha = 0,
                velocity_modifier = 1
            }
        },
        init = function(v768)
            -- upvalues: l_pui_0 (ref)
            v768.state.position = vector(v768.screen.x * 0.5 - v768.config.bar_width * 0.5, v768.screen.y * 0.35)
            local function v769()
                -- upvalues: v768 (ref)
                v768:render()
            end
            local function v770()
                -- upvalues: l_pui_0 (ref), v768 (ref)
                if l_pui_0.get_alpha() > 0 and v768.state.hover or v768.state.dragging then
                    return false
                else
                    return
                end
            end
            local function v772(v771)
                -- upvalues: v770 (ref), v769 (ref)
                events.mouse_input(v770, v771:get())
                events.render(v769, v771:get())
            end
            v768.ui.elements.slowed_down_indicator:set_callback(v772, true)
        end,
        lerp = function(_, v774, v775, v776)
            return v774 + (v775 - v774) * math.min(globals.frametime * v776, 1)
        end,
        handle_input = function(v777)
            -- upvalues: l_pui_0 (ref)
            if l_pui_0.get_alpha() == 0 then
                return
            else
                local v778 = l_pui_0.get_mouse_position()
                local v779 = common.is_button_down(1)
                local l_bar_width_0 = v777.config.bar_width
                local v781 = 23
                local v782 = 6
                local v783 =
                    v778.x >= v777.state.position.x - v782 and v778.x <= v777.state.position.x + l_bar_width_0 + v782 and
                    v778.y >= v777.state.position.y - v782 and
                    v778.y <= v777.state.position.y + v781 + v782
                v777.state.hover = v783
                if v779 and v783 and not v777.state.dragging then
                    v777.state.dragging = true
                    v777.state.drag_offset = v778 - v777.state.position
                end
                if v777.state.dragging then
                    if v779 then
                        local v784 = v778 - v777.state.drag_offset
                        v784.x = math.max(0, math.min(v777.screen.x - l_bar_width_0, v784.x))
                        v784.y = math.max(0, math.min(v777.screen.y - v781, v784.y))
                        v777.state.position = v784
                        if v777.ui.elements.slowed_down_x then
                            v777.ui.elements.slowed_down_x:set(v784.x)
                        end
                        if v777.ui.elements.slowed_down_y then
                            v777.ui.elements.slowed_down_y:set(v784.y)
                        end
                    else
                        v777.state.dragging = false
                    end
                end
                return
            end
        end,
        render = function(v785)
            -- upvalues: l_pui_0 (ref)
            local v786 = entity.get_local_player()
            if not v786 and l_pui_0.get_alpha() == 0 then
                return
            else
                local v787 = l_pui_0.get_alpha()
                local v788 = v786 and v786:is_alive() or v787 == 1
                local v789 = v787 == 1 and 0.5 or v786 and v786.m_flVelocityModifier or 1
                local v790 = v788 and 1 or 0
                v785.state.animations.death_fade =
                    v785:lerp(v785.state.animations.death_fade, v790, v785.config.animation.fade_speed)
                local v791 = (not (not v785.state.dragging) or v789 < 1) and 255 or 0
                v785.state.animations.base_alpha =
                    v785:lerp(
                    v785.state.animations.base_alpha,
                    v791 * v785.state.animations.death_fade,
                    v785.config.animation.fade_speed
                )
                if v785.state.animations.base_alpha < 1 then
                    return
                else
                    v785.state.animations.velocity_modifier =
                        v785:lerp(v785.state.animations.velocity_modifier, v789, 8)
                    if v785.ui.elements.slowed_down_x and v785.ui.elements.slowed_down_y then
                        v785.state.position =
                            vector(v785.ui.elements.slowed_down_x:get(), v785.ui.elements.slowed_down_y:get())
                    end
                    local v792 =
                        (v785.ui.elements.slowed_down_accent:get() or color(147, 190, 255)):alpha_modulate(
                        v785.state.animations.base_alpha
                    )
                    local v793 = color(255, 255, 255):alpha_modulate(v785.state.animations.base_alpha)
                    local v794 = color(0, 0, 0):alpha_modulate(math.min(200, v785.state.animations.base_alpha))
                    local v795 = "Max velocity reduced by"
                    local v796 = math.floor((1 - v785.state.animations.velocity_modifier) * 100)
                    local v797 = string.format("%s %d%%", v795, v796)
                    local v798 = vector(v785.config.bar_width, 6)
                    v785:handle_input()
                    local v799 = 0
                    if v785.state.hover and v787 > 0 then
                        v799 = 0.3
                    end
                    if v785.state.dragging then
                        v799 = 0.5
                    end
                    v785.state.animations.background_alpha =
                        v785:lerp(v785.state.animations.background_alpha, v799, v785.config.animation.hover_speed)
                    if v785.state.animations.background_alpha > 0.01 then
                        local v800 = math.floor(v785.state.animations.background_alpha * 40)
                        local v801 = color(255, 255, 255, v800)
                        local v802 = 8
                        local v803 = 15 + v798.y + 2
                        local v804 = math.floor(v785.state.animations.background_alpha * 20)
                        local v805 = color(0, 0, 0, v804)
                        render.shadow(
                            v785.state.position - vector(v802, v802),
                            v785.state.position + vector(v785.config.bar_width + v802, v803 + v802),
                            v805,
                            20,
                            2,
                            4
                        )
                        render.rect(
                            v785.state.position - vector(v802, v802),
                            v785.state.position + vector(v785.config.bar_width + v802, v803 + v802),
                            v801,
                            4
                        )
                        local v806 = math.floor(v785.state.animations.background_alpha * 60)
                        local v807 = color(255, 255, 255, v806)
                        render.rect_outline(
                            v785.state.position - vector(v802, v802),
                            v785.state.position + vector(v785.config.bar_width + v802, v803 + v802),
                            v807,
                            1,
                            4
                        )
                    end
                    render.text(1, v785.state.position, v793, nil, v797)
                    local v808 = v785.state.position + vector(0, 15)
                    local v809 = v808 + v798
                    render.rect(v808 - 1, v809 + 1, v794, 2)
                    render.shadow(v808 - 1, v809 + 1, v792, 25, 0, 3)
                    local v810 = 1 - v785.state.animations.velocity_modifier
                    render.rect(v808 + 1, v808 + vector(v798.x * v810, v798.y) - 1, v792, 2)
                    return
                end
            end
        end
    }
):struct("manual_arrows")(
    {
        screen = render.screen_size(),
        center = vector(0, 0),
        default_accent = color(35, 35, 35, 150),
        init = function(v811)
            v811.center_x = v811.screen.x / 2
            v811.center_y = v811.screen.y / 2 - 2
            local function v812()
                -- upvalues: v811 (ref)
                v811:render()
            end
            local function v814(v813)
                -- upvalues: v812 (ref)
                events.render(v812, v813:get())
            end
            v811.ui.elements.manual_arrows:set_callback(v814, true)
        end,
        render = function(v815)
            local v816 = entity.get_local_player()
            if not v816 or not v816:is_alive() then
                return
            else
                local v817 = v815.references.neverlose.yaw.offset:get_override()
                local v818 = rage.antiaim:inverter()
                local v819 = v815.ui.elements.manaul_arrows_yaw_accent:get()
                local v820 = v815.ui.elements.manaul_arrows_body_accent:get()
                render.poly(
                    v817 == -90 and v819 or v815.default_accent,
                    vector(v815.center_x - 55, v815.center_y + 2),
                    vector(v815.center_x - 42, v815.center_y - 7),
                    vector(v815.center_x - 42, v815.center_y + 11)
                )
                render.poly(
                    v817 == 90 and v819 or v815.default_accent,
                    vector(v815.center_x + 55, v815.center_y + 2),
                    vector(v815.center_x + 42, v815.center_y - 7),
                    vector(v815.center_x + 42, v815.center_y + 11)
                )
                render.rect(
                    vector(v815.center_x - 40, v815.center_y - 7),
                    vector(v815.center_x - 38, v815.center_y + 11),
                    v818 and v820 or v815.default_accent
                )
                render.rect(
                    vector(v815.center_x + 38, v815.center_y - 7),
                    vector(v815.center_x + 40, v815.center_y + 11),
                    not v818 and v820 or v815.default_accent
                )
                return
            end
        end
    }
):struct("shutdown")(
    {
        dump = function(v821)
            events.shutdown(
                function()
                    -- upvalues: v821 (ref)
                    cvar.r_aspectratio:float(0, true)
                    cvar.viewmodel_fov:float(58, true)
                    cvar.viewmodel_offset_x:float(0, true)
                    cvar.viewmodel_offset_y:float(0, true)
                    cvar.viewmodel_offset_z:float(0, true)
                    cvar.cl_use_new_headbob:int(1)
                    cvar.cl_bob_lower_amt:float(21)
                    cvar.cl_bobamt_lat:float(0.4)
                    cvar.cl_bobamt_vert:float(0.25)
                    cvar.cl_bobcycle:float(0.98)
                    cvar.sv_maxunlag:float(0.2)
                    v821.references.neverlose.scope_overlay:override()
                    v821.references.neverlose.log_events:override()
                    v821.references.neverlose.clan_tag:override()
                    common.set_clan_tag("")
                end
            )
        end
    }
)
v822.sidebar:init()
v822.presets:init()
v822.ui:init()
v822.notifications:init()
v822.states:init()
v822.antiaim:init()
v822.defensive:init()
v822.tweaks:init()
v822.csa:init()
v822.avoid_fall_damage:init()
v822.fast_ladder:init()
v822.avoid_collisions:init()
v822.watermark:init()
v822.magic_key:init()
v822.fake_duck_speed:init()
v822.fake_duck_freezetime:init()
v822.side_indicators:init()
v822.damage_indicator:init()
v822.scope_overlay:init()
v822.log_events:init()
v822.clan_tag_spammer:init()
v822.hitmarkers:init()
v822.keep_model_transparency:init()
v822.slowed_down_indicator:init()
v822.manual_arrows:init()
v822.shutdown:dump()
return
