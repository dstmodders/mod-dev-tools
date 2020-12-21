--
-- Packages
--

local preloads = {
    ["sdk/config"] = "scripts/devtools/sdk/sdk/config",
    ["sdk/console"] = "scripts/devtools/sdk/sdk/console",
    ["sdk/constant"] = "scripts/devtools/sdk/sdk/constant",
    ["sdk/debug"] = "scripts/devtools/sdk/sdk/debug",
    ["sdk/debugupvalue"] = "scripts/devtools/sdk/sdk/debugupvalue",
    ["sdk/dump"] = "scripts/devtools/sdk/sdk/dump",
    ["sdk/entity"] = "scripts/devtools/sdk/sdk/entity",
    ["sdk/input"] = "scripts/devtools/sdk/sdk/input",
    ["sdk/modmain"] = "scripts/devtools/sdk/sdk/modmain",
    ["sdk/player"] = "scripts/devtools/sdk/sdk/player",
    ["sdk/rpc"] = "scripts/devtools/sdk/sdk/rpc",
    ["sdk/thread"] = "scripts/devtools/sdk/sdk/thread",
    ["sdk/utils"] = "scripts/devtools/sdk/sdk/utils",
    ["sdk/utils/chain"] = "scripts/devtools/sdk/sdk/utils/chain",
    ["sdk/utils/methods"] = "scripts/devtools/sdk/sdk/utils/methods",
    ["sdk/utils/string"] = "scripts/devtools/sdk/sdk/utils/string",
    ["sdk/utils/table"] = "scripts/devtools/sdk/sdk/utils/table",
    ["sdk/world"] = "scripts/devtools/sdk/sdk/world",
    ["widgets/uianim"] = "spec/empty",
    class = "spec/class",
    consolecommands = "spec/empty",
    speech_wilson = "spec/empty",
}

package.path = "./scripts/?.lua;" .. package.path
for k, v in pairs(preloads) do
    package.preload[k] = function()
        return require(v)
    end
end

--
-- SDK
--

_G.MODS_ROOT = "./"

function softresolvefilepath(filepath)
    return _G.MODS_ROOT .. filepath
end

local SDK

SDK = require "devtools/sdk/sdk/sdk"
SDK.Load({
    modname = "dst-mod-dev-tools",
    AddPrefabPostInit = function() end
}, "scripts/devtools/sdk", {
    "Config",
    "Console",
    "Constant",
    "Debug",
    "DebugUpvalue",
    "Dump",
    "Entity",
    "Input",
    "ModMain",
    "Player",
    "Thread",
    "World",
})

_G.SDK = SDK

--
-- General
--

function TableCount(t)
    local result = 0
    for _, _ in pairs(t) do
        result = result + 1
    end
    return result
end

function TableCountFunctions(t)
    local result = 0
    for k, _ in pairs(t) do
        if type(t[k]) == "function" then
            result = result + 1
        end
    end
    return result
end

function TableHasValue(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function Empty()
end

function ReturnValues(...)
    return ...
end

function ReturnValueFn(value)
    return function()
        return value
    end
end

function ReturnValuesFn(...)
    local args = { ... }
    return function()
        return unpack(args)
    end
end

--
-- Debug
--

local _DEBUG_SPY = {}

function DebugSpy(name)
    for _name, method in pairs(_DEBUG_SPY) do
        if _name == name then
            return method
        end
    end
end

function DebugSpyAssert(name)
    local assert = require "luassert.assert"
    return assert.spy(DebugSpy(name))
end

function DebugSpyAssertWasCalled(name, calls, args)
    local match = require "luassert.match"
    calls = calls ~= nil and calls or 0
    args = args ~= nil and args or {}
    args = type(args) == "string" and { args } or args
    DebugSpyAssert(name).was_called(calls)
    if calls > 0 then
        DebugSpyAssert(name).was_called_with(match.is_not_nil(), unpack(args))
    end
end

function DebugSpyClear(name)
    if name ~= nil then
        for _name, method in pairs(_DEBUG_SPY) do
            if _name == name then
                method:clear()
                return
            end
        end
    end

    for _, method in pairs(_DEBUG_SPY) do
        method:clear()
    end
end

function DebugSpyInit()
    local spy = require "luassert.spy"
    local functions = {
        "Error",
        "Init",
        "ModConfigs",
        "String",
        "StringStart",
        "StringStop",
        "Term",
    }

    DebugSpyTerm()

    for _, fn in pairs(functions) do
        if SDK.Debug[fn] and not _DEBUG_SPY[fn] then
            _DEBUG_SPY[fn] = spy.new(Empty)
        end
    end

    SDK.Debug.AddMethods = function(self)
        for _, fn in pairs(functions) do
            if SDK.Debug[fn] and _DEBUG_SPY[fn] and not self["Debug" .. fn] then
                self["Debug" .. fn] = _DEBUG_SPY[fn]
                _DEBUG_SPY["Debug" .. fn] = self["Debug" .. fn]
            end
        end
    end
end

function DebugSpyTerm()
    for name, _ in pairs(_DEBUG_SPY) do
        _DEBUG_SPY[name] = nil
    end
end

--
-- RPC
--

function MockRPCInit()
    local spy = require("busted").spy

    _G.ACTIONS = {
        EQUIP = {
            id = "EQUIP",
            code = 49,
        },
    }

    _G.Ents = spy.new(ReturnValueFn({}))

    _G.RPC = {
        SwapActiveItemWithSlot = 49,
        UseItemFromInvTile = 56,
    }

    _G.SendRPCToServer = spy.new(Empty)
end

function MockRPCTerm()
    _G.ACTIONS = nil
    _G.Ents = nil
    _G.RPC = nil
    _G.SendRPCToServer = nil
end

function MockRPCClear()
    _G.SendRPCToServer:clear()
end

--
-- Asserts
--

function AssertAddedMethodsBefore(functions, dest)
    for k, v in pairs(functions) do
        k = type(k) == "number" and v or k
        AssertMethodIsMissing(dest, k)
    end
end

function AssertAddedMethodsAfter(functions, src, dest)
    for k, v in pairs(functions) do
        k = type(k) == "number" and v or k
        AssertMethodExists(src, v)
        AssertMethodExists(dest, k)
    end
end

function AssertChainNil(fn, src, ...)
    if src and (type(src) == "table" or type(src) == "userdata") then
        local args = { ... }
        local start = src
        local previous, key

        for i = 1, #args do
            if start[args[i]] then
                previous = start
                key = args[i]
                start = start[key]
            end
        end

        if previous and src then
            previous[key] = nil
            args[#args] = nil
            fn()
            AssertChainNil(fn, src, unpack(args))
        end
    end
end

function AssertMethodExists(class, fn_name)
    local assert = require("busted").assert
    local classname = class.name ~= nil and class.name or "Class"
    assert.is_not_nil(
        class[fn_name],
        string.format("Function %s:%s() is missing", tostring(classname), tostring(fn_name))
    )
end

function AssertMethodIsMissing(class, fn_name)
    local assert = require("busted").assert
    local classname = class.name ~= nil and class.name or "Class"
    assert.is_nil(class[fn_name], string.format("Function %s:%s() exists", classname, fn_name))
end

function AssertGetter(class, field, fn_name, test_data)
    test_data = test_data ~= nil and test_data or "test"

    AssertMethodExists(class, fn_name)
    local classname = class.name ~= nil and class.name or "Class"
    local fn = class[fn_name]

    local msg = string.format(
        "Getter %s:%s() doesn't return the %s.%s value",
        tostring(classname),
        tostring(fn_name),
        tostring(classname),
        tostring(field)
    )

    local assert = require("busted").assert
    assert.is_equal(class[field], fn(class), msg)
    class[field] = test_data
    assert.is_equal(test_data, fn(class), msg)
end

function AssertSetter(class, field, fn_name, test_data)
    test_data = test_data ~= nil and test_data or "test"

    AssertMethodExists(class, fn_name)
    local classname = class.name ~= nil and class.name or "Class"
    local fn = class[fn_name]

    local msg = string.format(
        "Setter %s:%s() doesn't set the %s.%s value",
        tostring(classname),
        tostring(fn_name),
        tostring(classname),
        tostring(field)
    )

    fn(class, test_data)

    local assert = require("busted").assert
    assert.is_equal(test_data, class[field], msg)
end

--
-- Mocks
--

function MockTheNet(client_table)
    client_table = client_table ~= nil and client_table or {
        { userid = "KU_admin", admin = true },
        { userid = "KU_one", admin = false },
    }

    return require("busted").mock({
        GetClientTable = function()
            return client_table
        end,
        SendRemoteExecute = Empty,
    })
end

function MockTheSim()
    return require("busted").mock({
        GetPersistentString = Empty,
        GetPosition = Empty,
        ProjectScreenPos = function()
            return 1, 2, 3
        end,
    })
end

function MockDevTools()
    return require("busted").mock({
        name = "DevTools",
        labels = {
            AddSelected = Empty,
            AddUsername = Empty,
            RemoveSelected = Empty,
        },
    })
end

function MockInventoryReplica()
    return require("busted").mock({
        GetItems = Empty,
    })
end

function MockPlayerDevTools()
    local world = MockWorldDevTools()
    return require("busted").mock({
        console = {},
        controller = nil,
        crafting = {},
        inst = MockPlayerInst("PlayerInst"),
        inventory = MockInventoryReplica(),
        ismastersim = world.inst.ismastersim,
        name = "PlayerDevTools",
        vision = {},
        world = world,
    })
end

function MockPlayerInst(name, userid, states, tags, position)
    userid = userid ~= nil and userid or "KU_admin"
    states = states ~= nil and states or { "idle" }
    tags = tags ~= nil and tags or {}
    position = position ~= nil and position or { 1, 2, 3 }

    local animation
    local state_tags = {}

    if TableHasValue(states, "dead") then
        table.insert(tags, "playerghost")
    end

    if TableHasValue(states, "idle") then
        animation = "idle_loop"
        table.insert(state_tags, "idle")
        table.insert(tags, "idle")
    end

    if TableHasValue(states, "hopping") then
        animation = "boat_jump_loop"
        table.insert(state_tags, "hop_loop")
        table.insert(tags, "ignorewalkableplatforms")
    end

    if TableHasValue(states, "running") then
        animation = "run_loop"
        table.insert(state_tags, "run")
        table.insert(tags, "moving")
    end

    if TableHasValue(states, "sinking") then
        animation = "sink"
        table.insert(state_tags, "sink_fast")
        table.insert(tags, "busy")
    end

    return require("busted").mock({
        components = {
            health = {
                invincible = TableHasValue(states, "godmode"),
            },
            playervision = {
                currentcctable = nil,
                overridecctable = nil,
                GetCCTable = function(self)
                    return self.currentcctable
                end,
                SetCustomCCTable = function(self, cct)
                    self.overridecctable = cct
                end,
            },
        },
        event_listeners = {
            one = Empty,
            two = Empty,
            three = Empty,
        },
        name = name,
        player_classified = {
            event_listeners = {
                one = Empty,
                two = Empty,
                three = Empty,
            },
            ListenForEvent = Empty,
            RemoveEventCallback = Empty,
            MapExplorer = {
                RevealArea = Empty,
            },
        },
        prefab = "wilson",
        replica = {
            inventory = MockInventoryReplica(),
        },
        sg = {
            HasStateTag = function(_, tag)
                return TableHasValue(state_tags, tag)
            end,
        },
        userid = userid,
        AnimState = {
            IsCurrentAnimation = function(_, anim)
                return anim == animation
            end,
        },
        GetCurrentPlatform = ReturnValueFn(nil),
        GetDisplayName = function(self)
            return self.name
        end,
        HasTag = function(_, tag)
            return TableHasValue(tags, tag)
        end,
        LightWatcher = {
            GetTimeInDark = ReturnValueFn(3),
            GetTimeInLight = ReturnValueFn(0),
            IsInLight = ReturnValueFn(false),
        },
        ListenForEvent = Empty,
        PushEvent = Empty,
        RemoveEventCallback = Empty,
        Transform = {
            GetWorldPosition = function()
                return unpack(position)
            end,
        },
    })
end

function MockWorldDevTools()
    return require("busted").mock({
        inst = MockWorldInst(),
        name = "WorldDevTools",
        GetPrecipitationEnds = ReturnValueFn(90),
        GetPrecipitationStarts = ReturnValueFn(30),
    })
end

function MockWorldInst()
    return require("busted").mock({
        ismastersim = true,
        meta = {
            saveversion = "5.031",
        },
        net = {
            components = {
                caveweather = {
                    name = "caveweather",
                },
                weather = {
                    name = "weather",
                },
            },
        },
        state = {
            cavephase = "day",
            phase = "day",
            remainingdaysinseason = 20,
            season = "autumn",
            temperature = 20,
            moisture = 500,
            moistureceil = 750,
            snowlevel = .5,
            issnowing = false,
            precipitation = "none",
            precipitationrate = 1.5,
            wetness = 50,
        },
        topology = {
            ids = {
                "Badlands:0:BuzzardyBadlands",
                "Badlands:1:BuzzardyBadlands",
                "Badlands:2:BarePlain",
                "MoonIsland_Beach:0:MoonIsland_Beach",
                "MoonIsland_Beach:1:MoonIsland_Beach",
                "MoonIsland_Beach:2:MoonIsland_Blank",
                "The hunters:0:Clearing",
                "The hunters:4:WalrusHut_Plains",
                "The hunters:5:WalrusHut_Rocky",
                "The hunters:8:WalrusHut_Grassy",
            },
        },
        HasTag = function(_, tag)
            return tag == "cave"
        end,
        Map = {
            GetSize = function()
                return 300, 300
            end,
            GetTileAtPoint = function(_, x, y, z)
                -- 6: GROUND.GRASS
                -- 201: GROUND.OCEAN_COASTAL
                return x == 100 and y == 0 and z == 100 and 201 or 6
            end,
            IsVisualGroundAtPoint = function(_, x, y, z)
                return not (x == 100 and y == 0 and z == 100) and true or false
            end,
        },
    })
end

--
-- Klei
--

function table.reverse(tab)
    local size = #tab
    local newTable = {}

    for i, v in ipairs(tab) do
        newTable[size - i + 1] = v
    end

    return newTable
end
