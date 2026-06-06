--fix made by 2k00 & E0n3x enjoy godmodki

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

    ["neverlose/memory"] = function(require)
        local memory = { procId = 0 }
ffi.cdef[[
    typedef unsigned long ULONG_PTR;
    typedef long LONG;
    typedef uint32_t DWORD;
    typedef void* HANDLE;
    typedef void* HMODULE;
    typedef void* LPVOID;
    typedef const void* LPCVOID;
    typedef unsigned char BYTE;
    typedef bool BOOL;
    typedef size_t SIZE_T;

    typedef enum {
        TH32CS_SNAPPROCESS = 0x00000002,
        TH32CS_SNAPMODULE = 0x00000008,
        TH32CS_SNAPMODULE32 = 0x00000010
    } SnapshotFlags;

    typedef enum {
        INVALID_HANDLE_VALUE = -1
    }  HandleValues;

    typedef enum {
        PROCESS_VM_READ = 0x0010,
        PROCESS_VM_WRITE = 0x0020,
        PROCESS_VM_OPERATION = 0x0008,
        PROCESS_ALL_ACCESS = PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION ,
        PROCESS_QUERY_INFORMATION = 0x0400
    } ProcessAccessRights;

    typedef enum {
        MAX_PATH = 260,
        MAX_MODULE_NAME32 = 255
    } MaxPath;

    typedef struct _MODULEENTRY32 {
        DWORD   dwSize;
        DWORD   th32ModuleID;
        DWORD   th32ProcessID;
        DWORD   GlblcntUsage;
        DWORD   ProccntUsage;
        BYTE  * modBaseAddr;
        DWORD   modBaseSize;
        HMODULE hModule;
        char   szModule[MAX_MODULE_NAME32 + 1];
        char   szExePath[MAX_PATH];
    } MODULEENTRY32, *PMODULEENTRY32 , *LPMODULEENTRY32;

    typedef struct _PROCESSENTRY32 {
        DWORD   dwSize;
        DWORD   cntUsage;
        DWORD   th32ProcessID;
        ULONG_PTR th32DefaultHeapID;
        DWORD   th32ModuleID;
        DWORD   cntThreads;
        DWORD   th32ParentProcessID;
        LONG    pcPriClassBase;
        DWORD   dwFlags;
        char    szExeFile[MAX_PATH];
    } PROCESSENTRY32, *PPROCESSENTRY32;

    HANDLE CreateToolhelp32Snapshot(DWORD dwFlags, DWORD th32ProcessID);
    BOOL Module32First(HANDLE hSnapshot, LPMODULEENTRY32 lpme);
    BOOL Module32Next(HANDLE hSnapshot, LPMODULEENTRY32 lpme);
    BOOL Process32First(HANDLE hSnapshot, PROCESSENTRY32 *lppe);
    BOOL Process32Next(HANDLE hSnapshot, PROCESSENTRY32 *lppe);
    HANDLE OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId);
    BOOL ReadProcessMemory(HANDLE hProcess, LPCVOID lpBaseAddress, LPVOID lpBuffer, SIZE_T nSize, SIZE_T* lpNumberOfBytesRead);
    BOOL WriteProcessMemory(HANDLE hProcess, LPVOID lpBaseAddress, LPCVOID lpBuffer, SIZE_T nSize, SIZE_T *lpNumberOfBytesWritten);
    void CloseHandle(HANDLE hObject);
]]
local kernel32 = ffi.load("kernel32")

function memory:getProcSnapshot()
    local hSnap = kernel32.CreateToolhelp32Snapshot(ffi.C.TH32CS_SNAPPROCESS, 0)

    if ffi.cast("HANDLE", hSnap) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] CreateToolhelp32Snapshot failed")
        return ffi.C.INVALID_HANDLE_VALUE
    end

    return hSnap
end

function memory:getHandle( print )
    if memory.procId == 0 then
        print_raw("[MEMORY] getHandle: procId is nil")
        return nil
    end

    local hProc = kernel32.OpenProcess(ffi.C.PROCESS_ALL_ACCESS, false, memory.procId)

    if ffi.cast("HANDLE", hProc) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] OpenProcess failed")
        return ffi.C.INVALID_HANDLE_VALUE
    end

    if print then
        print_raw("[MEMORY] Successfully opened handle")
    end

    return hProc

end


function memory:dumpModules()
    
    local hSnap = kernel32.CreateToolhelp32Snapshot(ffi.C.TH32CS_SNAPMODULE + ffi.C.TH32CS_SNAPMODULE32, memory.procId)

    if ffi.cast("HANDLE", hSnap) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] CreateToolhelp32Snapshot failed")
    end

    local modBaseAddr = ffi.new("uintptr_t[1]")
    modBaseAddr[0] = 0

    local modEntry = ffi.new("MODULEENTRY32")
    modEntry.dwSize = ffi.sizeof("MODULEENTRY32")

    if kernel32.Module32First(hSnap, modEntry) then
        repeat
            modBaseAddr[0] = ffi.cast("uintptr_t", modEntry.modBaseAddr)
            print_raw(string.format("[MEMORY] Module: %s, Base: 0x%X, Size: 0x%X", ffi.string(modEntry.szModule), modBaseAddr[0], modEntry.modBaseSize))
        until not kernel32.Module32Next(hSnap, modEntry)
    end

    kernel32.CloseHandle(hSnap)

end

function memory:GetModuleBaseAddress( modName )

    local hSnap = kernel32.CreateToolhelp32Snapshot(ffi.C.TH32CS_SNAPMODULE + ffi.C.TH32CS_SNAPMODULE32, memory.procId)

    if ffi.cast("HANDLE", hSnap) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] CreateToolhelp32Snapshot failed")
        return ffi.C.INVALID_HANDLE_VALUE
    end

    local modBaseAddr = ffi.new("uintptr_t[1]")
    local modEntry = ffi.new("MODULEENTRY32")
    modEntry.dwSize = ffi.sizeof("MODULEENTRY32")
    modBaseAddr[0] = -1

    if kernel32.Module32First(hSnap, modEntry) then
        repeat
            if ffi.string(modEntry.szModule) == modName then
                modBaseAddr[0] = ffi.cast("uintptr_t", modEntry.modBaseAddr)
                break
            end
        until not kernel32.Module32Next(hSnap, modEntry)
    end

    kernel32.CloseHandle(hSnap)
    return modBaseAddr[0]
end

function memory:findProcID( processname )
    local hProcessSnap = kernel32.CreateToolhelp32Snapshot(ffi.C.TH32CS_SNAPPROCESS, 0)
    if ffi.cast("HANDLE", hProcessSnap) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        return ffi.C.INVALID_HANDLE_VALUE
    end

    local pe32 = ffi.new("PROCESSENTRY32")
    pe32.dwSize = ffi.sizeof("PROCESSENTRY32")

    if not kernel32.Process32First(hProcessSnap, pe32) then
        kernel32.CloseHandle(hProcessSnap)
        return ffi.C.INVALID_HANDLE_VALUE
    end

    local result = 0

    repeat
        if processname == ffi.string(pe32.szExeFile) then
            result = pe32.th32ProcessID
            break
        end
    until not kernel32.Process32Next(hProcessSnap, pe32)

    kernel32.CloseHandle(hProcessSnap)

    return result
    
end

function memory:read( address, valueType )

    local hProc = memory:getHandle()

    if ffi.cast("HANDLE", hProc) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] OpenProcess failed")
        return false
    end

    local value = ffi.new(valueType .. "[1]")
    local bytesRead = ffi.new("SIZE_T[1]")
    bytesRead[0] = 0

    if not kernel32.ReadProcessMemory(hProc, ffi.cast("LPCVOID", address), value, ffi.sizeof(valueType), bytesRead) then
        print_raw("[MEMORY] ReadProcessMemory failed")
        return false
    end

    kernel32.CloseHandle(hProc)

    return value[0]
end


function memory:write( address, value, valueType)

    if memory.procId == 0 or address == nil or value == nil or valueType == nil or valueType == "" then
        print_raw("[MEMORY] WriteProcessMemory failed")
        return false
    end

    local hProc = memory:getHandle(procId)

    if ffi.cast("HANDLE", hProc) == ffi.cast("HANDLE", ffi.C.INVALID_HANDLE_VALUE) then
        print_raw("[MEMORY] OpenProcess failed")
        return false
    end

    local buffer = ffi.new(valueType .. "[1]")
    buffer[0] = value

    local bytesWritten = ffi.new("SIZE_T[1]")
    bytesWritten[0] = 0

    if not kernel32.WriteProcessMemory(hProc, ffi.cast("LPVOID", address), ffi.cast("LPVOID", buffer), ffi.sizeof(valueType), bytesWritten) then
        print_raw("[MEMORY] WriteProcessMemory failed")
        return false
    end

    kernel32.CloseHandle(hProc)

    return true
end

function memory:GetDMAAddr( baseAddr, offsets)

    if memory.procId == 0 or baseAddr == nil or offsets == nil then
        print_raw("[MEMORY] GetDMAAddr failed")
        return false
    end
    

    local dmaAddr = ffi.cast("uintptr_t", baseAddr)

    for i = 1, #offsets do
        local value = memory:read(dmaAddr, "uintptr_t")
        dmaAddr = value + offsets[i]
    end

    return dmaAddr
end

function memory:new(name)

    memory.procId = memory:findProcID(name)

    if memory.procId == 0 then
        print_raw("[MEMORY] Failed to find process ID")
        return -1
    end
    
end

return memory
end,
    

        ["neverlose/inspect"] = function(require)
local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local math = _tl_compat and _tl_compat.math or math; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local type = type
local inspect = { Options = {} }

















inspect._VERSION = 'inspect.lua 3.1.0'
inspect._URL = 'http://github.com/kikito/inspect.lua'
inspect._DESCRIPTION = 'human-readable representations of tables'
inspect._LICENSE = [[
  MIT LICENSE

  Copyright (c) 2022 Enrique García Cota

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
inspect.KEY = setmetatable({}, { __tostring = function() return 'inspect.KEY' end })
inspect.METATABLE = setmetatable({}, { __tostring = function() return 'inspect.METATABLE' end })

local tostring = tostring
local rep = string.rep
local match = string.match
local char = string.char
local gsub = string.gsub
local fmt = string.format


local sbavailable, stringbuffer = pcall(require, "string.buffer")
local buffnew
local puts
local render

if sbavailable then
   buffnew = stringbuffer.new
   puts = function(buf, str)
      buf:put(str)
   end
   render = function(buf)
      return buf:get()
   end
else
   buffnew = function()
      return { n = 0 }
   end
   puts = function(buf, str)
      buf.n = buf.n + 1
      buf[buf.n] = str
   end
   render = function(buf)
      return table.concat(buf)
   end
end

local _rawget
if rawget then
   _rawget = rawget
else
   _rawget = function(t, k) return t[k] end
end

local function rawpairs(t)
   return next, t, nil
end



local function smartQuote(str)
   if match(str, '"') and not match(str, "'") then
      return "'" .. str .. "'"
   end
   return '"' .. gsub(str, '"', '\\"') .. '"'
end


local shortControlCharEscapes = {
   ["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n",
   ["\r"] = "\\r", ["\t"] = "\\t", ["\v"] = "\\v", ["\127"] = "\\127",
}
local longControlCharEscapes = { ["\127"] = "\127" }
for i = 0, 31 do
   local ch = char(i)
   if not shortControlCharEscapes[ch] then
      shortControlCharEscapes[ch] = "\\" .. i
      longControlCharEscapes[ch] = fmt("\\%03d", i)
   end
end

local function escape(str)
   return (gsub(gsub(gsub(str, "\\", "\\\\"),
   "(%c)%f[0-9]", longControlCharEscapes),
   "%c", shortControlCharEscapes))
end

local luaKeywords = {}
for k in ([[ and break do else elseif end false for function goto if
             in local nil not or repeat return then true until while
]]):gmatch('%w+') do
   luaKeywords[k] = true
end

local function isIdentifier(str)
   return type(str) == "string" and
   not not str:match("^[_%a][_%a%d]*$") and
   not luaKeywords[str]
end

local flr = math.floor
local function isSequenceKey(k, sequenceLength)
   return type(k) == "number" and
   flr(k) == k and
   1 <= (k) and
   k <= sequenceLength
end

local defaultTypeOrders = {
   ['number'] = 1, ['boolean'] = 2, ['string'] = 3, ['table'] = 4,
   ['function'] = 5, ['userdata'] = 6, ['thread'] = 7,
}

local function sortKeys(a, b)
   local ta, tb = type(a), type(b)


   if ta == tb and (ta == 'string' or ta == 'number') then
      return (a) < (b)
   end

   local dta = defaultTypeOrders[ta] or 100
   local dtb = defaultTypeOrders[tb] or 100


   return dta == dtb and ta < tb or dta < dtb
end

local function getKeys(t)

   local seqLen = 1
   while _rawget(t, seqLen) ~= nil do
      seqLen = seqLen + 1
   end
   seqLen = seqLen - 1

   local keys, keysLen = {}, 0
   for k in rawpairs(t) do
      if not isSequenceKey(k, seqLen) then
         keysLen = keysLen + 1
         keys[keysLen] = k
      end
   end
   table.sort(keys, sortKeys)
   return keys, keysLen, seqLen
end

local function countCycles(x, cycles, depth)
   if type(x) == "table" then
      if cycles[x] then
         cycles[x] = cycles[x] + 1
      else
         cycles[x] = 1
         if depth > 0 then
            for k, v in rawpairs(x) do
               countCycles(k, cycles, depth - 1)
               countCycles(v, cycles, depth - 1)
            end
            countCycles(getmetatable(x), cycles, depth - 1)
         end
      end
   end
end

local function makePath(path, a, b)
   local newPath = {}
   local len = #path
   for i = 1, len do newPath[i] = path[i] end

   newPath[len + 1] = a
   newPath[len + 2] = b

   return newPath
end


local function processRecursive(process,
   item,
   path,
   visited)
   if item == nil then return nil end
   if visited[item] then return visited[item] end

   local processed = process(item, path)
   if type(processed) == "table" then
      local processedCopy = {}
      visited[item] = processedCopy
      local processedKey

      for k, v in rawpairs(processed) do
         processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY), visited)
         if processedKey ~= nil then
            processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey), visited)
         end
      end

      local mt = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE), visited)
      if type(mt) ~= 'table' then mt = nil end
      setmetatable(processedCopy, mt)
      processed = processedCopy
   end
   return processed
end



local Inspector = {}










local Inspector_mt = { __index = Inspector }

local function tabify(inspector)
   puts(inspector.buf, inspector.newline .. rep(inspector.indent, inspector.level))
end

function Inspector:getId(v)
   local id = self.ids[v]
   local ids = self.ids
   if not id then
      local tv = type(v)
      id = (ids[tv] or 0) + 1
      ids[v], ids[tv] = id, id
   end
   return tostring(id)
end

function Inspector:putValue(v)
   local buf = self.buf
   local tv = type(v)
   if tv == 'string' then
      puts(buf, smartQuote(escape(v)))
   elseif tv == 'number' or tv == 'boolean' or tv == 'nil' or
      tv == 'cdata' or tv == 'ctype' then
      puts(buf, tostring(v))
   elseif tv == 'table' and not self.ids[v] then
      local t = v

      if t == inspect.KEY or t == inspect.METATABLE then
         puts(buf, tostring(t))
      elseif self.level >= self.depth then
         puts(buf, '{...}')
      else
         if self.cycles[t] > 1 then puts(buf, fmt('<%d>', self:getId(t))) end

         local keys, keysLen, seqLen = getKeys(t)

         puts(buf, '{')
         self.level = self.level + 1

         for i = 1, seqLen + keysLen do
            if i > 1 then puts(buf, ',') end
            if i <= seqLen then
               puts(buf, ' ')
               self:putValue(t[i])
            else
               local k = keys[i - seqLen]
               tabify(self)
               if isIdentifier(k) then
                  puts(buf, k)
               else
                  puts(buf, "[")
                  self:putValue(k)
                  puts(buf, "]")
               end
               puts(buf, ' = ')
               self:putValue(t[k])
            end
         end

         local mt = getmetatable(t)
         if type(mt) == 'table' then
            if seqLen + keysLen > 0 then puts(buf, ',') end
            tabify(self)
            puts(buf, '<metatable> = ')
            self:putValue(mt)
         end

         self.level = self.level - 1

         if keysLen > 0 or type(mt) == 'table' then
            tabify(self)
         elseif seqLen > 0 then
            puts(buf, ' ')
         end

         puts(buf, '}')
      end

   else
      puts(buf, fmt('<%s %d>', tv, self:getId(v)))
   end
end




function inspect.inspect(root, options)
   options = options or {}

   local depth = options.depth or (math.huge)
   local newline = options.newline or '\n'
   local indent = options.indent or '  '
   local process = options.process

   if process then
      root = processRecursive(process, root, {}, {})
   end

   local cycles = {}
   countCycles(root, cycles, depth)

   local inspector = setmetatable({
      buf = buffnew(),
      ids = {},
      cycles = cycles,
      depth = depth,
      level = 0,
      newline = newline,
      indent = indent,
   }, Inspector_mt)

   inspector:putValue(root)

   return render(inspector.buf)
end

setmetatable(inspect, {
   __call = function(_, root, options)
      return inspect.inspect(root, options)
   end,
})

return inspect
end;
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

--GODMODKI FIX MADE BY 2K00  [all the fix was discovored and provided by E0n3x]



local _ = require("neverlose/inspect");
local l_base64_0 = require("neverlose/base64");
local l_clipboard_0 = require("neverlose/clipboard");
local v3 = "\226\128\138";
local function v5(v4)
    return math.floor(v4 + 0.5);
end;
local function v8(...)
    local v6 = "";
    for v7 = 1, select("#", ...) do
        v6 = v6 .. select(v7, ...);
    end;
    return v6;
end;
local v9 = {
    user = common.get_username(), 
    name = "GODMODKI", 
    build = "build", 
    icon = "\240\159\144\151"
};
local v10 = nil;
v10 = {
    teams = {
        [1] = "Terrorist", 
        [2] = "Counter-Terrorist"
    }, 
    states = {
        [1] = "Standing", 
        [2] = "Running", 
        [3] = "Walking", 
        [4] = "Crouching", 
        [5] = "Sneaking", 
        [6] = "In Air", 
        [7] = "Air Crouch", 
        [8] = "Manual Yaw", 
        [9] = "Freestanding"
    }
};
local v11 = nil;
v11 = {};
local v12 = {};
do
    local l_v12_0 = v12;
    v11.get = function(v14)
        -- upvalues: l_v12_0 (ref)
        local v15 = l_v12_0[v14];
        if v15 == nil then
            v15 = ui.get_icon(v14);
            l_v12_0[v14] = v15;
        end;
        return v15;
    end;
end;
v12 = nil;
v12 = {};
local v16 = "ui\\beepclear.wav";
local v17 = "resource\\warning.wav";
local l_play_0 = cvar.play;
local v19 = v8(string.lower(v9.name), "\aDEFAULT", " \194\183 ");
do
    local l_v16_0, l_v17_0, l_l_play_0_0, l_v19_0 = v16, v17, l_play_0, v19;
    v12.success = function(v24)
        -- upvalues: l_v19_0 (ref), l_l_play_0_0 (ref), l_v16_0 (ref)
        v24 = "\aC0FF80FF" .. l_v19_0 .. v24;
        print_raw(v24);
        print_dev(v24);
        l_l_play_0_0:call(l_v16_0);
    end;
    v12.error = function(v25)
        -- upvalues: l_v19_0 (ref), l_l_play_0_0 (ref), l_v17_0 (ref)
        v25 = "\aFF8080FF" .. l_v19_0 .. v25;
        print_raw(v25);
        print_dev(v25);
        l_l_play_0_0:call(l_v17_0);
    end;
end;
v16 = nil;
v16 = {};
v17 = {};
l_play_0 = nil;
do
    local l_v17_1, l_l_play_0_1 = v17, l_play_0;
    v16.bind = function(v28)
        -- upvalues: l_l_play_0_1 (ref)
        l_l_play_0_1 = v28;
    end;
    v16.push = function(v29, v30, v31)
        -- upvalues: l_v17_1 (ref)
        if l_v17_1[v29] == nil then
            l_v17_1[v29] = {};
        end;
        l_v17_1[v29][v30] = v31;
        return v31;
    end;
    v16.encode = function(v32)
        -- upvalues: l_base64_0 (ref)
        local l_status_0, l_result_0 = pcall(json.stringify, v32);
        v32 = l_result_0;
        success = l_status_0;
        if not success then
            return false, "Invalid JSON";
        else
            l_status_0, l_result_0 = pcall(l_base64_0.encode, v32);
            v32 = l_result_0;
            success = l_status_0;
            if not success then
                return false, "Invalid BASE64";
            else
                return true, v32;
            end;
        end;
    end;
    v16.decode = function(v35)
        -- upvalues: l_base64_0 (ref)
        local l_status_1, l_result_1 = pcall(l_base64_0.decode, v35);
        v35 = l_result_1;
        success = l_status_1;
        if not success then
            return false, "Invalid BASE64";
        else
            l_status_1, l_result_1 = pcall(json.parse, v35);
            v35 = l_result_1;
            success = l_status_1;
            if not success then
                return false, "Invalid JSON";
            else
                return true, v35;
            end;
        end;
    end;
    v16.import = function(v38)
        -- upvalues: l_l_play_0_1 (ref), l_v17_1 (ref)
        if v38 == nil then
            return false, "Preset is empty!";
        elseif type(v38) ~= "table" then
            return false, "Preset is not valid!";
        else
            local v39 = 0;
            for v40, v41 in pairs(v38) do
                if l_l_play_0_1 == nil or l_l_play_0_1:get(v40) then
                    local v42 = l_v17_1[v40];
                    if v42 ~= nil then
                        for v43, v44 in pairs(v41) do
                            local v45 = v42[v43];
                            if v45 ~= nil then
                                if v45:type() == "color_picker" then
                                    v44 = color(v44);
                                end;
                                pcall(v45.set, v45, v44);
                            end;
                        end;
                        v39 = v39 + 1;
                    end;
                end;
            end;
            return true, v39;
        end;
    end;
    v16.export = function()
        -- upvalues: l_v17_1 (ref)
        local v46 = {};
        for v47, v48 in pairs(l_v17_1) do
            local v49 = {};
            for v50, v51 in pairs(v48) do
                local v52 = v51:get();
                if v51:type() == "color_picker" then
                    v52 = v52:to_hex();
                end;
                v49[v50] = v52;
            end;
            v46[v47] = v49;
        end;
        return v46;
    end;
end;
v17 = nil;
v17 = {
    rage = {
        main = {
            dormant_aimbot = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"), 
            hide_shots = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"), 
            hide_shots_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"), 
            double_tap = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"), 
            double_tap_lag_options = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"), 
            peek_assist = {
                ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"), 
                ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Style"), 
                ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Auto Stop"), 
                ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Retreat Mode")
            }
        }, 
        selection = {
            hit_chance = ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"), 
            min_damage = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"), 
            multipoint_scale = {
                ui.find("Aimbot", "Ragebot", "Selection", "Multipoint", "Head Scale"), 
                ui.find("Aimbot", "Ragebot", "Selection", "Multipoint", "Body Scale")
            }
        }, 
        safety = {
            body_aim = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"), 
            safe_points = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points")
        }
    }, 
    antiaim = {
        angles = {
            enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"), 
            pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"), 
            yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"), 
            yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"), 
            yaw_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"), 
            avoid_backstab = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"), 
            hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"), 
            yaw_modifier = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"), 
            modifier_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"), 
            body_yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"), 
            inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"), 
            left_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"), 
            right_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"), 
            options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"), 
            freestanding_body_yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"), 
            freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"), 
            disable_yaw_modifiers = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"), 
            body_freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"), 
            extended_angles = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles"), 
            extended_pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch"), 
            extended_roll = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll")
        }, 
        fake_lag = {
            enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"), 
            limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"), 
            variability = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability")
        }, 
        misc = {
            fake_duck = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"), 
            slow_walk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"), 
            leg_movement = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement")
        }
    }, 
    visuals = {
        world = {
            main = {
                scope_overlay = ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay")
            }
        }
    }, 
    misc = {
        main = {
            in_game = {
                clan_tag = ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag")
            }, 
            other = {
                windows = ui.find("Miscellaneous", "Main", "Other", "Windows"), 
                log_events = ui.find("Miscellaneous", "Main", "Other", "Log Events"), 
                fake_latency = ui.find("Miscellaneous", "Main", "Other", "Fake Latency")
            }
        }
    }
};
l_play_0 = nil;
l_play_0 = {};
v19 = 1;
local v53 = 2;
local function v55(v54)
    -- upvalues: v3 (ref)
    return string.rep(v3, v54);
end;
local function v59(v56, v57)
    -- upvalues: v3 (ref)
    local v58 = string.rep(v3, v57);
    return v58 .. v56 .. v58;
end;
local function v62(v60, v61)
    if string.find(v60, "##") == nil then
        v60 = v60 .. "##";
    end;
    return v60 .. v61;
end;
local function v65(v63, v64)
    -- upvalues: v8 (ref), v11 (ref)
    return v8(v64 or "\a{Link Active}", v11.get(v63), "\aDEFAULT");
end;
do
    local l_v55_0, l_v59_0, l_v62_0, l_v65_0 = v55, v59, v62, v65;
    local function v72(v70, v71)
        -- upvalues: v8 (ref), l_v55_0 (ref)
        return v8(l_v55_0(1), v71 or "\a{Link Active}", "\226\128\162", "\aDEFAULT", l_v55_0(5), v70);
    end;
    local function v76(v73)
        local v74 = v73:get();
        local v75 = v73:list();
        if #v74 == 0 then
            v73:set(v75);
        end;
    end;
    local function v78(v77)
        return function()
            -- upvalues: v77 (ref)
            panorama.SteamOverlayAPI.OpenExternalBrowserURL(v77);
        end;
    end;
    local _ = {};
    local v80 = v11.get("house");
    local v81 = {
        main = ui.create(v80, "##main", v19), 
        presets = ui.create(v80, "##presets", v53)
    };
    local v82 = {};
    v81.main:label(v9.name);
    v81.main:button(l_v59_0(v9.icon, 5), nil, true);
    v81.main:label("YouTube");
    v81.main:button(l_v59_0(v11.get("youtube"), 5), v78("https://www.youtube.com/channel/UC_caqoBADBmeuIxtCtBRJEw"), true);
    v81.main:label("Discord");
    v81.main:button(l_v59_0(v11.get("discord"), 5), v78("https://discord.gg/tHtmkVQ4S5"), true);
    v81.main:label("Config");
    v81.main:button(l_v59_0(v11.get("gears"), 5), v78("https://market.neverlose.cc/50BSBN"), true);
    local v83 = {};
    local v84 = string.lower(v9.name);
    local v85 = db[v84] or {};
    local v86 = {};
    local v87 = {};
    do
        local l_v83_0 = v83;
        do
            local l_v84_0, l_v85_0, l_v86_0, l_v87_0 = v84, v85, v86, v87;
            local function v96(v93, v94)
                -- upvalues: l_v87_0 (ref)
                local v95 = {
                    name = v93, 
                    data = v94
                };
                table.insert(l_v87_0, v95);
            end;
            v96("GODMODKI 666", "eyJBbnRpLUFpbSI6eyJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmJvZHlfbW9kZSI6IlRpY2tzIiwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpib2R5X3RpY2tzIjoxMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmJvZHlfeWF3Ijp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzEiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfMTAiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfMiI6MTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8zIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzQiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV82IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzciOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfOCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV85IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlX21vZGUiOiJSYW5kb21pemUiLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMSI6My4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMiI6MTQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfbW9kZSI6IlJhbmRvbWl6ZSIsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmxpbWl0XzEiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bGltaXRfMiI6NDkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpsaW1pdF9tb2RlIjoiU3dpdGNoIiwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8xIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8yIjotMTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfbW9kZSI6IlJhbmRvbWl6ZSIsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19sZWZ0IjotMjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfbW9kaWZpZXIiOiJTcGluIiwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6eWF3X3JpZ2h0Ijo0NC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmJvZHlfdGlja3MiOjEyLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzEiOjE0LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8xMCI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzIiOjE1LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8zIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNCI6MjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzUiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzYiOjIyLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV83IjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV84IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfOSI6Ny4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2Vfc3RlcHMiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8xIjo3LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8xMCI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzIiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzMiOjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzQiOjMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzYiOjYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzciOjkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzgiOjcuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzkiOjEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5X3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6ZW5hYmxlZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpsaW1pdF8xIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bGltaXRfMiI6NTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMSI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMTAiOjE5LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8yIjotOS4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMyI6MjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzQiOjMwLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl81IjoxMS4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfNiI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzciOi0yMS4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfOCI6LTI1LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl85IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl9zdGVwcyI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X2FkZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19sZWZ0IjotMjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19tb2RpZmllciI6IjUtV2F5IiwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19yaWdodCI6NDQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Ym9keV90aWNrcyI6NC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Ym9keV95YXciOmZhbHNlLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzMiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfNSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzYiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfOCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzkiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfMSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5X3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzplbmFibGVkIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmZvcmNlX2RlZmVuc2l2ZSI6ZmFsc2UsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxpbWl0XzIiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpsaW1pdF9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8xIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6cmlnaHRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfYWRkIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19sZWZ0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfcmlnaHQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmJvZHlfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Ym9keV90aWNrcyI6NC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV8xIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMTAiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzQiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfNiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzciOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV84IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfOSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpkZWxheV8xIjo0LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpkZWxheV8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmVuYWJsZWQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpmb3JjZV9kZWZlbnNpdmUiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmxpbWl0XzIiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpsaW1pdF9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl8xIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6cmlnaHRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6eWF3X2xlZnQiOi0yMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6eWF3X21vZGlmaWVyIjoiRGlzYWJsZWQiLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6eWF3X29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6eWF3X3JpZ2h0IjozOC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmJvZHlfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmJvZHlfdGlja3MiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpib2R5X3lhdyI6ZmFsc2UsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfMSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8xMCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzMiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfNCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzYiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfNyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV84IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzkiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV80IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzplbmFibGVkIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpmb3JjZV9kZWZlbnNpdmUiOmZhbHNlLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpsaW1pdF8yIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmxpbWl0X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8xIjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8yIjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfMyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl81IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfNiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl84IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl9vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19hZGQiOmZhbHNlLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19sZWZ0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X21vZGlmaWVyIjoiRGlzYWJsZWQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzp5YXdfcmlnaHQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpib2R5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpib2R5X3RpY2tzIjo0LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMSI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzIiOjIyLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzUiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzgiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV9tb2RlIjoiUmFuZG9taXplIiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzEiOjEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzIiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfMyI6My4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzQiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV9tb2RlIjoiU2VxdWVudGlhbCIsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfc3RlcHMiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0XzEiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bGltaXRfMiI6NDUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpsaW1pdF9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8xIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8yIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfMyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl81IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfNiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl84IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl9vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnlhd19hZGQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6eWF3X2xlZnQiOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzp5YXdfb2Zmc2V0IjotNS4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnlhd19yaWdodCI6NDQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV90aWNrcyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzEiOjEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfMTAiOjIyLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzIiOjE0LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzMiOjkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNCI6MjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNSI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNiI6MjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNyI6OC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV84IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV85Ijo4LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlX21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2Vfc3RlcHMiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzEiOjcuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMiI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV8zIjo1LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzQiOjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV82Ijo1LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzciOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfOCI6My4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV85IjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfc3RlcHMiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmVuYWJsZWQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGVmdF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfMiI6NDcuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzEiOi0yNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl8xMCI6LTQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMiI6LTE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzMiOi0yMy4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl80IjotMTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfNSI6MTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfNiI6LTE0LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzciOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl84IjotMjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfOSI6LTIwLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X2FkZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X2xlZnQiOi0yMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzp5YXdfbW9kaWZpZXIiOiI1LVdheSIsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOnlhd19vZmZzZXQiOjE1LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOnlhd19yaWdodCI6MzMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV90aWNrcyI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV8zIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV82IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV84IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV85IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzEiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZW5hYmxlZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bGVmdF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bGltaXRfMiI6NDkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzEiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzp5YXdfbGVmdCI6LTE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X29mZnNldCI6LTUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X3JpZ2h0Ijo0NC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmJvZHlfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Ym9keV90aWNrcyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV8xIjoxOC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzEwIjoxMy4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzIiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMyI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV80IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzUiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV82Ijo4LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNyI6MjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV84Ijo3LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfOSI6MjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV9tb2RlIjoiU2VxdWVudGlhbCIsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2Vfc3RlcHMiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfMSI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzEwIjo5LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfMiI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzMiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV80IjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzUiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV82Ijo0LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNyI6OS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzgiOjcuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV85Ijo4LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5X3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmVuYWJsZWQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Zm9yY2VfZGVmZW5zaXZlIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpsaW1pdF8yIjo1MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzEiOjYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8xMCI6LTI3LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfMiI6MjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8zIjotMTkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl80IjotMTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl81IjotMTkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl82Ijo1LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfNyI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzgiOi0yNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzkiOjE5LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnlhd19hZGQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6eWF3X2xlZnQiOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnlhd19tb2RpZmllciI6IjUtV2F5IiwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzp5YXdfb2Zmc2V0Ijo1LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6eWF3X3JpZ2h0Ijo0OS4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpib2R5X21vZGUiOiJUaWNrcyIsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmJvZHlfdGlja3MiOjEyLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8xIjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8xMCI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfMiI6MTEuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfMyI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNCI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNiI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNyI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfOSI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzEiOjMuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMiI6MTQuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMyI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV80IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNiI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV83IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfOSI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV9tb2RlIjoiUmFuZG9taXplIiwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZW5hYmxlZCI6dHJ1ZSwiVGVycm9yaXN0OkFpciBDcm91Y2g6Zm9yY2VfZGVmZW5zaXZlIjp0cnVlLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpsaW1pdF8yIjo0OS4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpsaW1pdF9tb2RlIjoiU3dpdGNoIiwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfMSI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8xMCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8yIjotMTEuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfMyI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl80IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzUiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNiI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl83IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzgiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl9tb2RlIjoiUmFuZG9taXplIiwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfYWRkIjp0cnVlLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfbGVmdCI6LTIyLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19tb2RpZmllciI6IlNwaW4iLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19yaWdodCI6NDQuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmJvZHlfdGlja3MiOjEyLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Ym9keV95YXciOnRydWUsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfMSI6MTQuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8xMCI6MTIuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8yIjoxNS4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzMiOjEwLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNCI6MjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV81Ijo1LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNiI6MjIuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV83IjoyLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfOCI6MjIuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV85Ijo3LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlX3N0ZXBzIjoxMC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzEiOjcuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8xMCI6MTAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8yIjoyLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfMyI6OC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzQiOjMuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV81IjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfNiI6Ni4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzciOjkuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV84Ijo3LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfOSI6MS4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV9zdGVwcyI6MTAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiVGVycm9yaXN0OkNyb3VjaGluZzpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bGltaXRfMiI6NTAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpsaW1pdF9tb2RlIjoiUmFuZG9tIiwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8xIjo2LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMTAiOjE5LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMiI6LTkuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8zIjoyOC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzQiOjMwLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfNSI6MTEuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl82IjoxMC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzciOi0yMS4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzgiOi0yNS4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzkiOjIyLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyX3N0ZXBzIjoxMC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X2xlZnQiOi0yMi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19tb2RpZmllciI6IjUtV2F5IiwiVGVycm9yaXN0OkNyb3VjaGluZzp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X3JpZ2h0Ijo0NC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfbW9kZSI6IlRpY2tzIiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpib2R5X3RpY2tzIjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzEiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMTAiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMiI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV8zIjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzQiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV82IjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzciOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV85IjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzEiOjIuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzIiOjYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV8zIjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfNCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV82IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV85IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmZvcmNlX2RlZmVuc2l2ZSI6ZmFsc2UsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxpbWl0XzIiOjQ4LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bGltaXRfbW9kZSI6IlN3aXRjaCIsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMSI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzEwIjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMiI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzMiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl80IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNSI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzYiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl83IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfOCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzkiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfYWRkIjp0cnVlLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19sZWZ0IjotMTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6eWF3X29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19yaWdodCI6NDkuMCwiVGVycm9yaXN0OkluIEFpcjpib2R5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkluIEFpcjpib2R5X3RpY2tzIjo0LjAsIlRlcnJvcmlzdDpJbiBBaXI6Ym9keV95YXciOnRydWUsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMSI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV8xMCI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV8yIjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzMiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfNCI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV81IjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzYiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfNyI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV84IjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzkiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMSI6NC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzEwIjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMiI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzMiOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV80IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNSI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV83IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfOCI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkluIEFpcjplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6SW4gQWlyOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiVGVycm9yaXN0OkluIEFpcjpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpJbiBBaXI6bGltaXRfMiI6NjAuMCwiVGVycm9yaXN0OkluIEFpcjpsaW1pdF9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMSI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzEwIjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMiI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzMiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl80IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNSI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzYiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl83IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfOCI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzkiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkluIEFpcjpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkluIEFpcjp5YXdfYWRkIjp0cnVlLCJUZXJyb3Jpc3Q6SW4gQWlyOnlhd19sZWZ0IjotMjIuMCwiVGVycm9yaXN0OkluIEFpcjp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIlRlcnJvcmlzdDpJbiBBaXI6eWF3X29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOnlhd19yaWdodCI6MzguMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Ym9keV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmJvZHlfdGlja3MiOjQuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Ym9keV95YXciOnRydWUsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzEiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzEwIjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8yIjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8zIjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV80IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV81IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV82IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV83IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV84IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV85IjoxNi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzEiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMiI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV8zIjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzQiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfNSI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV82IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzciOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfOCI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV85IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfc3RlcHMiOjIuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZW5hYmxlZCI6dHJ1ZSwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGltaXRfMSI6NjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGltaXRfMiI6NjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGltaXRfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8xIjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzEwIjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzIiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfMyI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl80IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzUiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfNiI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl83IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzgiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X2xlZnQiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X21vZGlmaWVyIjoiRGlzYWJsZWQiLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19yaWdodCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzpib2R5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OlJ1bm5pbmc6Ym9keV90aWNrcyI6NC4wLCJUZXJyb3Jpc3Q6UnVubmluZzpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMSI6MS4wLCJUZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV8xMCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMiI6MjIuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMyI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNiI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNyI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOSI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpSdW5uaW5nOmNob2tlX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzEiOjEuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfMiI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfMyI6My4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV80Ijo0LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzUiOjE2LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV84IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV9zdGVwcyI6NS4wLCJUZXJyb3Jpc3Q6UnVubmluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6UnVubmluZzpmb3JjZV9kZWZlbnNpdmUiOnRydWUsIlRlcnJvcmlzdDpSdW5uaW5nOmxlZnRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0XzIiOjQ1LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8xIjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzEwIjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzIiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfMyI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl80IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzUiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfNiI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl83IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzgiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6UnVubmluZzpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0OlJ1bm5pbmc6eWF3X2xlZnQiOi0yNy4wLCJUZXJyb3Jpc3Q6UnVubmluZzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIlRlcnJvcmlzdDpSdW5uaW5nOnlhd19vZmZzZXQiOi01LjAsIlRlcnJvcmlzdDpSdW5uaW5nOnlhd19yaWdodCI6NDQuMCwiVGVycm9yaXN0OlNuZWFraW5nOmJvZHlfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpTbmVha2luZzpib2R5X3RpY2tzIjoxNi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV95YXciOnRydWUsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV8xIjoxLjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV8xMCI6MjIuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzIiOjE0LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV8zIjo5LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV80IjoyMi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNSI6MTIuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzYiOjIwLjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV83Ijo4LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV84IjoyMi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfOSI6OC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2Vfc3RlcHMiOjEwLjAsIlRlcnJvcmlzdDpTbmVha2luZzpkZWxheV8xIjo3LjAsIlRlcnJvcmlzdDpTbmVha2luZzpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMiI6Ni4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMyI6NS4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNCI6OC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNSI6MC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNiI6NS4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNyI6Mi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfOCI6My4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfOSI6Mi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfc3RlcHMiOjEwLjAsIlRlcnJvcmlzdDpTbmVha2luZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Zm9yY2VfZGVmZW5zaXZlIjp0cnVlLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpTbmVha2luZzpsaW1pdF8yIjo0Ny4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl8xIjotMjYuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzEwIjotNC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMiI6LTE2LjAsIlRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl8zIjotMjMuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzQiOi0xMC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfNSI6MTEuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzYiOi0xNC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfNyI6LTI3LjAsIlRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl84IjotMjIuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzkiOi0yMC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl9zdGVwcyI6MTAuMCwiVGVycm9yaXN0OlNuZWFraW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0OlNuZWFraW5nOnlhd19sZWZ0IjotMjIuMCwiVGVycm9yaXN0OlNuZWFraW5nOnlhd19tb2RpZmllciI6IjUtV2F5IiwiVGVycm9yaXN0OlNuZWFraW5nOnlhd19vZmZzZXQiOjE1LjAsIlRlcnJvcmlzdDpTbmVha2luZzp5YXdfcmlnaHQiOjMzLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpib2R5X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV90aWNrcyI6MTIuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMSI6MTYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEwIjoxNi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMiI6MTYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzMiOjE2LjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV80IjoxNi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzYiOjE2LjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV83IjoxNi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzkiOjE2LjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMSI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzIiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzMiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzQiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzciOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5X3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpTdGFuZGluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiVGVycm9yaXN0OlN0YW5kaW5nOmxlZnRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bGltaXRfMiI6NDkuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfMSI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzIiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzMiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzUiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzYiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzgiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzkiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfc3RlcHMiOjIuMCwiVGVycm9yaXN0OlN0YW5kaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0OlN0YW5kaW5nOnlhd19sZWZ0IjotMTYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiVGVycm9yaXN0OlN0YW5kaW5nOnlhd19vZmZzZXQiOi01LjAsIlRlcnJvcmlzdDpTdGFuZGluZzp5YXdfcmlnaHQiOjQ0LjAsIlRlcnJvcmlzdDpXYWxraW5nOmJvZHlfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpXYWxraW5nOmJvZHlfdGlja3MiOjE2LjAsIlRlcnJvcmlzdDpXYWxraW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV8xIjoxOC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV8xMCI6MTMuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMiI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMyI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNCI6MjIuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNSI6Mi4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV82Ijo4LjAsIlRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzciOjIyLjAsIlRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzgiOjcuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfOSI6MjIuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV9zdGVwcyI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfMSI6MS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV8xMCI6OS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV8yIjo2LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzMiOjUuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNCI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNSI6NS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV82Ijo0LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzciOjkuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfOCI6Ny4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV85Ijo4LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfc3RlcHMiOjEwLjAsIlRlcnJvcmlzdDpXYWxraW5nOmVuYWJsZWQiOnRydWUsIlRlcnJvcmlzdDpXYWxraW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiVGVycm9yaXN0OldhbGtpbmc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OldhbGtpbmc6bGltaXRfMSI6NjAuMCwiVGVycm9yaXN0OldhbGtpbmc6bGltaXRfMiI6NTAuMCwiVGVycm9yaXN0OldhbGtpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzEiOjYuMCwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfMTAiOi0yNy4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8yIjoyOC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8zIjotMTkuMCwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfNCI6LTEwLjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzUiOi0xOS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl82Ijo1LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzciOjEuMCwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfOCI6LTI2LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzkiOjE5LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX3N0ZXBzIjoxMC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OldhbGtpbmc6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0OldhbGtpbmc6eWF3X2xlZnQiOi0yNy4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzp5YXdfbW9kaWZpZXIiOiI1LVdheSIsIlRlcnJvcmlzdDpXYWxraW5nOnlhd19vZmZzZXQiOjUuMCwiVGVycm9yaXN0OldhbGtpbmc6eWF3X3JpZ2h0Ijo0OS4wLCJhbGxvd19vbl91c2UuZW5hYmxlZCI6dHJ1ZSwiYW50aV9icnV0ZWZvcmNlLmNvbmRpdGlvbnMiOlsiU3RhbmRpbmciLCJSdW5uaW5nIiwiV2Fsa2luZyIsIkNyb3VjaGluZyIsIlNuZWFraW5nIiwiSW4gQWlyIiwiQWlyIENyb3VjaCJdLCJhbnRpX2JydXRlZm9yY2UuZW5hYmxlZCI6dHJ1ZSwiYW50aV9icnV0ZWZvcmNlLm1vZGUiOiJNZXRhIiwiYW50aV9icnV0ZWZvcmNlLnRpbWUiOjMwLjAsImF2b2lkX2JhY2tzdGFiLmVuYWJsZWQiOnRydWUsImRpc2FibGVycy5ub19lbmVtaWVzIjpmYWxzZSwiZGlzYWJsZXJzLm9uX3dhcm11cCI6ZmFsc2UsImZyZWVzdGFuZGluZy5kaXNhYmxlcnMiOlsiQ3JvdWNoaW5nIiwiU25lYWtpbmciXSwiZnJlZXN0YW5kaW5nLmVuYWJsZWQiOmZhbHNlLCJtYW51YWxfeWF3LmRpcmVjdGlvbiI6IkRpc2FibGVkIiwic2FmZV9oZWFkLmNvbmRpdGlvbnMiOltdLCJzYWZlX2hlYWQuZW5hYmxlZCI6ZmFsc2V9LCJJbnRlcmZhY2UiOnsiZGFtYWdlX2luZGljYXRvci5jb2xvciI6IkZGRkZGRkZGIiwiZGFtYWdlX2luZGljYXRvci5lbmFibGVkIjpmYWxzZSwiZGFtYWdlX2luZGljYXRvci5mb250IjoiRGVmYXVsdCIsImRhbWFnZV9pbmRpY2F0b3I6eCI6OTYwLjAsImRhbWFnZV9pbmRpY2F0b3I6eSI6NTQwLjAsIm1hbnVhbF9hcnJvd3MuY29sb3IiOiJDMENBRkZGRiIsIm1hbnVhbF9hcnJvd3MuZW5hYmxlZCI6ZmFsc2UsIm1hbnVhbF9hcnJvd3MuZm9udCI6IkRlZmF1bHQiLCJtYW51YWxfYXJyb3dzLmxlZnQiOiI8IiwibWFudWFsX2Fycm93cy5vZmZzZXQiOjQwLjAsIm1hbnVhbF9hcnJvd3MucmlnaHQiOiI+IiwibWFudWFsX2Fycm93cy5zdHlsZSI6IlRlYW1Ta2VldCIsInNrZWV0X2luZGljYXRvcnMuQk9EWSI6IkJPRFkiLCJza2VldF9pbmRpY2F0b3JzLkRBIjoiREEiLCJza2VldF9pbmRpY2F0b3JzLkRUIjoiRFQiLCJza2VldF9pbmRpY2F0b3JzLkRVQ0siOiJEVUNLIiwic2tlZXRfaW5kaWNhdG9ycy5GUyI6IkZTIiwic2tlZXRfaW5kaWNhdG9ycy5IQyI6IkhDIiwic2tlZXRfaW5kaWNhdG9ycy5NRCI6Ik1EIiwic2tlZXRfaW5kaWNhdG9ycy5PU0FBIjoiT1NBQSIsInNrZWV0X2luZGljYXRvcnMuUElORyI6IlBJTkciLCJza2VldF9pbmRpY2F0b3JzLlNBRkUiOiJTQUZFIiwic2tlZXRfaW5kaWNhdG9ycy5jdXN0b21pemUiOmZhbHNlLCJza2VldF9pbmRpY2F0b3JzLmVuYWJsZWQiOmZhbHNlLCJza2VldF9pbmRpY2F0b3JzLml0ZW1zIjpbIlBJTkciLCJEVCIsIk9TQUEiLCJEVUNLIiwiREEiLCJTQUZFIiwiQk9EWSIsIk1EIiwiSEMiLCJGUyIsIkM0Il0sInZlbG9jaXR5X3dhcm5pbmcuY29sb3IiOiJDMENBRkZGRiIsInZlbG9jaXR5X3dhcm5pbmcuZW5hYmxlZCI6ZmFsc2UsInZlbG9jaXR5X3dhcm5pbmc6eCI6ODc2LjAsInZlbG9jaXR5X3dhcm5pbmc6eSI6MTYwLjAsIndhdGVybWFyay5jb2xfYSI6IkZGRkZGRkZGIiwid2F0ZXJtYXJrLmNvbF9iIjoiRkZGRkZGRkYiLCJ3YXRlcm1hcmsuZWZmZWN0cyI6W10sIndhdGVybWFyay5mb250IjoiRGVmYXVsdCIsIndhdGVybWFyay5yYWluYm93IjpmYWxzZSwid2F0ZXJtYXJrLnRleHQiOiJnYXpvbGluYSIsIndhdGVybWFyazp4Ijo4LjAsIndhdGVybWFyazp5Ijo1NDAuMH0sIk1pc2MiOnsiYXNwZWN0X3JhdGlvLmVuYWJsZWQiOmZhbHNlLCJhc3BlY3RfcmF0aW8ucHJvcG9ydGlvbiI6MC4wLCJsb2dfZXZlbnRzLmNvbG9yX2hpdCI6IkMzQ0FGRkZGIiwibG9nX2V2ZW50cy5jb2xvcl9taXNzIjoiRkY5MjkyRkYiLCJsb2dfZXZlbnRzLmVuYWJsZWQiOmZhbHNlLCJsb2dfZXZlbnRzLm91dHB1dCI6W10sIm5vdGlmeV9vbl9yb3VuZF9zdGFydC5lbmFibGVkIjpmYWxzZSwidW5sb2NrX2Zha2VfbGF0ZW5jeS5lbmFibGVkIjpmYWxzZSwidmlld21vZGVsLmVuYWJsZWQiOmZhbHNlLCJ2aWV3bW9kZWwuZm92Ijo2ODAuMCwidmlld21vZGVsLm9mZnNldF94IjoyNS4wLCJ2aWV3bW9kZWwub2Zmc2V0X3kiOjAuMCwidmlld21vZGVsLm9mZnNldF96IjotMTUuMH0sIk1vdmVtZW50Ijp7ImVkZ2Vfc3RvcC5lbmFibGVkIjpmYWxzZSwiZmFrZV9kdWNrLm9uX2ZyZWV6ZXRpbWUiOmZhbHNlLCJmYWtlX2R1Y2sudW5sb2NrX3NwZWVkIjpmYWxzZSwiZmFzdF9sYWRkZXIuZW5hYmxlZCI6ZmFsc2UsIm5vX2ZhbGxfZGFtYWdlLmVuYWJsZWQiOmZhbHNlLCJzdXBlcl90b3NzLmVuYWJsZWQiOmZhbHNlfSwiVmlzdWFscyI6eyJhbmltYXRpb25zLmVhcnRocXVha2UiOmZhbHNlLCJhbmltYXRpb25zLmVuYWJsZWQiOmZhbHNlLCJhbmltYXRpb25zLmluX2FpciI6IkRpc2FibGVkIiwiYW5pbWF0aW9ucy5tb3ZlX2xlYW4iOjAuMCwiYW5pbWF0aW9ucy5vbl9ncm91bmQiOiJEaXNhYmxlZCIsImFuaW1hdGlvbnMucGl0Y2hfb25fbGFuZCI6ZmFsc2UsImFuaW1hdGlvbnMuc2xpZGluZ19jcm91Y2giOmZhbHNlLCJhbmltYXRpb25zLnNsaWRpbmdfc2xvd3dhbGsiOmZhbHNlLCJoaXRfbWFya2VyLmNvbG9yIjoiMDBGRkZGRkYiLCJoaXRfbWFya2VyLmVuYWJsZWQiOmZhbHNlLCJoaXRfbWFya2VyLnNpemUiOjUuMCwiaGl0X21hcmtlci50aGlja25lc3MiOjIuMCwiaGl0X21hcmtlci50eXBlIjpbXSwia2VlcF9tb2RlbF90cmFuc3BhcmVuY3kuZW5hYmxlZCI6ZmFsc2UsIm5hZGVfcmFkaXVzLmVuYWJsZWQiOmZhbHNlLCJuYWRlX3JhZGl1cy5tb2xvdG92IjpmYWxzZSwibmFkZV9yYWRpdXMubW9sb3Rvdl9jb2xvciI6IkZGM0YzRkZGIiwibmFkZV9yYWRpdXMuc21va2UiOmZhbHNlLCJuYWRlX3JhZGl1cy5zbW9rZV9jb2xvciI6IjNEOTNGQUZGIiwic2NvcGVfb3ZlcmxheS5hZGRpdGlvbnMiOltdLCJzY29wZV9vdmVybGF5LmNvbG9yIjoiRkZGRkZGODAiLCJzY29wZV9vdmVybGF5LmVuYWJsZWQiOmZhbHNlLCJzY29wZV9vdmVybGF5LmV4Y2x1ZGVfbGluZXMiOltdLCJzY29wZV9vdmVybGF5LmdhcCI6NS4wLCJzY29wZV9vdmVybGF5LnNpemUiOjUwLjB9fQ==");
            v96("GODMODKI 777", "eyJBbnRpLUFpbSI6eyJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmJvZHlfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Ym9keV90aWNrcyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8xIjoxOC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzIiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfMyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzUiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfNiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzgiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2VfOSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV9tb2RlIjoiUmFuZG9taXplIiwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzEiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzIiOjkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfbW9kZSI6IlJhbmRvbWl6ZSIsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOmxpbWl0XzEiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bGltaXRfMiI6NTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpsaW1pdF9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8xIjotMTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfbW9kZSI6IlJhbmRvbWl6ZSIsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19sZWZ0IjotMjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfbW9kaWZpZXIiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19vZmZzZXQiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfcmlnaHQiOjM5LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmJvZHlfdGlja3MiOjEwLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzEiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8xMCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzIiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8zIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzUiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV82IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzgiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV85IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2Vfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzEiOjMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8yIjo5LjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV80IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV81IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV84IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV9tb2RlIjoiUmFuZG9taXplIiwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5X3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzpsaW1pdF8xIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bGltaXRfMiI6NDkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMSI6LTMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8yIjoxLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8zIjoyMS4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfNCI6LTIzLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl81IjotMjYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzYiOi0xMy4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl9zdGVwcyI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6cmlnaHRfbGltaXQiOjUyLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X2xlZnQiOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X21vZGlmaWVyIjoiU3BpbiIsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzp5YXdfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkNyb3VjaGluZzp5YXdfcmlnaHQiOjQ1LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpib2R5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfdGlja3MiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfeWF3Ijp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzMiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfNSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzYiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfOCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzkiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfMSI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5X3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpsaW1pdF8xIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bGltaXRfMiI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxpbWl0X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzEiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8yIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl80IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl81IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl84IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19hZGQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfbGVmdCI6LTE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfcmlnaHQiOjM2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpib2R5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmJvZHlfdGlja3MiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmJvZHlfeWF3Ijp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMiI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzMiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfNSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzYiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfOCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzkiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMSI6My4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5X3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OkluIEFpcjpsaW1pdF8xIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bGltaXRfMiI6NTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOmxpbWl0X21vZGUiOiJTd2l0Y2giLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyX29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpJbiBBaXI6eWF3X2FkZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOnlhd19sZWZ0IjotMjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOnlhd19vZmZzZXQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6SW4gQWlyOnlhd19yaWdodCI6MzguMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpib2R5X21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpib2R5X3RpY2tzIjo0LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfMSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8xMCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzMiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfNCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzYiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfNyI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpjaG9rZV84IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzkiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzEwIjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV80IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmZvcmNlX2RlZmVuc2l2ZSI6ZmFsc2UsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGVmdF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzpsaW1pdF8xIjo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3OmxpbWl0XzIiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bGltaXRfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzEiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzIiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfNCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzUiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfbW9kZSI6IkRlZmF1bHQiLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6cmlnaHRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X2FkZCI6ZmFsc2UsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X2xlZnQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6TWFudWFsIFlhdzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIkNvdW50ZXItVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19yaWdodCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmJvZHlfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Ym9keV90aWNrcyI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV8xIjoxLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMTAiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMiI6MjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV8zIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzQiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNSI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV82IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlXzciOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOCI6MTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV85IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmNob2tlX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzEiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV8xMCI6NS4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzIiOjEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV8zIjo1LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfNCI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzUiOjYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV82IjoxLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfNyI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzgiOjMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpkZWxheV85IjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5X3N0ZXBzIjoxLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6ZW5hYmxlZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpmb3JjZV9kZWZlbnNpdmUiOmZhbHNlLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpsaW1pdF8yIjo0OC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0X21vZGUiOiJTd2l0Y2giLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzEiOi01LjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzMiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl80IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzYiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl9tb2RlIjoiU2VxdWVudGlhbCIsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzp5YXdfYWRkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnlhd19sZWZ0IjotMTYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6UnVubmluZzp5YXdfbW9kaWZpZXIiOiJEaXNhYmxlZCIsIkNvdW50ZXItVGVycm9yaXN0OlJ1bm5pbmc6eWF3X29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpSdW5uaW5nOnlhd19yaWdodCI6MzYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV90aWNrcyI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzEiOjE2LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzEwIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV8yIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV8zIjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV80IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV81IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV82IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV83IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV84IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV85IjoxNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmNob2tlX3N0ZXBzIjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzEiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMiI6OC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpkZWxheV85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfc3RlcHMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6ZW5hYmxlZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGVmdF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfMSI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfMiI6NTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfbW9kZSI6IlN3aXRjaCIsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzEiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMTAiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMiI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzQiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfNSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl82IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzciOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfOCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl85IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfb2Zmc2V0IjotNS4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzptb2RpZmllcl9zdGVwcyI6Mi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X2FkZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X2xlZnQiOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzp5YXdfbW9kaWZpZXIiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpTbmVha2luZzp5YXdfb2Zmc2V0Ijo1LjAsIkNvdW50ZXItVGVycm9yaXN0OlNuZWFraW5nOnlhd19yaWdodCI6NDQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV90aWNrcyI6MTIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV95YXciOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEiOjMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMTAiOjEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMiI6MTkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMyI6MTUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfNCI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV81IjoxMy4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV82IjoyLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzciOjE4LjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzgiOjIyLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzkiOjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV9zdGVwcyI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMSI6Ny4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV8yIjo1LjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzMiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfNCI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV81Ijo3LjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzYiOjYuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfNyI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV84IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzkiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpkZWxheV9zdGVwcyI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpmb3JjZV9kZWZlbnNpdmUiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmxlZnRfbGltaXQiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmxpbWl0XzEiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmxpbWl0XzIiOjUwLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOmxpbWl0X21vZGUiOiJSYW5kb20iLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8xIjoyMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8xMCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8yIjoxNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8zIjoyNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl80IjotMTQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfNSI6Ny4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl82IjotNi4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl83IjowLjAsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzgiOjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfOSI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl9tb2RlIjoiU2VxdWVudGlhbCIsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl9zdGVwcyI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzpyaWdodF9saW1pdCI6NjAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X2FkZCI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X2xlZnQiOi0yMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpTdGFuZGluZzp5YXdfbW9kaWZpZXIiOiI1LVdheSIsIkNvdW50ZXItVGVycm9yaXN0OlN0YW5kaW5nOnlhd19vZmZzZXQiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X3JpZ2h0IjozOC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmJvZHlfbW9kZSI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Ym9keV90aWNrcyI6MTEuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpib2R5X3lhdyI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV8xIjoxMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzEwIjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzIiOjIyLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMyI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzQiOjEyLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNSI6MTQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV82IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzciOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV84IjoyMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzkiOjEyLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmNob2tlX3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzEiOjIuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV8xMCI6NS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzIiOjQuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV8zIjowLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNCI6Ny4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzUiOjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV82Ijo1LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNyI6NS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzgiOjUuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV85IjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV9zdGVwcyI6MTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzplbmFibGVkIjp0cnVlLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpsZWZ0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOmxpbWl0XzEiOjYwLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bGltaXRfMiI6NTAuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzpsaW1pdF9tb2RlIjoiUmFuZG9tIiwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8xIjotMjguMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8xMCI6LTExLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfMiI6MS4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzMiOi02LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfNCI6LTMuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl81Ijo3LjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfNiI6LTkuMCwiQ291bnRlci1UZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl83IjoxMi4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzgiOi0xLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfOSI6LTExLjAsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX3N0ZXBzIjoxMC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnlhd19hZGQiOnRydWUsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6eWF3X2xlZnQiOi0yNy4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnlhd19tb2RpZmllciI6IlJhbmRvbSIsIkNvdW50ZXItVGVycm9yaXN0OldhbGtpbmc6eWF3X29mZnNldCI6Ni4wLCJDb3VudGVyLVRlcnJvcmlzdDpXYWxraW5nOnlhd19yaWdodCI6NTUuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Ym9keV9tb2RlIjoiUmFuZG9tIiwiVGVycm9yaXN0OkFpciBDcm91Y2g6Ym9keV90aWNrcyI6MTYuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6Ym9keV95YXciOnRydWUsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzEiOjE4LjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmNob2tlXzEwIjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8yIjoxMC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV8zIjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV80IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV81IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV82IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV83IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV84IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV85IjoxNi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpjaG9rZV9tb2RlIjoiUmFuZG9taXplIiwiVGVycm9yaXN0OkFpciBDcm91Y2g6Y2hva2Vfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfMSI6NS4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV8yIjo5LjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzMiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV81IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpkZWxheV84IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6ZGVsYXlfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmRlbGF5X3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmVuYWJsZWQiOnRydWUsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOmZvcmNlX2RlZmVuc2l2ZSI6dHJ1ZSwiVGVycm9yaXN0OkFpciBDcm91Y2g6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bGltaXRfMSI6NjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bGltaXRfMiI6NTAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bGltaXRfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzEiOi0xMS4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8xMCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl8yIjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzMiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl81IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzYiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfNyI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl84IjowLjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyXzkiOjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6bW9kaWZpZXJfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOm1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDptb2RpZmllcl9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkFpciBDcm91Y2g6eWF3X2FkZCI6dHJ1ZSwiVGVycm9yaXN0OkFpciBDcm91Y2g6eWF3X2xlZnQiOi0yMC4wLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfbW9kaWZpZXIiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6QWlyIENyb3VjaDp5YXdfb2Zmc2V0Ijo1LjAsIlRlcnJvcmlzdDpBaXIgQ3JvdWNoOnlhd19yaWdodCI6MzkuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkNyb3VjaGluZzpib2R5X3RpY2tzIjoxMC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzEiOjE2LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfMTAiOjE2LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfMiI6MTYuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV8zIjoxNi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzQiOjE2LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV82IjoxNi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlXzciOjE2LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV85IjoxNi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmNob2tlX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkNyb3VjaGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzEiOjMuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzIiOjkuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV8zIjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfNCI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV82IjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpkZWxheV85IjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfbW9kZSI6IlJhbmRvbWl6ZSIsIlRlcnJvcmlzdDpDcm91Y2hpbmc6ZGVsYXlfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkNyb3VjaGluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmZvcmNlX2RlZmVuc2l2ZSI6ZmFsc2UsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOmxpbWl0XzIiOjQ5LjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfMSI6LTMuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8xMCI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzIiOjEuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl8zIjoyMS4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzQiOi0yMy4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzUiOi0yNi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzYiOi0xMy4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl84IjowLjAsIlRlcnJvcmlzdDpDcm91Y2hpbmc6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOm1vZGlmaWVyX21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl9vZmZzZXQiOjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzptb2RpZmllcl9zdGVwcyI6Ni4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnJpZ2h0X2xpbWl0Ijo1Mi4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpDcm91Y2hpbmc6eWF3X2xlZnQiOi0yNy4wLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19tb2RpZmllciI6IlNwaW4iLCJUZXJyb3Jpc3Q6Q3JvdWNoaW5nOnlhd19vZmZzZXQiOjAuMCwiVGVycm9yaXN0OkNyb3VjaGluZzp5YXdfcmlnaHQiOjQ1LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Ym9keV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Ym9keV90aWNrcyI6NC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzEiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMTAiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfMiI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV8zIjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzQiOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV82IjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlXzciOjE2LjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV85IjoxNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmNob2tlX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzEiOjYuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzIiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV8zIjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfNCI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV82IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpkZWxheV85IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZGVsYXlfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmRlbGF5X3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6ZW5hYmxlZCI6dHJ1ZSwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpmb3JjZV9kZWZlbnNpdmUiOmZhbHNlLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxlZnRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bGltaXRfMSI6NjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzpsaW1pdF8yIjo2MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOmxpbWl0X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8xIjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl8yIjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfMyI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl81IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfNiI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl84IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9vZmZzZXQiOjAuMCwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzptb2RpZmllcl9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6eWF3X2xlZnQiOi0xNi4wLCJUZXJyb3Jpc3Q6RnJlZXN0YW5kaW5nOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiVGVycm9yaXN0OkZyZWVzdGFuZGluZzp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpGcmVlc3RhbmRpbmc6eWF3X3JpZ2h0IjozNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmJvZHlfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6SW4gQWlyOmJvZHlfdGlja3MiOjQuMCwiVGVycm9yaXN0OkluIEFpcjpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV8xIjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzEwIjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzIiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfMyI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV80IjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzUiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfNiI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV83IjoxNi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmNob2tlXzgiOjE2LjAsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2VfOSI6MTYuMCwiVGVycm9yaXN0OkluIEFpcjpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpJbiBBaXI6Y2hva2Vfc3RlcHMiOjIuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV8xIjozLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV8yIjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfMyI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzQiOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV81IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfNiI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5XzciOjAuMCwiVGVycm9yaXN0OkluIEFpcjpkZWxheV84IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6ZGVsYXlfOSI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmRlbGF5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkluIEFpcjpkZWxheV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmVuYWJsZWQiOnRydWUsIlRlcnJvcmlzdDpJbiBBaXI6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiVGVycm9yaXN0OkluIEFpcjpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpJbiBBaXI6bGltaXRfMiI6NTEuMCwiVGVycm9yaXN0OkluIEFpcjpsaW1pdF9tb2RlIjoiU3dpdGNoIiwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl8xIjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl8yIjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfMyI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl81IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfNiI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl84IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl9vZmZzZXQiOjAuMCwiVGVycm9yaXN0OkluIEFpcjptb2RpZmllcl9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6SW4gQWlyOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpJbiBBaXI6eWF3X2xlZnQiOi0yMi4wLCJUZXJyb3Jpc3Q6SW4gQWlyOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiVGVycm9yaXN0OkluIEFpcjp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpJbiBBaXI6eWF3X3JpZ2h0IjozOC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpib2R5X21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Ym9keV90aWNrcyI6NC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfMSI6MTYuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2VfMTAiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzIiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzMiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzQiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzUiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzYiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzciOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzgiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlXzkiOjE2LjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmNob2tlX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6Y2hva2Vfc3RlcHMiOjIuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfMSI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV8xMCI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV8yIjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzMiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfNCI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV81IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfNyI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV84IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6ZGVsYXlfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpkZWxheV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpmb3JjZV9kZWZlbnNpdmUiOmZhbHNlLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpsaW1pdF8yIjo2MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzpsaW1pdF9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzEiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfMiI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl8zIjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfNSI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl82IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfOCI6MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzptb2RpZmllcl85IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Om1vZGlmaWVyX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3OnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzp5YXdfYWRkIjpmYWxzZSwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X2xlZnQiOjAuMCwiVGVycm9yaXN0Ok1hbnVhbCBZYXc6eWF3X21vZGlmaWVyIjoiRGlzYWJsZWQiLCJUZXJyb3Jpc3Q6TWFudWFsIFlhdzp5YXdfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpNYW51YWwgWWF3Onlhd19yaWdodCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzpib2R5X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6UnVubmluZzpib2R5X3RpY2tzIjoxMi4wLCJUZXJyb3Jpc3Q6UnVubmluZzpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMSI6MS4wLCJUZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV8xMCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMiI6MjIuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfMyI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNiI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfNyI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfOSI6MTYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6Y2hva2VfbW9kZSI6IkRlZmF1bHQiLCJUZXJyb3Jpc3Q6UnVubmluZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV8xIjo0LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzEwIjo1LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzIiOjEuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfMyI6NS4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV80IjoxLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzUiOjYuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfNiI6MS4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV83IjoxLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5XzgiOjMuMCwiVGVycm9yaXN0OlJ1bm5pbmc6ZGVsYXlfOSI6Mi4wLCJUZXJyb3Jpc3Q6UnVubmluZzpkZWxheV9tb2RlIjoiU2VxdWVudGlhbCIsIlRlcnJvcmlzdDpSdW5uaW5nOmRlbGF5X3N0ZXBzIjoxLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmVuYWJsZWQiOnRydWUsIlRlcnJvcmlzdDpSdW5uaW5nOmZvcmNlX2RlZmVuc2l2ZSI6ZmFsc2UsIlRlcnJvcmlzdDpSdW5uaW5nOmxlZnRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0XzIiOjQ4LjAsIlRlcnJvcmlzdDpSdW5uaW5nOmxpbWl0X21vZGUiOiJTd2l0Y2giLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8xIjotNS4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8xMCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8yIjoxNi4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl8zIjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfNSI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl82IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfOCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzptb2RpZmllcl85IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyX21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OlJ1bm5pbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpSdW5uaW5nOm1vZGlmaWVyX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpSdW5uaW5nOnJpZ2h0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzp5YXdfYWRkIjp0cnVlLCJUZXJyb3Jpc3Q6UnVubmluZzp5YXdfbGVmdCI6LTE2LjAsIlRlcnJvcmlzdDpSdW5uaW5nOnlhd19tb2RpZmllciI6IkRpc2FibGVkIiwiVGVycm9yaXN0OlJ1bm5pbmc6eWF3X29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6UnVubmluZzp5YXdfcmlnaHQiOjM2LjAsIlRlcnJvcmlzdDpTbmVha2luZzpib2R5X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Ym9keV90aWNrcyI6MTIuMCwiVGVycm9yaXN0OlNuZWFraW5nOmJvZHlfeWF3Ijp0cnVlLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfMSI6MTYuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzEwIjoxNi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfMiI6MTYuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzMiOjE2LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV80IjoxNi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfNSI6MTYuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzYiOjE2LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV83IjoxNi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Y2hva2VfOCI6MTYuMCwiVGVycm9yaXN0OlNuZWFraW5nOmNob2tlXzkiOjE2LjAsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV9tb2RlIjoiRGVmYXVsdCIsIlRlcnJvcmlzdDpTbmVha2luZzpjaG9rZV9zdGVwcyI6Mi4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMSI6NC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzIiOjguMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzMiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzQiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzUiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzYiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzciOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OlNuZWFraW5nOmRlbGF5X3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpTbmVha2luZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6U25lYWtpbmc6Zm9yY2VfZGVmZW5zaXZlIjpmYWxzZSwiVGVycm9yaXN0OlNuZWFraW5nOmxlZnRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpTbmVha2luZzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bGltaXRfMiI6NTEuMCwiVGVycm9yaXN0OlNuZWFraW5nOmxpbWl0X21vZGUiOiJTd2l0Y2giLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMSI6MC4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzIiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzMiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzQiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzUiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzYiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzciOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzgiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyXzkiOjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX21vZGUiOiJEZWZhdWx0IiwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX29mZnNldCI6LTUuMCwiVGVycm9yaXN0OlNuZWFraW5nOm1vZGlmaWVyX3N0ZXBzIjoyLjAsIlRlcnJvcmlzdDpTbmVha2luZzpyaWdodF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OlNuZWFraW5nOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpTbmVha2luZzp5YXdfbGVmdCI6LTI3LjAsIlRlcnJvcmlzdDpTbmVha2luZzp5YXdfbW9kaWZpZXIiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X29mZnNldCI6NS4wLCJUZXJyb3Jpc3Q6U25lYWtpbmc6eWF3X3JpZ2h0Ijo0NC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Ym9keV9tb2RlIjoiUmFuZG9tIiwiVGVycm9yaXN0OlN0YW5kaW5nOmJvZHlfdGlja3MiOjEyLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEiOjMuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzEwIjoxLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV8yIjoxOS4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfMyI6MTUuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzQiOjYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzUiOjEzLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV82IjoyLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpjaG9rZV83IjoxOC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Y2hva2VfOCI6MjIuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlXzkiOjguMCwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlX21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OlN0YW5kaW5nOmNob2tlX3N0ZXBzIjoxMC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMSI6Ny4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6ZGVsYXlfMTAiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzIiOjUuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzMiOjIuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzQiOjYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzUiOjcuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzYiOjYuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzciOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzgiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5XzkiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5X21vZGUiOiJTZXF1ZW50aWFsIiwiVGVycm9yaXN0OlN0YW5kaW5nOmRlbGF5X3N0ZXBzIjo2LjAsIlRlcnJvcmlzdDpTdGFuZGluZzplbmFibGVkIjp0cnVlLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6Zm9yY2VfZGVmZW5zaXZlIjp0cnVlLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bGVmdF9saW1pdCI6NjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOmxpbWl0XzEiOjYwLjAsIlRlcnJvcmlzdDpTdGFuZGluZzpsaW1pdF8yIjo1MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bGltaXRfbW9kZSI6IlJhbmRvbSIsIlRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8xIjoyMC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfMTAiOjAuMCwiVGVycm9yaXN0OlN0YW5kaW5nOm1vZGlmaWVyXzIiOjE3LjAsIlRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl8zIjoyNi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfNCI6LTE0LjAsIlRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl81Ijo3LjAsIlRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl82IjotNi4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfNyI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfOCI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfOSI6MC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6bW9kaWZpZXJfb2Zmc2V0IjowLjAsIlRlcnJvcmlzdDpTdGFuZGluZzptb2RpZmllcl9zdGVwcyI6Ni4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6cmlnaHRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpTdGFuZGluZzp5YXdfYWRkIjp0cnVlLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X2xlZnQiOi0yMC4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X21vZGlmaWVyIjoiNS1XYXkiLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X29mZnNldCI6NS4wLCJUZXJyb3Jpc3Q6U3RhbmRpbmc6eWF3X3JpZ2h0IjozOC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpib2R5X21vZGUiOiJSYW5kb20iLCJUZXJyb3Jpc3Q6V2Fsa2luZzpib2R5X3RpY2tzIjoxMS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpib2R5X3lhdyI6dHJ1ZSwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMSI6MTIuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfMTAiOjIyLjAsIlRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzIiOjIyLjAsIlRlcnJvcmlzdDpXYWxraW5nOmNob2tlXzMiOjYuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNCI6MTIuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNSI6MTQuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNiI6MjIuMCwiVGVycm9yaXN0OldhbGtpbmc6Y2hva2VfNyI6NS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV84IjoyMi4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV85IjoxMi4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpjaG9rZV9tb2RlIjoiU2VxdWVudGlhbCIsIlRlcnJvcmlzdDpXYWxraW5nOmNob2tlX3N0ZXBzIjoxMC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV8xIjoyLjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzEwIjo1LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzIiOjQuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfMyI6MC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV80Ijo3LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzUiOjguMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfNiI6NS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV83Ijo1LjAsIlRlcnJvcmlzdDpXYWxraW5nOmRlbGF5XzgiOjUuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfOSI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6ZGVsYXlfbW9kZSI6IlNlcXVlbnRpYWwiLCJUZXJyb3Jpc3Q6V2Fsa2luZzpkZWxheV9zdGVwcyI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6ZW5hYmxlZCI6dHJ1ZSwiVGVycm9yaXN0OldhbGtpbmc6Zm9yY2VfZGVmZW5zaXZlIjp0cnVlLCJUZXJyb3Jpc3Q6V2Fsa2luZzpsZWZ0X2xpbWl0Ijo2MC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpsaW1pdF8xIjo2MC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpsaW1pdF8yIjo1MC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzpsaW1pdF9tb2RlIjoiUmFuZG9tIiwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfMSI6LTI4LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzEwIjotMTEuMCwiVGVycm9yaXN0OldhbGtpbmc6bW9kaWZpZXJfMiI6MS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl8zIjotNi4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl80IjotMy4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl81Ijo3LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzYiOi05LjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzciOjEyLjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzgiOi0xLjAsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyXzkiOi0xMS4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl9tb2RlIjoiU2VxdWVudGlhbCIsIlRlcnJvcmlzdDpXYWxraW5nOm1vZGlmaWVyX29mZnNldCI6MC4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzptb2RpZmllcl9zdGVwcyI6MTAuMCwiVGVycm9yaXN0OldhbGtpbmc6cmlnaHRfbGltaXQiOjYwLjAsIlRlcnJvcmlzdDpXYWxraW5nOnlhd19hZGQiOnRydWUsIlRlcnJvcmlzdDpXYWxraW5nOnlhd19sZWZ0IjotMjcuMCwiVGVycm9yaXN0OldhbGtpbmc6eWF3X21vZGlmaWVyIjoiUmFuZG9tIiwiVGVycm9yaXN0OldhbGtpbmc6eWF3X29mZnNldCI6Ni4wLCJUZXJyb3Jpc3Q6V2Fsa2luZzp5YXdfcmlnaHQiOjU1LjAsImFsbG93X29uX3VzZS5lbmFibGVkIjpmYWxzZSwiYW50aV9icnV0ZWZvcmNlLmNvbmRpdGlvbnMiOltdLCJhbnRpX2JydXRlZm9yY2UuZW5hYmxlZCI6ZmFsc2UsImFudGlfYnJ1dGVmb3JjZS5tb2RlIjoiSW5jcmVhc2UiLCJhbnRpX2JydXRlZm9yY2UudGltZSI6MzAuMCwiYXZvaWRfYmFja3N0YWIuZW5hYmxlZCI6ZmFsc2UsImRpc2FibGVycy5ub19lbmVtaWVzIjpmYWxzZSwiZGlzYWJsZXJzLm9uX3dhcm11cCI6ZmFsc2UsImZyZWVzdGFuZGluZy5kaXNhYmxlcnMiOltdLCJmcmVlc3RhbmRpbmcuZW5hYmxlZCI6ZmFsc2UsIm1hbnVhbF95YXcuZGlyZWN0aW9uIjoiRGlzYWJsZWQiLCJzYWZlX2hlYWQuY29uZGl0aW9ucyI6W10sInNhZmVfaGVhZC5lbmFibGVkIjpmYWxzZX0sIkludGVyZmFjZSI6eyJkYW1hZ2VfaW5kaWNhdG9yLmNvbG9yIjoiRkZGRkZGRkYiLCJkYW1hZ2VfaW5kaWNhdG9yLmVuYWJsZWQiOnRydWUsImRhbWFnZV9pbmRpY2F0b3IuZm9udCI6IkRlZmF1bHQiLCJkYW1hZ2VfaW5kaWNhdG9yOngiOjk2MC4wLCJkYW1hZ2VfaW5kaWNhdG9yOnkiOjU0MC4wLCJtYW51YWxfYXJyb3dzLmNvbG9yIjoiQzBDQUZGRkYiLCJtYW51YWxfYXJyb3dzLmVuYWJsZWQiOnRydWUsIm1hbnVhbF9hcnJvd3MuZm9udCI6IkJvbGQiLCJtYW51YWxfYXJyb3dzLmxlZnQiOiI8IiwibWFudWFsX2Fycm93cy5vZmZzZXQiOjQwLjAsIm1hbnVhbF9hcnJvd3MucmlnaHQiOiI+IiwibWFudWFsX2Fycm93cy5zdHlsZSI6IkN1c3RvbSIsInNrZWV0X2luZGljYXRvcnMuQk9EWSI6IkJPRFkiLCJza2VldF9pbmRpY2F0b3JzLkRBIjoiREEiLCJza2VldF9pbmRpY2F0b3JzLkRUIjoiRFQiLCJza2VldF9pbmRpY2F0b3JzLkRVQ0siOiJEVUNLIiwic2tlZXRfaW5kaWNhdG9ycy5GUyI6IkZTIiwic2tlZXRfaW5kaWNhdG9ycy5IQyI6IkhDIiwic2tlZXRfaW5kaWNhdG9ycy5NRCI6Ik1EIiwic2tlZXRfaW5kaWNhdG9ycy5PU0FBIjoiT1NBQSIsInNrZWV0X2luZGljYXRvcnMuUElORyI6IlBJTkciLCJza2VldF9pbmRpY2F0b3JzLlNBRkUiOiJTQUZFIiwic2tlZXRfaW5kaWNhdG9ycy5jdXN0b21pemUiOmZhbHNlLCJza2VldF9pbmRpY2F0b3JzLmVuYWJsZWQiOnRydWUsInNrZWV0X2luZGljYXRvcnMuaXRlbXMiOlsiUElORyIsIkRUIiwiT1NBQSIsIkRVQ0siLCJEQSIsIlNBRkUiLCJCT0RZIiwiTUQiLCJIQyIsIkZTIiwiQzQiXSwidmVsb2NpdHlfd2FybmluZy5jb2xvciI6IkMwQ0FGRkZGIiwidmVsb2NpdHlfd2FybmluZy5lbmFibGVkIjp0cnVlLCJ2ZWxvY2l0eV93YXJuaW5nOngiOjEwNDQuMCwidmVsb2NpdHlfd2FybmluZzp5IjozMjUuMCwid2F0ZXJtYXJrLmNvbF9hIjoiRkZGRkZGRkYiLCJ3YXRlcm1hcmsuY29sX2IiOiJGRkZGRkZGRiIsIndhdGVybWFyay5lZmZlY3RzIjpbIkdyYWRpZW50IiwiTWF0cml4Il0sIndhdGVybWFyay5mb250IjoiQ29uc29sZSIsIndhdGVybWFyay5yYWluYm93Ijp0cnVlLCJ3YXRlcm1hcmsudGV4dCI6IkdPRE1PREtJQkEiLCJ3YXRlcm1hcms6eCI6NzkuMCwid2F0ZXJtYXJrOnkiOjc1My4wfSwiTWlzYyI6eyJhc3BlY3RfcmF0aW8uZW5hYmxlZCI6dHJ1ZSwiYXNwZWN0X3JhdGlvLnByb3BvcnRpb24iOjEzMy4wLCJsb2dfZXZlbnRzLmNvbG9yX2hpdCI6IkMzQ0FGRkZGIiwibG9nX2V2ZW50cy5jb2xvcl9taXNzIjoiRkY5MjkyRkYiLCJsb2dfZXZlbnRzLmVuYWJsZWQiOnRydWUsImxvZ19ldmVudHMub3V0cHV0IjpbIkNvbnNvbGUiLCJEZWJ1ZyIsIk5vdGlmeSJdLCJub3RpZnlfb25fcm91bmRfc3RhcnQuZW5hYmxlZCI6dHJ1ZSwidW5sb2NrX2Zha2VfbGF0ZW5jeS5lbmFibGVkIjpmYWxzZSwidmlld21vZGVsLmVuYWJsZWQiOmZhbHNlLCJ2aWV3bW9kZWwuZm92Ijo2ODAuMCwidmlld21vZGVsLm9mZnNldF94IjoyNS4wLCJ2aWV3bW9kZWwub2Zmc2V0X3kiOjAuMCwidmlld21vZGVsLm9mZnNldF96IjotMTUuMH0sIk1vdmVtZW50Ijp7ImVkZ2Vfc3RvcC5lbmFibGVkIjpmYWxzZSwiZmFrZV9kdWNrLm9uX2ZyZWV6ZXRpbWUiOmZhbHNlLCJmYWtlX2R1Y2sudW5sb2NrX3NwZWVkIjpmYWxzZSwiZmFzdF9sYWRkZXIuZW5hYmxlZCI6dHJ1ZSwibm9fZmFsbF9kYW1hZ2UuZW5hYmxlZCI6ZmFsc2UsInN1cGVyX3Rvc3MuZW5hYmxlZCI6ZmFsc2V9LCJWaXN1YWxzIjp7ImFuaW1hdGlvbnMuZWFydGhxdWFrZSI6dHJ1ZSwiYW5pbWF0aW9ucy5lbmFibGVkIjp0cnVlLCJhbmltYXRpb25zLmluX2FpciI6Ikthbmdhcm9vIiwiYW5pbWF0aW9ucy5tb3ZlX2xlYW4iOjY2LjAsImFuaW1hdGlvbnMub25fZ3JvdW5kIjoiS2FuZ2Fyb28iLCJhbmltYXRpb25zLnBpdGNoX29uX2xhbmQiOmZhbHNlLCJhbmltYXRpb25zLnNsaWRpbmdfY3JvdWNoIjp0cnVlLCJhbmltYXRpb25zLnNsaWRpbmdfc2xvd3dhbGsiOmZhbHNlLCJoaXRfbWFya2VyLmNvbG9yIjoiMDBGRjZGRkYiLCJoaXRfbWFya2VyLmVuYWJsZWQiOnRydWUsImhpdF9tYXJrZXIuc2l6ZSI6My4wLCJoaXRfbWFya2VyLnRoaWNrbmVzcyI6Mi4wLCJoaXRfbWFya2VyLnR5cGUiOlsiV29ybGQiLCJTY3JlZW4iXSwia2VlcF9tb2RlbF90cmFuc3BhcmVuY3kuZW5hYmxlZCI6ZmFsc2UsIm5hZGVfcmFkaXVzLmVuYWJsZWQiOmZhbHNlLCJuYWRlX3JhZGl1cy5tb2xvdG92IjpmYWxzZSwibmFkZV9yYWRpdXMubW9sb3Rvdl9jb2xvciI6IkZGM0YzRkZGIiwibmFkZV9yYWRpdXMuc21va2UiOmZhbHNlLCJuYWRlX3JhZGl1cy5zbW9rZV9jb2xvciI6IjNEOTNGQUZGIiwic2NvcGVfb3ZlcmxheS5hZGRpdGlvbnMiOltdLCJzY29wZV9vdmVybGF5LmNvbG9yIjoiRkZGRkZGODAiLCJzY29wZV9vdmVybGF5LmVuYWJsZWQiOnRydWUsInNjb3BlX292ZXJsYXkuZXhjbHVkZV9saW5lcyI6W10sInNjb3BlX292ZXJsYXkuZ2FwIjo1LjAsInNjb3BlX292ZXJsYXkuc2l6ZSI6MTI5LjB9fQ==+IiwibWFudWFsX2Fycm93cy5zdHlsZSI6IlRlYW1Ta2VldCIsInNrZWV0X2luZGljYXRvcnMuQk9EWSI6IkJPRFkiLCJza2VldF9pbmRpY2F0b3JzLkRBIjoiREEiLCJza2VldF9pbmRpY2F0b3JzLkRUIjoiRFQiLCJza2VldF9pbmRpY2F0b3JzLkRVQ0siOiJEVUNLIiwic2tlZXRfaW5kaWNhdG9ycy5GUyI6IkZTIiwic2tlZXRfaW5kaWNhdG9ycy5IQyI6IkhDIiwic2tlZXRfaW5kaWNhdG9ycy5NRCI6Ik1EIiwic2tlZXRfaW5kaWNhdG9ycy5PU0FBIjoiT1NBQSIsInNrZWV0X2luZGljYXRvcnMuUElORyI6IlBJTkciLCJza2VldF9pbmRpY2F0b3JzLlNBRkUiOiJTQUZFIiwic2tlZXRfaW5kaWNhdG9ycy5jdXN0b21pemUiOmZhbHNlLCJza2VldF9pbmRpY2F0b3JzLmVuYWJsZWQiOmZhbHNlLCJza2VldF9pbmRpY2F0b3JzLml0ZW1zIjpbIlBJTkciLCJEVCIsIk9TQUEiLCJEVUNLIiwiREEiLCJTQUZFIiwiQk9EWSIsIk1EIiwiSEMiLCJGUyIsIkM0Il0sInZlbG9jaXR5X3dhcm5pbmcuY29sb3IiOiJDMENBRkZGRiIsInZlbG9jaXR5X3dhcm5pbmcuZW5hYmxlZCI6ZmFsc2UsInZlbG9jaXR5X3dhcm5pbmc6eCI6ODc2LjAsInZlbG9jaXR5X3dhcm5pbmc6eSI6MTYwLjAsIndhdGVybWFyay5jb2xfYSI6IkZGRkZGRkZGIiwid2F0ZXJtYXJrLmNvbF9iIjoiRkZGRkZGRkYiLCJ3YXRlcm1hcmsuZWZmZWN0cyI6W10sIndhdGVybWFyay5mb250IjoiRGVmYXVsdCIsIndhdGVybWFyay5yYWluYm93IjpmYWxzZSwid2F0ZXJtYXJrLnRleHQiOiJnYXpvbGluYSIsIndhdGVybWFyazp4Ijo4LjAsIndhdGVybWFyazp5Ijo1NDAuMH0sIk1pc2MiOnsiYXNwZWN0X3JhdGlvLmVuYWJsZWQiOmZhbHNlLCJhc3BlY3RfcmF0aW8ucHJvcG9ydGlvbiI6MC4wLCJsb2dfZXZlbnRzLmNvbG9yX2hpdCI6IkMzQ0FGRkZGIiwibG9nX2V2ZW50cy5jb2xvcl9taXNzIjoiRkY5MjkyRkYiLCJsb2dfZXZlbnRzLmVuYWJsZWQiOmZhbHNlLCJsb2dfZXZlbnRzLm91dHB1dCI6W10sIm5vdGlmeV9vbl9yb3VuZF9zdGFydC5lbmFibGVkIjpmYWxzZSwidW5sb2NrX2Zha2VfbGF0ZW5jeS5lbmFibGVkIjpmYWxzZSwidmlld21vZGVsLmVuYWJsZWQiOmZhbHNlLCJ2aWV3bW9kZWwuZm92Ijo2ODAuMCwidmlld21vZGVsLm9mZnNldF94IjoyNS4wLCJ2aWV3bW9kZWwub2Zmc2V0X3kiOjAuMCwidmlld21vZGVsLm9mZnNldF96IjotMTUuMH0sIk1vdmVtZW50Ijp7ImVkZ2Vfc3RvcC5lbmFibGVkIjpmYWxzZSwiZmFrZV9kdWNrLm9uX2ZyZWV6ZXRpbWUiOmZhbHNlLCJmYWtlX2R1Y2sudW5sb2NrX3NwZWVkIjpmYWxzZSwiZmFzdF9sYWRkZXIuZW5hYmxlZCI6ZmFsc2UsIm5vX2ZhbGxfZGFtYWdlLmVuYWJsZWQiOmZhbHNlLCJzdXBlcl90b3NzLmVuYWJsZWQiOmZhbHNlfSwiVmlzdWFscyI6eyJhbmltYXRpb25zLmVhcnRocXVha2UiOmZhbHNlLCJhbmltYXRpb25zLmVuYWJsZWQiOmZhbHNlLCJhbmltYXRpb25zLmluX2FpciI6IkRpc2FibGVkIiwiYW5pbWF0aW9ucy5tb3ZlX2xlYW4iOjAuMCwiYW5pbWF0aW9ucy5vbl9ncm91bmQiOiJEaXNhYmxlZCIsImFuaW1hdGlvbnMucGl0Y2hfb25fbGFuZCI6ZmFsc2UsImFuaW1hdGlvbnMuc2xpZGluZ19jcm91Y2giOmZhbHNlLCJhbmltYXRpb25zLnNsaWRpbmdfc2xvd3dhbGsiOmZhbHNlLCJoaXRfbWFya2VyLmNvbG9yIjoiMDBGRkZGRkYiLCJoaXRfbWFya2VyLmVuYWJsZWQiOmZhbHNlLCJoaXRfbWFya2VyLnNpemUiOjUuMCwiaGl0X21hcmtlci50aGlja25lc3MiOjIuMCwiaGl0X21hcmtlci50eXBlIjpbXSwia2VlcF9tb2RlbF90cmFuc3BhcmVuY3kuZW5hYmxlZCI6ZmFsc2UsIm5hZGVfcmFkaXVzLmVuYWJsZWQiOmZhbHNlLCJuYWRlX3JhZGl1cy5tb2xvdG92IjpmYWxzZSwibmFkZV9yYWRpdXMubW9sb3Rvdl9jb2xvciI6IkZGM0YzRkZGIiwibmFkZV9yYWRpdXMuc21va2UiOmZhbHNlLCJuYWRlX3JhZGl1cy5zbW9rZV9jb2xvciI6IjNEOTNGQUZGIiwic2NvcGVfb3ZlcmxheS5hZGRpdGlvbnMiOltdLCJzY29wZV9vdmVybGF5LmNvbG9yIjoiRkZGRkZGODAiLCJzY29wZV9vdmVybGF5LmVuYWJsZWQiOmZhbHNlLCJzY29wZV9vdmVybGF5LmV4Y2x1ZGVfbGluZXMiOltdLCJzY29wZV9vdmVybGF5LmdhcCI6NS4wLCJzY29wZV9vdmVybGF5LnNpemUiOjUwLjB9fQ==");
            v96 = function(v97)
                -- upvalues: l_v86_0 (ref)
                for v98 = #l_v86_0, 1, -1 do
                    local v99 = l_v86_0[v98];
                    if v99.name == v97 then
                        return v99, v98;
                    end;
                end;
                return nil, -1;
            end;
            local function v104()
                -- upvalues: l_v86_0 (ref), l_v87_0 (ref)
                local v100 = {};
                for v101, v102 in pairs(l_v86_0) do
                    local l_name_0 = v102.name;
                    if l_v87_0[v101] then
                        l_name_0 = string.format("* %s", l_name_0);
                    end;
                    table.insert(v100, l_name_0);
                end;
                if #v100 == 0 then
                    return {
                        [1] = "\aFFFFFF40Empty presets list..."
                    };
                else
                    return v100;
                end;
            end;
            local function v106(v105)
                -- upvalues: l_v86_0 (ref)
                return l_v86_0[v105];
            end;
            local function v111()
                -- upvalues: l_v86_0 (ref), l_v87_0 (ref), l_v85_0 (ref), l_v83_0 (ref), v104 (ref)
                l_v86_0 = {};
                for _, v108 in pairs(l_v87_0) do
                    table.insert(l_v86_0, v108);
                end;
                for _, v110 in pairs(l_v85_0) do
                    table.insert(l_v86_0, v110);
                end;
                l_v83_0.list:update(v104());
            end;
            local function v117()
                -- upvalues: l_v83_0 (ref), v96 (ref), v12 (ref), v16 (ref)
                local v112 = l_v83_0.name:get();
                if v112 == "" then
                    return;
                else
                    local v113, _ = v96(v112);
                    if v113 == nil or v113.data == nil then
                        v12.error("Preset data is invalid!");
                        return;
                    else
                        local v115, v116 = v16.decode(v113.data);
                        data = v116;
                        success = v115;
                        if not success or data == nil then
                            v12.error(data);
                            return;
                        else
                            v115, v116 = v16.import(data);
                            data = v116;
                            success = v115;
                            if not success then
                                v12.error(data);
                                return;
                            else
                                v12.success("Preset successfully loaded!");
                                return;
                            end;
                        end;
                    end;
                end;
            end;
            local function v122()
                -- upvalues: l_v83_0 (ref), v16 (ref), v12 (ref), v96 (ref), l_v85_0 (ref), l_v87_0 (ref), l_v84_0 (ref), v111 (ref)
                local v118 = l_v83_0.name:get();
                if v118 == "" then
                    return;
                else
                    local v119, v120 = v16.encode(v16.export());
                    data = v120;
                    success = v119;
                    if not success then
                        v12.error(data);
                        return;
                    else
                        v119 = {
                            name = v118, 
                            data = data
                        };
                        local v121;
                        v120, v121 = v96(v118);
                        if v120 == nil then
                            v120 = v119;
                            table.insert(l_v85_0, v119);
                        end;
                        if v121 ~= -1 and v121 <= #l_v87_0 then
                            v12.error("Can't modify built-in preset!");
                            return;
                        else
                            v120.data = data;
                            db[l_v84_0] = l_v85_0;
                            v111();
                            v12.success("Preset successfully saved!");
                            return;
                        end;
                    end;
                end;
            end;
            local function v126()
                -- upvalues: l_v83_0 (ref), v96 (ref), v12 (ref), l_v87_0 (ref), l_v85_0 (ref), l_v84_0 (ref), v111 (ref)
                local v123 = l_v83_0.name:get();
                if v123 == "" then
                    return;
                else
                    local v124, v125 = v96(v123);
                    if v124 == nil then
                        v12.error("Preset not selected!");
                        return;
                    elseif v125 ~= -1 and v125 <= #l_v87_0 then
                        v12.error("Can't delete built-in preset!");
                        return;
                    else
                        table.remove(l_v85_0, v125 - #l_v87_0);
                        db[l_v84_0] = l_v85_0;
                        v111();
                        v12.success("Preset successfully deleted!");
                        return;
                    end;
                end;
            end;
            local function v131()
                -- upvalues: v16 (ref), l_clipboard_0 (ref), v12 (ref)
                local v127, v128 = v16.decode(l_clipboard_0.get());
                if not v127 then
                    v12.error(v128);
                    return;
                else
                    local v129, v130 = v16.import(v128);
                    v128 = v130;
                    if not v129 then
                        v12.error(v128);
                        return;
                    else
                        v12.success("Preset successfully imported!");
                        return;
                    end;
                end;
            end;
            local function v134()
                -- upvalues: v16 (ref), v12 (ref), l_clipboard_0 (ref)
                local v132, v133 = v16.encode(v16.export());
                if not v132 then
                    v12.error(v133);
                    return;
                else
                    l_clipboard_0.set(v133);
                    v12.success("Preset successfully exported!");
                    return;
                end;
            end;
            l_v83_0.list = v81.presets:list("##presets.list", {});
            l_v83_0.name = v81.presets:input("Preset Name");
            v81.presets:button(l_v59_0(v11.get("check"), 5), v117, false):tooltip("Load Preset");
            v81.presets:button(l_v59_0(v8("\a{Link Active}", v11.get("floppy-disk")), 7), v122, true):tooltip("Save Preset");
            v81.presets:button(l_v59_0(v8("\aFF5050FF", v11.get("trash-can")), 7), v126, true):tooltip("Delete Preset");
            v81.presets:button(l_v59_0(v11.get("up-from-bracket"), 7), v134, true):tooltip("Export Preset");
            v81.presets:button(l_v59_0(v11.get("down-to-bracket"), 7), v131, true):tooltip("Import Preset");
            v111();
            l_v83_0.list:set_callback(function(v135)
                -- upvalues: v106 (ref), l_v83_0 (ref)
                local v136 = v135:get();
                if v136 == nil or v136 <= 0 then
                    return;
                else
                    local v137 = v106(v136);
                    if v137 == nil then
                        return;
                    else
                        l_v83_0.name:set(v137.name);
                        return;
                    end;
                end;
            end, true);
        end;
    end;
    v80 = {};
    v81 = v11.get("shield");
    v82 = {
        selector = ui.create(v81, "##selector", v19), 
        tweaks = ui.create(v81, "Tweaks", v53), 
        hotkeys = ui.create(v81, "Hotkeys", v19), 
        states = ui.create(v81, "States", v19), 
        builder = ui.create(v81, "Builder", v53), 
        defensive = ui.create(v81, "##defensive", v53)
    };
    v83 = {};
    v84 = {
        v8(l_v55_0(2), l_v65_0("gears"), l_v55_0(5), "Settings"), 
        v8(l_v55_0(2), l_v65_0("layer-group"), l_v55_0(7), "Builder")
    };
    v83.list = v82.selector:list("##selector.list", v84);
    do
        local l_v84_1 = v84;
        v85 = function(v139)
            -- upvalues: l_v84_1 (ref)
            local v140 = v139:get();
            local v141 = {};
            for v142 = 1, #l_v84_1 do
                local v143 = l_v84_1[v142];
                if v140 == v142 then
                    v141[v142] = string.gsub(v143, "\a{Small Text}", "\a{Link Active}");
                else
                    v141[v142] = string.gsub(v143, "\a{Link Active}", "\a{Small Text}");
                end;
            end;
            v139:update(v141);
        end;
        v83.list:set_callback(v85, true);
    end;
    v84 = {
        avoid_backstab = {
            enabled = v16.push("Anti-Aim", "avoid_backstab.enabled", v82.tweaks:switch(v8(l_v55_0(2), l_v65_0("knife-kitchen"), l_v55_0(6), "Avoid Backstab")))
        }
    };
    v86 = {
        enabled = v16.push("Anti-Aim", "allow_on_use.enabled", v82.tweaks:switch(v8(l_v55_0(2), l_v65_0("shield-exclamation"), l_v55_0(7), "Allow on Use")))
    };
    v87 = v86.enabled:create();
    v86.yaw_base = v16.push("Anti-Aim", "allow_on_use.yaw_base", v87:combo("Yaw Base", {
        [1] = "Local View", 
        [2] = "At Target"
    }));
    local v144 = nil;
    do
        local l_v87_1 = v87;
        local function v147(v146)
            -- upvalues: l_v87_1 (ref)
            l_v87_1:visibility(v146:get());
        end;
        v86.enabled:set_callback(v147, true);
        v84.allow_on_use = v86;
    end;
    v87 = {
        enabled = v16.push("Anti-Aim", "anti_bruteforce.enabled", v82.tweaks:switch(v8(l_v55_0(2), l_v65_0("repeat"), l_v55_0(7), "Anti-Bruteforce")))
    };
    v144 = v87.enabled:create();
    v87.conditions = v16.push("Anti-Aim", "anti_bruteforce.conditions", v144:selectable("Conditions", {
        [1] = "Standing", 
        [2] = "Running", 
        [3] = "Walking", 
        [4] = "Crouching", 
        [5] = "Sneaking", 
        [6] = "In Air", 
        [7] = "Air Crouch"
    }));
    v87.mode = v16.push("Anti-Aim", "anti_bruteforce.mode", v144:combo("Mode", {
        [1] = "Increase", 
        [2] = "Decrease", 
        [3] = "Meta"
    }));
    v87.time = v16.push("Anti-Aim", "anti_bruteforce.time", v144:slider("Time", 0, 50, 30, 0.1, "s"));
    local v148 = nil;
    do
        local l_v144_0 = v144;
        local function v151(v150)
            -- upvalues: l_v144_0 (ref)
            l_v144_0:visibility(v150:get());
        end;
        v87.enabled:set_callback(v151, true);
        v84.anti_bruteforce = v87;
    end;
    v144 = {
        enabled = v16.push("Anti-Aim", "safe_head.enabled", v82.tweaks:switch(v8(" ", l_v65_0("face-head-bandage"), l_v55_0(5), " ", "Safe Head")))
    };
    v148 = v144.enabled:create();
    v144.conditions = v16.push("Anti-Aim", "safe_head.conditions", v148:listable("##safe_head.conditions", {
        [1] = "Standing", 
        [2] = "Crouch", 
        [3] = "Air Crouch", 
        [4] = "Air Knife", 
        [5] = "Air Taser", 
        [6] = "Distance"
    }));
    local v152 = nil;
    do
        local l_v148_0 = v148;
        local function v155(v154)
            -- upvalues: l_v148_0 (ref)
            l_v148_0:visibility(v154:get());
        end;
        v144.enabled:set_callback(v155, true);
        v84.safe_head = v144;
    end;
    v148 = {};
    local v156 = v82.tweaks:label(v8(l_v55_0(2), l_v65_0("ban", "\a{Small Text}"), l_v55_0(7), "Disablers")):create();
    v148.on_warmup = v16.push("Anti-Aim", "disablers.on_warmup", v156:switch(v8(l_v55_0(2), l_v65_0("person-rifle"), l_v55_0(7), "On Warmup")));
    v148.no_enemies = v16.push("Anti-Aim", "disablers.no_enemies", v156:switch(v8(l_v55_0(2), l_v65_0("users-slash"), l_v55_0(6), "No Enemies")));
    v84.disablers = v148;
    v80.tweaks = v84;
    v85 = {};
    v86 = {
        enabled = v16.push("Anti-Aim", "freestanding.enabled", v82.hotkeys:switch("Freestanding"))
    };
    v87 = v86.enabled:create();
    v86.disablers = v16.push("Anti-Aim", "freestanding.disablers", v87:selectable("Disablers", {
        [1] = "Standing", 
        [2] = "Running", 
        [3] = "Walking", 
        [4] = "Crouching", 
        [5] = "Sneaking", 
        [6] = "In Air", 
        [7] = "Air Crouch"
    }));
    v85.freestanding = v86;
    v85.manual_yaw = {
        direction = v16.push("Anti-Aim", "manual_yaw.direction", v82.hotkeys:combo("Manual Yaw", {
            [1] = "Disabled", 
            [2] = "Left", 
            [3] = "Right", 
            [4] = "Backward", 
            [5] = "Forward"
        }))
    };
    v80.hotkeys = v85;
    v86 = function()
        -- upvalues: v80 (ref), v10 (ref)
        local v157 = v80.builder.state:get();
        local v158 = v80.builder.team:get();
        for v159 = 1, #v10.teams do
            local v160 = v10.teams[v159];
            local v161 = v160 == v158;
            for v162 = 1, #v10.states do
                local v163 = v10.states[v162];
                local v164 = v80.builder[v160][v163];
                if v164 ~= nil then
                    local v165 = v163 == v157;
                    local v166 = v161 and v165;
                    v164.enabled:visibility(v166);
                    if not v164.enabled:get() then
                        v166 = false;
                    end;
                    v164.yaw_offset:visibility(v166);
                    v164.yaw_add:visibility(v166);
                    v164.yaw_modifier:visibility(v166);
                    v164.body_yaw:visibility(v166);
                    v164.force_defensive:visibility(v166);
                end;
            end;
        end;
    end;
    do
        local l_v82_0, l_v83_1, l_v86_1, l_v144_1 = v82, v83, v86, v144;
        v87 = function(v171, v172)
            -- upvalues: v16 (ref), l_v82_0 (ref), l_v62_0 (ref), l_v86_1 (ref), v72 (ref), l_v59_0 (ref), v8 (ref), l_v65_0 (ref), l_v55_0 (ref)
            local v173 = {};
            local function v175(v174)
                -- upvalues: v171 (ref), v172 (ref)
                return v171 .. ":" .. v172 .. ":" .. v174;
            end;
            v173.enabled = v16.push("Anti-Aim", v175("enabled"), l_v82_0.builder:switch(l_v62_0("Allow " .. v172, v175("enabled")))):set_callback(l_v86_1);
            v173.yaw_offset = v16.push("Anti-Aim", v175("yaw_offset"), l_v82_0.builder:slider(l_v62_0(v72("Yaw Offset"), v175("yaw_offset")), -180, 180, 0, nil, "\194\176"));
            v173.yaw_add = v16.push("Anti-Aim", v175("yaw_add"), l_v82_0.builder:switch(l_v62_0(v72("Yaw Add"), v175("yaw_add"))));
            local v176 = v173.yaw_add:create();
            v173.yaw_left = v16.push("Anti-Aim", v175("yaw_left"), v176:slider(v72("Left Offset"), -180, 180, 0, nil, "\194\176"));
            v173.yaw_right = v16.push("Anti-Aim", v175("yaw_right"), v176:slider(v72("Right Offset"), -180, 180, 0, nil, "\194\176"));
            v173.delay_mode = v16.push("Anti-Aim", v175("delay_mode"), v176:combo("Mode", {
                [1] = "Default", 
                [2] = "Randomize", 
                [3] = "Sequential"
            }));
            v173.delay_steps = v16.push("Anti-Aim", v175("delay_steps"), v176:slider("Steps", 1, 10, 2));
            local v177 = {
                [1] = "st", 
                [2] = "nd", 
                [3] = "rd"
            };
            local function v179(v178)
                if v178 == 0 then
                    return "Off";
                else
                    return v178 .. "t";
                end;
            end;
            for v180 = 1, 10 do
                local v181 = "delay_" .. v180;
                local v182 = v177[v180] or "th";
                v173[v181] = v16.push("Anti-Aim", v175(v181), v176:slider(string.format(v72("%i%s Delay"), v180, v182), 0, 16, 0, nil, v179));
            end;
            local function v186()
                -- upvalues: v173 (ref)
                for v183 = 1, v173.delay_steps:get() do
                    local v184 = "delay_" .. v183;
                    local v185 = math.random(0, 10);
                    v173[v184]:set(v185);
                end;
            end;
            v173.shuffle_delay = v176:button(l_v59_0(v8(l_v65_0("shuffle"), l_v55_0(2), "Shuffle"), 45), v186, true);
            local function v191()
                -- upvalues: v173 (ref)
                local v187 = v173.yaw_add:get();
                local v188 = v173.delay_mode:get();
                local v189 = v173.delay_steps:get();
                v173.yaw_left:visibility(v187);
                v173.yaw_right:visibility(v187);
                v173.delay_mode:visibility(v187);
                v173.delay_steps:visibility(v187 and v188 == "Sequential");
                for v190 = 1, 10 do
                    v173["delay_" .. v190]:visibility(v187 and v188 == "Sequential" and v190 <= v189);
                end;
                if v188 ~= "Sequential" then
                    v173.delay_1:visibility(v187 and (v188 == "Default" or v188 == "Randomize"));
                    v173.delay_2:visibility(v187 and v188 == "Randomize");
                end;
                v173.shuffle_delay:visibility(v187 and v188 == "Sequential");
            end;
            v173.yaw_add:set_callback(v191);
            v173.delay_mode:set_callback(v191);
            v173.delay_steps:set_callback(v191);
            v191();
            v173.yaw_modifier = v16.push("Anti-Aim", v175("yaw_modifier"), l_v82_0.builder:combo(l_v62_0(v72("Yaw Modifier"), v175("yaw_modifier")), {
                [1] = "Disabled", 
                [2] = "Center", 
                [3] = "Offset", 
                [4] = "Random", 
                [5] = "Spin", 
                [6] = "3-Way", 
                [7] = "5-Way"
            }));
            v177 = v173.yaw_modifier:create();
            v173.modifier_mode = v16.push("Anti-Aim", v175("modifier_mode"), v177:combo("Mode", {
                [1] = "Default", 
                [2] = "Randomize", 
                [3] = "Sequential"
            }));
            v173.modifier_offset = v16.push("Anti-Aim", v175("modifier_offset"), v177:slider(v72("Offset"), -180, 180, 0, nil, "\194\176"));
            v173.modifier_steps = v16.push("Anti-Aim", v175("modifier_steps"), v177:slider("Steps", 1, 10, 2));
            v179 = {
                [1] = "st", 
                [2] = "nd", 
                [3] = "rd"
            };
            for v192 = 1, 10 do
                local v193 = "modifier_" .. v192;
                local v194 = v179[v192] or "th";
                v173[v193] = v16.push("Anti-Aim", v175(v193), v177:slider(string.format(v72("%i%s Offset"), v192, v194), -180, 180, 0, nil, "\194\176"));
            end;
            v186 = function()
                -- upvalues: v173 (ref)
                for v195 = 1, v173.modifier_steps:get() do
                    local v196 = "modifier_" .. v195;
                    local v197 = math.random(-30, 30);
                    v173[v196]:set(v197);
                end;
            end;
            v173.shuffle_modifier = v177:button(l_v59_0(v8(l_v65_0("shuffle"), l_v55_0(2), "Shuffle"), 45), v186, true);
            v191 = function()
                -- upvalues: v173 (ref)
                local v198 = v173.yaw_modifier:get();
                local v199 = v173.modifier_mode:get();
                local v200 = v173.modifier_steps:get();
                v173.modifier_mode:visibility(v198 ~= "Disabled");
                v173.modifier_offset:visibility(v198 ~= "Disabled" and v199 == "Default");
                v173.modifier_steps:visibility(v198 ~= "Disabled" and v199 == "Sequential");
                for v201 = 1, 10 do
                    v173["modifier_" .. v201]:visibility(v198 ~= "Disabled" and v199 == "Sequential" and v201 <= v200);
                end;
                if v199 ~= "Sequential" then
                    v173.modifier_1:visibility(v198 ~= "Disabled" and v199 == "Randomize");
                    v173.modifier_2:visibility(v198 ~= "Disabled" and v199 == "Randomize");
                end;
                v173.shuffle_modifier:visibility(v198 ~= "Disabled" and v199 == "Sequential");
            end;
            v173.yaw_modifier:set_callback(v191);
            v173.modifier_mode:set_callback(v191);
            v173.modifier_steps:set_callback(v191);
            v191();
            v173.body_yaw = v16.push("Anti-Aim", v175("body_yaw"), l_v82_0.builder:switch(l_v62_0(v72("Body Yaw"), v175("body_yaw"))));
            v179 = v173.body_yaw:create();
            v173.body_mode = v16.push("Anti-Aim", v175("body_mode"), v179:combo("Body Mode", {
                [1] = "Default", 
                [2] = "Ticks", 
                [3] = "Random"
            }));
            v173.body_ticks = v16.push("Anti-Aim", v175("body_ticks"), v179:slider(v72("Ticks"), 4, 16, 4, nil, "t"));
            v173.limit_mode = v16.push("Anti-Aim", v175("limit_mode"), v179:combo("Limit Mode", {
                [1] = "Default", 
                [2] = "Switch", 
                [3] = "Random"
            }));
            v173.left_limit = v16.push("Anti-Aim", v175("left_limit"), v179:slider(v72("Left Limit"), 0, 60, 60, nil, "\194\176"));
            v173.right_limit = v16.push("Anti-Aim", v175("right_limit"), v179:slider(v72("Right Limit"), 0, 60, 60, nil, "\194\176"));
            v173.limit_1 = v16.push("Anti-Aim", v175("limit_1"), v179:slider(v72("From"), 0, 60, 60, nil, "\194\176"));
            v173.limit_2 = v16.push("Anti-Aim", v175("limit_2"), v179:slider(v72("To"), 0, 60, 60, nil, "\194\176"));
            v186 = function()
                -- upvalues: v173 (ref)
                local v202 = v173.body_yaw:get();
                local v203 = v173.body_mode:get();
                local v204 = v173.limit_mode:get();
                v173.body_mode:visibility(v202);
                v173.body_ticks:visibility(v202 and (v203 == "Ticks" or v203 == "Random"));
                v173.limit_mode:visibility(v202);
                v173.left_limit:visibility(v202 and v204 == "Default");
                v173.right_limit:visibility(v202 and v204 == "Default");
                v173.limit_1:visibility(v202 and (v204 == "Switch" or v204 == "Random"));
                v173.limit_2:visibility(v202 and (v204 == "Switch" or v204 == "Random"));
            end;
            v173.body_yaw:set_callback(v186);
            v173.body_mode:set_callback(v186);
            v173.limit_mode:set_callback(v186);
            v186();
            v173.force_defensive = v16.push("Anti-Aim", v175("force_defensive"), l_v82_0.defensive:switch(l_v62_0("Force Defensive", v175("force_defensive"))));
            v186 = v173.force_defensive:create();
            v173.choke_mode = v16.push("Anti-Aim", v175("choke_mode"), v186:combo("Mode", {
                [1] = "Default", 
                [2] = "Custom", 
                [3] = "Randomize", 
                [4] = "Sequential"
            }));
            v173.choke_steps = v16.push("Anti-Aim", v175("choke_steps"), v186:slider("Steps", 1, 10, 2));
            v191 = {
                [1] = "st", 
                [2] = "nd", 
                [3] = "rd"
            };
            local function v206(v205)
                if v205 == 16 then
                    return "Default";
                else
                    return v205 .. "t";
                end;
            end;
            for v207 = 1, 10 do
                local v208 = "choke_" .. v207;
                local v209 = v191[v207] or "th";
                v173[v208] = v16.push("Anti-Aim", v175(v208), v186:slider(string.format(v72("%i%s Choke"), v207, v209), 1, 22, 16, nil, v206));
            end;
            local _ = nil;
            local function v215()
                -- upvalues: v173 (ref)
                local v211 = v173.force_defensive:get();
                local v212 = v173.choke_mode:get();
                local v213 = v173.choke_steps:get();
                v173.choke_mode:visibility(v211);
                v173.choke_steps:visibility(v211 and v212 == "Sequential");
                for v214 = 1, 10 do
                    v173["choke_" .. v214]:visibility(v211 and v212 == "Sequential" and v214 <= v213);
                end;
                if v212 ~= "Sequential" then
                    v173.choke_1:visibility(v211 and (v212 == "Custom" or v212 == "Randomize"));
                    v173.choke_2:visibility(v211 and v212 == "Randomize");
                end;
            end;
            v173.force_defensive:set_callback(v215);
            v173.choke_mode:set_callback(v215);
            v173.choke_steps:set_callback(v215);
            v215();
            return v173;
        end;
        l_v144_1 = {
            team = l_v82_0.states:combo(v8(l_v55_0(2), l_v65_0("user-pen"), l_v55_0(5), "Team"), v10.teams):set_callback(l_v86_1), 
            state = l_v82_0.states:combo(v8(l_v55_0(2), l_v65_0("satellite"), l_v55_0(7), "State"), v10.states):set_callback(l_v86_1)
        };
        for v216 = 1, #v10.teams do
            local v217 = v10.teams[v216];
            local v218 = {};
            for v219 = 1, #v10.states do
                local v220 = v10.states[v219];
                v218[v220] = v87(v217, v220);
            end;
            l_v144_1[v217] = v218;
        end;
        v148 = function(v221)
            local v222 = {};
            for v223, _ in pairs(v221) do
                local v225 = v221[v223];
                if v225 ~= nil and v225:type() ~= "button" then
                    v222[v223] = v225:get();
                end;
            end;
            return v222;
        end;
        v152 = function(v226, v227)
            for v228, _ in pairs(v226) do
                local v230 = v226[v228];
                local v231 = v227[v228];
                if v230 ~= nil and v230:type() ~= "button" and v231 ~= nil then
                    v230:set(v231);
                end;
            end;
        end;
        do
            local l_v148_1, l_v152_0 = v148, v152;
            v156 = function()
                -- upvalues: l_v144_1 (ref), l_v148_1 (ref), l_base64_0 (ref), l_clipboard_0 (ref), v12 (ref)
                local v234 = l_v144_1.team:get();
                local v235 = l_v144_1.state:get();
                local v236 = l_v144_1[v234][v235];
                if v236 == nil then
                    return;
                else
                    local v237 = l_v148_1(v236);
                    local l_status_2, l_result_2 = pcall(json.stringify, v237);
                    v237 = l_result_2;
                    success = l_status_2;
                    if not success then
                        return;
                    else
                        l_status_2, l_result_2 = pcall(l_base64_0.encode, v237);
                        v237 = l_result_2;
                        success = l_status_2;
                        if not success then
                            return;
                        else
                            l_clipboard_0.set(v237);
                            v12.success("State successfully exported!");
                            return;
                        end;
                    end;
                end;
            end;
            local function v243()
                -- upvalues: l_clipboard_0 (ref), l_base64_0 (ref), l_v144_1 (ref), l_v152_0 (ref), v12 (ref)
                local l_status_3, l_result_3 = pcall(l_clipboard_0.get);
                data = l_result_3;
                success = l_status_3;
                if not success then
                    return;
                else
                    l_status_3, l_result_3 = pcall(l_base64_0.decode, data);
                    data = l_result_3;
                    success = l_status_3;
                    if not success then
                        return;
                    else
                        l_status_3, l_result_3 = pcall(json.parse, data);
                        data = l_result_3;
                        success = l_status_3;
                        if not success then
                            return;
                        else
                            l_status_3 = l_v144_1.team:get();
                            l_result_3 = l_v144_1.state:get();
                            local v242 = l_v144_1[l_status_3][l_result_3];
                            if v242 == nil then
                                return;
                            else
                                l_v152_0(v242, data);
                                v12.success("State successfully imported!");
                                return;
                            end;
                        end;
                    end;
                end;
            end;
            local function v249()
                -- upvalues: l_v144_1 (ref), l_v148_1 (ref), l_v152_0 (ref), v12 (ref)
                local v244 = l_v144_1.team:get();
                local v245 = l_v144_1.state:get();
                local v246 = l_v144_1[v244][v245];
                if v246 == nil then
                    return;
                else
                    local v247 = l_v148_1(v246);
                    local v248 = l_v144_1[v244 == "Counter-Terrorist" and "Terrorist" or "Counter-Terrorist"][v245];
                    if v248 == nil then
                        return;
                    else
                        l_v152_0(v248, v247);
                        v12.success("State successfully transfered to opposite team!");
                        return;
                    end;
                end;
            end;
            local v250 = l_v144_1.state:create();
            v250:button(l_v59_0(v8(l_v65_0("arrow-up-from-bracket"), l_v55_0(3), "Copy"), 5), v156, true);
            v250:button(l_v59_0(v8(l_v65_0("arrow-down-to-bracket"), l_v55_0(3), "Paste"), 5), v243, true);
            v250:button(l_v59_0(v8(l_v65_0("send-backward"), l_v55_0(3), "Send to another team"), 3), v249, true);
            v80.builder = l_v144_1;
        end;
        l_v86_1();
        v148 = nil;
        v152 = function()
            -- upvalues: l_v83_1 (ref), l_v82_0 (ref)
            local v251 = l_v83_1.list:get();
            l_v82_0.tweaks:visibility(v251 == 1);
            l_v82_0.hotkeys:visibility(v251 == 1);
            l_v82_0.states:visibility(v251 == 2);
            l_v82_0.builder:visibility(v251 == 2);
            l_v82_0.defensive:visibility(v251 == 2);
        end;
        v152();
        l_v83_1.list:set_callback(v152);
        l_play_0.antiaim = v80;
    end;
    v81 = {};
    v82 = v11.get("scribble");
    v83 = {
        interface = ui.create(v82, "Interface", v53), 
        misc = ui.create(v82, "Miscellaneous", v19), 
        visuals = ui.create(v82, "Visuals", v53), 
        movement = ui.create(v82, "Movement", v19)
    };
    v84 = {};
    v85 = {
        enabled = v16.push("Misc", "aspect_ratio.enabled", v83.misc:switch(v8(l_v55_0(2), l_v65_0("tv"), l_v55_0(6), "Aspect Ratio")))
    };
    v86 = v85.enabled:create();
    v87 = {
        [1] = "5:4", 
        [2] = "4:3", 
        [3] = "3:2", 
        [4] = "16:10", 
        [5] = "16:9"
    };
    v144 = {
        ["5:4"] = 125, 
        ["16:9"] = 177, 
        ["16:10"] = 160, 
        ["3:2"] = 150, 
        ["4:3"] = 133
    };
    v148 = {};
    for v252 = 1, #v87 do
        local v253 = v87[v252];
        v148[v144[v253]] = v253;
    end;
    do
        local l_v85_1, l_v86_2, l_v87_2 = v85, v86, v87;
        do
            local l_v148_2 = v148;
            v152 = function(v258)
                -- upvalues: l_v148_2 (ref)
                if v258 == 0 then
                    return "Off";
                else
                    return l_v148_2[v258];
                end;
            end;
            l_v85_1.proportion = v16.push("Misc", "aspect_ratio.proportion", l_v86_2:slider("Aspect Ratio", 0, 200, 0, 0.01, v152));
            for v259 = 1, #l_v87_2 do
                local v260 = l_v87_2[v259];
                local v261 = v144[v260];
                do
                    local l_v261_0 = v261;
                    local function v263()
                        -- upvalues: l_v85_1 (ref), l_v261_0 (ref)
                        l_v85_1.proportion:set(l_v261_0);
                    end;
                    l_v86_2:button(l_v59_0(v260, 3), v263, true);
                end;
            end;
        end;
        l_v87_2 = nil;
        do
            local l_l_v86_2_0 = l_v86_2;
            v144 = function(v265)
                -- upvalues: l_l_v86_2_0 (ref)
                l_l_v86_2_0:visibility(v265:get());
            end;
            l_v85_1.enabled:set_callback(v144, true);
            v84.aspect_ratio = l_v85_1;
        end;
        l_v86_2 = {
            enabled = v16.push("Misc", "viewmodel.enabled", v83.misc:switch(v8(l_v55_0(1), " ", l_v65_0("hand"), l_v55_0(7), "Viewmodel")))
        };
        l_v87_2 = l_v86_2.enabled:create();
        l_v86_2.fov = v16.push("Misc", "viewmodel.fov", l_v87_2:slider("Field of View", 0, 1000, 680, 0.1, "\194\176"));
        l_v86_2.offset_x = v16.push("Misc", "viewmodel.offset_x", l_v87_2:slider("Offset X", -100, 100, 25, 0.1, "\194\176"));
        l_v86_2.offset_y = v16.push("Misc", "viewmodel.offset_y", l_v87_2:slider("Offset Y", -100, 100, 0, 0.1, "\194\176"));
        l_v86_2.offset_z = v16.push("Misc", "viewmodel.offset_z", l_v87_2:slider("Offset Z", -100, 100, -15, 0.1, "\194\176"));
        v144 = function()
            -- upvalues: l_v86_2 (ref)
            l_v86_2.fov:reset();
            l_v86_2.offset_x:reset();
            l_v86_2.offset_y:reset();
            l_v86_2.offset_z:reset();
        end;
        l_v87_2:button(l_v59_0(v8(l_v65_0("arrow-rotate-left", "\aFF5050FF"), l_v55_0(2), "Reset"), 48), v144, true);
        v144 = nil;
        do
            local l_l_v87_2_0 = l_v87_2;
            v148 = function(v267)
                -- upvalues: l_l_v87_2_0 (ref)
                l_l_v87_2_0:visibility(v267:get());
            end;
            l_v86_2.enabled:set_callback(v148, true);
            v84.viewmodel = l_v86_2;
        end;
        l_v87_2 = {
            enabled = v16.push("Misc", "log_events.enabled", v83.misc:switch(v8(l_v55_0(3), l_v65_0("calendar-lines-pen"), l_v55_0(4), " ", "Log Events")))
        };
        v144 = l_v87_2.enabled:create();
        l_v87_2.output = v16.push("Misc", "log_events.output", v144:selectable("Output", {
            [1] = "Console", 
            [2] = "Debug", 
            [3] = "Notify"
        }));
        l_v87_2.color_hit = v16.push("Misc", "log_events.color_hit", v144:color_picker("Hit Color", color(195, 202, 255, 255)));
        l_v87_2.color_miss = v16.push("Misc", "log_events.color_miss", v144:color_picker("Miss Color", color(255, 146, 146, 255)));
        v148 = nil;
        v152 = function()
            -- upvalues: l_v87_2 (ref)
            local v268 = l_v87_2.enabled:get();
            l_v87_2.output:visibility(v268);
            if #l_v87_2.output:get() == 0 then
                v268 = false;
            end;
            l_v87_2.color_hit:visibility(v268);
            l_v87_2.color_miss:visibility(v268);
        end;
        l_v87_2.output:set_callback(v152);
        l_v87_2.enabled:set_callback(v152);
        v152();
        v84.log_events = l_v87_2;
        v84.unlock_fake_latency = {
            enabled = v16.push("Misc", "unlock_fake_latency.enabled", v83.misc:switch(v8(l_v55_0(3), l_v65_0("satellite-dish"), l_v55_0(5), " ", "Unlock Fake Latency")))
        };
        v84.notify_on_round_start = {
            enabled = v16.push("Misc", "notify_on_round_start.enabled", v83.misc:switch(v8(l_v55_0(3), l_v65_0("bell"), l_v55_0(7), "Notify on Round Start")))
        };
        v81.misc = v84;
    end;
    v85 = {};
    v86 = {
        label = v83.interface:label(v8(l_v55_0(3), l_v65_0("pen-to-square"), l_v55_0(6), "Watermark"))
    };
    v87 = v86.label:create();
    v86.font = v16.push("Interface", "watermark.font", v87:combo("Font", {
        [1] = "Default", 
        [2] = "Small", 
        [3] = "Console", 
        [4] = "Bold"
    }));
    v86.text = v16.push("Interface", "watermark.text", v87:input("Text", v9.name));
    v86.effects = v16.push("Interface", "watermark.effects", v87:selectable("Effects", {
        [1] = "Gradient", 
        [2] = "Matrix", 
        [3] = "Pulse"
    }));
    v86.rainbow = v16.push("Interface", "watermark.rainbow", v87:switch("Rainbow"));
    v86.col_a = v16.push("Interface", "watermark.col_a", v87:color_picker("Color", color(255, 255, 255, 255)));
    v86.col_b = v16.push("Interface", "watermark.col_b", v87:color_picker("2nd Color", color(255, 255, 255, 255)));
    do
        local l_v86_3, l_v87_3, l_v144_2, l_v152_1 = v86, v87, v144, v152;
        l_v144_2 = function()
            -- upvalues: l_v86_3 (ref)
            return {
                font = l_v86_3.font:get(), 
                text = l_v86_3.text:get(), 
                effects = l_v86_3.effects:get(), 
                rainbow = l_v86_3.rainbow:get(), 
                col_a = l_v86_3.col_a:get():to_hex(), 
                col_b = l_v86_3.col_b:get():to_hex()
            };
        end;
        v148 = function(v273)
            -- upvalues: l_v86_3 (ref)
            l_v86_3.font:set(v273.font);
            l_v86_3.text:set(v273.text);
            l_v86_3.effects:set(v273.effects);
            l_v86_3.rainbow:set(v273.rainbow);
            l_v86_3.col_a:set(color(v273.col_a));
            l_v86_3.col_b:set(color(v273.col_b));
        end;
        do
            local l_l_v144_2_0, l_v148_3 = l_v144_2, v148;
            l_v152_1 = function()
                -- upvalues: l_l_v144_2_0 (ref), l_base64_0 (ref), l_clipboard_0 (ref), v12 (ref)
                local v276 = l_l_v144_2_0();
                local l_status_4, l_result_4 = pcall(json.stringify, v276);
                v276 = l_result_4;
                success = l_status_4;
                if not success then
                    return;
                else
                    l_status_4, l_result_4 = pcall(l_base64_0.encode, v276);
                    v276 = l_result_4;
                    success = l_status_4;
                    if not success then
                        return;
                    else
                        l_clipboard_0.set(v276);
                        v12.success("Watermark settings successfully exported!");
                        return;
                    end;
                end;
            end;
            v156 = function()
                -- upvalues: l_clipboard_0 (ref), l_base64_0 (ref), l_v148_3 (ref), v12 (ref)
                local l_status_5, l_result_5 = pcall(l_clipboard_0.get);
                data = l_result_5;
                success = l_status_5;
                if not success then
                    return;
                else
                    l_status_5, l_result_5 = pcall(l_base64_0.decode, data);
                    data = l_result_5;
                    success = l_status_5;
                    if not success then
                        return;
                    else
                        l_status_5, l_result_5 = pcall(json.parse, data);
                        data = l_result_5;
                        success = l_status_5;
                        if not success then
                            return;
                        else
                            l_v148_3(data);
                            v12.success("Watermark settings successfully imported!");
                            return;
                        end;
                    end;
                end;
            end;
            l_v87_3:button(l_v59_0(v8(l_v65_0("arrow-up-from-bracket"), l_v55_0(3), "Copy"), 15), l_v152_1, true);
            l_v87_3:button(l_v59_0(v8(l_v65_0("arrow-down-to-bracket"), l_v55_0(3), "Paste"), 15), v156, true);
        end;
        l_v144_2 = nil;
        v148 = function(_)
            -- upvalues: l_v86_3 (ref)
            local v282 = l_v86_3.effects:get("Gradient");
            local v283 = l_v86_3.rainbow:get();
            l_v86_3.rainbow:visibility(v282);
            l_v86_3.col_a:visibility(not v283);
            l_v86_3.col_b:visibility(not v283 and v282);
        end;
        l_v86_3.rainbow:set_callback(v148);
        l_v86_3.effects:set_callback(v148);
        v148();
        v85.watermark = l_v86_3;
        l_v87_3 = {};
        l_v144_2 = {
            [1] = "PING", 
            [2] = "DT", 
            [3] = "OSAA", 
            [4] = "DUCK", 
            [5] = "DA", 
            [6] = "SAFE", 
            [7] = "BODY", 
            [8] = "MD", 
            [9] = "HC", 
            [10] = "FS", 
            [11] = "C4"
        };
        l_v87_3.enabled = v16.push("Interface", "skeet_indicators.enabled", v83.interface:switch(v8(" ", "\a{Link Active}", "G", "\aDEFAULT", "S", l_v55_0(6), "Indicators")));
        v148 = l_v87_3.enabled:create();
        l_v87_3.items = v16.push("Interface", "skeet_indicators.items", v148:selectable("Items", l_v144_2));
        v76(l_v87_3.items);
        l_v87_3.customize = v16.push("Interface", "skeet_indicators.customize", v148:switch("Customize"));
        for v284 = 1, #l_v144_2 - 1 do
            local v285 = l_v144_2[v284];
            l_v87_3[v285] = v16.push("Interface", "skeet_indicators." .. v285, v148:input(v285, v285));
        end;
        l_v152_1 = nil;
        do
            local l_l_v144_2_1 = l_v144_2;
            v156 = function()
                -- upvalues: l_v87_3 (ref), l_l_v144_2_1 (ref)
                local v287 = l_v87_3.enabled:get();
                local v288 = l_v87_3.customize:get();
                l_v87_3.items:visibility(v287);
                l_v87_3.customize:visibility(v287);
                for v289 = 1, #l_l_v144_2_1 - 1 do
                    l_v87_3[l_l_v144_2_1[v289]]:visibility(v287 and v288);
                end;
            end;
            l_v87_3.enabled:set_callback(v156);
            l_v87_3.customize:set_callback(v156);
            v156();
            v85.skeet_indicators = l_v87_3;
        end;
        l_v144_2 = {
            enabled = v16.push("Interface", "manual_arrows.enabled", v83.interface:switch(v8(l_v55_0(2), l_v65_0("location-arrow"), l_v55_0(8), "Manual Arrows")))
        };
        v148 = l_v144_2.enabled:create();
        l_v144_2.style = v16.push("Interface", "manual_arrows.style", v148:combo("Style", {
            [1] = "TeamSkeet", 
            [2] = "Custom"
        }));
        l_v144_2.font = v16.push("Interface", "manual_arrows.font", v148:combo("Font", {
            [1] = "Default", 
            [2] = "Small", 
            [3] = "Console", 
            [4] = "Bold"
        }));
        l_v144_2.left = v16.push("Interface", "manual_arrows.left", v148:input("Left", "<"));
        l_v144_2.right = v16.push("Interface", "manual_arrows.right", v148:input("Right", ">"));
        l_v144_2.offset = v16.push("Interface", "manual_arrows.offset", v148:slider("Offset", 0, 200, 40, nil, "px"));
        l_v144_2.color = v16.push("Interface", "manual_arrows.color", v148:color_picker("Color", color(192, 202, 255, 255)));
        l_v152_1 = nil;
        v156 = function()
            -- upvalues: l_v144_2 (ref)
            local v290 = l_v144_2.enabled:get();
            local v291 = l_v144_2.style:get();
            l_v144_2.style:visibility(v290);
            l_v144_2.font:visibility(v290 and v291 == "Custom");
            l_v144_2.left:visibility(v290 and v291 == "Custom");
            l_v144_2.right:visibility(v290 and v291 == "Custom");
            l_v144_2.offset:visibility(v290);
            l_v144_2.color:visibility(v290);
        end;
        l_v144_2.enabled:set_callback(v156);
        l_v144_2.style:set_callback(v156);
        v156();
        v85.manual_arrows = l_v144_2;
        v148 = {
            enabled = v16.push("Interface", "damage_indicator.enabled", v83.interface:switch(v8(l_v55_0(2), l_v65_0("hundred-points"), l_v55_0(7), "Damage Indicator")))
        };
        l_v152_1 = v148.enabled:create();
        v148.font = v16.push("Interface", "damage_indicator.font", l_v152_1:combo("Font", {
            [1] = "Default", 
            [2] = "Small", 
            [3] = "Console", 
            [4] = "Bold"
        }));
        v148.color = v16.push("Interface", "damage_indicator.color", l_v152_1:color_picker("Color", color(255, 255, 255, 255)));
        v156 = nil;
        do
            local l_l_v152_1_0 = l_v152_1;
            local function v294(v293)
                -- upvalues: l_l_v152_1_0 (ref)
                l_l_v152_1_0:visibility(v293:get());
            end;
            v148.enabled:set_callback(v294, true);
            v85.damage_indicator = v148;
        end;
        l_v152_1 = {
            enabled = v16.push("Interface", "velocity_warning.enabled", v83.interface:switch(v8(l_v55_0(2), l_v65_0("chart-line"), l_v55_0(7), "Velocity Warning")))
        };
        l_v152_1.color = v16.push("Interface", "velocity_warning.color", l_v152_1.enabled:color_picker(color(192, 202, 255, 255)));
        v156 = nil;
        local function v296(v295)
            -- upvalues: l_v152_1 (ref)
            l_v152_1.color:visibility(v295:get());
        end;
        l_v152_1.enabled:set_callback(v296, true);
        v85.velocity_warning = l_v152_1;
        v81.interface = v85;
    end;
    v86 = {
        no_fall_damage = {
            enabled = v16.push("Movement", "no_fall_damage.enabled", v83.movement:switch(v8(l_v55_0(4), l_v65_0("person-arrow-up-from-line"), l_v55_0(5), "No Fall Damage")))
        }, 
        fast_ladder = {
            enabled = v16.push("Movement", "fast_ladder.enabled", v83.movement:switch(v8(l_v55_0(3), l_v65_0("water-ladder"), l_v55_0(7), "Fast Ladder")))
        }, 
        super_toss = {
            enabled = v16.push("Movement", "super_toss.enabled", v83.movement:switch(v8(l_v55_0(4), l_v65_0("bomb"), l_v55_0(7), "Super Toss")))
        }, 
        edge_stop = {
            enabled = v16.push("Movement", "edge_stop.enabled", v83.movement:switch(v8(l_v55_0(3), l_v65_0("person-falling-burst"), l_v55_0(6), "Edge Stop")))
        }
    };
    v156 = {};
    local v297 = v83.movement:label(v8(l_v55_0(3), l_v65_0("duck", "\a{Small Text}"), l_v55_0(8), "Fake Duck")):create();
    v156.unlock_speed = v16.push("Movement", "fake_duck.unlock_speed", v297:switch("Unlock Speed"));
    v156.on_freezetime = v16.push("Movement", "fake_duck.on_freezetime", v297:switch("On Freezetime"));
    v86.fake_duck = v156;
    v81.movement = v86;
    v87 = {};
    v144 = {
        enabled = v16.push("Visuals", "animations.enabled", v83.visuals:switch(v8(l_v55_0(2), l_v65_0("layer-group"), l_v55_0(7), "Animations")))
    };
    v148 = v144.enabled:create();
    v152 = {
        [1] = "Disabled", 
        [2] = "Static", 
        [3] = "Walking", 
        [4] = "Jitter", 
        [5] = "Kangaroo"
    };
    v144.on_ground = v16.push("Visuals", "animations.on_ground", v148:combo("On Ground", v152));
    v144.in_air = v16.push("Visuals", "animations.in_air", v148:combo("In Air", v152));
    v144.pitch_on_land = v16.push("Visuals", "animations.pitch_on_land", v148:switch("0 Pitch on Land"));
    v144.sliding_slowwalk = v16.push("Visuals", "animations.sliding_slowwalk", v148:switch("Sliding Slow Walk"));
    v144.sliding_crouch = v16.push("Visuals", "animations.sliding_crouch", v148:switch("Sliding Crouch"));
    v144.earthquake = v16.push("Visuals", "animations.earthquake", v148:switch("Earthquake"));
    v144.move_lean = v16.push("Visuals", "animations.move_lean", v148:slider("Move Lean", 0, 100, 0, nil, "%"));
    v152 = nil;
    do
        local l_v148_4 = v148;
        v156 = function(v299)
            -- upvalues: l_v148_4 (ref)
            l_v148_4:visibility(v299:get());
        end;
        v144.enabled:set_callback(v156, true);
        v87.animations = v144;
    end;
    v148 = {
        enabled = v16.push("Visuals", "scope_overlay.enabled", v83.visuals:switch(v8(l_v55_0(2), l_v65_0("crosshairs-simple"), l_v55_0(7), "Scope Overlay")))
    };
    v152 = v148.enabled:create();
    v148.additions = v16.push("Visuals", "scope_overlay.additions", v152:selectable("Additions", {
        [1] = "Inverted", 
        [2] = "Rotated", 
        [3] = "Animated", 
        [4] = "Spread Dependency"
    }));
    v148.exclude_lines = v16.push("Visuals", "scope_overlay.exclude_lines", v152:selectable("Exclude Lines", {
        [1] = "Left", 
        [2] = "Right", 
        [3] = "Top", 
        [4] = "Bottom"
    }));
    v148.size = v16.push("Visuals", "scope_overlay.size", v152:slider("Size", 0, 300, 50, nil, "px"));
    v148.gap = v16.push("Visuals", "scope_overlay.gap", v152:slider("Gap", 0, 300, 5, nil, "px"));
    v148.color = v16.push("Visuals", "scope_overlay.color", v152:color_picker("Color", color(255, 255, 255, 128)));
    v156 = nil;
    do
        local l_v152_2 = v152;
        local function v302(v301)
            -- upvalues: l_v152_2 (ref)
            l_v152_2:visibility(v301:get());
        end;
        v148.enabled:set_callback(v302, true);
        v87.scope_overlay = v148;
    end;
    v152 = {
        enabled = v16.push("Visuals", "hit_marker.enabled", v83.visuals:switch(v8(l_v55_0(2), l_v65_0("crosshairs"), l_v55_0(7), "Hit Marker")))
    };
    v156 = v152.enabled:create();
    v152.type = v16.push("Visuals", "hit_marker.type", v156:selectable("Type", {
        [1] = "World", 
        [2] = "Screen"
    }));
    v152.size = v16.push("Visuals", "hit_marker.size", v156:slider("Size", 2, 5, 5, nil, "px"));
    v152.thickness = v16.push("Visuals", "hit_marker.thickness", v156:slider("Thickness", 1, 5, 2, nil, "px"));
    v152.color = v16.push("Visuals", "hit_marker.color", v156:color_picker("Color", color(0, 255, 255, 255)));
    local v303 = nil;
    do
        local l_v152_3 = v152;
        v297 = function()
            -- upvalues: l_v152_3 (ref)
            local v305 = l_v152_3.enabled:get();
            l_v152_3.type:visibility(v305);
            if not l_v152_3.type:get("World") then
                v305 = false;
            end;
            l_v152_3.size:visibility(v305);
            l_v152_3.thickness:visibility(v305);
            l_v152_3.color:visibility(v305);
        end;
        l_v152_3.enabled:set_callback(v297);
        l_v152_3.type:set_callback(v297);
        v297();
        v87.hit_marker = l_v152_3;
        v156 = {
            enabled = v16.push("Visuals", "nade_radius.enabled", v83.visuals:switch(v8(l_v55_0(1), " ", l_v65_0("fire"), l_v55_0(6), " ", "Nade Radius")))
        };
        v303 = v156.enabled:create();
        v156.molotov = v16.push("Visuals", "nade_radius.molotov", v303:switch("Molotov"));
        v156.molotov_color = v16.push("Visuals", "nade_radius.molotov_color", v156.molotov:color_picker(color(255, 63, 63, 255)));
        v156.smoke = v16.push("Visuals", "nade_radius.smoke", v303:switch("Smoke"));
        v156.smoke_color = v16.push("Visuals", "nade_radius.smoke_color", v156.smoke:color_picker(color(61, 147, 250, 255)));
        v297 = nil;
        do
            local l_v303_0 = v303;
            local function v308(v307)
                -- upvalues: l_v303_0 (ref)
                l_v303_0:visibility(v307:get());
            end;
            v156.enabled:set_callback(v308, true);
            v87.nade_radius = v156;
        end;
        v87.keep_model_transparency = {
            enabled = v16.push("Visuals", "keep_model_transparency.enabled", v83.visuals:switch(v8(" ", l_v65_0("transporter-2"), l_v55_0(7), "Keep Transparency")))
        };
        v81.visuals = v87;
    end;
    l_play_0.features = v81;
end;
v19 = nil;
v19 = {
    is_moving = false, 
    is_onground = false, 
    is_crouched = false, 
    sent_packets = 0, 
    duck_amount = 0, 
    velocity2d_sqr = 0, 
    side = -1, 
    desync_delta = 0
};
v53 = function(v309)
    -- upvalues: v19 (ref)
    local v310 = entity.get_local_player();
    if v310 == nil then
        return;
    else
        local l_m_fFlags_0 = v310.m_fFlags;
        local l_m_vecVelocity_0 = v310.m_vecVelocity;
        local l_m_flDuckAmount_0 = v310.m_flDuckAmount;
        local v314 = bit.band(l_m_fFlags_0, 1) ~= 0;
        local v315 = math.abs(v310.m_flPoseParameter[11] * 2 - 1);
        local v316 = l_m_vecVelocity_0:length2dsqr();
        v19.is_moving = v316 > 25;
        v19.is_onground = v314;
        if v309.choked_commands == 0 then
            v19.sent_packets = v19.sent_packets + 1;
            v19.is_crouched = l_m_flDuckAmount_0 > 0.5;
            v19.duck_amount = l_m_flDuckAmount_0;
            v19.desync_delta = v315;
        end;
        v19.velocity2d_sqr = v316;
        if v309.sidemove ~= 0 then
            v19.side = v309.sidemove < 0 and -1 or 1;
        end;
        return;
    end;
end;
events.createmove(v53);
v53 = nil;
v53 = {};
v55 = 4096;
v59 = 0;
v62 = {
    breaking_lc = false, 
    shift = false, 
    old_origin = vector(), 
    defensive = {
        left = 0, 
        max = 0, 
        force = false
    }, 
    lagcompensation = {
        teleport = false, 
        distance = 0
    }
};
do
    local l_v55_1, l_v59_1, l_v62_1, l_v65_1 = v55, v59, v62, v65;
    l_v65_1 = function(v321, v322)
        -- upvalues: l_v55_1 (ref), l_v62_1 (ref)
        local v323 = (v322 - v321):lengthsqr();
        local v324 = l_v55_1 < v323;
        l_v62_1.breaking_lc = v324;
        l_v62_1.lagcompensation.distance = v323;
        l_v62_1.lagcompensation.teleport = v324;
    end;
    local function v330(v325)
        -- upvalues: l_v62_1 (ref), l_v65_1 (ref)
        local l_old_origin_0 = l_v62_1.old_origin;
        local l_m_vecOrigin_0 = v325.m_vecOrigin;
        local v328 = v325:get_simulation_time();
        local v329 = to_ticks(v328.current - v328.old);
        if v329 < 0 or v329 > 0 and v329 <= 64 then
            l_v65_1(l_old_origin_0, l_m_vecOrigin_0);
        end;
        l_v62_1.old_origin = l_m_vecOrigin_0;
    end;
    local function v334(v331)
        -- upvalues: l_v59_1 (ref), l_v62_1 (ref)
        local l_m_nTickBase_0 = v331.m_nTickBase;
        if math.abs(l_m_nTickBase_0 - l_v59_1) > 64 then
            l_v59_1 = 0;
        end;
        local v333 = 0;
        if l_v59_1 < l_m_nTickBase_0 then
            l_v59_1 = l_m_nTickBase_0;
        elseif l_m_nTickBase_0 < l_v59_1 then
            v333 = math.min(14, math.max(0, l_v59_1 - l_m_nTickBase_0 - 1));
        end;
        if v333 > 0 then
            l_v62_1.breaking_lc = true;
            l_v62_1.defensive.left = v333;
            if l_v62_1.defensive.max == 0 then
                l_v62_1.defensive.max = v333;
            end;
        else
            l_v62_1.defensive.left = 0;
            l_v62_1.defensive.max = 0;
        end;
    end;
    v53.get = function()
        -- upvalues: l_v62_1 (ref)
        return l_v62_1;
    end;
    local function v337(_)
        -- upvalues: v334 (ref)
        local v336 = entity.get_local_player();
        if v336 == nil then
            return;
        else
            v334(v336);
            return;
        end;
    end;
    local function v339()
        -- upvalues: v330 (ref)
        local v338 = entity.get_local_player();
        if v338 == nil then
            return;
        else
            v330(v338);
            return;
        end;
    end;
    events.createmove(v337);
    events.net_update_start(v339);
end;
v55 = nil;
v55 = {};
v59 = {};
v62 = 0;
do
    local l_v59_2, l_v62_2, l_v65_2 = v59, v62, v65;
    l_v65_2 = function(v343)
        -- upvalues: l_v62_2 (ref), l_v59_2 (ref)
        l_v62_2 = l_v62_2 + 1;
        l_v59_2[l_v62_2] = v343;
    end;
    local function v345()
        -- upvalues: l_v62_2 (ref), l_v59_2 (ref)
        for v344 = 1, l_v62_2 do
            l_v59_2[v344] = nil;
        end;
        l_v62_2 = 0;
    end;
    local function v346()
        -- upvalues: v19 (ref), l_v65_2 (ref), v17 (ref)
        if not v19.is_onground then
            return;
        elseif v19.is_moving then
            l_v65_2("Running");
            if v19.is_crouched then
                return;
            else
                if v17.antiaim.misc.slow_walk:get() then
                    l_v65_2("Walking");
                end;
                return;
            end;
        else
            l_v65_2("Standing");
            return;
        end;
    end;
    local function v347()
        -- upvalues: v19 (ref), l_v65_2 (ref)
        if not v19.is_crouched then
            return;
        else
            l_v65_2("Crouching");
            if v19.is_moving then
                l_v65_2("Sneaking");
            end;
            return;
        end;
    end;
    local function v349(v348)
        -- upvalues: v19 (ref), l_v65_2 (ref)
        if v19.is_onground and not v348.in_jump then
            return;
        else
            l_v65_2("In Air");
            if v19.is_crouched then
                l_v65_2("Air Crouch");
            end;
            return;
        end;
    end;
    v55.get = function()
        -- upvalues: l_v59_2 (ref)
        return l_v59_2[#l_v59_2];
    end;
    local function v351(v350)
        -- upvalues: v345 (ref), v346 (ref), v347 (ref), v349 (ref)
        v345();
        v346();
        v347();
        v349(v350);
    end;
    events.createmove(v351);
end;
v59 = nil;
v59 = {
    get = function()
        local v352 = entity.get_local_player();
        if v352 == nil then
            return;
        else
            local l_m_iTeamNum_0 = v352.m_iTeamNum;
            if l_m_iTeamNum_0 == 2 then
                return "Terrorist";
            elseif l_m_iTeamNum_0 == 3 then
                return "Counter-Terrorist";
            else
                return;
            end;
        end;
    end
};
v62 = nil;
v62 = {};
v65 = 0;
local v354 = false;
local v355 = 0;
local function v359(v356, v357, v358)
    return v356 + v358 * (v357 - v356);
end;
local v360 = {};
local l_angles_0 = v17.antiaim.angles;
local function v363(v362)
    v362:override(nil);
end;
local function v365(v364, ...)
    if ... == nil then
        return;
    else
        v364:override(...);
        return;
    end;
end;
local v366 = {};
v366.__index = v366;
v366.clear = function(v367)
    for v368 in pairs(v367) do
        v367[v368] = nil;
    end;
end;
do
    local l_l_angles_0_0, l_v363_0, l_v365_0 = l_angles_0, v363, v365;
    v366.unset = function(_)
        -- upvalues: l_v363_0 (ref), l_l_angles_0_0 (ref)
        l_v363_0(l_l_angles_0_0.extended_roll);
        l_v363_0(l_l_angles_0_0.extended_pitch);
        l_v363_0(l_l_angles_0_0.extended_angles);
        l_v363_0(l_l_angles_0_0.body_freestanding);
        l_v363_0(l_l_angles_0_0.disable_yaw_modifiers);
        l_v363_0(l_l_angles_0_0.freestanding);
        l_v363_0(l_l_angles_0_0.freestanding_body_yaw);
        l_v363_0(l_l_angles_0_0.options);
        l_v363_0(l_l_angles_0_0.right_limit);
        l_v363_0(l_l_angles_0_0.left_limit);
        l_v363_0(l_l_angles_0_0.inverter);
        l_v363_0(l_l_angles_0_0.body_yaw);
        l_v363_0(l_l_angles_0_0.modifier_offset);
        l_v363_0(l_l_angles_0_0.yaw_modifier);
        l_v363_0(l_l_angles_0_0.hidden);
        l_v363_0(l_l_angles_0_0.avoid_backstab);
        l_v363_0(l_l_angles_0_0.yaw_offset);
        l_v363_0(l_l_angles_0_0.yaw_base);
        l_v363_0(l_l_angles_0_0.yaw);
        l_v363_0(l_l_angles_0_0.pitch);
        l_v363_0(l_l_angles_0_0.enabled);
    end;
    v366.set = function(v373)
        -- upvalues: l_v365_0 (ref), l_l_angles_0_0 (ref)
        if v373.yaw_offset ~= nil then
            v373.yaw_offset = math.normalize_yaw(v373.yaw_offset);
        end;
        if v373.modifier_offset ~= nil then
            v373.modifier_offset = math.normalize_yaw(v373.modifier_offset);
        end;
        if v373.left_limit ~= nil then
            v373.left_limit = math.clamp(v373.left_limit, 0, 60);
        end;
        if v373.right_limit ~= nil then
            v373.right_limit = math.clamp(v373.right_limit, 0, 60);
        end;
        if v373.extended_pitch ~= nil then
            v373.extended_pitch = math.normalize_yaw(v373.extended_pitch);
        end;
        if v373.extended_roll ~= nil then
            v373.extended_roll = math.clamp(v373.extended_roll, -90, 90);
        end;
        l_v365_0(l_l_angles_0_0.enabled, v373.enabled);
        l_v365_0(l_l_angles_0_0.pitch, v373.pitch);
        l_v365_0(l_l_angles_0_0.yaw, v373.yaw);
        l_v365_0(l_l_angles_0_0.yaw_base, v373.yaw_base);
        l_v365_0(l_l_angles_0_0.yaw_offset, v373.yaw_offset);
        l_v365_0(l_l_angles_0_0.avoid_backstab, v373.avoid_backstab);
        l_v365_0(l_l_angles_0_0.hidden, v373.hidden);
        l_v365_0(l_l_angles_0_0.yaw_modifier, v373.yaw_modifier);
        l_v365_0(l_l_angles_0_0.modifier_offset, v373.modifier_offset);
        l_v365_0(l_l_angles_0_0.body_yaw, v373.body_yaw);
        l_v365_0(l_l_angles_0_0.inverter, v373.inverter);
        l_v365_0(l_l_angles_0_0.left_limit, v373.left_limit);
        l_v365_0(l_l_angles_0_0.right_limit, v373.right_limit);
        l_v365_0(l_l_angles_0_0.options, v373.options);
        l_v365_0(l_l_angles_0_0.freestanding_body_yaw, v373.freestanding_body_yaw);
        l_v365_0(l_l_angles_0_0.freestanding, v373.freestanding);
        l_v365_0(l_l_angles_0_0.disable_yaw_modifiers, v373.disable_yaw_modifiers);
        l_v365_0(l_l_angles_0_0.body_freestanding, v373.body_freestanding);
        l_v365_0(l_l_angles_0_0.extended_angles, v373.extended_angles);
        l_v365_0(l_l_angles_0_0.extended_pitch, v373.extended_pitch);
        l_v365_0(l_l_angles_0_0.extended_roll, v373.extended_roll);
    end;
    setmetatable(v360, v366);
    v62.buffer = v360;
end;
l_angles_0 = {};
v363 = l_play_0.antiaim.builder;
do
    local l_v65_3, l_v354_0, l_v355_0, l_v360_0, l_l_angles_0_1, l_v363_1, l_v365_1 = v65, v354, v355, v360, l_angles_0, v363, v365;
    l_v365_1 = function(_)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.pitch = "Down";
    end;
    v366 = function(v382)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.yaw = "Backward";
        l_v360_0.yaw_base = "At Target";
        l_v360_0.yaw_offset = v382.yaw_offset:get();
        l_v360_0.yaw_add = v382.yaw_add:get();
        l_v360_0.yaw_left = v382.yaw_left:get();
        l_v360_0.yaw_right = v382.yaw_right:get();
        l_v360_0.delay_mode = v382.delay_mode:get();
        l_v360_0.delay_steps = v382.delay_steps:get();
        for v383 = 1, 10 do
            local v384 = "delay_" .. v383;
            l_v360_0[v384] = v382[v384]:get();
        end;
    end;
    local function v388(v385)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.yaw_modifier = v385.yaw_modifier:get();
        l_v360_0.modifier_mode = v385.modifier_mode:get();
        l_v360_0.modifier_offset = v385.modifier_offset:get();
        l_v360_0.modifier_steps = v385.modifier_steps:get();
        for v386 = 1, 10 do
            local v387 = "modifier_" .. v386;
            l_v360_0[v387] = v385[v387]:get();
        end;
    end;
    local function v390(v389)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.body_yaw = v389.body_yaw:get();
        l_v360_0.inverter = false;
        l_v360_0.body_mode = v389.body_mode:get();
        l_v360_0.body_ticks = v389.body_ticks:get();
        l_v360_0.limit_mode = v389.limit_mode:get();
        l_v360_0.left_limit = v389.left_limit:get();
        l_v360_0.right_limit = v389.right_limit:get();
        l_v360_0.limit_1 = v389.limit_1:get();
        l_v360_0.limit_2 = v389.limit_2:get();
        l_v360_0.options = {};
        l_v360_0.freestanding_body_yaw = "Off";
    end;
    local function v392(_)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.freestanding = false;
    end;
    local function v394(_)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.extended_angles = false;
        l_v360_0.extended_pitch = 0;
        l_v360_0.extended_roll = 0;
    end;
    local function v398(v395)
        -- upvalues: l_v360_0 (ref)
        l_v360_0.force_defensive = v395.force_defensive:get();
        l_v360_0.choke_mode = v395.choke_mode:get();
        l_v360_0.choke_steps = v395.choke_steps:get();
        for v396 = 1, 10 do
            local v397 = "choke_" .. v396;
            l_v360_0[v397] = v395[v397]:get();
        end;
    end;
    do
        local l_l_v363_1_0, l_l_v365_1_0, l_v366_0, l_v388_0, l_v390_0, l_v392_0, l_v394_0, l_v398_0 = l_v363_1, l_v365_1, v366, v388, v390, v392, v394, v398;
        l_l_angles_0_1.get = function(_, v408, v409)
            -- upvalues: l_l_v363_1_0 (ref)
            return l_l_v363_1_0[v408][v409];
        end;
        l_l_angles_0_1.is_active_ex = function(_, v411)
            if v411 == nil then
                return false;
            else
                return true;
            end;
        end;
        l_l_angles_0_1.is_active = function(v412, v413, v414)
            local v415 = v412:get(v413, v414);
            if v415 == nil then
                return false;
            else
                return v412:is_active_ex(v415);
            end;
        end;
        l_l_angles_0_1.apply_ex = function(_, v417)
            -- upvalues: l_v360_0 (ref), l_l_v365_1_0 (ref), l_v366_0 (ref), l_v388_0 (ref), l_v390_0 (ref), l_v392_0 (ref), l_v394_0 (ref), l_v398_0 (ref)
            if v417 == nil then
                return false;
            else
                l_v360_0.enabled = v417.enabled:get();
                l_l_v365_1_0(v417);
                l_v366_0(v417);
                l_v388_0(v417);
                l_v390_0(v417);
                l_v392_0(v417);
                l_v394_0(v417);
                l_v398_0(v417);
                return true;
            end;
        end;
        l_l_angles_0_1.apply = function(v418, v419, v420)
            local v421 = v418:get(v419, v420);
            if v421 == nil then
                return false, nil;
            elseif not v418:is_active_ex(v421) then
                return false, v421;
            else
                v418:apply_ex(v421);
                return true, v421;
            end;
        end;
        l_l_angles_0_1.update = function(v422)
            -- upvalues: v55 (ref), v59 (ref), l_play_0 (ref)
            local v423 = v55.get();
            local v424 = v59.get();
            if v423 == nil or v424 == nil then
                return false, nil;
            else
                if l_play_0.antiaim.hotkeys.manual_yaw.direction:get() ~= "Disabled" then
                    local v425, v426 = v422:apply(v424, "Manual Yaw");
                    if v425 and v426 ~= nil then
                        return v425, v426;
                    end;
                end;
                if l_play_0.antiaim.hotkeys.freestanding.enabled:get() then
                    local v427, v428 = v422:apply(v424, "Freestanding");
                    if v427 and v428 ~= nil then
                        return v427, v428;
                    end;
                end;
                local _, v430 = v422:apply(v424, v423);
                return true, v430;
            end;
        end;
    end;
    l_v363_1 = {};
    l_v365_1 = l_play_0.antiaim.tweaks.avoid_backstab;
    do
        local l_l_v365_1_1 = l_v365_1;
        l_v363_1.update = function(_)
            -- upvalues: l_v360_0 (ref), l_l_v365_1_1 (ref)
            l_v360_0.avoid_backstab = l_l_v365_1_1.enabled:get();
        end;
    end;
    l_v365_1 = {};
    v366 = l_play_0.antiaim.tweaks.allow_on_use;
    v388 = false;
    do
        local l_v366_1, l_v388_1, l_v390_1 = v366, v388, v390;
        l_v390_1 = function(v436)
            -- upvalues: l_v366_1 (ref), l_v388_1 (ref)
            if not l_v366_1.enabled:get() then
                return false;
            else
                local v437 = entity.get_local_player();
                if v437 == nil then
                    return false;
                else
                    local v438 = v437:get_player_weapon();
                    if v438 == nil then
                        return false;
                    else
                        local v439 = v438:get_weapon_info();
                        if v439 == nil then
                            return false;
                        else
                            local l_m_iTeamNum_1 = v437.m_iTeamNum;
                            local v441 = v437:get_origin();
                            local v442 = v439.idx == 49;
                            local l_m_bIsDefusing_0 = v437.m_bIsDefusing;
                            local l_m_bIsGrabbingHostage_0 = v437.m_bIsGrabbingHostage;
                            local l_m_bInBombZone_0 = v437.m_bInBombZone;
                            if l_m_bIsDefusing_0 or l_m_bIsGrabbingHostage_0 then
                                return false;
                            elseif l_m_bInBombZone_0 and v442 then
                                return false;
                            else
                                if l_m_iTeamNum_1 == 3 and v436.view_angles.x > 25 then
                                    local v446 = entity.get_entities("CPlantedC4");
                                    for v447 = 1, #v446 do
                                        if (v446[v447]:get_origin() - v441):lengthsqr() < 3844 then
                                            return false;
                                        end;
                                    end;
                                end;
                                local v448 = render.camera_angles();
                                local v449 = vector():angles(v448);
                                local v450 = v437:get_eye_position();
                                local v451 = v450 + v449 * 128;
                                local v452 = utils.trace_line(v450, v451, v437);
                                if v452.fraction ~= 1 then
                                    local v453 = v452.entity:get_classname();
                                    if v453 == "CWorld" then
                                        return true;
                                    elseif v453 == "CFuncBrush" then
                                        return true;
                                    elseif v453 == "CCSPlayer" then
                                        return true;
                                    elseif v453 == "CHostage" and v450:distsqr((ent:get_origin())) < 7056 then
                                        return false;
                                    elseif not l_v388_1 then
                                        l_v388_1 = true;
                                        return false;
                                    end;
                                end;
                                return true;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        l_v365_1.update = function(_, v455)
            -- upvalues: l_v388_1 (ref), l_v390_1 (ref), l_v360_0 (ref), l_v366_1 (ref)
            if v455.in_use == false then
                l_v388_1 = false;
                return false;
            elseif not l_v390_1(v455) then
                return false;
            else
                l_v360_0.pitch = "Disabled";
                l_v360_0.yaw_base = l_v366_1.yaw_base:get();
                l_v360_0.yaw_offset = l_v360_0.yaw_offset + 180;
                l_v360_0.freestanding = false;
                v455.in_use = false;
                return true;
            end;
        end;
    end;
    v366 = {};
    v388 = l_play_0.antiaim.tweaks.anti_bruteforce;
    v390 = 0;
    v392 = 0;
    v394 = 0;
    v398 = 0;
    do
        local l_v388_2, l_v392_1, l_v394_1, l_v398_1 = v388, v392, v394, v398;
        local function v461()
            -- upvalues: v55 (ref), l_v388_2 (ref)
            local v460 = v55.get();
            if v460 == nil then
                return false;
            else
                return l_v388_2.conditions:get(v460);
            end;
        end;
        local function v467(v462)
            -- upvalues: l_v392_1 (ref), l_v388_2 (ref), l_v398_1 (ref), l_v394_1 (ref)
            if l_v392_1 == globals.tickcount then
                return;
            else
                local v463 = entity.get_local_player();
                if v463 == nil or not v463:is_alive() then
                    return;
                else
                    local v464 = entity.get(v462.userid, true);
                    if v464 == nil or not v464:is_enemy() then
                        return;
                    else
                        local v465 = v463:get_eye_position();
                        if (v465:closest_ray_point(v464:get_eye_position(), (vector(v462.x, v462.y, v462.z))) - v465):lengthsqr() > 5625 then
                            return;
                        else
                            local v466 = l_v388_2.mode:get();
                            if v466 == "Increase" then
                                l_v398_1 = math.random(5, 10);
                            end;
                            if v466 == "Decrease" then
                                l_v398_1 = math.random(-5, -10);
                            end;
                            if v466 == "Meta" then
                                l_v398_1 = math.random(0, 1) == 1 and math.random(-5, -10) or math.random(5, 10);
                            end;
                            l_v394_1 = l_v388_2.time:get() * 0.1;
                            events.bruteforce:call({
                                attacker = v464, 
                                offset = l_v398_1, 
                                time = l_v394_1
                            });
                            l_v392_1 = globals.tickcount;
                            return;
                        end;
                    end;
                end;
            end;
        end;
        local function v470()
            -- upvalues: v461 (ref), l_v394_1 (ref), l_v360_0 (ref), l_v398_1 (ref)
            if not v461() then
                return;
            else
                local l_frametime_0 = globals.frametime;
                local v469 = l_v394_1 > 0;
                if v469 then
                    l_v394_1 = l_v394_1 - l_frametime_0;
                end;
                if v469 then
                    l_v360_0.yaw_offset = l_v360_0.yaw_offset - l_v398_1;
                end;
                return;
            end;
        end;
        local _ = nil;
        local function v474(v472)
            -- upvalues: v470 (ref), v467 (ref)
            local v473 = v472:get();
            events.createmove(v470, v473);
            events.bullet_impact(v467, v473);
        end;
        l_v388_2.enabled:set_callback(v474, true);
    end;
    v388 = {};
    v390 = l_play_0.antiaim.tweaks.safe_head;
    v392 = 1000000;
    do
        local l_v390_2, l_v392_2, l_v394_2, l_v398_2 = v390, v392, v394, v398;
        l_v394_2 = function(v479, v480)
            -- upvalues: v19 (ref), l_v392_2 (ref)
            local v481 = v479:get_player_weapon();
            if v481 == nil then
                return nil;
            else
                local v482 = v481:get_classname();
                local v483 = v482 == "CKnife";
                local v484 = v482 == "CWeaponTaser";
                local v485 = v479:get_origin();
                local v486 = v480:get_origin() - v485;
                local v487 = -v486.z;
                local v488 = v486:length2dsqr();
                if v19.is_onground then
                    if (not v19.is_moving or v19.is_crouched) and v487 >= 10 and l_v392_2 < v488 then
                        return "Distance";
                    else
                        if v19.is_crouched then
                            if v487 >= 48 then
                                return "Crouching";
                            end;
                        elseif not v19.is_moving and v487 >= 24 then
                            return "Standing";
                        end;
                        return nil;
                    end;
                else
                    if v19.is_crouched then
                        if v484 and v487 > -20 and v488 < 250000 then
                            return "Air Taser";
                        elseif v483 and v487 > -100 then
                            return "Air Knife";
                        elseif v487 > 130 then
                            return "Air Crouch";
                        end;
                    end;
                    return nil;
                end;
            end;
        end;
        l_v398_2 = function()
            -- upvalues: l_v390_2 (ref), l_v394_2 (ref)
            if not l_v390_2.enabled:get() then
                return false;
            else
                local v489 = entity.get_local_player();
                if v489 == nil then
                    return false;
                else
                    local v490 = entity.get_threat();
                    if v490 == nil then
                        return false;
                    else
                        local v491 = l_v394_2(v489, v490);
                        if v491 == nil then
                            return false;
                        else
                            return l_v390_2.conditions:get(v491);
                        end;
                    end;
                end;
            end;
        end;
        v388.update = function(_)
            -- upvalues: l_v398_2 (ref), l_v360_0 (ref)
            if not l_v398_2() then
                return false;
            else
                l_v360_0.enabled = true;
                l_v360_0.pitch = "Down";
                l_v360_0.yaw = "Backward";
                l_v360_0.yaw_base = "At Target";
                l_v360_0.yaw_offset = 0;
                l_v360_0.yaw_add = false;
                l_v360_0.yaw_modifier = "Disabled";
                l_v360_0.body_yaw = false;
                l_v360_0.freestanding = false;
                return true;
            end;
        end;
    end;
    v390 = {};
    v392 = l_play_0.antiaim.tweaks.disablers;
    v394 = function()
        local v493 = entity.get_game_rules();
        if v493 == nil then
            return false;
        else
            return v493.m_bWarmupPeriod;
        end;
    end;
    v398 = function()
        local v494 = false;
        local v495 = entity.get_player_resource();
        for v496 = 1, globals.max_players do
            local v497 = entity.get(v496);
            if v497 ~= nil and v495.m_bConnected[v496] and v497:is_enemy() and v497:is_alive() then
                v494 = true;
            end;
        end;
        return v494;
    end;
    do
        local l_v392_3, l_v394_3, l_v398_3 = v392, v394, v398;
        local function v501()
            -- upvalues: l_v392_3 (ref), l_v394_3 (ref), l_v398_3 (ref)
            if l_v392_3.on_warmup:get() and l_v394_3() then
                return true;
            elseif l_v392_3.no_enemies:get() and not l_v398_3() then
                return true;
            else
                return false;
            end;
        end;
        v390.update = function(_)
            -- upvalues: v501 (ref), l_v360_0 (ref)
            if not v501() then
                return false;
            else
                l_v360_0.enabled = true;
                l_v360_0.pitch = "Disabled";
                l_v360_0.yaw = "Backward";
                l_v360_0.yaw_base = "At Target";
                l_v360_0.yaw_offset = globals.tickcount * 8;
                l_v360_0.yaw_add = false;
                l_v360_0.yaw_modifier = "Disabled";
                l_v360_0.body_yaw = false;
                l_v360_0.freestanding = false;
                return true;
            end;
        end;
    end;
    v392 = {};
    v394 = l_play_0.antiaim.hotkeys.freestanding;
    do
        local l_v394_4, l_v398_4 = v394, v398;
        l_v398_4 = function()
            -- upvalues: v55 (ref), l_v394_4 (ref)
            local v505 = v55.get();
            if v505 == nil then
                return false;
            else
                return l_v394_4.disablers:get(v505);
            end;
        end;
        v392.update = function(_)
            -- upvalues: l_v394_4 (ref), l_v398_4 (ref), l_v360_0 (ref)
            if not l_v394_4.enabled:get() then
                return false;
            elseif l_v398_4() then
                return false;
            else
                l_v360_0.yaw_base = "Local View";
                l_v360_0.freestanding = true;
                return true;
            end;
        end;
    end;
    v394 = {};
    v398 = l_play_0.antiaim.hotkeys.manual_yaw;
    local v507 = {
        Left = -90, 
        Forward = 180, 
        Backward = 0, 
        Right = 90
    };
    do
        local l_v398_5, l_v507_0 = v398, v507;
        v394.update = function(_)
            -- upvalues: l_v507_0 (ref), l_v398_5 (ref), l_v360_0 (ref)
            local v511 = l_v507_0[l_v398_5.direction:get()];
            if not v511 then
                return false;
            else
                l_v360_0.yaw_base = "Local View";
                l_v360_0.yaw_offset = l_v360_0.yaw_offset + v511;
                return true;
            end;
        end;
    end;
    v398 = function()
        -- upvalues: l_v354_0 (ref), l_v360_0 (ref), l_v355_0 (ref), l_v65_3 (ref)
        if rage.exploit:get() == 0 then
            l_v354_0 = not l_v354_0;
            return;
        else
            if l_v360_0.delay_mode == "Default" then
                l_v355_0 = l_v360_0.delay_1;
            end;
            if l_v360_0.delay_mode == "Randomize" then
                l_v355_0 = math.random(l_v360_0.delay_1, l_v360_0.delay_2);
            end;
            if l_v360_0.delay_mode == "Sequential" then
                l_v355_0 = l_v360_0["delay_" .. math.random(1, l_v360_0.delay_steps)];
            end;
            l_v65_3 = l_v65_3 + 1;
            if l_v355_0 < l_v65_3 then
                l_v354_0 = not l_v354_0;
                l_v65_3 = 0;
            end;
            return;
        end;
    end;
    v507 = function(v512)
        -- upvalues: l_l_angles_0_1 (ref), v390 (ref), l_v365_1 (ref), l_v363_1 (ref), v388 (ref), v394 (ref), v392 (ref)
        local _, _ = l_l_angles_0_1:update();
        if v390:update() then
            return;
        elseif l_v365_1:update(v512) then
            return;
        elseif l_v363_1:update() then
            return;
        elseif v388:update() then
            return;
        elseif v394:update() then
            return;
        elseif v392:update() then
            return;
        else
            return;
        end;
    end;
    local function v516()
        -- upvalues: l_v360_0 (ref), l_v354_0 (ref)
        if not l_v360_0.yaw_add then
            return;
        else
            rage.antiaim:inverter(l_v354_0);
            local v515 = l_v354_0 and l_v360_0.yaw_left or l_v360_0.yaw_right;
            l_v360_0.yaw_offset = l_v360_0.yaw_offset + v515;
            return;
        end;
    end;
    local function v517()
        -- upvalues: l_v360_0 (ref)
        if l_v360_0.modifier_mode == "Randomize" then
            l_v360_0.modifier_offset = math.random(l_v360_0.modifier_1, l_v360_0.modifier_2);
        end;
        if l_v360_0.modifier_mode == "Sequential" then
            l_v360_0.modifier_offset = l_v360_0["modifier_" .. math.random(1, l_v360_0.modifier_steps)];
        end;
    end;
    local function v520()
        -- upvalues: l_v360_0 (ref)
        if not l_v360_0.body_yaw then
            return;
        else
            if l_v360_0.body_mode == "Ticks" then
                l_v360_0.body_yaw = globals.tickcount % l_v360_0.body_ticks > 1;
            end;
            if l_v360_0.body_mode == "Random" then
                l_v360_0.body_yaw = math.random(0, l_v360_0.body_ticks) == l_v360_0.body_ticks;
            end;
            if l_v360_0.limit_mode == "Switch" then
                local v518 = globals.tickcount % 4 > 1;
                l_v360_0.left_limit = v518 and l_v360_0.limit_1 or l_v360_0.limit_2;
                l_v360_0.right_limit = v518 and l_v360_0.limit_1 or l_v360_0.limit_2;
            end;
            if l_v360_0.limit_mode == "Random" then
                local v519 = math.random(0, 1) == 1;
                l_v360_0.left_limit = v519 and l_v360_0.limit_1 or l_v360_0.limit_2;
                l_v360_0.right_limit = v519 and l_v360_0.limit_1 or l_v360_0.limit_2;
            end;
            return;
        end;
    end;
    local function v523(v521)
        -- upvalues: v17 (ref), l_v360_0 (ref)
        v17.rage.main.double_tap_lag_options:override();
        v17.rage.main.hide_shots_options:override();
        if not l_v360_0.force_defensive then
            return;
        else
            local v522 = nil;
            if l_v360_0.choke_mode == "Custom" then
                v522 = l_v360_0.choke_1;
            end;
            if l_v360_0.choke_mode == "Randomize" then
                v522 = math.random(l_v360_0.choke_1, l_v360_0.choke_2);
            end;
            if l_v360_0.choke_mode == "Sequential" then
                v522 = l_v360_0["choke_" .. math.random(1, l_v360_0.choke_steps)];
            end;
            if v522 then
                v521.force_defensive = v521.command_number % v522 == 0;
            end;
            v17.rage.main.double_tap_lag_options:override("Always on");
            v17.rage.main.hide_shots_options:override("Break LC");
            return;
        end;
    end;
    local function v525(v524)
        -- upvalues: v398 (ref), v523 (ref), v520 (ref), v517 (ref), v516 (ref)
        if v524.choked_commands == 0 then
            v398();
        end;
        v523(v524);
        v520();
        v517();
        v516();
    end;
    local function v527(v526)
        -- upvalues: l_v360_0 (ref), v507 (ref), v525 (ref)
        l_v360_0:clear();
        l_v360_0:unset();
        v507(v526);
        v525(v526);
        l_v360_0:set();
    end;
    local function v528()
        -- upvalues: l_v360_0 (ref)
        l_v360_0:clear();
        l_v360_0:unset();
    end;
    local _ = nil;
    events.shutdown(v528);
    events.createmove(v527);
end;
v65 = nil;
v65 = {};
v354 = function(v530, v531, v532, v533)
    return v532 * v530 / v533 + v531;
end;
v355 = function()
    return globals.frametime;
end;
v359 = function(v534, v535, v536, v537, v538)
    if v537 <= 0 then
        return v536;
    elseif v538 <= v537 then
        return v536;
    else
        v535 = v534(v537, v535, v536 - v535, v538);
        if type(v535) == "number" then
            if math.abs(v536 - v535) < 0.001 then
                return v536;
            else
                local v539 = v535 % 1;
                if v539 < 0.001 then
                    return math.floor(v535);
                elseif v539 > 0.999 then
                    return math.ceil(v535);
                end;
            end;
        end;
        return v535;
    end;
end;
do
    local l_v354_1, l_v355_1, l_v359_0 = v354, v355, v359;
    v65.interp = function(v543, v544, v545, v546)
        -- upvalues: l_v354_1 (ref), l_v359_0 (ref), l_v355_1 (ref)
        if not v546 then
            v546 = l_v354_1;
        end;
        if type(v544) == "boolean" then
            v544 = v544 and 1 or 0;
        end;
        return l_v359_0(v546, v543, v544, l_v355_1(), v545);
    end;
end;
v354 = nil;
v354 = {};
v355 = function(v547)
    local v548 = {};
    local v549 = 0;
    for v550 in string.gmatch(v547, ".[\128-\191]*") do
        v549 = v549 + 1;
        v548[v549] = v550;
    end;
    return v548, v549;
end;
do
    local l_v355_2 = v355;
    v354.gradient = function(v552, v553, ...)
        -- upvalues: l_v355_2 (ref)
        local v554 = {};
        local v555, v556 = l_v355_2(v552);
        if v556 < 2 then
            return v552;
        else
            local v557 = {
                ...
            };
            local v558 = 1 / (v556 - 1);
            local v559 = #v557 - 1;
            for v560 = 1, v556 do
                local v561 = v555[v560];
                local v562 = (v553 + v560 * v558) % 2;
                if v562 > 1 then
                    v562 = 2 - v562;
                end;
                local v563 = math.floor(v562 * v559) + 1;
                if #v557 <= v563 then
                    v563 = #v557 - 1;
                end;
                local v564 = v557[v563]:lerp(v557[v563 + 1], v562 * v559 % 1);
                v554[#v554 + 1] = "\a" .. v564:to_hex();
                v554[#v554 + 1] = v561;
            end;
            return table.concat(v554);
        end;
    end;
    v354.matrix = function(v565)
        -- upvalues: l_v355_2 (ref)
        local v566 = "abcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*+-/=?_<>";
        local _, v568 = l_v355_2(v565);
        local v569 = "";
        for _ = 1, v568 do
            local v571 = math.random(#v566);
            v569 = v569 .. v566:sub(v571, v571);
        end;
        local v572 = math.abs(globals.realtime * 0.5 % 2 - 1) * (v568 + 1);
        v572 = math.clamp(v572, 0, v568);
        return v565:sub(1, v572) .. v569.sub(v569, v572 + 1);
    end;
end;
v355 = nil;
v359 = nil;
v360 = l_play_0.features.misc.aspect_ratio;
l_angles_0 = cvar.r_aspectratio;
do
    local l_v360_1, l_l_angles_0_2, l_v363_2, l_v365_2, l_v366_2 = v360, l_angles_0, v363, v365, v366;
    l_v363_2 = function()
        -- upvalues: l_l_angles_0_2 (ref)
        local v578 = tonumber(l_l_angles_0_2:string());
        l_l_angles_0_2:float(v578, true);
    end;
    l_v365_2 = function(v579)
        -- upvalues: l_l_angles_0_2 (ref)
        l_l_angles_0_2:float(v579:get() * 0.01, true);
    end;
    l_v366_2 = function()
        -- upvalues: l_v363_2 (ref)
        l_v363_2();
    end;
    local _ = nil;
    local function v583(v581)
        -- upvalues: l_v360_1 (ref), l_v365_2 (ref), l_v363_2 (ref), l_v366_2 (ref)
        local v582 = v581:get();
        if v582 then
            l_v360_1.proportion:set_callback(l_v365_2, true);
        else
            l_v360_1.proportion:unset_callback(l_v365_2);
        end;
        if not v582 then
            l_v363_2();
        end;
        events.shutdown(l_v366_2, v582);
    end;
    l_v360_1.enabled:set_callback(v583, true);
end;
v360 = nil;
l_angles_0 = l_play_0.features.misc.viewmodel;
v363 = cvar.viewmodel_fov;
v365 = cvar.viewmodel_offset_x;
v366 = cvar.viewmodel_offset_y;
local l_viewmodel_offset_z_0 = cvar.viewmodel_offset_z;
local function v586(v585)
    return tonumber(v585:string());
end;
do
    local l_l_angles_0_3, l_v363_3, l_v365_3, l_v366_3, l_l_viewmodel_offset_z_0_0, l_v586_0 = l_angles_0, v363, v365, v366, l_viewmodel_offset_z_0, v586;
    local function v593()
        -- upvalues: l_v363_3 (ref), l_v586_0 (ref), l_v365_3 (ref), l_v366_3 (ref), l_l_viewmodel_offset_z_0_0 (ref)
        l_v363_3:float(l_v586_0(l_v363_3), true);
        l_v365_3:float(l_v586_0(l_v365_3), true);
        l_v366_3:float(l_v586_0(l_v366_3), true);
        l_l_viewmodel_offset_z_0_0:float(l_v586_0(l_l_viewmodel_offset_z_0_0), true);
    end;
    local function v595(v594)
        -- upvalues: l_v363_3 (ref)
        l_v363_3:float(v594:get() * 0.1, true);
    end;
    local function v597(v596)
        -- upvalues: l_v365_3 (ref)
        l_v365_3:float(v596:get() * 0.1, true);
    end;
    local function v599(v598)
        -- upvalues: l_v366_3 (ref)
        l_v366_3:float(v598:get() * 0.1, true);
    end;
    local function v601(v600)
        -- upvalues: l_l_viewmodel_offset_z_0_0 (ref)
        l_l_viewmodel_offset_z_0_0:float(v600:get() * 0.1, true);
    end;
    local function v602()
        -- upvalues: v593 (ref)
        v593();
    end;
    local _ = nil;
    local function v606(v604)
        -- upvalues: l_l_angles_0_3 (ref), v595 (ref), v597 (ref), v599 (ref), v601 (ref), v593 (ref), v602 (ref)
        local v605 = v604:get();
        if v605 then
            l_l_angles_0_3.fov:set_callback(v595, true);
            l_l_angles_0_3.offset_x:set_callback(v597, true);
            l_l_angles_0_3.offset_y:set_callback(v599, true);
            l_l_angles_0_3.offset_z:set_callback(v601, true);
        else
            l_l_angles_0_3.fov:unset_callback(v595);
            l_l_angles_0_3.offset_x:unset_callback(v597);
            l_l_angles_0_3.offset_y:unset_callback(v599);
            l_l_angles_0_3.offset_z:unset_callback(v601);
        end;
        if not v605 then
            v593();
        end;
        events.shutdown(v602, v605);
    end;
    l_l_angles_0_3.enabled:set_callback(v606, true);
end;
l_angles_0 = nil;
v363 = l_play_0.features.misc.log_events;
v365 = 6;
v366 = 6;
l_viewmodel_offset_z_0 = 4;
v586 = 2;
local v607 = 8;
local v608 = 4;
local v609 = 24;
local v610 = v8("\aF64F59FF", string.lower(v9.name), "\aDEFAULT", " \194\183 ");
local v611 = {};
do
    local l_v363_4, l_v365_4, l_v366_4, l_l_viewmodel_offset_z_0_1, l_v586_1, l_v607_0, l_v608_0, l_v609_0, l_v610_0, l_v611_0 = v363, v365, v366, l_viewmodel_offset_z_0, v586, v607, v608, v609, v610, v611;
    local function v622()
        -- upvalues: l_v611_0 (ref)
        l_v611_0 = {};
    end;
    local function v626(v623, v624)
        -- upvalues: l_v363_4 (ref), l_v611_0 (ref)
        if not l_v363_4.output:get("Notify") then
            return;
        else
            local v625 = {
                text = v624, 
                color = v623, 
                time = 5, 
                alpha = 0
            };
            table.insert(l_v611_0, 1, v625);
            return;
        end;
    end;
    local function v648()
        -- upvalues: l_v611_0 (ref), v65 (ref), v11 (ref), v5 (ref), l_v365_4 (ref), l_v366_4 (ref), l_l_viewmodel_offset_z_0_1 (ref), l_v586_1 (ref), l_v609_0 (ref), l_v608_0 (ref), l_v607_0 (ref)
        local l_frametime_1 = globals.frametime;
        local v628 = #l_v611_0;
        for v629 = v628, 1, -1 do
            local v630 = l_v611_0[v629];
            local v631 = v630.time > 0 and v628 - v629 < 5;
            v630.alpha = v65.interp(v630.alpha, v631, 0.05);
            if v631 then
                v630.time = v630.time - l_frametime_1;
            elseif v630.alpha <= 0 then
                table.remove(l_v611_0, v628);
            end;
        end;
        local v632 = render.screen_size() * 0.5;
        v632.y = v632.y * 1.7;
        local v633 = v11.get("sparkles");
        local v634 = render.measure_text(4, nil, v633);
        for v635 = 1, #l_v611_0 do
            local v636 = l_v611_0[v635];
            local v637, v638, v639, _ = v636.color:unpack();
            local l_text_0 = v636.text;
            local l_alpha_0 = v636.alpha;
            local v643 = v5(#l_text_0 * l_alpha_0);
            l_text_0 = string.sub(l_text_0, 1, v643);
            local v644 = render.measure_text(1, nil, l_text_0) + vector(l_v365_4, l_v366_4) * 2;
            v644.x = v644.x + v634.x + l_l_viewmodel_offset_z_0_1 + l_v586_1 + l_l_viewmodel_offset_z_0_1;
            local v645 = v632 - v644 * 0.5;
            local v646 = v645 + vector(l_v365_4, l_v366_4 - 1);
            local v647 = v646 + vector(v634.x + l_l_viewmodel_offset_z_0_1 + l_v586_1 + l_l_viewmodel_offset_z_0_1, 0);
            render.shadow(v645, v645 + v644, color(v637, v638, v639, 128 * l_alpha_0), l_v609_0, 0, l_v608_0);
            render.rect(v645, v645 + v644, color(18, 18, 18, 128 * l_alpha_0), l_v608_0);
            render.text(4, v646, color(v637, v638, v639, 255 * l_alpha_0), nil, v633);
            render.rect(v646 + vector(v634.x + l_l_viewmodel_offset_z_0_1, 0), v646 + vector(v634.x + l_l_viewmodel_offset_z_0_1 + l_v586_1, v634.y + 1), color(255, 255, 255, 128 * l_alpha_0), l_v608_0);
            render.text(1, v647, color(255, 255, 255, 255 * l_alpha_0), nil, l_text_0);
            v632.y = v632.y + v5((v644.y + l_v607_0) * l_alpha_0);
        end;
    end;
    local v649 = {
        [0] = "generic", 
        [1] = "head", 
        [2] = "chest", 
        [3] = "stomach", 
        [4] = "left arm", 
        [5] = "right arm", 
        [6] = "left leg", 
        [7] = "right leg", 
        [8] = "neck", 
        [9] = nil, 
        [10] = "gear"
    };
    local v650 = {
        c4 = "Bombed", 
        decoy = "Decoyed", 
        molotov = "Harmed", 
        smokegrenade = "Harmed", 
        incgrenade = "Harmed", 
        inferno = "Burned", 
        hegrenade = "Naded", 
        flashbang = "Harmed", 
        knife = "Knifed"
    };
    local function v654(v651, v652)
        v652 = v652:to_hex();
        return (v651:gsub("%${(.-)}", function(v653)
            -- upvalues: v652 (ref)
            return string.format("\a%s%s\aDEFAULT", v652, v653);
        end));
    end;
    local function v657(_, v656)
        -- upvalues: l_v363_4 (ref), l_v610_0 (ref)
        if not l_v363_4.output:get("Debug") then
            return;
        else
            print_dev(l_v610_0 .. v656);
            return;
        end;
    end;
    local function v660(_, v659)
        -- upvalues: l_v363_4 (ref), l_v610_0 (ref)
        if not l_v363_4.output:get("Console") then
            return;
        else
            print_raw(l_v610_0 .. v659);
            return;
        end;
    end;
    local function v662(v661)
        -- upvalues: v649 (ref)
        return v649[v661] or "?";
    end;
    local function v678(v663)
        -- upvalues: v662 (ref), l_v363_4 (ref), v654 (ref), v626 (ref), v657 (ref), v660 (ref)
        local l_target_0 = v663.target;
        if l_target_0 == nil then
            return;
        else
            local v665 = "Hit";
            if not v663.target:is_alive() then
                v665 = "Killed";
            end;
            local v666 = l_target_0:get_name();
            local v667 = v662(v663.hitgroup);
            local v668 = v662(v663.wanted_hitgroup);
            local l_damage_0 = v663.damage;
            local l_wanted_damage_0 = v663.wanted_damage;
            local l_hitchance_0 = v663.hitchance;
            local l_backtrack_0 = v663.backtrack;
            local v673 = l_v363_4.color_hit:get();
            local v674 = nil;
            v674 = string.format("%s ${%s} in ${%s} for ${%s} damage", v665, v666, v667, l_damage_0);
            v674 = v654(v674, v673);
            local v675 = nil;
            if v667 ~= v668 then
                v667 = string.format("%s(%s)", v667, v668);
            end;
            if l_damage_0 ~= l_wanted_damage_0 then
                l_damage_0 = string.format("%s(%d)", l_damage_0, l_wanted_damage_0);
            end;
            local v676 = {};
            local v677 = " \194\183 ";
            table.insert(v676, string.format("hc: ${%d%%}", l_hitchance_0));
            table.insert(v676, string.format("bt: ${%dt}", l_backtrack_0));
            v676 = table.concat(v676, v677);
            v675 = string.format("%s ${%s} in ${%s} for ${%s} damage (%s)", v665, v666, v667, l_damage_0, v676);
            v675 = v654(v675, v673);
            v626(v673, v674);
            v657(v673, v675);
            v660(v673, v675);
            return;
        end;
    end;
    local function v691(v679)
        -- upvalues: v662 (ref), l_v363_4 (ref), v654 (ref), v626 (ref), v657 (ref), v660 (ref)
        local l_target_1 = v679.target;
        if l_target_1 == nil then
            return;
        else
            local v681 = l_target_1:get_name();
            local v682 = v662(v679.wanted_hitgroup);
            local l_state_0 = v679.state;
            local l_hitchance_1 = v679.hitchance;
            local l_backtrack_1 = v679.backtrack;
            local v686 = l_v363_4.color_miss:get();
            local v687 = nil;
            v687 = string.format("Missed ${%s}'s ${%s} due to ${%s}", v681, v682, l_state_0);
            v687 = v654(v687, v686);
            local v688 = nil;
            local v689 = {};
            local v690 = " \194\183 ";
            table.insert(v689, string.format("hc: ${%d%%}", l_hitchance_1));
            table.insert(v689, string.format("bt: ${%dt}", l_backtrack_1));
            v689 = table.concat(v689, v690);
            v688 = string.format("Missed ${%s}'s ${%s} due to ${%s} (%s)", v681, v682, l_state_0, v689);
            v688 = v654(v688, v686);
            v626(v686, v687);
            v657(v686, v688);
            v660(v686, v688);
            return;
        end;
    end;
    local function v693(v692)
        -- upvalues: v678 (ref), v691 (ref)
        if v692.state == nil then
            v678(v692);
        else
            v691(v692);
        end;
    end;
    local function v702(v694)
        -- upvalues: v650 (ref), l_v363_4 (ref), v654 (ref), v626 (ref), v657 (ref), v660 (ref)
        local v695 = entity.get_local_player();
        local v696 = entity.get(v694.userid, true);
        if entity.get(v694.attacker, true) ~= v695 or v696 == v695 then
            return;
        else
            local v697 = v650[v694.weapon];
            if v697 == nil then
                return;
            else
                local v698 = v696:get_name();
                local l_dmg_health_0 = v694.dmg_health;
                local v700 = l_v363_4.color_hit:get();
                local v701 = string.format("%s ${%s} for ${%d} damage", v697, v698, l_dmg_health_0);
                v701 = v654(v701, v700);
                v626(v700, v701);
                v657(v700, v701);
                v660(v700, v701);
                return;
            end;
        end;
    end;
    local function v708(v703)
        -- upvalues: l_v363_4 (ref), v654 (ref), v626 (ref), v657 (ref), v660 (ref)
        local v704 = v703.attacker:get_name();
        local _ = v703.offset;
        local v706 = l_v363_4.color_hit:get();
        local v707 = string.format("Anti-bruteforce triggered by ${%s}", v704);
        v707 = v654(v707, v706);
        v626(v706, v707);
        v657(v706, v707);
        v660(v706, v707);
    end;
    local _ = nil;
    local function v711(v710)
        -- upvalues: v622 (ref)
        if not v710:get("Notify") then
            v622();
        end;
    end;
    do
        local l_v711_0 = v711;
        local function v715(v713)
            -- upvalues: l_v363_4 (ref), l_v711_0 (ref), v622 (ref), v708 (ref), v702 (ref), v693 (ref), v648 (ref)
            local v714 = v713:get();
            if v714 then
                l_v363_4.output:set_callback(l_v711_0);
            else
                l_v363_4.output:unset_callback(l_v711_0);
            end;
            if not v714 then
                v622();
            end;
            events.bruteforce(v708, v714);
            events.player_hurt(v702, v714);
            events.aim_ack(v693, v714);
            events.render(v648, v714);
        end;
        l_v363_4.enabled:set_callback(v715, true);
    end;
end;
v363 = nil;
v365 = l_play_0.features.misc.unlock_fake_latency;
v366 = cvar.sv_maxunlag;
do
    local l_v366_5, l_l_viewmodel_offset_z_0_2, l_v586_2, l_v607_1 = v366, l_viewmodel_offset_z_0, v586, v607;
    l_l_viewmodel_offset_z_0_2 = function()
        -- upvalues: l_v366_5 (ref)
        l_v366_5:float(tonumber(l_v366_5:string()), true);
    end;
    l_v586_2 = function()
        -- upvalues: l_v366_5 (ref)
        l_v366_5:float(0.4, true);
    end;
    l_v607_1 = function()
        -- upvalues: l_l_viewmodel_offset_z_0_2 (ref)
        l_l_viewmodel_offset_z_0_2();
    end;
    v608 = nil;
    v609 = function(v720)
        -- upvalues: l_v586_2 (ref), l_l_viewmodel_offset_z_0_2 (ref), l_v607_1 (ref)
        local v721 = v720:get();
        if v721 then
            l_v586_2();
        else
            l_l_viewmodel_offset_z_0_2();
        end;
        events.shutdown(l_v607_1, v721);
    end;
    v365.enabled:set_callback(v609, true);
end;
v365 = nil;
v366 = l_play_0.features.misc.notify_on_round_start;
ffi.cdef("            int GetForegroundWindow();\n            bool FlashWindow(int hwnd, bool invert);\n            int FindWindowA(const char* class, const char* name);\n        ");
l_viewmodel_offset_z_0 = ffi.load("user32");
v586 = l_viewmodel_offset_z_0.FindWindowA("Valve001", "Counter-Strike: Global Offensive - Direct3D 9");
do
    local l_l_viewmodel_offset_z_0_3, l_v586_3, l_v607_2, l_v608_1 = l_viewmodel_offset_z_0, v586, v607, v608;
    l_v607_2 = function()
        -- upvalues: l_l_viewmodel_offset_z_0_3 (ref), l_v586_3 (ref)
        return l_l_viewmodel_offset_z_0_3.GetForegroundWindow() == l_v586_3;
    end;
    l_v608_1 = function()
        -- upvalues: l_v607_2 (ref), l_l_viewmodel_offset_z_0_3 (ref), l_v586_3 (ref)
        if not l_v607_2() then
            l_l_viewmodel_offset_z_0_3.FlashWindow(l_v586_3, true);
        end;
    end;
    v609 = nil;
    v610 = function(v726)
        -- upvalues: l_v608_1 (ref)
        events.round_start(l_v608_1, v726:get());
    end;
    v366.enabled:set_callback(v610, true);
end;
v359 = nil;
v360 = nil;
l_angles_0 = l_play_0.features.movement.no_fall_damage;
v363 = false;
v365 = math.pi * 2;
v366 = v365 / 8;
do
    local l_v363_5, l_v365_5, l_v366_6, l_l_viewmodel_offset_z_0_4, l_v586_4 = v363, v365, v366, l_viewmodel_offset_z_0, v586;
    l_l_viewmodel_offset_z_0_4 = function(v732, v733)
        -- upvalues: l_v365_5 (ref), l_v366_6 (ref)
        local v734 = v732:get_origin();
        for v735 = 0, l_v365_5, l_v366_6 do
            local v736 = math.sin(v735);
            local v737 = math.cos(v735);
            local v738 = v734.x + v737 * 10;
            local v739 = v734.y + v736 * 10;
            local v740 = vector(v738, v739, v734.z);
            local v741 = v740:clone();
            v741.z = v741.z - v733;
            if utils.trace_line(v740, v741, v732).fraction ~= 1 then
                return true;
            end;
        end;
        return false;
    end;
    l_v586_4 = function(v742)
        -- upvalues: l_v363_5 (ref), l_l_viewmodel_offset_z_0_4 (ref)
        local v743 = entity.get_local_player();
        if v743 == nil then
            return;
        elseif v743.m_vecVelocity.z >= -500 then
            l_v363_5 = false;
            return;
        else
            if l_l_viewmodel_offset_z_0_4(v743, 15) then
                l_v363_5 = false;
            elseif l_l_viewmodel_offset_z_0_4(v743, 75) then
                l_v363_5 = true;
            end;
            v742.in_duck = l_v363_5;
            return;
        end;
    end;
    v607 = nil;
    v608 = function(v744)
        -- upvalues: l_v586_4 (ref)
        events.createmove(l_v586_4, v744:get());
    end;
    l_angles_0.enabled:set_callback(v608, true);
end;
l_angles_0 = nil;
v363 = l_play_0.features.movement.fast_ladder;
v365 = 9;
v366 = function(v745)
    local l_x_0 = render.camera_angles().x;
    if v745.forwardmove > 0 and l_x_0 < 45 then
        v745.view_angles.x = 89;
        v745.in_moveright = 1;
        v745.in_moveleft = 0;
        v745.in_forward = 0;
        v745.in_back = 1;
        if v745.sidemove == 0 then
            v745.view_angles.y = v745.view_angles.y + 90;
        end;
        if v745.sidemove < 0 then
            v745.view_angles.y = v745.view_angles.y + 150;
        end;
        if v745.sidemove > 0 then
            v745.view_angles.y = v745.view_angles.y + 30;
        end;
    end;
    if v745.forwardmove < 0 then
        v745.view_angles.x = 89;
        v745.in_moveleft = 1;
        v745.in_moveright = 0;
        v745.in_forward = 1;
        v745.in_back = 0;
        if v745.sidemove == 0 then
            v745.view_angles.y = v745.view_angles.y + 90;
        end;
        if v745.sidemove > 0 then
            v745.view_angles.y = v745.view_angles.y + 150;
        end;
        if v745.sidemove < 0 then
            v745.view_angles.y = v745.view_angles.y + 30;
        end;
    end;
end;
do
    local l_v365_6, l_v366_7, l_l_viewmodel_offset_z_0_5 = v365, v366, l_viewmodel_offset_z_0;
    l_l_viewmodel_offset_z_0_5 = function(v750)
        -- upvalues: l_v365_6 (ref), l_v366_7 (ref)
        local v751 = entity.get_local_player();
        if v751 == nil then
            return;
        elseif v751.m_MoveType ~= l_v365_6 then
            return;
        else
            l_v366_7(v750);
            return;
        end;
    end;
    v586 = nil;
    v607 = function(v752)
        -- upvalues: l_l_viewmodel_offset_z_0_5 (ref)
        events.createmove(l_l_viewmodel_offset_z_0_5, v752:get());
    end;
    v363.enabled:set_callback(v607, true);
end;
v363 = nil;
v365 = l_play_0.features.movement.super_toss;
v366 = 0.3;
l_viewmodel_offset_z_0 = function(v753, v754, v755)
    return v753 + v755 * (v754 - v753);
end;
do
    local l_v366_8, l_l_viewmodel_offset_z_0_6, l_v586_5, l_v607_3, l_v608_2 = v366, l_viewmodel_offset_z_0, v586, v607, v608;
    l_v586_5 = function(v761, v762, v763, v764)
        -- upvalues: l_l_viewmodel_offset_z_0_6 (ref), l_v366_8 (ref)
        v761.x = v761.x - 10 + math.abs(v761.x) / 9;
        local v765 = vector():angles(v761);
        local v766 = v764 * 1.25;
        local v767 = math.clamp(v762 * 0.9, 15, 750);
        local v768 = math.clamp(v763, 0, 1);
        v767 = v767 * l_l_viewmodel_offset_z_0_6(l_v366_8, 1, v768);
        local l_v765_0 = v765;
        for _ = 1, 8 do
            l_v765_0 = (v765 * (l_v765_0 * v767 + v766):length() - v766) / v767;
            l_v765_0:normalize();
        end;
        local v771 = l_v765_0.angles(l_v765_0);
        if v771.x > -10 then
            v771.x = 0.9 * v771.x + 9;
        else
            v771.x = 1.125 * v771.x + 11.25;
        end;
        return v771;
    end;
    l_v607_3 = function(v772)
        -- upvalues: l_v586_5 (ref)
        local v773 = entity.get_local_player();
        if v773 == nil then
            return;
        else
            local v774 = v773:get_player_weapon();
            if v774 == nil then
                return;
            else
                local v775 = v774:get_weapon_info();
                if v775 == nil then
                    return;
                else
                    v772.angles = l_v586_5(v772.angles, v775.throw_velocity, v774.m_flThrowStrength, v772.velocity);
                    return;
                end;
            end;
        end;
    end;
    l_v608_2 = function(v776)
        -- upvalues: l_v586_5 (ref)
        if v776.jitter_move ~= true then
            return;
        else
            local v777 = entity.get_local_player();
            if v777 == nil then
                return;
            else
                local v778 = v777:get_player_weapon();
                if v778 == nil then
                    return;
                else
                    local v779 = v778:get_weapon_info();
                    if v779 == nil or v779.weapon_type ~= 9 then
                        return;
                    elseif v778.m_fThrowTime < globals.curtime - to_time(globals.clock_offset) then
                        return;
                    else
                        v776.in_speed = true;
                        local v780 = v777:simulate_movement();
                        v780:think();
                        v776.view_angles = l_v586_5(v776.view_angles, v779.throw_velocity, v778.m_flThrowStrength, v780.velocity);
                        return;
                    end;
                end;
            end;
        end;
    end;
    v609 = nil;
    v610 = function(v781)
        -- upvalues: l_v608_2 (ref), l_v607_3 (ref)
        local v782 = v781:get();
        events.createmove(l_v608_2, v782);
        events.grenade_override_view(l_v607_3, v782);
    end;
    v365.enabled:set_callback(v610, true);
end;
v365 = nil;
v366 = l_play_0.features.movement.edge_stop;
l_viewmodel_offset_z_0 = function(v783)
    local v784 = entity.get_local_player();
    if v784 == nil then
        return;
    else
        local v785 = v784:simulate_movement();
        v785:think(5);
        if v785.velocity.z < 0 then
            v783.block_movement = 2;
        end;
        return;
    end;
end;
v586 = nil;
do
    local l_l_viewmodel_offset_z_0_7 = l_viewmodel_offset_z_0;
    v607 = function(v787)
        -- upvalues: l_l_viewmodel_offset_z_0_7 (ref)
        events.createmove(l_l_viewmodel_offset_z_0_7, v787:get());
    end;
    v366.enabled:set_callback(v607, true);
end;
v366 = nil;
l_viewmodel_offset_z_0 = l_play_0.features.movement.fake_duck;
v586 = 5;
do
    local l_v586_6, l_v607_4 = v586, v607;
    l_v607_4 = function(v790)
        -- upvalues: v17 (ref), l_v586_6 (ref)
        if not v17.antiaim.misc.fake_duck:get() then
            return;
        elseif entity.get_local_player() == nil then
            return;
        else
            local l_forwardmove_0 = v790.forwardmove;
            local l_sidemove_0 = v790.sidemove;
            if math.abs(l_forwardmove_0) > l_v586_6 or math.abs(l_sidemove_0) > l_v586_6 then
                local v793 = 450 / (l_forwardmove_0 * l_forwardmove_0 + l_sidemove_0 * l_sidemove_0) ^ 0.5;
                v790.forwardmove = l_forwardmove_0 * v793;
                v790.sidemove = l_sidemove_0 * v793;
            end;
            return;
        end;
    end;
    v608 = nil;
    v609 = function(v794)
        -- upvalues: l_v607_4 (ref)
        events.createmove_run(l_v607_4, v794:get());
    end;
    l_viewmodel_offset_z_0.unlock_speed:set_callback(v609, true);
end;
l_viewmodel_offset_z_0 = nil;
v586 = l_play_0.features.movement.fake_duck;
v607 = 0;
v608 = function()
    local v795 = entity.get_game_rules();
    if v795 == nil then
        return false;
    else
        return v795.m_bFreezePeriod;
    end;
end;
do
    local l_v607_5, l_v608_3, l_v609_1, l_v610_1, l_v611_1 = v607, v608, v609, v610, v611;
    l_v609_1 = function()
        -- upvalues: v17 (ref), l_v608_3 (ref)
        if not v17.antiaim.misc.fake_duck:get() then
            return false;
        else
            return l_v608_3();
        end;
    end;
    l_v610_1 = function(v801)
        -- upvalues: l_v609_1 (ref)
        if not l_v609_1() then
            return;
        else
            rage.exploit:force_teleport();
            v801.in_duck = v801.choked_commands >= 7;
            v801.send_packet = v801.choked_commands ~= 14;
            return;
        end;
    end;
    l_v611_1 = function(v802)
        -- upvalues: l_v609_1 (ref), l_v607_5 (ref)
        if not l_v609_1() then
            l_v607_5 = v802.camera.z;
            return;
        else
            v802.camera.z = l_v607_5;
            return;
        end;
    end;
    local _ = nil;
    local function v806(v804)
        -- upvalues: l_v611_1 (ref), l_v610_1 (ref)
        local v805 = v804:get();
        events.override_view(l_v611_1, v805);
        events.createmove(l_v610_1, v805);
    end;
    v586.on_freezetime:set_callback(v806, true);
end;
v360 = nil;
l_angles_0 = nil;
l_angles_0 = {};
v363 = {};
v365 = render.screen_size();
v366 = ui.create("Windows"):visibility(false);
l_viewmodel_offset_z_0 = nil;
v586 = nil;
v607 = {
    mouse_pos = vector(), 
    mouse_pos_prev = vector(), 
    mouse_down = false, 
    mouse_clicked = false, 
    mouse_down_duration = 0, 
    mouse_delta = vector(), 
    mouse_clicked_pos = vector()
};
do
    local l_v363_6, l_v365_7, l_v366_9, l_l_viewmodel_offset_z_0_8, l_v586_7, l_v607_6, l_v608_4, l_v609_2, l_v610_2, l_v611_2 = v363, v365, v366, l_viewmodel_offset_z_0, v586, v607, v608, v609, v610, v611;
    l_v607_6.update_mouse_inputs = function()
        -- upvalues: l_v607_6 (ref)
        local l_frametime_2 = globals.frametime;
        local v818 = ui.get_mouse_position();
        local v819 = common.is_button_down(1);
        l_v607_6.mouse_pos_prev = l_v607_6.mouse_pos;
        l_v607_6.mouse_pos = v818;
        l_v607_6.mouse_delta = l_v607_6.mouse_pos - l_v607_6.mouse_pos_prev;
        l_v607_6.mouse_down = v819;
        l_v607_6.mouse_clicked = v819 and l_v607_6.mouse_down_duration < 0;
        local l_l_v607_6_0 = l_v607_6;
        local v821;
        if v819 then
            if l_v607_6.mouse_down_duration < 0 then
                v821 = 0;
                goto label0 --[[  true, true  ]];
            else
                v821 = l_v607_6.mouse_down_duration + l_frametime_2;
                if v821 then
                    goto label0;
                end;
            end;
        end;
        v821 = -1;
        ::label0::;
        l_l_v607_6_0.mouse_down_duration = v821;
        if l_v607_6.mouse_clicked then
            l_v607_6.mouse_clicked_pos = l_v607_6.mouse_pos;
        end;
    end;
    l_v608_4 = {};
    l_v608_4.__index = l_v608_4;
    l_v608_4.__new = function(v822, v823)
        local v824 = {
            name = v823, 
            item = {}, 
            is_dragged = false, 
            is_hovered = false, 
            pos = vector(), 
            size = vector()
        };
        return setmetatable(v824, v822);
    end;
    l_v608_4.get_pos = function(v825)
        return v825.pos;
    end;
    l_v608_4.set_pos = function(v826, v827)
        -- upvalues: l_v365_7 (ref)
        local v828 = v827:clone();
        v828.x = math.clamp(v828.x, 0, l_v365_7.x - v826.size.x);
        v828.y = math.clamp(v828.y, 0, l_v365_7.y - v826.size.y);
        if v826.pos ~= v828 then
            v826.item.x:set(v828.x + v826.size.x);
            v826.item.y:set(v828.y + v826.size.y);
        end;
        v826.pos = v828;
        return v826;
    end;
    l_v608_4.get_size = function(v829)
        return v829.size;
    end;
    l_v608_4.set_size = function(v830, v831)
        v830.size = v831;
        v830:set_pos(v830.pos);
        return v830;
    end;
    l_v608_4.build = function(v832, v833)
        -- upvalues: v16 (ref), l_v366_9 (ref), l_v365_7 (ref), l_v363_6 (ref)
        v832.item = {
            x = v16.push("Interface", v832.name .. ":x", l_v366_9:slider(v832.name .. ":x", 0, l_v365_7.x, v833.x)), 
            y = v16.push("Interface", v832.name .. ":y", l_v366_9:slider(v832.name .. ":y", 0, l_v365_7.y, v833.y))
        };
        v832.pos = vector(v832.item.x:get(), v832.item.y:get());
        table.insert(l_v363_6, v832);
        return v832;
    end;
    l_v609_2 = function(v834, v835, v836)
        return v834.x >= v835.x and v834.x <= v836.x and v834.y >= v835.y and v834.y <= v836.y;
    end;
    l_v610_2 = function()
        -- upvalues: l_v363_6 (ref), l_v609_2 (ref), l_v607_6 (ref), l_l_viewmodel_offset_z_0_8 (ref)
        local v837 = nil;
        if ui.get_alpha() > 0 then
            for v838 = 1, #l_v363_6 do
                local v839 = l_v363_6[v838];
                local l_pos_0 = v839.pos;
                local l_size_0 = v839.size;
                if l_v609_2(l_v607_6.mouse_pos, l_pos_0, l_pos_0 + l_size_0) then
                    v837 = v839;
                end;
            end;
        end;
        l_l_viewmodel_offset_z_0_8 = v837;
    end;
    l_v611_2 = function()
        -- upvalues: l_v607_6 (ref), l_v586_7 (ref), l_l_viewmodel_offset_z_0_8 (ref)
        if not l_v607_6.mouse_down then
            l_v586_7 = nil;
            return;
        else
            if l_v607_6.mouse_clicked and l_l_viewmodel_offset_z_0_8 ~= nil then
                l_v586_7 = l_l_viewmodel_offset_z_0_8;
            end;
            return;
        end;
    end;
    local function v844()
        -- upvalues: l_v363_6 (ref)
        for v842 = 1, #l_v363_6 do
            local v843 = l_v363_6[v842];
            v843.is_dragged = false;
            v843.is_hovered = false;
        end;
    end;
    local function v845()
        -- upvalues: l_l_viewmodel_offset_z_0_8 (ref)
        if l_l_viewmodel_offset_z_0_8 == nil then
            return;
        else
            l_l_viewmodel_offset_z_0_8.is_hovered = true;
            return;
        end;
    end;
    local function v847()
        -- upvalues: l_v586_7 (ref), l_v607_6 (ref)
        if l_v586_7 == nil then
            return;
        else
            local v846 = l_v586_7.pos + l_v607_6.mouse_delta;
            l_v586_7:set_pos(v846);
            l_v586_7.is_dragged = true;
            return;
        end;
    end;
    local function v848()
        -- upvalues: l_v607_6 (ref), l_v610_2 (ref), l_v611_2 (ref), v844 (ref), v845 (ref), v847 (ref)
        l_v607_6.update_mouse_inputs();
        l_v610_2();
        l_v611_2();
        v844();
        v845();
        v847();
    end;
    local function v850(v849)
        -- upvalues: l_v586_7 (ref), l_l_viewmodel_offset_z_0_8 (ref)
        if not (l_v586_7 ~= nil or l_l_viewmodel_offset_z_0_8 ~= nil) then
            return;
        else
            v849.in_attack = false;
            v849.in_attack2 = false;
            return;
        end;
    end;
    l_angles_0.new = function(v851, v852)
        -- upvalues: l_v608_4 (ref)
        return l_v608_4:__new(v851, v852);
    end;
    events.render(v848);
    events.createmove(v850);
end;
v363 = nil;
v365 = l_play_0.features.interface.watermark;
v366 = {
    Small = 2, 
    Bold = 4, 
    Console = 3, 
    Default = 1
};
l_viewmodel_offset_z_0 = {
    color(255, 0, 0, 255), 
    color(255, 127, 0, 255), 
    color(255, 255, 0, 255), 
    color(0, 255, 0, 255), 
    color(0, 0, 255, 255), 
    color(75, 0, 130, 255), 
    color(148, 0, 211, 255)
};
v586 = 4;
v607 = 4;
v608 = render.screen_size();
v609 = l_angles_0.new("watermark"):build(vector(8, v608.y * 0.5));
do
    local l_v365_8, l_v366_10, l_l_viewmodel_offset_z_0_9, l_v586_8, l_v607_7, l_v609_3 = v365, v366, l_viewmodel_offset_z_0, v586, v607, v609;
    v610 = function()
        -- upvalues: l_v609_3 (ref), l_v365_8 (ref), l_v366_10 (ref), v9 (ref), v354 (ref), l_l_viewmodel_offset_z_0_9 (ref), l_v586_8 (ref), l_v607_7 (ref)
        local v859 = l_v609_3:get_pos():clone();
        local v860 = l_v366_10[l_v365_8.font:get()];
        local v861 = l_v365_8.text:get();
        if #v861 == 0 then
            v861 = v9.name;
        end;
        local v862 = l_v365_8.col_a:get();
        local v863 = l_v365_8.col_b:get();
        if l_v365_8.effects:get("Matrix") then
            v861 = v354.matrix(v861);
        end;
        if l_v365_8.effects:get("Gradient") then
            local v864 = -(globals.realtime * 1.5);
            if l_v365_8.rainbow:get() then
                v861 = v354.gradient(v861, v864, unpack(l_l_viewmodel_offset_z_0_9));
            else
                v861 = v354.gradient(v861, v864, v862, v863);
            end;
        end;
        if l_v365_8.effects:get("Pulse") then
            local v865 = globals.realtime * 3;
            local v866 = math.sin(v865) * 0.5 + 0.5;
            v862.a = v862.a * v866;
        end;
        if v860 == 2 then
            v861 = string.upper(v861);
        end;
        local v867 = render.measure_text(v860, nil, v861) + vector(l_v586_8, l_v607_7) * 2;
        render.text(v860, v859 + vector(l_v586_8, l_v607_7), v862, nil, v861);
        l_v609_3:set_size(v867);
    end;
    v611 = nil;
    events.render(v610);
end;
v365 = nil;
v366 = l_play_0.features.interface.skeet_indicators;
l_viewmodel_offset_z_0 = vector(24, 22, 0);
v586 = render.load_font("Calibri", l_viewmodel_offset_z_0, "ab");
v607 = 520;
v608 = 8;
v609 = 24;
v610 = 4;
v611 = 3;
local v868 = vector(30, 30);
local v869 = render.load_image_from_file("materials/panorama/images/icons/ui/bomb_c4.svg", v868);
local v870 = color(0, 0, 0, 50);
local v871 = color(0, 0, 0, 0);
local function v874(v872)
    local v873 = v872:get_override();
    if v873 ~= nil then
        return v873;
    else
        return v872:get();
    end;
end;
local function v881(v875)
    local v876 = ui.get_binds(true);
    for v877 = 1, #v876 do
        local v878 = v876[v877];
        local l_value_0 = v878.value;
        local l_reference_0 = v878.reference;
        if l_reference_0:get() == l_value_0 and l_reference_0:id() == v875:id() then
            return true;
        end;
    end;
    return false;
end;
local function v887(v882, v883)
    local v884 = 0.5;
    local v885 = 0.5;
    if v883 > 0 then
        local v886 = v882 * v884;
        if v883 < (v882 - v886) * v885 then
            v886 = v882 - v883 * (1 / v885);
        end;
        v882 = v886;
    end;
    return v882;
end;
do
    local l_v366_11, l_v586_9, l_v607_8, l_v608_5, l_v609_4, l_v610_3, l_v611_3, l_v868_0, l_v869_0, l_v870_0, l_v871_0, l_v874_0, l_v881_0, l_v887_0 = v366, v586, v607, v608, v609, v610, v611, v868, v869, v870, v871, v874, v881, v887;
    local function v910(v902, v903)
        -- upvalues: l_v887_0 (ref)
        local v904 = 1;
        local v905 = 500;
        local v906 = v905 * 3.5;
        local v907 = (v903:get_origin() - v902:get_origin()):length();
        local v908 = v906 / 3;
        local v909 = v905 * math.exp(-v907 * v907 / (2 * v908 * v908)) * v904;
        return l_v887_0(v909, v902.m_ArmorValue);
    end;
    local function v923(v911, v912, v913, v914, v915)
        -- upvalues: l_v609_4 (ref), l_v610_3 (ref), l_v586_9 (ref), l_v868_0 (ref), l_v871_0 (ref), l_v870_0 (ref), v5 (ref), l_v608_5 (ref)
        local v916 = v911 + vector(l_v609_4, l_v610_3);
        local v917 = render.measure_text(l_v586_9, nil, v913);
        local l_v917_0 = v917;
        l_v917_0.y = l_v917_0.y + l_v610_3 * 2;
        l_v917_0 = l_v917_0 + vector(50, 2);
        v916.y = v916.y + 3;
        if v914 then
            l_v917_0.x = l_v917_0.x + 30;
        end;
        if v915 then
            l_v917_0.x = l_v917_0.x + l_v868_0.x + 2;
        end;
        local l_v911_0 = v911;
        local v920 = v911 + l_v917_0;
        local v921 = (l_v911_0 + v920) * 0.5;
        render.gradient(l_v911_0, vector(v921.x, v920.y), l_v871_0, l_v870_0, l_v871_0, l_v870_0);
        render.gradient(v920, vector(v921.x, l_v911_0.y), l_v871_0, l_v870_0, l_v871_0, l_v870_0);
        if v915 then
            l_v911_0 = v911:clone();
            l_v911_0.x = l_v911_0.x + l_v609_4;
            l_v911_0.y = l_v911_0.y + (l_v917_0.y - l_v868_0.y) * 0.5;
            render.texture(v915, l_v911_0, l_v868_0, v912, "f");
            v916.x = v916.x + l_v868_0.x + 6;
        end;
        render.text(l_v586_9, v916 + 1, color(0, 0, 0, 128), nil, v913);
        render.text(l_v586_9, v916, v912, nil, v913);
        v916.x = v916.x + v917.x;
        if v914 then
            l_v911_0 = 10;
            v920 = 5;
            v921 = color(255, 255, 255, 200);
            local v922 = vector(v916.x + l_v911_0 * 0.5 + 12, v911.y + l_v917_0.y * 0.5);
            render.circle_outline(v922, color(0, 0, 0, 255), l_v911_0, 0, 1, v920);
            render.circle_outline(v922, v921, l_v911_0 - 1, 0, v914, v920 - 2);
        end;
        v911.y = v911.y - v5(l_v917_0.y + l_v608_5);
    end;
    local function v934(v924, v925, v926)
        -- upvalues: v923 (ref), l_v869_0 (ref)
        local v927 = v925:get_player_weapon();
        if v927 == nil then
            return;
        elseif not v927.m_bStartedArming then
            return;
        else
            local l_m_fArmedTime_0 = v927.m_fArmedTime;
            if l_m_fArmedTime_0 == nil then
                return;
            else
                local v929 = v925:get_origin();
                local l_m_bombsiteCenterA_0 = v926.m_bombsiteCenterA;
                local l_m_bombsiteCenterB_0 = v926.m_bombsiteCenterB;
                local v932 = v929:distsqr(l_m_bombsiteCenterA_0) < v929:distsqr(l_m_bombsiteCenterB_0) and "A" or "B";
                local v933 = (l_m_fArmedTime_0 - globals.curtime) / 3;
                v923(v924, color(252, 243, 105, 255), v932, 1 - v933, l_v869_0);
                return;
            end;
        end;
    end;
    local function v950(v935, v936, v937)
        -- upvalues: v923 (ref), l_v869_0 (ref), v910 (ref)
        local l_m_bBombDefused_0 = v937.m_bBombDefused;
        if not v937.m_bBombTicking or l_m_bBombDefused_0 then
            return;
        else
            local l_curtime_0 = globals.curtime;
            local l_m_flC4Blow_0 = v937.m_flC4Blow;
            local v941 = l_m_flC4Blow_0 - l_curtime_0;
            if v941 > 0 then
                if v937.m_hBombDefuser ~= nil then
                    local v942 = render.screen_size();
                    local l_m_flDefuseCountDown_0 = v937.m_flDefuseCountDown;
                    local v944 = (l_m_flDefuseCountDown_0 - l_curtime_0) / 10;
                    local v945 = l_m_flC4Blow_0 < l_m_flDefuseCountDown_0 and color(235, 50, 75, 125) or color(50, 235, 75, 125);
                    local v946 = (v942.y - 2) * v944;
                    render.rect(vector(0, 0), vector(20, v942.y), color(0, 0, 0, 115));
                    render.rect(vector(1, 1 + v946), vector(19, v942.y - 1), v945);
                end;
                local v947 = string.format("%s - %.1fs", v937.m_nBombSite == 1 and "B" or "A", v941);
                v923(v935, color(255, 255, 255, 200), v947, nil, l_v869_0);
            end;
            local l_m_iHealth_0 = v936.m_iHealth;
            local v949 = v910(v936, v937);
            v949 = math.floor(v949);
            if l_m_iHealth_0 <= v949 then
                v923(v935, color(255, 0, 50, 255), "FATAL");
            elseif v949 > 0 then
                v923(v935, color(252, 243, 105, 255), string.format("-%d HP", v949));
            end;
            return;
        end;
    end;
    local function v959(v951, v952)
        -- upvalues: v934 (ref), v950 (ref)
        local v953 = entity.get_game_rules();
        if v953 == nil then
            return;
        else
            local v954 = entity.get_player_resource();
            if v954 == nil then
                return;
            else
                local l_m_bBombPlanted_0 = v953.m_bBombPlanted;
                local l_m_iPlayerC4_0 = v954.m_iPlayerC4;
                if l_m_iPlayerC4_0 ~= nil and l_m_iPlayerC4_0 ~= 0 then
                    local v957 = entity.get(l_m_iPlayerC4_0);
                    if v957 ~= nil then
                        v934(v951, v957, v954);
                    end;
                end;
                if l_m_bBombPlanted_0 then
                    local v958 = entity.get_entities("CPlantedC4")[1];
                    if v958 ~= nil then
                        v950(v951, v952, v958);
                    end;
                end;
                return;
            end;
        end;
    end;
    local function v982()
        -- upvalues: l_v611_3 (ref), l_v607_8 (ref), l_v366_11 (ref), l_v874_0 (ref), v17 (ref), v923 (ref), l_v881_0 (ref), v959 (ref)
        local v960 = entity.get_local_player();
        if v960 == nil then
            return;
        else
            local v961 = render.screen_size();
            local v962 = vector(l_v611_3, v961.y - (v961.y - l_v607_8) * 0.5);
            local v963 = l_v366_11.customize:get();
            if v960:is_alive() then
                local v964 = "PING";
                if l_v366_11.items:get(v964) then
                    if v963 then
                        v964 = l_v366_11[v964]:get();
                    end;
                    local v965 = l_v874_0(v17.misc.main.other.fake_latency);
                    if v965 > 0 then
                        local v966 = utils.net_channel();
                        if v966 ~= nil then
                            local v967 = nil;
                            local v968 = math.clamp(v966.latency[0] + v966.latency[1], 0.001, 0.2);
                            local v969 = math.clamp(v965 * 0.001 + v966.avg_latency[1], 0.001, 0.2);
                            local v970 = math.clamp(v968 / v969, 0, 1);
                            if v970 < 0.5 then
                                v967 = color(200, 200, 200, 255):lerp(color(213, 197, 84, 255), v970 * 2);
                            else
                                v967 = color(213, 197, 84, 255):lerp(color(143, 194, 21, 255), (v970 - 0.5) * 2);
                            end;
                            if v967 ~= nil then
                                v923(v962, v967, v964);
                            end;
                        end;
                    end;
                end;
                local v971 = "DT";
                if l_v366_11.items:get(v971) then
                    if v963 then
                        v971 = l_v366_11[v971]:get();
                    end;
                    if l_v874_0(v17.rage.main.double_tap) and not l_v874_0(v17.antiaim.misc.fake_duck) then
                        local v972 = color(255, 0, 50, 255);
                        if rage.exploit:get() == 1 then
                            v972 = color(255, 255, 255, 200);
                        end;
                        v923(v962, v972, v971);
                    end;
                end;
                local v973 = "OSAA";
                if l_v366_11.items:get(v973) then
                    if v963 then
                        v973 = l_v366_11[v973]:get();
                    end;
                    if l_v874_0(v17.rage.main.hide_shots) and not l_v874_0(v17.rage.main.double_tap) and not l_v874_0(v17.antiaim.misc.fake_duck) then
                        v923(v962, color(255, 255, 255, 200), v973);
                    end;
                end;
                local v974 = "DUCK";
                if l_v366_11.items:get(v974) then
                    if v963 then
                        v974 = l_v366_11[v974]:get();
                    end;
                    if l_v874_0(v17.antiaim.misc.fake_duck) then
                        v923(v962, color(255, 255, 255, 200), v974);
                    end;
                end;
                local v975 = "DA";
                if l_v366_11.items:get(v975) then
                    if v963 then
                        v975 = l_v366_11[v975]:get();
                    end;
                    if l_v874_0(v17.rage.main.dormant_aimbot) then
                        local v976 = color(255, 0, 50, 255);
                        if #entity.get_players(true, false) == 0 then
                            v976 = color(255, 255, 255, 200);
                        end;
                        v923(v962, v976, "DA");
                    end;
                end;
                local v977 = "SAFE";
                if l_v366_11.items:get(v977) then
                    if v963 then
                        v977 = l_v366_11[v977]:get();
                    end;
                    if l_v874_0(v17.rage.safety.safe_points) == "Force" then
                        v923(v962, color(255, 255, 255, 200), v977);
                    end;
                end;
                local v978 = "BODY";
                if l_v366_11.items:get(v978) then
                    if v963 then
                        v978 = l_v366_11[v978]:get();
                    end;
                    if l_v874_0(v17.rage.safety.body_aim) == "Force" then
                        v923(v962, color(255, 255, 255, 200), v978);
                    end;
                end;
                local v979 = "MD";
                if l_v366_11.items:get(v979) then
                    if v963 then
                        v979 = l_v366_11[v979]:get();
                    end;
                    if l_v881_0(v17.rage.selection.min_damage) then
                        v923(v962, color(255, 255, 255, 200), v979);
                    end;
                end;
                local v980 = "HC";
                if l_v366_11.items:get(v980) then
                    if v963 then
                        v980 = l_v366_11[v980]:get();
                    end;
                    if l_v881_0(v17.rage.selection.hit_chance) then
                        v923(v962, color(255, 255, 255, 200), v980);
                    end;
                end;
                local v981 = "FS";
                if l_v366_11.items:get(v981) then
                    if v963 then
                        v981 = l_v366_11[v981]:get();
                    end;
                    if l_v874_0(v17.antiaim.angles.freestanding) then
                        v923(v962, color(255, 255, 255, 200), v981);
                    end;
                end;
            end;
            if l_v366_11.items:get("C4") then
                v959(v962, v960);
            end;
            return;
        end;
    end;
    local _ = nil;
    local function v985(v984)
        -- upvalues: v982 (ref)
        events.render(v982, v984:get());
    end;
    l_v366_11.enabled:set_callback(v985, true);
end;
v366 = nil;
l_viewmodel_offset_z_0 = l_play_0.features.interface.manual_arrows;
v586 = {
    Small = 2, 
    Bold = 4, 
    Console = 3, 
    Default = 1
};
v607 = color(0, 0, 0, 96);
do
    local l_l_viewmodel_offset_z_0_10, l_v586_10, l_v607_9, l_v608_6 = l_viewmodel_offset_z_0, v586, v607, v608;
    l_v608_6 = function()
        -- upvalues: l_play_0 (ref), l_l_viewmodel_offset_z_0_10 (ref), l_v607_9 (ref), l_v586_10 (ref)
        local v990 = entity.get_local_player();
        if v990 == nil or not v990:is_alive() then
            return;
        else
            local v991 = render.screen_size() * 0.5;
            local v992 = l_play_0.antiaim.hotkeys.manual_yaw.direction:get();
            local v993 = l_l_viewmodel_offset_z_0_10.style:get();
            local v994 = l_l_viewmodel_offset_z_0_10.offset:get();
            local v995 = l_l_viewmodel_offset_z_0_10.color:get();
            if v993 == "TeamSkeet" then
                local v996 = 2;
                local v997 = 18;
                local v998 = 2;
                local v999 = math.floor(v997 * 0.75);
                local v1000 = rage.antiaim:get_rotation(false);
                local v1001 = rage.antiaim:get_rotation(true);
                local v1002 = math.normalize_yaw(v1001 - v1000);
                local v1003 = v1002 < 0;
                local v1004 = v1002 > 0;
                local _ = nil;
                local v1006 = v991 - vector(v994, 0);
                local v1007 = vector(v996, v997);
                local v1008 = v1006 - vector(v1007.x, v1007.y * 0.5);
                local v1009 = v1003 and v995 or l_v607_9;
                local v1010 = v992 == "Left" and v995 or l_v607_9;
                render.rect(v1008, v1008 + v1007, v1009);
                v1006.x = v1006.x - (v1007.x + v998);
                local v1011 = vector(v1006.x, v1006.y - v997 * 0.5);
                local v1012 = vector(v1006.x, v1006.y + v997 * 0.5);
                local v1013 = vector(v1006.x - v999, v1006.y);
                render.poly(v1010, v1011, v1012, v1013);
                v1006 = nil;
                v1007 = v991 + vector(v994 + 1, 0);
                v1008 = vector(v996, v997);
                v1009 = v1007 - vector(0, v1008.y * 0.5);
                v1010 = v1004 and v995 or l_v607_9;
                v1011 = v992 == "Right" and v995 or l_v607_9;
                render.rect(v1009, v1009 + v1008, v1010);
                v1007.x = v1007.x + (v1008.x + v998);
                v1012 = vector(v1007.x, v1007.y - v997 * 0.5);
                v1013 = vector(v1007.x, v1007.y + v997 * 0.5);
                local v1014 = vector(v1007.x + v999, v1007.y);
                render.poly(v1011, v1012, v1013, v1014);
            end;
            local v1015 = l_v586_10[l_l_viewmodel_offset_z_0_10.font:get()];
            if v993 == "Custom" then
                if v992 == "Left" then
                    local v1016 = l_l_viewmodel_offset_z_0_10.left:get();
                    local v1017 = render.measure_text(v1015, "s", v1016);
                    local v1018 = vector(v991.x - v1017.x - v994 + 1, v991.y - v1017.y * 0.5 - 1);
                    render.text(v1015, v1018, v995, "s", v1016);
                end;
                if v992 == "Right" then
                    local v1019 = l_l_viewmodel_offset_z_0_10.right:get();
                    local v1020 = render.measure_text(v1015, "s", v1019);
                    local v1021 = vector(v991.x + v994, v991.y - v1020.y * 0.5 - 1);
                    render.text(v1015, v1021, v995, "s", v1019);
                end;
                return;
            else
                return;
            end;
        end;
    end;
    v609 = nil;
    v610 = function(v1022)
        -- upvalues: l_v608_6 (ref)
        events.render(l_v608_6, v1022:get());
    end;
    l_l_viewmodel_offset_z_0_10.enabled:set_callback(v610, true);
end;
l_viewmodel_offset_z_0 = nil;
v586 = l_play_0.features.interface.damage_indicator;
v607 = {
    Small = 2, 
    Bold = 4, 
    Console = 3, 
    Default = 1
};
v608 = 4;
v609 = 4;
v610 = 0;
v611 = render.screen_size();
v868 = l_angles_0.new("damage_indicator"):build(v611 * 0.5);
v869 = v17.rage.selection.min_damage;
do
    local l_v586_11, l_v607_10, l_v608_7, l_v609_5, l_v610_4, l_v868_1, l_v869_1, l_v871_1 = v586, v607, v608, v609, v610, v868, v869, v871;
    v870 = function()
        -- upvalues: l_v869_1 (ref)
        local v1031 = ui.get_binds(true);
        for v1032 = 1, #v1031 do
            local v1033 = v1031[v1032];
            local l_value_1 = v1033.value;
            local l_reference_1 = v1033.reference;
            if l_reference_1:get() == l_value_1 and l_reference_1:id() == l_v869_1:id() then
                return true;
            end;
        end;
        return false;
    end;
    l_v871_1 = function()
        -- upvalues: l_v868_1 (ref), l_v610_4 (ref), v65 (ref), l_v869_1 (ref), l_v586_11 (ref), l_v607_10 (ref), l_v608_7 (ref), l_v609_5 (ref)
        local v1036 = entity.get_local_player();
        if v1036 == nil or not v1036:is_alive() then
            return;
        else
            local v1037 = l_v868_1:get_pos():clone();
            local v1038 = ui.get_alpha() > 0.5;
            l_v610_4 = v65.interp(l_v610_4, v1038, 0.05);
            local v1039 = l_v869_1:get();
            local v1040 = l_v586_11.font:get();
            local v1041 = l_v586_11.color:get();
            local v1042 = tostring(v1039);
            local v1043 = l_v607_10[v1040];
            local v1044 = render.measure_text(v1043, nil, v1042) + vector(l_v608_7, l_v609_5) * 2;
            render.text(v1043, v1037 + v1044 * 0.5, v1041, "c", v1042);
            render.rect_outline(v1037, v1037 + v1044, color(255, 255, 255, 255 * l_v610_4), 1, 4);
            l_v868_1:set_size(v1044);
            return;
        end;
    end;
    v874 = nil;
    v881 = function(v1045)
        -- upvalues: l_v871_1 (ref)
        events.render(l_v871_1, v1045:get());
    end;
    l_v586_11.enabled:set_callback(v881, true);
end;
v586 = nil;
v607 = l_play_0.features.interface.velocity_warning;
v608 = 4;
v609 = 6;
v610 = 168;
v611 = 34;
v868 = 160;
v869 = 4;
v870 = 0;
v871 = render.screen_size();
v874 = l_angles_0.new("velocity_warning"):build(vector(v871.x * 0.5 - v610 * 0.5, 160));
do
    local l_v607_11, l_v608_8, l_v609_6, l_v610_5, l_v611_4, l_v868_2, l_v869_2, l_v870_1, l_v874_1, l_v881_1 = v607, v608, v609, v610, v611, v868, v869, v870, v874, v881;
    l_v881_1 = function()
        -- upvalues: l_v874_1 (ref), l_v870_1 (ref), v65 (ref), l_v607_11 (ref), l_v610_5 (ref), l_v608_8 (ref), l_v609_6 (ref), l_v868_2 (ref), l_v869_2 (ref), l_v611_4 (ref)
        local v1056 = entity.get_local_player();
        if v1056 == nil then
            return;
        else
            local v1057 = l_v874_1:get_pos():clone();
            local v1058 = v1056:is_alive();
            local v1059 = ui.get_alpha() > 0.5;
            local l_m_flVelocityModifier_0 = v1056.m_flVelocityModifier;
            if not v1058 then
                l_m_flVelocityModifier_0 = 1;
            end;
            local v1061 = v1059 or v1058 and l_m_flVelocityModifier_0 < 1;
            l_v870_1 = v65.interp(l_v870_1, v1061, 0.05);
            if l_v870_1 <= 0 then
                return;
            else
                local v1062 = l_v607_11.color:get();
                local v1063 = color(0, 0, 0, 255);
                local v1064 = color(255, 255, 255, 255);
                local l_l_v870_1_0 = l_v870_1;
                v1062.a = v1062.a * l_l_v870_1_0;
                v1063.a = v1063.a * l_l_v870_1_0;
                v1064.a = v1064.a * l_l_v870_1_0;
                local v1066 = string.format("Max velocity reduced by %d%%", l_m_flVelocityModifier_0 * 100);
                local v1067 = 1;
                local v1068 = render.measure_text(v1067, nil, v1066);
                local v1069 = v1057 + vector(l_v610_5 * 0.5 - v1068.x * 0.5, l_v608_8);
                render.text(v1067, v1069, v1064, nil, v1066);
                v1057.y = v1069.y + v1068.y + l_v609_6;
                if v1062.a > 0 then
                    local v1070 = vector(l_v868_2, l_v869_2);
                    local v1071 = v1057 + vector(l_v610_5 * 0.5 - v1070.x * 0.5, 0);
                    local v1072 = vector(l_v868_2 * l_m_flVelocityModifier_0, l_v869_2);
                    render.shadow(v1071, v1071 + v1070, v1062, 24, 0, 4);
                    render.rect(v1071, v1071 + v1070, v1063, 4);
                    render.rect(v1071 + 1, v1071 + v1072 - 1, v1062, 4);
                end;
                l_v874_1:set_size(vector(l_v610_5, l_v611_4));
                return;
            end;
        end;
    end;
    v887 = nil;
    local function v1074(v1073)
        -- upvalues: l_v881_1 (ref)
        events.render(l_v881_1, v1073:get());
    end;
    l_v607_11.enabled:set_callback(v1074, true);
end;
l_angles_0 = nil;
v363 = nil;
v365 = l_play_0.features.visuals.animations;
v366 = ffi.typeof("            struct {\n                float  m_flLayerAnimtime;\n                float  m_flLayerFadeOuttime;\n    \n                // dispatch flags\n                void  *m_pDispatchedStudioHdr;\n                int    m_nDispatchedSrc;\n                int    m_nDispatchedDst;\n    \n                int    m_nOrder;\n                int    m_nSequence;\n                float  m_flPrevCycle;\n                float  m_flWeight;\n                float  m_flWeightDeltaRate;\n    \n                // used for automatic crossfades between sequence changes;\n                float  m_flPlaybackRate;\n                float  m_flCycle;\n                int    m_pOwner;\n                int    m_nInvalidatePhysicsBits;\n            } **\n        ");
do
    local l_v365_9, l_v366_12, l_l_viewmodel_offset_z_0_11, l_v586_12, l_v607_12, l_v608_9, l_v609_7, l_v610_6, l_v611_5, l_v868_3, l_v869_3, l_v870_2 = v365, v366, l_viewmodel_offset_z_0, v586, v607, v608, v609, v610, v611, v868, v869, v870;
    l_l_viewmodel_offset_z_0_11 = function(v1087)
        -- upvalues: l_v366_12 (ref)
        return ffi.cast(l_v366_12, ffi.cast("uintptr_t", v1087[0]) + 10640)[0];
    end;
    l_v586_12 = 6;
    l_v607_12 = 12;
    l_v608_9 = function(v1088)
        -- upvalues: l_v365_9 (ref), v17 (ref)
        local v1089 = l_v365_9.on_ground:get();
        if v1089 == "Static" then
            v1088.m_flPoseParameter[0] = 1;
            v17.antiaim.misc.leg_movement:override("Sliding");
            return;
        elseif v1089 == "Jitter" then
            if globals.tickcount % 4 > 1 then
                v1088.m_flPoseParameter[0] = 1;
                v1088.m_flPoseParameter[1] = 1;
            end;
            v17.antiaim.misc.leg_movement:override("Sliding");
            return;
        elseif v1089 == "Walking" then
            v1088.m_flPoseParameter[7] = 0;
            v17.antiaim.misc.leg_movement:override("Walking");
            return;
        elseif v1089 == "Kangaroo" then
            v1088.m_flPoseParameter[0] = utils.random_float(0, 1);
            v17.antiaim.misc.leg_movement:override("Sliding");
            return;
        else
            v17.antiaim.misc.leg_movement:override();
            return;
        end;
    end;
    l_v609_7 = function(v1090)
        -- upvalues: l_v365_9 (ref), l_l_viewmodel_offset_z_0_11 (ref), l_v586_12 (ref)
        local v1091 = l_v365_9.in_air:get();
        if v1091 == "Static" then
            v1090.m_flPoseParameter[6] = 1;
            return;
        elseif v1091 == "Jitter" then
            v1090.m_flPoseParameter[6] = globals.tickcount % 4 > 1 and 1 or 0;
            return;
        elseif v1091 == "Walking" then
            local v1092 = l_l_viewmodel_offset_z_0_11(v1090);
            if v1092 == nil then
                return;
            else
                local v1093 = v1092[l_v586_12];
                if v1093 == nil then
                    return;
                else
                    v1093.m_flWeight = 1;
                    return;
                end;
            end;
        elseif v1091 == "Kangaroo" then
            v1090.m_flPoseParameter[6] = utils.random_float(0.1, 1);
            return;
        else
            return;
        end;
    end;
    l_v610_6 = function(v1094)
        -- upvalues: l_v365_9 (ref)
        if not l_v365_9.pitch_on_land:get() then
            return;
        else
            local v1095 = v1094:get_anim_state();
            if v1095 == nil or not v1095.landing then
                return;
            else
                v1094.m_flPoseParameter[12] = 0.5;
                return;
            end;
        end;
    end;
    l_v611_5 = function(v1096)
        -- upvalues: l_v365_9 (ref)
        if not l_v365_9.sliding_slowwalk:get() then
            return;
        else
            v1096.m_flPoseParameter[9] = 0;
            return;
        end;
    end;
    l_v868_3 = function(v1097)
        -- upvalues: l_v365_9 (ref)
        if not l_v365_9.sliding_crouch:get() then
            return;
        else
            v1097.m_flPoseParameter[8] = 0;
            return;
        end;
    end;
    l_v869_3 = function(v1098)
        -- upvalues: l_l_viewmodel_offset_z_0_11 (ref), l_v607_12 (ref), l_v365_9 (ref)
        local v1099 = l_l_viewmodel_offset_z_0_11(v1098);
        if v1099 == nil then
            return;
        else
            local v1100 = v1099[l_v607_12];
            if v1100 == nil then
                return;
            elseif l_v365_9.earthquake:get() then
                v1100.m_flWeight = utils.random_float(0, 1);
                return;
            else
                local v1101 = l_v365_9.move_lean:get();
                if v1101 == -1 then
                    return;
                else
                    v1100.m_flWeight = v1101 * 0.01;
                    return;
                end;
            end;
        end;
    end;
    l_v870_2 = function(v1102)
        -- upvalues: l_v608_9 (ref), l_v609_7 (ref), l_v610_6 (ref), l_v611_5 (ref), l_v868_3 (ref), l_v869_3 (ref)
        local v1103 = entity.get_local_player();
        if v1102 ~= v1103 then
            return;
        else
            l_v608_9(v1103);
            l_v609_7(v1103);
            l_v610_6(v1103);
            l_v611_5(v1103);
            l_v868_3(v1103);
            l_v869_3(v1103);
            return;
        end;
    end;
    v871 = nil;
    v874 = function(v1104)
        -- upvalues: v17 (ref), l_v870_2 (ref)
        local v1105 = v1104:get();
        if not v1105 then
            v17.antiaim.misc.leg_movement:override();
        end;
        events.post_update_clientside_animation(l_v870_2, v1105);
    end;
    l_v365_9.enabled:set_callback(v874, true);
end;
v365 = nil;
v366 = l_play_0.features.visuals.scope_overlay;
l_viewmodel_offset_z_0 = 0;
do
    local l_v366_13, l_l_viewmodel_offset_z_0_12, l_v586_13 = v366, l_viewmodel_offset_z_0, v586;
    l_v586_13 = function()
        -- upvalues: l_l_viewmodel_offset_z_0_12 (ref), v65 (ref), v17 (ref), l_v366_13 (ref)
        local v1109 = entity.get_local_player();
        if v1109 == nil or not v1109:is_alive() then
            return;
        else
            local v1110 = v1109:get_player_weapon();
            if v1110 == nil then
                return;
            else
                l_l_viewmodel_offset_z_0_12 = v65.interp(l_l_viewmodel_offset_z_0_12, v1109.m_bIsScoped, 0.05);
                if l_l_viewmodel_offset_z_0_12 <= 0 then
                    return;
                else
                    v17.visuals.world.main.scope_overlay:override("Remove All");
                    local v1111 = render.screen_size() * 0.5;
                    local v1112 = l_v366_13.size:get() * l_l_viewmodel_offset_z_0_12;
                    local v1113 = l_v366_13.gap:get();
                    local v1114 = l_v366_13.color:get();
                    local v1115 = v1110:get_inaccuracy();
                    if l_v366_13.additions:get("Spread Dependency") then
                        v1113 = v1113 + v1115 * 100;
                    end;
                    local v1116 = v1114:clone();
                    local v1117 = v1114:clone();
                    if l_v366_13.additions:get("Inverted") then
                        v1116.a = v1116.a * l_l_viewmodel_offset_z_0_12;
                        v1117.a = 0;
                    else
                        v1116.a = 0;
                        v1117.a = v1117.a * l_l_viewmodel_offset_z_0_12;
                    end;
                    local v1118 = 0;
                    if l_v366_13.additions:get("Rotated") then
                        v1118 = 45;
                    end;
                    if l_v366_13.additions:get("Animated") then
                        v1118 = -(globals.realtime * 100 % 180 - 360);
                    end;
                    if v1118 ~= 0 then
                        render.push_rotation(v1118);
                    end;
                    if not l_v366_13.exclude_lines:get("Top") then
                        local v1119 = vector(v1111.x, v1111.y - (v1112 + v1113));
                        local v1120 = vector(v1119.x + 1, v1111.y - v1113);
                        render.gradient(v1119, v1120, v1116, v1116, v1117, v1117);
                    end;
                    if not l_v366_13.exclude_lines:get("Bottom") then
                        local v1121 = vector(v1111.x, v1111.y + v1112 + v1113);
                        local v1122 = vector(v1121.x + 1, v1111.y + v1113);
                        render.gradient(v1121, v1122, v1116, v1116, v1117, v1117);
                    end;
                    if not l_v366_13.exclude_lines:get("Left") then
                        local v1123 = vector(v1111.x - (v1112 + v1113), v1111.y);
                        local v1124 = vector(v1111.x - v1113, v1111.y + 1);
                        render.gradient(v1123, v1124, v1116, v1117, v1116, v1117);
                    end;
                    if not l_v366_13.exclude_lines:get("Right") then
                        local v1125 = vector(v1111.x + v1112 + v1113, v1111.y);
                        local v1126 = vector(v1111.x + v1113, v1111.y + 1);
                        render.gradient(v1125, v1126, v1116, v1117, v1116, v1117);
                    end;
                    if v1118 ~= 0 then
                        render.pop_rotation();
                    end;
                    return;
                end;
            end;
        end;
    end;
    v607 = nil;
    v608 = function(v1127)
        -- upvalues: v17 (ref), l_v586_13 (ref)
        local v1128 = v1127:get();
        if not v1128 then
            v17.visuals.world.main.scope_overlay:override();
        end;
        events.render(l_v586_13, v1128);
    end;
    l_v366_13.enabled:set_callback(v608, true);
end;
v366 = nil;
l_viewmodel_offset_z_0 = l_play_0.features.visuals.hit_marker;
v586 = {};
do
    local l_l_viewmodel_offset_z_0_13, l_v586_14, l_v607_13, l_v608_10, l_v609_8 = l_viewmodel_offset_z_0, v586, v607, v608, v609;
    l_v607_13 = function()
        -- upvalues: l_v586_14 (ref)
        l_v586_14 = {};
    end;
    l_v608_10 = function(v1134)
        -- upvalues: l_v586_14 (ref)
        local v1135 = {
            position = v1134.aim, 
            time = 3
        };
        table.insert(l_v586_14, 1, v1135);
    end;
    l_v609_8 = function()
        -- upvalues: l_v586_14 (ref), l_l_viewmodel_offset_z_0_13 (ref)
        local v1136 = entity.get_local_player();
        if v1136 == nil or not v1136:is_alive() then
            return;
        else
            local v1137 = render.screen_size() * 0.5;
            local l_frametime_3 = globals.frametime;
            local v1139 = #l_v586_14;
            for v1140 = v1139, 1, -1 do
                local v1141 = l_v586_14[v1140];
                if v1141.time > 0 then
                    v1141.time = v1141.time - l_frametime_3;
                else
                    table.remove(l_v586_14, v1139);
                end;
            end;
            local v1142 = l_l_viewmodel_offset_z_0_13.thickness:get() * 0.5;
            local v1143 = l_l_viewmodel_offset_z_0_13.size:get() + v1142;
            local v1144 = l_l_viewmodel_offset_z_0_13.color:get();
            if l_l_viewmodel_offset_z_0_13.type:get("World") then
                for v1145 = 1, #l_v586_14 do
                    local v1146 = l_v586_14[v1145];
                    local v1147 = render.world_to_screen(v1146.position);
                    if v1147 ~= nil then
                        local v1148 = math.clamp(v1146.time, 0, 1);
                        local v1149 = v1144:clone();
                        local v1150 = v1147 - vector(v1142, v1143);
                        local v1151 = v1147 + vector(v1142, v1143);
                        local v1152 = v1147 - vector(v1143, v1142);
                        local v1153 = v1147 + vector(v1143, v1142);
                        v1149.a = v1149.a * v1148;
                        render.rect(v1150, v1151, v1149);
                        render.rect(v1152, v1153, v1149);
                    end;
                end;
            end;
            if l_l_viewmodel_offset_z_0_13.type:get("Screen") then
                local v1154 = l_v586_14[1];
                if v1154 then
                    local v1155 = math.clamp(v1154.time, 0, 1);
                    local v1156 = color(255, 255, 255, 255);
                    v1156.a = v1156.a * v1155;
                    render.line(vector(v1137.x - 10, v1137.y - 10), vector(v1137.x - 5, v1137.y - 5), v1156);
                    render.line(vector(v1137.x + 10, v1137.y - 10), vector(v1137.x + 5, v1137.y - 5), v1156);
                    render.line(vector(v1137.x + 10, v1137.y + 10), vector(v1137.x + 5, v1137.y + 5), v1156);
                    render.line(vector(v1137.x - 10, v1137.y + 10), vector(v1137.x - 5, v1137.y + 5), v1156);
                end;
            end;
            return;
        end;
    end;
    v610 = nil;
    v611 = function(v1157)
        -- upvalues: l_v607_13 (ref), l_v609_8 (ref), l_v608_10 (ref)
        local v1158 = v1157:get();
        if not v1158 then
            l_v607_13();
        end;
        events.render(l_v609_8, v1158);
        events.aim_ack(l_v608_10, v1158);
    end;
    l_l_viewmodel_offset_z_0_13.enabled:set_callback(v611, true);
end;
l_viewmodel_offset_z_0 = nil;
v586 = l_play_0.features.visuals.nade_radius;
do
    local l_v586_15, l_v607_14 = v586, v607;
    l_v607_14 = function()
        -- upvalues: l_v586_15 (ref)
        if entity.get_local_player() == nil then
            return;
        else
            local v1161 = l_v586_15.molotov_color:get();
            local v1162 = l_v586_15.smoke_color:get();
            if l_v586_15.molotov:get() then
                entity.get_entities("CInferno", nil, function(v1163)
                    -- upvalues: v1161 (ref)
                    local v1164 = v1163:get_origin();
                    local v1165 = v1163:get_bbox();
                    local v1166 = v1161:alpha_modulate(v1165.alpha * 255);
                    render.circle_3d_outline(v1164, v1166, 125, 0, 1, 1.5);
                end);
            end;
            if l_v586_15.smoke:get() then
                entity.get_entities("CSmokeGrenadeProjectile", nil, function(v1167)
                    -- upvalues: v1162 (ref)
                    if not v1167.m_bDidSmokeEffect then
                        return;
                    else
                        local v1168 = v1167:get_origin();
                        local v1169 = v1167:get_bbox();
                        local v1170 = v1162:alpha_modulate(v1169.alpha * 255);
                        render.circle_3d_outline(v1168, v1170, 125, 0, 1, 1.5);
                        return;
                    end;
                end);
            end;
            return;
        end;
    end;
    v608 = nil;
    v609 = function(v1171)
        -- upvalues: l_v607_14 (ref)
        events.render(l_v607_14, v1171:get());
    end;
    l_v586_15.enabled:set_callback(v609, true);
end;
v586 = nil;
v607 = l_play_0.features.visuals.keep_model_transparency;
v608 = function()
    local v1172 = entity.get_local_player();
    if v1172 == nil or not v1172:is_alive() then
        return;
    else
        local l_m_bIsScoped_0 = v1172.m_bIsScoped;
        local l_m_bResumeZoom_0 = v1172.m_bResumeZoom;
        if not l_m_bIsScoped_0 and not l_m_bResumeZoom_0 then
            return;
        else
            return 59;
        end;
    end;
end;
v609 = nil;
do
    local l_v608_11 = v608;
    v610 = function(v1176)
        -- upvalues: l_v608_11 (ref)
        events.localplayer_transparency(l_v608_11, v1176:get());
    end;
    v607.enabled:set_callback(v610, true);
end;
v363 = nil;
ui.sidebar(v9.name, v9.icon);