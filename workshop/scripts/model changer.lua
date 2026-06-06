local v0 = (function()
    local anonteam_0_0 = ffi.load("kernel32")
local anonteam_0_1 = ffi.load("shell32")
local anonteam_0_2 = ffi.load("WinInet")
local anonteam_0_3 = ffi.load("UrlMon")

ffi.cdef("    typedef int BOOL;\n    typedef unsigned long DWORD;\n    typedef long HRESULT;\n    typedef void* HANDLE;\n    typedef void* HINSTANCE;\n    typedef void* HWND;\n    typedef void* HICON;\n    typedef const char* LPCSTR;\n    typedef void* LPVOID;\n    typedef void* HKEY;\n\n    typedef struct {\n        DWORD cbSize;\n        DWORD fMask;\n        HWND hwnd;\n        LPCSTR lpVerb;\n        LPCSTR lpFile;\n        LPCSTR lpParameters;\n        LPCSTR lpDirectory;\n        int nShow;\n        HINSTANCE hInstApp;\n        LPVOID lpIDList;\n        LPCSTR lpClass;\n        HKEY hkeyClass;\n        DWORD dwHotKey;\n        HICON hIcon;\n        HANDLE hProcess;\n    } SHELLEXECUTEINFOA, *LPSHELLEXECUTEINFOA;\n\n    BOOL ShellExecuteExA(LPSHELLEXECUTEINFOA lpExecInfo);\n    DWORD WaitForSingleObject(HANDLE hHandle, DWORD dwMilliseconds);\n    BOOL CloseHandle(HANDLE hObject);\n    BOOL GetExitCodeProcess(HANDLE hProcess, DWORD* lpExitCode);\n\n    HINSTANCE ShellExecuteA(HWND hwnd, LPCSTR lpOperation, LPCSTR lpFile, LPCSTR lpParameters, LPCSTR lpDirectory, int nShowCmd);\n\n    HRESULT URLDownloadToFileA(LPVOID pCaller, LPCSTR szURL, LPCSTR szFileName, DWORD dwReserved, int lpfnCB); // #5 is wrong type, should be LPVOID. But since everyone uses it I give in for compatibility reasons.\n\n    BOOL DeleteUrlCacheEntryA(LPCSTR lpszUrlName);\n    BOOL DeleteFileA(LPCSTR lpFileName);\n    DWORD GetFileAttributesA(LPCSTR lpFileName);\n")

local anonteam_0_4 = {
	download = function(arg_1_0, arg_1_1)
		anonteam_0_2.DeleteUrlCacheEntryA(arg_1_0)

		if anonteam_0_3.URLDownloadToFileA(nil, arg_1_0, arg_1_1, 0, 0) == 0 then
			return true
		end

		return false, "Download failed"
	end,
	extract = function(arg_2_0, arg_2_1)
		if not arg_2_1:match("[\\/]$") then
			arg_2_1 = arg_2_1 .. "\\"
		end

		local anonteam_2_0 = ffi.new("SHELLEXECUTEINFOA")

		anonteam_2_0.cbSize = ffi.sizeof(anonteam_2_0)
		anonteam_2_0.fMask = 64
		anonteam_2_0.hwnd = nil
		anonteam_2_0.lpVerb = "open"
		anonteam_2_0.lpFile = "powershell.exe"
		anonteam_2_0.lpParameters = string.format("-NoProfile -WindowStyle Hidden -Command \"Expand-Archive -LiteralPath '%s' -DestinationPath '%s' -Force\"", arg_2_0, arg_2_1)
		anonteam_2_0.lpDirectory = nil
		anonteam_2_0.nShow = 0
		anonteam_2_0.hInstApp = nil
		anonteam_2_0.hProcess = nil

		if anonteam_0_1.ShellExecuteExA(anonteam_2_0) == 0 then
			return false, "ShellExecuteExA failed"
		end

		anonteam_0_0.WaitForSingleObject(anonteam_2_0.hProcess, 4294967295)

		local anonteam_2_1 = ffi.new("DWORD[1]")

		if anonteam_0_0.GetExitCodeProcess(anonteam_2_0.hProcess, anonteam_2_1) == 0 then
			anonteam_0_0.CloseHandle(anonteam_2_0.hProcess)

			return false, "GetExitCodeProcess failed"
		end

		anonteam_0_0.CloseHandle(anonteam_2_0.hProcess)

		if anonteam_2_1[0] == 0 then
			return true
		else
			return false, "Powershell failed"
		end
	end,
	delete = function(arg_3_0)
		if anonteam_0_0.DeleteFileA(arg_3_0) == 0 then
			return false, "DeleteFileA failed"
		end

		return true
	end,
	open = function(arg_4_0)
		local anonteam_4_0 = anonteam_0_1.ShellExecuteA(nil, "open", arg_4_0, nil, nil, 1)

		if anonteam_4_0 == nil or tonumber(ffi.cast("intptr_t", anonteam_4_0)) <= 32 then
			return false, "ShellExecuteA failed"
		end

		return true
	end,
	exists = function(arg_5_0)
		return anonteam_0_0.GetFileAttributesA(arg_5_0) ~= 4294967295
	end
}
local anonteam_0_5 = (function()
	local function anonteam_6_0()
		print_error("unauthorized access")
		common.unload_script()
	end

	return {
		download = anonteam_6_0,
		extract = anonteam_6_0,
		delete = anonteam_6_0,
		open = anonteam_6_0,
		exists = anonteam_6_0
	}
end)()

return setmetatable({}, {
	__call = function(arg_8_0, arg_8_1)
		local anonteam_8_0 = arg_8_1 == "bmxfbmVlZHNfdG9fZml4X3RoZV9kdW1wZXI=" and anonteam_0_4 or anonteam_0_5

		return setmetatable({}, {
			__index = anonteam_8_0,
			__metatable = {}
		})
	end,
	__metatable = anonteam_0_5
})
end)()

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

local _, l_result_0 = pcall(require, "neverlose/clipboard");
local v3 = true -- db["weapon_model_changer:UBtdBuzKUvXDKseM0&"] or false;
local v4 = db.cloud_model_changer or {};
v4.custom_list = v4.custom_list or {
    T = {}, 
    CT = {}
};
local v5 = utils.get_vfunc("engine.dll", "VEngineClientStringTable001", 3, "void*(__thiscall*)(void*, const char*)");
local v6 = utils.get_vfunc("engine.dll", "VModelInfoClient004", 39, "void*(__thiscall*)(void*, const char*)");
local v7 = utils.get_vfunc(8, "int*(__thiscall*)(void*, bool, const char*, int, const void*)");
local v8 = utils.get_vfunc("engine.dll", "VModelInfoClient004", 2, "int(__thiscall*)(void*, const char*)");
local v9 = utils.get_vfunc(75, "void(__thiscall*)(void*, int)");
local v10 = utils.get_vfunc("client.dll", "VClientEntityList003", 4, "void*(__thiscall*)(void*, void*)");
local v11 = utils.get_vfunc("engine.dll", "VModelInfoClient004", 1, "const void*(__thiscall*)(void*, int)");
local v12 = utils.get_vfunc("engine.dll", "VModelInfoClient004", 32, "void*(__thiscall*)(void*, const void*)");
local v13 = ffi.cast("int(__fastcall*)(void*, void*, int)", utils.opcode_scan("client.dll", "55 8B EC 53 8B 5D 08 56 8B F1 83"));
local v14 = ffi.cast("void(__fastcall*)(void*)", utils.opcode_scan("client.dll", "51 56 57 8B F9 33 F6 39 ? ? ? ? ? 7E 38"));
local v15 = utils.get_vfunc(247, "void(__thiscall*)(void*, int)");
local v16 = {
    [1] = {
        name = "CS:GO - Jumpsuit (A)", 
        path = "models/player/custom_player/legacy/tm_jumpsuit_variantA.mdl"
    }, 
    [2] = {
        name = "CS:GO - Jumpsuit (B)", 
        path = "models/player/custom_player/legacy/tm_jumpsuit_variantB.mdl"
    }, 
    [3] = {
        name = "CS:GO - Jumpsuit (C)", 
        path = "models/player/custom_player/legacy/tm_jumpsuit_variantC.mdl"
    }, 
    [4] = {
        name = "CS:GO - ST6", 
        path = "models/player/custom_player/legacy/ctm_st6.mdl"
    }, 
    [5] = {
        name = "CS:GO - ST6 (A)", 
        path = "models/player/custom_player/legacy/ctm_st6_variantA.mdl"
    }, 
    [6] = {
        name = "CS:GO - ST6 (B)", 
        path = "models/player/custom_player/legacy/ctm_st6_variantB.mdl"
    }, 
    [7] = {
        name = "CS:GO - ST6 (C)", 
        path = "models/player/custom_player/legacy/ctm_st6_variantC.mdl"
    }, 
    [8] = {
        name = "CS:GO - ST6 (D)", 
        path = "models/player/custom_player/legacy/ctm_st6_variantD.mdl"
    }, 
    [9] = {
        name = "CS:GO - FBI", 
        path = "models/player/custom_player/legacy/ctm_fbi.mdl"
    }, 
    [10] = {
        name = "CS:GO - FBI (A)", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantA.mdl"
    }, 
    [11] = {
        name = "CS:GO - FBI (C)", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantC.mdl"
    }, 
    [12] = {
        name = "CS:GO - FBI (D)", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantD.mdl"
    }, 
    [13] = {
        name = "CS:GO - FBI (E)", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantE.mdl"
    }, 
    [14] = {
        name = "CS:GO - GIGN", 
        path = "models/player/custom_player/legacy/ctm_gign.mdl"
    }, 
    [15] = {
        name = "CS:GO - GIGN (A)", 
        path = "models/player/custom_player/legacy/ctm_gign_variantA.mdl"
    }, 
    [16] = {
        name = "CS:GO - GIGN (B)", 
        path = "models/player/custom_player/legacy/ctm_gign_variantB.mdl"
    }, 
    [17] = {
        name = "CS:GO - GIGN (C)", 
        path = "models/player/custom_player/legacy/ctm_gign_variantC.mdl"
    }, 
    [18] = {
        name = "CS:GO - GIGN (D)", 
        path = "models/player/custom_player/legacy/ctm_gign_variantD.mdl"
    }, 
    [19] = {
        name = "CS:GO - GSG9", 
        path = "models/player/custom_player/legacy/ctm_gsg9.mdl"
    }, 
    [20] = {
        name = "CS:GO - GSG9 (A)", 
        path = "models/player/custom_player/legacy/ctm_gsg9_variantA.mdl"
    }, 
    [21] = {
        name = "CS:GO - GSG9 (B)", 
        path = "models/player/custom_player/legacy/ctm_gsg9_variantB.mdl"
    }, 
    [22] = {
        name = "CS:GO - GSG9 (C)", 
        path = "models/player/custom_player/legacy/ctm_gsg9_variantC.mdl"
    }, 
    [23] = {
        name = "CS:GO - GSG9 (D)", 
        path = "models/player/custom_player/legacy/ctm_gsg9_variantD.mdl"
    }, 
    [24] = {
        name = "CS:GO - IDF", 
        path = "models/player/custom_player/legacy/ctm_idf.mdl"
    }, 
    [25] = {
        name = "CS:GO - IDF (B)", 
        path = "models/player/custom_player/legacy/ctm_idf_variantB.mdl"
    }, 
    [26] = {
        name = "CS:GO - IDF (C)", 
        path = "models/player/custom_player/legacy/ctm_idf_variantC.mdl"
    }, 
    [27] = {
        name = "CS:GO - IDF (D)", 
        path = "models/player/custom_player/legacy/ctm_idf_variantD.mdl"
    }, 
    [28] = {
        name = "CS:GO - IDF (E)", 
        path = "models/player/custom_player/legacy/ctm_idf_variantE.mdl"
    }, 
    [29] = {
        name = "CS:GO - IDF (F)", 
        path = "models/player/custom_player/legacy/ctm_idf_variantF.mdl"
    }, 
    [30] = {
        name = "CS:GO - SAS", 
        path = "models/player/custom_player/legacy/ctm_sas.mdl"
    }, 
    [31] = {
        name = "CS:GO - SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat.mdl"
    }, 
    [32] = {
        name = "CS:GO - SWAT (A)", 
        path = "models/player/custom_player/legacy/ctm_swat_variantA.mdl"
    }, 
    [33] = {
        name = "CS:GO - SWAT (B)", 
        path = "models/player/custom_player/legacy/ctm_swat_variantB.mdl"
    }, 
    [34] = {
        name = "CS:GO - SWAT (C)", 
        path = "models/player/custom_player/legacy/ctm_swat_variantC.mdl"
    }, 
    [35] = {
        name = "CS:GO - SWAT (D)", 
        path = "models/player/custom_player/legacy/ctm_swat_variantD.mdl"
    }, 
    [36] = {
        name = "CS:GO - Anarchist", 
        path = "models/player/custom_player/legacy/tm_anarchist.mdl"
    }, 
    [37] = {
        name = "CS:GO - Anarchist (A)", 
        path = "models/player/custom_player/legacy/tm_anarchist_variantA.mdl"
    }, 
    [38] = {
        name = "CS:GO - Anarchist (B)", 
        path = "models/player/custom_player/legacy/tm_anarchist_variantB.mdl"
    }, 
    [39] = {
        name = "CS:GO - Anarchist (C)", 
        path = "models/player/custom_player/legacy/tm_anarchist_variantC.mdl"
    }, 
    [40] = {
        name = "CS:GO - Anarchist (D)", 
        path = "models/player/custom_player/legacy/tm_anarchist_variantD.mdl"
    }, 
    [41] = {
        name = "CS:GO - Balkan", 
        path = "models/player/custom_player/legacy/tm_balkan_variantA.mdl"
    }, 
    [42] = {
        name = "CS:GO - Balkan (B)", 
        path = "models/player/custom_player/legacy/tm_balkan_variantB.mdl"
    }, 
    [43] = {
        name = "CS:GO - Balkan (C)", 
        path = "models/player/custom_player/legacy/tm_balkan_variantC.mdl"
    }, 
    [44] = {
        name = "CS:GO - Balkan (D)", 
        path = "models/player/custom_player/legacy/tm_balkan_variantD.mdl"
    }, 
    [45] = {
        name = "CS:GO - Balkan (E)", 
        path = "models/player/custom_player/legacy/tm_balkan_variantE.mdl"
    }, 
    [46] = {
        name = "CS:GO - Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantA.mdl"
    }, 
    [47] = {
        name = "CS:GO - Elite Crew (B)", 
        path = "models/player/custom_player/legacy/tm_leet_variantB.mdl"
    }, 
    [48] = {
        name = "CS:GO - Elite Crew (C)", 
        path = "models/player/custom_player/legacy/tm_leet_variantC.mdl"
    }, 
    [49] = {
        name = "CS:GO - Elite Crew (D)", 
        path = "models/player/custom_player/legacy/tm_leet_variantD.mdl"
    }, 
    [50] = {
        name = "CS:GO - Elite Crew (E)", 
        path = "models/player/custom_player/legacy/tm_leet_variantE.mdl"
    }, 
    [51] = {
        name = "CS:GO - Elite Crew (K)", 
        path = "models/player/custom_player/legacy/tm_leet_variantK.mdl"
    }, 
    [52] = {
        name = "CS:GO - Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix.mdl"
    }, 
    [53] = {
        name = "CS:GO - Phoenix (A)", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantA.mdl"
    }, 
    [54] = {
        name = "CS:GO - Phoenix (B)", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantB.mdl"
    }, 
    [55] = {
        name = "CS:GO - Phoenix (C)", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantC.mdl"
    }, 
    [56] = {
        name = "CS:GO - Phoenix (D)", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantD.mdl"
    }, 
    [57] = {
        name = "CS:GO - Pirate", 
        path = "models/player/custom_player/legacy/tm_pirate.mdl"
    }, 
    [58] = {
        name = "CS:GO - Pirate (A)", 
        path = "models/player/custom_player/legacy/tm_pirate_variantA.mdl"
    }, 
    [59] = {
        name = "CS:GO - Pirate (B)", 
        path = "models/player/custom_player/legacy/tm_pirate_variantB.mdl"
    }, 
    [60] = {
        name = "CS:GO - Pirate (C)", 
        path = "models/player/custom_player/legacy/tm_pirate_variantC.mdl"
    }, 
    [61] = {
        name = "CS:GO - Pirate (D)", 
        path = "models/player/custom_player/legacy/tm_pirate_variantD.mdl"
    }, 
    [62] = {
        name = "CS:GO - Professional", 
        path = "models/player/custom_player/legacy/tm_professional.mdl"
    }, 
    [63] = {
        name = "CS:GO - Professional (1)", 
        path = "models/player/custom_player/legacy/tm_professional_var1.mdl"
    }, 
    [64] = {
        name = "CS:GO - Professional (2)", 
        path = "models/player/custom_player/legacy/tm_professional_var2.mdl"
    }, 
    [65] = {
        name = "CS:GO - Professional (3)", 
        path = "models/player/custom_player/legacy/tm_professional_var3.mdl"
    }, 
    [66] = {
        name = "CS:GO - Professional (4)", 
        path = "models/player/custom_player/legacy/tm_professional_var4.mdl"
    }, 
    [67] = {
        name = "CS:GO - Separatist", 
        path = "models/player/custom_player/legacy/tm_separatist.mdl"
    }, 
    [68] = {
        name = "CS:GO - Separatist (A)", 
        path = "models/player/custom_player/legacy/tm_separatist_variantA.mdl"
    }, 
    [69] = {
        name = "CS:GO - Separatist (B)", 
        path = "models/player/custom_player/legacy/tm_separatist_variantB.mdl"
    }, 
    [70] = {
        name = "CS:GO - Separatist (C)", 
        path = "models/player/custom_player/legacy/tm_separatist_variantC.mdl"
    }, 
    [71] = {
        name = "CS:GO - Separatist (D)", 
        path = "models/player/custom_player/legacy/tm_separatist_variantD.mdl"
    }, 
    [72] = {
        name = "CS:GO - Heavy Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix_heavy.mdl"
    }, 
    [73] = {
        name = "CS:GO - Heavy CT", 
        path = "models/player/custom_player/legacy/ctm_heavy.mdl"
    }, 
    [74] = {
        name = "CS:GO - Operator | FBI SWAT", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantF.mdl"
    }, 
    [75] = {
        name = "CS:GO - Markus Delrow | FBI HRT", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantG.mdl"
    }, 
    [76] = {
        name = "CS:GO - Michael Syfers | FBI Sniper", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantH.mdl"
    }, 
    [77] = {
        name = "CS:GO - B Squadron Officer | SAS", 
        path = "models/player/custom_player/legacy/ctm_sas_variantF.mdl"
    }, 
    [78] = {
        name = "CS:GO - D Squadron Officer | NZSAS", 
        path = "models/player/custom_player/legacy/ctm_sas_variantG.mdl"
    }, 
    [79] = {
        name = "CS:GO - Seal Team 6 Soldier | NSWC SEAL", 
        path = "models/player/custom_player/legacy/ctm_st6_variantE.mdl"
    }, 
    [80] = {
        name = "CS:GO - Buckshot | NSWC SEAL", 
        path = "models/player/custom_player/legacy/ctm_st6_variantG.mdl"
    }, 
    [81] = {
        name = "CS:GO - Lt. Commander Ricksaw | NSWC SEAL", 
        path = "models/player/custom_player/legacy/ctm_st6_variantI.mdl"
    }, 
    [82] = {
        name = "CS:GO - 'Blueberries' Buckshot | NSWC SEAL", 
        path = "models/player/custom_player/legacy/ctm_st6_variantJ.mdl"
    }, 
    [83] = {
        name = "CS:GO - 3rd Commando Company | KSK", 
        path = "models/player/custom_player/legacy/ctm_st6_variantK.mdl"
    }, 
    [84] = {
        name = "CS:GO - 'Two Times' McCoy | TACP Cavalry", 
        path = "models/player/custom_player/legacy/ctm_st6_variantL.mdl"
    }, 
    [85] = {
        name = "CS:GO - 'Two Times' McCoy | USAF TACP", 
        path = "models/player/custom_player/legacy/ctm_st6_variantM.mdl"
    }, 
    [86] = {
        name = "CS:GO - Primeiro Tenente | Brazilian 1st Battalion", 
        path = "models/player/custom_player/legacy/ctm_st6_variantN.mdl"
    }, 
    [87] = {
        name = "CS:GO - Cmdr. Mae 'Dead Cold' Jamison | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantE.mdl"
    }, 
    [88] = {
        name = "CS:GO - 1st Lieutenant Farlow | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantF.mdl"
    }, 
    [89] = {
        name = "CS:GO - John 'Van Healen' Kask | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantG.mdl"
    }, 
    [90] = {
        name = "CS:GO - Bio-Haz Specialist | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantH.mdl"
    }, 
    [91] = {
        name = "CS:GO - Sergeant Bombson | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantI.mdl"
    }, 
    [92] = {
        name = "CS:GO - Chem-Haz Specialist | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantJ.mdl"
    }, 
    [93] = {
        name = "CS:GO - Lieutenant 'Tree Hugger' Farlow | SWAT", 
        path = "models/player/custom_player/legacy/ctm_swat_variantK.mdl"
    }, 
    [94] = {
        name = "CS:GO - Dragomir | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantF.mdl"
    }, 
    [95] = {
        name = "CS:GO - Rezan The Ready | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantG.mdl"
    }, 
    [96] = {
        name = "CS:GO - 'The Doctor' Romanov | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantH.mdl"
    }, 
    [97] = {
        name = "CS:GO - Maximus | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantI.mdl"
    }, 
    [98] = {
        name = "CS:GO - Blackwolf | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantJ.mdl"
    }, 
    [99] = {
        name = "CS:GO - Rezan the Redshirt | Sabre", 
        path = "models/player/custom_player/legacy/tm_balkan_variantK.mdl"
    }, 
    [100] = {
        name = "CS:GO - Dragomir | Sabre Footsoldier", 
        path = "models/player/custom_player/legacy/tm_balkan_variantL.mdl"
    }, 
    [101] = {
        name = "CS:GO - The Elite Mr. Muhlik | Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantF.mdl"
    }, 
    [102] = {
        name = "CS:GO - Ground Rebel | Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantG.mdl"
    }, 
    [103] = {
        name = "CS:GO - Osiris | Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantH.mdl"
    }, 
    [104] = {
        name = "CS:GO - Prof. Shahmat | Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantI.mdl"
    }, 
    [105] = {
        name = "CS:GO - Jungle Rebel | Elite Crew", 
        path = "models/player/custom_player/legacy/tm_leet_variantJ.mdl"
    }, 
    [106] = {
        name = "CS:GO - Enforcer | Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantF.mdl"
    }, 
    [107] = {
        name = "CS:GO - Slingshot | Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantG.mdl"
    }, 
    [108] = {
        name = "CS:GO - Soldier | Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantH.mdl"
    }, 
    [109] = {
        name = "CS:GO - Street Soldier | Phoenix", 
        path = "models/player/custom_player/legacy/tm_phoenix_variantI.mdl"
    }, 
    [110] = {
        name = "CS:GO - Sir Bloody Miami Darryl | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF.mdl"
    }, 
    [111] = {
        name = "CS:GO - Sir Bloody Silent Darryl | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF1.mdl"
    }, 
    [112] = {
        name = "CS:GO - Sir Bloody Skullhead Darryl | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF2.mdl"
    }, 
    [113] = {
        name = "CS:GO - Sir Bloody Darryl Royale | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF3.mdl"
    }, 
    [114] = {
        name = "CS:GO - Sir Bloody Loudmouth Darryl | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF4.mdl"
    }, 
    [115] = {
        name = "CS:GO - Bloody Darryl The Strapped | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varF5.mdl"
    }, 
    [116] = {
        name = "CS:GO - Safecracker Voltzmann | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varG.mdl"
    }, 
    [117] = {
        name = "CS:GO - Little Kev | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varH.mdl"
    }, 
    [118] = {
        name = "CS:GO - Number K | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varI.mdl"
    }, 
    [119] = {
        name = "CS:GO - Getaway Sally | The Professionals", 
        path = "models/player/custom_player/legacy/tm_professional_varJ.mdl"
    }, 
    [120] = {
        name = "CS:GO - Special Agent Ava | FBI", 
        path = "models/player/custom_player/legacy/ctm_fbi_variantB.mdl"
    }, 
    [121] = {
        name = "CS:GO - Cmdr. Davida 'Goggles' Fernandez | SEAL Frogman", 
        path = "models/player/custom_player/legacy/ctm_diver_variantA.mdl"
    }, 
    [122] = {
        name = "CS:GO - Cmdr. Frank 'Wet Sox' Baroud | SEAL Frogman", 
        path = "models/player/custom_player/legacy/ctm_diver_variantB.mdl"
    }, 
    [123] = {
        name = "CS:GO - Lieutenant Rex Krikey | SEAL Frogman", 
        path = "models/player/custom_player/legacy/ctm_diver_variantC.mdl"
    }, 
    [124] = {
        name = "CS:GO - Sous-Lieutenant Medic | Gendarmerie Nationale", 
        path = "models/player/custom_player/legacy/ctm_gendarmerie_variantA.mdl"
    }, 
    [125] = {
        name = "CS:GO - Chem-Haz Capitaine | Gendarmerie Nationale", 
        path = "models/player/custom_player/legacy/ctm_gendarmerie_variantB.mdl"
    }, 
    [126] = {
        name = "CS:GO - Chef d'Escadron Rouchard | Gendarmerie Nationale", 
        path = "models/player/custom_player/legacy/ctm_gendarmerie_variantC.mdl"
    }, 
    [127] = {
        name = "CS:GO - Aspirant | Gendarmerie Nationale", 
        path = "models/player/custom_player/legacy/ctm_gendarmerie_variantD.mdl"
    }, 
    [128] = {
        name = "CS:GO - Officer Jacques Beltram | Gendarmerie Nationale", 
        path = "models/player/custom_player/legacy/ctm_gendarmerie_variantE.mdl"
    }, 
    [129] = {
        name = "CS:GO - Elite Trapper Solman | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantA.mdl"
    }, 
    [130] = {
        name = "CS:GO - Crasswater The Forgotten | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantB.mdl"
    }, 
    [131] = {
        name = "CS:GO - 'Medium Rare' Crasswater | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantB2.mdl"
    }, 
    [132] = {
        name = "CS:GO - Arno The Overgrown | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantC.mdl"
    }, 
    [133] = {
        name = "CS:GO - Col. Mangos Dabisi | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantD.mdl"
    }, 
    [134] = {
        name = "CS:GO - Vypa Sista of the Revolution | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantE.mdl"
    }, 
    [135] = {
        name = "CS:GO - Trapper Aggressor | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantF.mdl"
    }, 
    [136] = {
        name = "CS:GO - Trapper | Guerrilla Warfare", 
        path = "models/player/custom_player/legacy/tm_jungle_raider_variantF2.mdl"
    }, 
    [137] = {
        path = "models/player/custom_player/kirby/leetkumla/leetkumla.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20-%20Jumpsuit%20(Black).zip", 
        name = "CS:GO - Jumpsuit (Black)"
    }, 
    [138] = {
        path = "models/player/custom_player/kirby/kumlafbi/kumlafbi.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20-%20FBI%20(Black).zip", 
        name = "CS:GO - FBI (Black)"
    }, 
    [139] = {
        path = "models/player/custom_player/csgo_legacy/ctm_fbi.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20FBI.zip", 
        name = "CS:GO (legacy) - FBI"
    }, 
    [140] = {
        path = "models/player/custom_player/csgo_legacy/tm_leet_varianta.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20Elite%20Crew.zip", 
        name = "CS:GO (legacy) - Elite Crew (A)"
    }, 
    [141] = {
        path = "models/player/custom_player/csgo_legacy/tm_leet_variantb.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20Elite%20Crew.zip", 
        name = "CS:GO (legacy) - Elite Crew (B)"
    }, 
    [142] = {
        path = "models/player/custom_player/csgo_legacy/tm_leet_variantc.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20Elite%20Crew.zip", 
        name = "CS:GO (legacy) - Elite Crew (C)"
    }, 
    [143] = {
        path = "models/player/custom_player/csgo_legacy/tm_leet_variantd.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20Elite%20Crew.zip", 
        name = "CS:GO (legacy) - Elite Crew (D)"
    }, 
    [144] = {
        path = "models/player/custom_player/csgo_legacy/tm_leet_variante.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSGO%20(legacy)%20-%20Elite%20Crew.zip", 
        name = "CS:GO (legacy) - Elite Crew (E)"
    }, 
    [145] = {
        path = "models/player/custom_player/eminem/css/t_arctic.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Arctic.zip", 
        name = "CS:S - Arctic"
    }, 
    [146] = {
        path = "models/player/custom_player/eminem/css/t_leet.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Elite%20Crew.zip", 
        name = "CS:S - Elite Crew"
    }, 
    [147] = {
        path = "models/player/custom_player/kirby/umbrella_leet/umbrella_leet3.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Elite%20Crew%20(Black).zip", 
        name = "CS:S - Elite Crew (Black)"
    }, 
    [148] = {
        path = "models/player/custom_player/eminem/css/t_guerilla.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Guerilla.zip", 
        name = "CS:S - Guerilla"
    }, 
    [149] = {
        path = "models/player/custom_player/eminem/css/t_phoenix.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Phoenix.zip", 
        name = "CS:S - Phoenix"
    }, 
    [150] = {
        path = "models/player/custom_player/kirby/kirbys_robber/kirbys_robber2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Phoenix%20(Black).zip", 
        name = "CS:S - Phoenix (Black)"
    }, 
    [151] = {
        path = "models/player/custom_player/eminem/css/ct_gign.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20GIGN.zip", 
        name = "CS:S - GIGN"
    }, 
    [152] = {
        path = "models/player/custom_player/eminem/css/ct_gsg9.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20GSG9.zip", 
        name = "CS:S - GSG9"
    }, 
    [153] = {
        path = "models/player/custom_player/eminem/css/ct_sas.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20SAS.zip", 
        name = "CS:S - SAS"
    }, 
    [154] = {
        path = "models/player/custom_player/eminem/css/ct_urban.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSS%20-%20Urban.zip", 
        name = "CS:S - Urban"
    }, 
    [155] = {
        path = "models/player/custom_player/kuristaja/cso2/lisa/lisa.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Lisa.zip", 
        name = "CS:O - Lisa"
    }, 
    [156] = {
        path = "models/player/custom_player/kuristaja/cso2/mila/mila.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Mila.zip", 
        name = "CS:O - Mila"
    }, 
    [157] = {
        path = "models/player/custom_player/kuristaja/cso2/karachenko/karachenko.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Karachenko.zip", 
        name = "CS:O - Karachenko"
    }, 
    [158] = {
        path = "models/player/custom_player/kuristaja/cso2/helga/helga.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Helga.zip", 
        name = "CS:O - Helga"
    }, 
    [159] = {
        path = "models/player/custom_player/kuristaja/cso2/natalie/natalie.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Natalie.zip", 
        name = "CS:O - Natalie"
    }, 
    [160] = {
        path = "models/player/custom_player/kuristaja/cso2/miyu_schoolgirl/miyu.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CSO%20-%20Miyu.zip", 
        name = "CS:O - Miyu"
    }, 
    [161] = {
        path = "models/player/custom_player/legacy/tm_arctic_varianta.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/CS%20-%20Arctic%20Avenger%20(A).zip", 
        name = "CS - Arctic Avenger (A)"
    }, 
    [162] = {
        path = "models/player/custom_player/kuristaja/tf2/sniper/sniper_bluv2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/TF2%20-%20Sniper%20(Blue).zip", 
        name = "TF2 - Sniper (Blue)"
    }, 
    [163] = {
        path = "models/player/custom_player/kuristaja/tf2/sniper/sniper_redv2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/TF2%20-%20Sniper%20(Red).zip", 
        name = "TF2 - Sniper (Red)"
    }, 
    [164] = {
        path = "models/player/custom_player/eminem/gta_sa/swmotr5.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Homeless.zip", 
        name = "GTA - Homeless"
    }, 
    [165] = {
        path = "models/player/custom_player/madebyruzh/homeless/homeless.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Homeless%20(Box).zip", 
        name = "GTA - Homeless (Box)"
    }, 
    [166] = {
        path = "models/player/custom_player/kolka/ballas/ballas.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Ballas.zip", 
        name = "GTA - Ballas"
    }, 
    [167] = {
        path = "models/player/custom_player/frnchise9812/ballas1.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Ballas%201.zip", 
        name = "GTA - Ballas 1"
    }, 
    [168] = {
        path = "models/player/custom_player/frnchise9812/ballas2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Ballas%201%20(Black).zip", 
        name = "GTA - Ballas 1 (Black)"
    }, 
    [169] = {
        path = "models/player/custom_player/caleon1/ballas1/ballas1.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Ballas%201%20(Wraith).zip", 
        name = "GTA - Ballas 1 (Wraith)"
    }, 
    [170] = {
        path = "models/player/custom_player/nf/gta/tommi.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Tommy.zip", 
        name = "GTA - Tommy"
    }, 
    [171] = {
        path = "models/player/custom_player/eminem/gta_sa/vla2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20VLA2.zip", 
        name = "GTA - VLA2"
    }, 
    [172] = {
        path = "models/player/custom_player/eminem/gta_sa/fam1.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Fam1.zip", 
        name = "GTA - Fam1"
    }, 
    [173] = {
        path = "models/player/custom_player/eminem/gta_sa/bmybar.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Bmybar.zip", 
        name = "GTA - Bmybar"
    }, 
    [174] = {
        path = "models/player/custom_player/eminem/gta_sa/somyst.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Somyst.zip", 
        name = "GTA - Somyst"
    }, 
    [175] = {
        path = "models/player/custom_player/eminem/gta_sa/vwfypro.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Vwfypro.zip", 
        name = "GTA - Vwfypro"
    }, 
    [176] = {
        path = "models/player/custom_player/z-piks.ru/gta_blood.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Bloods.zip", 
        name = "GTA - Bloods"
    }, 
    [177] = {
        path = "models/player/custom_player/z-piks.ru/gta_crip.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Crips.zip", 
        name = "GTA - Crips"
    }, 
    [178] = {
        path = "models/player/custom_player/madebyruzh/ryder/ryder.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Ryder.zip", 
        name = "GTA - Ryder"
    }, 
    [179] = {
        path = "models/player/custom_player/madebyruzh/sweet/sweet.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Sweet.zip", 
        name = "GTA - Sweet"
    }, 
    [180] = {
        path = "models/player/custom_player/frnchise9812/fam2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20Fam2.zip", 
        name = "GTA - Fam2"
    }, 
    [181] = {
        path = "models/player/custom_player/legacy/toppi/bew/gta/ogloc.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/GTA%20-%20OG%20Loc.zip", 
        name = "GTA - OG Loc"
    }, 
    [182] = {
        path = "models/player/custom_player/eminem/gta_sa/wuzimu.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Matrix%20-%20Neo.zip", 
        name = "Matrix - Neo"
    }, 
    [183] = {
        path = "models/player/custom_player/darnias/sas_william_fix.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/MW%20-%20SAS%20Assault%20William.zip", 
        name = "MW - SAS Assault William"
    }, 
    [184] = {
        path = "models/player/custom_player/kuristaja/duke/dukev3.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/DNF%20-%20Duke%20Nukem.zip", 
        name = "DNF - Duke Nukem"
    }, 
    [185] = {
        path = "models/player/custom_player/kuristaja/l4d2/ellis/ellisv2.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/L4D2%20-%20Ellis.zip", 
        name = "L4D2 - Ellis"
    }, 
    [186] = {
        path = "models/player/custom_player/night_fighter/valorant/jett/jett.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Valorant%20-%20Jett.zip", 
        name = "Valorant - Jett"
    }, 
    [187] = {
        path = "models/player/custom_player/darnias/hunk/hunk.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/RE2%20-%20Hunk.zip", 
        name = "RE2 - Hunk"
    }, 
    [188] = {
        path = "models/player/custom_player/kuristaja/re6/chris/chrisv4.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/RE6%20-%20Chris%20Redfield.zip", 
        name = "RE6 - Chris Redfield"
    }, 
    [189] = {
        path = "models/player/custom_player/legacy/ctm_mpssc_variantc.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20MPSSC.zip", 
        name = "Special Forces - MPSSC"
    }, 
    [190] = {
        path = "models/player/custom_player/legacy/ctm_ksk.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20KSK.zip", 
        name = "Special Forces - KSK"
    }, 
    [191] = {
        path = "models/player/custom_player/legacy/ctm_ksk_varianta.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20KSK.zip", 
        name = "Special Forces - KSK (A)"
    }, 
    [192] = {
        path = "models/player/custom_player/legacy/ctm_ksk_variantb.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20KSK.zip", 
        name = "Special Forces - KSK (B)"
    }, 
    [193] = {
        path = "models/player/custom_player/legacy/ctm_ksk_variantc.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20KSK.zip", 
        name = "Special Forces - KSK (C)"
    }, 
    [194] = {
        path = "models/player/custom_player/legacy/ctm_ksk_variantd.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Special%20Forces%20-%20KSK.zip", 
        name = "Special Forces - KSK (D)"
    }, 
    [195] = {
        path = "models/player/custom_player/xnet/girl/compa/compa.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Anime%20-%20Compa.zip", 
        name = "Anime - Compa"
    }, 
    [196] = {
        path = "models/player/custom_player/uuz/gothic_miku/gothic_miku.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Anime%20-%20Hatsune%20Miku%20(Gothic).zip", 
        name = "Anime - Hatsune Miku (Gothic)"
    }, 
    [197] = {
        path = "models/player/custom_player/frnchise9812/neverlosee.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Celebrity%20-%20Andrew%20Tate%20(NL).zip", 
        name = "Celebrity - Andrew Tate (NL)"
    }, 
    [198] = {
        path = "models/player/custom_player/frnchise9812/gamesensee.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Celebrity%20-%20Andrew%20Tate%20(GS).zip", 
        name = "Celebrity - Andrew Tate (GS)"
    }, 
    [199] = {
        path = "models/player/custom_player/pentaqua/quarex_fortnitemodelleri/quarex_travis_scott.mdl", 
        files = "https://gitlab.com/luascript/csgo/-/raw/main/models/agents/Celebrity%20-%20Travis%20Scott.zip", 
        name = "Celebrity - Travis Scott"
    }
};
local v17 = {
    attachment_hider = {
        T = {
            [1] = "Bomb", 
            [2] = "Grenades", 
            [3] = "Knife", 
            [4] = "Pistol", 
            [5] = "Primary Weapon", 
            [6] = "Gloves"
        }, 
        CT = {
            [1] = "Defuse Kit", 
            [2] = "Grenades", 
            [3] = "Knife", 
            [4] = "Pistol", 
            [5] = "Primary Weapon", 
            [6] = "Gloves"
        }, 
        patterns = {
            [1] = {
                [1] = "w_ied_dropped.mdl", 
                [2] = "w_defuser.mdl"
            }, 
            [2] = {
                [1] = "w_eq_fraggrenade_dropped.mdl", 
                [2] = "w_eq_smokegrenade_dropped.mdl", 
                [3] = "w_eq_flashbang_dropped.mdl", 
                [4] = "w_eq_decoy_dropped.mdl"
            }, 
            [3] = {
                [1] = "knife.*dropped"
            }, 
            [4] = {
                [1] = "pist.*dropped", 
                [2] = "elite.*dropped", 
                [3] = "w_eq_eholster", 
                [4] = "w_eq_taser"
            }, 
            [5] = {
                [1] = "snip.*dropped", 
                [2] = "rif.*dropped", 
                [3] = "smg.*dropped", 
                [4] = "shot.*dropped", 
                [5] = "mach.*dropped"
            }, 
            [6] = {
                [1] = "glove"
            }
        }
    }, 
    masks = {
        [1] = {
            name = "CS:GO - Zombie Fortune", 
            path = "models/player/holiday/facemasks/facemask_zombie_fortune_plastic.mdl"
        }, 
        [2] = {
            name = "CS:GO - Tiki", 
            path = "models/player/holiday/facemasks/facemask_tiki.mdl"
        }, 
        [3] = {
            name = "CS:GO - Skull", 
            path = "models/player/holiday/facemasks/facemask_skull.mdl"
        }, 
        [4] = {
            name = "CS:GO - Skull (Gold)", 
            path = "models/player/holiday/facemasks/facemask_skull_gold.mdl"
        }, 
        [5] = {
            name = "CS:GO - Sheep", 
            path = "models/player/holiday/facemasks/facemask_sheep_model.mdl"
        }, 
        [6] = {
            name = "CS:GO - Sheep (Bloody)", 
            path = "models/player/holiday/facemasks/facemask_sheep_bloody.mdl"
        }, 
        [7] = {
            name = "CS:GO - Sheep (Gold)", 
            path = "models/player/holiday/facemasks/facemask_sheep_gold.mdl"
        }, 
        [8] = {
            name = "CS:GO - Samurai", 
            path = "models/player/holiday/facemasks/facemask_samurai.mdl"
        }, 
        [9] = {
            name = "CS:GO - Pumpkin", 
            path = "models/player/holiday/facemasks/facemask_pumpkin.mdl"
        }, 
        [10] = {
            name = "CS:GO - Doll Kabuki (Porcelan)", 
            path = "models/player/holiday/facemasks/facemask_porcelain_doll_kabuki.mdl"
        }, 
        [11] = {
            name = "CS:GO - Devil (Plastic)", 
            path = "models/player/holiday/facemasks/facemask_devil_plastic.mdl"
        }, 
        [12] = {
            name = "CS:GO - Doll", 
            path = "models/player/holiday/facemasks/porcelain_doll.mdl"
        }, 
        [13] = {
            name = "CS:GO - Bunny", 
            path = "models/player/holiday/facemasks/facemask_bunny.mdl"
        }, 
        [14] = {
            name = "CS:GO - Bunny (Gold)", 
            path = "models/player/holiday/facemasks/facemask_bunny_gold.mdl"
        }, 
        [15] = {
            name = "CS:GO - Boar", 
            path = "models/player/holiday/facemasks/facemask_boar.mdl"
        }, 
        [16] = {
            name = "CS:GO - Battlemask", 
            path = "models/player/holiday/facemasks/facemask_battlemask.mdl"
        }, 
        [17] = {
            name = "CS:GO - 3D Glasses (Anaglyh)", 
            path = "models/player/holiday/facemasks/facemask_anaglyph.mdl"
        }, 
        [18] = {
            name = "CS:GO - Clown", 
            path = "models/player/holiday/facemasks/evil_clown.mdl"
        }, 
        [19] = {
            name = "CS:GO - Target", 
            path = "models/player/holiday/facemasks/facemask_template.mdl"
        }, 
        [20] = {
            name = "TF2 - Spy", 
            path = "models/player/holiday/facemasks/facemask_tf2_spy_model.mdl"
        }, 
        [21] = {
            name = "TF2 - Soldier", 
            path = "models/player/holiday/facemasks/facemask_tf2_soldier_model.mdl"
        }, 
        [22] = {
            name = "TF2 - Sniper", 
            path = "models/player/holiday/facemasks/facemask_tf2_sniper_model.mdl"
        }, 
        [23] = {
            name = "TF2 - Scout", 
            path = "models/player/holiday/facemasks/facemask_tf2_scout_model.mdl"
        }, 
        [24] = {
            name = "TF2 - Pyro", 
            path = "models/player/holiday/facemasks/facemask_tf2_pyro_model.mdl"
        }, 
        [25] = {
            name = "TF2 - Medic", 
            path = "models/player/holiday/facemasks/facemask_tf2_medic_model.mdl"
        }, 
        [26] = {
            name = "TF2 - Heavy", 
            path = "models/player/holiday/facemasks/facemask_tf2_heavy_model.mdl"
        }, 
        [27] = {
            name = "TF2 - Enginner", 
            path = "models/player/holiday/facemasks/facemask_tf2_engi_model.mdl"
        }, 
        [28] = {
            name = "TF2 - Demoman", 
            path = "models/player/holiday/facemasks/facemask_tf2_demo_model.mdl"
        }, 
        [29] = {
            name = "PayDay - Dallas", 
            path = "models/player/holiday/facemasks/facemask_dallas.mdl"
        }, 
        [30] = {
            name = "PayDay - Hoxton", 
            path = "models/player/holiday/facemasks/facemask_hoxton.mdl"
        }, 
        [31] = {
            name = "PayDay - Wolf", 
            path = "models/player/holiday/facemasks/facemask_wolf.mdl"
        }, 
        [32] = {
            name = "PayDay - Chains", 
            path = "models/player/holiday/facemasks/facemask_chains.mdl"
        }
    }, 
    viewmodels = {
        [1] = {
            name = "CS:GO - Anarchist", 
            path = "models/weapons/t_arms_anarchist.mdl"
        }, 
        [2] = {
            name = "CS:GO - Balkan", 
            path = "models/weapons/t_arms_balkan.mdl"
        }, 
        [3] = {
            name = "CS:GO - LEET", 
            path = "models/weapons/t_arms_leet.mdl"
        }, 
        [4] = {
            name = "CS:GO - Phoenix", 
            path = "models/weapons/t_arms_phoenix.mdl"
        }, 
        [5] = {
            name = "CS:GO - Pirate", 
            path = "models/weapons/t_arms_pirate.mdl"
        }, 
        [6] = {
            name = "CS:GO - Professional", 
            path = "models/weapons/t_arms_professional.mdl"
        }, 
        [7] = {
            name = "CS:GO - Separatist", 
            path = "models/weapons/t_arms_separatist.mdl"
        }, 
        [8] = {
            name = "CS:GO - FBI", 
            path = "models/weapons/ct_arms_fbi.mdl"
        }, 
        [9] = {
            name = "CS:GO - GIGN", 
            path = "models/weapons/ct_arms_gign.mdl"
        }, 
        [10] = {
            name = "CS:GO - GSG", 
            path = "models/weapons/ct_arms_gsg9.mdl"
        }, 
        [11] = {
            name = "CS:GO - IDF", 
            path = "models/weapons/ct_arms_idf.mdl"
        }, 
        [12] = {
            name = "CS:GO - SAS", 
            path = "models/weapons/ct_arms_sas.mdl"
        }, 
        [13] = {
            name = "CS:GO - SEALS", 
            path = "models/weapons/ct_arms_st6.mdl"
        }, 
        [14] = {
            name = "CS:GO - SWAT", 
            path = "models/weapons/ct_arms_swat.mdl"
        }
    }, 
    weapon_model_changer = {
        weapon_types = {
            [1] = "Tools", 
            [2] = "Snipers", 
            [3] = "Rifles", 
            [4] = "Heavy", 
            [5] = "SMG", 
            [6] = "Pistols"
        }, 
        game_weapon_models = {
            ["Viewmodel - Skeleton Knife"] = "models/weapons/v_knife_skeleton.mdl", 
            ["Worldmodel - Navaja Knife"] = "models/weapons/w_knife_gypsy_jackknife.mdl", 
            ["Viewmodel - Shadow Daggers"] = "models/weapons/v_knife_push.mdl", 
            ["Worldmodel - Nomad Knife"] = "models/weapons/w_knife_nomad.mdl", 
            ["Viewmodel - Paracord Knife"] = "models/weapons/v_knife_cord.mdl", 
            ["Worldmodel - Paracord Knife"] = "models/weapons/w_knife_cord.mdl", 
            ["Viewmodel - Nomad Knife"] = "models/weapons/v_knife_nomad.mdl", 
            ["Worldmodel - Shadow Daggers"] = "models/weapons/w_knife_push.mdl", 
            ["Viewmodel - Navaja Knife"] = "models/weapons/v_knife_gypsy_jackknife.mdl", 
            ["Worldmodel - Skeleton Knife"] = "models/weapons/w_knife_skeleton.mdl", 
            ["Viewmodel - M9 Bayonet"] = "models/weapons/v_knife_m9_bay.mdl", 
            ["Worldmodel - Stiletto Knife"] = "models/weapons/w_knife_stiletto.mdl", 
            ["Viewmodel - Karambit"] = "models/weapons/v_knife_karam.mdl", 
            ["Worldmodel - Survival Knife"] = "models/weapons/w_knife_outdoor.mdl", 
            ["Viewmodel - Huntsman Knife"] = "models/weapons/v_knife_tactical.mdl", 
            ["Worldmodel - Talon Kinfe"] = "models/weapons/w_knife_widowmaker.mdl", 
            ["Viewmodel - Gut Knife"] = "models/weapons/v_knife_gut.mdl", 
            ["Worldmodel - Urus"] = "models/weapons/w_knife_ursus.mdl", 
            ["Viewmodel - Flip Knife"] = "models/weapons/v_knife_flip.mdl", 
            ["Worldmodel - Gold Kinfe"] = "models/weapons/w_knife_gg.mdl", 
            ["Viewmodel - Falchion Knife"] = "models/weapons/v_knife_falchion_advanced.mdl", 
            ["Worldmodel - Ghost Knife"] = "models/weapons/w_knife_ghost.mdl", 
            ["Viewmodel - Classic Knife"] = "models/weapons/v_knife_css.mdl", 
            ["Worldmodel - Snowball"] = "models/weapons/w_eq_snowball.mdl", 
            ["Viewmodel - Butterfly Knife"] = "models/weapons/v_knife_butterfly.mdl", 
            ["Viewmodel - Bowie Knife"] = "models/weapons/v_knife_survival_bowie.mdl", 
            ["Viewmodel - Bayonet"] = "models/weapons/v_knife_bayonet.mdl", 
            ["Worldmodel - M9 Bayonet"] = "models/weapons/w_knife_m9_bay.mdl", 
            ["Worldmodel - Karambit"] = "models/weapons/w_knife_karam.mdl", 
            ["Worldmodel - Huntsman Knife"] = "models/weapons/w_knife_tactical.mdl", 
            ["Worldmodel - Gut Knife"] = "models/weapons/w_knife_gut.mdl", 
            ["Worldmodel - Flip Knife"] = "models/weapons/w_knife_flip.mdl", 
            ["Worldmodel - Falchion Knife"] = "models/weapons/w_knife_falchion_advanced.mdl", 
            ["Worldmodel - Classic Knife"] = "models/weapons/w_knife_css.mdl", 
            ["Worldmodel - Butterfly Knife"] = "models/weapons/w_knife_butterfly.mdl", 
            ["Worldmodel - Bowie Knife"] = "models/weapons/w_knife_survival_bowie.mdl", 
            ["Worldmodel - Bayonet"] = "models/weapons/w_knife_bayonet.mdl", 
            ["Viewmodel - Snowball"] = "models/weapons/v_eq_snowball.mdl", 
            ["Viewmodel - Ghost Knife"] = "models/weapons/v_knife_ghost.mdl", 
            ["Viewmodel - Gold Kinfe"] = "models/weapons/v_knife_gg.mdl", 
            ["Viewmodel - Urus"] = "models/weapons/v_knife_ursus.mdl", 
            ["Viewmodel - Talon Kinfe"] = "models/weapons/v_knife_widowmaker.mdl", 
            ["Viewmodel - Survival Knife"] = "models/weapons/v_knife_outdoor.mdl", 
            ["Viewmodel - Stiletto Knife"] = "models/weapons/v_knife_stiletto.mdl"
        }, 
        weapon_ids = {
            Tools = {
                Smoke = 45, 
                Explosive = 44, 
                Zeus = 31, 
                Knife = {
                    [1] = 42, 
                    [2] = 59, 
                    [3] = 500, 
                    [4] = 505, 
                    [5] = 506, 
                    [6] = 507, 
                    [7] = 508, 
                    [8] = 509, 
                    [9] = 512, 
                    [10] = 514, 
                    [11] = 515, 
                    [12] = 516, 
                    [13] = 519, 
                    [14] = 520, 
                    [15] = 522, 
                    [16] = 523
                }, 
                Molotov = {
                    [1] = 46, 
                    [2] = 48
                }
            }, 
            Pistols = {
                ["Glock-18"] = 4, 
                ["Tec-9"] = 30, 
                ["CZ75-Auto"] = 63, 
                USP = 61, 
                P250 = 36, 
                P2000 = 32, 
                ["Dual Berettas"] = 2, 
                Revolver = 64, 
                ["Five-Seven"] = 3, 
                Deagle = 1
            }, 
            Snipers = {
                G3SG1 = 11, 
                AWP = 9, 
                ["SSG-08"] = 40, 
                ["Scar-20"] = 38
            }, 
            Heavy = {
                Nova = 35, 
                XM1014 = 25, 
                ["Sawed-Off"] = 29, 
                ["MAG-7"] = 27, 
                Negev = 28, 
                M249 = 14
            }, 
            SMG = {
                P90 = 19, 
                MP9 = 34, 
                MP7 = 33, 
                MP5 = 23, 
                ["PP-Bizon"] = 26, 
                ["UMP-45"] = 24, 
                ["MAC-10"] = 17
            }, 
            Rifles = {
                ["SG 553"] = 39, 
                AUG = 8, 
                Galil = 13, 
                Famas = 10, 
                M4A4 = 16, 
                ["AK-47"] = 7
            }
        }, 
        weapon_sequence_overrides = {
            ["models/weapons/v_knife_butterfly.mdl"] = {
                [1] = {
                    sequence = 3, 
                    activity = 185, 
                    fixed_sequence = 2
                }
            }, 
            ["models/weapons/v_knife_css.mdl"] = {
                [1] = {
                    sequence = 13, 
                    activity = -1, 
                    fixed_sequence = 12
                }
            }, 
            ["models/weapons/v_sniperrifle.mdl"] = {
                [1] = {
                    sequence = 4, 
                    activity = -1, 
                    fixed_sequence = 3
                }
            }, 
            ["models/weapons/v_reaversheriff.mdl"] = {
                [1] = {
                    sequence = 1, 
                    activity = 213, 
                    fixed_sequence = 2
                }
            }, 
            ["models/weapons/v_eq_flintlock.mdl"] = {
                [1] = {
                    sequence = 1, 
                    activity = 185, 
                    fixed_sequence = 0
                }
            }, 
            ["models/weapons/eminem/gold_fararm_atf_12/v_gold_fararm_atf_12.mdl"] = {
                [1] = {
                    sequence = 0, 
                    activity = 185, 
                    fixed_cycle = 0, 
                    fixed_sequence = 0
                }
            }, 
            ["models/weapons/counter-strike-source/deagle/v_pist_deagle.mdl"] = {
                [1] = {
                    sequence = 2, 
                    activity = 213, 
                    fixed_sequence = 0
                }
            }, 
            ["models/newvision/awp_infernaldragon/v_snip_awp.mdl"] = {
                [1] = {
                    sequence = 0, 
                    activity = 185, 
                    fixed_cycle = 0, 
                    fixed_sequence = 0
                }
            }, 
            ["models/newvision/crossfire_trg21_aries/v_snip_ssg08.mdl"] = {
                [1] = {
                    sequence = 0, 
                    activity = 185, 
                    fixed_cycle = 1, 
                    fixed_sequence = 0
                }
            }
        }
    }
};
local v18 = {
    cached_viewmodel = "unset", 
    changed_ragdoll_convar = false, 
    game_dir = common.get_game_directory(), 
    cached_agent_lists = {
        T = {
            presets = {}, 
            custom = v4.custom_list.T
        }, 
        CT = {
            presets = {}, 
            custom = v4.custom_list.CT
        }
    }, 
    ref_self_viewmodel = ui.find("Visuals", "Players", "Self", "Chams", "Viewmodel"), 
    ref_self_viewmodel_color = ui.find("Visuals", "Players", "Self", "Chams", "Viewmodel", "Color")
};
local v22 = setmetatable({}, {
    __index = function(v19, v20)
        local v21 = ui.get_icon(v20);
        rawset(v19, v20, v21);
        return v21;
    end
});
local v23 = {
    warning_red = "\aB33A3AFF", 
    red = "\aDC6464FF", 
    default = "\aDEFAULT", 
    green = "\a69B83FFF", 
    primary = "\a" .. ui.get_style("Link Active"):to_hex(), 
    inactive = "\a" .. ui.get_style("Small Text"):to_hex(), 
    disabled = "\a" .. ui.get_style("Disabled Text"):to_hex()
};
local v24 = {
    home = {}, 
    agent = {}, 
    extras = {}
};
v24.home.group_a = {
    ui.create(v22["house-user"] .. v23.default .. "  Home", "\n", 1)
};
v24.home.group_a.user_info = v24.home.group_a[1]:label("Welcome back, ...");
v24.home.group_a.lua_version = v24.home.group_a[1]:label("");
v24.home.group_a.lua_link = v24.home.group_a[1]:button("   " .. v22["rectangle-history"] .. "   ", function()
    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=F4k5VZ");
end, false):tooltip("\226\139\133 See the scripts changelog");
v24.home.group_b = {
    ui.create(v22["house-user"] .. v23.default .. "  Home", "\n\n", 1)
};
v24.home.group_b.discord_label = v24.home.group_b[1]:label("Discord - Community");
v24.home.group_b.discord_invite_button = v24.home.group_b[1]:button("join server", function()
    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/h4Ake82T");
end, true);
v24.home.group_c = {
    ui.create(v22["house-user"] .. v23.default .. "  Home", "\n\n\n", 1)
};
v24.home.group_c.tip = v24.home.group_c[1]:label(v22["lightbulb-on"] .. "   Tip: Unset NL skinchanger for the models you change"):disabled(true);
v24.agent.T = {
    ui.create(v22["user-gear"] .. v23.default .. "  Agent", "Terrorist", 1)
};
v24.agent.T.element_selector = v24.agent.T[1]:list("", {
    [1] = v22.cloud .. v23.default .. "   Presets", 
    [2] = v22.folders .. v23.default .. "   Custom List"
});
v24.agent.T.search_input = v24.agent.T[1]:input("Search:", ""):tooltip("\226\139\133 Search for any model in the list below");
v24.agent.T.preset_agents = v24.agent.T[1]:list("", {
    [1] = "                     fetching data . . ."
});
v24.agent.T.custom_agents = v24.agent.T[1]:list("", {
    [1] = "                          empty list"
});
v24.agent.T.applied_agent_path = v24.agent.T[1]:input("", "unset"):visibility(false);
v24.agent.T.applied_agent_name = v24.agent.T[1]:input("", "unset"):visibility(false);
v24.agent.T.remove_button = v24.agent.T[1]:button(" - ", nil, true):tooltip("\226\139\133 Remove selected path");
v24.agent.T.add_button = v24.agent.T[1]:button(" + ", nil, true):tooltip("\226\139\133 Add path from clipboard");
v24.agent.T.apply_button = v24.agent.T[1]:button("  Apply Model  ", nil, false);
v24.agent.T.reset_button = v24.agent.T[1]:button(" " .. v23.red .. v22.rotate .. v23.default .. "  Reset ", nil, true);
v24.agent.CT = {
    ui.create(v22["user-gear"] .. v23.default .. "  Agent", "Counter-Terrorist", 2)
};
v24.agent.CT.element_selector = v24.agent.CT[1]:list("", {
    [1] = v22.cloud .. v23.default .. "   Presets ", 
    [2] = v22.folders .. v23.default .. "   Custom List "
});
v24.agent.CT.search_input = v24.agent.CT[1]:input("Search:", ""):tooltip("\226\139\133 Search for any model in the list below");
v24.agent.CT.preset_agents = v24.agent.CT[1]:list("", {
    [1] = "                     fetching data . . ."
});
v24.agent.CT.custom_agents = v24.agent.CT[1]:list("", {
    [1] = "                          empty list"
});
v24.agent.CT.applied_agent_path = v24.agent.CT[1]:input("", "unset"):visibility(false);
v24.agent.CT.applied_agent_name = v24.agent.CT[1]:input("", "unset"):visibility(false);
v24.agent.CT.remove_button = v24.agent.CT[1]:button(" - ", nil, true):tooltip("\226\139\133 Remove selected path");
v24.agent.CT.add_button = v24.agent.CT[1]:button(" + ", nil, true):tooltip("\226\139\133 Add path from clipboard");
v24.agent.CT.apply_button = v24.agent.CT[1]:button("  Apply Model  ", nil, false);
v24.agent.CT.reset_button = v24.agent.CT[1]:button(" " .. v23.red .. v22.rotate .. v23.default .. "  Reset ", nil, true);
v24.extras.T = {
    ui.create(v22["rectangle-history-circle-plus"] .. v23.default .. "  Extras", "Terrorist", 1)
};
v24.extras.T.element_selector = v24.extras.T[1]:list("", v22["link-simple-slash"] .. v23.default .. "    Attachment Hider", v22["masks-theater"] .. v23.default .. "    Mask Changer", v22.hands .. v23.default .. "     Viewmodel Changer", "" .. (v3 and v22.gun .. v23.default .. "    Weapon Model Changer" or v22["lock-keyhole"] .. v23.default .. "      Weapon Model Changer"));
v24.extras.T.attachment_hider = v24.extras.T[1]:listable("", v17.attachment_hider.T);
v24.extras.T.mask_combo = v24.extras.T[1]:combo("", "Disabled", "Presets", "Custom");
v24.extras.T.mask_presets = v24.extras.T[1]:list("", {});
v24.extras.T.mask_custom_path = v24.extras.T[1]:input("Path:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl mask file");
v24.extras.T.view_combo = v24.extras.T[1]:combo("", "Disabled", "Presets", "Custom");
v24.extras.T.view_presets = v24.extras.T[1]:list("", {});
v24.extras.T.view_custom_path = v24.extras.T[1]:input("Path:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl viewmodel file");
v24.extras.T.weap_unlocker_text = v24.extras.T[1]:label("Click to unlock"):disabled(true);
v24.extras.T.weap_unlocker = v24.extras.T[1]:button("    " .. v22.key .. "    ", nil, false):set_callback(function()
    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://en.neverlose.cc/market/item?id=EfI5Wc");
end):tooltip("\226\139\133 market.neverlose.cc/EfI5Wc"):visibility(not v3);
v24.extras.T.weap_selector = v24.extras.T[1]:slider("", 1, 6, 2, 1, function(v25)
    -- upvalues: v17 (ref)
    return v17.weapon_model_changer.weapon_types[v25];
end):visibility(false);
v24.extras.T.weap_Tools_Knife = v24.extras.T[1]:input("Knife:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl knife file"):visibility(false);
v24.extras.T.weap_Tools_Explosive = v24.extras.T[1]:input("Explosive:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.T.weap_Tools_Smoke = v24.extras.T[1]:input("Smoke:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.T.weap_Tools_Molotov = v24.extras.T[1]:input("Molotov:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.T.weap_Tools_Zeus = v24.extras.T[1]:input("Zeus:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl zeus file"):visibility(false);
v24.extras.T.weap_Snipers_AWP = v24.extras.T[1]:input("AWP:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Snipers_G3SG1 = v24.extras.T[1]:input("G3SG1:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Snipers_Scar-20"] = v24.extras.T[1]:input("Scar-20:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Snipers_SSG-08"] = v24.extras.T[1]:input("SSG-08:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Rifles_M4A4 = v24.extras.T[1]:input("M4A4:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Rifles_Famas = v24.extras.T[1]:input("Famas:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Rifles_Galil = v24.extras.T[1]:input("Galil:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Rifles_AUG = v24.extras.T[1]:input("AUG:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Rifles_SG 553"] = v24.extras.T[1]:input("SG 553:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Rifles_AK-47"] = v24.extras.T[1]:input("AK-47:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Heavy_XM1014 = v24.extras.T[1]:input("XM1014:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Heavy_Nova = v24.extras.T[1]:input("Nova:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Heavy_M249 = v24.extras.T[1]:input("M249:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Heavy_Negev = v24.extras.T[1]:input("Negev:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Heavy_MAG-7"] = v24.extras.T[1]:input("MAG-7:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Heavy_Sawed-Off"] = v24.extras.T[1]:input("Sawed-Off:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_SMG_MP5 = v24.extras.T[1]:input("MP5:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_SMG_MP7 = v24.extras.T[1]:input("MP7:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_SMG_MP9 = v24.extras.T[1]:input("MP9:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_SMG_P90 = v24.extras.T[1]:input("P90:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_SMG_MAC-10"] = v24.extras.T[1]:input("MAC-10:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_SMG_UMP-45"] = v24.extras.T[1]:input("UMP-45:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_SMG_PP-Bizon"] = v24.extras.T[1]:input("PP-Bizon:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Pistols_Deagle = v24.extras.T[1]:input("Deagle:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Pistols_Five-Seven"] = v24.extras.T[1]:input("Five Seven:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Pistols_Revolver = v24.extras.T[1]:input("Revolver:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Pistols_Dual Berettas"] = v24.extras.T[1]:input("Dual Berettas:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Pistols_P2000 = v24.extras.T[1]:input("P2000:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Pistols_P250 = v24.extras.T[1]:input("P250:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T.weap_Pistols_USP = v24.extras.T[1]:input("USP:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Pistols_CZ75-Auto"] = v24.extras.T[1]:input("CZ75-Auto:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Pistols_Tec-9"] = v24.extras.T[1]:input("Tec-9:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.T["weap_Pistols_Glock-18"] = v24.extras.T[1]:input("Glock-18:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT = {
    ui.create(v22["rectangle-history-circle-plus"] .. v23.default .. "  Extras", "Counter-Terrorist", 2)
};
v24.extras.CT.element_selector = v24.extras.CT[1]:list("", v22["link-simple-slash"] .. v23.default .. "    Attachment Hider ", v22["masks-theater"] .. v23.default .. "    Mask Changer ", v22.hands .. v23.default .. "     Viewmodel Changer ", "" .. (v3 and v22.gun .. v23.default .. "    Weapon Model Changer " or v22["lock-keyhole"] .. v23.default .. "      Weapon Model Changer "));
v24.extras.CT.attachment_hider = v24.extras.CT[1]:listable("", v17.attachment_hider.CT);
v24.extras.CT.mask_combo = v24.extras.CT[1]:combo("", "Disabled", "Presets", "Custom");
v24.extras.CT.mask_presets = v24.extras.CT[1]:list("", {});
v24.extras.CT.mask_custom_path = v24.extras.CT[1]:input("Path:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl mask file");
v24.extras.CT.view_combo = v24.extras.CT[1]:combo("", "Disabled", "Presets", "Custom");
v24.extras.CT.view_presets = v24.extras.CT[1]:list("", {});
v24.extras.CT.view_custom_path = v24.extras.CT[1]:input("Path:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl viewmodel file");
v24.extras.CT.weap_unlocker_text = v24.extras.CT[1]:label("Click to unlock"):disabled(true);
v24.extras.CT.weap_unlocker = v24.extras.CT[1]:button("    " .. v22.key .. "    ", nil, false):set_callback(function()
    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://en.neverlose.cc/market/item?id=EfI5Wc");
end):tooltip("\226\139\133 market.neverlose.cc/EfI5Wc"):visibility(not v3);
v24.extras.CT.weap_selector = v24.extras.CT[1]:slider("", 1, 6, 2, 1, function(v26)
    -- upvalues: v17 (ref)
    return v17.weapon_model_changer.weapon_types[v26];
end):visibility(false);
v24.extras.CT.weap_Tools_Knife = v24.extras.CT[1]:input("Knife:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl knife file"):visibility(false);
v24.extras.CT.weap_Tools_Explosive = v24.extras.CT[1]:input("Explosive:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.CT.weap_Tools_Smoke = v24.extras.CT[1]:input("Smoke:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.CT.weap_Tools_Molotov = v24.extras.CT[1]:input("Molotov:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl grenade file"):visibility(false);
v24.extras.CT.weap_Tools_Zeus = v24.extras.CT[1]:input("Zeus:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl zeus file"):visibility(false);
v24.extras.CT.weap_Snipers_AWP = v24.extras.CT[1]:input("AWP:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Snipers_G3SG1 = v24.extras.CT[1]:input("G3SG1:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Snipers_Scar-20"] = v24.extras.CT[1]:input("Scar-20:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Snipers_SSG-08"] = v24.extras.CT[1]:input("SSG-08:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Rifles_M4A4 = v24.extras.CT[1]:input("M4A4:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Rifles_Famas = v24.extras.CT[1]:input("Famas:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Rifles_Galil = v24.extras.CT[1]:input("Galil:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Rifles_AUG = v24.extras.CT[1]:input("AUG:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Rifles_SG 553"] = v24.extras.CT[1]:input("SG 553:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Rifles_AK-47"] = v24.extras.CT[1]:input("AK-47:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Heavy_XM1014 = v24.extras.CT[1]:input("XM1014:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Heavy_Nova = v24.extras.CT[1]:input("Nova:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Heavy_M249 = v24.extras.CT[1]:input("M249:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Heavy_Negev = v24.extras.CT[1]:input("Negev:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Heavy_MAG-7"] = v24.extras.CT[1]:input("MAG-7:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Heavy_Sawed-Off"] = v24.extras.CT[1]:input("Sawed-Off:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_SMG_MP5 = v24.extras.CT[1]:input("MP5:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_SMG_MP7 = v24.extras.CT[1]:input("MP7:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_SMG_MP9 = v24.extras.CT[1]:input("MP9:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_SMG_P90 = v24.extras.CT[1]:input("P90:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_SMG_MAC-10"] = v24.extras.CT[1]:input("MAC-10:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_SMG_UMP-45"] = v24.extras.CT[1]:input("UMP-45:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_SMG_PP-Bizon"] = v24.extras.CT[1]:input("PP-Bizon:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Pistols_Deagle = v24.extras.CT[1]:input("Deagle:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Pistols_Five-Seven"] = v24.extras.CT[1]:input("Five Seven:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Pistols_Revolver = v24.extras.CT[1]:input("Revolver:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Pistols_Dual Berettas"] = v24.extras.CT[1]:input("Dual Berettas:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Pistols_P2000 = v24.extras.CT[1]:input("P2000:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Pistols_P250 = v24.extras.CT[1]:input("P250:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT.weap_Pistols_USP = v24.extras.CT[1]:input("USP:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Pistols_CZ75-Auto"] = v24.extras.CT[1]:input("CZ75-Auto:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Pistols_Tec-9"] = v24.extras.CT[1]:input("Tec-9:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
v24.extras.CT["weap_Pistols_Glock-18"] = v24.extras.CT[1]:input("Glock-18:", "models/..."):tooltip("\226\139\133 Insert the path of the .mdl weapon file"):visibility(false);
local function v28(v27)
    return v27:match("^%s*(.-)%s*$");
end;
local function v31(v29)
    local v30 = v29:find("\000");
    if v30 then
        return v29:sub(1, v30 - 1);
    else
        return v29;
    end;
end;
local function v33(v32)
    return (string.lower(v32):gsub("^%s+", ""):gsub(":", ""):gsub("%- ?", ""):gsub("([^%w])", "%%%1"));
end;
transform_slashes = function(v34)
    return v34:gsub("[\\]+", "/");
end;
local function v36(v35)
    if v35 == "models/weapons/counter-strike-source/knife/v_knife_default_t.mdl" then
        v35 = "models/weapons/w_knife_css.mdl";
    end;
    return v35.gsub(v35, "v_", "w_");
end;
local function v38(v39)
    for _, v42 in ipairs(v39) do
        table.insert(v40, v42.name);
    end;
    return v40;
end;
local function v45(v44)
    -- upvalues: v0 (ref), v18 (ref)
    if not v0 or not v0.exists then return end
    if not v0.exists(v18.game_dir .. "/" .. v44.path) then
        v0.download(v44.files, v18.game_dir .. "/temp.zip");
        v0.extract(v18.game_dir .. "/temp.zip", v18.game_dir);
        v0.delete(v18.game_dir .. "/temp.zip");
    end;
end;
local function v64(v46, v47, v48)
    local l_r_0 = v46.r;
    local l_g_0 = v46.g;
    local l_b_0 = v46.b;
    local l_a_0 = v46.a;
    local l_r_1 = v47.r;
    local l_g_1 = v47.g;
    local l_b_1 = v47.b;
    local l_a_1 = v47.a;
    local v57 = "";
    local v58 = #v48 - 1;
    local v59 = (l_r_1 - l_r_0) / v58;
    local v60 = (l_g_1 - l_g_0) / v58;
    local v61 = (l_b_1 - l_b_0) / v58;
    local v62 = (l_a_1 - l_a_0) / v58;
    for v63 = 1, v58 + 1 do
        v57 = v57 .. ("\a%02x%02x%02x%02x%s"):format(l_r_0, l_g_0, l_b_0, l_a_0, v48:sub(v63, v63));
        l_r_0 = l_r_0 + v59;
        l_g_0 = l_g_0 + v60;
        l_b_0 = l_b_0 + v61;
        l_a_0 = l_a_0 + v62;
    end;
    return v57;
end;
local function v66()
    local v65 = entity.get_local_player();
    if not v65 then
        return;
    else
        return v65:is_alive(), v65.m_iTeamNum == 1 and "Spectator" or v65.m_iTeamNum == 2 and "T" or v65.m_iTeamNum == 3 and "CT", v65;
    end;
end;
local function v76(v67, v68, v69, v70, v71)
    if not v67:visibility() then
        return;
    else
        local v72 = v67:list();
        local v73 = v68 .. v69 .. v70;
        for v74, v75 in pairs(v72) do
            if v71 and (not (v75 ~= v71) or not (v75:sub(#v73 + 1) ~= v71)) or v71 == nil and v74 == v67:get() then
                if v75:find(v69) then
                    v72[v74] = v68 .. v72[v74]:sub(#v68 + 1);
                else
                    v72[v74] = v73 .. v75;
                end;
            elseif v75:find(v73) then
                v72[v74] = v75:sub(#v73 + 1);
            end;
        end;
        v67:update(v72);
        return;
    end;
end;
local function v84(v77, v78)
    -- upvalues: v23 (ref)
    if not v77:visibility() then
        return;
    else
        local v79 = v77:list();
        local v80 = v78 or v79[v77:get()];
        for v81, v82 in pairs(v79) do
            local v83 = v82:gsub("\a%x+", "");
            if v82 == v80 then
                v79[v81] = v23.primary .. v83;
            else
                v79[v81] = v23.inactive .. v83;
            end;
            v79[v81] = v79[v81]:gsub("ULT", v23.default .. "");
        end;
        v77:update(v79);
        return;
    end;
end;
local function v85(v86, v87)
    -- upvalues: v85 (ref)
    for v88, v89 in pairs(v86) do
        if type(v89) == "string" then
            if v89 == v87 then
                return true;
            end;
        elseif type(v89) == "table" and v85(v89, v87) then
            return true;
        end;
        if type(v88) == "string" then
            if v88 == v87 then
                return true;
            end;
        elseif type(v88) == "table" and v85(v88, v87) then
            return true;
        end;
    end;
    return false;
end;
local function v92(v90, v91)
    -- upvalues: v18 (ref), v0 (ref), v85 (ref), v17 (ref)
    if type(v90) == "string" and string.find(v90, "%.mdl") then
        v90 = transform_slashes(v90);
        if files.read(v18.game_dir .. "/" .. v90) or (v0 and v0.exists and v0.exists(v18.game_dir .. "/" .. v90)) then
            return true;
        end;
    end;
    if v91 == "mask" then
        if v85(v17.masks, v90) then
            return true;
        end;
    elseif v91 == "viewmodel" then
        if v85(v17.viewmodels, v90) then
            return true;
        end;
    elseif v91 == "weapon" and v85(v17.weapon_model_changer.game_weapon_models, v90) then
        return true;
    end;
    return false;
end;
local function v101(v93, v94)
    -- upvalues: v33 (ref), v18 (ref), v24 (ref)
    local v95 = v33(v93);
    local v96 = {
        presets = {}, 
        customs = {}
    };
    for _, v98 in pairs(v18.cached_agent_lists[v94].presets) do
        if string.lower(v98):gsub(":", ""):gsub(" %- ", " "):find(v95) then
            table.insert(v96.presets, v98);
        end;
    end;
    if #v96.presets == 0 then
        table.insert(v96.presets, "                    no models found");
    end;
    v24.agent[v94].preset_agents:update(v96.presets);
    v24.agent[v94].preset_agents:disabled(v96.presets[1] == "                    no models found");
    for _, v100 in pairs(v18.cached_agent_lists[v94].custom) do
        if string.lower(v100.name):gsub(":", ""):find(v95) then
            table.insert(v96.customs, v100.name);
        end;
    end;
    if #v96.customs == 0 then
        if #v95 > 0 then
            table.insert(v96.customs, "                    no models found");
        else
            table.insert(v96.customs, "                          empty list");
        end;
    end;
    v24.agent[v94].custom_agents:update(v96.customs);
end;
local function v125()
    -- upvalues: v64 (ref), v23 (ref), v24 (ref), v22 (ref), v38 (ref), v84 (ref), v76 (ref), v33 (ref), v92 (ref), v3 (ref), v17 (ref)
    if ui.get_alpha() > 0 then
        local v102 = ui.get_style("Link Active");
        local v103 = ui.get_style("Sidebar Text");
        local v104 = ui.get_style("Disabled Text");
        local v105 = ui.get_style("Small Text");
        ui.sidebar(v64(v102, v103, "Model Changer"), "user-pen");
        v23.primary = "\a" .. v102:to_hex();
        v23.disabled = "\a" .. v104:to_hex();
        v23.inactive = "\a" .. v105:to_hex();
        v24.home.group_a[1]:parent():name(v23.primary .. v22["house-user"] .. v23.default .. "  Home");
        v24.home.group_a.user_info:name(v23.primary .. v22.user .. v23.default .. "    Welcome back, " .. v23.primary .. common.get_username());
        v24.home.group_a.lua_version:name(v23.primary .. v22["code-branch"] .. v23.default .. "    " .. "3.3.1" .. "  \226\128\148  " .. v23.primary .. "Release");
        v24.home.group_b.discord_label:name(v23.primary .. v22.discord .. v23.default .. "    Community                                                         ");
        v24.home.group_b.discord_invite_button:name("     " .. v23.primary .. v22["right-to-bracket"] .. v23.default .. "  Join server     ");
        v24.home.group_c.tip:name(v23.primary .. v22["lightbulb-on"] .. v23.default .. "   Tip: unset Neverlose skinchanger for the models you change");
        v24.agent.T[1]:parent():name(v23.primary .. v22["user-gear"] .. v23.default .. "  Agent");
        v24.agent.T[1]:name(v23.primary .. v22["user-ninja"] .. v23.default .. "  Terrorist");
        v24.agent.CT[1]:name(v23.primary .. v22["user-shield"] .. v23.default .. "  Counter-Terrorist");
        for _, v107 in pairs(v24.agent) do
            local v108 = v107.element_selector:get() == 1;
            local v109 = v108 and v107.preset_agents or v107.custom_agents;
            local v110 = v108 and v107.applied_agent_name:get() or v38(v107.applied_agent_name:get());
            local v111 = v107.preset_agents:list()[v107.preset_agents:get()];
            local v112 = v107.custom_agents:list()[v107.custom_agents:get()];
            local v113 = v108 and v111 or v112;
            local v114 = v113 == "                          empty list" or v113 == "                    no models found";
            local v115 = v113 == v107.applied_agent_name:get() or v113 and v113:sub(24) == v107.applied_agent_name:get();
            v84(v107.element_selector);
            v76(v109, v23.primary, v22["circle-check"], v23.default .. "   ", v110);
            v107.search_input:name(v23.primary .. v22["filter-list"] .. v23.default .. "  Search:");
            v107.remove_button:name(" " .. v23.primary .. v22["file-slash"] .. " ");
            v107.add_button:name(" " .. v23.primary .. v22["file-circle-plus"] .. " ");
            if v33(v107.search_input:get()) == "" or v114 then
                v107.preset_agents:name("");
                v107.custom_agents:name("");
            else
                v107.preset_agents:name(v23.disabled .. "\226\128\162" .. "  found " .. v23.primary .. #v107.preset_agents:list() .. v23.disabled .. (#v107.preset_agents:list() == 1 and " model" or " models"));
                v107.custom_agents:name(v23.disabled .. "\226\128\162" .. "  found " .. v23.primary .. #v107.custom_agents:list() .. v23.disabled .. (#v107.custom_agents:list() == 1 and " model" or " models"));
            end;
            v107.preset_agents:visibility(v108);
            v107.custom_agents:visibility(not v108);
            v107.custom_agents:disabled(v114);
            v107.remove_button:disabled(v108 or v115 or v114);
            v107.add_button:disabled(v108);
            v107.reset_button:disabled(v107.applied_agent_name:get() == "unset");
            v107.apply_button:disabled(v115 or v114);
        end;
        v24.extras.T[1]:parent():name(v23.primary .. v22["rectangle-history-circle-plus"] .. v23.default .. "  Extras");
        v24.extras.T[1]:name(v23.primary .. v22["user-ninja"] .. v23.default .. "  Terrorist");
        v24.extras.CT[1]:name(v23.primary .. v22["user-shield"] .. v23.default .. "  Counter-Terrorist");
        for _, v117 in pairs(v24.extras) do
            local v118 = v117.element_selector:get();
            v84(v117.element_selector);
            v117.attachment_hider:visibility(v118 == 1);
            v76(v117.mask_presets, v23.primary, v22["circle-check"], v23.default .. "   ");
            v117.mask_custom_path:name((v92(v117.mask_custom_path:get(), "mask") and v23.green .. v22["file-circle-check"] or v23.red .. v22["file-circle-xmark"]) .. v23.default .. "  Path:");
            v117.mask_combo:visibility(v118 == 2);
            v117.mask_presets:visibility(v118 == 2 and v117.mask_combo:get() == "Presets");
            v117.mask_custom_path:visibility(v118 == 2 and v117.mask_combo:get() == "Custom");
            v76(v117.view_presets, v23.primary, v22["circle-check"], v23.default .. "   ");
            v117.view_custom_path:name((v92(v117.view_custom_path:get(), "viewmodel") and v23.green .. v22["file-circle-check"] or v23.red .. v22["file-circle-xmark"]) .. v23.default .. "  Path:");
            v117.view_combo:visibility(v118 == 3);
            v117.view_presets:visibility(v118 == 3 and v117.view_combo:get() == "Presets");
            v117.view_custom_path:visibility(v118 == 3 and v117.view_combo:get() == "Custom");
            if v3 then
                v117.weap_selector:visibility(v118 == 4);
                for v119, v120 in pairs(v117) do
                    if type(v119) == "string" and v119:find("weap_") and v119:find("selector") == nil then
                        local v121 = v17.weapon_model_changer.weapon_types[v117.weap_selector:get()];
                        v120:visibility(v118 == 4 and (v119:find(v121) and true or false));
                        if v120:visibility() then
                            local _, _, v124 = v119:find("^[^_]+_[^_]+_(.*)");
                            v120:name((v92(v120:get(), "weapon") and v23.green .. v22["file-circle-check"] or v23.red .. v22["file-circle-xmark"]) .. v23.default .. "  " .. v124 .. ":");
                        end;
                    end;
                end;
            else
                v117.weap_unlocker:visibility(v118 == 4);
                v117.weap_unlocker_text:visibility(v118 == 4);
                v117.weap_unlocker_text:name(v23.primary .. v22["arrow-up-right-from-square"] .. v23.default .. "  Click to unlock");
            end;
        end;
    end;
end;
local function v130(v126, v127)
    -- upvalues: v11 (ref), v12 (ref), v13 (ref)
    if not v126 then
        return;
    else
        local v128 = v11(v126.m_nModelIndex);
        if not v128 then
            return;
        else
            local v129 = v12(v128);
            if not v129 then
                return;
            else
                return v13(v126[0], v129, v127);
            end;
        end;
    end;
end;
local function v133(v131)
    -- upvalues: v5 (ref), v6 (ref), v7 (ref)
    local v132 = ffi.cast("void***", v5("modelprecache"));
    if v132 then
        v6(v131);
        if v7(v132, false, v131, -1, nil) then
            return true;
        end;
    end;
    return false;
end;
local function v137(v134)
    -- upvalues: v133 (ref), v8 (ref)
    if not v134 then
        return;
    elseif v134:len() < 10 then
        return;
    else
        local v135 = entity.get_local_player();
        if not v135 then
            return;
        elseif not v133(v134) then
            return;
        else
            local v136 = v8(v134);
            if v136 ~= -1 and v135.m_nModelIndex ~= v136 then
                v135.m_nModelIndex = v136;
            end;
            return;
        end;
    end;
end;
local function v146(v138)
    -- upvalues: v133 (ref), v8 (ref), v10 (ref), v9 (ref)
    if not v138 then
        return;
    else
        local v139 = entity.get_local_player();
        if not v139 then
            return;
        elseif not v133(v138) then
            return;
        else
            local v140 = v8(v138);
            local v141 = ffi.cast("intptr_t*", v139[0]);
            local v142 = ffi.cast("intptr_t*", v141 + 17967)[0];
            while v142 ~= -1 do
                local v143 = ffi.cast("intptr_t*", v141 + 17964)[0] + 24 * v142;
                v142 = ffi.cast("intptr_t*", v143 + 20)[0];
                local v144 = ffi.cast("intptr_t**", v143)[0];
                if ffi.cast("intptr_t*", v143 + 4)[0] == 16 and v140 ~= -1 then
                    local v145 = v10(v144);
                    v9(v145, v140);
                end;
            end;
            if bit.band(v139.m_iAddonBits, 65536) ~= 65536 then
                v139.m_iAddonBits = v139.m_iAddonBits + 65536;
            end;
            return;
        end;
    end;
end;
local function v151(v147)
    -- upvalues: v133 (ref), v66 (ref), v18 (ref)
    if not v147 then
        return;
    elseif v147:len() < 10 then
        return;
    elseif not v133(v147) then
        return;
    else
        local v148, _, v150 = v66();
        if v148 then
            v18.ref_self_viewmodel:override(true);
            v18.ref_self_viewmodel_color:override(color(0, 0, 0, 0));
            if v150.m_szArmsModel ~= v147 then
                v150.m_szArmsModel = v147;
            end;
        end;
        if v18.cached_viewmodel ~= v147 then
            common.force_full_update();
            v18.cached_viewmodel = v147;
        end;
        return;
    end;
end;
local function v171(v152)
    -- upvalues: v36 (ref), v92 (ref), v133 (ref), v8 (ref), v130 (ref), v9 (ref), v14 (ref), v17 (ref), v15 (ref)
    if not v152 then
        return;
    elseif v152:len() < 10 then
        return;
    else
        local v153 = transform_slashes(v152);
        local v154 = v36(v153);
        if not common.is_in_thirdperson() then
            if v92(v153, "weapon") and v133(v153) then
                local v155 = v8(v153);
                if v155 ~= -1 then
                    local v156 = entity.get_local_player().m_hViewModel[0];
                    if v156 then
                        local l_m_nSequence_0 = v156.m_nSequence;
                        local l_m_flCycle_0 = v156.m_flCycle;
                        local v159 = v130(v156, l_m_nSequence_0);
                        if v156.m_nModelIndex ~= v155 then
                            v9(v156[0], v155);
                            v14(v156[0]);
                            entity.get_local_player().m_hViewModel[0].m_hWeapon.m_iItemIDHigh = -1;
                        end;
                        local v160 = 1;
                        local v161 = 0;
                        for v162 = 0, 20 do
                            local v163 = v130(v156, v162);
                            if v159 ~= -1 and v159 == v163 or v159 == -1 and v163 == 213 then
                                v160 = v162;
                                for v164 = 0, 3 do
                                    if v130(v156, v162 + v164) == v163 then
                                        v161 = v161 + 1;
                                    end;
                                end;
                                break;
                            end;
                        end;
                        if v159 == -1 and v160 == 1 then
                            v160 = l_m_nSequence_0;
                        end;
                        if v161 == 0 then
                            l_m_nSequence_0 = v160;
                        else
                            l_m_nSequence_0 = math.max(v160, v160 + v161 - 1);
                        end;
                        if v159 == 213 then
                            l_m_nSequence_0 = 2;
                        end;
                        for v165, v166 in pairs(v17.weapon_model_changer.weapon_sequence_overrides) do
                            if transform_slashes(v165) == v153 then
                                for _, v168 in pairs(v166) do
                                    if v159 == v168.activity and l_m_nSequence_0 == v168.sequence then
                                        l_m_nSequence_0 = v168.fixed_sequence;
                                        if v168.fixed_cycle then
                                            l_m_flCycle_0 = v168.fixed_cycle;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        v15(v156[0], l_m_nSequence_0);
                        v156.m_flCycle = l_m_flCycle_0;
                    end;
                end;
            end;
        elseif v154 ~= v153 and v92(v154, "weapon") and v133(v154) then
            local v169 = v8(v154);
            if v169 ~= -1 then
                local l_m_hWeaponWorldModel_0 = entity.get_local_player().m_hViewModel[0].m_hWeapon.m_hWeaponWorldModel;
                if l_m_hWeaponWorldModel_0 and l_m_hWeaponWorldModel_0.m_nModelIndex ~= v169 then
                    v9(l_m_hWeaponWorldModel_0[0], v169);
                end;
            end;
        end;
        return;
    end;
end;
for v172 in pairs(v18.cached_agent_lists) do
    for _, v174 in pairs(v16) do
        table.insert(v18.cached_agent_lists[v172].presets, v174.name);
    end;
    local v175 = {};
    for _, v177 in pairs(v17.masks) do
        table.insert(v175, v177.name);
    end;
    v24.extras[v172].mask_presets:update(v175);
    local v178 = {};
    for _, v180 in pairs(v17.viewmodels) do
        table.insert(v178, v180.name);
    end;
    v24.extras[v172].view_presets:update(v178);
end;
v24.agent.T.search_input:set_callback(function(v181)
    -- upvalues: v101 (ref)
    v101(v181:get(), "T");
end, true);
v24.agent.T.remove_button:set_callback(function()
    -- upvalues: v24 (ref), v4 (ref), v101 (ref), v23 (ref), v22 (ref)
    local v182 = v24.agent.T.custom_agents:list()[v24.agent.T.custom_agents:get()];
    if v182 == "                          empty list" or v182 == "                    no models found" then
        return;
    else
        for v183, v184 in pairs(v4.custom_list.T) do
            if v182:find(v184.name) then
                table.remove(v4.custom_list.T, v183);
            end;
        end;
        v101(v24.agent.T.search_input:get(), "T");
        cvar.play:call("ui/menu_invalid.wav");
        common.add_notify("Cloud Model Changer", v23.primary .. v22["file-slash"] .. v23.default .. "  Removed path from Custom List");
        return;
    end;
end);
v24.agent.T.add_button:set_callback(function()
    -- upvalues: l_result_0 (ref), v23 (ref), v22 (ref), v31 (ref), v28 (ref), v38 (ref), v16 (ref), v92 (ref), v85 (ref), v4 (ref), v101 (ref), v24 (ref)
    local v185 = l_result_0.get();
    if not v185 then
        common.add_notify("Cloud Model Changer", v23.red .. v22["file-circle-xmark"] .. v23.default .. "  Cannot find the model file");
        cvar.play:call("ui/panorama/lobby_error_01.wav");
        return;
    else
        v185 = v31(v185);
        v185 = v28(v185);
        local v186 = transform_slashes(v185);
        local v187 = v38(v186);
        for _, v189 in pairs(v16) do
            if v189.path == v186 then
                common.add_notify("Cloud Model Changer", v23.primary .. v22["circle-info"] .. v23.default .. "  This model can be found under the Presets with the name:\n" .. "\"" .. v23.default .. v189.name .. "\"");
                cvar.play:call("survival/info_tips_01.wav");
                return;
            end;
        end;
        if v92(v186) == false then
            common.add_notify("Cloud Model Changer", v23.red .. v22["file-circle-xmark"] .. v23.default .. "  Cannot find the model file");
            cvar.play:call("ui/panorama/lobby_error_01.wav");
            return;
        elseif v85(v4.custom_list.T, v187) then
            common.add_notify("Cloud Model Changer", v23.primary .. v22["circle-info"] .. v23.default .. "  This model is already added as:\n" .. v23.primary .. "\226\128\162 " .. v23.default .. v187);
            cvar.play:call("survival/info_tips_01.wav");
            return;
        else
            table.insert(v4.custom_list.T, {
                name = v187, 
                path = v186
            });
            v101(v24.agent.T.search_input:get(), "T");
            cvar.play:call("ui/menu_accept.wav");
            common.add_notify("Cloud Model Changer", v23.primary .. v22["file-circle-plus"] .. v23.default .. "  Added path to Custom List");
            return;
        end;
    end;
end);
v24.agent.T.apply_button:set_callback(function()
    -- upvalues: v24 (ref), v16 (ref), v4 (ref), v23 (ref)
    local v190 = v24.agent.T.element_selector:get() == 1;
    local v191 = v190 and v24.agent.T.preset_agents or v24.agent.T.custom_agents;
    local v192 = v190 and v16 or v4.custom_list.T;
    local v193 = v191:list()[v191:get()];
    local v194 = "unset";
    if v193 == "                          empty list" or v193 == "                    no models found" then
        return;
    elseif v193 == v24.agent.T.applied_agent_name:get() or v193:sub(24) == v24.agent.T.applied_agent_name:get() then
        return;
    else
        for _, v196 in pairs(v192) do
            if v193 == v196.name then
                v194 = v196.path;
                break;
            end;
        end;
        v24.agent.T.applied_agent_name:set(v193);
        v24.agent.T.applied_agent_path:set(v194);
        cvar.play:call("ui/armsrace_level_up.wav");
        common.add_notify("Cloud Model Changer", "Set Terrorist model to:\n" .. v23.primary .. "\226\128\162 " .. v23.default .. v193);
        return;
    end;
end);
v24.agent.T.reset_button:set_callback(function()
    -- upvalues: v66 (ref), v24 (ref), v23 (ref), v22 (ref)
    local v197, v198 = v66();
    if v197 and v198 == "T" then
        common.force_full_update();
    end;
    v24.agent.T.applied_agent_name:set("unset");
    v24.agent.T.applied_agent_path:set("unset");
    cvar.play:call("ui/menu_invalid.wav");
    common.add_notify("Cloud Model Changer", v23.red .. v22.rotate .. v23.default .. "  Reset Terrorist model");
end);
v24.agent.CT.search_input:set_callback(function(v199)
    -- upvalues: v101 (ref)
    v101(v199:get(), "CT");
end, true);
v24.agent.CT.remove_button:set_callback(function()
    -- upvalues: v24 (ref), v4 (ref), v101 (ref), v23 (ref), v22 (ref)
    local v200 = v24.agent.CT.custom_agents:list()[v24.agent.CT.custom_agents:get()];
    if v200 == "                          empty list" or v200 == "                    no models found" then
        return;
    else
        for v201, v202 in pairs(v4.custom_list.CT) do
            if v200:find(v202.name) then
                table.remove(v4.custom_list.CT, v201);
            end;
        end;
        v101(v24.agent.CT.search_input:get(), "CT");
        cvar.play:call("ui/menu_invalid.wav");
        common.add_notify("Cloud Model Changer", v23.primary .. v22["file-slash"] .. v23.default .. "  Removed path from Custom List");
        return;
    end;
end);
v24.agent.CT.add_button:set_callback(function()
    -- upvalues: l_result_0 (ref), v23 (ref), v22 (ref), v31 (ref), v28 (ref), v38 (ref), v16 (ref), v92 (ref), v85 (ref), v4 (ref), v101 (ref), v24 (ref)
    local v203 = l_result_0.get();
    if not v203 then
        common.add_notify("Cloud Model Changer", v23.red .. v22["file-circle-xmark"] .. v23.default .. "  Cannot find the model file");
        cvar.play:call("ui/panorama/lobby_error_01.wav");
        return;
    else
        v203 = v31(v203);
        v203 = v28(v203);
        local v204 = transform_slashes(v203);
        local v205 = v38(v204);
        for _, v207 in pairs(v16) do
            if v207.path == v204 then
                common.add_notify("Cloud Model Changer", v23.primary .. v22["circle-info"] .. v23.default .. "  This model can be found under the Presets with the name:\n" .. "\"" .. v23.default .. v207.name .. "\"");
                cvar.play:call("survival/info_tips_01.wav");
                return;
            end;
        end;
        if v92(v204) == false then
            common.add_notify("Cloud Model Changer", v23.red .. v22["file-circle-xmark"] .. v23.default .. "  Cannot find the model file");
            cvar.play:call("ui/panorama/lobby_error_01.wav");
            return;
        elseif v85(v4.custom_list.CT, v205) then
            common.add_notify("Cloud Model Changer", v23.primary .. v22["circle-info"] .. v23.default .. "  This model is already added as:\n" .. v23.primary .. "\226\128\162 " .. v23.default .. v205);
            cvar.play:call("survival/info_tips_01.wav");
            return;
        else
            table.insert(v4.custom_list.CT, {
                name = v205, 
                path = v204
            });
            v101(v24.agent.CT.search_input:get(), "CT");
            cvar.play:call("ui/menu_accept.wav");
            common.add_notify("Cloud Model Changer", v23.primary .. v22["file-circle-plus"] .. v23.default .. "  Added path to Custom List");
            return;
        end;
    end;
end);
v24.agent.CT.apply_button:set_callback(function()
    -- upvalues: v24 (ref), v16 (ref), v4 (ref), v23 (ref)
    local v208 = v24.agent.CT.element_selector:get() == 1;
    local v209 = v208 and v24.agent.CT.preset_agents or v24.agent.CT.custom_agents;
    local v210 = v208 and v16 or v4.custom_list.CT;
    local v211 = v209:list()[v209:get()];
    local v212 = "unset";
    if v211 == "                          empty list" or v211 == "                    no models found" then
        return;
    elseif v211 == v24.agent.CT.applied_agent_name:get() or v211:sub(24) == v24.agent.CT.applied_agent_name:get() then
        return;
    else
        for _, v214 in pairs(v210) do
            if v211 == v214.name or v211:sub(1, -15) == v214.name then
                v212 = v214.path;
                break;
            end;
        end;
        v24.agent.CT.applied_agent_name:set(v211);
        v24.agent.CT.applied_agent_path:set(v212);
        cvar.play:call("ui/armsrace_level_up.wav");
        common.add_notify("Cloud Model Changer", "Set Counter-Terrorist model to:\n" .. v23.primary .. "\226\128\162 " .. v23.default .. v211);
        return;
    end;
end);
v24.agent.CT.reset_button:set_callback(function()
    -- upvalues: v66 (ref), v24 (ref), v23 (ref), v22 (ref)
    local v215, v216 = v66();
    if v215 and v216 == "CT" then
        common.force_full_update();
    end;
    v24.agent.CT.applied_agent_name:set("unset");
    v24.agent.CT.applied_agent_path:set("unset");
    cvar.play:call("ui/menu_invalid.wav");
    common.add_notify("Cloud Model Changer", v23.red .. v22.rotate .. v23.default .. "  Reset Counter-Terrorist model");
end);
events.render:set(function()
    -- upvalues: v125 (ref), v18 (ref), v24 (ref), v16 (ref), v45 (ref)
    v125();
    for v217 in pairs(v18.cached_agent_lists) do
        local v218 = v24.agent[v217].applied_agent_name:get();
        for _, v220 in pairs(v16) do
            if v220.files and v220.name == v218 then
                v45(v220);
                break;
            end;
        end;
    end;
end);
events.net_update_end:set(function()
    -- upvalues: v66 (ref), v24 (ref), v137 (ref), v18 (ref), v17 (ref), v146 (ref), v92 (ref)
    local v221, v222, v223 = v66();
    if v221 and v222 == "T" or v222 == "CT" then
        local v224 = v24.agent[v222].applied_agent_path:get();
        if v224 ~= "unset" then
            v137(v224);
            if v222 == "CT" then
                cvar.cl_ragdoll_physics_enable:int(0);
                v18.changed_ragdoll_convar = true;
            elseif v18.changed_ragdoll_convar then
                cvar.cl_ragdoll_physics_enable:int(1);
                v18.changed_ragdoll_convar = false;
            end;
        end;
        local v225 = v24.extras[v222].mask_combo:get();
        local v226 = v225 == "Presets" and v17.masks[v24.extras[v222].mask_presets:get()].path or v225 == "Custom" and v24.extras[v222].mask_custom_path:get() or "unset";
        if v225 == "Disabled" then
            if bit.band(v223.m_iAddonBits, 65536) == 65536 then
                v223.m_iAddonBits = v223.m_iAddonBits - 65536;
            end;
        elseif v225 == "Presets" then
            v146(v226);
        elseif v225 == "Custom" then
            if v92(v226, "mask") then
                v146(v226);
            elseif bit.band(v223.m_iAddonBits, 65536) == 65536 then
                v223.m_iAddonBits = v223.m_iAddonBits - 65536;
            end;
        end;
    end;
end);
events.draw_model:set(function(v227)
    -- upvalues: v66 (ref), v24 (ref), v17 (ref)
    if common.is_in_thirdperson() then
        if v227.name:find("contactshadow") then
            return false;
        else
            local v228, v229, v230 = v66();
            if v228 and v229 == "T" or v229 == "CT" then
                for _, v232 in pairs(v24.extras[v229].attachment_hider:get()) do
                    for _, v234 in pairs(v17.attachment_hider.patterns[v232]) do
                        if v227.name:find(v234) then
                            if v232 == 1 and v234 == "w_ied_dropped.mdl" then
                                return v230 ~= entity.get(v230:get_resource().m_iPlayerC4);
                            elseif v232 == 4 and v234 == "w_eq_taser" then
                                return v230:get_player_weapon() and v230:get_player_weapon():get_weapon_index() == 31;
                            else
                                return false;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end);
events.override_view:set(function()
    -- upvalues: v66 (ref), v24 (ref), v17 (ref), v18 (ref), v151 (ref), v92 (ref), v3 (ref), v171 (ref)
    local v235, v236, v237 = v66();
    if v236 == "T" or v236 == "CT" then
        local v238 = v24.extras[v236].view_combo:get();
        local v239 = v238 == "Presets" and v17.viewmodels[v24.extras[v236].view_presets:get()].path or v238 == "Custom" and v24.extras[v236].view_custom_path:get() or "unset";
        if v238 == "Disabled" then
            v18.ref_self_viewmodel:override();
            v18.ref_self_viewmodel_color:override();
            if v18.cached_viewmodel ~= "unset" then
                common.force_full_update();
                v18.cached_viewmodel = "unset";
            end;
        elseif v238 == "Presets" then
            v151(v239);
        elseif v238 == "Custom" then
            if v92(v239, "viewmodel") then
                v151(v239);
            else
                v18.ref_self_viewmodel:override();
                v18.ref_self_viewmodel_color:override();
                if v18.cached_viewmodel ~= "unset" then
                    common.force_full_update();
                    v18.cached_viewmodel = "unset";
                end;
            end;
        end;
        if v3 and v235 then
            local v240 = v237:get_player_weapon();
            if v240 then
                local v241 = v240:get_weapon_index();
                local v242 = "";
                local v243 = "";
                for v244, v245 in pairs(v17.weapon_model_changer.weapon_ids) do
                    for v246, v247 in pairs(v245) do
                        if type(v247) == "table" then
                            for _, v249 in pairs(v247) do
                                if v241 == v249 then
                                    v242 = v244;
                                    v243 = v246;
                                    break;
                                end;
                            end;
                        elseif v241 == v247 then
                            v242 = v244;
                            v243 = v246;
                            break;
                        end;
                    end;
                end;
                if v24.extras[v236]["weap_" .. v242 .. "_" .. v243] then
                    v171(v24.extras[v236]["weap_" .. v242 .. "_" .. v243]:get());
                end;
            end;
        end;
    end;
end);
events.shutdown:set(function()
    -- upvalues: v66 (ref), v24 (ref), v18 (ref), v4 (ref)
    local v250, v251, v252 = v66();
    if (v250 and v251 == "T" or v251 == "CT") and v24.agent[v251].applied_agent_path:get() ~= "unset" then
        common.force_full_update();
    end;
    if v252 and bit.band(v252.m_iAddonBits, 65536) == 65536 then
        v252.m_iAddonBits = v252.m_iAddonBits - 65536;
    end;
    if v18.cached_viewmodel then
        common.force_full_update();
    end;
    if v18.changed_ragdoll_convar then
        cvar.cl_ragdoll_physics_enable:int(1);
    end;
    db.cloud_model_changer = v4;
end);