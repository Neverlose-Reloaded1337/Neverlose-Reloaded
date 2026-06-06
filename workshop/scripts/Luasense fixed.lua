--fix made by 2k00 & E0n3x enjoy luasneeze

local origrequire = require
local compiler = loadstring or load

local modules = {
    ["neverlose/clipboard"] = function(require)
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
    end,

    ["neverlose/base64"] = function(require)
        local shl, shr, band = bit.lshift, bit.rshift, bit.band
        local char, byte, gsub, sub, format, concat, tostring, error, pairs = string.char, string.byte, string.gsub, string.sub, string.format, table.concat, tostring, error, pairs

        local extract = function(v, from, width)
            return band(shr(v, from), shl(1, width) - 1)
        end

        local function makeencoder(alphabet)
            local encoder, decoder = {}, {}
            for i=1, 65 do
                local chr = byte(sub(alphabet, i, i)) or 32
                if decoder[chr] ~= nil then
                    error('invalid alphabet: duplicate character ' .. tostring(chr), 3)
                end
                encoder[i-1] = chr
                decoder[chr] = i-1
            end
            return encoder, decoder
        end

        local encoders, decoders = {}, {}

        encoders['base64'], decoders['base64'] = makeencoder('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')
        encoders['base64url'], decoders['base64url'] = makeencoder('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_')

        local alphabet_mt = {
            __index = function(tbl, key)
                if type(key) == 'string' and (key:len() == 64 or key:len() == 65) then
                    encoders[key], decoders[key] = makeencoder(key)
                    return tbl[key]
                end
            end
        }

        setmetatable(encoders, alphabet_mt)
        setmetatable(decoders, alphabet_mt)

        local function encode(str, encoder)
            encoder = encoders[encoder or 'base64'] or error('invalid alphabet specified', 2)
            str = tostring(str)
            local t, k, n = {}, 1, #str
            local lastn = n % 3
            local cache = {}

            for i = 1, n-lastn, 3 do
                local a, b, c = byte(str, i, i+2)
                local v = a*0x10000 + b*0x100 + c
                local s = cache[v]
                if not s then
                    s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
                    cache[v] = s
                end
                t[k] = s
                k = k + 1
            end

            if lastn == 2 then
                local a, b = byte(str, n-1, n)
                local v = a*0x10000 + b*0x100
                t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
            elseif lastn == 1 then
                local v = byte(str, n)*0x10000
                t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
            end
            return concat(t)
        end

        local function decode(b64, decoder)
            decoder = decoders[decoder or 'base64'] or error('invalid alphabet specified', 2)
            local pattern = '[^%w%+%/%=]'
            b64 = gsub(tostring(b64), pattern, '')

            local cache = {}
            local t, k = {}, 1
            local n = #b64
            local padding = sub(b64, -2) == '==' and 2 or sub(b64, -1) == '=' and 1 or 0

            for i = 1, padding > 0 and n-4 or n, 4 do
                local a, b, c, d = byte(b64, i, i+3)
                local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
                local s = cache[v0]
                if not s then
                    local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
                    s = char(extract(v,16,8), extract(v,8,8), extract(v,0,8))
                    cache[v0] = s
                end
                t[k] = s
                k = k + 1
            end

            if padding == 1 then
                local a, b, c = byte(b64, n-3, n-1)
                local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
                t[k] = char(extract(v,16,8), extract(v,8,8))
            elseif padding == 2 then
                local a, b = byte(b64, n-3, n-2)
                local v = decoder[a]*0x40000 + decoder[b]*0x1000
                t[k] = char(extract(v,16,8))
            end
            return concat(t)
        end

        return {
            encode = encode,
            decode = decode
        }
    end,
    ["neverlose/pui"] = function(require)
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
    end,

["neverlose/smoothy"] = function(require)
        local native_GetTimescale = utils.get_vfunc('engine.dll', 'VEngineClient014', 91, 'float(__thiscall*)(void*)')

        local to_pairs = {
            vector = { 'x', 'y', 'z' },
            imcolor =  { 'r', 'g', 'b', 'a' }
        }

        local function get_type(value)
            local val_type = type(value)

            if val_type == 'userdata' and value.__type then
                return string.lower(value.__type.name)
            end

            if val_type == 'boolean' then
                value = value and 1 or 0
            end

            return val_type
        end

        local function copy_tables(destination, keysTable, valuesTable)
            valuesTable = valuesTable or keysTable
            local mt = getmetatable(keysTable)

            if mt and getmetatable(destination) == nil then
                setmetatable(destination, mt)
            end

            for k,v in pairs(keysTable) do
                if type(v) == 'table' then
                    destination[k] = copy_tables({}, v, valuesTable[k])
                else
                    local value = valuesTable[k]

                    if type(value) == 'boolean' then
                        value = value and 1 or 0
                    end

                    destination[k] = value
                end
            end

            return destination
        end

        local function resolve(easing_fn, previous, new, clock, duration)
            if type(new) == 'boolean' then new = new and 1 or 0 end
            if type(previous) == 'boolean' then previous = previous and 1 or 0 end

            local previous = easing_fn(clock, previous, new - previous, duration)

            if type(new) == 'number' then
                if math.abs(new-previous) <= .001 then
                    previous = new
                end

                if previous % 1 < .0001 then
                    previous = math.floor(previous)
                elseif previous % 1 > .9999 then
                    previous = math.ceil(previous)
                end
            end

            return previous
        end

        local function perform_easing(ntype, easing_fn, previous, new, clock, duration)
            if to_pairs[ntype] then
                for _, key in ipairs(to_pairs[ntype]) do
                    previous[key] = perform_easing(
                        type(v), easing_fn,
                        previous[key], new[key],
                        clock, duration
                    )
                end

                return previous
            end

            if ntype == 'table' then
                for k, v in pairs(new) do
                    previous[k] = previous[k] or v
                    previous[k] = perform_easing(
                        type(v), easing_fn,
                        previous[k], v,
                        clock, duration
                    )
                end

                return previous
            end

            return resolve(easing_fn, previous, new, clock, duration)
        end

        local adjusted_speed

        local new = function(default, easing_fn)
            if type(default) == 'boolean' then
                default = default and 1 or 0
            end

            local mt = { }
            local mt_data = {
                value = default or 0,
                easing = easing_fn or function(t, b, c, d)
                    return c * t / d + b
                end
            }

            function mt.update(self, duration, value, easing, ignore_adj_speed)
                if type(value) == 'boolean' then
                    value = value and 1 or 0
                end

                local clock = globals.frametime / native_GetTimescale()
                local duration = duration or .15
                local value_type = get_type(value)
                local target_type = get_type(self.value)

                assert(value_type == target_type, string.format('type mismatch. expected %s (received %s)', target_type, value_type))

                if self.value == value then
                    return value
                end

                if adjusted_speed and ignore_adj_speed ~= true then
                    duration = duration * adjusted_speed
                end

                if clock <= 0 or clock >= duration then
                    if target_type == 'imcolor' or target_type == 'vector' then
                        self.value = value:clone()
                    elseif target_type == 'table' then
                        copy_tables(self.value, value)
                    else
                        self.value = value
                    end
                else
                    local easing = easing or self.easing

                    self.value = perform_easing(
                        target_type, easing,
                        self.value, value,
                        clock, duration
                    )
                end

                return self.value
            end

            return setmetatable(mt, {
                __metatable = false,
                __call = mt.update,
                __index = mt_data
            })
        end

        local new_interp = function(initial_value)
            return setmetatable({
                previous = initial_value or 0
            }, {
                __call = function(self, new_value, mul)
                    local mul = mul or 1
                    local tickinterval = globals.tickinterval * mul
                    local difference = math.abs(new_value - self.previous)

                    if difference > 0 then
                        local clock = globals.frametime / native_GetTimescale()
                        local time = math.min(tickinterval, clock) / tickinterval

                        self.previous = self.previous + time * (new_value - self.previous)
                    else
                        self.previous = new_value
                    end

                    self.previous = (self.previous % 1 < .0001) and 0 or self.previous

                    return self.previous
                end
            })
        end

        local set_speed = function(new_speed)
            if new_speed == true then return adjusted_speed or 1 end
            if new_speed == nil then adjusted_speed = nil end

            if type(new_speed) == 'number' and new_speed >= 0 then
                adjusted_speed = new_speed
            end

            return adjusted_speed
        end

        return {
            new = new,
            new_interp = new_interp,
            set_speed = set_speed
        }
    end,

    ["ffi"] = function()
        return ffi
    end,
}

local loaded = {}
local loading = {}
local custom_require

local function make_env(modname)
    return setmetatable({ require = custom_require, _MODULE = modname }, { __index = _G })
end

local function load_embedded_module(lib, def)
    if loaded[lib] ~= nil then return loaded[lib] end
    if loading[lib] then error("circular require detected for module: " .. lib, 2) end
    loading[lib] = true

    local ret
    local t = type(def)
    if t == "function" then
        local ok, result = pcall(def, custom_require, lib)
        loading[lib] = nil
        if not ok then error(("failed to load module '%s': %s"):format(lib, tostring(result)), 2) end
        ret = result
    elseif t == "table" then
        loading[lib] = nil
        ret = def
    elseif t == "string" then
        if not compiler then
            loading[lib] = nil
            error(("module '%s' is stored as source string, but load/loadstring is unavailable"):format(lib), 2)
        end
        local chunk, err = compiler(def, "@" .. lib)
        if not chunk then
            loading[lib] = nil
            error(("failed to compile module '%s': %s"):format(lib, tostring(err)), 2)
        end
        if setfenv then setfenv(chunk, make_env(lib)) end
        local ok, result = pcall(chunk, lib)
        loading[lib] = nil
        if not ok then error(("failed to load module '%s': %s"):format(lib, tostring(result)), 2) end
        ret = result
    else
        loading[lib] = nil
        error(("unsupported embedded module type for '%s': %s"):format(lib, t), 2)
    end
    if ret == nil then ret = true end
    loaded[lib] = ret
    return ret
end

custom_require = function(lib)
    if lib == "ffi" then
        return ffi
    end
    local def = modules[lib]
    if def ~= nil then
        return load_embedded_module(lib, def)
    end
    return error("require: " .. lib)
end

require = custom_require

--LUASENSE FIX MADE BY 2K00  [all the fix was discovored and provided by E0n3x]

local l_clipboard_0 = require("neverlose/clipboard");
local l_pui_0 = require("neverlose/pui");
local l_inspect_0 = (function()
local r0_0 = {
  _DESCRIPTION = "human-readable representations of tables",
  _URL = "http://github.com/kikito/inspect.lua",
  _VERSION = "inspect.lua 3.1.0",
}
local r1_0 = tostring
r0_0.KEY = setmetatable({}, {
  __tostring = function() return "inspect.KEY" end,
})
r0_0.METATABLE = setmetatable({}, {
  __tostring = function() return "inspect.METATABLE" end,
})
local function r2_0(r0_23)
  return next, r0_23, nil
end
local function r3_0(r0_22)
  if r0_22:match("\"") and not r0_22:match("\'") then
    return "\'" .. r0_22 .. "\'"
  end
  return "\"" .. r0_22:gsub("\"", "\\\"") .. "\""
end
local r4_0 = {
  ["\u{7}"] = "\\a",
  ["\r"] = "\\r",
  ["\u{8}"] = "\\b",
  ["\u{c}"] = "\\f",
  ["\u{b}"] = "\\v",
  ["\n"] = "\\n",
  ["\t"] = "\\t",
}
local r5_0 = {}
for r9_0 = 0, 31, 1 do
  local r10_0 = string.char(r9_0)
  if not r4_0[r10_0] then
    r4_0[r10_0] = "\\" .. r9_0
    r5_0[r10_0] = string.format("\\%03d", r9_0)
  end
end
local function r6_0(r0_21)
  return r0_21:gsub("\\", "\\\\"):gsub("(%c)%f[0-9]", r5_0):gsub("%c", r4_0)
end
local function r7_0(r0_20)
  local r1_20 = type(r0_20)
  if r1_20 == "string" then
    r1_20 = r0_20:match("^[_%a][_%a%d]*$")
  else
    r1_20 = false
  end
  return r1_20
end
local function r8_0(r0_19, r1_19)
  local r2_19 = type(r0_19)
  if r2_19 == "number" then
    r2_19 = 1
    if r2_19 <= r0_19 and r0_19 <= r1_19 then
      r2_19 = math.floor(r0_19) == r0_19
    end
  else
    r2_19 = false
  end
  return r2_19
end
local r9_0 = {
  table = 4,
  ["function"] = 5,
  userdata = 6,
  thread = 7,
  string = 3,
  number = 1,
  boolean = 2,
}
local function r10_0(r0_18, r1_18)
  local r2_18 = type(r0_18)
  local r3_18 = type(r1_18)
  if r2_18 == r3_18 and (r2_18 == "string" or r2_18 == "number") then
    return r0_18 < r1_18
  end
  local r4_18 = r9_0[r2_18]
  local r5_18 = r9_0[r3_18]
  if r4_18 and r5_18 then
    return r9_0[r2_18] < r9_0[r3_18]
  elseif r4_18 then
    return true
  elseif r5_18 then
    return false
  end
  return r2_18 < r3_18
end
local function r11_0(r0_17)
  local r1_17 = 1
  local r2_17 = rawget(r0_17, r1_17)
  while r2_17 ~= nil do
    r1_17 = r1_17 + 1
    r2_17 = rawget(r0_17, r1_17)
  end
  return r1_17 - 1
end
local function r12_0(r0_16)
  local r1_16 = {}
  local r2_16 = 0
  local r3_16 = r11_0(r0_16)
  for r7_16, r8_16 in r2_0(r0_16) do
    if not r8_0(r7_16, r3_16) then
      r2_16 = r2_16 + 1
      r1_16[r2_16] = r7_16
    end
  end
  table.sort(r1_16, r10_0)
  return r1_16, r2_16, r3_16
end
local function r13_0(r0_15, r1_15)
  if not r1_15 then
    r1_15 = {}
  end
  if type(r0_15) == "table" then
    if not r1_15[r0_15] then
      r1_15[r0_15] = 1
      for r5_15, r6_15 in r2_0(r0_15) do
        r13_0(r5_15, r1_15)
        r13_0(r6_15, r1_15)
      end
      r13_0(getmetatable(r0_15), r1_15)
    else
      r1_15[r0_15] = r1_15[r0_15] + 1
    end
  end
  return r1_15
end
local function r14_0(r0_14)
  local r1_14 = {}
  local r2_14 = #r0_14
  for r6_14 = 1, r2_14, 1 do
    r1_14[r6_14] = r0_14[r6_14]
  end
  return r1_14, r2_14
end
local function r15_0(r0_13, ...)
  local r1_13 = {
    ...
  }
  local r2_13, r3_13 = r14_0(r0_13)
  for r7_13 = 1, #r0_13, 1 do
    r2_13[r3_13 + r7_13] = r1_13[r7_13]
  end
  return r2_13
end
local function r16_0(r0_12, r1_12, r2_12, r3_12)
  if r1_12 == nil then
    return nil
  end
  if r3_12[r1_12] then
    return r3_12[r1_12]
  end
  local r4_12 = r0_12(r1_12, r2_12)
  if type(r4_12) == "table" then
    local r5_12 = {}
    r3_12[r1_12] = r5_12
    local r6_12 = nil
    for r10_12, r11_12 in r2_0(r4_12) do
      r6_12 = r16_0(r0_12, r10_12, r15_0(r2_12, r10_12, r0_0.KEY), r3_12)
      if r6_12 ~= nil then
        r5_12[r6_12] = r16_0(r0_12, r11_12, r15_0(r2_12, r6_12), r3_12)
      end
    end
    local r7_12 = r16_0(r0_12, getmetatable(r4_12), r15_0(r2_12, r0_0.METATABLE), r3_12)
    if type(r7_12) ~= "table" then
      r7_12 = nil
    end
    setmetatable(r5_12, r7_12)
    r4_12 = r5_12
  end
  return r4_12
end
local r17_0 = {}
local r18_0 = {
  __index = r17_0,
}
function r17_0.puts(r0_11, ...)
  local r1_11 = {
    ...
  }
  local r2_11 = r0_11.buffer
  local r3_11 = #r0_11
  for r7_11 = 1, #r0_11, 1 do
    r2_11[r3_11 + 1] = r1_11[r7_11]
  end
end
function r17_0.down(r0_10, r1_10)
  r0_10.level = r0_10.level + 1
  r1_10()
  r0_10.level = r0_10.level - 1
end
function r17_0.tabify(r0_9)
  r0_9:puts(r0_9.newline, string.rep(r0_9.indent, r0_9.level))
end
function r17_0.alreadyVisited(r0_8, r1_8)
  return r0_8.ids[r1_8] ~= nil
end
function r17_0.getId(r0_7, r1_7)
  local r2_7 = r0_7.ids[r1_7]
  if not r2_7 then
    local r3_7 = type(r1_7)
    local r4_7 = r0_7.maxIds[r3_7]
    if not r4_7 then
      r4_7 = 0
    end
    r2_7 = r4_7 + 1
    r0_7.maxIds[r3_7] = r2_7
    r0_7.ids[r1_7] = r2_7
  end
  return r1_0(r2_7)
end
function r17_0.putKey(r0_6, r1_6)
  if r7_0(r1_6) then
    return r0_6:puts(r1_6)
  end
  r0_6:puts("[")
  r0_6:putValue(r1_6)
  r0_6:puts("]")
end
function r17_0.putTable(r0_4, r1_4)
  -- [FIXED GOTO LOGIC]
  if r1_4 == r0_0.KEY or r1_4 == r0_0.METATABLE then
      r0_4:puts(r1_0(r1_4))
  elseif r0_4:alreadyVisited(r1_4) then
      local r5_4 = r0_4:getId(r1_4)
      r0_4:puts("<table ", r5_4, ">")
  else
      local r3_4 = r0_4.depth
      if r3_4 <= r0_4.level then
        r0_4:puts("{...}")
      else
        r3_4 = 1
        if r3_4 < r0_4.tableAppearances[r1_4] then
          local r5_4 = r0_4:getId(r1_4)
          r0_4:puts("<", r5_4, ">")
        end
        local r2_4, r3_4, r4_4 = r12_0(r1_4)
        local r5_4 = getmetatable(r1_4)
        r0_4:puts("{")
        r0_4:down(function()
          local r0_5 = 0
          for r4_5 = 1, r4_4, 1 do
            if r0_5 > 0 then
              r0_4:puts(",")
            end
            r0_4:puts(" ")
            r0_4:putValue(r1_4[r4_5])
            r0_5 = r0_5 + 1
          end
          for r4_5 = 1, r3_4, 1 do
            local r5_5 = r2_4[r4_5]
            if r0_5 > 0 then
              r0_4:puts(",")
            end
            r0_4:tabify()
            r0_4:putKey(r5_5)
            r0_4:puts(" = ")
            r0_4:putValue(r1_4[r5_5])
            r0_5 = r0_5 + 1
          end
          if type(r5_4) == "table" then
            if r0_5 > 0 then
              r0_4:puts(",")
            end
            r0_4:tabify()
            r0_4:puts("<metatable> = ")
            r0_4:putValue(r5_4)
          end
        end)
        if 0 < r3_4 or type(r5_4) == "table" then
          r0_4:tabify()
        elseif r4_4 > 0 then
          r0_4:puts(" ")
        end
        r0_4:puts("}")
      end
  end
end
function r17_0.putValue(r0_3, r1_3)
  local r2_3 = type(r1_3)
  if r2_3 == "string" then
    r0_3:puts(r3_0(r6_0(r1_3)))
  elseif r2_3 == "number" or r2_3 == "boolean" or r2_3 == "nil" or r2_3 == "cdata" or r2_3 == "ctype" then
    r0_3:puts(r1_0(r1_3))
  elseif r2_3 == "table" then
    r0_3:putTable(r1_3)
  else
    r0_3:puts("<", r2_3, " ", r0_3:getId(r1_3), ">")
  end
end
function r0_0.inspect(r0_2, r1_2)
  if not r1_2 then
    r1_2 = {}
  end
  local r2_2 = r1_2.depth
  if not r2_2 then
    r2_2 = math.huge
  end
  local r3_2 = r1_2.newline
  if not r3_2 then
    r3_2 = "\n"
  end
  local r4_2 = r1_2.indent
  if not r4_2 then
    r4_2 = "\t"
  end
  local r5_2 = r1_2.process
  if r5_2 then
    r0_2 = r16_0(r5_2, r0_2, {}, {})
  end
  local r6_2 = setmetatable({
    level = 0,
    depth = r2_2,
    buffer = {},
    ids = {},
    maxIds = {},
    newline = r3_2,
    indent = r4_2,
    tableAppearances = r13_0(r0_2),
  }, r18_0)
  r6_2:putValue(r0_2)
  return table.concat(r6_2.buffer)
end
setmetatable(r0_0, {
  __call = function(r0_1, ...)
    return r0_0.inspect(...)
  end,
})
return r0_0
end)()
local l_gradient_0 = (function()
-- [[ FIX GRADIENT LIBRARY ]]
local r0_0 = "[%z\u{1}-\u{7f}\xc2-\xf4][\x80-\xbf]*"
local function r1_0(r0_31, r1_31)
  if r0_31 < 0 then
    r0_31 = r1_31 + r0_31 + 1
  end
  return r0_31
end

-- FIX: Declarăm variabila înainte pentru a fi vizibilă în funcțiile din interior
local r2_0 
r2_0 = {
  map = function(r0_30, r1_30, r2_30)
    local r3_30 = 0
    if r2_30 then
      for r7_30, r8_30 in r0_30.gmatch(r0_30, "()" .. r0_0 .. "()") do
        r3_30 = r3_30 + 1
        r1_30(r3_30, r8_30 - r7_30, r7_30)
      end
    else
      for r7_30, r8_30 in r0_30.gmatch(r0_30, "()(" .. r0_0 .. ")") do
        r3_30 = r3_30 + 1
        r1_30(r3_30, r8_30, r7_30)
      end
    end
  end,
  chars = function(r0_28, r1_28)
    return coroutine.wrap(function()
      return r2_0.map(r0_28, coroutine.yield, r1_28)
    end)
  end,
  len = function(r0_27)
    return select(2, r0_27:gsub("[^\x80-\xc1]", ""))
  end,
  replace = function(r0_26, r1_26)
    return r0_26:gsub(r0_0, r1_26)
  end,
  reverse = function(r0_24)
    r0_24 = r0_24:gsub(r0_0, function(r0_25)
      local r1_25 = #r0_25
      if r1_25 > 1 then
        r1_25 = r0_25:reverse()
      else
        r1_25 = false
      end
      return r1_25
    end)
    return r0_24:reverse()
  end,
  strip = function(r0_22)
    return r0_22:gsub(r0_0, function(r0_23)
      local r1_23 = #r0_23
      if r1_23 > 1 then
        r1_23 = ""
      else
        r1_23 = false
      end
      return r1_23
    end)
  end,
  sub = function(r0_21, r1_21, r2_21)
    local r3_21 = r2_0.len(r0_21)
    r1_21 = r1_0(r1_21, r3_21)
    
    -- [FIX GOTO LOGIC]
    if r2_21 then
      r2_21 = r1_0(r2_21, r3_21)
    end
    if not r2_21 then
      r2_21 = r3_21
    end
    -- [END FIX]

    if r1_21 < 1 then
      r1_21 = 1
    end
    if r3_21 < r2_21 then
      r2_21 = r3_21
    end
    if r2_21 < r1_21 then
      return ""
    end
    local r4_21 = r2_21 - r1_21
    local r5_21 = r2_0.chars(r0_21, true)
    for r9_21 = 1, r1_21 - 1, 1 do
      r5_21()
    end
    local r6_21, r7_21 = select(2, r5_21())
    if r4_21 == 0 then
      return string.sub(r0_21, r7_21, r7_21 + r6_21 - 1)
    end
    r1_21 = r7_21
    for r11_21 = 1, r4_21 - 1, 1 do
      r5_21()
    end
    r6_21, r7_21 = select(2, r5_21())
    return string.sub(r0_21, r1_21, r7_21 + r6_21 - 1)
  end,
}

local function r3_0(r0_20)
  if #r0_20 < 2 then
    error("2 or more colors required!")
  end
  if r0_20[1][2] ~= 0 then
    error("First color must start at position 0!")
  end
  if r0_20[#r0_20][2] ~= 1 then
    error("Last color must end at position 1!")
  end
  local r1_20 = 0
  for r5_20, r6_20 in ipairs(r0_20) do
    local r7_20 = r6_20[2]
    if not r7_20 then
      error("Color doesn\'t have a stop property!")
    end
    if r7_20 < 0 or 1 < r7_20 then
      error("Color stop is out of boundaries!")
    end
    if r1_20 <= r7_20 then
      r1_20 = r7_20
    else
      error("Color stops are out of order!")
    end
  end
  return r0_20
end
local function r4_0(r0_19, r1_19, r2_19)
  r1_19 = (r1_19 + r2_19 - 1) % #r0_19 + 1
  return r0_19[r1_19], r1_19
end
local function r5_0(r0_18, r1_18)
  return color((r0_18.r / 255) ^ (r1_18 / 1) * 255, (r0_18.g / 255) ^ (r1_18 / 1) * 255, (r0_18.b / 255) ^ (r1_18 / 1) * 255)
end
local function r6_0(r0_17, r1_17)
  local r2_17 = #r0_17
  local r4_17 = r1_17 / (r2_17 - 1) / 1
  local r5_17 = math.floor(r4_17) + 1
  if r4_17 == r2_17 - 1 then
    return r0_17[r2_17]
  end
  return r0_17[r5_17]:lerp(r0_17[r5_17 + 1], r4_17 % 1)
end
local r7_0 = {}
local r8_0 = {}
r8_0.__index = r8_0
local r9_0 = {}
r9_0.__index = r9_0
function r8_0.linear(r0_16, r1_16)
  if type(r0_16[1]) ~= "table" then
    return r6_0(r0_16, r1_16)
  end
  local r2_16 = r3_0(r0_16)
  local r3_16 = 1
  while r2_16[r3_16 + 1][2] < r1_16 do
    r3_16 = r3_16 + 1
  end
  return r2_16[r3_16][1]:lerp(r2_16[r3_16 + 1][1], (r1_16 - r2_16[r3_16][2]) / (r2_16[r3_16 + 1][2] - r2_16[r3_16][2]))
end
function r8_0.text(r0_15, r1_15, r2_15)
  local r3_15 = ""
  local r4_15 = r2_0.len(r0_15) - 1
  for r8_15, r9_15, r10_15 in r2_0.chars(r0_15) do
    local r12_15 = r8_0.linear(r2_15, (r8_15 - 1) / r4_15):to_hex()
    if r1_15 then
      r12_15 = r12_15:sub(1, 6)
    end
    r3_15 = string.format("%s\u{7}%s%s", r3_15, r12_15, r2_0.sub(r0_15, r8_15, r8_15))
  end
  return r3_15
end
function r8_0.text_animate(r0_14, r1_14, r2_14)
  local r3_14 = r0_14 .. r1_14
  for r7_14, r8_14 in ipairs(r2_14) do
    r3_14 = r3_14 .. tostring(r8_14)
  end
  local r4_14 = r7_0[r3_14]
  if not r4_14 then
    r4_14 = setmetatable({}, r9_0)
    r4_14.text = r0_14
    r4_14.animated_text = ""
    r4_14.speed = r1_14 / 1
    r4_14.current_pos = 0
    r4_14.colors = r2_14
    local r6_14 = r4_14.colors
    r4_14.colors[#r0_14 + 1] = r4_14.colors[1]
    r4_14:populate_gradient()
  end
  r7_0[r3_14] = r4_14
  return r4_14
end
function r9_0.populate_gradient(r0_13)
  local r1_13 = r0_13:get_colors()
  local r2_13 = r0_13:get_text()
  local r3_13 = {}
  local r6_13 = r2_13 .. string.rep("|", math.floor(r2_0.len(r2_13) / (#r0_13 - 2) + 0.5))
  local r7_13 = r2_0.len(r6_13)
  for r11_13, r12_13, r13_13 in r2_0.chars(r6_13) do
    r3_13[#r0_13 + 1] = r8_0.linear(r1_13, (r11_13 - 1) / (r7_13 - 1)):to_hex()
  end
  r0_13.gradients = r3_13
  r0_13:populate_text()
end
function r9_0.populate_text(r0_12)
  local r1_12 = r0_12.text
  r0_12.animated_text = ""
  for r5_12, r6_12, r7_12 in r2_0.chars(r1_12) do
    r0_12.animated_text = string.format("%s\u{7}%s%s", r0_12.animated_text, r4_0(r0_12.gradients, r5_12, 0), r2_0.sub(r1_12, r5_12, r5_12))
  end
end
function r9_0.animate(r0_11)
  if math.abs(r0_11.current_pos) >= 1 then
    r0_11.current_pos = r0_11.speed * globals.frametime
  end
  r0_11.animated_text = ""
  r0_11.current_pos = r0_11.current_pos + r0_11.speed * globals.frametime
  local r1_11 = r0_11.text
  local r4_11 = r0_11.gradients
  local r2_11 = math.floor(r0_11.current_pos * #r0_11)
  for r6_11, r7_11, r8_11 in r2_0.chars(r1_11) do
    r0_11.animated_text = string.format("%s\u{7}%s%s", r0_11.animated_text, r4_0(r0_11.gradients, r6_11, r2_11), r2_0.sub(r1_11, r6_11, r6_11))
  end
end
function r9_0.get_colors(r0_10)
  return r0_10.colors
end
function r9_0.set_colors(r0_9, r1_9)
  local r2_9 = false
  for r6_9, r7_9 in ipairs(r1_9) do
    if r0_9.colors[r6_9] ~= r7_9 then
      r2_9 = true
    end
  end
  if r2_9 then
    r0_9.colors = r1_9
    local r4_9 = r0_9.colors
    r0_9.colors[#r0_9 + 1] = r0_9.colors[1]
    r0_9:populate_gradient()
  end
end
function r9_0.get_speed(r0_8)
  return r0_8.speed / 1
end
function r9_0.set_speed(r0_7, r1_7)
  r0_7.speed = r1_7 / 1
end
function r9_0.get_current_position(r0_6)
  return r0_6.current_pos
end
function r9_0.set_current_position(r0_5, r1_5)
  r0_5.current_pos = math.clamp(r1_5, -1, 1)
  r0_5.animated_text = ""
  local r2_5 = r0_5.text
  local r5_5 = r0_5.gradients
  local r3_5 = math.floor(r0_5.current_pos * #r0_5)
  for r7_5, r8_5, r9_5 in r2_0.chars(r2_5) do
    r0_5.animated_text = string.format("%s\u{7}%s%s", r0_5.animated_text, r4_0(r0_5.gradients, r7_5, r3_5), r2_0.sub(r2_5, r7_5, r7_5))
  end
end
function r9_0.get_text(r0_4)
  return r0_4.text
end
function r9_0.set_text(r0_3, r1_3)
  if r0_3.text ~= r1_3 then
    r0_3.text = r1_3
    r0_3:populate_gradient()
  end
end
function r9_0.get_animated_text(r0_2)
  return r0_2.animated_text
end
function r9_0.gamma_correct(r0_1, r1_1)
  for r5_1, r6_1 in ipairs(r0_1.gradients) do
    r0_1.gradients[r5_1] = r5_0(color(r6_1), r1_1):to_hex()
  end
end
return r8_0
end)()

local _ = require("neverlose/base64");
local l_smoothy_0 = require("neverlose/smoothy");

local _ = (function()
    -- LISTENER [v:0101110]
local is_syncing = false
local lifetime = 120
local last_verification = 0
local debugging_privelege_level = 0
local voice_callback = events.voice_message

-- ConVars
local voice_modenable = cvar.voice_modenable

local cl_mute_enemy_team = cvar.cl_mute_enemy_team
local cl_mute_all_but_friends_and_party = cvar.cl_mute_all_but_friends_and_party
local cl_mute_player_after_reporting_abuse = cvar.cl_mute_player_after_reporting_abuse

local last_availability_chk = 0
local last_voice_enabled = 1

cvar.voice_buffer_debug:set_callback(function(cvar_obj, previous, new)
    local value = tonumber(new)
    local prev_value = tonumber(previous)

    debugging_privelege_level = 0

    if value > 1 then
        cvar_obj:int(prev_value)
        debugging_privelege_level = math.clamp(value-1, 0, 2)
    end
end)

-- Other
local CHEAT = {
    NEVERLOSE = 'NL',
    GAMESENSE = 'GS',
    PRIMORDIAL = 'PRMD',
    FATALITY = 'FT',
    ONETAP = 'OT',
    PANDORA = 'PD',
    NIXWARE = 'NW',
    EVOLVE = 'EVO',
    SPIRT = 'SPRT'
}

local ICONS = {
    [CHEAT.NEVERLOSE] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/neverlose.png',
    [CHEAT.GAMESENSE] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/gamesense.png',
    [CHEAT.PRIMORDIAL] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/primordial.png',
    [CHEAT.FATALITY] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/fatality.png',
    [CHEAT.ONETAP] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/onetap.png',
    [CHEAT.PANDORA] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/pandora.png',
    [CHEAT.NIXWARE] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/nixware.png',
    [CHEAT.EVOLVE] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/ev0.png',
    [CHEAT.SPIRT] = 'https://raw.githubusercontent.com/tickcount/.p2c-icons/main/spirthack.png'
}

-- Parse Database
local base64 = require 'neverlose/base64'

local function xorstr(...)
    local str = table.concat({ ... })
    local key = '64 0e 87 3c e5 b1 4f c8 05 9a'

    local strlen, keylen = #str, #key
    local strbuf = ffi.new('char[?]', strlen+1)
    local keybuf = ffi.new('char[?]', keylen+1)

    ffi.copy(strbuf, str)
    ffi.copy(keybuf, key)

    for i=0, strlen-1 do
        strbuf[i] = bit.bxor(strbuf[i], keybuf[i % keylen])
    end

    return ffi.string(strbuf, strlen)
end

local database, database_name do
    database_name = '@vclistener'

    local decrypt_database = function(response)
        return json.parse(xorstr(base64.decode(response)))
    end

    local success, data = pcall(decrypt_database, db[database_name]) do
        database = success == true and data or { }
        db[database_name] = nil
    end
end

-- Crc32
local crc32 = (function()
    local s_crc32 = ffi.new('const uint32_t[16]', {
		0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac,
		0x76dc4190, 0x6b6b51f4, 0x4db26158, 0x5005713c,
		0xedb88320, 0xf00f9344, 0xd6d6a3e8, 0xcb61b38c,
		0x9b64c2b0, 0x86d3d2d4, 0xa00ae278, 0xbdbdf21c
	})

	function mz_crc32(buff, buf_len, crc)
		crc = crc or 0

		local crcu32 = crc
		local ptr = ffi.cast('const uint8_t*', buff)

		if ptr == nil then
			return 0
		end

		crcu32 = bit.bnot(crcu32)

		while buf_len > 0 do
			local b = ptr[0]

			crcu32 = bit.bxor(bit.rshift(crcu32, 4), s_crc32[bit.bxor(bit.band(crcu32, 0xF), bit.band(b, 0xF))])
			crcu32 = bit.bxor(bit.rshift(crcu32, 4), s_crc32[bit.bxor(bit.band(crcu32, 0xF), bit.rshift(b, 4))])

			ptr = ptr + 1
			buf_len = buf_len - 1
		end

		return bit.bnot(crcu32)
	end

	local function CRC32(src, len)
		if not len then
			if type(src) == 'string' then
				len = #src
			elseif type(src) == 'cdata' then
				len = ffi.sizeof(src)
			end
		end

		if not len then
            return nil
        end

		return mz_crc32(src, len)
	end

	return CRC32
end)()

-- Common Functions
local function sort(a, b) return a.is_reliable and a.amount > b.amount end
local function get_time() return globals.realtime end

local is_using_gamesense, get_player_info do
    ffi.cdef [[
        void* VirtualAlloc(void* lpAddress, size_t dwSize, uint32_t flAllocationType, uint32_t flProtect);
        int VirtualFree(void* lpAddress, size_t dwSize, uint32_t dwFreeType);
    ]]

    local function allocate_shellcode(buffer)
        assert(type(buffer) == 'table', 'invalid shellcode')

        local sizeof = #buffer
        local base_address = ffi.C.VirtualAlloc(nil, sizeof, 0x1000, 0x40) -- MEM_COMMIT, PAGE_EXECUTE_READWRITE

        assert(base_address ~= nil, 'allocation failed')

        ffi.gc(base_address, function(memory) ffi.C.VirtualFree(memory, sizeof, 0x00008000) end)
        ffi.copy(base_address, ffi.new('char[?]', sizeof, buffer), sizeof)

        return base_address
    end

    local player_info_t = ffi.typeof [[
        struct {
            uint64_t version;
            uint32_t xuid_low;
            uint32_t xuid_high;
            char name[128];
            int userid;
            char guid[33];
            uint32_t friendsid;
            char friendsname[128];
            bool isbot;
            bool ishltv;
            uint32_t customfiles[4];
            uint8_t filesdownloaded;
        }
    ]]

    local native_GetPlayerInfo = utils.get_vfunc('engine.dll', 'VEngineClient014', 8, 'bool(__thiscall*)(void*, int, $*)', player_info_t)

    get_player_info = function(entindex)
        if type(entindex) ~= 'number' then
            return
        end

        local out = player_info_t()
        out.version = 0xFFFFFFFFFFFFF002ULL

        if native_GetPlayerInfo(entindex, out) then
            return out
        end
    end

    is_using_gamesense = ffi.cast('bool(__fastcall*)(void*, uint32_t)', allocate_shellcode {
        0x81, 0xEC, 0x4C, 0x01, 0x00, 0x00, 0x53, 0x55, 0x56, 0x8B, 0xF1, 0x89, 0x54, 0x24, 0x54, 0x33,
        0xDB, 0xC7, 0x44, 0x24, 0x10, 0x68, 0x33, 0x05, 0x97, 0x57, 0xC7, 0x44, 0x24, 0x18, 0x36, 0x06,
        0xD4, 0xEA, 0xBF, 0x00, 0x01, 0x00, 0x00, 0x8B, 0x46, 0x10, 0x8B, 0x4E, 0x14, 0x89, 0x44, 0x24,
        0x30, 0x8B, 0x46, 0x28, 0x89, 0x44, 0x24, 0x38, 0x8B, 0x46, 0x24, 0x89, 0x44, 0x24, 0x3C, 0x8B,
        0x46, 0x2C, 0x89, 0x44, 0x24, 0x40, 0x8B, 0xC3, 0xC7, 0x44, 0x24, 0x1C, 0x4F, 0xC4, 0xA4, 0x3E,
        0xC7, 0x44, 0x24, 0x20, 0x85, 0xB2, 0xAC, 0x0F, 0x89, 0x4C, 0x24, 0x34, 0x89, 0x5C, 0x24, 0x28,
        0x88, 0x44, 0x04, 0x5C, 0x40, 0x3B, 0xC7, 0x72, 0xF7, 0x8A, 0xF3, 0x8B, 0xF3, 0x8A, 0x54, 0x34,
        0x5C, 0x8B, 0xC6, 0x83, 0xE0, 0x0F, 0x8A, 0x44, 0x04, 0x14, 0x02, 0xC2, 0x02, 0xF0, 0x0F, 0xB6,
        0xCE, 0x8A, 0x44, 0x0C, 0x5C, 0x88, 0x44, 0x34, 0x5C, 0x46, 0x88, 0x54, 0x0C, 0x5C, 0x3B, 0xF7,
        0x72, 0xDB, 0x8A, 0xE3, 0x8B, 0xFB, 0xBD, 0x80, 0x00, 0x00, 0x00, 0x8A, 0xF4, 0xFE, 0xC6, 0x0F,
        0xB6, 0xF6, 0x8A, 0x54, 0x34, 0x5C, 0x02, 0xE2, 0x0F, 0xB6, 0xCC, 0x8A, 0x44, 0x0C, 0x5C, 0x88,
        0x44, 0x34, 0x5C, 0x88, 0x54, 0x0C, 0x5C, 0x83, 0xED, 0x01, 0x75, 0xE1, 0xFE, 0xC6, 0x0F, 0xB6,
        0xF6, 0x8A, 0x54, 0x34, 0x5C, 0x8A, 0xDA, 0x02, 0xDC, 0x0F, 0xB6, 0xCB, 0x8A, 0x44, 0x0C, 0x5C,
        0x88, 0x44, 0x34, 0x5C, 0x88, 0x54, 0x0C, 0x5C, 0x8A, 0x44, 0x34, 0x5C, 0x02, 0xC2, 0x0F, 0xB6,
        0xC0, 0x8A, 0x44, 0x04, 0x5C, 0x8A, 0xE3, 0x30, 0x44, 0x3C, 0x30, 0x47, 0x83, 0xFF, 0x14, 0x72,
        0xCB, 0x33, 0xFF, 0x89, 0x7C, 0x24, 0x2C, 0x8B, 0xEF, 0xC7, 0x44, 0x24, 0x24, 0x0F, 0x00, 0x00,
        0x00, 0x8B, 0x7C, 0x24, 0x24, 0xD1, 0xED, 0x89, 0x6C, 0x24, 0x48, 0x0F, 0xB7, 0x4C, 0xAC, 0x32,
        0x8B, 0xC1, 0x0F, 0xBF, 0xC9, 0x89, 0x44, 0x24, 0x54, 0x0F, 0xB7, 0x44, 0xAC, 0x34, 0xBD, 0x85,
        0x8E, 0xD5, 0x91, 0x8B, 0xD0, 0x89, 0x4C, 0x24, 0x44, 0x8B, 0xD8, 0x89, 0x54, 0x24, 0x4C, 0x8B,
        0xC1, 0x0F, 0xB7, 0xF0, 0x2B, 0xDD, 0x24, 0x0F, 0x8B, 0xD5, 0x8A, 0xC8, 0xD1, 0xC2, 0x66, 0xD3,
        0xCB, 0x8B, 0xEA, 0x66, 0x8B, 0xC3, 0xD1, 0xC5, 0x66, 0x33, 0xC6, 0x2B, 0xF2, 0x0F, 0xB7, 0xD8,
        0x8A, 0xCB, 0x80, 0xE1, 0x0F, 0x66, 0xD3, 0xCE, 0x66, 0x33, 0xF0, 0x0F, 0xB7, 0xCE, 0x0F, 0xB7,
        0xC6, 0x83, 0xEF, 0x01, 0x75, 0xCB, 0x8B, 0x7C, 0x24, 0x28, 0x8B, 0xC5, 0x2B, 0xD8, 0x89, 0x6C,
        0x24, 0x24, 0x33, 0x5C, 0x24, 0x50, 0x83, 0xC7, 0x02, 0x8B, 0x6C, 0x24, 0x48, 0xD1, 0xC0, 0x2B,
        0xC8, 0x89, 0x7C, 0x24, 0x28, 0x8B, 0x44, 0x24, 0x4C, 0x33, 0x4C, 0x24, 0x2C, 0x0F, 0xB7, 0xC0,
        0x89, 0x44, 0x24, 0x50, 0x8B, 0x44, 0x24, 0x54, 0x0F, 0xB7, 0xC0, 0x66, 0x89, 0x5C, 0xAC, 0x34,
        0x66, 0x89, 0x4C, 0xAC, 0x32, 0x89, 0x44, 0x24, 0x2C, 0x83, 0xFF, 0x09, 0x0F, 0x82, 0x45, 0xFF,
        0xFF, 0xFF, 0x8B, 0x44, 0x24, 0x30, 0x8B, 0x4C, 0x24, 0x58, 0xC1, 0xF8, 0x10, 0xC1, 0xF9, 0x10,
        0x33, 0xC1, 0xB9, 0x24, 0x24, 0x00, 0x00, 0x5F, 0x5E, 0x66, 0x3B, 0xC1, 0x5D, 0x0F, 0x94, 0xC0,
        0x5B, 0x81, 0xC4, 0x4C, 0x01, 0x00, 0x00, 0xC3
    })
end

local function is_voice_packet_reliable(ctx)
	local _msg = ffi.cast('uintptr_t*', ctx[0])

	if bit.band(bit.rshift(_msg[13], 4), 1) == 1 and ffi.cast('uintptr_t*', _msg[6] + 16)[0] ~= 0 then
		return false
	end

	if bit.band(bit.rshift(_msg[13], 6), 1) == 0 then
		return false
	end

	if _msg[8] ~= 0 then
		return false
	end

	if bit.band(_msg[13], 0x185) ~= 0x185 then
		return false
	end

	return true
end

function is_valid_entity(ent)
    if ent == nil then return false end
    local success, _ = pcall(function() return ent:get_index() end)
    return success
end

local function get_signature(ctx)
    if type(ctx) ~= 'userdata' or ctx.entity == nil then
        return nil
    end

    if not is_valid_entity(ctx.entity) then
        return nil
    end

    if ctx.entity == entity.get_local_player() then
        return nil
    end

    local packet_reliable = is_voice_packet_reliable(ctx)
    local pct = ffi.cast('uint16_t*', ffi.cast('uint32_t', ctx[0]) + 16)[0]

    local player_info = get_player_info(ctx.entity:get_index())

    if player_info == nil or (ctx.sequence_bytes == 0 and ctx.section_number == 0 and ctx.uncompressed_sample_offset == 0) then
        return
    end

    local voice_hash = bit.lshift(
        ctx.sequence_bytes +
        ctx.section_number +
        ctx.uncompressed_sample_offset, 4
    ) % 0x100000000

    if packet_reliable == true then
        if ctx.is_nl then
            return CHEAT.NEVERLOSE, voice_hash
        end

        if is_using_gamesense(ctx[0], player_info.xuid_low) then
            return CHEAT.GAMESENSE, voice_hash
        end

        do
            local buffer = ctx.buffer

            -- parse buffer and preserve variables
            local packet = buffer:read_bits(16)
            local player_idx = buffer:read_bits(7) + 1
            local position = vector(buffer:read_coord(), buffer:read_coord(), buffer:read_coord())
            local tickcount = buffer:read_bits(32)
            local health = buffer:read_bits(7)
            local idk = buffer:read_bits(32)

            -- reset buffer
            buffer:reset()

            -- VERIFY PACKET
            local sent_entity = entity.get(player_idx)
            local time_difference = globals.server_tick - tickcount

            if sent_entity and is_valid_entity(sent_entity) and sent_entity:is_alive() and health >= 0 and health <= 127 then
                if time_difference > 0 and time_difference * globals.tickinterval < 1 then
                    if math.abs((globals.curtime * .5) - pct) <= 2 then
                        if packet == 0xBEEF then
                            return CHEAT.NIXWARE, voice_hash
                        end

                        if packet == 0xD0D0 then
                            return CHEAT.SPIRT, voice_hash
                        end
                    end

                    return nil
                end
            end
        end

        if pct == 0x7FFA then return CHEAT.FATALITY, voice_hash end
        if pct == 0x57FA then return CHEAT.ONETAP, voice_hash end
        if pct == 0x7FFC or pct == 0x7FFD then return CHEAT.EVOLVE, voice_hash end
        if pct == 0x695B or pct == 0xAFF1 or pct == 0x1B39 then return CHEAT.PANDORA, voice_hash end

        goto packet_end
    end

    do
        -- PRIMORDIAL
        local sequence_bytes = ctx.sequence_bytes
        local uncompressed_sample_offset = ctx.uncompressed_sample_offset

        local thing = bit.bxor(
            bit.band(sequence_bytes, 0xFF),
            bit.band(bit.rshift(uncompressed_sample_offset, 16), 0xFF)
        ) - bit.rshift(sequence_bytes, 16)

        if packet_reliable == false and bit.band(thing, 0xFF) == 0x4d then
            local ent_index = bit.band(bit.bxor(
                bit.rshift(sequence_bytes, 16),
                bit.rshift(sequence_bytes, 8)
            ), 0xFF)

            local shared_entity =
                ent_index >= 1 and ent_index <= 64 and
                entity.get(ent_index)

            if shared_entity and is_valid_entity(shared_entity) and is_valid_entity(ctx.entity) and shared_entity == ctx.entity then
                -- Only account for packets where primordial sends itself (entity == sent_entity)
                return CHEAT.PRIMORDIAL, voice_hash
            end
        end
    end

    ::packet_end::

    if backup_indexes == nil or debugging_privelege_level == 0 then
        backup_indexes = { }
    end

    if debugging_privelege_level > 0 then
        if not is_valid_entity(ctx.entity) then
            return nil
        end
        local should_print = false
        local reliability_color = packet_reliable and '\aC0FF91' or '\aFF3E3E'

        if debugging_privelege_level == 1 and pct ~= backup_indexes[ctx.entity:get_index()] then
            backup_indexes[ctx.entity:get_index()] = pct
            should_print = true
        end

        if should_print or debugging_privelege_level == 2 then
            print_raw(string.format(
                '\a9BF0EB[revealer] \aBABFCCentity: [%s] | pct: %s%d [0x%X] \aBABFCC[seqb: \aE4AF36%d\aBABFCC | secn: \aE4AF36%d\aBABFCC | ucso: \aE4AF36%d\aBABFCC]',
                ctx.entity:get_name(), reliability_color, pct, pct,
                ctx.sequence_bytes, ctx.section_number, ctx.uncompressed_sample_offset
            ))
        end
    end

    return nil
end

local function update_reliability(db)
    local sgn = { }

    for i, record in ipairs(db.records) do
        local did_find = false

        for n, val in pairs(sgn) do
            if val.signature == record.signature then
                val.amount = val.amount + 1
                val.time = math.max(val.time, record.time)

                if not val.is_reliable then
                    val.is_reliable =
                        val.amount > 4 or record.is_shared
                end

                did_find = true
                break
            end
        end

        if not did_find then
            sgn[#sgn+1] = {
                amount = 1,
                is_reliable = false,
                time = record.time,
                signature = record.signature,
            }
        end
    end

    table.sort(sgn, sort)

    db.sorted_records = sgn
end

local function verify_players(ignore_verification)
    local real_time = get_time()

    if ignore_verification ~= true then
        if math.abs(last_verification - real_time) <= 1 then
            return
        end

        last_verification = real_time
    end

    local players = { }
    local should_refresh = false

    entity.get_players(false, true, function(player)
        if is_valid_entity(player) then
            players[tostring(player:get_xuid())] = player
        end
    end)

    for xuid, player in pairs(database) do
        if players[xuid] == nil or player.heartbeat > real_time or real_time-player.heartbeat >= lifetime or #player.records <= 0 then
            database[xuid] = nil
            should_refresh = true
        else
            local new_record_tbl = { }

            for id, value in ipairs(player.records) do
                if value ~= nil and value.time > real_time or real_time-value.time <= lifetime then
                    new_record_tbl[#new_record_tbl+1] = value
                end
            end

            if #new_record_tbl <= 0 then
                database[xuid] = nil
                should_refresh = true
            else
                player.records = new_record_tbl
                update_reliability(player)
            end
        end
    end

    if should_refresh == true then
        local new_database = { }

        for id, value in pairs(database) do
            if value ~= nil then
                new_database[id] = value
            end
        end

        database = new_database
    end

    return database
end

local function add_record(player, software, via_shared, custom_time, voice_hash)
    if player == nil or software == nil then
        return
    end

    if not is_valid_entity(player) then
        return
    end

    -- CHEATCHECk
    local did_find = false

    for name, val in pairs(CHEAT) do
        if software == val then
            did_find = true
            break
        end
    end

    if not did_find then
        return
    end

    local real_time = custom_time or get_time()
    local xuid = tostring(player:get_xuid())

    via_shared = via_shared or false

    database[xuid] = database[xuid] or {
        heartbeat = 0,

        records = { },
        sorted_records = { },
    }

    do
        local this = database[xuid]
        local records = this.records

        this.heartbeat = real_time

        if records and #records > 0 then
            local did_scan = false

            for rid, rval in ipairs(records) do
                if did_scan then
                    break
                end

                if rval.signature == software then
                    did_scan = true

                    if math.abs(real_time-rval.time) <= .5 then
                        return
                    end
                end
            end
        end

        if #records >= 16 then
            for i=16, #records do
                table.remove(records, i)
            end
        end

        for i, val in ipairs(records) do
            if voice_hash ~= nil and voice_hash == val.hash then
                -- the exact same voice hash cannot be acknowledged twice
                return false
            end

            if software == val.signature and val.time > real_time then
                return false
            end
        end

        table.insert(records, 1, {
            signature = software,
            is_shared = via_shared,
            time = real_time,
            hash = voice_hash
        })

        update_reliability(this)

        return true
    end
end

-- Functions
local function get_all(player, reliable_only)
    if player == nil then
        return
    end

    if not is_valid_entity(player) then
        return
    end

    local xuid = tostring(player:get_xuid())
    local this = database[xuid]

    if this == nil or #this.sorted_records <= 0 then
        return
    end

    local sgn = { }
    local rec_amt = #this.records

    for i, val in ipairs(this.sorted_records) do
        if reliable_only and not val.is_reliable then
            goto skip
        end

        do
            sgn[#sgn+1] = {
                signature = val.signature,
                is_reliable = val.is_reliable,
                amount = val.amount / rec_amt,
                heartbeat = get_time() - val.time
            }
        end

        ::skip::
    end

    return #sgn > 0 and sgn or nil
end

local function get_software(player)
    if player == nil then
        return
    end

    if not is_valid_entity(player) then
        return
    end

    local xuid = tostring(player:get_xuid())
    local this = database[xuid]

    if this == nil or #this.sorted_records <= 0 then
        return
    end

    local best = this.sorted_records[1]

    if not best.is_reliable then
        return
    end

    return {
        signature = best.signature,
        amount = best.amount / #this.records,
        heartbeat = get_time() - best.time
    }
end

local function get_icon(signature)
    return ICONS[signature] or nil
end

local function is_in_sync()
    return is_syncing
end

do  -- Initialization
    verify_players(true)

    local function handle_voice(ctx)
        local player = ctx.entity

        if player == nil then
            return
        end

        local software, voice_hash = get_signature(ctx)

        if software == nil then
            return
        end

        add_record(player, software, false, nil, voice_hash)
    end

    local function encrypt_database()
        local unec, count = verify_players(true), 0

        for id in pairs(unec) do
            count = count + 1
        end

        db[database_name] = count > 0 and
            base64.encode(xorstr(json.stringify(unec))) or nil
    end

    local function handle_availability()
        local time = globals.realtime

        if math.abs(time - last_availability_chk) <= .1 then
            return
        end

        voice_modenable:int(1, true)
        cl_mute_enemy_team:int(0, true)
        cl_mute_all_but_friends_and_party:int(0, true)
        cl_mute_player_after_reporting_abuse:int(0, true)

        last_availability_chk = time
    end

    local function availability_fix()
        voice_modenable:int(tonumber(voice_modenable:string()))
        cl_mute_enemy_team:int(tonumber(cl_mute_enemy_team:string()))
        cl_mute_all_but_friends_and_party:int(tonumber(cl_mute_all_but_friends_and_party:string()))
        cl_mute_player_after_reporting_abuse:int(tonumber(cl_mute_player_after_reporting_abuse:string()))
    end

    -- base callbacks
    events.render(verify_players)
    events.shutdown(encrypt_database)

    -- fix game restrictions
    events.render(handle_availability)
    events.shutdown(availability_fix)

    -- voice handler
    voice_callback(handle_voice)

    local receiver do
        local RCV = {
            ID = 0xB16B00B5,
            SECURITY_KEY = '$ZGFydGh2dnY.',
            RV_PLAYER_REQUEST = 0x1,
            RV_PLAYER_SEND = 0x2
        }

        local to_int = function(str)
            local is_num = type(str) == 'number'
            local union = ffi.typeof(is_num and
                'union { uint32_t num; char bytes[5]; }' or
                'union { char bytes[5]; uint32_t num; }'
            )(str)

            return is_num and ffi.string(union.bytes) or union.num
        end

        local resolve_hash = function(number, rcv)
            local hash = bit.bxor(number, rcv)

            hash = hash
                + bit.lshift(hash, 1)
                + bit.lshift(hash, 4)
                + bit.lshift(hash, 7)
                + bit.lshift(hash, 8)
                + bit.lshift(hash, 24)

            return hash % 0x100000000
        end

        local function send_player(player, signature, time_difference)
            voice_callback:call(function(message)
                local server_tick = globals.server_tick
                local tick_hash = resolve_hash(server_tick, RCV.ID)

                message:write_bits(server_tick, 32)
                message:write_bits(tick_hash, 32)
                message:write_bits(RCV.ID, 32)
                message:write_bits(RCV.RV_PLAYER_SEND, 4)
                message:write_bits(player:get_index() - 1, 7)
                message:write_bits(to_int(signature), 32)
                message:write_bits(time_difference, 16)

                message:crypt(RCV.SECURITY_KEY)

                -- print('RV_PLAYER_SEND '', player:get_name(), '' -> ', signature)
            end)
        end

        local function request_players()
            voice_callback:call(function(message)
                local server_tick = globals.server_tick
                local tick_hash = resolve_hash(server_tick, RCV.ID)

                message:write_bits(server_tick, 32)
                message:write_bits(tick_hash, 32)
                message:write_bits(RCV.ID, 32)
                message:write_bits(RCV.RV_PLAYER_REQUEST, 4)

                message:crypt(RCV.SECURITY_KEY)
            end)
        end

        local function RECEIVER(ctx)
            if type(ctx) ~= 'userdata' or ctx.entity == nil then
                return
            end

            local buffer = ctx.buffer

            buffer:crypt(RCV.SECURITY_KEY)

            local tick = buffer:read_bits(32)
            local hash_sum = buffer:read_bits(32)
            local packet = buffer:read_bits(32)

            if packet ~= RCV.ID then
                return
            end

            local action = buffer:read_bits(4)

            if action == RCV.RV_PLAYER_REQUEST then
                if to_time(globals.server_tick - tick) < 1 and hash_sum == resolve_hash(tick, RCV.ID) then
                    is_syncing = true

                    local next_request = 0

                    -- print_raw('\aFF0000RV_PLAYER_REQUEST from: ', entity.get(ctx.entity):get_name())

                    entity.get_players(false, true, function(player)
                        if not is_valid_entity(player) then
                            return
                        end
                        local software = get_software(player)

                        if software ~= nil then
                            utils.execute_after(next_request, send_player, player, software.signature, to_ticks(software.heartbeat))
                            next_request = next_request + to_time(5)
                        end
                    end)

                    utils.execute_after(next_request, function()
                        is_syncing = false
                    end)
                end

                return
            end

            if action == RCV.RV_PLAYER_SEND then
                local tick = buffer:read_bits(32)
                local hash_sum = buffer:read_bits(32)

                if to_time(globals.server_tick - tick) < 1 and hash_sum == resolve_hash(tick, RCV.ID) then
                    local player = entity.get(buffer:read_bits(7) + 1)
                    local signature = to_int(buffer:read_bits(32))
                    local heartbeat = to_time(buffer:read_bits(16))

                    local found_sig

                    for id, value in pairs(CHEAT) do
                        if signature == value then
                            found_sig = id
                            break
                        end
                    end

                    if player ~= nil and is_valid_entity(player) and found_sig and heartbeat < 120 then
                        local response = add_record(player, signature, true, get_time() - heartbeat)

                        -- print(string.format(
                        --     'RV_PLAYER_ACKNOWLEDGE [%s] [%s:%.2f]%s',
                        --     player:get_name(), signature, heartbeat, response == false and ' [REJECTED]' or ''
                        -- ))
                    end
                end
            end
        end

        voice_callback(RECEIVER)

        -- REGISTER
        if globals.is_in_game then
            local count = 0

            for _ in pairs(database) do
                count = count + 1
            end

            if count == 0 then
                request_players()
            end
        end

        events.player_connect_full(function(e)
            local player = entity.get(e.userid, true)
            local local_player = entity.get_local_player()
            if player and is_valid_entity(player) and local_player and is_valid_entity(local_player) and player == local_player then
                request_players()
            end
        end)
    end
end

return {
    get_all = get_all,
    get_software = get_software,
    get_icon = get_icon,
    is_syncing = is_in_sync
}
end)()
local v7 = {};
local v8 = {};
local v9 = {};
local v10 = {};
local v11 = {};
local v12 = {};
local v13 = {};
local v14 = {};
local _ = {};
local v16 = {};
local _ = {};
local _ = {};
local v19 = {};
v19 = {
    common = {
        get_username = common.get_username, 
        get_time = common.get_time
    }, 
    entity = {
        get = entity.get, 
        get_local_player = entity.get_local_player
    }, 
    render = {
        measure_text = render.measure_text, 
        text = render.text, 
        rect = render.rect, 
        circle = render.circle, 
        shadow = render.shadow, 
        screen_size = render.screen_size(), 
        screen_center = render.screen_size() / 2
    }, 
    math = {
        floor = math.floor, 
        ceil = math.ceil, 
        min = math.min, 
        max = math.max, 
        abs = math.abs, 
        difference = math.difference, 
        normalize_yaw = math.normalize_yaw, 
        lerp = function(v20, v21, v22)
            return v20 + v22 * (v21 - v20);
        end
    }, 
    string = {
        format = string.format, 
        lower = string.lower, 
        find = string.find
    }, 
    utils = {
        random_int = utils.random_int, 
        random_float = utils.random_float
    }, 
    globals = {
        realtime = globals.realtime, 
        curtime = globals.curtime, 
        frametime = globals.frametime, 
        tickcount = globals.tickcount, 
        commandack = globals.commandack
    }, 
    ui = {
        getalpha = ui.get_alpha, 
        get_icon = ui.get_icon, 
        get_style = ui.get_style
    }, 
    colors = {
        black = color(0, 0, 0, 255), 
        white = color(255, 255, 255, 255), 
        transparent = color(0, 0, 0, 0)
    }, 
    entity_methods = {
        is_enemy = function(v23)
            return v23:is_enemy();
        end, 
        is_alive = function(v24)
            return v24:is_alive();
        end, 
        get_player_weapon = function(v25)
            return v25:get_player_weapon();
        end, 
        get_name = function(v26)
            return v26:get_name();
        end
    }, 
    string_ops = {
        to_hex = function(v27)
            return v27:to_hex();
        end, 
        alpha_modulate = function(v28, v29)
            return v28:alpha_modulate(v29);
        end
    }, 
    events = {
        register = v11.register, 
        set = function(v30, v31)
            events[v30]:set(v31);
        end
    }, 
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
    weapon_actions = {
        knife = "Knifed", 
        inferno = "Burned", 
        hegrenade = "Naded"
    }, 
    print = {
        raw = print_raw, 
        dev = print_dev
    }, 
    panorama = {
        get_name = panorama.MyPersonaAPI.GetName, 
        get_xuid = panorama.MyPersonaAPI.GetXuid
    }
};
local v32 = "BETA";
local v54 = new_class():struct("core")({
    username = v19.common.get_username(), 
    steamid = v19.panorama.get_xuid(), 
    steam_name = v19.panorama.get_name(), 
    screen_size = v19.render.screen_size, 
    screen_center = v19.render.screen_center, 
    dpi_scale = v19.render.screen_size / vector(2560, 1440), 
    hitgroups = v19.hitgroups, 
    wpn2act = v19.weapon_actions, 
    branded_printing = function(_, v34)
        -- upvalues: v9 (ref), v19 (ref)
        local v35 = v9.visuals.accent:get();
        local v36 = v19.string.format("[%s] %s", "\a" .. v19.string_ops.to_hex(v35) .. "LuaSense\aFFFFFFFF", v34);
        v19.print.raw(v36);
        v19.print.dev(v36);
    end, 
    with_icon = function(_, v38, v39, v40)
        -- upvalues: v19 (ref)
        local v41 = v19.ui.get_icon(v38);
        if v40 ~= nil then
            v41 = "\a" .. (type(v40) == "string" and v40 or v19.string_ops.to_hex(v40)) .. v41 .. "\aFFFFFFFF";
        end;
        return v41 .. " " .. v39;
    end, 
    gradient = l_gradient_0.text_animate("S E N S E", -2, {
        color(255, 255, 255), 
        color(91, 91, 91)
    })
}):struct("shared")({
    data = {
        team = 0, 
        throw_time = 0, 
        pin_pulled = false, 
        movetype = -1, 
        able_to_render = false, 
        scoped = false,
        localplayer = nil
    }, 
    collect = function(v42)
        v42.data.localplayer = nil
        v42.data.able_to_render = false
    end, 
    collect_render_info = function(v45)
        v45.data.able_to_render = false
    end
}):struct("safecall")({
    execute = function(_, v48, v49, v50)
        return function(...)
            local l_status_0, l_result_0 = pcall(v50, ...);
            if not l_status_0 then
                return false, "error suppressed";
            else
                return l_result_0, l_status_0;
            end;
        end;
    end
}):struct("refs")({
    weapon_action = ui.find("Miscellaneous", "Main", "Other", "Weapon Actions"),
    pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"), 
    yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"), 
    base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"), 
    offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"), 
    backstab = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"), 
    jitter = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"), 
    jitter_val = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"), 
    body_yaw = {
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding")
    }, 
    freestand = {
        ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"), 
        ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding")
    }, 
    def = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"), 
    legs = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"), 
    slow = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"), 
    fake_latency = ui.find("Miscellaneous", "Main", "Other", "Fake Latency"), 
    scope_type = ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"), 
    hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"), 
    inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"), 
    fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"), 
    freestand_bind = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"), 
    hideshot_config = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"), 
    autopeek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"), 
    fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")
});
local v55 = ui.find("Miscellaneous", "Main", "Movement", "Quick Stop");
local l_core_0 = v54.core;
l_core_0.shared_data = v54.shared.data;
v11.register = function(v57, v58, v59)
    -- upvalues: v54 (ref)
    events[v57]:set(v54.safecall:execute(v58, v57 ~= "shutdown", v59));
end;
local v60 = {
    black = color(0, 255), 
    white = color(255)
};
getmetatable(color()).override = function(v61, v62, v63)
    local v64 = v61:clone();
    v64[v62] = v63;
    return v64;
end;
local v65 = nil;
v65 = {};
local v66 = 2.2222222222222223;
v65.difference = function(v67, v68)
    return math.abs(v67 - v68);
end;
do
    local l_v66_0 = v66;
    v65.color_lerp = function(v70, v71, v72)
        -- upvalues: l_v66_0 (ref)
        local v73 = globals.frametime * 100;
        return v70:lerp(v71, v72 * math.min(v73, l_v66_0));
    end;
    v65.lerp = function(v74, v75, v76)
        if v74 == v75 then
            return v75;
        else
            v76 = v76 * (globals.frametime * 170);
            local v77 = v74 + (v75 - v74) * v76;
            if math.abs(v77 - v75) < 0.01 then
                return v75;
            else
                return v77;
            end;
        end;
    end;
    math.normalize_yaw = math.normalize_yaw;
end;
local l_manager_0 = new_class():struct("manager")({
    base_speed = 0.07, 
    _list = {}, 
    new = function(v78, v79, v80, v81, v82)
        -- upvalues: v65 (ref)
        if not v81 then
            v81 = v78.base_speed;
        end;
        local v83 = type(v80) ~= "number";
        if v78._list[v79] == nil then
            v78._list[v79] = v82 and v82 or v83 and color(0, 0, 0, 0) or 0;
        end;
        local v84 = v83 and v80.lerp or v65.lerp;
        v78._list[v79] = v84(v78._list[v79], v80, v81);
        return v78._list[v79];
    end, 
    get = function(v85, v86)
        return v85._list[v86];
    end, 
    reset = function(v87, v88)
        v87._list[v88] = nil;
    end, 
    clear = function(v89)
        v89._list = {};
    end
}).manager;
local v91 = {
    conditions = {
        [1] = "Standing", 
        [2] = "Running", 
        [3] = "Slowmotion", 
        [4] = "Crouch", 
        [5] = "Crouch Moving", 
        [6] = "Air", 
        [7] = "Air Crouch", 
        [8] = "Manual"
    }, 
    cheats = {
        [1] = "NL", 
        [2] = "GS"
    }
};
local function v95(v92, v93, v94)
    -- upvalues: l_pui_0 (ref), l_core_0 (ref)
    return l_pui_0.create(l_core_0:with_icon(v92, "", "{Link Active}"), v93, v94);
end;
local v96 = v95("igloo", "", 1);
local _ = v95("igloo", "", 1);
local _ = v95("igloo", "\nchooser", 1);
local v99 = v95("igloo", "Links", 1);
local v100 = v95("igloo", "Discord", 1);
local v101 = v95("igloo", "\nconfigs2", 2);
local v102 = v95("igloo", "\nconfigs", 2);
local v103 = v95("atom", "\ncurrent state", 2);
local _ = v95("atom", "\n233332", 2);
local v105 = v95("atom", "\n2332", 2);
local v106 = v95("atom", "\nTickbase", 2);
local v107 = v95("atom", "", 2);
local _ = v95("atom", "\n4", 1);
local v109 = v95("atom", "\nlister", 1);
local v110 = v95("atom", "\n", 1);
local v111 = v95("atom", "\nextra1", 1);
local v112 = v95("atom", "\nextra", 2);
local _ = v95("atom", "\n5", 1);
local v114 = v95("atom", "Defensive", 1);
local v115 = v95("rectangles-mixed", "\nvisuals2", 2);
local v116 = v95("rectangles-mixed", "\ntab selector", 1);
local v117 = v95("rectangles-mixed", "Visuals", 1);
local v118 = v95("rectangles-mixed", "Movement", 1);
local v119 = v95("rectangles-mixed", "Extra", 2);
local _ = v95("rectangles-mixed", "\nvisuals", 2);
local v121 = v95("rectangles-mixed", "Widgets\nwidgets", 2);
local v122 = v95("rectangles-mixed", "\nPing Spike");
local v123 = {
    [1] = nil, 
    [2] = nil, 
    [3] = nil, 
    [4] = nil, 
    [5] = nil, 
    [6] = "------------------------------------------", 
    [7] = "Create new config...", 
    [1] = l_core_0:with_icon("star-christmas", " Meta - \a55555586japan (new settings)", "{Link Active}"), 
    [2] = l_core_0:with_icon("sun", " Aggressive [fixed] - \a55555586brandon", "{Link Active}"), 
    [3] = l_core_0:with_icon("soap", " Snap [test] - \a55555586japan", "{Link Active}"), 
    [4] = l_core_0:with_icon("gitter", " Custom Jitter - \a55555586brandon", "{Link Active}"), 
    [5] = l_core_0:with_icon("crown", " Royal - \a55555586japan x brandon", "{Link Active}")
};
local v124 = {
    github_url = "https://raw.githubusercontent.com/zxjapan/ls_config/refs/heads/main/codes.txt", 
    github_token = "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", 
    github_api_url = "https://api.github.com/repos/zxjapan/ls_config/contents/codes.txt", 
    db_key = "userverified"
};
local _ = "\226\128\138";
if ({
    robertica = true, 
    Netflix234 = true, 
    ceenai = true, 
    david2020 = true, 
    xRazor = true, 
    Andreic2001 = true
})[common.get_username()] then
    error("blacklisted");
    return;
else
    v9 = {
        main = {
            username = v96:label(l_core_0:with_icon("person-circle-question", "   User\n", "{Link Active}")), 
            user_button = v96:button(common.get_username(), nil, true), 
            version = v96:label(l_core_0:with_icon("code-commit", "  Version\n", "{Link Active}")), 
            version_button = v96:button("3.00.zb1", nil, true), 
            scripts = v99:label("Scripts\n"), 
            live_button = v99:button(l_core_0:with_icon("circle-1", " Live\n", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=luasense");
            end, true), 
            beta_button = v99:button(l_core_0:with_icon("circle-2", " Beta", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=byAMx1");
            end, true), 
            configs = v99:label("Brandon configs\n"), 
            live_button2 = v99:button(l_core_0:with_icon("square-1", " Live\n", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=RuE7C8");
            end, true), 
            beta_button2 = v99:button(l_core_0:with_icon("square-2", " Beta", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=MAxYSG");
            end, true), 
            youtube = v99:label("Socials\n"), 
            yt_button = v99:button(l_core_0:with_icon("youtube", " YT\n", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://www.youtube.com/@vorbic");
            end, true), 
            dc_label = v100:label(l_core_0:with_icon("bug", " Encounter any Bugs?\n", "{Link Active}")), 
            dc_button = v100:button(l_core_0:with_icon("discord", " Join Us!\n", "{Link Active}"), function()
                panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/NgU7NzRxXr");
            end, true), 
            dc_label = v100:label(l_core_0:with_icon("check", " Want to verify?\n", "{Link Active}")), 
            verify_switch = v100:button("           Click me!           ", function()
                -- upvalues: v124 (ref)
                v124.check();
            end, false), 
            new_button = v102:button(l_core_0:with_icon("plus", " save \n"), function()
                -- upvalues: v7 (ref)
                v7.save_config();
            end, true), 
            import_button = v102:button(l_core_0:with_icon("up-from-line", " import \n", "{Link Active}"), function()
                -- upvalues: v7 (ref)
                v7.import_config();
            end, true), 
            export_button = v102:button(l_core_0:with_icon("down-from-line", " export \n", "{Link Active}"), function()
                -- upvalues: v7 (ref)
                v7.export_config();
            end, true), 
            load_button = v102:button(l_core_0:with_icon("plus", " load \n"), function()
                -- upvalues: v7 (ref)
                v7.load_config();
            end, true), 
            delete_button = v102:button("                                   \aFF0000FFdelete                                  \n", function()
                -- upvalues: v7 (ref)
                v7.delete_config();
            end, true), 
            input_name = v101:input("Config Name", "Type Here"), 
            preset_list = v101:list("", v8)
        }, 
        labels = {}, 
        rage = {
            state_label = v103:label("oh oh im not meant to be empty!"), 
            aa_lister = v109:list("\n", {
                l_core_0:with_icon("gears", "  Settings", "{Link Active}"), 
                l_core_0:with_icon("helmet-safety", "  Anti-Aim", "{Link Active}"), 
                l_core_0:with_icon("shield-plus", "  Defensive", "{Link Active}")
            }), 
            anims = {}, 
            team_list = v110:combo(l_core_0:with_icon("people-group", "  Choose Team", "{Link Active}"), {
                [1] = "T", 
                [2] = "CT"
            }), 
            state_list = v110:combo(l_core_0:with_icon("person-running", "   Anti-Aim State", "{Link Active}"), v91.conditions), 
            manual = v111:combo(l_core_0:with_icon("square-poll-horizontal", " Yaw Base", "{Link Active}"), "At Target", "Left", "Right", "Forward"), 
            freestanding_bind = v111:switch(l_core_0:with_icon("block-brick-fire", "  Freestanding", "{Link Active}"), false, function(v126)
                -- upvalues: v91 (ref)
                return {
                    prefer_manual = v126:switch("Prefer Manual AA"), 
                    keep_fs = v126:switch("Keep FS Enabled After Manual AA"), 
                    freestand_options = v126:selectable("Disablers", v91.conditions), 
                    freestand_enablers = v126:selectable("Enablers", v91.conditions), 
                    freestand_body = v126:list("Bodyyaw", {
                        [1] = "Static", 
                        [2] = "Jitter"
                    })
                }, false;
            end), 
            avoid_knife = v112:switch(l_core_0:with_icon("sword", "  Avoid Backstab", "{Link Active}"), false), 
            safe_head = v112:switch(l_core_0:with_icon("eye-slash", "  Hide Head", "{Link Active}"), false, function(v127)
                return {
                    safe_options = v127:listable("Conditions", {
                        [1] = "Standing", 
                        [2] = "Crouch", 
                        [3] = "Air Crouch Knife", 
                        [4] = "Distance", 
                        [5] = "Height Advantage", 
                        [6] = "Taser In Air"
                    })
                }, true;
            end), 
            hidden_builder = v114:switch("Hidden", false, function(v128)
                -- upvalues: v91 (ref)
                return {
                    state_list = v128:combo("Condition", v91.conditions), 
                    antiaim_label = v128:label(" "), 
                    antiaim_conditions = v128:selectable("Active On", v91.conditions), 
                    disablers = v128:selectable("Disablers", {
                        [1] = "Freestanding", 
                        [2] = "Manual aa", 
                        [3] = "Peek Assist"
                    }), 
                    on_exploit = v128:selectable("On Exploit", {
                        [1] = "Doubletap", 
                        [2] = "Hideshots"
                    }), 
                    antiaim_label = v128:label(" ")
                }, true;
            end), 
            anims = v112:switch(l_core_0:with_icon("flask-round-potion", "  Animations", "{Link Active}"), false, function(v129)
                return {
                    move_jitter_mode = v129:list("Jitter Mode", {
                        [1] = "Default", 
                        [2] = "Delta"
                    }), 
                    move_jitter = v129:slider("Jitter", 0, 10, 0, 1, function(v130)
                        if v130 == 0 then
                            return "Default";
                        else
                            return tostring(v130) .. "%";
                        end;
                    end), 
                    move_legs1 = v129:slider("Legs Delta 1", 0, 100, 0, 1, function(v131)
                        if v131 == 0 then
                            return "Default";
                        else
                            return tostring(v131) .. "%";
                        end;
                    end), 
                    move_legs2 = v129:slider("Legs Delta 2", 0, 100, 0, 1, function(v132)
                        if v132 == 0 then
                            return "Default";
                        else
                            return tostring(v132) .. "%";
                        end;
                    end), 
                    move_fall = v129:slider("Falling", 0, 10, 0, 1, function(v133)
                        if v133 == 0 then
                            return "Default";
                        else
                            return tostring(v133) .. "%";
                        end;
                    end), 
                    move_lean_val = v129:slider("Leaning", 0, 100, 0, 1, function(v134)
                        if v134 == 0 then
                            return "NL";
                        else
                            return tostring(v134);
                        end;
                    end)
                }, true;
            end), 
            additions = v112:selectable(l_core_0:with_icon("plus-large", "  Additions", "{Link Active}"), {
                [1] = "Warmup / Round End AA", 
                [2] = "No Fakelag on Exploits", 
                [3] = "Fluccate Fakelag on Body"
            })
        }, 
        defensive = {
            defensive_settings = v114:label(l_core_0:with_icon("helmet-safety", "  Defensive Settings", "{Link Active}"))
        }, 
        misc_chooser = v116:list("\n", {
            l_core_0:with_icon("palette", "  Visuals", "{Link Active}"), 
            l_core_0:with_icon("swatchbook", "  Misc", "{Link Active}")
        }), 
        visuals = {
            scope = {}, 
            accent = v115:color_picker(l_core_0:with_icon("image-landscape", "Accent", "{Link Active}"), color("96C83CFF")), 
            watermark_style = v115:list("", {
                [1] = "Legacy", 
                [2] = "Recode", 
                [3] = "Desync.Max"
            }), 
            watermark = v115:combo("Watermark Position", {
                [1] = "Left", 
                [2] = "Right", 
                [3] = "Bottom"
            }), 
            molotov_radius = v117:switch(l_core_0:with_icon("circle-xmark", "  Molotov Radius", "{Link Active}"), false), 
            smokes_radius = v117:switch(l_core_0:with_icon("circle", "  Smoke Radius", "{Link Active}"), false), 
            gs_inds = v117:switch(l_core_0:with_icon("badge-dollar", "  500$ Indicators", "{Link Active}"), false), 
            scope = v121:switch(l_core_0:with_icon("telescope", "  Scope Overlay", "{Link Active}"), false, function(v135)
                return {
                    scope_style = v135:list("Style", {
                        [1] = "Default", 
                        [2] = "T", 
                        [3] = "X"
                    }), 
                    scope_settings = v135:selectable("Settings", {
                        [1] = "Spread Based", 
                        [2] = "Glow", 
                        [3] = "Animated Zoom"
                    }), 
                    scope_size = v135:slider("Size", 0, 300, 100), 
                    scope_gap = v135:slider("Gap", 0, 300, 5), 
                    scope_color1 = v135:color_picker("Color", color(255, 255, 255, 255)), 
                    scope_color2 = v135:color_picker("Second Color", color(255, 255, 255, 0))
                }, true;
            end), 
            kibit_hitmark = v117:switch(l_core_0:with_icon("bullseye-arrow", "  Kibit Hitmarker", "{Link Active}"), false, function(v136)
                return {
                    kibit_hitmark_color = v136:color_picker("Color", color(88, 255, 209, 255))
                }, true;
            end), 
            notifs = v121:switch(l_core_0:with_icon("bell", "  Notifications", "{Link Active}"), false, function(v137)
                return {
                    notifs_prefix = v137:switch("Prefix infront of text"), 
                    notifs_prefix_font = v137:list("Font", {
                        [1] = "Default", 
                        [2] = "Small", 
                        [3] = "Console", 
                        [4] = "Bold"
                    }), 
                    notifs_prefix_clr = v137:color_picker("Prefix color", color(0, 255, 0, 255)), 
                    notifs_hit_clr = v137:color_picker("Hit color", color(0, 255, 0, 255)), 
                    notifs_miss_clr = v137:color_picker("Miss color", color(255, 0, 0, 255)), 
                    notifs_glow_amount = v137:slider("Glow amount", 0, 100, 41), 
                    notifs_round_amount = v137:slider("Rounded amount", 0, 15, 11)
                }, true;
            end), 
            slowed_down = v121:switch(l_core_0:with_icon("turtle", "  Slowed Down", "{Link Active}"), false, function(v138)
                return {
                    style = v138:list("Glow", "Yes", "No")
                }, true;
            end)
        }, 
        misc = {
            aspect_ratio = v119:switch(l_core_0:with_icon("arrows-to-circle", "  Aspect Ratio Manager", "{Link Active}"), false), 
            no_fall = v118:switch(l_core_0:with_icon("person-falling", "  No Fall Damage", "{Link Active}"), false), 
            fast_ladder = v118:switch(l_core_0:with_icon("water-ladder", "  Fast Ladder", "{Link Active}"), false), 
            view_model_changer = v119:switch(l_core_0:with_icon("eye", "  View Model", "{Link Active}"), false), 
            clantag = v119:switch(l_core_0:with_icon("tag", "  Clantag [\vsynced\r]", "{Link Active}"), false), 
            log_event = v119:selectable(l_core_0:with_icon("calendar-star", "  Log Events", "{Link Active}"), {
                [1] = "Aimbot", 
                [2] = "Purchases"
            }), 
            client_nickname = v119:switch(l_core_0:with_icon("user", "  Client Sided Nickname", "{Link Active}"), false, function(v139)
                return {
                    client_nickname_text = v139:input("Nickname", "Type Here")
                }, true;
            end), 
            super_toss = v119:switch(l_core_0:with_icon("arrow-up-right-from-square", "  Super Toss", "{Link Active}"), false), 
            freeze_fakeduck = v118:switch(l_core_0:with_icon("duck", "  Freezetime Fakeduck", "{Link Active}"), false), 
            unlock_fakeduck = v118:switch(l_core_0:with_icon("unlock", "  Unlock Fakeduck Speed", "{Link Active}"), false), 
            fake_latency_toggle = v122:switch(l_core_0:with_icon("trash-clock", "  Fake Latency", "{Link Active}"), false, function(v140)
                -- upvalues: l_core_0 (ref)
                return {
                    fake_latency_slider = v140:slider(l_core_0:with_icon("trash-clock", " Fake Latency", "{Link Active}"), 0, 200, 0, 1, "ms")
                }, true;
            end)
        }
    };
    v9.rage.hidden_builder:visibility(false);
    v9.defensive.defensive_conditions = v9.defensive.defensive_settings:create():selectable("Conditions", v91.conditions);
    v9.defensive.game_events = v9.defensive.defensive_settings:create():selectable("Game Events", {
        [1] = "Weapon Switch", 
        [2] = "Weapon Reload"
    });
    v9.defensive.force_hideshot = v9.defensive.defensive_settings:create():switch("Force On Hideshots");
    v9.capitalize = function(v141)
        return (v141:gsub("^%l", string.upper));
    end;
    v9.menu_handler = function()
        -- upvalues: v106 (ref), l_core_0 (ref), v105 (ref), v9 (ref), v107 (ref), v91 (ref)
        local v142 = {};
        local v143 = {};
        local function v161(v144)
            -- upvalues: v142 (ref), v106 (ref), l_core_0 (ref), v105 (ref), v9 (ref), v107 (ref)
            v142[v144] = {};
            v142[v144].defensive_tickbase = v106:slider("\aFFF800FFTickbase", 0, 1, 0, 1, function(v145)
                return v145 == 0 and "Neverlose" or "LuaSense";
            end);
            v142[v144].tick_random = v142[v144].defensive_tickbase:create():switch("Random choke\n" .. v144, false);
            v142[v144].tick_speed1 = v142[v144].defensive_tickbase:create():slider("Choke\n" .. v144, 1, 22, 1, 1, function(v146)
                return v146 == 16 and "Neverlose" or tostring(v146);
            end);
            v142[v144].tick_speed2 = v142[v144].defensive_tickbase:create():slider("Choke 2nd\n" .. v144, 1, 22, 1, 1, function(v147)
                return v147 == 16 and "Neverlose" or tostring(v147);
            end);
            v142[v144].tick_speed_info = v142[v144].defensive_tickbase:create():label("Default choke value for Neverlose is 16.");
            local function v153(v148)
                -- upvalues: v142 (ref), v144 (ref), v105 (ref), l_core_0 (ref), v9 (ref)
                v142[v144]["yaw_mode" .. v148] = v105:combo(l_core_0:with_icon("ruler", "   Yaw" .. "\n" .. v148 .. v144, "{Link Active}"), {
                    [1] = "L - R", 
                    [2] = "Automatic"
                });
                v142[v144]["yaw_random_methods" .. v148] = v142[v144]["yaw_mode" .. v148]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v148 .. v144, "{Link Active}"), {
                    [1] = "Default", 
                    [2] = "Sinusoidal", 
                    [3] = "Chaotic"
                });
                for _, v150 in ipairs({
                    [1] = "center", 
                    [2] = "left", 
                    [3] = "right"
                }) do
                    v142[v144]["yaw_" .. v150 .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider(l_core_0:with_icon("angle-right", "  " .. v9.capitalize(v150) .. "\n" .. v148 .. v144, "{Link Active}"), -180, 180, 0, 1, "\194\176");
                end;
                v142[v144]["yaw_randomize" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Randomize\n" .. v148 .. v144, 0, 180, 0, 1);
                v142[v144]["frequency" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Frequency\n" .. v148 .. v144, 0, 60, 0, 1);
                v142[v144]["amplitude" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Amplitude\n" .. v148 .. v144, 0, 30, 0, 1);
                v142[v144]["r_min" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Min\n" .. v148 .. v144, 0, 100, 0, 1);
                v142[v144]["r_max" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Max\n" .. v148 .. v144, 0, 100, 0, 1);
                v142[v144]["scale" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider("Scale\n" .. v148 .. v144, 0, 100, 0, 1);
                v142[v144]["antibrute" .. v148] = v142[v144]["yaw_mode" .. v148]:create():switch(l_core_0:with_icon("shirt-running", "  Anti-bruteforce" .. "\n" .. v148 .. v144, "{Link Active}"), false);
                v142[v144]["antibrute_method" .. v148] = v142[v144]["yaw_mode" .. v148]:create():list("Method", {
                    [1] = "Decrease", 
                    [2] = "Randomize", 
                    [3] = "Increase"
                });
                v142[v144]["anti_timeout" .. v148] = v142[v144]["yaw_mode" .. v148]:create():slider(l_core_0:with_icon("reply-clock", "  Timeout" .. "\n" .. v148 .. v144, "{Link Active}"), 0, 30, 0, 1, function(v151)
                    return v151 == 0 and "Infinite" or tostring(v151);
                end);
                v142[v144]["anti_timeout_info" .. v148] = v142[v144]["yaw_mode" .. v148]:create():label("If you put timeout at 0 it will be infinite till round ends");
                v142[v144]["Jitter" .. v148] = v105:combo(l_core_0:with_icon("angle-90", "   Modifier" .. "\n" .. v148 .. v144, "{Link Active}"), {
                    [1] = "Disabled", 
                    [2] = "Center", 
                    [3] = "Offset", 
                    [4] = "Random", 
                    [5] = "Spin", 
                    [6] = "3-way", 
                    [7] = "5-way", 
                    [8] = "Hold", 
                    [9] = "Torpedo"
                });
                v142[v144]["center_options" .. v148] = v142[v144]["Jitter" .. v148]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v148 .. v144, "{Link Active}"), {
                    [1] = "Randomize", 
                    [2] = "Min - Max", 
                    [3] = "Custom"
                });
                v142[v144]["yaw_jitter_ovr" .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("slider", "  Offset" .. "\n" .. v148 .. v144, "{Link Active}"), -180, 180, 0, 1, "\194\176");
                v142[v144]["jitter_randomize" .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("angle-right", "  Randomize" .. "\n" .. v148 .. v144, "{Link Active}"), 0, 180, 0, 1);
                v142[v144]["center_min" .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("angle-right", "  Min" .. "\n" .. v148 .. v144, "{Link Active}"), -180, 180, 0, 1);
                v142[v144]["center_max" .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("angle-right", "  Max" .. "\n" .. v148 .. v144, "{Link Active}"), -180, 180, 0, 1);
                v142[v144]["custom_amount" .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("sliders-simple", "  Slider Amount" .. "\n" .. v148 .. v144, "{Link Active}"), 1, 22);
                for v152 = 1, 22 do
                    v142[v144]["custom_slider_" .. v152 .. v148] = v142[v144]["Jitter" .. v148]:create():slider(l_core_0:with_icon("angle-right", "    " .. v152 .. "\n" .. v148 .. v144, "{Link Active}"), -180, 180, 0);
                end;
            end;
            local function v160(v154)
                -- upvalues: v142 (ref), v144 (ref), v105 (ref), l_core_0 (ref), v9 (ref)
                v142[v144]["body_yaw" .. v154] = v105:switch(l_core_0:with_icon("infinity", "  Body" .. "\n" .. v154 .. v144, "{Link Active}"), true);
                v142[v144]["fake_options" .. v154] = v105:combo(l_core_0:with_icon("option", "  Options" .. "\n" .. v154 .. v144, "{Link Active}"), {
                    [1] = "Jitter", 
                    [2] = "Static"
                });
                v142[v144]["speed_options" .. v154] = v142[v144]["fake_options" .. v154]:create():combo(l_core_0:with_icon("bars-progress", "  Method" .. "\n" .. v154 .. v144, "{Link Active}"), {
                    [1] = "Neverlose", 
                    [2] = "Inverter", 
                    [3] = "Amnesia"
                });
                v142[v144]["body_speed" .. v154] = v142[v144]["fake_options" .. v154]:create():slider(l_core_0:with_icon("gauge-simple-high", "  Speed" .. "\n" .. v154 .. v144, "{Link Active}"), 1, 20, 0, 1, function(v155)
                    return v155 == 1 and "Default" or tostring(v155);
                end);
                v142[v144]["amnesia_tick_speed" .. v154] = v142[v144]["fake_options" .. v154]:create():slider("Amnesia Tick\n" .. v154 .. v144, 1, 22, 16);
                v142[v144]["random_speed" .. v154] = v142[v144]["fake_options" .. v154]:create():switch(l_core_0:with_icon("shuffle", "  Random Speed" .. "\n" .. v154 .. v144, "{Link Active}"), false);
                v142[v144]["random_speed_method" .. v154] = v142[v144]["fake_options" .. v154]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v154 .. v144, "{Link Active}"), {
                    [1] = "Random", 
                    [2] = "Custom"
                });
                v142[v144]["custom_speed_amount" .. v154] = v142[v144]["fake_options" .. v154]:create():slider(l_core_0:with_icon("sliders-simple", "  Slider Amount" .. "\n" .. v154 .. v144, "{Link Active}"), 1, 22);
                for v156 = 1, 22 do
                    v142[v144]["custom_speed_slider_" .. v156 .. v154] = v142[v144]["fake_options" .. v154]:create():slider(l_core_0:with_icon("angle-right", "    " .. v156 .. "\n" .. v154 .. v144, "{Link Active}"), 1, 20, 0);
                end;
                v142[v144]["ran_speed_1" .. v154] = v142[v144]["fake_options" .. v154]:create():slider(l_core_0:with_icon("angle-right", "  Min Speed" .. "\n" .. v154 .. v144, "{Link Active}"), 1, 20, 1);
                v142[v144]["ran_speed_2" .. v154] = v142[v144]["fake_options" .. v154]:create():slider(l_core_0:with_icon("angle-right", "  Max Speed" .. "\n" .. v154 .. v144, "{Link Active}"), 1, 20, 1);
                for _, v158 in ipairs({
                    [1] = "left", 
                    [2] = "right"
                }) do
                    local v159 = "fake_" .. v158 .. v154;
                    v142[v144][v159] = v142[v144]["body_yaw" .. v154]:create():slider(l_core_0:with_icon("angle-right", "  " .. v9.capitalize(v158) .. "\n" .. v154 .. v144, "{Link Active}"), 0, 60, 60, 1, "\194\176");
                    v159 = "fake_" .. v158 .. "_random" .. v154;
                    v142[v144][v159] = v142[v144]["body_yaw" .. v154]:create():slider("Randomize\n" .. v154 .. v144, 0, 60, 0, 1);
                end;
            end;
            v153("");
            v153("_ct");
            v160("");
            v160("_ct");
            v142[v144].send_to = v107:button(l_core_0:with_icon("star", "      Send To CT      \n" .. v144, "{Link Active}"), function()
                send_to_opposite_team();
            end, true);
            v142[v144].reset = v107:button("      \aFF0000FFReset      \n" .. v144, function()
                reset_current_state();
            end, true);
            v142[v144].send_to_ct = v107:button(l_core_0:with_icon("star", "      Send To T      \n" .. v144, "{Link Active}"), function()
                send_to_opposite_team();
            end, true);
            v142[v144].reset_ct = v107:button("      \aFF0000FFReset      \n" .. v144, function()
                reset_current_state();
            end, true);
        end;
        local function v173(v162)
            -- upvalues: v143 (ref), v105 (ref), l_core_0 (ref), v9 (ref), v107 (ref)
            v143[v162] = {};
            v143[v162].def_toggle = v105:switch(l_core_0:with_icon("shield-check", "  Enable " .. v162 .. "\n" .. v162, "{Link Active}"), false);
            v143[v162].def_toggle_ct = v105:switch(l_core_0:with_icon("shield-check", "  Enable " .. v162 .. "\n" .. v162, "{Link Active}"), false);
            local function v166(v163)
                -- upvalues: v143 (ref), v162 (ref), v105 (ref), l_core_0 (ref), v9 (ref)
                v143[v162]["def_pitch" .. v163] = v105:combo("Pitch\n" .. v162 .. v163, {
                    [1] = "Down", 
                    [2] = "Random", 
                    [3] = "Auto", 
                    [4] = "Custom"
                });
                v143[v162]["pitch_offset" .. v163] = v143[v162]["def_pitch" .. v163]:create():slider("Pitch\n" .. v162, -89, 89, 0, 1, "\194\176");
                v143[v162]["yaw_mode" .. v163] = v105:combo(l_core_0:with_icon("ruler", "   Yaw" .. "\n" .. v163 .. v162, "{Link Active}"), {
                    [1] = "L - R", 
                    [2] = "Sideways", 
                    [3] = "Random", 
                    [4] = "Spin"
                });
                v143[v162]["yaw_random_methods" .. v163] = v143[v162]["yaw_mode" .. v163]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v163 .. v162, "{Link Active}"), {
                    [1] = "Default", 
                    [2] = "Sinusoidal", 
                    [3] = "Chaotic"
                });
                for _, v165 in ipairs({
                    [1] = "center", 
                    [2] = "left", 
                    [3] = "right"
                }) do
                    v143[v162]["yaw_" .. v165 .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider(l_core_0:with_icon("angle-right", "  " .. v9.capitalize(v165) .. "\n" .. v163 .. v162, "{Link Active}"), -180, 180, 0, 1, "\194\176");
                end;
                v143[v162]["spin_speed" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Spin Speed\n" .. v163 .. v162, 1, 10);
                v143[v162]["yaw_randomize" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Randomize\n" .. v163 .. v162, 0, 180, 0, 1);
                v143[v162]["frequency" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Frequency\n" .. v163 .. v162, 0, 60, 0, 1);
                v143[v162]["amplitude" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Amplitude\n" .. v163 .. v162, 0, 30, 0, 1);
                v143[v162]["r_min" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Min\n" .. v163 .. v162, 0, 100, 0, 1);
                v143[v162]["r_max" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Max\n" .. v163 .. v162, 0, 100, 0, 1);
                v143[v162]["scale" .. v163] = v143[v162]["yaw_mode" .. v163]:create():slider("Scale\n" .. v163 .. v162, 0, 100, 0, 1);
                v143[v162]["Jitter" .. v163] = v105:combo(l_core_0:with_icon("angle-90", "   Modifier" .. "\n" .. v163 .. v162, "{Link Active}"), {
                    [1] = "Disabled", 
                    [2] = "Center", 
                    [3] = "Offset", 
                    [4] = "Random", 
                    [5] = "Spin", 
                    [6] = "3-way", 
                    [7] = "5-way"
                });
                v143[v162]["center_options" .. v163] = v143[v162]["Jitter" .. v163]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v163 .. v162, "{Link Active}"), {
                    [1] = "Randomize", 
                    [2] = "Min - Max"
                });
                v143[v162]["yaw_jitter_ovr" .. v163] = v143[v162]["Jitter" .. v163]:create():slider(l_core_0:with_icon("slider", "  Offset" .. "\n" .. v163 .. v162, "{Link Active}"), -180, 180, 0, 1, "\194\176");
                v143[v162]["jitter_randomize" .. v163] = v143[v162]["Jitter" .. v163]:create():slider(l_core_0:with_icon("angle-right", "  Randomize" .. "\n" .. v163 .. v162, "{Link Active}"), 0, 180, 0, 1);
                v143[v162]["center_min" .. v163] = v143[v162]["Jitter" .. v163]:create():slider(l_core_0:with_icon("angle-right", "  Min" .. "\n" .. v163 .. v162, "{Link Active}"), -180, 180, 0, 1);
                v143[v162]["center_max" .. v163] = v143[v162]["Jitter" .. v163]:create():slider(l_core_0:with_icon("angle-right", "  Max" .. "\n" .. v163 .. v162, "{Link Active}"), -180, 180, 0, 1);
            end;
            local function v172(v167)
                -- upvalues: v143 (ref), v162 (ref), v105 (ref), l_core_0 (ref), v9 (ref), v107 (ref)
                v143[v162]["body_yaw" .. v167] = v105:switch(l_core_0:with_icon("infinity", "  Body" .. "\n" .. v167 .. v162, "{Link Active}"), true);
                v143[v162]["fake_options" .. v167] = v105:combo(l_core_0:with_icon("option", "  Options" .. "\n" .. v167 .. v162, "{Link Active}"), {
                    [1] = "Jitter", 
                    [2] = "Static"
                });
                v143[v162]["speed_options" .. v167] = v143[v162]["fake_options" .. v167]:create():combo(l_core_0:with_icon("bars-progress", "  Method" .. "\n" .. v167 .. v162, "{Link Active}"), {
                    [1] = "Neverlose", 
                    [2] = "Inverter", 
                    [3] = "Amnesia"
                });
                v143[v162]["body_speed" .. v167] = v143[v162]["fake_options" .. v167]:create():slider(l_core_0:with_icon("gauge-simple-high", "  Speed" .. "\n" .. v167 .. v162, "{Link Active}"), 1, 20, 0, 1, function(v168)
                    return v168 == 1 and "Default" or tostring(v168);
                end);
                v143[v162]["amnesia_tick_speed" .. v167] = v143[v162]["fake_options" .. v167]:create():slider("Amnesia Tick\n" .. v167 .. v162, 1, 22, 16);
                v143[v162]["random_speed" .. v167] = v143[v162]["fake_options" .. v167]:create():switch(l_core_0:with_icon("shuffle", "  Random Speed" .. "\n" .. v167 .. v162, "{Link Active}"), false);
                v143[v162]["random_speed_method" .. v167] = v143[v162]["fake_options" .. v167]:create():combo(l_core_0:with_icon("rectangles-mixed", "  Random" .. "\n" .. v167 .. v162, "{Link Active}"), {
                    [1] = "Random"
                });
                v143[v162]["ran_speed_1" .. v167] = v143[v162]["fake_options" .. v167]:create():slider(l_core_0:with_icon("angle-right", "  Min Speed" .. "\n" .. v167 .. v162, "{Link Active}"), 1, 20, 1);
                v143[v162]["ran_speed_2" .. v167] = v143[v162]["fake_options" .. v167]:create():slider(l_core_0:with_icon("angle-right", "  Max Speed" .. "\n" .. v167 .. v162, "{Link Active}"), 1, 20, 1);
                for _, v170 in ipairs({
                    [1] = "left", 
                    [2] = "right"
                }) do
                    local v171 = "fake_" .. v170 .. v167;
                    v143[v162][v171] = v143[v162]["body_yaw" .. v167]:create():slider(l_core_0:with_icon("angle-right", "  " .. v9.capitalize(v170) .. "\n" .. v167 .. v162, "{Link Active}"), 0, 60, 60, 1, "\194\176");
                    v171 = "fake_" .. v170 .. "_random" .. v167;
                    v143[v162][v171] = v143[v162]["body_yaw" .. v167]:create():slider("Randomize\n" .. v167 .. v162, 0, 60, 0, 1);
                end;
                v143[v162]["def_activation" .. v167] = v107:combo(l_core_0:with_icon("chart-network", "  Activation" .. "\n" .. v167 .. v162, "{Link Active}"), {
                    [1] = "Always", 
                    [2] = "Hittable"
                });
            end;
            v166("");
            v166("_ct");
            v172("");
            v172("_ct");
            v143[v162].send_to = v107:button(l_core_0:with_icon("star", "      Send To CT      \n" .. v162, "{Link Active}"), function()
                send_to_opposite_team();
            end, true);
            v143[v162].reset = v107:button("      \aFF0000FFReset      \n" .. v162, function()
                reset_current_state();
            end, true);
            v143[v162].send_to_ct = v107:button(l_core_0:with_icon("star", "      Send To T      \n" .. v162, "{Link Active}"), function()
                send_to_opposite_team();
            end, true);
            v143[v162].reset_ct = v107:button("      \aFF0000FFReset      \n" .. v162, function()
                reset_current_state();
            end, true);
        end;
        for _, v175 in pairs(v91.conditions) do
            v161(v175);
            v173(v175);
        end;
        v9.rage.builder_elements = v142;
        v9.rage.defensive_elements = v143;
    end;
    v9.menu_handler();
    v9.set_visibility = function(v176, v177, v178, v179)
        -- upvalues: v9 (ref)
        local v180 = v178 and "_ct" or "";
        local v181 = v9.rage.aa_lister and v9.rage.aa_lister:get() == v179;
        if v177 then
            v177 = v181;
        end;
        v9.visuals.notifs.notifs_prefix_font:visibility(v9.visuals.notifs.notifs_prefix:get());
        local v182 = {};
        local v183 = {};
        local function v187(v184, v185)
            -- upvalues: v176 (ref)
            local v186 = v176[v184];
            if v186 and v186.get then
                return v186:get();
            else
                return v185;
            end;
        end;
        local v188 = v176["Jitter" .. v180];
        local v189;
        if not v188 or v188:get() == "Hold" or v188:get() == "Torpedo" then
            v189 = false;
        else
            v189 = true;
        end;
        local v190;
        if not v188 or v188:get() == "Disabled" then
            v190 = false;
        else
            v190 = true;
        end;
        local v191 = v187("center_options" .. v180, "");
        local v192 = v191 == "Custom";
        local v193 = v191 == "Min - Max";
        local v194 = v191 == "Randomize";
        local v195 = v192 and v188:get() ~= "Disabled";
        local v196 = v187("custom_amount" .. v180, 0);
        local v197 = v187("yaw_random_methods" .. v180, "");
        local v198 = v197 == "Chaotic";
        local v199 = v197 == "Sinusoidal";
        local v200 = v197 == "Default";
        local v201 = v187("random_speed" .. v180, false);
        local v202 = v187("random_speed_method" .. v180, "") == "Custom";
        local v203 = v187("custom_speed_amount" .. v180, 0);
        local v204 = v187("yaw_mode" .. v180, "") == "Spin";
        local v205 = v187("defensive_tickbase", 0) == 1;
        local v206 = v187("antibrute" .. v180, false);
        local v207 = v187("speed_options" .. v180, "") == "Amnesia";
        local v208 = v187("yaw_mode" .. v180, "") == "Sideways" or not (v187("yaw_mode" .. v180, "") ~= "Random") or v187("yaw_mode" .. v180, "") == "Spin";
        local function v212()
            -- upvalues: v176 (ref), v180 (ref), v196 (ref), v195 (ref), v189 (ref), v181 (ref), v203 (ref), v202 (ref), v201 (ref)
            for v209 = 1, 22 do
                local v210 = v176["custom_slider_" .. v209 .. v180];
                if v210 and v210.visibility then
                    v210:visibility(v209 <= v196 and v195 and v189 and v181);
                end;
                local v211 = v176["custom_speed_slider_" .. v209 .. v180];
                if v211 and v211.visibility then
                    v211:visibility(v209 <= v203 and v202 and v201 and v181);
                end;
            end;
        end;
        local v213 = v176["body_speed" .. v180];
        if v213 and v213.override then
            if v201 then
                v213:override(1);
            else
                v213:override();
            end;
        end;
        local v214 = v176["yaw_jitter_ovr" .. v180];
        if v214 and v214.disabled then
            v214:disabled(v193 or v192 or not v189);
        end;
        local v215 = {
            def_activation = false, 
            custom_amount = v192 and v189, 
            custom_speed_amount = v202 and v201, 
            amnesia_tick_speed = v207, 
            spin_speed = v204, 
            yaw_randomize = v200, 
            r_min = v198, 
            r_max = v198, 
            scale = v198, 
            frequency = v199, 
            amplitude = v199, 
            def_pitch = v177, 
            yaw_mode = v177
        };
        local v216;
        if v177 then
            v216 = show_yaw_center;
        else
            v216 = v177;
        end;
        v215.yaw_center = v216;
        if v177 then
            v216 = not v208;
        else
            v216 = v177;
        end;
        v215.yaw_left = v216;
        if v177 then
            v216 = not v208;
        else
            v216 = v177;
        end;
        v215.yaw_right = v216;
        v215.antibrute_method = v206;
        v215.anti_timeout = v206;
        v215.anti_timeout_info = v206;
        v215.ran_speed_1 = v201 and not v202;
        v215.ran_speed_2 = v201 and not v202;
        v215.random_speed_method = v201;
        v215.speed_options = v177;
        v215.Jitter = v177;
        if v177 then
            v216 = v189;
        else
            v216 = v177;
        end;
        v215.center_options = v216;
        v215.center_min = v193 and v189;
        v215.center_max = v193 and v189;
        v215.jitter_randomize = v194 and v189;
        if v177 then
            v216 = v190;
        else
            v216 = v177;
        end;
        v215.yaw_jitter_ovr = v216;
        v215.body_yaw = v177;
        v215.fake_left = v177;
        v215.fake_right = v177;
        v215.fake_options = v177;
        v215.send_to = v177;
        v215.reset = v177;
        v215.body_speed = v177;
        v182 = v215;
        v183 = {
            defensive_tickbase = v177, 
            tick_random = v205 and v177, 
            tick_speed1 = v205 and v177, 
            tick_speed2 = v205 and v187("tick_random", false) and v177, 
            tick_speed_info = v205 and v177
        };
        v212();
        for v217, v218 in pairs(v182) do
            local v219 = v176[v217 .. v180];
            if v219 and v219.visibility then
                v219:visibility(v218);
            end;
        end;
        for v220, v221 in pairs(v183) do
            local v222 = v176[v220];
            if v222 and v222.visibility then
                v222:visibility(v221);
            end;
        end;
    end;
    v9.hide_side = function(v223, v224)
        local v225 = v224 and "_ct" or "";
        for _, v227 in ipairs({
            [1] = "def_toggle", 
            [2] = "def_pitch", 
            [3] = "yaw_mode", 
            [4] = "yaw_center", 
            [5] = "yaw_left", 
            [6] = "yaw_right", 
            [7] = "Jitter", 
            [8] = "center_options", 
            [9] = "center_min", 
            [10] = "center_max", 
            [11] = "jitter_randomize", 
            [12] = "fake_left", 
            [13] = "fake_right", 
            [14] = "yaw_jitter_ovr", 
            [15] = "body_yaw", 
            [16] = "fake_options", 
            [17] = "reset", 
            [18] = "send_to", 
            [19] = "body_speed", 
            [20] = "speed_options", 
            [21] = "def_activation", 
            [22] = "spin_speed"
        }) do
            local v228 = v223[v227 .. v225];
            if v228 and v228:visibility() then
                v228:visibility(false);
            end;
        end;
    end;
    v9.visibility_handler = function()
        -- upvalues: v9 (ref), l_core_0 (ref), l_pui_0 (ref), v91 (ref)
        local v229 = v9.misc_chooser:get() == 1;
        local v230 = v9.misc_chooser:get() == 2;
        local v231 = v9.rage.team_list:get() == "T";
        local v232 = v9.rage.team_list:get() == "CT";
        local v233 = v9.rage.aa_lister:get() == 1;
        local v234 = v9.rage.aa_lister:get() == 2;
        local v235 = v9.rage.aa_lister:get() == 3;
        local v236 = v234 or v235;
        v9.rage.state_label:name(l_core_0:with_icon("wrench", "  Current State ", "{Link Active}") .. "\a" .. ui.get_style("Link Active"):to_hex() .. " \226\128\162 \r " .. v9.rage.state_list:get());
        v9.rage.state_label:visibility(v236);
        v9.rage.team_list:visibility(v236);
        v9.rage.state_list:visibility(v236);
        v9.rage.anims:visibility(v233);
        v9.rage.freestanding_bind:visibility(v233);
        v9.rage.manual:visibility(v233);
        v9.rage.safe_head:visibility(v233);
        v9.rage.avoid_knife:visibility(v233);
        v9.rage.additions:visibility(v233);
        l_pui_0.traverse(v9.visuals, function(v237)
            -- upvalues: v229 (ref)
            v237:visibility(v229);
        end);
        l_pui_0.traverse(v9.misc, function(v238)
            -- upvalues: v230 (ref)
            v238:visibility(v230);
        end);
        if v9.rage.anims.move_jitter_mode:get() == 1 then
            v9.rage.anims.move_legs1:visibility(false);
            v9.rage.anims.move_legs2:visibility(false);
            v9.rage.anims.move_jitter:visibility(true);
        else
            v9.rage.anims.move_legs1:visibility(true);
            v9.rage.anims.move_legs2:visibility(true);
            v9.rage.anims.move_jitter:visibility(false);
        end;
        for _, v240 in pairs(v91.conditions) do
            local v241 = v9.rage.state_list:get() == v240;
            local _ = v9.rage.hidden_builder.state_list:get() == v240;
            local v243 = v9.rage.builder_elements[v240];
            v9.hide_side(v243, false);
            v9.hide_side(v243, true);
            if v231 then
                local _ = v243.yaw_mode:get() == "Static" or not (v243.yaw_mode:get() ~= "3-way") or v243.yaw_mode:get() == "5-way";
                v9.set_visibility(v243, v241, false, 2);
            elseif v232 then
                local _ = v243.yaw_mode_ct:get() == "Static" or not (v243.yaw_mode_ct:get() ~= "3-way") or v243.yaw_mode_ct:get() == "5-way";
                v9.set_visibility(v243, v241, true, 2);
            end;
        end;
        for _, v247 in pairs(v91.conditions) do
            local v248 = v9.rage.state_list:get() == v247 and v235;
            local v249 = v9.rage.defensive_elements[v247];
            if v235 then
                for _, v251 in pairs(v249) do
                    if v251.visibility then
                        v251:visibility(false);
                    end;
                end;
                if v249.def_toggle then
                    v249.def_toggle:visibility(v248 and v231);
                end;
                if v249.def_toggle_ct then
                    v249.def_toggle_ct:visibility(v248 and v232);
                end;
                v249.def_activation:visibility(false);
                v249.def_activation_ct:visibility(false);
                if v231 then
                    v249.reset:visibility(v248);
                    v249.send_to:visibility(v248);
                else
                    v249.reset_ct:visibility(v248);
                    v249.send_to_ct:visibility(v248);
                end;
                if v231 then
                    v9.set_visibility(v249, v248, false, 3);
                    local v252 = v249.def_toggle and v249.def_toggle:get() or false;
                    for v253, v254 in pairs(v249) do
                        if v253:find("_ct") then
                            if v254.visibility then
                                v254:visibility(false);
                            end;
                        elseif v253 ~= "def_toggle" and v253 ~= "def_toggle_ct" and v254.visibility and v254:visibility() then
                            v254:visibility(v252);
                        end;
                    end;
                    if v249.pitch_offset then
                        v249.pitch_offset:visibility(v248 and v252 and v249.def_pitch:get() == "Custom");
                    end;
                end;
                if v232 then
                    v9.set_visibility(v249, v248, true, 3);
                    local v255 = v249.def_toggle_ct and v249.def_toggle_ct:get() or false;
                    for v256, v257 in pairs(v249) do
                        if not v256:find("_ct") then
                            if v257.visibility then
                                v257:visibility(false);
                            end;
                        elseif v256 ~= "def_toggle" and v256 ~= "def_toggle_ct" and v257.visibility and v257:visibility() then
                            v257:visibility(v255);
                        end;
                    end;
                    if v249.pitch_offset_ct then
                        v249.pitch_offset_ct:visibility(v248 and v255 and v249.def_pitch_ct:get() == "Custom");
                    end;
                end;
            else
                for _, v259 in pairs(v249) do
                    if v259.visibility then
                        v259:visibility(false);
                    end;
                end;
            end;
        end;
    end;
    if not db.configurations4 then
        local _ = {};
    end;
    local _ = nil;
    v7.is_config_in_list = function(v262)
        -- upvalues: v8 (ref)
        for _, v264 in ipairs(v8) do
            if v264:find(v262) then
                return true;
            end;
        end;
        return false;
    end;
    v9.main.preset_list:set_callback(function()
        -- upvalues: v9 (ref), v7 (ref)
        local v265 = v9.main.preset_list:get();
        local v266 = v7.get_config_name_from_index(v265);
        if v266 then
            v9.main.input_name:set(v266);
        end;
    end);
    v7.check_index = function()
        -- upvalues: v19 (ref), v9 (ref), v123 (ref)
        if v19.ui.getalpha() > 0 then
            local v267 = v9.main.preset_list:get();
            local _ = #v123;
            if v267 <= 6 then
                v9.main.new_button:disabled(true);
                v9.main.import_button:disabled(true);
                v9.main.export_button:disabled(true);
                v9.main.delete_button:disabled(true);
            else
                v9.main.new_button:disabled(false);
                v9.main.import_button:disabled(false);
                v9.main.export_button:disabled(false);
                v9.main.load_button:disabled(false);
                v9.main.delete_button:disabled(false);
            end;
            return;
        else
            return;
        end;
    end;
    v11.register("render", "ls_utils.check_index", v7.check_index);
    v7.export_config = function()
        -- upvalues: l_pui_0 (ref), l_clipboard_0 (ref), v12 (ref)
        local _ = l_pui_0.save();
        local v270 = json.stringify(l_pui_0.save());
        l_clipboard_0.set(v270);
        v12.push("config has been successfully exported!");
    end;
    v7.import_config = function()
        -- upvalues: l_clipboard_0 (ref), l_pui_0 (ref), v12 (ref)
        local v271 = l_clipboard_0.get();
        local v272 = json.parse(v271);
        l_pui_0.load(v272);
        v12.push("config has been successfully imported!");
    end;
    v7.save_config = function()
        -- upvalues: v9 (ref), v123 (ref), v12 (ref), v7 (ref), l_pui_0 (ref)
        local v273 = v9.main.preset_list:get();
        local v274 = #v123;
        local v275 = v9.main.input_name:get();
        if not v275 or v275 == "" then
            v12.push("please enter a valid config name");
            return;
        else
            local v276 = db.configurations4 or {};
            local v277 = v7.get_config_name_from_index(v273);
            if #v276 == 0 then
                table.remove(v123, 8);
            end;
            if v274 < v273 and v277 and v277 ~= v275 then
                print("creating new config:", v275);
                v12.push("creating new config:" .. v275);
            elseif v276[v275] then
                print("updating existing config:", v275);
                v12.push("updating existing config:" .. v275);
            end;
            v276[v275] = l_pui_0.save();
            db.configurations4 = v276;
            v7.update_config_list();
            v12.push("config saved : " .. v275);
            return;
        end;
    end;
    v7.update_config_list = function()
        -- upvalues: v8 (ref), l_core_0 (ref), v123 (ref), v9 (ref)
        v8 = {};
        local v278 = db.configurations4 or {};
        local v279 = {};
        for v280, _ in pairs(v278) do
            table.insert(v279, v280);
        end;
        table.sort(v279);
        for _, v283 in ipairs(v279) do
            table.insert(v8, l_core_0:with_icon("list-ul", v283, "{Link Active}"));
        end;
        local v284 = {};
        for v285 = 1, 6 do
            table.insert(v284, v123[v285]);
        end;
        if #v279 == 0 then
            table.insert(v284, v123[7]);
        end;
        for _, v287 in ipairs(v8) do
            table.insert(v284, v287);
        end;
        v9.main.preset_list:update(v284);
    end;
    v7.update_config_list();
    v7.get_config_name_from_index = function(v288)
        local v289 = db.configurations4 or {};
        local v290 = {};
        for v291, _ in pairs(v289) do
            table.insert(v290, v291);
        end;
        table.sort(v290);
        if v288 <= 6 then
            return nil;
        elseif #v290 == 0 and v288 == 7 then
            return nil;
        else
            local v293 = nil;
            if #v290 == 0 then
                v293 = v288 - 7;
            else
                v293 = v288 - 6;
            end;
            return v290[v293];
        end;
    end;
    local v294 = {
        ["crouch moving"] = "Crouch Moving", 
        crouch = "Crouch", 
        manual = "Manual", 
        jitter = "Jitter", 
        jitter_ct = "Jitter_ct", 
        air = "Air", 
        ["air crouch"] = "Air Crouch", 
        center = "Center", 
        ["l - r"] = "L - R", 
        running = "Running", 
        standing = "Standing", 
        slowmotion = "Slowmotion"
    };
    do
        local l_v294_0 = v294;
        renameKeys = function(v296)
            -- upvalues: l_v294_0 (ref)
            if type(v296) ~= "table" then
                return v296;
            else
                local v297 = {};
                for v298, v299 in pairs(v296) do
                    v297[l_v294_0[string.lower(v298)] or v298] = renameKeys(v299);
                end;
                return v297;
            end;
        end;
        v7.load_config = function()
            -- upvalues: v9 (ref), v12 (ref), v123 (ref), l_pui_0 (ref), v7 (ref)
            local v300 = v9.main.preset_list:get();
            if not v300 or v300 == 0 then
                v12.push("please select valid config to load");
                return;
            elseif v300 <= #v123 - 1 then
                if v300 == 1 then
                    local v301 = json.parse("{\"defensive\":{\"antiaim_conditions\":[\"~\"],\"defensive_conditions\":[\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air\",\"Air Crouch\",\"~\"],\"disablers\":[\"~\"],\"force_hideshot\":true,\"game_events\":[\"~\"],\"on_exploit\":[\"~\"],\"state_list\":\"Standing\"},\"main\":{\"input_name\":\"default\",\"preset_list\":1.0},\"misc\":{\"aim_logs\":true,\"aspect_ratio\":true,\"aspect_ratio_val\":134.0,\"clantag\":false,\"fast_ladder\":true,\"fps_boost\":true,\"kibit_hitmark\":false,\"kibit_hitmark_color\":\"#58FFD1FF\",\"no_fall\":true,\"view_model_changer\":true,\"viewmodel_changer_fov\":68.0,\"viewmodel_changer_x\":100.0,\"viewmodel_changer_y\":-100.0,\"viewmodel_changer_z\":200.0},\"rage\":{\"additions\":[\"Warmup / Round End AA\",\"Improve Fakelag on Defensive\",\"Avoid Backstab\",\"~\"],\"anims\":true,\"builder_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":2.0,\"fake_left_random_ct\":2.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":5.0,\"fake_right_random_ct\":5.0,\"flick_left\":-11.0,\"flick_left_body\":24.0,\"flick_left_body_ct\":24.0,\"flick_left_ct\":-11.0,\"flick_right\":11.0,\"flick_right_body\":26.0,\"flick_right_body_ct\":26.0,\"flick_right_ct\":11.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":5.0,\"flick_speed_random_ct\":6.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-29.0,\"yaw_left_ct\":-29.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":35.0,\"yaw_right_ct\":35.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Random\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-7.0,\"flick_left_body\":24.0,\"flick_left_body_ct\":24.0,\"flick_left_ct\":-7.0,\"flick_right\":15.0,\"flick_right_body\":26.0,\"flick_right_body_ct\":26.0,\"flick_right_ct\":15.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":3.0,\"flick_speed_random_ct\":3.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":-89.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-18.0,\"yaw_left_ct\":-18.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":44.0,\"yaw_right_ct\":44.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-32.0,\"yaw_left_ct\":-32.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":46.0,\"yaw_right_ct\":46.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-3.0,\"flick_left_body\":25.0,\"flick_left_body_ct\":8.0,\"flick_left_ct\":-7.0,\"flick_right\":6.0,\"flick_right_body\":29.0,\"flick_right_body_ct\":8.0,\"flick_right_ct\":12.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":3.0,\"flick_speed_random_ct\":5.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-22.0,\"yaw_left_ct\":-22.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":44.0,\"yaw_right_ct\":44.0},\"Manual\":{\"Jitter\":\"Center\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"Static\",\"yaw_mode_ct\":\"Static\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Random\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-12.0,\"flick_left_body\":26.0,\"flick_left_body_ct\":26.0,\"flick_left_ct\":-12.0,\"flick_right\":8.0,\"flick_right_body\":20.0,\"flick_right_body_ct\":20.0,\"flick_right_ct\":8.0,\"flick_speed\":8.0,\"flick_speed_ct\":8.0,\"flick_speed_random\":5.0,\"flick_speed_random_ct\":5.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":180.0,\"yaw_jitter_ovr_ct\":180.0,\"yaw_left\":-24.0,\"yaw_left_ct\":-24.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":37.0,\"yaw_right_ct\":37.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-23.0,\"yaw_left_ct\":-23.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":47.0,\"yaw_right_ct\":47.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":-5.0,\"center_max_ct\":0.0,\"center_min\":5.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":92.0,\"yaw_jitter_ovr_ct\":92.0,\"yaw_left\":-24.0,\"yaw_left_ct\":-24.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":41.0,\"yaw_right_ct\":41.0}},\"freestand_body\":2.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"freestanding_bind\":false,\"hidden_builder\":false,\"keep_fs\":true,\"manual\":\"At Target\",\"prefer_manual\":true,\"safe_head\":false,\"safe_options\":[\"~\"],\"state_list\":\"Air Crouch\",\"team_list\":1.0,\"~anims\":{\"move_fall\":0.0,\"move_jitter\":0.0,\"move_jitter_mode\":2.0,\"move_lean_val\":100.0,\"move_legs1\":0.0,\"move_legs2\":100.0}},\"visuals\":{\"accent\":\"#DFC3FFFF\",\"crosshair_ind\":false,\"fake_latency_slider\":0.0,\"fake_latency_toggle\":false,\"gs_inds\":false,\"molotov_radius\":true,\"notifs\":false,\"scope\":true,\"slowed_down\":true,\"smokes_radius\":true,\"unlock_fakeduck\":true,\"watermark\":\"Left\",\"watermark_style\":1.0,\"~notifs\":{\"notifs_glow_amount\":41.0,\"notifs_hit_clr\":\"#00FF00FF\",\"notifs_miss_clr\":\"#FF0000FF\",\"notifs_prefix\":false,\"notifs_prefix_clr\":\"#00FF00FF\",\"notifs_prefix_font\":1.0,\"notifs_round_amount\":11.0},\"~scope\":{\"scope_color1\":\"#FFFFFFFF\",\"scope_color2\":\"#FFFFFF00\",\"scope_gap\":5.0,\"scope_settings\":[\"~\"],\"scope_size\":100.0,\"scope_style\":1.0}}}");
                    l_pui_0.load(v301);
                    v12.push("Meta preset has been successfully imported!");
                elseif v300 == 2 then
                    local v302 = json.parse("{\"defensive\":{\"antiaim_conditions\":[\"~\"],\"defensive_conditions\":[\"Crouch\",\"Crouch Moving\",\"~\"],\"disablers\":[\"~\"],\"force_hideshot\":false,\"game_events\":[\"~\"],\"on_exploit\":[\"~\"],\"state_list\":\"Standing\"},\"main\":{\"input_name\":\"omg?\",\"preset_list\":2.0},\"misc\":{\"aim_logs\":true,\"aspect_ratio\":true,\"aspect_ratio_val\":139.0,\"clantag\":false,\"fast_ladder\":true,\"fps_boost\":true,\"kibit_hitmark\":true,\"kibit_hitmark_color\":\"#58FFD1FF\",\"no_fall\":true,\"view_model_changer\":true,\"viewmodel_changer_fov\":65.0,\"viewmodel_changer_x\":205.0,\"viewmodel_changer_y\":100.0,\"viewmodel_changer_z\":-100.0},\"rage\":{\"additions\":[\"Warmup / Round End AA\",\"Improve Fakelag on Defensive\",\"Avoid Backstab\",\"~\"],\"anims\":true,\"builder_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":39.0,\"yaw_left\":-19.0,\"yaw_left_ct\":-22.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":23.0,\"yaw_right_ct\":27.0},\"Air Crouch\":{\"Jitter\":\"Center\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":7.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-10.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-10.0,\"yaw_left_ct\":-24.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":31.0,\"yaw_right_ct\":30.0},\"Crouch\":{\"Jitter\":\"Center\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":20.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-31.0,\"yaw_jitter_ovr_ct\":-3.0,\"yaw_left\":5.0,\"yaw_left_ct\":-10.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":5.0,\"yaw_right_ct\":16.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":20.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":-30.0,\"yaw_left\":-10.0,\"yaw_left_ct\":-8.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":31.0,\"yaw_right_ct\":20.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"Static\",\"yaw_mode_ct\":\"Static\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Center\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":14.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-58.0,\"yaw_jitter_ovr_ct\":-62.0,\"yaw_left\":6.0,\"yaw_left_ct\":6.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":6.0,\"yaw_right_ct\":6.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-23.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"Static\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":47.0,\"yaw_right_ct\":0.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":0.0,\"custom_speed_slider_10\":0.0,\"custom_speed_slider_10_ct\":0.0,\"custom_speed_slider_11\":0.0,\"custom_speed_slider_11_ct\":0.0,\"custom_speed_slider_12\":0.0,\"custom_speed_slider_12_ct\":0.0,\"custom_speed_slider_13\":0.0,\"custom_speed_slider_13_ct\":0.0,\"custom_speed_slider_14\":0.0,\"custom_speed_slider_14_ct\":0.0,\"custom_speed_slider_15\":0.0,\"custom_speed_slider_15_ct\":0.0,\"custom_speed_slider_16\":0.0,\"custom_speed_slider_16_ct\":0.0,\"custom_speed_slider_17\":0.0,\"custom_speed_slider_17_ct\":0.0,\"custom_speed_slider_18\":0.0,\"custom_speed_slider_18_ct\":0.0,\"custom_speed_slider_19\":0.0,\"custom_speed_slider_19_ct\":0.0,\"custom_speed_slider_1_ct\":0.0,\"custom_speed_slider_2\":0.0,\"custom_speed_slider_20\":0.0,\"custom_speed_slider_20_ct\":0.0,\"custom_speed_slider_21\":0.0,\"custom_speed_slider_21_ct\":0.0,\"custom_speed_slider_22\":0.0,\"custom_speed_slider_22_ct\":0.0,\"custom_speed_slider_2_ct\":0.0,\"custom_speed_slider_3\":0.0,\"custom_speed_slider_3_ct\":0.0,\"custom_speed_slider_4\":0.0,\"custom_speed_slider_4_ct\":0.0,\"custom_speed_slider_5\":0.0,\"custom_speed_slider_5_ct\":0.0,\"custom_speed_slider_6\":0.0,\"custom_speed_slider_6_ct\":0.0,\"custom_speed_slider_7\":0.0,\"custom_speed_slider_7_ct\":0.0,\"custom_speed_slider_8\":0.0,\"custom_speed_slider_8_ct\":0.0,\"custom_speed_slider_9\":0.0,\"custom_speed_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"None\",\"extend_option_ct\":\"None\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":16.0,\"flick_left_body_ct\":16.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":16.0,\"flick_right_body_ct\":16.0,\"flick_right_ct\":0.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":7.0,\"flick_speed_random_ct\":7.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"Static\",\"yaw_mode_ct\":\"Static\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0}},\"freestand_body\":1.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"freestanding_bind\":false,\"hidden_builder\":false,\"keep_fs\":true,\"manual\":\"At Target\",\"prefer_manual\":true,\"safe_head\":false,\"safe_options\":[\"~\"],\"state_list\":\"Standing\",\"team_list\":2.0,\"~anims\":{\"move_fall\":0.0,\"move_jitter\":0.0,\"move_jitter_mode\":2.0,\"move_lean_val\":100.0,\"move_legs1\":0.0,\"move_legs2\":100.0}},\"visuals\":{\"accent\":\"#96C83CFF\",\"crosshair_ind\":false,\"fake_latency_slider\":0.0,\"fake_latency_toggle\":false,\"gs_inds\":false,\"molotov_radius\":true,\"notifs\":true,\"scope\":true,\"slowed_down\":true,\"smokes_radius\":true,\"unlock_fakeduck\":true,\"watermark\":\"Bottom\",\"watermark_style\":1.0,\"~notifs\":{\"notifs_glow_amount\":41.0,\"notifs_hit_clr\":\"#00FF00FF\",\"notifs_miss_clr\":\"#FF0000FF\",\"notifs_prefix\":false,\"notifs_prefix_clr\":\"#00FF00FF\",\"notifs_prefix_font\":1.0,\"notifs_round_amount\":11.0},\"~scope\":{\"scope_color1\":\"#FFFFFFFF\",\"scope_color2\":\"#FFFFFF00\",\"scope_gap\":5.0,\"scope_settings\":[\"~\"],\"scope_size\":100.0,\"scope_style\":1.0}}}");
                    l_pui_0.load(v302);
                    v12.push("Aggressive preset has been successfully imported!");
                elseif v300 == 3 then
                    local v303 = json.parse("{\"defensive\":{\"defensive_conditions\":[\"Standing\",\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air\",\"Air Crouch\",\"~\"],\"force_hideshot\":false,\"game_events\":[\"~\"]},\"main\":{\"input_name\":\"type here\",\"preset_list\":3.0},\"misc\":{\"aspect_ratio\":true,\"aspect_ratio_val\":133.0,\"clantag\":false,\"client_nickname\":false,\"fake_latency_toggle\":false,\"fast_ladder\":true,\"freeze_fakeduck\":false,\"log_event\":[\"~\"],\"no_fall\":true,\"super_toss\":false,\"unlock_fakeduck\":false,\"view_model_changer\":false,\"viewmodel_changer_fov\":68.0,\"viewmodel_changer_x\":205.0,\"viewmodel_changer_y\":100.0,\"viewmodel_changer_z\":-100.0,\"~client_nickname\":{\"client_nickname_text\":\"Type Here\"},\"~fake_latency_toggle\":{\"fake_latency_slider\":0.0}},\"misc_chooser\":1.0,\"rage\":{\"aa_lister\":1.0,\"additions\":[\"Warmup / Round End AA\",\"~\"],\"anims\":true,\"avoid_knife\":false,\"builder_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":4.0,\"body_speed_ct\":4.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-18.0,\"yaw_left_ct\":-18.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":27.0,\"yaw_right_ct\":27.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":true,\"antibrute_ct\":true,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":4.0,\"body_speed_ct\":4.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":1.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":5.0,\"tick_speed2\":15.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-19.0,\"yaw_left_ct\":-19.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":47.0,\"yaw_right_ct\":47.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":4.0,\"body_speed_ct\":4.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":-30.0,\"yaw_center_ct\":-30.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":45.0,\"yaw_right_ct\":45.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":true,\"antibrute_ct\":true,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":4.0,\"body_speed_ct\":4.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":6.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":86.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":-180.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":1.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":3.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":6.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":7.0,\"tick_speed2\":15.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-76.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":33.0,\"yaw_right_ct\":33.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Static\",\"fake_options_ct\":\"Static\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Amnesia\",\"speed_options_ct\":\"Amnesia\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":12.0,\"ran_speed_2_ct\":12.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Inverter\",\"speed_options_ct\":\"Inverter\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-27.0,\"yaw_jitter_ovr_ct\":-27.0,\"yaw_left\":-25.0,\"yaw_left_ct\":-25.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":42.0,\"yaw_right_ct\":42.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Randomize\",\"custom_amount\":4.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":-22.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":-111.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":56.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":45.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":7.0,\"ran_speed_1_ct\":11.0,\"ran_speed_2\":10.0,\"ran_speed_2_ct\":17.0,\"random_speed\":true,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Amnesia\",\"speed_options_ct\":\"Amnesia\",\"tick_random\":false,\"tick_speed1\":22.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-31.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":45.0,\"yaw_right_ct\":0.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Randomize\",\"custom_amount\":4.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":-22.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":-57.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":1.0,\"custom_speed_slider_10_ct\":1.0,\"custom_speed_slider_11\":1.0,\"custom_speed_slider_11_ct\":1.0,\"custom_speed_slider_12\":1.0,\"custom_speed_slider_12_ct\":1.0,\"custom_speed_slider_13\":1.0,\"custom_speed_slider_13_ct\":1.0,\"custom_speed_slider_14\":1.0,\"custom_speed_slider_14_ct\":1.0,\"custom_speed_slider_15\":1.0,\"custom_speed_slider_15_ct\":1.0,\"custom_speed_slider_16\":1.0,\"custom_speed_slider_16_ct\":1.0,\"custom_speed_slider_17\":1.0,\"custom_speed_slider_17_ct\":1.0,\"custom_speed_slider_18\":1.0,\"custom_speed_slider_18_ct\":1.0,\"custom_speed_slider_19\":1.0,\"custom_speed_slider_19_ct\":1.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":1.0,\"custom_speed_slider_20_ct\":1.0,\"custom_speed_slider_21\":1.0,\"custom_speed_slider_21_ct\":1.0,\"custom_speed_slider_22\":1.0,\"custom_speed_slider_22_ct\":1.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":1.0,\"custom_speed_slider_6_ct\":1.0,\"custom_speed_slider_7\":1.0,\"custom_speed_slider_7_ct\":1.0,\"custom_speed_slider_8\":1.0,\"custom_speed_slider_8_ct\":1.0,\"custom_speed_slider_9\":1.0,\"custom_speed_slider_9_ct\":1.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":20.0,\"ran_speed_2_ct\":20.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-33.0,\"yaw_left_ct\":-33.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":41.0,\"yaw_right_ct\":41.0}},\"defensive_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":0.0,\"body_speed_ct\":0.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0}},\"freestanding_bind\":false,\"hidden_builder\":false,\"manual\":\"At Target\",\"safe_head\":false,\"state_list\":\"Running\",\"team_list\":\"T\",\"~anims\":{\"move_fall\":0.0,\"move_jitter\":0.0,\"move_jitter_mode\":1.0,\"move_lean_val\":0.0,\"move_legs1\":0.0,\"move_legs2\":0.0},\"~freestanding_bind\":{\"freestand_body\":1.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"keep_fs\":false,\"prefer_manual\":false},\"~hidden_builder\":{\"antiaim_conditions\":[\"~\"],\"disablers\":[\"~\"],\"on_exploit\":[\"~\"],\"state_list\":\"Standing\"},\"~safe_head\":{\"safe_options\":[\"~\"]}},\"visuals\":{\"accent\":\"#96C83CFF\",\"gs_inds\":false,\"kibit_hitmark\":false,\"molotov_radius\":false,\"notifs\":false,\"scope\":true,\"slowed_down\":false,\"smokes_radius\":false,\"watermark\":\"Left\",\"watermark_style\":1.0,\"~kibit_hitmark\":{\"kibit_hitmark_color\":\"#58FFD1FF\"},\"~notifs\":{\"notifs_glow_amount\":41.0,\"notifs_hit_clr\":\"#00FF00FF\",\"notifs_miss_clr\":\"#FF0000FF\",\"notifs_prefix\":false,\"notifs_prefix_clr\":\"#00FF00FF\",\"notifs_prefix_font\":1.0,\"notifs_round_amount\":11.0},\"~scope\":{\"scope_color1\":\"#FFFFFFFF\",\"scope_color2\":\"#FFFFFF00\",\"scope_gap\":5.0,\"scope_settings\":[\"~\"],\"scope_size\":190.0,\"scope_style\":1.0}}}");
                    l_pui_0.load(v303);
                    v12.push("Snap [Test] preset has been successfully imported!");
                elseif v300 == 4 then
                    local v304 = json.parse("{\"defensive\":{\"defensive_conditions\":[\"Standing\",\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air\",\"Air Crouch\",\"~\"],\"force_hideshot\":true,\"game_events\":[\"~\"]},\"main\":{\"input_name\":\"hold test\",\"preset_list\":4.0},\"misc\":{\"aspect_ratio\":true,\"aspect_ratio_val\":133.0,\"clantag\":false,\"client_nickname\":true,\"fake_latency_toggle\":false,\"fast_ladder\":true,\"freeze_fakeduck\":false,\"log_event\":[\"Aimbot\",\"Purchases\",\"~\"],\"no_fall\":true,\"super_toss\":false,\"unlock_fakeduck\":true,\"view_model_changer\":false,\"viewmodel_changer_fov\":68.0,\"viewmodel_changer_x\":205.0,\"viewmodel_changer_y\":100.0,\"viewmodel_changer_z\":-100.0,\"~client_nickname\":{\"client_nickname_text\":\"brandon\"},\"~fake_latency_toggle\":{\"fake_latency_slider\":0.0}},\"misc_chooser\":2.0,\"rage\":{\"aa_lister\":2.0,\"additions\":[\"Warmup / Round End AA\",\"~\"],\"anims\":true,\"avoid_knife\":true,\"builder_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-18.0,\"yaw_left_ct\":-18.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":27.0,\"yaw_right_ct\":27.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":true,\"antibrute_ct\":true,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":5.0,\"body_speed_ct\":5.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":1.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":3.0,\"ran_speed_1_ct\":3.0,\"ran_speed_2\":4.0,\"ran_speed_2_ct\":4.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":16.0,\"tick_speed2\":16.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-19.0,\"yaw_left_ct\":-19.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":47.0,\"yaw_right_ct\":47.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":-30.0,\"yaw_center_ct\":-30.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":45.0,\"yaw_right_ct\":45.0},\"Crouch Moving\":{\"Jitter\":\"3-way\",\"Jitter_ct\":\"3-way\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":true,\"antibrute_ct\":true,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Custom\",\"custom_amount\":6.0,\"custom_amount_ct\":6.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":86.0,\"custom_slider_12_ct\":86.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":15.0,\"custom_slider_4_ct\":15.0,\"custom_slider_5\":-10.0,\"custom_slider_5_ct\":-10.0,\"custom_slider_6\":15.0,\"custom_slider_6_ct\":15.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":1.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":3.0,\"ran_speed_1_ct\":3.0,\"ran_speed_2\":6.0,\"ran_speed_2_ct\":6.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":14.0,\"tick_speed2\":18.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":6.0,\"yaw_jitter_ovr_ct\":6.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":33.0,\"yaw_right_ct\":33.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Static\",\"fake_options_ct\":\"Static\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Amnesia\",\"speed_options_ct\":\"Amnesia\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":3.0,\"fake_left_random_ct\":3.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":3.0,\"fake_right_random_ct\":3.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":12.0,\"ran_speed_2_ct\":12.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Amnesia\",\"speed_options_ct\":\"Amnesia\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-27.0,\"yaw_jitter_ovr_ct\":-27.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":30.0,\"yaw_right_ct\":30.0},\"Slowmotion\":{\"Jitter\":\"Random\",\"Jitter_ct\":\"Random\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Custom\",\"custom_amount\":4.0,\"custom_amount_ct\":4.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":-22.0,\"custom_slider_4_ct\":-22.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":-111.0,\"custom_slider_6_ct\":-111.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":56.0,\"fake_left_ct\":56.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":45.0,\"fake_right_ct\":45.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":11.0,\"ran_speed_1_ct\":11.0,\"ran_speed_2\":18.0,\"ran_speed_2_ct\":18.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":22.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-38.0,\"yaw_left_ct\":-38.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":44.0,\"yaw_right_ct\":44.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":4.0,\"custom_amount_ct\":4.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":-22.0,\"custom_slider_4_ct\":-22.0,\"custom_slider_5\":-57.0,\"custom_slider_5_ct\":-57.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":20.0,\"ran_speed_2_ct\":20.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-33.0,\"yaw_left_ct\":-33.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":41.0,\"yaw_right_ct\":41.0}},\"defensive_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0}},\"freestanding_bind\":false,\"hidden_builder\":false,\"manual\":\"At Target\",\"safe_head\":true,\"state_list\":\"Standing\",\"team_list\":\"T\",\"~anims\":{\"move_fall\":0.0,\"move_jitter\":0.0,\"move_jitter_mode\":2.0,\"move_lean_val\":100.0,\"move_legs1\":0.0,\"move_legs2\":100.0},\"~freestanding_bind\":{\"freestand_body\":1.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"keep_fs\":false,\"prefer_manual\":false},\"~hidden_builder\":{\"antiaim_conditions\":[\"~\"],\"disablers\":[\"~\"],\"on_exploit\":[\"~\"],\"state_list\":\"Standing\"},\"~safe_head\":{\"safe_options\":[3.0,\"~\"]}},\"visuals\":{\"accent\":\"#96C83CFF\",\"gs_inds\":false,\"kibit_hitmark\":false,\"molotov_radius\":false,\"notifs\":false,\"scope\":true,\"slowed_down\":true,\"smokes_radius\":false,\"watermark\":\"Left\",\"watermark_style\":1.0,\"~kibit_hitmark\":{\"kibit_hitmark_color\":\"#58FFD1FF\"},\"~notifs\":{\"notifs_glow_amount\":41.0,\"notifs_hit_clr\":\"#00FF00FF\",\"notifs_miss_clr\":\"#FF0000FF\",\"notifs_prefix\":false,\"notifs_prefix_clr\":\"#00FF00FF\",\"notifs_prefix_font\":1.0,\"notifs_round_amount\":11.0},\"~scope\":{\"scope_color1\":\"#FFFFFFFF\",\"scope_color2\":\"#8A8A8A00\",\"scope_gap\":5.0,\"scope_settings\":[\"~\"],\"scope_size\":201.0,\"scope_style\":1.0}}}");
                    l_pui_0.load(v304);
                    v12.push("Custom Jitter preset has been successfully imported!");
                elseif v300 == 5 then
                    local v305 = json.parse("{\"defensive\":{\"defensive_conditions\":[\"Standing\",\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air Crouch\",\"~\"],\"force_hideshot\":false,\"game_events\":[\"~\"]},\"main\":{\"input_name\":\"defaultnyuanza\",\"preset_list\":5.0},\"misc\":{\"aspect_ratio\":true,\"aspect_ratio_val\":133.0,\"clantag\":false,\"client_nickname\":false,\"fake_latency_toggle\":false,\"fast_ladder\":true,\"freeze_fakeduck\":true,\"log_event\":[\"Aimbot\",\"Purchases\",\"~\"],\"no_fall\":true,\"super_toss\":true,\"unlock_fakeduck\":true,\"view_model_changer\":true,\"viewmodel_changer_fov\":72.0,\"viewmodel_changer_x\":0.0,\"viewmodel_changer_y\":-174.0,\"viewmodel_changer_z\":-314.0,\"~client_nickname\":{\"client_nickname_text\":\"Type Here\"},\"~fake_latency_toggle\":{\"fake_latency_slider\":30.0}},\"misc_chooser\":1.0,\"rage\":{\"aa_lister\":2.0,\"additions\":[\"~\"],\"anims\":true,\"avoid_knife\":true,\"builder_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":8.0,\"body_speed_ct\":8.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Custom\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":4.0,\"yaw_randomize_ct\":4.0,\"yaw_right\":30.0,\"yaw_right_ct\":30.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":7.0,\"amplitude_ct\":7.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":12.0,\"custom_amount_ct\":12.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":-24.0,\"custom_slider_12_ct\":-24.0,\"custom_slider_13\":6.0,\"custom_slider_13_ct\":6.0,\"custom_slider_14\":-6.0,\"custom_slider_14_ct\":-6.0,\"custom_slider_15\":-10.0,\"custom_slider_15_ct\":-10.0,\"custom_slider_16\":-23.0,\"custom_slider_16_ct\":-23.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":-19.0,\"custom_slider_6_ct\":-19.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":6.0,\"custom_speed_amount_ct\":6.0,\"custom_speed_slider_1\":1.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":1.0,\"custom_speed_slider_2\":1.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":1.0,\"custom_speed_slider_3\":1.0,\"custom_speed_slider_3_ct\":1.0,\"custom_speed_slider_4\":1.0,\"custom_speed_slider_4_ct\":1.0,\"custom_speed_slider_5\":1.0,\"custom_speed_slider_5_ct\":1.0,\"custom_speed_slider_6\":20.0,\"custom_speed_slider_6_ct\":20.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":18.0,\"frequency_ct\":18.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":6.0,\"ran_speed_1_ct\":6.0,\"ran_speed_2\":10.0,\"ran_speed_2_ct\":10.0,\"random_speed\":true,\"random_speed_ct\":true,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":12.0,\"tick_speed2\":16.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-20.0,\"yaw_left_ct\":-20.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":4.0,\"yaw_randomize_ct\":4.0,\"yaw_right\":42.0,\"yaw_right_ct\":42.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":6.0,\"custom_amount_ct\":6.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":-15.0,\"custom_slider_5_ct\":-15.0,\"custom_slider_6\":19.0,\"custom_slider_6_ct\":19.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":6.0,\"custom_speed_amount_ct\":6.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":3.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":3.0,\"custom_speed_slider_3\":4.0,\"custom_speed_slider_3_ct\":4.0,\"custom_speed_slider_4\":5.0,\"custom_speed_slider_4_ct\":5.0,\"custom_speed_slider_5\":3.0,\"custom_speed_slider_5_ct\":3.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":1.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":16.0,\"tick_speed2\":1.0,\"yaw_center\":-30.0,\"yaw_center_ct\":-30.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-30.0,\"yaw_left_ct\":-30.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":5.0,\"yaw_randomize_ct\":5.0,\"yaw_right\":46.0,\"yaw_right_ct\":46.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":8.0,\"body_speed_ct\":8.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":1.0,\"center_max_ct\":1.0,\"center_min\":-1.0,\"center_min_ct\":-1.0,\"center_options\":\"Min - Max\",\"center_options_ct\":\"Min - Max\",\"custom_amount\":6.0,\"custom_amount_ct\":6.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":-6.0,\"custom_slider_13_ct\":-6.0,\"custom_slider_14\":-19.0,\"custom_slider_14_ct\":-19.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":-15.0,\"custom_slider_5_ct\":-15.0,\"custom_slider_6\":19.0,\"custom_slider_6_ct\":19.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":5.0,\"custom_speed_amount_ct\":5.0,\"custom_speed_slider_1\":4.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":4.0,\"custom_speed_slider_2\":4.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":4.0,\"custom_speed_slider_3\":6.0,\"custom_speed_slider_3_ct\":6.0,\"custom_speed_slider_4\":4.0,\"custom_speed_slider_4_ct\":4.0,\"custom_speed_slider_5\":4.0,\"custom_speed_slider_5_ct\":4.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":4.0,\"ran_speed_1_ct\":4.0,\"ran_speed_2\":14.0,\"ran_speed_2_ct\":14.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":14.0,\"tick_speed2\":18.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":6.0,\"yaw_jitter_ovr_ct\":6.0,\"yaw_left\":-27.0,\"yaw_left_ct\":-27.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":3.0,\"yaw_randomize_ct\":3.0,\"yaw_right\":40.0,\"yaw_right_ct\":40.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":6.0,\"body_speed_ct\":6.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":6.0,\"custom_speed_amount_ct\":6.0,\"custom_speed_slider_1\":3.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":3.0,\"custom_speed_slider_2\":3.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":3.0,\"custom_speed_slider_3\":3.0,\"custom_speed_slider_3_ct\":3.0,\"custom_speed_slider_4\":3.0,\"custom_speed_slider_4_ct\":3.0,\"custom_speed_slider_5\":3.0,\"custom_speed_slider_5_ct\":3.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":4.0,\"ran_speed_1_ct\":4.0,\"ran_speed_2\":6.0,\"ran_speed_2_ct\":6.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Custom\",\"random_speed_method_ct\":\"Custom\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-27.0,\"yaw_jitter_ovr_ct\":-27.0,\"yaw_left\":-27.0,\"yaw_left_ct\":-27.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":3.0,\"yaw_randomize_ct\":3.0,\"yaw_right\":39.0,\"yaw_right_ct\":39.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":4.0,\"anti_timeout_ct\":4.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":2.0,\"antibrute_method_ct\":2.0,\"body_speed\":10.0,\"body_speed_ct\":8.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Custom\",\"center_options_ct\":\"Custom\",\"custom_amount\":6.0,\"custom_amount_ct\":6.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":-19.0,\"custom_slider_5_ct\":-19.0,\"custom_slider_6\":15.0,\"custom_slider_6_ct\":15.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":4.0,\"custom_speed_amount_ct\":4.0,\"custom_speed_slider_1\":16.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":16.0,\"custom_speed_slider_2\":13.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":13.0,\"custom_speed_slider_3\":20.0,\"custom_speed_slider_3_ct\":20.0,\"custom_speed_slider_4\":11.0,\"custom_speed_slider_4_ct\":11.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":58.0,\"fake_left_ct\":58.0,\"fake_left_random\":28.0,\"fake_left_random_ct\":28.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":58.0,\"fake_right_ct\":58.0,\"fake_right_random\":28.0,\"fake_right_random_ct\":28.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":14.0,\"ran_speed_2_ct\":14.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Custom\",\"random_speed_method_ct\":\"Custom\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":true,\"tick_speed1\":2.0,\"tick_speed2\":22.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-31.0,\"yaw_left_ct\":-31.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":5.0,\"yaw_randomize_ct\":5.0,\"yaw_right\":47.0,\"yaw_right_ct\":47.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":8.0,\"body_speed_ct\":8.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":4.0,\"custom_amount_ct\":4.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":-22.0,\"custom_slider_4_ct\":-22.0,\"custom_slider_5\":-57.0,\"custom_slider_5_ct\":-57.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"custom_speed_amount\":1.0,\"custom_speed_amount_ct\":1.0,\"custom_speed_slider_1\":2.0,\"custom_speed_slider_10\":2.0,\"custom_speed_slider_10_ct\":2.0,\"custom_speed_slider_11\":2.0,\"custom_speed_slider_11_ct\":2.0,\"custom_speed_slider_12\":2.0,\"custom_speed_slider_12_ct\":2.0,\"custom_speed_slider_13\":2.0,\"custom_speed_slider_13_ct\":2.0,\"custom_speed_slider_14\":2.0,\"custom_speed_slider_14_ct\":2.0,\"custom_speed_slider_15\":2.0,\"custom_speed_slider_15_ct\":2.0,\"custom_speed_slider_16\":2.0,\"custom_speed_slider_16_ct\":2.0,\"custom_speed_slider_17\":2.0,\"custom_speed_slider_17_ct\":2.0,\"custom_speed_slider_18\":2.0,\"custom_speed_slider_18_ct\":2.0,\"custom_speed_slider_19\":2.0,\"custom_speed_slider_19_ct\":2.0,\"custom_speed_slider_1_ct\":2.0,\"custom_speed_slider_2\":2.0,\"custom_speed_slider_20\":2.0,\"custom_speed_slider_20_ct\":2.0,\"custom_speed_slider_21\":2.0,\"custom_speed_slider_21_ct\":2.0,\"custom_speed_slider_22\":2.0,\"custom_speed_slider_22_ct\":2.0,\"custom_speed_slider_2_ct\":2.0,\"custom_speed_slider_3\":2.0,\"custom_speed_slider_3_ct\":2.0,\"custom_speed_slider_4\":2.0,\"custom_speed_slider_4_ct\":2.0,\"custom_speed_slider_5\":2.0,\"custom_speed_slider_5_ct\":2.0,\"custom_speed_slider_6\":2.0,\"custom_speed_slider_6_ct\":2.0,\"custom_speed_slider_7\":2.0,\"custom_speed_slider_7_ct\":2.0,\"custom_speed_slider_8\":2.0,\"custom_speed_slider_8_ct\":2.0,\"custom_speed_slider_9\":2.0,\"custom_speed_slider_9_ct\":2.0,\"defensive_tickbase\":0.0,\"fake_left\":59.0,\"fake_left_ct\":59.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":59.0,\"fake_right_ct\":59.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":20.0,\"ran_speed_2_ct\":20.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-23.0,\"yaw_left_ct\":-23.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":6.0,\"yaw_randomize_ct\":6.0,\"yaw_right\":45.0,\"yaw_right_ct\":45.0}},\"defensive_elements\":{\"Air\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Air Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":6.0,\"body_speed_ct\":8.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Inverter\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-25.0,\"yaw_left_ct\":-25.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":5.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":53.0,\"yaw_right_ct\":41.0},\"Crouch\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Crouch Moving\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":6.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Custom\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Static\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":82.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Amnesia\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":-15.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-27.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":12.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":32.0,\"yaw_right_ct\":0.0},\"Manual\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":10.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Inverter\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-41.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":3.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":41.0,\"yaw_right_ct\":0.0},\"Slowmotion\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Standing\":{\"Jitter\":\"Disabled\",\"Jitter_ct\":\"Disabled\",\"amnesia_tick_speed\":16.0,\"amnesia_tick_speed_ct\":16.0,\"amplitude\":0.0,\"amplitude_ct\":0.0,\"body_speed\":1.0,\"body_speed_ct\":1.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"def_activation\":\"Always\",\"def_activation_ct\":\"Always\",\"def_pitch\":\"Down\",\"def_pitch_ct\":\"Down\",\"def_toggle\":false,\"def_toggle_ct\":false,\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"frequency\":0.0,\"frequency_ct\":0.0,\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"pitch_offset\":0.0,\"pitch_offset_ct\":0.0,\"r_max\":0.0,\"r_max_ct\":0.0,\"r_min\":0.0,\"r_min_ct\":0.0,\"ran_speed_1\":1.0,\"ran_speed_1_ct\":1.0,\"ran_speed_2\":1.0,\"ran_speed_2_ct\":1.0,\"random_speed\":false,\"random_speed_ct\":false,\"random_speed_method\":\"Random\",\"random_speed_method_ct\":\"Random\",\"scale\":0.0,\"scale_ct\":0.0,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"spin_speed_ct\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_random_methods\":\"Default\",\"yaw_random_methods_ct\":\"Default\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0}},\"freestanding_bind\":false,\"hidden_builder\":false,\"manual\":\"At Target\",\"safe_head\":true,\"state_list\":\"Slowmotion\",\"team_list\":\"T\",\"~anims\":{\"move_fall\":0.0,\"move_jitter\":0.0,\"move_jitter_mode\":2.0,\"move_lean_val\":100.0,\"move_legs1\":0.0,\"move_legs2\":100.0},\"~freestanding_bind\":{\"freestand_body\":2.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"keep_fs\":true,\"prefer_manual\":true},\"~hidden_builder\":{\"antiaim_conditions\":[\"~\"],\"disablers\":[\"~\"],\"on_exploit\":[\"~\"],\"state_list\":\"Standing\"},\"~safe_head\":{\"safe_options\":[3.0,\"~\"]}},\"visuals\":{\"accent\":\"#FBC3FAFF\",\"gs_inds\":true,\"kibit_hitmark\":true,\"molotov_radius\":false,\"notifs\":false,\"scope\":true,\"slowed_down\":true,\"smokes_radius\":false,\"watermark\":\"Bottom\",\"watermark_style\":1.0,\"~kibit_hitmark\":{\"kibit_hitmark_color\":\"#58FFD1FF\"},\"~notifs\":{\"notifs_glow_amount\":41.0,\"notifs_hit_clr\":\"#FBC3FAFF\",\"notifs_miss_clr\":\"#FF0000FF\",\"notifs_prefix\":true,\"notifs_prefix_clr\":\"#FBC3FAFF\",\"notifs_prefix_font\":4.0,\"notifs_round_amount\":11.0},\"~scope\":{\"scope_color1\":\"#C5C5C5FF\",\"scope_color2\":\"#FFFFFF00\",\"scope_gap\":5.0,\"scope_settings\":[\"~\"],\"scope_size\":197.0,\"scope_style\":1.0}}}");
                    l_pui_0.load(v305);
                    v12.push("Royal preset has been successfully imported!");
                end;
                return;
            else
                local v306 = v7.get_config_name_from_index(v300);
                if not v306 then
                    v12.push("no config found with the selected index");
                    return;
                else
                    local v307 = (db.configurations4 or {})[v306];
                    if not v307 then
                        v12.push("no config found with name : " .. v306);
                        return;
                    else
                        local _ = "{\"defensive\":{\"antiaim_conditions\":[\"Standing\",\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air\",\"Air Crouch\",\"~\"],\"defensive_conditions\":[\"Standing\",\"Slowmotion\",\"Crouch\",\"Crouch Moving\",\"Air\",\"Air Crouch\",\"~\"],\"disablers\":[\"freestanding\",\"manual aa\",\"peek assist\",\"~\"],\"force_hideshot\":true,\"game_events\":[\"~\"],\"on_exploit\":[\"doubletap\",\"hideshots\",\"~\"],\"state_list\":\"Air Crouch\"},\"main\":{\"input_name\":\"default\",\"preset_list\":6.0},\"misc\":{\"aim_logs\":true,\"aspect_ratio\":true,\"aspect_ratio_val\":134.0,\"clantag\":false,\"fake_latency\":15.0,\"fast_ladder\":true,\"fps_boost\":true,\"kibit_hitmark\":false,\"kibit_hitmark_color\":\"#58FFD1FF\",\"no_fall\":false,\"view_model_changer\":true,\"viewmodel_changer_fov\":68.0,\"viewmodel_changer_x\":100.0,\"viewmodel_changer_y\":-100.0,\"viewmodel_changer_z\":200.0},\"rage\":{\"anim_options\":[1.0,2.0,\"~\"],\"anims\":true,\"anti_back\":false,\"builder_elements\":{\"Air\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Auto\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":2.0,\"fake_left_random_ct\":2.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":5.0,\"fake_right_random_ct\":5.0,\"flick_left\":-11.0,\"flick_left_body\":24.0,\"flick_left_body_ct\":24.0,\"flick_left_ct\":-11.0,\"flick_right\":11.0,\"flick_right_body\":26.0,\"flick_right_body_ct\":26.0,\"flick_right_ct\":11.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":5.0,\"flick_speed_random_ct\":6.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":3.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-29.0,\"yaw_left_ct\":-29.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":35.0,\"yaw_right_ct\":35.0},\"Air Crouch\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-7.0,\"flick_left_body\":24.0,\"flick_left_body_ct\":24.0,\"flick_left_ct\":-7.0,\"flick_right\":15.0,\"flick_right_body\":26.0,\"flick_right_body_ct\":26.0,\"flick_right_ct\":15.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":3.0,\"flick_speed_random_ct\":3.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":-89.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":2.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-18.0,\"yaw_left_ct\":-18.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":44.0,\"yaw_right_ct\":44.0},\"Crouch\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-32.0,\"yaw_left_ct\":-32.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":46.0,\"yaw_right_ct\":46.0},\"Crouch Moving\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-3.0,\"flick_left_body\":25.0,\"flick_left_body_ct\":8.0,\"flick_left_ct\":-7.0,\"flick_right\":6.0,\"flick_right_body\":29.0,\"flick_right_body_ct\":8.0,\"flick_right_ct\":12.0,\"flick_speed\":7.0,\"flick_speed_ct\":7.0,\"flick_speed_random\":3.0,\"flick_speed_random_ct\":5.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-22.0,\"yaw_left_ct\":-22.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":44.0,\"yaw_right_ct\":44.0},\"Manual\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Static\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"Jitter\":\"Center\",\"jitter_ct\":\"Center\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":0.0,\"yaw_left_ct\":0.0,\"yaw_mode\":\"Static\",\"yaw_mode_ct\":\"Static\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":0.0,\"yaw_right_ct\":0.0},\"Running\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Random\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Random\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":-12.0,\"flick_left_body\":26.0,\"flick_left_body_ct\":26.0,\"flick_left_ct\":-12.0,\"flick_right\":8.0,\"flick_right_body\":20.0,\"flick_right_body_ct\":20.0,\"flick_right_ct\":8.0,\"flick_speed\":8.0,\"flick_speed_ct\":8.0,\"flick_speed_random\":5.0,\"flick_speed_random_ct\":5.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":true,\"limit_random_ct\":true,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":180.0,\"yaw_jitter_ovr_ct\":180.0,\"yaw_left\":-24.0,\"yaw_left_ct\":-24.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":37.0,\"yaw_right_ct\":37.0},\"Slowmotion\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":0.0,\"center_max_ct\":0.0,\"center_min\":0.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Auto\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":0.0,\"yaw_jitter_ovr_ct\":0.0,\"yaw_left\":-23.0,\"yaw_left_ct\":-23.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":47.0,\"yaw_right_ct\":47.0},\"Standing\":{\"anti_timeout\":0.0,\"anti_timeout_ct\":0.0,\"antibrute\":false,\"antibrute_ct\":false,\"antibrute_method\":1.0,\"antibrute_method_ct\":1.0,\"body_speed\":2.0,\"body_speed_ct\":2.0,\"body_yaw\":true,\"body_yaw_ct\":true,\"center_max\":-5.0,\"center_max_ct\":0.0,\"center_min\":5.0,\"center_min_ct\":0.0,\"center_options\":\"Randomize\",\"center_options_ct\":\"Randomize\",\"custom_amount\":1.0,\"custom_amount_ct\":1.0,\"custom_slider_1\":0.0,\"custom_slider_10\":0.0,\"custom_slider_10_ct\":0.0,\"custom_slider_11\":0.0,\"custom_slider_11_ct\":0.0,\"custom_slider_12\":0.0,\"custom_slider_12_ct\":0.0,\"custom_slider_13\":0.0,\"custom_slider_13_ct\":0.0,\"custom_slider_14\":0.0,\"custom_slider_14_ct\":0.0,\"custom_slider_15\":0.0,\"custom_slider_15_ct\":0.0,\"custom_slider_16\":0.0,\"custom_slider_16_ct\":0.0,\"custom_slider_17\":0.0,\"custom_slider_17_ct\":0.0,\"custom_slider_18\":0.0,\"custom_slider_18_ct\":0.0,\"custom_slider_19\":0.0,\"custom_slider_19_ct\":0.0,\"custom_slider_1_ct\":0.0,\"custom_slider_2\":0.0,\"custom_slider_20\":0.0,\"custom_slider_20_ct\":0.0,\"custom_slider_21\":0.0,\"custom_slider_21_ct\":0.0,\"custom_slider_22\":0.0,\"custom_slider_22_ct\":0.0,\"custom_slider_2_ct\":0.0,\"custom_slider_3\":0.0,\"custom_slider_3_ct\":0.0,\"custom_slider_4\":0.0,\"custom_slider_4_ct\":0.0,\"custom_slider_5\":0.0,\"custom_slider_5_ct\":0.0,\"custom_slider_6\":0.0,\"custom_slider_6_ct\":0.0,\"custom_slider_7\":0.0,\"custom_slider_7_ct\":0.0,\"custom_slider_8\":0.0,\"custom_slider_8_ct\":0.0,\"custom_slider_9\":0.0,\"custom_slider_9_ct\":0.0,\"def_activation\":\"Always\",\"def_static_offset\":0.0,\"defensive_pitch\":\"Auto\",\"defensive_tickbase\":0.0,\"defensive_yaw\":\"Spin\",\"extend_option\":\"none\",\"extend_option_ct\":\"none\",\"fake_left\":60.0,\"fake_left_ct\":60.0,\"fake_left_random\":0.0,\"fake_left_random_ct\":0.0,\"fake_options\":\"Jitter\",\"fake_options_ct\":\"Jitter\",\"fake_right\":60.0,\"fake_right_ct\":60.0,\"fake_right_random\":0.0,\"fake_right_random_ct\":0.0,\"flick_left\":0.0,\"flick_left_body\":0.0,\"flick_left_body_ct\":0.0,\"flick_left_ct\":0.0,\"flick_right\":0.0,\"flick_right_body\":0.0,\"flick_right_body_ct\":0.0,\"flick_right_ct\":0.0,\"flick_speed\":1.0,\"flick_speed_ct\":1.0,\"flick_speed_random\":1.0,\"flick_speed_random_ct\":1.0,\"Jitter\":\"Disabled\",\"jitter_ct\":\"Disabled\",\"jitter_randomize\":0.0,\"jitter_randomize_ct\":0.0,\"limit_random\":false,\"limit_random_ct\":false,\"pitch_offset\":0.0,\"ran_speed_1\":2.0,\"ran_speed_1_ct\":2.0,\"ran_speed_2\":2.0,\"ran_speed_2_ct\":2.0,\"random_speed\":false,\"random_speed_ct\":false,\"speed_options\":\"Neverlose\",\"speed_options_ct\":\"Neverlose\",\"spin_speed\":1.0,\"tick_random\":false,\"tick_speed1\":1.0,\"tick_speed2\":1.0,\"yaw_center\":0.0,\"yaw_center_ct\":0.0,\"yaw_jitter_ovr\":92.0,\"yaw_jitter_ovr_ct\":92.0,\"yaw_left\":-24.0,\"yaw_left_ct\":-24.0,\"yaw_mode\":\"L - R\",\"yaw_mode_ct\":\"L - R\",\"yaw_randomize\":0.0,\"yaw_randomize_ct\":0.0,\"yaw_right\":41.0,\"yaw_right_ct\":41.0}},\"fluccate_fakelag\":true,\"freestand_body\":2.0,\"freestand_enablers\":[\"~\"],\"freestand_options\":[\"~\"],\"freestanding_bind\":false,\"keep_fs\":true,\"Manual\":\"At Target\",\"move_lean_val\":100.0,\"prefer_manual\":true,\"safe_head\":[\"~\"],\"state_list\":\"Air Crouch\",\"team_list\":1.0},\"visuals\":{\"accent\":\"#DFC3FFFF\",\"crosshair_ind\":false,\"gs_inds\":false,\"molotov_radius\":true,\"notifs\":false,\"notifs_hit_clr\":\"#00FF00FF\",\"notifs_miss_clr\":\"#FF0000FF\",\"scope\":true,\"slowed_down\":true,\"smokes_radius\":true,\"watermark\":\"Left\",\"watermark_style\":1.0}}";
                        local v309 = renameKeys(v307);
                        l_pui_0.load(v309);
                        v12.push("config loaded : " .. v306);
                        return;
                    end;
                end;
            end;
        end;
        v7.delete_config = function()
            -- upvalues: v9 (ref), v12 (ref), v7 (ref)
            local v310 = v9.main.preset_list:get();
            if v310 <= 7 then
                v12.push("cannot delete predefined config");
                return;
            else
                local v311 = v7.get_config_name_from_index(v310);
                if not v311 then
                    v12.push("no config found with the selected index");
                    return;
                else
                    local v312 = db.configurations4 or {};
                    v312[v311] = nil;
                    db.configurations4 = v312;
                    v7.update_config_list();
                    v12.push("config deleted : " .. v311);
                    return;
                end;
            end;
        end;
    end;
    v124.start = function()
        -- upvalues: v32 (ref), v12 (ref), l_clipboard_0 (ref), l_core_0 (ref)
        local v313 = v32 == "BETA";
        network.get("https://api.github.com/repos/zxjapan/ls_config/contents/codes.txt", {
            ["Cache-Control"] = "no-cache", 
            Accept = "application/vnd.github.v3.raw", 
            ["User-Agent"] = "LuaSense", 
            Authorization = "token " .. "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"
        }, function(v314, _, _)
            -- upvalues: v12 (ref), v313 (ref), l_clipboard_0 (ref), l_core_0 (ref)
            if not v314 then
                v12.push("Failed to fetch verification codes");
                return;
            else
                local v317 = {};
                for v318 in v314:gmatch("[^\r\n]+") do
                    table.insert(v317, v318);
                end;
                local v319 = v313 and ":beta" or ":live";
                local v320 = nil;
                for _, v322 in ipairs(v317) do
                    if v322:sub(-#v319) == v319 then
                        v320 = v322;
                        break;
                    end;
                end;
                if not v320 then
                    v12.push(string.format("No %s verification codes available", v313 and "beta" or "live"));
                    return;
                else
                    l_clipboard_0.set(v320);
                    v12.push(string.format("Your verification code: %s", v320));
                    v12.push("Code is in your Console!");
                    l_core_0:branded_printing(string.format("Your verification code: %s", v320));
                    l_core_0:branded_printing("Please enter this code in our Discord bot");
                    return;
                end;
            end;
        end);
    end;
    v124.check = function()
        -- upvalues: v124 (ref)
        v124.start();
    end;
    v294 = nil;
    local v323 = ffi.cast("uintptr_t**", utils.opcode_scan("engine.dll", "A1 ? ? ? ? 0F 28 C1 F3 0F 5C 80 ? ? ? ? F3 0F 11 45 ? A1 ? ? ? ? 56 85 C0 75 04 33 F6 EB 26 80 78 14 00 74 F6 8B 4D 08 33 D2 E8 ? ? ? ? 8B F0 85 F6", 1));
    local v324 = ffi.typeof("        struct {\n            int64_t         unknown;\n            int64_t         steamID64;\n            char            szName[128];\n            int             userId;\n            char            szSteamID[20];\n            char            pad_0x00A8[0x10];\n            unsigned long   iSteamID;\n            char            szFriendsName[128];\n            bool            fakeplayer;\n            bool            ishltv;\n            unsigned int    customfiles[4];\n            unsigned char   filesdownloaded;\n        }\n    ");
    local v325 = utils.get_vfunc(11, ffi.typeof("$*(__thiscall*)(void*, int, int*)", v324));
    local v326 = nil;
    do
        local l_v323_0, l_v325_0, l_v326_0 = v323, v325, v326;
        local function v336(v330)
            -- upvalues: l_v323_0 (ref), l_v325_0 (ref), l_v326_0 (ref)
            local v331 = entity.get_local_player();
            if not v331 then
                return;
            else
                local v332 = l_v323_0[0][0];
                if not v332 then
                    return;
                else
                    local v333 = ffi.cast("void***", v332 + 21184)[0];
                    if not v333 then
                        return;
                    else
                        local v334 = l_v325_0(v333, v331:get_index() - 1, nil);
                        if not v334 then
                            return;
                        else
                            local v335 = ffi.string(v334[0].szName);
                            if v330 ~= v335 and l_v326_0 == nil then
                                l_v326_0 = v335;
                            end;
                            ffi.copy(v334[0].szName, v330, #v330 + 1);
                            return;
                        end;
                    end;
                end;
            end;
        end;
        local v337 = false;
        local function v339()
            -- upvalues: v9 (ref), v337 (ref), v336 (ref), l_v326_0 (ref)
            local v338 = v9.misc.client_nickname.client_nickname_text:get():sub(0, 32);
            v9.misc.client_nickname.client_nickname_text:set(v338);
            if not v9.misc.client_nickname:get() or #v338 == 0 then
                if v337 then
                    v337 = false;
                    v336(l_v326_0 or panorama.MyPersonaAPI.GetName());
                    l_v326_0 = nil;
                end;
                return;
            else
                v337 = true;
                v336(v338);
                return;
            end;
        end;
        events.net_update_start(v339);
        events.net_update_end(v339);
        v339();
    end;
    l_core_0.super_toss = {
        damp = 0.3
    };
    l_core_0.resolve_grenade_throw = function(v340, v341, v342, v343)
        -- upvalues: v19 (ref), l_core_0 (ref)
        v340.x = v340.x - 10 + math.abs(v340.x) / 9;
        local v344 = vector():angles(v340);
        local v345 = v343 * 1.25;
        local v346 = math.clamp(v341 * 0.9, 15, 750);
        local v347 = math.clamp(v342, 0, 1);
        v346 = v346 * v19.math.lerp(l_core_0.super_toss.damp, 1, v347);
        local l_v344_0 = v344;
        for _ = 1, 8 do
            l_v344_0 = (v344 * (l_v344_0 * v346 + v345):length() - v345) / v346;
            l_v344_0:normalize();
        end;
        local v350 = l_v344_0.angles(l_v344_0);
        if v350.x > -10 then
            v350.x = 0.9 * v350.x + 9;
        else
            v350.x = 1.125 * v350.x + 11.25;
        end;
        return v350;
    end;
    l_core_0.on_grenade_override_view = function(v351)
        -- upvalues: v9 (ref), l_core_0 (ref)
        local v352 = entity.get_local_player();
        if v352 == nil or not v352:is_alive() then
            return;
        elseif not v9.misc.super_toss:get() then
            return;
        else
            local v353 = v352:get_player_weapon();
            if v353 == nil then
                return;
            else
                local v354 = v353:get_weapon_info();
                if v354 == nil then
                    return;
                elseif v354.weapon_type ~= 9 then
                    return;
                else
                    v351.angles = l_core_0.resolve_grenade_throw(v351.angles, v354.throw_velocity, v353.m_flThrowStrength, v351.velocity);
                    return;
                end;
            end;
        end;
    end;
    v323 = vector();
    v324 = vector();
    l_core_0.handle_supertoss = function(v355)
        -- upvalues: v9 (ref), l_core_0 (ref)
        if v355.jitter_move ~= true then
            return;
        elseif not v9.misc.super_toss:get() then
            return;
        else
            local v356 = entity.get_local_player();
            if v356 == nil then
                return;
            elseif v356:get_player_weapon() == nil then
                return;
            else
                local v357 = v356:get_player_weapon();
                local v358 = v357:get_weapon_info();
                local _ = v357:get_name();
                if v358 == nil or v358.weapon_type ~= 9 then
                    return;
                elseif v357.m_fThrowTime < globals.curtime - to_time(globals.clock_offset) then
                    return;
                else
                    v355.in_speed = true;
                    local v360 = v356:simulate_movement();
                    v360:think();
                    v355.view_angles = l_core_0.resolve_grenade_throw(v355.view_angles, v358.throw_velocity, v357.m_flThrowStrength, v360.velocity);
                    return;
                end;
            end;
        end;
    end;
    events.createmove(l_core_0.handle_supertoss);
    events.grenade_override_view(l_core_0.on_grenade_override_view);
    v325 = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck");
    v326 = l_smoothy_0.new(46);
    l_core_0.freezetime = false;
    l_core_0.fake_duck = function(v361)
        -- upvalues: v9 (ref), l_core_0 (ref), v325 (ref)
        local v362 = entity.get_local_player();
        if not v9.misc.freeze_fakeduck:get() then
            return;
        elseif not l_core_0.freezetime then
            return;
        elseif v362 == nil or not v362:is_alive() then
            return;
        elseif not v325:get() then
            return;
        else
            local _ = v362.m_flDuckAmount;
            v361.in_bullrush = true;
            if v361.choked_commands < 7 then
                v361.in_duck = false;
            else
                v361.in_duck = true;
            end;
            v361.send_packet = not v361.choked_commands == 14;
            return;
        end;
    end;
    l_core_0.on_override_view = function(v364)
        -- upvalues: v9 (ref), l_core_0 (ref), v325 (ref), v326 (ref)
        local v365 = entity.get_local_player();
        if not v9.misc.freeze_fakeduck:get() then
            return;
        elseif not l_core_0.freezetime then
            return;
        elseif v365 == nil or not v365:is_alive() then
            return;
        elseif not v325:get() then
            return;
        else
            local _ = v365.m_flDuckAmount;
            local v367 = v365.m_vecAbsOrigin.z + v365.m_vecViewOffset.z;
            local v368 = v326(0.1, v365.m_vecAbsOrigin.z + v365.m_vecViewOffset.z);
            if bit.band(v365.m_fFlags, 1) == 1 and math.abs(v368 - v367) < 20 then
                v364.camera.z = v368;
            end;
            return;
        end;
    end;
    events.createmove(l_core_0.fake_duck);
    events.override_view(l_core_0.on_override_view);
    l_core_0.clantag = {
        step = 1, 
        speed = 2, 
        ref = ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag"), 
        list = {
            [1] = "", 
            [2] = "l", 
            [3] = "lu", 
            [4] = "lua", 
            [5] = "luas", 
            [6] = "luase", 
            [7] = "luasen", 
            [8] = "luasens", 
            [9] = "luasense", 
            [10] = "luasense", 
            [11] = "luasens", 
            [12] = "luasen", 
            [13] = "luase", 
            [14] = "luas", 
            [15] = "lua", 
            [16] = "lu", 
            [17] = "l", 
            [18] = ""
        }, 
        run = function(v369)
            -- upvalues: v9 (ref)
            local function v371()
                -- upvalues: v369 (ref)
                local v370 = math.floor(globals.curtime * v369.speed + 0.5) % #v369.list + 1;
                if v370 == v369.step then
                    return;
                else
                    v369.step = v370;
                    v369.ref:override(false);
                    common.set_clan_tag(v369.list[v370]);
                    return;
                end;
            end;
            v9.misc.clantag:set_callback(function(v372)
                -- upvalues: v371 (ref)
                if v372:get() then
                    events.net_update_end:set(v371);
                else
                    events.net_update_end:unset(v371);
                    common.set_clan_tag("");
                end;
            end, true);
            events.shutdown:set(function()
                -- upvalues: v369 (ref)
                common.set_clan_tag("");
                v369.ref:override();
            end);
        end
    };
    local v373 = false;
    no_fall_damage = false;
    local v374 = math.pi * 2;
    local v375 = v374 / 8;
    local function v386(v376, v377)
        -- upvalues: v374 (ref), v375 (ref)
        local v378 = v376:get_origin();
        for v379 = 0, v374, v375 do
            local v380 = math.sin(v379);
            local v381 = math.cos(v379);
            local v382 = v378.x + v381 * 10;
            local v383 = v378.y + v380 * 10;
            local v384 = vector(v382, v383, v378.z);
            local v385 = v384:clone();
            v385.z = v385.z - v377;
            if utils.trace_line(v384, v385, v376).fraction ~= 1 then
                return true;
            end;
        end;
        return false;
    end;
    events.createmove_run:set(function()
        -- upvalues: v9 (ref), v373 (ref), v386 (ref)
        self = entity.get_local_player();
        if self == nil then
            return;
        elseif not v9.misc.no_fall:get() then
            return;
        elseif self.m_vecVelocity.z >= -500 then
            v373 = false;
            return;
        else
            if v386(self, 15) then
                v373 = false;
            elseif v386(self, 75) then
                v373 = true;
            end;
            self.in_duck = v373;
            return;
        end;
    end);
    v11.register("createmove", "unlock_spike", function()
        -- upvalues: v9 (ref), l_core_0 (ref)
        local l_sv_maxunlag_0 = cvar.sv_maxunlag;
        if v9.misc.fake_latency_toggle:get() then
            l_core_0.refs.fake_latency:override(v9.misc.fake_latency_toggle.fake_latency_slider:get());
            l_sv_maxunlag_0:float(0.4, true);
        else
            l_core_0.refs.fake_latency:override();
            l_sv_maxunlag_0:float(tonumber(l_sv_maxunlag_0:string()), true);
        end;
    end);
    v16.rotation = 0;
    v16.shadow_anim = 0;
    v16.handle = function()
        -- upvalues: v9 (ref), l_core_0 (ref), l_manager_0 (ref), v16 (ref)
        local v388 = v9.visuals.scope:get();
        if not v388 then
            return;
        else
            local v389 = entity.get_local_player();
            if v389 == nil then
                return;
            else
                local v390 = v389:get_player_weapon();
                if not v390 then
                    return;
                elseif v390 == nil then
                    return;
                else
                    l_core_0.refs.scope_type:override("Remove All");
                    local v391 = v9.visuals.scope.scope_settings:get(3);
                    local l_m_bIsScoped_0 = v389.m_bIsScoped;
                    local v393 = v388 and l_m_bIsScoped_0 and 1 or 0;
                    local v394 = v391 and l_manager_0:new("scope_overlay", v393) or v393;
                    if v394 < 0.1 then
                        return;
                    else
                        local v395 = v9.visuals.scope.scope_style:get();
                        local v396 = v9.visuals.scope.scope_settings:get(1);
                        local v397 = v9.visuals.scope.scope_size:get();
                        local v398 = v9.visuals.scope.scope_gap:get();
                        local v399 = v9.visuals.scope.scope_color1:get();
                        local v400 = v9.visuals.scope.scope_color2:get();
                        local v401 = v9.visuals.scope.scope_settings:get(2);
                        local v402 = v396 and l_manager_0:new("spread_dependensy", v390:get_inaccuracy() * 75) + v398 or v398;
                        local v403 = {
                            v399:override("a", v399.a * v394), 
                            v400:override("a", v400.a * v394)
                        };
                        v397 = v397 * v394;
                        local v404 = l_core_0.screen_size / 2;
                        v16.rotation = l_manager_0:new("scop_ratator", v395 == 3 and 45 or 90);
                        v16.shadow_anim = l_manager_0:new("scope_shadow_anim", v401 and 15 or 1);
                        if v16.rotation ~= 90 then
                            render.push_rotation(v16.rotation, l_core_0.screen_size / 2);
                        end;
                        if v16.shadow_anim ~= 1 then
                            render.shadow(v404 - vector(v397 + v402, -1), v404 - vector(v402, 0), v403[1], v16.shadow_anim);
                            render.shadow(v404 + vector(v402, 1), v404 + vector(v397 + v402, 0), v403[1], v16.shadow_anim);
                            render.shadow(v404 + vector(0, v402), v404 + vector(-1, v397 + v402), v403[1], v16.shadow_anim);
                        end;
                        render.gradient(v404 - vector(v397 + v402, -1), v404 - vector(v402, 0), v403[2], v403[1], v403[2], v403[1]);
                        render.gradient(v404 + vector(v397 + v402, 1), v404 + vector(v402, 0), v403[2], v403[1], v403[2], v403[1]);
                        if v395 ~= 2 then
                            if v16.shadow_anim ~= 1 then
                                render.shadow(v404 - vector(-1, v397 + v402), v404 - vector(0, v402), v403[1], v16.shadow_anim);
                            end;
                            render.gradient(v404 - vector(-1, v397 + v402), v404 - vector(0, v402), v403[2], v403[2], v403[1], v403[1]);
                        end;
                        render.gradient(v404 + vector(1, v397 + v402), v404 + vector(0, v402), v403[2], v403[2], v403[1], v403[1]);
                        if v16.rotation ~= 90 then
                            render.pop_rotation();
                        end;
                        return;
                    end;
                end;
            end;
        end;
    end;
    v11.register("render", "scope_overlay", v16.handle);
    v9.misc.viewmodel_changer_fov = v9.misc.view_model_changer:create():slider("Field Of View", 0, 100, 68);
    v9.misc.viewmodel_changer_x = v9.misc.view_model_changer:create():slider("X Axis", -3000, 3000, 205, 0.01);
    v9.misc.viewmodel_changer_y = v9.misc.view_model_changer:create():slider("Y Axis", -3000, 3000, 100, 0.01);
    v9.misc.viewmodel_changer_z = v9.misc.view_model_changer:create():slider("Z Axis", -3000, 3000, -100, 0.01);
    v13.cvars = {
        viewmodel_fov = cvar.viewmodel_fov, 
        viewmodel_offset_x = cvar.viewmodel_offset_x, 
        viewmodel_offset_y = cvar.viewmodel_offset_y, 
        viewmodel_offset_z = cvar.viewmodel_offset_z
    };
    v13.handle = function()
        -- upvalues: v9 (ref), v13 (ref)
        if v9.misc.view_model_changer:get() then
            v13.cvars.viewmodel_fov:float(v9.misc.viewmodel_changer_fov:get(), true);
            v13.cvars.viewmodel_offset_x:float(v9.misc.viewmodel_changer_x:get() / 100, true);
            v13.cvars.viewmodel_offset_y:float(v9.misc.viewmodel_changer_y:get() / 100, true);
            v13.cvars.viewmodel_offset_z:float(v9.misc.viewmodel_changer_z:get() / 100, true);
        else
            v13.cvars.viewmodel_fov:float(68);
            v13.cvars.viewmodel_offset_x:float(2.5);
            v13.cvars.viewmodel_offset_y:float(0);
            v13.cvars.viewmodel_offset_z:float(-1.5);
        end;
    end;
    v13.destroy = function()
        -- upvalues: v13 (ref)
        v13.cvars.viewmodel_fov:float(68);
        v13.cvars.viewmodel_offset_x:float(2.5);
        v13.cvars.viewmodel_offset_y:float(0);
        v13.cvars.viewmodel_offset_z:float(-1.5);
    end;
    v11.register("render", "viewmodel", v13.handle);
    v11.register("shutdown", "viewmodel", v13.destroy);
    v9.misc.aspect_ratio_val = v9.misc.aspect_ratio:create():slider("Aspect Value", 50, 300, 0, 0.01);
    local v405 = {
        cvar = cvar.r_aspectratio
    };
    v405.cvar_float_raw = v405.cvar.float;
    l_core_0.handle_aspect = function(_)
        -- upvalues: l_manager_0 (ref), v9 (ref), v405 (ref)
        local v407 = l_manager_0:new("aspect_ratio", v9.misc.aspect_ratio_val:get() / 100, 0.1);
        if v9.misc.aspect_ratio_val:get() == 50 then
            v407 = 0;
        end;
        if not v9.misc.aspect_ratio:get() then
            v407 = 0;
        end;
        if v407 ~= v405.cvar_float_raw(v405.cvar) then
            v405.cvar_float_raw(v405.cvar, v407);
        end;
    end;
    aspect_ratio_destroy = function()
        -- upvalues: v405 (ref)
        aspect_ratio.cvar_float_raw(v405.cvar, 0);
    end;
    aspect_ratio_ratios = {
        [161] = "16:10", 
        [177] = "16:9", 
        [125] = "5:4", 
        [150] = "3:2", 
        [133] = "4:3"
    };
    local v408 = 0;
    for v409, v410 in pairs(aspect_ratio_ratios) do
        v408 = v408 + 1;
        do
            local l_v409_0 = v409;
            local _ = v9.misc.aspect_ratio:create():button(v410, function()
                -- upvalues: v9 (ref), l_v409_0 (ref)
                v9.misc.aspect_ratio_val:set(l_v409_0);
            end);
        end;
    end;
    v10.animlayer_offset = 10640;
    v10.animlayer_t = ffi.typeof("    struct {\n        char pad_0x0000[0x18];\n        uint32_t seq;\n        float prev_cycle;\n        float weight;\n        float weight_delta_rate;\n        float playback_rate;\n        float cycle;\n        void *entity;\n        char pad_0x0038[0x4];\n    }**\n");
    v10.get_anim_layer = function(v413)
        -- upvalues: v10 (ref)
        local v414 = ffi.cast("void***", v413[0]);
        if v414 == ffi.NULL then
            return nil;
        else
            return ffi.cast(v10.animlayer_t, ffi.cast("char*", v414) + v10.animlayer_offset)[0];
        end;
    end;
    v10.handle = function(v415)
        -- upvalues: v9 (ref), v10 (ref)
        if not v9.rage.anims:get() then
            return;
        else
            local v416 = entity.get_local_player();
            if not v416 or v415 ~= v416 then
                return;
            else
                local v417 = v9.rage.anims.move_lean_val:get() * 0.1;
                if v417 ~= -1 then
                    local v418 = v10.get_anim_layer(v416);
                    if v418 then
                        v418[12].weight = v417;
                    end;
                end;
                local v419 = v9.rage.anims.move_fall:get() * 0.1;
                if v419 ~= -1 then
                    v416.m_flPoseParameter[6] = v419;
                end;
                return;
            end;
        end;
    end;
    v10.handle_pre_render = function()
        -- upvalues: v9 (ref)
        if not v9.rage.anims:get() then
            return;
        else
            local v420 = entity.get_local_player();
            if not v420 then
                return;
            else
                local v421 = v9.rage.anims.move_jitter_mode:get();
                local v422 = v9.rage.anims.move_jitter:get();
                local _ = globals.tickcount;
                if v421 == 1 then
                    if v422 > 1 then
                        v420.m_flPoseParameter[0] = globals.tickcount % 4 >= 2 and 86 or 50 / (globals.tickcount % 8 >= 4 and 200 or 400);
                    end;
                else
                    local v424 = globals.tickcount % 8;
                    local v425 = globals.tickcount % 4;
                    local v426 = 1 / (v424 >= 4 and 200 or 400);
                    local v427 = v425 >= 2 and v9.rage.anims.move_legs1:get() or v9.rage.anims.move_legs2:get();
                    v420.m_flPoseParameter[0] = v427 * v426;
                end;
                return;
            end;
        end;
    end;
    v10.handle_legs = function(_)
        -- upvalues: v9 (ref), l_core_0 (ref)
        if not v9.rage.anims:get() then
            l_core_0.refs.legs:override();
            return;
        else
            local v429 = v9.rage.anims.move_jitter_mode:get();
            local v430 = v9.rage.anims.move_jitter:get();
            local l_commandack_0 = globals.commandack;
            if v430 > 5 and v429 == 1 then
                l_core_0.refs.legs:override(l_commandack_0 % 3 == 0 and "Default" or "Sliding");
            elseif v9.rage.anims.move_legs1:get() > 1 or v9.rage.anims.move_legs2:get() > 1 then
                l_core_0.refs.legs:override("Sliding");
            else
                l_core_0.refs.legs:override();
            end;
            return;
        end;
    end;
    v11.register("post_update_clientside_animation", "animbreaker.handle", v10.handle);
    v11.register("createmove", "animbreaker.handle_legs", v10.handle_legs);
    v11.register("post_update_clientside_animation", "animbreaker.handle_pre_render", v10.handle_pre_render);
    gs_settings = v9.visuals.gs_inds:create();
    local v432 = {};
    local v433 = {};
    local v434 = render.screen_size();
    local v435 = {
        on_plant_time = 0, 
        planting = false, 
        planting_site = "", 
        fill = 0
    };
    local v436 = {
        ping = ui.find("Miscellaneous", "Main", "Other", "Fake Latency"), 
        da = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"), 
        dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"), 
        body = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"), 
        safe = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"), 
        hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"), 
        fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"), 
        fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding")
    };
    local v437 = gs_settings:listable("", {
        [1] = "Double Tap", 
        [2] = "Hide Shots", 
        [3] = "Damage", 
        [4] = "Hitchance", 
        [5] = "Fake Duck", 
        [6] = "Body Aim", 
        [7] = "Safe Points", 
        [8] = "Dormant Aimbot", 
        [9] = "Freestanding", 
        [10] = "PING", 
        [11] = "Bomb Info"
    });
    local v438 = gs_settings:switch("Enable Spectator List", false);
    v432.font = render.load_font("Calibri Bold", vector(25, 23.5, 0), "da");
    local v439 = render.load_image("\137PNG\r\n\026\n\000\000\000\rIHDR\000\000\000d\000\000\000\\\b\003\000\000\000\175\021\224\166\000\000\000\001sRGB\001\217\201,\127\000\000\000\tpHYs\000\000\v\019\000\000\v\019\001\000\154\156\024\000\000\002\223PLTE\000\000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255v\153it\000\000\000\245tRNS\000\001C\147X\006Z\251\255\253\150\004\213\249\002\014\227\024\022\234+\027\2396)sr\030\242?uk \235\2442!\246G/\231\2267^\183\015#\248Q\b\179\154}\247c\000pz\193%n-\224b\252\194(v\174\136\v\201]~\250\233'\\\223\0181\132\216\140\207\151:\138\003\172\218\028l.B\143{\161K\149\016\202\019U=\0263\nNi\130\187A\199\128\135\145\158\166\170\134\127_&\220\254I\232\023\195F\137\146\186,\192\184\163\159\168\175\177\181\188\212|\243\157$\r\142[\005\217\209\153\241\204\203\155O\020\206\197\205\0250\245\a\222\021\164\029\017\229\131*\160q\214\208\198\185\169mR5\221\f\228d\237\191\196\141w\133\139\144\238\230\165x\236\t`\031\129\171\156\1528aJ\1784L\219\167\210E9S\176\240\189\148M\180DT>\162\"Yj\225\215\173@H;\190et4r\001\212\000\000\anIDATx\156\237\154\249[\212F\024\199\179\"2+\139\138X\208B\229\016T(B\017p\017\017\016\149\"(V,\136\020\005\228\180\028\197 `E\188Q\001\161\136\136\162\162xq\021\021\v\136x\v\021T\020\207\nx\182\181\213Z\219\218\235\015hf&\187\155\132\221%\134\165\207\211>\190\191d\231\155\247}?9f\146w&K\016\002L4@k\160\182\144\1927\177A:@<\184\159\025\186\018\000\128\222\144\254\133\f\029FA\128~\255B\134\027@\200\136\254\133\188c\b!F\154K8r\212\187=\014\217\216\004B\222\227\168\162\145\163M\205\0041\244\205\001\176\024\195\017-\173 d,G\0297\030\000k\027!\144\247a:\219\tl\209\206\030\170\031\176E\135\137Pt\020\002\177\019\195P'\142\232\f\197I,M\234\162\003\197\201B \132+\f\021\179o\203\020=(\186\177\180\169\227\161\230n&\b\226\225\t\131\167905/\164MgJ\1863\160\004f\nb\016\222\031\162h\031\1666\002I\179\024\138\212\195\023J~\179\133A\1369(\163\255\\\134\244\017\146\2301\020\203\000$\205\023\252\168\249\024\197\a2\226\131\144\178@!\004/DJ\200'B\025D(\186\003\022\139\020\202b\1482L!\140E\002\b\023\204\144\221\149\b\133\178\004\t\145\242v\020\246\136\142\017\014!\198\196B\139S\bK\145\240\169\188\029\159\144\232\150\228\248Yr\031\024o\237\127cR\227P\219e\131D\178f\130\169\155\019I\146)\203#\177\005\166\166\165\243\180\136@\024\160\181\226s\151\149\025l\134\254tw\170W\219{\225\150\003i\0154a\171\024}|\200\148\249\1712\145\186\026\vnb\1410\168'\181\183\140a\182`\r\173\025\172\197\202:\r1\128\243z\156\208{\131\191L\178ZBc\253\213\005\190\145\133\162|\027\205\229B\214&\217\185\025\240\203\016\176yKv\142\194\"\178\211r\211\023n\205\155\152\191%\235\139\002\236\178\r\229\147Gx\146Q\242\155T\200\aa\161\246m\020\139\157R\152\016\207\237E\f\015^}\203z\a\015H1\003\226\183s\023\211\131W\231*\217\1654;\027\162%\135\024jq\ne>\f \017)\201\205\133\004\162\006\245\138\2032\210\229x\240\130\236V\199\144A\246\160\198\222\210\213\\\004O\200>>\144\253\168Qv@\137\a/\200A>\144\237\170=xA\014\241\129\164\246\017\018\r=c\226\014\031\017\137\202+f\014%*\195K\141\2275\r)\128\158\185\133:U\213\195\253\128\213rbR\166x\141bBACr\250\b\145H)\207/\0010\1699z\f\150u\199\169\159\181\\\200\137\190B\2248\177\252*+\214Adc\016\184\150\152\189\160\196g\130\166!uj\139\\\rA\002\130\255\005H\136\218E\014\026\130\v\217\241\195\170J\n\234\2475\184\158\156\145\222\184g\222\169\166\211KE\252 g\028x@\178U\028\180\161\027?\136\251Y\030\1444UWf\149J\1369\170y\246\226\198\185(\030\144tU\016\019U\144\204\243(D\130[\023\212.\164\244\006\137V\005\1858\129\t\017_\202kn\025\205\176\150\201\219f\145I_\167l\184\220\220\186\209\150\003\017[\180]q/\145H\014\187\230_m\189f\218\020\163\002\210nD\\/R@xY#\130\028\245V\210\221\149\a\180JE\2257\004A\148\154\204\197j\243\172\184\142\202\168Q\168QeF\148_\024\203\128\024\238'o\230\154P\221\172\153$\179\157\169n\1775)\233\150\0145J\195H\242\182/_H\189\017~\141\215\192\134\175\135\148\184\003\2382 \247\224>\018\1282\184\r\003zA\212F\186\005\180u\192\246I\236\147\219\027\164t(nI\191\129\173\251\193Dg;X\196\128\160\197\173.\000:\241\214\031\213\189\129\160\027=\t\"\177\207\131^ z\176\160\220q\249\161D\210N\181*:\b\221\019xiN\006\129gE<\002\000M>\031\211\213\203m\176\170\018n\181\248A\242\168\031\218\247\233\132\153\205T\030g6\228\017tm\002\224\t\220.\161\235\176[t\209\151\141}\210z\129\192K~O\214\005\252k\b\"\021\176!\167j)s\002 \220L\191\186\166\017T\148\r\175^Zt\b\152\aA\157\158\024\\\237\005r\154\186\027\r2\200dj\134\225*\145H\236\168\189y\018\019\021\029\182\167\225\a\228\001eo\005\180\127\0285;\170\163}\205\217\207\169\193\188!\248Q\223\176\220X\005\004\206_\002i\223\167\236\2537\145\168S%\t\248\150\218zvKJ,\160` \169k\1636\206%\146\238\n:\016\215]V\160\221\173Gy\142\246\195\005\178\140v\236\219\016K\027\236\213F\177\223!\1779FZi3\r\000\199\179\196\245\228n\000\190\175\021\233\006\237\005\190\231\227\137\029\207\218p ^\127\132\135\240\195]e\144h\216%\203\031Z\177N\031\222\248\131\244o8\248\136\213\000\160:(\020\248\161Zt\006\176F\195+\021\251\224\021\029<\169\n\235\232\t\017\255\b\127\206\029\240<6\150\005\145\202z\215c\184?\025\128\169p\251\002\004\160\154z?=N\232\219\134\215\166\134\225FHS0\023\002\206X\210M\017\251Ld\144\197p_\023=^d\1311\130\030\249?a\159\021(A\183,<\253\165\148\003\001u\003\241\027\214L9\164\v\238\243\001\224g\184}\005\174\160\213\194<p\f\245Dz\020\135\163\004\151\229\243\195\170\004.\004\000\251\137\197$\025\246\vPj\005\023)+\001\224\215\173\2179\233\212\173\v\137\200y\144o\b|/A\221\016\251\188\194\t-\159\202\186\027(\158\203\133\244\213<\159\208\025w%\148f\210Z>=\r\180\214\020d\141\151\252\234T'\214\209SQzy\239t\183\250X\222\214\200,e\143\\\195\a/\251@0\213\189O\185\197\021\021\021\133\006~U\191\217\177F\006a\214\178\207\1760W>k\030\017\219\023kJ~\253\250\197\166\145Jf\138\218\157q\241=\213\183\246_1o\023\146$\157|\024\139\253/Ih\191+\132?\160\v9]mU\174\222\018\209w$\2413\133\242\002\245\221\249\n\2259\238\205\166\194!\165(\193no\133b\131\148\020\133\160\189\f)\209jg1\234l\016\138\247e~\186,GR\018C\233D\175*O7n0O\187\142\015\210\145\185\022\213\243s\211\144\227H\170W\182x\195\195n\160;r\193\146\169y\161\167_\vS\138\169G\020\015a\144?Q\240$)S\203@e\188\v\203\2399\002\175\019\244W\128\181\232Dl\217k\005Eh\2212\145\165iG@\205\190K\bd%\f=W\203\022\241\183_\206\165\233@\175\140@!\1442\0249\135#v\160\242n'G\253\139\186`:\161B \186\145V\134N\220\133\149\0264\241\230|`&\028\254\014(\189\167\185\191g\028A%\227z\141\229Sj\213~\016\162\193\127\022(3\252G\f\203\222\029\251b\186p\150\225\171v\209[\003VLA\166\2453\131\136iM\191\147\209\187\155\220\254\001Q\1440+D^\186l\000\000\000\000IEND\174B`\130", vector(30, 25));
    local function v447(v440, v441, v442, v443, v444, v445, v446)
        return (v443 - v440) * v446 + v440, (v444 - v441) * v446 + v441, (v445 - v442) * v446 + v442;
    end;
    local function v454(v448)
        local _ = 0;
        local _ = 0;
        local v451 = 0;
        local v452 = 0;
        local v453 = {
            [1] = utils.net_channel(), 
            [2] = utils.net_channel()
        };
        if v448 ~= nil and v448:is_alive() then
            v453[1] = utils.net_channel();
            v453[2] = v453[1];
            if v453[1] then
                v451 = v453[1].sequence_nr[0];
                v452 = (v453[2].sequence_nr[1] + v451) / math.min(math.max(0.1, 0.001), 0.2);
                return math.clamp(-1.7014636E38, math.min(math.max(v452, 0), 1), v452);
            end;
        end;
    end;
    v432.indicator = function(v455, v456, v457, v458, v459, v460)
        -- upvalues: v432 (ref)
        local v461 = render.screen_size().x / 100 + 2;
        local v462 = render.screen_size().y / 1.47;
        local v463 = render.measure_text(v432.font, bad, v455);
        v456 = v456 + 1;
        if v460 then
            render.gradient(vector(v461 - 17, v462 + v456), vector(v461 + (v463.x + v460.width + 8) / 2, v462 + v456 + v463.y + 8), color(0, 0, 0, 0), color(0, 0, 0, 55), color(0, 0, 0, 0), color(0, 0, 0, 55));
            render.gradient(vector(v461 + (v463.x + v460.width + 6) / 2, v462 + v456), vector(v461 + v463.x + v460.width + 17 + 8, v462 + v456 + v463.y + 8), color(0, 0, 0, 55), color(0, 0, 0, 0), color(0, 0, 0, 55), color(0, 0, 0, 0));
            render.texture(v460, vector(v461 + 1, v462 + v456 + 3), color(0, 0, 0, 200));
            render.texture(v460, vector(v461, v462 + v456 + 2), v457);
            render.text(v432.font, vector(v461 + v460.width + 8, v462 + 5 + v456), v457, "bad", v455);
        else
            render.gradient(vector(v461 - 17, v462 + v456), vector(v461 + v463.x / 2, v462 + v456 + v463.y + 8), color(0, 0, 0, 0), color(0, 0, 0, 55), color(0, 0, 0, 0), color(0, 0, 0, 55));
            render.gradient(vector(v461 + v463.x / 2, v462 + v456), vector(v461 + v463.x + 17, v462 + v456 + v463.y + 8), color(0, 0, 0, 55), color(0, 0, 0, 0), color(0, 0, 0, 55), color(0, 0, 0, 0));
            render.text(v432.font, vector(v461, v462 + 5 + v456), v457, "bad", v455);
        end;
        if v458 and v459 then
            if v460 then
                local v464 = v462 + v456 + v463.y * 0.6;
                render.circle_outline(vector(v461 + v463.x + v460.width + 18, v464), color(0, 0, 0, 255), 9.5, 90, 1, 4);
                render.circle_outline(vector(v461 + v463.x + v460.width + 18, v464), v458, 9, 90, v459, 3);
            else
                render.circle_outline(vector(v461 + v463.x + 18, v462 + v456 + v463.y / 2 + 2), color(0, 0, 0, 255), 10.5, 90, 1, 4);
                render.circle_outline(vector(v461 + v463.x + 18, v462 + v456 + v463.y / 2 + 2), v458, 10, 90, v459, 3);
            end;
        end;
    end;
    v432.get_bind_state = function(v465)
        local v466 = false;
        local v467 = 0;
        local v468 = ui.get_binds();
        for v469 = 1, #v468 do
            if v468[v469].name == v465 and v468[v469].active then
                v466 = true;
                v467 = v468[v469].value;
            end;
        end;
        return {
            [1] = v466, 
            [2] = v467
        };
    end;
   v432.spectators_get = function()
    local v470 = {};
    local v471 = entity.get_local_player();
    local v472_handle = nil; 
    if v471 ~= nil and is_valid_entity(v471) then
        local success, local_obs_handle = pcall(function() return v471:get_prop("m_hObserverTarget") end)
        if success and local_obs_handle and local_obs_handle > 0 then
            v472_handle = local_obs_handle;
        else
            local success_idx, idx = pcall(function() return v471:get_index() end)
            if success_idx then
                v472_handle = idx;
            else
                return v470;
            end;
        end;

        local v473 = entity.get_players(false, false);
        if v473 ~= nil then
            for _, v475 in pairs(v473) do
                if is_valid_entity(v475) then
                    local success_obs, enemy_obs_handle = pcall(function() return v475:get_prop("m_hObserverTarget") end)
                    if success_obs and enemy_obs_handle and enemy_obs_handle == v472_handle then
                        table.insert(v470, v475);
                    end;
                end;
            end;
        end;
    end;
    return v470;
end;
    v432.handle = function()
        -- upvalues: v9 (ref), v434 (ref), v435 (ref), v436 (ref), v447 (ref), v454 (ref), v437 (ref), v439 (ref), v432 (ref)
        if not v9.visuals.gs_inds:get() then
            return;
        else
            local v477 = entity.get_local_player();
            if v477 == nil or v477:is_alive() == false then
                return;
            else
                local v478 = entity.get_entities("CPlantedC4", true)[1];
                local v479 = "";
                local v480 = 0;
                local v481 = false;
                local v482 = 0;
                local v483 = 0;
                local v484 = false;
                if v478 ~= nil and is_valid_entity(v478) then
                    v480 = v478.m_flC4Blow - globals.curtime;
                    v481 = v478.m_bBombDefused;
                    if v480 > 0 and not v481 then
                        local v485 = v478.m_hBombDefuser ~= 4294967295;
                        local l_m_flDefuseLength_0 = v478.m_flDefuseLength;
                        local v487 = v485 and v478.m_flDefuseCountDown - globals.curtime or -1;
                        if v487 > 0 then
                            local v488 = v487 < v480 and color(58, 191, 54, 160) or color(252, 18, 19, 125);
                            local v489 = (v434.y - 50) / l_m_flDefuseLength_0 * v487;
                            render.rect(vector(0, 0), vector(16, v434.y), color(25, 25, 25, 160));
                            render.rect_outline(vector(0, 0), vector(16, v434.y), color(25, 25, 25, 160));
                            render.rect(vector(0, v434.y - v489), vector(16, v434.y), v488);
                        end;
                        v479 = v478.m_nBombSite == 0 and "A" or "B";
                        local l_m_iHealth_0 = v477.m_iHealth;
                        local l_m_ArmorValue_0 = v477.m_ArmorValue;
                        local v492 = v478.m_vecOrigin:dist(v477.m_vecOrigin);
                        local v493 = 450.7;
                        local v494 = (v492 - 75.68) / 789.2;
                        v482 = v493 * math.exp(-v494 * v494);
                        if l_m_ArmorValue_0 > 0 then
                            local v495 = v482 * 0.5;
                            local v496 = (v482 - v495) * 0.5;
                            if l_m_ArmorValue_0 < v496 then
                                l_m_ArmorValue_0 = l_m_ArmorValue_0 * 2;
                                v495 = v482 - v496;
                            end;
                            v482 = v495;
                        end;
                        v483 = math.ceil(v482);
                        v484 = l_m_iHealth_0 <= v483;
                    end;
                end;
                if v435.planting then
                    v435.fill = 3.125 - (3.125 + v435.on_plant_time - globals.curtime);
                    if v435.fill > 3.125 then
                        v435.fill = 3.125;
                    end;
                end;
                local v497 = 44;
                local v498 = 0;
                local l_m_iPing_0 = v477:get_resource().m_iPing;
                local v500 = v9.misc.fake_latency_toggle.fake_latency_slider:get();
                local v501 = v436.ping:get();
                local v502 = math.max(v501, v500) / 2;
                local _ = math.min(1, l_m_iPing_0 / v502);
                local _ = {
                    [1] = 255, 
                    [2] = 0, 
                    [3] = 0
                };
                local _ = {
                    [1] = 150, 
                    [2] = 189, 
                    [3] = 18
                };
                local v506, v507, v508 = color(255, 255, 255):to_hsv();
                local v509, v510, v511 = color(151, 175, 54):to_hsv();
                local v512 = color();
                local v513, v514, v515 = v447(v506, v507, v508, v509, v510, v511, v454(v477));
                v512:as_hsv(v513, v514, v515, 255);
                v513 = {
                    [1] = {
                        [1] = "PING", 
                        [2] = v437:get("PING") and (not (v436.ping:get() <= 0) or v500 > 0) and v477:is_alive(), 
                        [3] = v512
                    }, 
                    [2] = {
                        [1] = "DT", 
                        [2] = v437:get("Double Tap") and not v436.hs:get() and v436.dt:get(), 
                        [3] = rage.exploit:get() == 1 and color(255, 200) or color(255, 0, 53, 255)
                    }, 
                    [3] = {
                        "OSAA", 
                        v437:get("Hide Shots") and v436.hs:get(), 
                        color(200, 255)
                    }, 
                    [4] = {
                        "DA", 
                        v437:get("Dormant Aimbot") and v436.da:get(), 
                        color(255, 200)
                    }, 
                    [5] = {
                        "DUCK", 
                        v437:get("Fake Duck") and v436.fd:get(), 
                        color(255, 200)
                    }, 
                    [6] = {
                        "BODY", 
                        v437:get("Body Aim") and v436.body:get() == "Force", 
                        color(255, 200)
                    }, 
                    [7] = {
                        "SAFE", 
                        v437:get("Safe Points") and v436.safe:get() == "Force", 
                        color(255, 200)
                    }, 
                    [8] = {
                        [1] = v479 .. " - " .. string.format("%.1f", v480) .. "s", 
                        [2] = v437:get("Bomb Info") and v480 > 0 and not v481, 
                        [3] = color(255, 200), 
                        [6] = v439
                    }, 
                    [9] = {
                        [1] = "FATAL", 
                        [2] = v437:get("Bomb Info") and v477:is_alive() and v484, 
                        [3] = color(255, 0, 0, 255)
                    }, 
                    [10] = {
                        [1] = "-" .. v483 .. " HP", 
                        [2] = v437:get("Bomb Info") and v477:is_alive() and not v484 and v482 > 0.5, 
                        [3] = color(210, 216, 112, 255)
                    }, 
                    [11] = {
                        [1] = v435.planting_site .. " ", 
                        [2] = v437:get("Bomb Info") and v435.planting, 
                        [3] = color(210, 216, 112, 255), 
                        [4] = color(255, 255), 
                        [5] = v435.fill / 3.3, 
                        [6] = v439
                    }, 
                    [12] = {
                        "FS", 
                        v437:get("Freestanding") and (v436.fs:get() or v9.rage.freestanding_bind:get()), 
                        color(255, 200)
                    }, 
                    [13] = {
                        "H1TCHANCE", 
                        v437:get("Hitchance") and v432.get_bind_state("Hit Chance")[1], 
                        color(255, 255)
                    }, 
                    [14] = {
                        "MD", 
                        v437:get("Damage") and v432.get_bind_state("Min. Damage")[1], 
                        color(255, 200)
                    }
                };
                for _, v517 in pairs(v513) do
                    if v517[2] then
                        v432.indicator(v517[1], v498, v517[3], v517[4], v517[5], v517[6]);
                        v498 = v498 - v497;
                    end;
                end;
                return;
            end;
        end;
    end;
    v432.spectators = function()
        -- upvalues: v438 (ref), v9 (ref), v432 (ref), v434 (ref)
        if not v438:get() or not v9.visuals.gs_inds:get() then
            return;
        else
            local v518 = 5;
            local v519 = v432.spectators_get();
            for _, v521 in pairs(v519) do
                if not is_valid_entity(v521) then
                    goto continue_spectator;
                end;
                local v522 = v521:get_name();
                local l_x_0 = render.measure_text(1, nil, v522).x;
                render.text(1, vector(v434.x - l_x_0 - 2, 2 + v518), color(255), nil, v522);
                v518 = v518 + 17;
                ::continue_spectator::
            end;
            return;
        end;
    end;
    v433.reset_bomb = function()
        -- upvalues: v435 (ref)
        v435.planting = false;
        v435.fill = 0;
        v435.on_plant_time = 0;
        v435.planting_site = "";
    end;
    v433.bomb_beginplant = function(v524)
        -- upvalues: v435 (ref)
        local v525 = entity.get_player_resource();
        if v525 == nil then
            return;
        else
            v435.on_plant_time = globals.curtime;
            v435.planting = true;
            local l_m_bombsiteCenterA_0 = v525.m_bombsiteCenterA;
            local l_m_bombsiteCenterB_0 = v525.m_bombsiteCenterB;
            local v528_ent = entity.get(v524.userid, true);
            if not v528_ent or not is_valid_entity(v528_ent) then
                return;
            end;
            local v528 = v528_ent:get_origin();
            v435.planting_site = v528:dist(l_m_bombsiteCenterA_0) < v528:dist(l_m_bombsiteCenterB_0) and "A" or "B";
            return;
        end;
    end;
    v9.visuals.molotov_radius.molotov_color = v9.visuals.molotov_radius:create():color_picker("Circle Color", color(255, 183, 183));
    v9.visuals.smokes_radius.smoks_color = v9.visuals.smokes_radius:create():color_picker("Circle Color", color(197, 199, 255));
    local v529 = nil;
    v529 = {};
    local v530 = 17.55;
    local v531 = 125;
    v529.distance_2d = function(v532, v533)
        return math.sqrt((v533.x - v532.x) ^ 2 + (v533.y - v532.y) ^ 2);
    end;
    v529.lerp_position = function(v534, v535, v536)
        return vector((v535.x - v534.x) * v536 + v534.x, (v535.y - v534.y) * v536 + v534.y, (v535.z - v534.z) * v536 + v534.z);
    end;
    do
        local l_v530_0, l_v531_0 = v530, v531;
        v529.draw = function()
            -- upvalues: v9 (ref), v529 (ref), l_v530_0 (ref), l_v531_0 (ref)
            if not entity.get_local_player() then
                return;
            else
                if v9.visuals.molotov_radius:get() then
                    local v539 = entity.get_entities("CInferno");
                    for v540 = 1, #v539 do
                        local v541 = v539[v540];
                        if not is_valid_entity(v541) then
                            goto continue_molotov;
                        end;
                        local v542 = v541:get_origin();
                        local v543 = 40;
                        local v544 = {};
                        local v545 = 0;
                        local v546 = nil;
                        local v547 = nil;
                        for v548 = 1, 64 do
                            if v541.m_bFireIsBurning[v548] == true then
                                table.insert(v544, vector(v541.m_fireXDelta[v548], v541.m_fireYDelta[v548], v541.m_fireZDelta[v548]));
                            end;
                        end;
                        for v549 = 1, #v544 do
                            for v550 = 1, #v544 do
                                local v551 = v529.distance_2d(v544[v549], v544[v550]);
                                if v545 < v551 then
                                    v545 = v551;
                                    v546 = v544[v549];
                                    v547 = v544[v550];
                                end;
                            end;
                        end;
                        if v546 and v547 then
                            local v552 = v542 + v529.lerp_position(v546, v547, 0.5);
                            local v553 = v9.visuals.molotov_radius.molotov_color:get();
                            render.circle_3d_outline(v552, color(v553.r, v553.g, v553.b, 255), v545 / 2 + v543, 0, 1);
                        end;
                        ::continue_molotov::
                    end;
                end;
                if v9.visuals.smokes_radius:get() then
                    local l_tickcount_1 = globals.tickcount;
                    local l_tickinterval_0 = globals.tickinterval;
                    local v556 = entity.get_entities("CSmokeGrenadeProjectile");
                    for v557 = 1, #v556 do
                        local v558 = v556[v557];
                        if not is_valid_entity(v558) then
                            goto continue_smoke;
                        end;
                        if v558:get_classname() == "CSmokeGrenadeProjectile" and v558.m_bDidSmokeEffect == true then
                            local l_m_nSmokeEffectTickBegin_0 = v558.m_nSmokeEffectTickBegin;
                            if l_m_nSmokeEffectTickBegin_0 ~= nil then
                                local v560 = l_tickinterval_0 * (l_tickcount_1 - l_m_nSmokeEffectTickBegin_0);
                                if v560 > 0 and l_v530_0 - v560 > 0 then
                                    local v561 = 1;
                                    if grenade_timer then
                                        v561 = 1 - v560 / l_v530_0;
                                    end;
                                    local v562 = v9.visuals.smokes_radius.smoks_color:get();
                                    local l_r_0 = v562.r;
                                    local l_g_0 = v562.g;
                                    local l_b_0 = v562.b;
                                    local l_a_0 = v562.a;
                                    local l_l_v531_0_0 = l_v531_0;
                                    if v560 < 0.3 then
                                        l_l_v531_0_0 = l_l_v531_0_0 * 0.6 + l_l_v531_0_0 * (v560 / 0.3) * 0.4;
                                        l_a_0 = l_a_0 * (v560 / 0.3);
                                    end;
                                    if l_v530_0 - v560 < 1 then
                                        l_l_v531_0_0 = l_l_v531_0_0 * ((l_v530_0 - v560) / 1 * 0.3 + 0.7);
                                    end;
                                    render.circle_3d_outline(v558:get_origin(), color(l_r_0, l_g_0, l_b_0, l_a_0 * math.min(1, v561 * 1.3)), l_l_v531_0_0, 0, 1);
                                end;
                            end;
                        end;
                        ::continue_smoke::
                    end;
                end;
                return;
            end;
        end;
    end;
    v530 = {
        lag_timer = 0, 
        ground_timer = 0, 
        in_air = function(v568, v569)
            if not v569 then
                return false;
            else
                local l_m_fFlags_0 = v569.m_fFlags;
                if bit.band(l_m_fFlags_0, 1) ~= 0 then
                    if v568.ground_timer == 5 then
                        return false;
                    else
                        v568.ground_timer = v568.ground_timer + 1;
                    end;
                else
                    v568.ground_timer = 0;
                end;
                return true;
            end;
        end, 
        is_moving = function(_, v572)
            local l_m_vecVelocity_0 = v572.m_vecVelocity;
            return math.sqrt(l_m_vecVelocity_0.x * l_m_vecVelocity_0.x + l_m_vecVelocity_0.y * l_m_vecVelocity_0.y) > 2;
        end, 
        is_crouching = function(_, v575)
            return v575.m_bDucked;
        end, 
        team_num = function(_, v577)
            return v577.m_iTeamNum;
        end, 
        get_state = function(v578, v579)
            -- upvalues: v9 (ref), l_core_0 (ref)
            local v580 = v578:is_moving(v579);
            local v581 = v578:is_crouching(v579);
            local v582 = v578:in_air(v579);
            if v9.rage.manual:get() ~= "At Target" then
                return "Manual";
            elseif v582 then
                return v581 and "Air Crouch" or "Air";
            elseif l_core_0.refs.slow:get() then
                return "Slowmotion";
            elseif v581 then
                return v580 and "Crouch Moving" or "Crouch";
            else
                return v580 and "Running" or "Standing";
            end;
        end
    };
    v531 = {
        manual_last_pressed = globals.realtime
    };
    local _ = function(v583, v584, _, v586, v587, _)
        return math.sqrt((v583 - v586) * (v583 - v586) + (v584 - v587) * (v584 - v587));
    end;
    local function _(v590, v591, v592, v593, v594)
        local l_m_vecVelocity_1 = v590.m_vecVelocity;
        return v592 + globals.tickinterval * l_m_vecVelocity_1.x * v591, v593 + globals.tickinterval * l_m_vecVelocity_1.y * v591, v594 + globals.tickinterval * l_m_vecVelocity_1.z * v591;
    end;
    reset_current_state = function()
        -- upvalues: v9 (ref), v12 (ref)
        local v597 = v9.rage.team_list:get();
        local v598 = v597 == "T" and "" or "_ct";
        local v599 = v9.rage.aa_lister:get();
        local v600 = {
            [1] = "yaw_mode", 
            [2] = "yaw_left", 
            [3] = "yaw_right", 
            [4] = "Jitter", 
            [5] = "yaw_jitter_ovr", 
            [6] = "body_yaw", 
            [7] = "fake_left", 
            [8] = "fake_right", 
            [9] = "fake_options", 
            [10] = "body_speed"
        };
        local v601 = {
            fake_options = "Jitter", 
            yaw_mode = "L - R", 
            body_speed = 2, 
            fake_right = 60, 
            fake_left = 60, 
            yaw_right = 0, 
            yaw_left = 0, 
            yaw_jitter_ovr = 0, 
            Jitter = "Disabled", 
            body_yaw = true
        };
        local v602 = v9.rage.state_list:get();
        local v603 = nil;
        if v599 == 2 then
            v603 = v9.rage.builder_elements[v602];
        elseif v599 == 3 then
            v603 = v9.rage.defensive_elements[v602];
        else
            v12.push("Error: Please select Anti-Aim or Defensive tab");
            return;
        end;
        if not v603 then
            v12.push("Error: No settings found for the selected state");
            return;
        else
            for _, v605 in ipairs(v600) do
                local v606 = v603[v605 .. v598];
                if v606 and v606.set and v601[v605] then
                    v606:set(v601[v605]);
                end;
            end;
            local v607 = v599 == 2 and "Anti-Aim" or "Defensive";
            v12.push(v607 .. " settings reset to default values for " .. (v597 == "T" and "T-side" or "CT-side"));
            return;
        end;
    end;
    send_to_opposite_team = function()
        -- upvalues: v9 (ref), v12 (ref)
        local v608 = v9.rage.state_list:get();
        local v609 = v9.rage.team_list:get();
        local v610 = v9.rage.aa_lister:get();
        local v611 = v609 == "T";
        local v612 = v609 == "CT";
        if not v608 then
            v12.push("Error: No state selected.");
            return;
        else
            local v613 = nil;
            if v610 == 2 then
                v613 = v9.rage.builder_elements[v608];
            elseif v610 == 3 then
                v613 = v9.rage.defensive_elements[v608];
            else
                v12.push("Error: Please select Anti-Aim or Defensive tab");
                return;
            end;
            if not v613 then
                v12.push("Error: No settings found for the selected state: " .. v608);
                return;
            else
                local v614 = {
                    [1] = "yaw_mode", 
                    [2] = "yaw", 
                    [3] = "yaw_randomize", 
                    [4] = "yaw_center", 
                    [5] = "yaw_left", 
                    [6] = "yaw_right", 
                    [7] = "Jitter", 
                    [8] = "yaw_jitter_ovr", 
                    [9] = "jitter_randomize", 
                    [10] = "body_yaw", 
                    [11] = "body_speed", 
                    [12] = "random_speed", 
                    [13] = "fake_left", 
                    [14] = "fake_left_random", 
                    [15] = "fake_right", 
                    [16] = "fake_right_random", 
                    [17] = "fake_options", 
                    [18] = "antibrute", 
                    [19] = "anti_timeout", 
                    [20] = "antibrute_method", 
                    [21] = "ran_speed_1", 
                    [22] = "ran_speed_2", 
                    [23] = "speed_options", 
                    [24] = "center_options", 
                    [25] = "custom_speed_amount", 
                    [26] = "random_speed_method", 
                    [27] = "custom_amount", 
                    [28] = "amnesia_tick_speed", 
                    [29] = "yaw_random_methods", 
                    [30] = "r_min", 
                    [31] = "r_max", 
                    [32] = "scale", 
                    [33] = "frequency", 
                    [34] = "amplitude"
                };
                for v615 = 1, 22 do
                    table.insert(v614, "custom_slider_" .. v615);
                    table.insert(v614, "custom_speed_slider_" .. v615);
                end;
                local v616 = v612 and "_ct" or "";
                local v617 = v611 and "_ct" or "";
                if v616 == v617 then
                    v12.push("Error: Source and target teams are the same.");
                    return;
                else
                    local v618 = 0;
                    local v619 = 0;
                    for _, v621 in ipairs(v614) do
                        local v622 = v621 .. v616;
                        local v623 = v621 .. v617;
                        local v624 = v613[v622];
                        local v625 = v613[v623];
                        do
                            local l_v624_0, l_v625_0 = v624, v625;
                            if l_v624_0 and l_v625_0 and l_v624_0.get and l_v625_0.set then
                                v619 = v619 + 1;
                                if pcall(function()
                                    -- upvalues: l_v624_0 (ref), l_v625_0 (ref)
                                    local v628 = l_v624_0:get();
                                    l_v625_0:set(v628);
                                end) then
                                    v618 = v618 + 1;
                                end;
                            end;
                        end;
                    end;
                    local v629 = v612 and "CT-side" or "T-side";
                    local v630 = v611 and "CT-side" or "T-side";
                    local v631 = v610 == 2 and "Anti-Aim" or "Defensive";
                    v12.push("Transferred " .. v618 .. "/" .. v619 .. " " .. v631 .. " settings from " .. v629 .. " to " .. v630 .. " for state: " .. v608);
                    return;
                end;
            end;
        end;
    end;
    v14.handle = function(v632)
        -- upvalues: v9 (ref), l_core_0 (ref)
        if not v9.misc.fast_ladder:get() then
            return;
        elseif l_core_0.shared_data.movetype ~= 9 then
            return;
        elseif math.abs(v632.forwardmove) < 50 then
            return;
        else
            local _ = entity.get_local_player();
            if v632.sidemove == 0 then
                v632.view_angles.y = v632.view_angles.y + 45;
            end;
            if v632.in_forward and v632.sidemove < 0 then
                v632.view_angles.y = v632.view_angles.y + 90;
            end;
            if v632.in_back and v632.sidemove > 0 then
                v632.view_angles.y = v632.view_angles.y + 90;
            end;
            v632.in_moveleft = v632.in_back;
            v632.in_moveright = v632.in_forward;
            if v632.view_angles.x < 0 then
                v632.view_angles.x = -45;
            end;
            return;
        end;
    end;
    v11.register("createmove", "fast_ladder", v14.handle);
    local v634 = false;
    local v635 = false;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local _ = 0;
    local v644 = 0;
    local v645 = 0;
    local _ = 4;
    local _ = function(v647)
        -- upvalues: v91 (ref)
        for _, v649 in ipairs(v91.conditions) do
            if v647 == v649 then
                return true;
            end;
        end;
        return false;
    end;
    local v651 = 0;
    local v652 = false;
    local v653 = nil;
    check_weapon_swap = function()
        -- upvalues: v653 (ref)
        local v654 = entity.get_local_player();
        if v654 == nil or not v654:is_alive() then
            return;
        else
            local v655 = v654:get_player_weapon();
            if v655 then
                local v656 = v655:get_weapon_index();
                if v653 == nil then
                    v653 = v656;
                    return;
                elseif v656 ~= v653 then
                    v653 = v656;
                    return true;
                end;
            end;
            return;
        end;
    end;
    local v657 = false;
    check_reloading = function()
        -- upvalues: v657 (ref)
        local v658 = entity.get_local_player();
        if v658 == nil or not v658:is_alive() then
            return;
        else
            local v659 = v658:get_player_weapon();
            if v659 then
                local v660 = v659:get_weapon_reload();
                if v660 > 0 and v660 < 1 then
                    if not v657 then
                        v657 = true;
                        return true;
                    end;
                elseif v657 then
                    v657 = false;
                    return false;
                end;
                return;
            else
                return false;
            end;
        end;
    end;
    local v661 = 0;
    l_core_0.calculate_yaw_5way = function(v662, v663, v664)
        local v665 = nil;
        if v662 % 7 < 1.4 then
            v665 = utils.random_float(v663 / -2, v663 / -2 - v664);
        elseif v662 % 7 < 1.75 then
            v665 = utils.random_float(v663 / -2.5, v663 / -2.5 - v664);
        elseif v662 % 7 < 2.3333333333333335 then
            v665 = 0;
        elseif v662 % 7 < 3.5 then
            v665 = utils.random_float(v663 / 2.5, v663 / 2.5 - v664);
        elseif v662 % 7 < 7 then
            v665 = utils.random_float(v663 / 2, v663 / 2 - v664);
        end;
        return v665;
    end;
    l_core_0.calculate_yaw_3way = function(v666, v667, v668)
        local v669 = nil;
        if v666 % 7 < 2.3333333333333335 then
            v669 = utils.random_float(v667 / -2, v667 / -2 - v668);
        elseif v666 % 7 < 3.5 then
            v669 = 0;
        elseif v666 % 7 < 7 then
            v669 = utils.random_float(v667 / 2, v667 / 2 - v668);
        end;
        return v669;
    end;
    local v672 = {
        max_tickbase = 0, 
        is_defensive = function()
            -- upvalues: v661 (ref)
            local v670 = entity.get_local_player();
            if not v670 or not v670:is_alive() then
                return;
            else
                local l_m_nTickBase_0 = v670.m_nTickBase;
                if math.abs(l_m_nTickBase_0 - v661) > 64 then
                    v661 = 0;
                end;
                if v661 < l_m_nTickBase_0 then
                    v661 = l_m_nTickBase_0;
                elseif l_m_nTickBase_0 < v661 then
                    return math.min(14, math.max(0, v661 - l_m_nTickBase_0 - 1)) > 1;
                end;
                return false;
            end;
        end
    };
    local _ = 0;
    local v674 = 0;
    local _ = 0;
    local v676 = false;
    local _ = false;
    local v678 = 180;
    local _ = 0;
    local _ = 0;
    local function _(v681)
        -- upvalues: v674 (ref), v676 (ref), v678 (ref)
        local v682 = 2;
        local v683 = 2 * v681;
        v674 = v674 + 1;
        if v676 and v682 <= v674 or not v676 and v683 <= v674 then
            v676 = not v676;
            v674 = 0;
        end;
        return v676, v676 and (v674 == 1 and v678 or v678) or 0;
    end;
    l_core_0.random_choke = function(v685, v686, v687)
        return v685 % v686[v687 and math.random(1, #v686) or (v685 - 1) % #v686 + 1] == 0;
    end;
    l_core_0.choke_aa = function(v688, v689)
        local v690 = v688[v689 % #v688 + 1];
        v689 = v689 + 1;
        return v690;
    end;
    events.createmove:set(function(v691)
        jumping = v691.in_jump == true;
    end);
    events.createmove_run:set(function(v692)
        -- upvalues: l_core_0 (ref), v9 (ref)
        local local_player_fd = entity.get_local_player();
        if l_core_0.refs.fd:get() and v9.misc.unlock_fakeduck:get() and not jumping and local_player_fd and is_valid_entity(local_player_fd) and bit.band(local_player_fd.m_fFlags, 1) ~= 0 then
            v692.forwardmove = v692.forwardmove * 2;
            v692.sidemove = v692.sidemove * 2;
        end;
    end);
    l_core_0.closest_ray_point = function(v693, v694, v695)
        local v696 = v693 - v694;
        local v697 = v695 - v694;
        local v698 = v697:length();
        v697 = v697 / v698;
        local v699 = v697:dot(v696);
        if v699 < 0 then
            return v694;
        elseif v698 < v699 then
            return v695;
        else
            return v694 + v697 * v699;
        end;
    end;
    l_core_0.active_brute = false;
    l_core_0.active_timeout = false;
    l_core_0.dist = 0;
    l_core_0.brute_target = "none";
    l_core_0.get_camera_pos = function(v700)
        local l_m_vecOrigin_0 = v700.m_vecOrigin;
        if l_m_vecOrigin_0.x == nil then
            return;
        else
            local l_m_vecViewOffset_0 = v700.m_vecViewOffset;
            l_m_vecOrigin_0.z = l_m_vecOrigin_0.z + (l_m_vecViewOffset_0.z - v700.m_flDuckAmount * 16);
            return l_m_vecOrigin_0.x, l_m_vecOrigin_0.y, l_m_vecOrigin_0.z;
        end;
    end;
    l_core_0.fired_at = function(v703, v704, v705)
        -- upvalues: l_core_0 (ref)
        if not is_valid_entity(v703) or not is_valid_entity(v704) then
            return;
        end;
        local v706 = {
            l_core_0.get_camera_pos(v704)
        };
        if v706[1] == nil then
            return;
        else
            local v707 = v703:get_hitbox_position(0);
            local v708 = {
                [1] = v707.x - v706[1], 
                [2] = v707.y - v706[2], 
                [3] = v707.z - v706[3]
            };
            local v709 = {
                [1] = v705[1] - v706[1], 
                [2] = v705[2] - v706[2], 
                [3] = v705[3] - v706[3]
            };
            local v710 = (v708[1] * v709[1] + v708[2] * v709[2] + v708[3] * v709[3]) / (math.pow(v709[1], 2) + math.pow(v709[2], 2) + math.pow(v709[3], 2));
            local v711 = {
                [1] = v706[1] + v709[1] * v710, 
                [2] = v706[2] + v709[2] * v710, 
                [3] = v706[3] + v709[3] * v710
            };
            local v712 = math.abs(math.sqrt(math.pow(v707.x - v711[1], 2) + math.pow(v707.y - v711[2], 2) + math.pow(v707.z - v711[3], 2)));
            local v713 = utils.trace_bullet(v704, vector(v705[1], v705[2], v705[3]), v707);
            local v714 = utils.trace_bullet(v703, vector(v711[1], v711[2], v711[3]), v707);
            return v712 < 129 and (not (v713 <= 0.99) or v714 > 0.99);
        end;
    end;
    local _ = 0;
    l_core_0.antibrute = {
        damaged = 0, 
        latest = 0, 
        players = entity.get_players(false, true), 
        trigger = function(v716)
            -- upvalues: v530 (ref), v9 (ref), l_core_0 (ref)
            local v717 = entity.get_local_player();
            if v717 == nil or not is_valid_entity(v717) or not v717:is_alive() then
                return;
            else
                local v718 = v530:get_state(v717);
                v530.state = v718;
                if v718 == "none" then
                    return;
                else
                    local v719 = v9.rage.builder_elements[v718];
                    if not v719.antibrute:get() and l_core_0.shared_data.team == 2 or not v719.antibrute_ct:get() and l_core_0.shared_data.team == 3 then
                        return;
                    else
                        local v720 = entity.get(v716.userid, true);
                        if not v720 or not is_valid_entity(v720) or not v720:is_enemy() or v720:is_dormant() then
                            return;
                        else
                            if l_core_0.fired_at(v717, v720, {
                                [1] = v716.x, 
                                [2] = v716.y, 
                                [3] = v716.z
                            }) and l_core_0.antibrute.latest ~= globals.tickcount then
                                l_core_0.antibrute.latest = globals.tickcount;
                                l_core_0.brute_target = v720:get_name();
                                l_core_0.active_brute = true;
                                l_core_0.active_timeout = false;
                                l_core_0.antibrute.latest = globals.tickcount;
                                if l_core_0.shared_data.team == 2 then
                                    if v719.anti_timeout:get() == 0 then
                                        l_core_0.active_brute = true;
                                    else
                                        utils.execute_after(v719.anti_timeout:get(), function()
                                            -- upvalues: l_core_0 (ref)
                                            l_core_0.active_brute = false;
                                            l_core_0.active_timeout = true;
                                        end);
                                    end;
                                elseif l_core_0.shared_data.team == 3 then
                                    if v719.anti_timeout_ct:get() == 0 then
                                        l_core_0.active_brute = true;
                                    else
                                        utils.execute_after(v719.anti_timeout_ct:get(), function()
                                            -- upvalues: l_core_0 (ref)
                                            l_core_0.active_brute = false;
                                            l_core_0.active_timeout = true;
                                        end);
                                    end;
                                end;
                            end;
                            return;
                        end;
                    end;
                end;
            end;
        end, 
        run = function(v721)
            events.bullet_impact:set(v721.trigger);
            events.player_hurt:set(function(v722)
                -- upvalues: v721 (ref)
                local v722_ent = entity.get(v722.userid, true);
                if v722_ent and is_valid_entity(v722_ent) and v722_ent == lp then
                    v721.damaged = globals.tickcount;
                end;
            end);
        end
    };
    l_core_0.antibrute:run();
    l_core_0.choked_commands = 0;
    l_core_0.update_choked_commands = function(v723)
        -- upvalues: l_core_0 (ref)
        l_core_0.choked_commands = v723.choked_commands;
    end;
    events.createmove(l_core_0.update_choked_commands);
    l_core_0.choke_values = {
        [1] = 6, 
        [2] = 6, 
        [3] = 6
    };
    l_core_0.tick_choke = 0;
    l_core_0.allow_inverter = true;
    l_core_0.brute_modifier = 0;
    l_core_0.brute_modifier_ct = 0;
    local v724 = false;
    local v725 = false;
    l_core_0.auto = false;
    l_core_0.get_ref = function(v726, v727, _)
        -- upvalues: l_core_0 (ref)
        local v729 = v726 .. (l_core_0.shared_data.team == 2 and "" or "_ct");
        return v727[v729]:get() or v727[v729]:get_override();
    end;
    l_core_0.index = 0;
    l_core_0.yaw_ovr = 0;
    local v730 = 0;
    local _ = {};
    local v732 = 1;
    local v733 = 1;
    local v734 = 0;
    local v735 = false;
    l_core_0.ctx = {
        pitch = "Down", 
        counter = 0, 
        torpedo_value = 0, 
        yaw = 0, 
        tick_count = 0, 
        hold_value = 0, 
        offset = 0
    };
    local v736 = false;
    local _ = 0.5;
    local function v740(v738, v739)
        return math.floor(math.random() * (v739 - v738 + 1) + v738);
    end;
    local v741 = 0;
    local _ = 0;
    l_core_0.update_counters = function()
        -- upvalues: l_core_0 (ref), v644 (ref), v645 (ref), v651 (ref), v652 (ref)
        l_core_0.tick_choke = l_core_0.tick_choke + 1;
        l_core_0.ctx.counter = l_core_0.ctx.counter + 1;
        v644 = v644 + 1;
        v645 = v645 + 1;
        v651 = v651 + 1;
        if v651 > 1 then
            v652 = not v652;
            v651 = 0;
        end;
    end;
    events.createmove(l_core_0.update_counters);
    l_core_0.apply_yaw_settings = function(v743, v744, v745, _, _, v748, v749, _)
        -- upvalues: l_core_0 (ref), v741 (ref), v740 (ref), v732 (ref), v730 (ref), v736 (ref)
        if l_core_0.choked_commands > 0 then
            return;
        else
            local l_get_ref_0 = l_core_0.get_ref;
            local l_random_float_0 = utils.random_float;
            local l_random_int_0 = utils.random_int;
            local v754 = l_get_ref_0("Jitter", v744, v745);
            local v755 = l_get_ref_0("yaw_randomize", v744, v745);
            local v756 = l_get_ref_0("fake_options", v744, v745);
            local v757 = l_get_ref_0("center_options", v744, v745);
            local v758 = v757 == "Custom";
            local local_player_wpn = entity.get_local_player();
            local _ = local_player_wpn and is_valid_entity(local_player_wpn) and local_player_wpn:get_player_weapon(false) and local_player_wpn:get_player_weapon(false):get_classname() or nil;
            local function v773(v761, v762)
                -- upvalues: l_get_ref_0 (ref), v744 (ref), v745 (ref), l_random_float_0 (ref)
                local v763 = l_get_ref_0("yaw_random_methods", v744, v745);
                if v763 == "Default" then
                    if v761 > 0 then
                        local v764 = v761 - v762;
                        local l_v761_0 = v761;
                        return l_random_float_0(math.min(v764, l_v761_0), math.max(v764, l_v761_0));
                    elseif v761 < 0 then
                        local l_v761_1 = v761;
                        local v767 = v761 + v762;
                        return l_random_float_0(math.min(l_v761_1, v767), math.max(l_v761_1, v767));
                    else
                        return 0;
                    end;
                elseif v763 == "Sinusoidal" then
                    local v768 = l_get_ref_0("frequency", v744, v745);
                    local v769 = l_get_ref_0("amplitude", v744, v745);
                    return v761 + math.sin(globals.curtime * v768) * v769;
                elseif v763 == "Chaotic" then
                    local v770 = l_get_ref_0("r_min", v744, v745);
                    local v771 = l_get_ref_0("r_max", v744, v745);
                    local v772 = globals.curtime * l_get_ref_0("scale", v744, v745);
                    return v761 + l_random_float_0(v770, v771) * math.sin(v772) * math.cos(v772 * 2) * math.sin(v772 * 0.5);
                else
                    return v761;
                end;
            end;
            local function v780(v774, v775, _, _, v778)
                -- upvalues: v741 (ref), v773 (ref), v755 (ref), v740 (ref)
                local v779 = math.random(1, 100);
                if v778 then
                    if v779 <= 45 then
                        v741 = v773(v774, v755);
                    elseif v779 <= 75 then
                        v741 = -math.abs(v773(v774 * 0.8, v755));
                    else
                        v741 = v740(-5, 0);
                    end;
                elseif v779 <= 45 then
                    v741 = v773(v775, v755);
                elseif v779 <= 75 then
                    v741 = math.abs(v773(v775 * 0.8, v755));
                else
                    v741 = v740(0, 5);
                end;
                return v741;
            end;
            local function v786(v781, v782, _, _, v785)
                -- upvalues: l_core_0 (ref), v773 (ref), v755 (ref)
                if l_core_0.ctx.counter % math.random(5, 7) == 0 then
                    l_core_0.ctx.torpedo_value = math.random(-3, 6);
                elseif v785 then
                    l_core_0.ctx.torpedo_value = v773(v781, v755);
                else
                    l_core_0.ctx.torpedo_value = v773(v782, v755);
                end;
                return l_core_0.ctx.torpedo_value;
            end;
            local v787 = nil;
            local l_body_yaw_0 = l_core_0.refs.body_yaw;
            if v756 == "Static" then
                v787 = v773(l_get_ref_0("yaw_left", v744, v745), v755);
                l_body_yaw_0[3]:override(l_random_int_0(l_get_ref_0("fake_left", v744, v745), l_get_ref_0("fake_left", v744, v745) - l_get_ref_0("fake_left_random", v744, v745)));
                l_body_yaw_0[4]:override(l_random_int_0(l_get_ref_0("fake_right", v744, v745), l_get_ref_0("fake_right", v744, v745) - l_get_ref_0("fake_right_random", v744, v745)));
                l_core_0.refs.inverter:override(true);
            else
                if v758 then
                    local v789 = {};
                    for v790 = 1, l_get_ref_0("custom_amount", v744, v745) do
                        local v791 = l_get_ref_0("custom_slider_" .. v790, v744, v745);
                        if v791 then
                            table.insert(v789, v791);
                        end;
                    end;
                    if #v789 > 0 then
                        v732 = v732 % #v789 + 1;
                        v730 = v789[v732];
                    end;
                end;
                if v754 ~= "Center" then
                    local v792 = v757 == "Min - Max" and math.random(l_get_ref_0("center_min", v744, v745), l_get_ref_0("center_max", v744, v745)) or v757 == "Randomize" and l_random_float_0(l_get_ref_0("yaw_jitter_ovr", v744, v745), l_get_ref_0("yaw_jitter_ovr", v744, v745) - l_get_ref_0("jitter_randomize", v744, v745)) or v758 and v730 or l_random_float_0(l_get_ref_0("yaw_jitter_ovr", v744, v745), l_get_ref_0("yaw_jitter_ovr", v744, v745));
                    l_core_0.refs.jitter:override(v754);
                    l_core_0.refs.jitter_val:override(v792);
                else
                    l_core_0.refs.jitter:override("Disabled");
                    l_core_0.refs.jitter_val:override(0);
                end;
                if v743 then
                    if v754 == "Center" then
                        v787 = v758 and v730 or v773(v748, v755);
                    elseif v754 == "3-way" or v754 == "5-way" or v754 == "Spin" then
                        v787 = v773(v748, v755);
                    elseif v754 == "Hold" then
                        v787 = v780(v748, v749, v744, v745, v743);
                    elseif v754 == "Torpedo" then
                        v787 = v786(v748, v749, v744, v745, v743);
                    else
                        v787 = v773(l_get_ref_0("yaw_left", v744, v745), v755);
                    end;
                    if v736 then
                        l_body_yaw_0[3]:override(l_random_int_0(l_get_ref_0("fake_left", v744, v745), l_get_ref_0("fake_left", v744, v745) - l_get_ref_0("fake_left_random", v744, v745)));
                        l_body_yaw_0[4]:override(l_random_int_0(l_get_ref_0("fake_right", v744, v745), l_get_ref_0("fake_right", v744, v745) - l_get_ref_0("fake_right_random", v744, v745)));
                        l_core_0.refs.inverter:override(false);
                    else
                        l_body_yaw_0[3]:override(l_random_int_0(l_get_ref_0("fake_left", v744, v745), l_get_ref_0("fake_left", v744, v745) - l_get_ref_0("fake_left_random", v744, v745)));
                        l_body_yaw_0[4]:override(l_random_int_0(-l_get_ref_0("fake_right", v744, v745), -l_get_ref_0("fake_right", v744, v745) - l_get_ref_0("fake_right_random", v744, v745)));
                        l_core_0.refs.inverter:override(l_core_0.allow_inverter);
                    end;
                else
                    if v754 == "Center" then
                        v787 = v758 and v730 or v773(v749, v755);
                    elseif v754 == "3-way" or v754 == "5-way" or v754 == "Spin" then
                        v787 = v773(v749, v755);
                    elseif v754 == "Hold" then
                        v787 = v780(v748, v749, v744, v745, v743);
                    elseif v754 == "Torpedo" then
                        v787 = v786(v748, v749, v744, v745, v743);
                    else
                        v787 = v773(l_get_ref_0("yaw_right", v744, v745), v755);
                    end;
                    if v736 then
                        l_body_yaw_0[3]:override(l_random_int_0(l_get_ref_0("fake_left", v744, v745), l_get_ref_0("fake_left", v744, v745) - l_get_ref_0("fake_left_random", v744, v745)));
                        l_body_yaw_0[4]:override(l_random_int_0(l_get_ref_0("fake_right", v744, v745), l_get_ref_0("fake_right", v744, v745) - l_get_ref_0("fake_right_random", v744, v745)));
                    else
                        l_body_yaw_0[3]:override(l_random_int_0(-l_get_ref_0("fake_left", v744, v745), -l_get_ref_0("fake_left", v744, v745) - l_get_ref_0("fake_left_random", v744, v745)));
                        l_body_yaw_0[4]:override(l_random_int_0(l_get_ref_0("fake_right", v744, v745), l_get_ref_0("fake_right", v744, v745) - l_get_ref_0("fake_right_random", v744, v745)));
                    end;
                    l_core_0.refs.inverter:override(false);
                end;
            end;
            return v787;
        end;
    end;
    local v793 = {
        Forward = 180, 
        Right = 90, 
        Left = -90
    };
    local v794 = {
        [1] = "Standing", 
        [2] = "Running", 
        [3] = "Slowmotion", 
        [4] = "Crouch", 
        [5] = "Crouch Moving", 
        [6] = "Air", 
        [7] = "Air Crouch"
    };
    l_core_0.should_disable_freestand = function(v795, v796)
        -- upvalues: v794 (ref)
        for v797, v798 in pairs(v794) do
            if v795:get(v797) and v796 == v798 then
                return true;
            end;
        end;
        return false;
    end;
    l_core_0.apply_manual = function(v799)
        -- upvalues: v531 (ref), l_core_0 (ref), v9 (ref)
        v531.manual_state = v799;
        l_core_0.refs.base:override("local view");
        if v9.rage.freestanding_bind.prefer_manual:get() then
            l_core_0.refs.freestand_bind:set(false);
            if not v9.rage.freestanding_bind.keep_fs:get() then
                v9.rage.freestanding_bind:set(false);
            end;
        end;
    end;
    l_core_0.handle_safe_head = function()
        -- upvalues: v530 (ref), v9 (ref)
        local v800 = entity.get_local_player();
        if v800 == nil then
            return;
        elseif not v800:is_alive() then
            return;
        else
            local v801 = v530:get_state(v800);
            local v802 = v800:get_player_weapon(false);
            if v802 == nil then
                return;
            else
                local v803 = v802:get_classname();
                local l_safe_options_0 = v9.rage.safe_head.safe_options;
                local v805 = entity.get_threat(false);
                local v806 = v803:find("Knife");
                local v807 = v803:find("Taser");
                local v808 = v800:get_origin();
                local _ = 0;
                local v810 = (v805 == nil and 0 or v805:get_origin()) - v808;
                local v811 = -v810.z;
                local v812 = v810:length2dsqr();
                local v813 = l_safe_options_0:get(1);
                local v814 = l_safe_options_0:get(2);
                local v815 = l_safe_options_0:get(3);
                local v816 = l_safe_options_0:get(4);
                local v817 = l_safe_options_0:get(5);
                local v818 = l_safe_options_0:get(6);
                if v813 and v801 == "Standing" then
                    return true;
                elseif v814 and v801 == "Crouch" then
                    return true;
                elseif v815 and v801 == "Air Crouch" and v806 then
                    return true;
                elseif v818 and v801 == "Air Crouch" and v807 then
                    return true;
                elseif v816 and v805 ~= nil and v812 > 1000000 then
                    return true;
                elseif v817 and v811 >= 24 then
                    return true;
                else
                    return false;
                end;
            end;
        end;
    end;
    l_core_0.distance = function(v819, v820, _, v822, v823, _)
        return math.sqrt((v819 - v822) * (v819 - v822) + (v820 - v823) * (v820 - v823));
    end;
    l_core_0.extrapolate = function(v825, v826, v827, v828, v829)
        local l_x_1 = v825.m_vecVelocity.x;
        local l_y_0 = v825.m_vecVelocity.y;
        local l_z_0 = v825.m_vecVelocity.z;
        return v827 + globals.tickinterval * l_x_1 * v826, v828 + globals.tickinterval * l_y_0 * v826, v829 + globals.tickinterval * l_z_0 * v826;
    end;
    l_core_0.round_end = false;
    l_core_0.last_values = {
        body_mode_val = "Disabled", 
        yaw4_val = 0, 
        yaw3_val = 0, 
        inverter_val = false, 
        body_enable_val = false, 
        jitter_val_val = 0, 
        jitter_mode_val = "Disabled", 
        pitch_val = "Disabled", 
        offset_val = 0, 
        base_val = "At Target", 
        body6_val = "Off"
    };
    l_core_0.handle_neverlose_body = function(v833, v834, _, v836)
        -- upvalues: l_core_0 (ref), v531 (ref), v736 (ref)
        if l_core_0.choked_commands == 0 then
            local v837 = entity.get_local_player();
            if v837 == nil or not v837:is_alive() then
                return;
            elseif v837:get_player_weapon(false) == nil then
                return;
            else
                local _ = l_core_0.refs;
                local v839 = not l_core_0.should_disable_freestand(v833.rage.freestanding_bind.freestand_options, v834) and (v833.rage.freestanding_bind:get() or v833.rage.freestanding_bind:get_override());
                local l_manual_state_0 = v531.manual_state;
                local l_tickcount_2 = globals.tickcount;
                local function v845(v842)
                    -- upvalues: l_core_0 (ref)
                    for v843, v844 in pairs(v842) do
                        l_core_0.last_values[v843] = v844;
                    end;
                end;
                l_core_0.refs.backstab:override(v833.rage.avoid_knife:get());
                if v839 then
                    local v846 = v833.rage.freestanding_bind.freestand_body:get();
                    if v846 == 1 or v846 == 2 then
                        v845({
                            body6_val = "Off", 
                            body_enable_val = true, 
                            base_val = "At Target", 
                            pitch_val = "Down", 
                            offset_val = l_manual_state_0, 
                            body_mode_val = v846 == 1 and "Static" or "Jitter"
                        });
                    end;
                    v736 = v846 == 1;
                elseif v833.rage.manual:get() ~= "At Target" then
                    v845({
                        base_val = "local view", 
                        offset_val = l_manual_state_0 - v836
                    });
                    v736 = false;
                elseif v833.rage.safe_head:get() and l_core_0.handle_safe_head() then
                    v845({
                        body_mode_val = "Static", 
                        offset_val = 30, 
                        body6_val = "Off", 
                        body_enable_val = true, 
                        base_val = "At Target", 
                        pitch_val = "Down"
                    });
                    v736 = true;
                elseif (entity.get_game_rules().m_bWarmupPeriod or l_core_0.round_end) and v833.rage.additions:get(1) then
                    v845({
                        body_mode_val = "Disabled", 
                        body6_val = "Off", 
                        body_enable_val = false, 
                        base_val = "local view", 
                        pitch_val = "Disabled", 
                        offset_val = l_tickcount_2 * 25 % 360
                    });
                    v736 = false;
                else
                    v845({
                        body6_val = "off", 
                        body_enable_val = true, 
                        base_val = "At Target", 
                        pitch_val = "down", 
                        offset_val = v836 - l_core_0.brute_modifier
                    });
                    v736 = false;
                end;
            end;
        end;
        local l_refs_1 = l_core_0.refs;
        l_refs_1.offset:override(l_core_0.last_values.offset_val);
        l_refs_1.pitch:set(l_core_0.last_values.pitch_val);
        l_refs_1.body_yaw[6]:override(l_core_0.last_values.body6_val);
        l_refs_1.base:override(l_core_0.last_values.base_val);
    end;
    local l_random_int_1 = v19.utils.random_int;
    local l_random_float_1 = v19.utils.random_float;
    local l_normalize_yaw_0 = v19.math.normalize_yaw;
    local l_get_ref_1 = l_core_0.get_ref;
    local l_commandack_1 = globals.commandack;
    local _ = globals.tickcount;
    local v854 = {};
    for v855, v856 in pairs(v794) do
        v854[v856] = v855;
    end;
    local function v891(v857, v858, v859, v860)
        -- upvalues: l_core_0 (ref), l_random_float_1 (ref), l_normalize_yaw_0 (ref), v672 (ref), v736 (ref), l_random_int_1 (ref)
        local v861 = l_core_0.get_ref("def_toggle", v857, v858);
        if not v859 or not v861 then
            return false;
        else
            local l_body_yaw_1 = l_core_0.refs.body_yaw;
            local l_get_ref_2 = l_core_0.get_ref;
            local v864 = l_get_ref_2("yaw_mode", v857, v858);
            local v865 = l_get_ref_2("def_pitch", v857, v858);
            local v866 = v865 == "Down" and 89 or v865 == "Random" and l_random_float_1(-89, 89) or v865 == "Auto" and (globals.tickcount % 178 > 89 and -(globals.tickcount % 89) or globals.tickcount % 89) or l_get_ref_2("pitch_offset", v857, v858);
            rage.antiaim:override_hidden_pitch(v866);
            local v867 = nil;
            local function v879(v868, v869, v870, v871)
                -- upvalues: l_core_0 (ref), l_random_float_1 (ref)
                local v872 = l_core_0.get_ref("yaw_random_methods", v870, v871);
                if v872 == "Default" then
                    return l_random_float_1(v868, v868 - v869);
                elseif v872 == "Sinusoidal" then
                    local v873 = l_core_0.get_ref("frequency", v870, v871);
                    local v874 = l_core_0.get_ref("amplitude", v870, v871);
                    return v868 + math.sin(globals.curtime * v873) * v874;
                elseif v872 == "Chaotic" then
                    local v875 = l_core_0.get_ref("r_min", v870, v871);
                    local v876 = l_core_0.get_ref("r_max", v870, v871);
                    local v877 = l_core_0.get_ref("scale", v870, v871);
                    local v878 = globals.curtime * v877;
                    return v868 + l_random_float_1(v875, v876) * math.sin(v878) * math.cos(v878 * 2) * math.sin(v878 * 0.5);
                else
                    return v868;
                end;
            end;
            if v864 == "Sideways" then
                local v880 = v860 and 90 or -90;
                rage.antiaim:override_hidden_yaw_offset(v880);
                v867 = 0;
            elseif v864 == "Random" then
                local v881 = l_normalize_yaw_0(math.random(-180, 180), -180, 180);
                rage.antiaim:override_hidden_yaw_offset(v881);
                v867 = 0;
            elseif v864 == "Spin" then
                local v882 = globals.tickcount * 2 ^ l_get_ref_2("spin_speed", v857, v858) % 360;
                rage.antiaim:override_hidden_yaw_offset(v882);
                v867 = 0;
            elseif v864 == "L - R" then
                local l_v860_0 = v860;
                local v884 = l_get_ref_2("Jitter", v857, v858);
                local v885 = l_get_ref_2("yaw_randomize", v857, v858);
                local v886 = l_get_ref_2("center_options", v857, v858);
                local _ = v886 == "Custom";
                local v888 = l_get_ref_2("yaw_left", v857, v858);
                local v889 = l_get_ref_2("yaw_right", v857, v858);
                if v884 ~= "Center" then
                    local v890 = v886 == "Min - Max" and math.random(l_get_ref_2("center_min", v857, v858), l_get_ref_2("center_max", v857, v858)) or v886 == "Randomize" and l_random_float_1(l_get_ref_2("yaw_jitter_ovr", v857, v858), l_get_ref_2("yaw_jitter_ovr", v857, v858) - l_get_ref_2("jitter_randomize", v857, v858));
                    if v672.is_defensive() then
                        l_core_0.refs.jitter:override(v884);
                        l_core_0.refs.jitter_val:override(v890);
                    end;
                elseif v672.is_defensive() then
                    l_core_0.refs.jitter:override("Disabled");
                    l_core_0.refs.jitter_val:override(0);
                end;
                if l_v860_0 then
                    if v884 == "Center" then
                        v867 = v879(v888, v885, v857, v858);
                    elseif v884 == "3-way" or v884 == "5-way" or v884 == "Spin" then
                        v867 = v879(v888, v885, v857, v858);
                    else
                        v867 = v879(l_get_ref_2("yaw_left", v857, v858), v885, v857, v858);
                    end;
                    if v736 then
                        l_body_yaw_1[3]:override(l_random_int_1(l_get_ref_2("fake_left", v857, v858), l_get_ref_2("fake_left", v857, v858) - l_get_ref_2("fake_left_random", v857, v858)));
                        l_body_yaw_1[4]:override(l_random_int_1(l_get_ref_2("fake_right", v857, v858), l_get_ref_2("fake_right", v857, v858) - l_get_ref_2("fake_right_random", v857, v858)));
                        l_core_0.refs.inverter:override(false);
                    else
                        l_body_yaw_1[3]:override(l_random_int_1(l_get_ref_2("fake_left", v857, v858), l_get_ref_2("fake_left", v857, v858) - l_get_ref_2("fake_left_random", v857, v858)));
                        l_body_yaw_1[4]:override(l_random_int_1(-l_get_ref_2("fake_right", v857, v858), -l_get_ref_2("fake_right", v857, v858) - l_get_ref_2("fake_right_random", v857, v858)));
                        l_core_0.refs.inverter:override(l_core_0.allow_inverter);
                    end;
                else
                    if v884 == "Center" then
                        v867 = v879(v889, v885, v857, v858);
                    elseif v884 == "3-way" or v884 == "5-way" or v884 == "Spin" then
                        v867 = v879(v889, v885, v857, v858);
                    else
                        v867 = v879(l_get_ref_2("yaw_right", v857, v858), v885, v857, v858);
                    end;
                    if v736 then
                        l_body_yaw_1[3]:override(l_random_int_1(l_get_ref_2("fake_left", v857, v858), l_get_ref_2("fake_left", v857, v858) - l_get_ref_2("fake_left_random", v857, v858)));
                        l_body_yaw_1[4]:override(l_random_int_1(l_get_ref_2("fake_right", v857, v858), l_get_ref_2("fake_right", v857, v858) - l_get_ref_2("fake_right_random", v857, v858)));
                    else
                        l_body_yaw_1[3]:override(l_random_int_1(-l_get_ref_2("fake_left", v857, v858), -l_get_ref_2("fake_left", v857, v858) - l_get_ref_2("fake_left_random", v857, v858)));
                        l_body_yaw_1[4]:override(l_random_int_1(l_get_ref_2("fake_right", v857, v858), l_get_ref_2("fake_right", v857, v858) - l_get_ref_2("fake_right_random", v857, v858)));
                    end;
                    l_core_0.refs.inverter:override(false);
                end;
                rage.antiaim:override_hidden_yaw_offset(0);
            end;
            return true, v867;
        end;
    end;
    l_core_0.handle_def = function(v892)
        -- upvalues: v530 (ref), v9 (ref), l_core_0 (ref), v794 (ref), v735 (ref), v55 (ref)
        local v893 = entity.get_local_player();
        if v893 == nil or not v893:is_alive() then
            return;
        else
            local v894 = v530:get_state(v893);
            if v894 == "none" then
                return;
            else
                local v895 = v9.rage.builder_elements[v894];
                local v896 = v893:get_player_weapon(false);
                if not v896 then
                    return;
                else
                    local v897 = v896:get_classname();
                    local v898 = false;
                    local v899 = false;
                    local v900 = {
                        [1] = 1, 
                        [2] = 1, 
                        [3] = 1
                    };
                    if v895.defensive_tickbase:get() == 1 then
                        if v895.tick_random:get() then
                            v900 = {
                                v895.tick_speed1:get(), 
                                v895.tick_speed2:get()
                            };
                        else
                            v900 = {
                                v895.tick_speed1:get()
                            };
                        end;
                        v899 = l_core_0.random_choke(l_core_0.tick_choke, v900, true);
                        l_core_0.refs.def:override("On peek");
                        v892.force_defensive = v899 and not v897:find("Grenade");
                    else
                        for v901, v902 in pairs(v794) do
                            if v9.defensive.defensive_conditions:get(v901) and v894 == v902 then
                                v898 = true;
                                break;
                            end;
                        end;
                    end;
                    local v903 = check_weapon_swap() and v9.defensive.game_events:get(1);
                    if v9.defensive.force_hideshot:get() then
                        l_core_0.refs.hideshot_config:override("Break LC");
                    else
                        l_core_0.refs.hideshot_config:override("Favor Fire Rate");
                    end;
                    if v903 or check_reloading() and v9.defensive.game_events:get(2) then
                        l_core_0.refs.def:override("Always on");
                    elseif v898 then
                        l_core_0.refs.def:override("Always on");
                    elseif v735 then
                        l_core_0.refs.def:override("Disabled");
                    else
                        l_core_0.refs.def:override("On peek");
                    end;
                    if not v897:find("Grenade") then
                        v55:override(true);
                    end;
                    return;
                end;
            end;
        end;
    end;
    events.createmove(l_core_0.handle_def);
    l_core_0.antiaim = function(v904)
        -- upvalues: v530 (ref), l_core_0 (ref), v9 (ref), v793 (ref), v531 (ref), v634 (ref), v794 (ref), v725 (ref), v12 (ref), v724 (ref), l_random_int_1 (ref), v436 (ref), v891 (ref), v672 (ref), v736 (ref), l_get_ref_1 (ref), v730 (ref), l_commandack_1 (ref), v733 (ref), v644 (ref), v734 (ref), v735 (ref), v645 (ref), v635 (ref)
        local v905 = entity.get_local_player();
        if v905 == nil or not v905:is_alive() then
            return;
        else
            local v906 = v530:get_state(v905);
            if v906 == "none" then
                return;
            else
                v530.state = v906;
                l_core_0.refs.yaw:override("Backward");
                local l_team_0 = l_core_0.shared_data.team;
                local v908 = v9.rage.builder_elements[v906];
                local v909 = v9.rage.defensive_elements[v906];
                local v910 = v905:get_player_weapon(false);
                if v910 == nil then
                    return;
                else
                    local v911 = v910:get_classname();
                    local v912 = v9.rage.manual:get();
                    local v913 = entity.get_game_rules();
                    local v914 = 0;
                    local _ = 0;
                    if v793[v912] then
                        l_core_0.apply_manual(v793[v912]);
                    else
                        l_core_0.refs.base:override("At Target");
                        v531.manual_state = 0;
                        if v9.rage.freestanding_bind:get() then
                            l_core_0.refs.freestand_bind:override(not l_core_0.should_disable_freestand(v9.rage.freestanding_bind.freestand_options, v906));
                        else
                            local v916 = l_core_0.should_disable_freestand(v9.rage.freestanding_bind.freestand_enablers, v906);
                            v9.rage.freestanding_bind:override(v916);
                            l_core_0.refs.freestand_bind:override(v916);
                        end;
                    end;
                    if v9.rage.additions:get(1) and v913.m_bWarmupPeriod then
                        l_core_0.refs.fakelag:override(1);
                    elseif v9.rage.additions:get(2) and rage.exploit:get() == 1 then
                        l_core_0.refs.fakelag:override(1);
                    elseif v9.rage.additions:get(3) and rage.exploit:get() == 1 and v634 then
                        l_core_0.refs.fakelag:override(1);
                    else
                        l_core_0.refs.fakelag:override();
                    end;
                    local v917 = false;
                    if v9.rage.hidden_builder:get() then
                        local v918 = v908.def_activation:get();
                        for v919, v920 in pairs(v794) do
                            if v9.rage.hidden_builder.antiaim_conditions:get(v919) and v906 == v920 and (v918 == "Always" or v918 == "Hittable" and entity.get_threat(true) ~= nil) then
                                v917 = true;
                                break;
                            end;
                        end;
                    end;
                    local _ = (not v9.rage.freestanding_bind:get() or not v9.rage.hidden_builder.disablers:get(1)) and (not (v9.rage.manual:get() ~= "At Target") or not v9.rage.hidden_builder.disablers:get(2)) and (not l_core_0.refs.autopeek:get() or not v9.rage.hidden_builder.disablers:get(3));
                    if l_core_0.active_timeout and not v725 then
                        v12.push("anti-brute timed out and was reset", clr);
                    end;
                    v725 = l_core_0.active_timeout;
                    if l_core_0.active_brute and not v724 then
                        local v922 = v908.antibrute_method:get();
                        v12.push(string.format("changed anti-aim due to %s bullet [method:%s]", l_core_0.brute_target, v922), clr);
                    end;
                    v724 = l_core_0.active_brute;
                    if l_core_0.active_brute then
                        local v923 = v908.antibrute_method:get();
                        if v923 == 1 then
                            l_core_0.brute_modifier = 10;
                        elseif v923 == 2 then
                            l_core_0.brute_modifier = l_random_int_1(5, 10);
                        else
                            l_core_0.brute_modifier = -10;
                        end;
                    else
                        l_core_0.brute_modifier = 0;
                    end;
                    local _ = rage.exploit:get() == 1 or v436.hs:get();
                    local v925, v926 = v891(v909, l_team_0, v672.is_defensive(), v634);
                    if v925 then
                        if v736 then
                            l_core_0.refs.body_yaw[5]:override("");
                        else
                            local v927 = l_get_ref_1("speed_options", v909, l_team_0);
                            l_core_0.allow_inverter = v927 ~= "Neverlose";
                            if l_get_ref_1("fake_options", v909, l_team_0) == "Static" then
                                l_core_0.refs.body_yaw[5]:override("");
                            else
                                l_core_0.refs.body_yaw[5]:override(v927 == "Neverlose" and "Jitter" or "off");
                            end;
                        end;
                    elseif v736 then
                        l_core_0.refs.body_yaw[5]:override("");
                    else
                        local v928 = l_get_ref_1("speed_options", v908, l_team_0);
                        l_core_0.allow_inverter = v928 ~= "Neverlose";
                        if l_get_ref_1("fake_options", v908, l_team_0) == "Static" then
                            l_core_0.refs.body_yaw[5]:override("");
                        else
                            l_core_0.refs.body_yaw[5]:override(v928 == "Neverlose" and "Jitter" or "off");
                        end;
                    end;
                    local v929 = l_get_ref_1("center_options", v908, l_team_0);
                    l_core_0.yaw_ovr = v929 == "Min - Max" and l_random_int_1(l_get_ref_1("center_min", v908, l_team_0), l_get_ref_1("center_max", v908, l_team_0)) or v929 == "Randomize" and l_random_int_1(l_get_ref_1("yaw_jitter_ovr", v908, l_team_0), l_get_ref_1("yaw_jitter_ovr", v908, l_team_0) - l_get_ref_1("jitter_randomize", v908, l_team_0)) or 0;
                    local v930 = l_get_ref_1("Jitter", v908, l_team_0) == "Center" and l_core_0.yaw_ovr / 2 or 0;
                    local v931 = l_get_ref_1("yaw_left", v908, l_team_0) + v930;
                    local v932 = l_get_ref_1("yaw_right", v908, l_team_0) - v930;
                    local v933 = l_get_ref_1("yaw_mode", v908, l_team_0);
                    local v934 = 0;
                    if v933 == "L - R" then
                        if not v925 then
                            l_core_0.refs.hidden:override(false);
                            v934 = l_core_0.apply_yaw_settings(v634, v908, l_team_0, v914, v730, v931, v932, v904);
                        else
                            l_core_0.refs.hidden:override(true);
                            v934 = v926;
                        end;
                    elseif v933 == "Automatic" then
                        local v935 = l_get_ref_1("random_speed", v908, l_team_0) and l_random_int_1(l_get_ref_1("ran_speed_1", v908, l_team_0), l_get_ref_1("ran_speed_2", v908, l_team_0)) or l_get_ref_1("body_speed", v908, l_team_0);
                        if l_commandack_1 % v935 == 1 then
                            l_core_0.auto = not l_core_0.auto;
                            v934 = l_core_0.apply_yaw_settings(not l_core_0.auto, v908, l_team_0, v914, v730, v931, v932, v904);
                        end;
                    end;
                    local v936 = l_get_ref_1("custom_speed_amount", v908, l_team_0);
                    local v937 = {};
                    local v938 = l_get_ref_1("random_speed_method", v908, l_team_0) == "Custom";
                    if v938 then
                        for v939 = 1, v936 do
                            local v940 = l_get_ref_1("custom_speed_slider_" .. v939, v908, l_team_0);
                            if v940 then
                                table.insert(v937, v940);
                            end;
                        end;
                        if not v733 or v733 > #v937 then
                            v733 = 1;
                        end;
                    end;
                    if v925 then
                        local v941 = 0;
                        if not l_get_ref_1("random_speed", v909, l_team_0) then
                            v941 = l_get_ref_1("body_speed", v909, l_team_0) or 0;
                        elseif l_get_ref_1("random_speed_method", v909, l_team_0) == "Random" then
                            v941 = l_random_int_1(l_get_ref_1("ran_speed_1", v909, l_team_0) or 0, l_get_ref_1("ran_speed_2", v909, l_team_0) or 0);
                        elseif v938 and #v937 > 0 then
                            v941 = v937[v733] or 0;
                        end;
                        if v941 < v644 then
                            v644 = 0;
                            v634 = not v634;
                            if v938 and #v937 > 0 then
                                v733 = v733 % #v937 + 1;
                            end;
                        end;
                    else
                        local v942 = 0;
                        if not l_get_ref_1("random_speed", v908, l_team_0) then
                            v942 = l_get_ref_1("body_speed", v908, l_team_0) or 0;
                        elseif l_get_ref_1("random_speed_method", v908, l_team_0) == "Random" then
                            v942 = l_random_int_1(l_get_ref_1("ran_speed_1", v908, l_team_0) or 0, l_get_ref_1("ran_speed_2", v908, l_team_0) or 0);
                        elseif v938 and #v937 > 0 then
                            v942 = v937[v733] or 0;
                        end;
                        if rage.exploit:get() == 0 or v9.rage.freestanding_bind:get() then
                            if v644 > 1 then
                                v644 = 0;
                                v634 = not v634;
                                if v938 and #v937 > 0 then
                                    v733 = v733 % #v937 + 1;
                                end;
                            end;
                        elseif v942 < v644 then
                            v644 = 0;
                            v634 = not v634;
                            if v938 and #v937 > 0 then
                                v733 = v733 % #v937 + 1;
                            end;
                        end;
                    end;
                    if v911:find("Grenade") or v911:find("Flashbang") then
                        v734 = globals.tickcount;
                    elseif math.max(v910.m_flNextPrimaryAttack, v905.m_flNextAttack) - globals.tickinterval - globals.curtime < 0 then
                        v735 = true;
                    else
                        v735 = false;
                    end;
                    local l_m_fThrowTime_0 = v910.m_fThrowTime;
                    v735 = v734 + 15 == globals.tickcount or l_m_fThrowTime_0 and l_m_fThrowTime_0 ~= 0;
                    if v925 then
                        if v735 then
                            l_core_0.refs.body_yaw[1]:override(false);
                        elseif speed_option == "Amnesia" then
                            if v645 > l_get_ref_1("amnesia_tick_speed", v909, l_team_0) then
                                v645 = 0;
                                v635 = not v635;
                            end;
                            l_core_0.refs.body_yaw[1]:override(not v635);
                        else
                            l_core_0.refs.body_yaw[1]:override(l_get_ref_1("body_yaw", v909, l_team_0) and true or false);
                        end;
                    elseif v735 then
                        l_core_0.refs.body_yaw[1]:override(false);
                    elseif speed_option == "Amnesia" then
                        if v645 > l_get_ref_1("amnesia_tick_speed", v908, l_team_0) then
                            v645 = 0;
                            v635 = not v635;
                        end;
                        l_core_0.refs.body_yaw[1]:override(not v635);
                    else
                        l_core_0.refs.body_yaw[1]:override(l_get_ref_1("body_yaw", v908, l_team_0) and true or false);
                    end;
                    l_core_0.handle_neverlose_body(v9, v906, v911, v934);
                    return;
                end;
            end;
        end;
    end;
    v12 = {
        show_time = 3, 
        per_notify_offset = 35, 
        prefix_icon = "", 
        base_offset = 100 * l_core_0.dpi_scale.x, 
        anim_speed = l_manager_0.base_speed / 3, 
        list = {}
    };
    local function v959(v944, v945, v946, v947)
        -- upvalues: v12 (ref), v9 (ref), l_core_0 (ref), v60 (ref)
        v945 = math.floor(v945);
        local v948 = v946 * 255;
        v12.prefix_icon = v9.visuals.notifs.notifs_prefix:get() and "pipe" or "triangle-exclamation";
        local v949 = v9.visuals.notifs.notifs_prefix:get() and "luasense  " or "";
        local v950 = render.measure_text(4, nil, v949);
        local v951 = render.measure_text(1, nil, v944);
        local v952 = vector(27, 12);
        local v953 = vector(v950.x + v951.x, math.max(v950.y, v951.y)) + v952;
        local v954 = v9.visuals.notifs.notifs_round_amount:get();
        local v955 = color(23, 23, 23, v948);
        v947 = v947:override("a", v948);
        local v956 = vector(l_core_0.screen_size.x / 2 - v953.x / 2, l_core_0.screen_size.y - v945);
        if v9.visuals.notifs.notifs_glow_amount:get() ~= 0 then
            render.shadow(v956, v956 + v953, v947, v9.visuals.notifs.notifs_glow_amount:get(), 1, v954);
        end;
        render.rect(v956, v956 + v953, v955, v954);
        local v957 = v956 + vector(v952.x / 2, v953.y / 2 - v950.y / 2);
        local v958 = v949 ~= "" and v957 + vector(v950.x, 0) or v956 + vector(v952.x / 2, v953.y / 2 - v951.y / 2);
        if v949 ~= "" then
            render.text(v9.visuals.notifs.notifs_prefix_font:get(), v957, v9.visuals.notifs.notifs_prefix_clr:get():override("a", v948), "l", v9.visuals.notifs.notifs_prefix_font:get() == 2 and v949:upper() or v949);
        end;
        render.text(1, v958, v60.white:override("a", v948), "l", v944);
    end;
    v12.push = function(v960, v961)
        -- upvalues: v12 (ref), l_core_0 (ref), v9 (ref)
        table.insert(v12.list, 1, {
            state = 0, 
            offset = 50, 
            text = l_core_0:with_icon(v12.prefix_icon, v960, v961 or v9.visuals.accent:get()), 
            shows_until = globals.realtime + v12.show_time, 
            color = v961 or v9.visuals.accent:get()
        });
    end;
    do
        local l_v959_0 = v959;
        v12.handle = function()
            -- upvalues: v12 (ref), v65 (ref), l_v959_0 (ref)
            if #v12.list == 0 then
                return;
            else
                local l_base_offset_0 = v12.base_offset;
                local l_realtime_0 = globals.realtime;
                for v965, v966 in pairs(v12.list) do
                    l_base_offset_0 = l_base_offset_0 + v12.per_notify_offset;
                    local l_l_base_offset_0_0 = l_base_offset_0;
                    local v968 = v966.shows_until < l_realtime_0 or v965 > 3;
                    local v969 = v968 and 0 or 1;
                    v12.list[v965].state = v65.lerp(v966.state, v969, v12.anim_speed);
                    v12.list[v965].offset = v65.lerp(v966.offset, l_l_base_offset_0_0, v12.anim_speed);
                    l_v959_0(v966.text, v12.list[v965].offset, v12.list[v965].state, v966.color);
                    if v966.state < 0.01 and v968 then
                        table.remove(v12.list, v965);
                    end;
                end;
                return;
            end;
        end;
    end;
    v11.register("render", "notifications", v12.handle);
    v959 = nil;
    v959 = {
        database = db.luasense_draggable3 or {}, 
        menu = {}, 
        items = {
            [1] = "slowed_down"
        }, 
        drag = {}, 
        current_drugging_item = nil, 
        hovered_something = false, 
        scale_anim = 0, 
        scale_target = 0, 
        scale_velocity = 0
    };
    local v970 = render.measure_text(1, nil, "Max velocity reduced by 100%").x + 3;
    local v971 = l_core_0.screen_size / 2;
    for _, v973 in pairs(v959.items) do
        if v959.database[v973 .. "_pos_x"] == nil then
            v959.database[v973 .. "_pos_x"] = l_core_0.screen_size.x / 2 - v970 / 2;
        end;
        if v959.database[v973 .. "_pos_y"] == nil then
            v959.database[v973 .. "_pos_y"] = l_core_0.screen_size.y / 4;
        end;
        v959.menu[v973] = {
            pos_x = v959.database[v973 .. "_pos_x"], 
            pos_y = v959.database[v973 .. "_pos_y"]
        };
    end;
    v959.adjust = function()
        -- upvalues: l_core_0 (ref), v959 (ref)
        local v974 = vector(2560, 1440);
        local _ = l_core_0.screen_size / v974;
        for _, v977 in pairs(v959.items) do
            v959.database[v977 .. "_pos_x"] = v959.database[v977 .. "_pos_x"];
            v959.database[v977 .. "_pos_x"] = v959.database[v977 .. "_pos_x"];
        end;
    end;
    v959.in_bounds = function(v978, v979)
        local v980 = ui.get_mouse_position();
        return v980.x >= v978.x and v980.x <= v979.x and v980.y >= v978.y and v980.y <= v979.y;
    end;
    v959.drag_handle = function(v981, v982, v983, v984)
        -- upvalues: l_core_0 (ref), v959 (ref), v19 (ref), v65 (ref)
        if not v984 then
            v984 = 0;
        end;
        local v985 = l_core_0.screen_size.x / 2;
        if v959.drag[v983] == nil then
            v959.drag[v983] = {
                is_dragging = false, 
                drag_position = vector(0, 0)
            };
        end;
        local v986 = ui.get_mouse_position();
        local v987 = vector();
        local v988 = v19.ui.getalpha() / 255;
        local _ = v959.scale_target;
        if v988 > 0 then
            v959.scale_target = v988 < 1 and 1.1 or 1;
        else
            v959.scale_target = 0.7;
        end;
        local v990 = 0.1;
        local v991 = 0.7;
        local v992 = globals.frametime * 100;
        local v993 = v959.scale_target - v959.scale_anim;
        v959.scale_velocity = (v959.scale_velocity or 0) * v991 + v993 * v990 * v992;
        v959.scale_anim = v959.scale_anim + v959.scale_velocity;
        if v959.scale_anim < 0.6 then
            v959.scale_anim = 0.6;
        end;
        if v959.scale_anim > 1.2 then
            v959.scale_anim = 1.2;
        end;
        v959.centering = v959.centering or {};
        local v994 = l_core_0.screen_size.x / 2 - v982.x / 2;
        local v995 = v959.database[v983 .. "_pos_x"];
        if v959.in_bounds(v981, v981 + v982) then
            v959.hovered_something = true;
            if common.is_button_down(2) then
                v959.centering[v983] = true;
            end;
        end;
        if v959.centering[v983] then
            v959.database[v983 .. "_pos_x"] = v65.lerp(v995, v994, 0.15);
            if math.abs(v959.database[v983 .. "_pos_x"] - v994) < 0.5 then
                v959.database[v983 .. "_pos_x"] = v994;
                v959.centering[v983] = false;
            end;
        end;
        if v959.in_bounds(v981, v981 + v982) and common.is_button_down(1) and not v959.drag[v983].is_dragging and (v959.current_drugging_item == nil or v959.current_drugging_item == v983) then
            v959.drag[v983].is_dragging = true;
            v959.current_drugging_item = v983;
            v959.drag[v983].drag_position = v981 - v986;
        end;
        if not v959.in_bounds(v987, l_core_0.screen_size) then
            v959.drag[v983].is_dragging = false;
        end;
        if not common.is_button_down(1) then
            v959.drag[v983].is_dragging = false;
            v959.current_drugging_item = nil;
        end;
        if v959.drag[v983].is_dragging and v19.ui.getalpha() > 0 then
            local v996 = l_core_0.screen_size - v982;
            local v997 = math.clamp(v986.x + v959.drag[v983].drag_position.x, 0, v996.x);
            local v998 = math.clamp(v986.y + v959.drag[v983].drag_position.y, 0, v996.y);
            local v999 = 35;
            local v1000 = v997 + v982.x / 2;
            if math.abs(v1000 - v985) < v999 then
                v997 = v985 - v982.x / 2;
            end;
            v959.database[v983 .. "_pos_x"] = v65.lerp(v959.database[v983 .. "_pos_x"], v997, 0.08);
            v959.database[v983 .. "_pos_y"] = v65.lerp(v959.database[v983 .. "_pos_y"], v998, 0.08);
        end;
        local v1001 = v959.scale_anim or 1;
        local v1002 = v981 + v982 / 2;
        local v1003 = v982 * v1001;
        local v1004 = v1002 - v1003 / 2;
        render.rect_outline(v1004 - 6, v1004 + v1003 + 6, color(255, 255, 255, v19.ui.getalpha() * 150 * v984), 1, 4);
        render.line(vector(v985, 2), vector(v985, l_core_0.screen_size.y), color(255, 255, 255, v19.ui.getalpha() * 45 * v984));
        local v1005 = "PRESS \aFFFFFFFFM2\aFFFFFFFF TO CENTER";
        local v1006 = 4;
        local v1007 = render.measure_text(v1006, nil, v1005);
        local v1008 = v1004.x + v1003.x / 2 - v1007.x / 2;
        local v1009 = (v1004 + v1003 + 6).y + 4;
        render.text(v1006, vector(v1008, v1009), color(200, 200, 200, v19.ui.getalpha() * 220 * v984), nil, v1005);
    end;
    v959.adjust();
    events.mouse_input:set(function()
        -- upvalues: v959 (ref), v19 (ref)
        if (v959.hovered_something or v959.current_drugging_item) and v19.ui.getalpha() > 0 then
            return false;
        else
            return;
        end;
    end);
    l_core_0.slowdown_handle = v54.safecall:execute("slowed_down", true, function()
        -- upvalues: l_core_0 (ref), v9 (ref), v19 (ref), l_manager_0 (ref), v959 (ref)
        if not v9.visuals.slowed_down:get() then
            return;
        else
            local v1010 = entity.get_local_player();
            if v1010 == nil or not is_valid_entity(v1010) or not v1010:is_alive() then
                return;
            else
                local v1011 = v19.ui.getalpha();
                local v1012 = v1011 == 1 and 0.5 or v1010.m_flVelocityModifier;
                local v1013 = l_manager_0:new("velocity_modifier", v959.current_drugging_item == "slowed_down" and 100 or v1012 == 1 and 0 or 255);
                if v1013 < 0.03 then
                    return;
                else
                    local v1014 = vector(v959.database.slowed_down_pos_x, v959.database.slowed_down_pos_y);
                    local l_v1014_0 = v1014;
                    local v1016 = v9.visuals.accent:get():alpha_modulate(v1013);
                    local v1017 = "Max velocity reduced by";
                    local v1018 = v19.render.measure_text(1, nil, v1017 .. " 100%");
                    local v1019 = vector(v1018.x + 3, 6);
                    v19.render.text(1, v1014, v19.colors.white:alpha_modulate(v1013), nil, v19.string.format(v1017 .. " %d%%", v1012 * 100));
                    v1014 = v1014 + vector(0, 15);
                    local v1020 = {
                        [1] = v1014 - 1, 
                        [2] = v1014 + v1019 + 1
                    };
                    if v9.visuals.slowed_down.style:get() == 1 then
                        v19.render.rect(v1020[1], v1020[2], v19.colors.black:alpha_modulate(v19.math.min(200, v1013)), 2);
                        v19.render.shadow(v1020[1], v1020[2], v1016, 25, 0, 3);
                        v19.render.rect(v1014 + 1, v1014 + v1019 * vector(v1012, 1) - 1, v1016, 2);
                    elseif v9.visuals.slowed_down.style:get() == 2 then
                        local _ = color(0, 0, 0, 255):alpha_modulate(v1013);
                        v19.render.rect(v1020[1], v1020[2], v19.colors.black:alpha_modulate(v19.math.min(125, v1013)), 2);
                        render.rect_outline(v1020[1], v1020[2], color(25, 25, 25, 255):alpha_modulate(v19.math.min(255, v1013)), 1, 2);
                        v19.render.rect(v1014 + 1, v1014 + v1019 * vector(v1012, 1) - 1, v1016, 2);
                    end;
                    v959.drag_handle(l_v1014_0, v1019 + vector(1, 15), "slowed_down", v1011);
                    return;
                end;
            end;
        end;
    end);
    v11.register("render", "ls_utils.slowdown_handle", l_core_0.slowdown_handle);
    local v1022 = {
        gradient = l_gradient_0.text_animate("S E N S E", -2, {
            color(255, 255, 255), 
            color(91, 91, 91)
        }), 
        desync = l_gradient_0.text_animate(".max", -1, {
            color(255, 255, 255), 
            color(255, 255, 255)
        }), 
        starting_padding = 15
    };
    v970 = l_core_0.screen_size / 2;
    v1022.build_text = function(_, v1024)
        -- upvalues: v1022 (ref), v9 (ref), v32 (ref)
        v1022.gradient:animate();
        local v1025 = "\a" .. (v1024 and v1024 or v9.visuals.accent:get():to_hex()) .. "L U A " .. v1022.gradient:get_animated_text();
        if v32 == "BETA" then
            v1025 = v1025 .. " \aEB6161FF[BETA]";
        end;
        return v1025, (render.measure_text(1, "s", v1025));
    end;
    v1022.build_desync_max = function(_, v1027)
        -- upvalues: v1022 (ref), v9 (ref)
        v1022.gradient:animate();
        local v1028 = "\a" .. (v1027 and v1027 or v9.visuals.accent:get():to_hex()) .. "luasync" .. v1022.desync:get_animated_text();
        return v1028, (render.measure_text(1, "s", v1028));
    end;
    do
        local l_v970_0, l_v971_0 = v970, v971;
        l_v971_0 = function(v1031, v1032)
            -- upvalues: l_v970_0 (ref), l_core_0 (ref), v1022 (ref)
            local v1033 = vector(0, 0);
            if v1032 == "Bottom" then
                v1033 = vector(l_v970_0.x - v1031.x / 2, l_core_0.screen_center.y * 2 - v1022.starting_padding);
            elseif v1032 == "Left" then
                v1033 = vector(v1022.starting_padding, l_core_0.screen_center.y);
            elseif v1032 == "Right" then
                v1033 = vector(l_core_0.screen_size.x - v1031.x - v1022.starting_padding, l_core_0.screen_center.y);
            elseif v1032 == "perm" then
                v1033 = vector(l_v970_0.x - 20, l_core_0.screen_center.y - l_core_0.screen_center.y + 15);
            else
                v1033 = vector(l_v970_0.x - v1031.x / 2, l_core_0.screen_center.y * 2 - v1022.starting_padding);
            end;
            return v1033 + v1031;
        end;
        v1022.render = v54.safecall:execute("watermark_render", true, function()
            -- upvalues: v9 (ref), v1022 (ref), l_v970_0 (ref), l_v971_0 (ref), l_core_0 (ref)
            if not globals.is_in_game then
                return;
            else
                local l_status_1, l_result_1 = pcall(function()
                    -- upvalues: v9 (ref), v1022 (ref), l_v970_0 (ref), l_v971_0 (ref), l_core_0 (ref)
                    local v1034 = v9.visuals.watermark:get();
                    local v1035 = v9.visuals.watermark_style:get();
                    local v1036 = nil;
                    local v1037 = nil;
                    if v1035 == 1 then
                        local v1038, v1039 = v1022.build_text();
                        v1037 = v1039;
                        v1036 = v1038;
                        if not v1036 or not v1037 then
                            return;
                        end;
                    elseif v1035 == 2 then
                        v1036 = "LUASENSE";
                        v1037 = render.measure_text(1, "s", v1036 .. "  ");
                    elseif v1035 == 3 then
                        local v1040, v1041 = v1022.build_desync_max();
                        v1037 = v1041;
                        v1036 = v1040;
                        if not v1036 or not v1037 then
                            return;
                        end;
                    end;
                    if not l_v970_0 then
                        return;
                    else
                        local v1042 = l_v971_0(v1037, v1034);
                        local _ = l_v971_0(v1037, "perm");
                        if v1035 == 1 then
                            render.text(1, v1042 - v1037, color(255), "s", v1036);
                        elseif v1035 == 2 then
                            render.text(1, v1042 - v1037, color(255), "s", l_core_0:with_icon("star", v1036, v9.visuals.accent:get():to_hex()));
                        elseif v1035 == 3 then
                            render.text(1, v1042 - v1037, color(255), "s", v1036);
                        end;
                        return;
                    end;
                end);
                if not l_status_1 then
                    print("Rendering error:", l_result_1);
                end;
                return;
            end;
        end);
    end;
    v11.register("render", "watermark.render", v1022.render);
    events.createmove(function(...)
        -- upvalues: l_core_0 (ref)
        local v1046 = entity.get_local_player();
        if v1046 == nil or not v1046:is_alive() then
            return;
        else
            l_core_0.antiaim(...);
            return;
        end;
    end);
    v970 = render.world_to_screen;
    v971 = render.rect;
    local l_screen_size_0 = render.screen_size;
    local _ = ui.find;
    local v1049 = 0.5;
    local v1050 = 1;
    local v1051 = {};
    local function v1060()
        -- upvalues: v9 (ref), v1051 (ref), v1049 (ref), v970 (ref), l_screen_size_0 (ref), v971 (ref)
        if not v9.visuals.kibit_hitmark:get() then
            return;
        else
            for v1052, v1053 in pairs(v1051) do
                if v1053.FadeTime <= 0 then
                    v1051[v1052] = nil;
                else
                    v1053.WaitTime = v1053.WaitTime - globals.frametime;
                    if v1053.WaitTime <= 0 then
                        v1053.FadeTime = v1053.FadeTime - 1 / v1049 * globals.frametime;
                    end;
                    if v1053.Position.x ~= nil and v1053.Position.y ~= nil and v1053.Position.z ~= nil then
                        local v1054 = v970(vector(v1053.Position.x, v1053.Position.y, v1053.Position.z));
                        if v1054 ~= nil then
                            local l_x_2 = v1054.x;
                            local l_y_1 = v1054.y;
                            local v1057 = l_screen_size_0();
                            local v1058 = v9.visuals.kibit_hitmark.kibit_hitmark_color:get();
                            local v1059 = v1058:override("a", v1058.a * v1053.FadeTime);
                            v971(vector(l_x_2 - 1 / v1057.x * v1057.x, l_y_1 - 5 / v1057.y * v1057.y), vector(l_x_2 + 1 / v1057.x * v1057.x, l_y_1 + 5 / v1057.y * v1057.y), v1059, 0, true);
                            v971(vector(l_x_2 - 5 / v1057.x * v1057.x, l_y_1 - 1 / v1057.y * v1057.y), vector(l_x_2 + 5 / v1057.x * v1057.x, l_y_1 + 1 / v1057.y * v1057.y), v1059, 0, true);
                        end;
                    end;
                end;
            end;
            return;
        end;
    end;
    v11.register("render", "paint_kibit", v1060);
    local function v1062(v1061)
        -- upvalues: v1051 (ref), v1050 (ref)
        v1051[v1061.id] = {
            FadeTime = 1, 
            Position = v1061.aim, 
            WaitTime = v1050, 
            Reason = v1061.state
        };
    end;
    local v1063 = {
        reason_redirect = {
            ["prediction error"] = "pred. error"
        }, 
        last_tick_triggered = 0
    };
       v1063.aim_ack = function(v1064)
    -- upvalues: v1062 (ref), v9 (ref), v1063 (ref), l_core_0 (ref), v12 (ref)
    v1062(v1064);

    if not v9.misc.log_event:get(1) and not v9.visuals.notifs:get() then 
        return 
    end

    local target = v1064.target
    if target == nil then return end
    local success, name = pcall(function() return target:get_name() end)
    if not success then return end

    local v1066 = v1063.reason_redirect[v1064.state] or v1064.state;
    local v1067 = name;
    local l_m_iHealth_1 = target.m_iHealth;
    local l_spread_0 = v1064.spread;
    local l_backtrack_0 = v1064.backtrack;
    local l_hitchance_0 = v1064.hitchance;
    local l_damage_0 = v1064.damage;
    local l_wanted_damage_0 = v1064.wanted_damage;
    local v1074 = l_core_0.hitgroups[v1064.hitgroup] or "?";
    local v1075 = l_core_0.hitgroups[v1064.wanted_hitgroup] or "?";
    local v1076 = v9.visuals.accent:get():to_hex();

    if v1066 == nil then
        local v1077 = string.format("\a%sRegistered \aFFFFFFFFshot at %s's %s for \a%s%d(%d) \aFFFFFFFFdamage (hp: \a%s%d\aFFFFFFFF) (aimed: \a%s%s\aFFFFFFFF) (bt: \a%s%s\aFFFFFFFF) (spread: \a%s%.1f\194\176\aFFFFFFFF)", v1076, v1067, v1074, v1076, l_damage_0, l_wanted_damage_0, v1076, l_m_iHealth_1, v1076, v1075, v1076, l_backtrack_0, v1076, l_spread_0);
        l_core_0:branded_printing(v1077);
        return;
    else
        local v1078 = string.format("\a%sMissed \aFFFFFFFFshot at %s's %s due to \a%s%s \aFFFFFFFF(hc: \a%s%d%%\aFFFFFFFF) (damage: \a%s%d\aFFFFFFFF) (bt: \a%s%s\aFFFFFFFF)", v1076, v1067, v1075, v1076, v1066, v1076, l_hitchance_0, v1076, l_wanted_damage_0, v1076, l_backtrack_0);
        local v1079 = string.format("\a%sMissed \aFFFFFFFFshot at \a%s%s\aFFFFFFFF's %s due to \a%s%s\aFFFFFFFF(%d%%) [damage: \a%s%d \aFFFFFFFF bt: \a%s%s\aFFFFFFFF", v1076, v1067, v1076, v1075, v1076, v1066, l_hitchance_0, v1076, l_wanted_damage_0, v1076, l_backtrack_0);
        
        if l_spread_0 ~= nil then
            v1078 = string.format("%s (spread: \a%s%.1f\194\176\aFFFFFFFF)", v1078, v1076, l_spread_0);
        end;

        l_core_0:branded_printing(v1078);

        if v9.visuals.notifs:get() then
            local miss_color = v9.visuals.notifs.notifs_miss_clr:get();
            local miss_hex = "\a" .. miss_color:to_hex();
            v12.push(string.format("Missed %s%s\aFFFFFFFF's %s%s\aFFFFFFFF due to %s%s\aFFFFFFFF!", miss_hex, v1067, miss_hex, v1075, miss_hex, v1066), miss_color);
        end;
        return;
    end;
end;
    v12.hurt = function(v1080)
        -- upvalues: v19 (ref), v9 (ref), v12 (ref)
        local v1081 = entity.get_local_player();
        local v1082 = v19.entity.get(v1080.userid, true);
        local v1083 = v19.entity.get(v1080.attacker, true);
        if v1081 == nil or v1082 == nil or v1083 == nil then
            return;
        elseif not is_valid_entity(v1081) or not is_valid_entity(v1082) or not is_valid_entity(v1083) then
            return;
        elseif v1082 == v1081 or v1083 ~= v1081 then
            return;
        else
            local v1084 = v19.weapon_actions[v1080.weapon] or "Hit";
            local v1085 = v19.hitgroups[v1080.hitgroup] or "?";
            local v1086 = v9.visuals.notifs.notifs_hit_clr:get();
            local v1087 = v19.string_ops.to_hex(v1086);
            v12.push(v19.string.format("%s \a%s%s\aFFFFFFFF's \a%s%s \aFFFFFFFFfor \a%s%s\aFFFFFFFF!", v1084, v1087, v19.entity_methods.get_name(v1082), v1087, v1085, v1087, v1080.dmg_health), v1086);
            return;
        end;
    end;
    v1063.handle_hurt = function(v1088)
        -- upvalues: v19 (ref), l_core_0 (ref), v9 (ref)
        local v1089 = entity.get_local_player();
        local v1090 = v19.entity.get(v1088.userid, true);
        local v1091 = v19.entity.get(v1088.attacker, true);
        if v1089 == nil or v1090 == nil or v1091 == nil then
            return;
        elseif not is_valid_entity(v1089) or not is_valid_entity(v1090) or not is_valid_entity(v1091) then
            return;
        elseif v1090 == v1089 or v1091 ~= v1089 then
            return;
        else
            local v1092 = l_core_0.wpn2act[v1088.weapon];
            if v1092 == nil then
                return;
            else
                local v1093 = v9.visuals.accent:get():to_hex();
                local v1094 = v19.entity_methods.get_name(v1090);
                local v1095 = v19.string.format("%s \a%s%s \aFFFFFFFFfor \a%s%d \aFFFFFFFFdamage (%d health remaining)", v1092, v1093, v1094:lower(), v1093, v1088.dmg_health, v1088.health);
                l_core_0:branded_printing(v1095);
                return;
            end;
        end;
    end;
    v1063.handle_purchase = function(v1096)
        -- upvalues: v9 (ref), v19 (ref), l_core_0 (ref)
        if not v9.misc.log_event:get(2) then
            return;
        else
            local v1097 = v19.entity.get(v1096.userid, true);
            if v1097 == nil or not is_valid_entity(v1097) or not v19.entity_methods.is_enemy(v1097) then
                return;
            else
                local l_weapon_0 = v1096.weapon;
                if l_weapon_0 == "weapon_unknown" then
                    return;
                else
                    local v1099 = v19.entity_methods.get_name(v1097);
                    local v1100 = v9.visuals.accent:get():to_hex();
                    local v1101 = v19.string.format("\a%s%s \aFFFFFFFFbought \a%s%s", v1100, v19.string.lower(v1099), v1100, l_weapon_0);
                    l_core_0:branded_printing(v1101);
                    return;
                end;
            end;
        end;
    end;
    v1063.player_hurt = function(v1102)
        -- upvalues: v9 (ref), v1063 (ref), v12 (ref)
        if v9.misc.log_event:get(1) then
            v1063.handle_hurt(v1102);
        end;
        if v9.visuals.notifs:get() then
            v12.hurt(v1102);
        end;
    end;
    v11.register("item_purchase", "hitlogs.handle_purchase", v1063.handle_purchase);
    v11.register("aim_ack", "hitlogs.aim_ack", v1063.aim_ack);
    v11.register("player_hurt", "hitlogs.player_hurt", v1063.player_hurt);
    v11.register("shutdown", "draggables_shut", function()
        -- upvalues: v959 (ref)
        db.luasense_draggable2 = v959.database;
    end);
    events.createmove:set(v54.safecall:execute("ls_utils.collect_render_shared_info", true, function()
        -- upvalues: v54 (ref)
        v54.shared:collect_render_info();
    end));
    events.createmove:set(v54.safecall:execute("ls_utils.collect", true, function()
        -- upvalues: v54 (ref)
        v54.shared:collect();
    end));
    events.round_end:set(function()
        -- upvalues: l_core_0 (ref)
        l_core_0.brute_modifier = 0;
        l_core_0.brute_modifier_ct = 0;
        l_core_0.active_brute = false;
        l_core_0.round_end = true;
    end);
    events.round_start:set(function()
        -- upvalues: l_core_0 (ref)
        l_core_0.round_end = false;
        l_core_0.freezetime = true;
    end);
    events.round_freeze_end:set(function()
        -- upvalues: l_core_0 (ref)
        l_core_0.freezetime = false;
    end);
    events.render:set(function()
        -- upvalues: v432 (ref), v437 (ref), v9 (ref), v438 (ref), v529 (ref), v19 (ref), l_core_0 (ref)
        v432.handle();
        v432.spectators();
        v437:visibility(v9.visuals.gs_inds:get());
        v438:visibility(v9.visuals.gs_inds:get());
        v529.draw();
        if v19.ui.getalpha() > 0 then
            v9.visibility_handler();
        end;
        l_core_0.handle_aspect();
    end);
    events.render:set(function()
        -- upvalues: v19 (ref), l_gradient_0 (ref), l_pui_0 (ref), l_core_0 (ref)
        if l_core_0.loading_screen_render then
            l_core_0.loading_screen_render();
        end;
        if v19.ui.getalpha() > 0 then
            local v1103 = v19.ui.get_style("Link Active");
            local v1104 = l_gradient_0.text_animate("LuaSense", -1, {
                [1] = v1103, 
                [2] = v19.colors.white
            });
            l_pui_0.sidebar(v1104:get_animated_text(), "hand-sparkles");
            v1104:animate();
        end;
    end);
    events.bomb_defused:set(function(_)
        -- upvalues: v433 (ref)
        v433.reset_bomb();
    end);
    events.bomb_planted:set(function(_)
        -- upvalues: v433 (ref)
        v433.reset_bomb();
    end);
    events.bomb_abortplant:set(function(_)
        -- upvalues: v433 (ref)
        v433.reset_bomb();
    end);
    events.round_prestart:set(function(_)
        -- upvalues: v433 (ref)
        v433.reset_bomb();
    end);
    events.bomb_beginplant:set(function(v1109)
        -- upvalues: v433 (ref)
        v433.bomb_beginplant(v1109);
    end);
    l_core_0.clantag:run();
    l_pui_0.setup(v9);
    
    do
        local loading_config = {
            image_url = "https://i.imgur.com/2EOkXMU.png",
            image_path = "nl/LuaSense/logo.png",
            image_size = vector(300, 300),
            duration = 3.5,
            text = "\aFFFFFFFFLuaSense \a71A1F2FFfixed by 2k00 & E0n3x",
            text_offset_x = -22,
            overlay_alpha = 0.8
        };
        
        local loading_effect = {
            start_time = globals.realtime,
            duration = loading_config.duration,
            alpha = 0,
            image = nil,
            image_loaded = false
        };
        
        do
            local ffi = require("ffi");
            ffi.cdef[[
                void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);
                bool DeleteUrlCacheEntryA(const char* lpszUrlName);
            ]];
            local urlmon = ffi.load("UrlMon");
            local wininet = ffi.load("WinInet");
            local function download_file(url, path)
                wininet.DeleteUrlCacheEntryA(url);
                urlmon.URLDownloadToFileA(nil, url, path, 0, 0);
            end;
            pcall(function()
                files.create_folder("nl/LuaSense/");
                if not files.read(loading_config.image_path) then
                    download_file(loading_config.image_url, loading_config.image_path);
                end;
                local status, img = pcall(function() return render.load_image_from_file(loading_config.image_path, loading_config.image_size) end);
                if status and img then
                    loading_effect.image = img;
                    loading_effect.image_loaded = true;
                end;
            end);
        end;
        
        local function utility_lerp(a, b, t)
            return a + (b - a) * t;
        end;
        
        local loading_render_callback = function()
            if loading_effect then
                local elapsed = globals.realtime - loading_effect.start_time;
                if elapsed < loading_effect.duration then
                    local screen = render.screen_size();
                    local progress = elapsed / loading_effect.duration;
                    if progress < 0.25 then
                        loading_effect.alpha = utility_lerp(loading_effect.alpha, 255, 12 * globals.frametime);
                    elseif progress > 0.75 then
                        loading_effect.alpha = utility_lerp(loading_effect.alpha, 0, 12 * globals.frametime);
                    else
                        loading_effect.alpha = 255;
                    end;
                    if loading_effect.alpha > 1 then
                        render.rect(vector(0, 0), screen, color(0, 0, 0, loading_effect.alpha * loading_config.overlay_alpha), 0, true);
                        local center_y = screen.y / 2;
                        if loading_effect.image and loading_effect.image_loaded then
                            local img_pos = vector(screen.x / 2 - loading_config.image_size.x / 2, center_y - loading_config.image_size.y / 2 - 50);
                            render.texture(loading_effect.image, img_pos, loading_config.image_size, color(255, 255, 255, loading_effect.alpha));
                            render.text(4, vector(screen.x / 2 + loading_config.text_offset_x, center_y + loading_config.image_size.y / 2 + 30), color(255, 255, 255, loading_effect.alpha), "c", loading_config.text);
                        else
                            render.text(4, vector(screen.x / 2, center_y - 20), color(255, 255, 255, loading_effect.alpha), "c", "\aFFFFFFFFLuaSense");
                            render.text(4, vector(screen.x / 2, center_y + 20), color(255, 255, 255, loading_effect.alpha), "c", "\aFFFFFFFFFixed by \aFF6B9DFF2k00 & E0n3x");
                        end;
                    end;
                else
                    loading_effect = nil;
                end;
            end;
        end;
        
        -- Store reference to the loading screen callback for use in render
        l_core_0.loading_screen_render = loading_render_callback;
    end;
    
    return;
end;