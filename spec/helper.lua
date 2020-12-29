--
-- Packages
--

package.path = "./scripts/?.lua;" .. package.path

local preloads = {
    class = "devtools/sdk/spec/class",
    consolecommands = "devtools/sdk/spec/empty",
}

for k, v in pairs(preloads) do
    package.preload[k] = function()
        return require(v)
    end
end

--
-- SDK
--

local SDK

SDK = require "devtools/sdk/sdk/sdk"
SDK.SetIsSilent(true).Load({
    modname = "dst-mod-dev-tools",
    AddPrefabPostInit = function() end
}, "devtools/sdk")

_G.SDK = SDK

--
-- General
--

function TableCountFunctions(t)
    local result = 0
    for k, _ in pairs(t) do
        if type(t[k]) == "function" then
            result = result + 1
        end
    end
    return result
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
        AssertHasNoFunction(dest, k)
    end
end

function AssertAddedMethodsAfter(functions, src, dest)
    for k, v in pairs(functions) do
        k = type(k) == "number" and v or k
        AssertHasFunction(src, v)
        AssertHasFunction(dest, k)
    end
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
