require "busted.runner"()

describe("ConsoleDevTools", function()
    -- before_each initialization
    local ConsoleDevTools, consoledevtools
    local devtools, playerdevtools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.ConsoleRemote = nil
        _G.MOD_DEV_TOOLS_TEST = nil
        _G.TheNet = nil
        _G.TheSim = nil
    end)

    before_each(function()
        -- general
        devtools = MockDevTools()
        playerdevtools = MockPlayerDevTools()

        -- globals
        _G.ConsoleRemote = spy.new(Empty)
        _G.MOD_DEV_TOOLS_TEST = true
        _G.TheNet = MockTheNet()
        _G.TheSim = MockTheSim()

        -- sdk
        _G.SDK.Player.IsAdmin = ReturnValueFn(true)
        _G.SDK.World.IsCave = ReturnValueFn(false)

        -- initialization
        ConsoleDevTools = require "devtools/devtools/player/consoledevtools"
        consoledevtools = ConsoleDevTools(playerdevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playerdevtools = MockPlayerDevTools()

            -- initialization
            ConsoleDevTools = require "devtools/devtools/player/consoledevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("ConsoleDevTools", self.name)

            -- general
            assert.is_equal(playerdevtools.inst, self.inst)
            assert.is_equal(playerdevtools, self.playerdevtools)
            assert.is_equal(playerdevtools.world, self.worlddevtools)

            -- other
            --assert.is_equal(self, self.playerdevtools.console)
        end

        describe("using the constructor", function()
            before_each(function()
                consoledevtools = ConsoleDevTools(playerdevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(consoledevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- player
                "SetHealthPercent",
                "SetHungerPercent",
                "SetSanityPercent",
                "SetMaxHealthPercent",
                "SetMoisturePercent",
                "SetTemperature",
                "SetWerenessPercent",

                -- teleport
                "GoNext",
                "GatherPlayers",

                -- world
                "DeltaMoisture",
                "DeltaWetness",
                "ForcePrecipitation",
                "MiniQuake",
                "PushWorldEvent",
                "SendLightningStrike",
                "SetSeason",
                "SetSeasonLength",
                "SetSnowLevel",
                "SetTimeScale",

                -- crafting
                --"ToggleFreeCrafting",
                "UnlockRecipe",
                "LockRecipe",
            }

            AssertAddedMethodsBefore(methods, devtools)
            consoledevtools = ConsoleDevTools(playerdevtools, devtools)
            AssertAddedMethodsAfter(methods, consoledevtools, devtools)
        end)
    end)

    describe("remote", function()
        local remotes = {
            SetHealthPercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'c_sethealth(%0.2f)', { .4 } },
                    { "Health:", "40%" },
                },
            },
            SetHungerPercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'c_sethunger(%0.2f)', { .4 } },
                    { "Hunger:", "40%" },
                },
            },
            SetSanityPercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'c_setsanity(%0.2f)', { .4 } },
                    { "Sanity:", "40%" },
                },
            },
            SetMaxHealthPercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'ConsoleCommandPlayer().components.health:SetPenalty(%0.2f)', { .6 } },
                    { "Maximum Health:", "40%" },
                },
            },
            SetMoisturePercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'c_setmoisture(%0.2f)', { .4 } },
                    { "Moisture:", "40%" },
                },
            },
            SetTemperature = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'c_settemperature(%0.2f)', { 40 } },
                    { "Temperature:", "40" },
                },
            },
            SetWerenessPercent = {
                invalid = { 1000, "1000" },
                valid = {
                    40,
                    { 'ConsoleCommandPlayer().components.wereness:SetPercent(%0.2f)', { 40 } },
                    { "Wereness:", "40" },
                },
            },
            GoNext = {
                invalid = { { "Bearger", 1000 }, "1000" },
                valid = {
                    { "Bearger", "bearger" },
                    { 'c_gonext("%s")', { "bearger" } },
                    { "Teleported to", "Bearger" },
                },
            },
            GatherPlayers = {
                valid = {
                    {},
                    { "c_gatherplayers()" },
                    { "Gathered players" },
                },
            },
            DeltaMoisture = {
                invalid = { "test", "test" },
                valid = {
                    100,
                    { 'TheWorld:PushEvent("ms_deltamoisture", %d)', { 100 } },
                    { "ConsoleDevTools:DeltaMoisture():", "100" },
                },
            },
            DeltaWetness = {
                invalid = { "test", "test" },
                valid = {
                    100,
                    { 'TheWorld:PushEvent("ms_deltawetness", %d)', { 100 } },
                    { "ConsoleDevTools:DeltaWetness():", "100" },
                },
            },
            ForcePrecipitation = {
                invalid = { 1000, "1000" },
                valid = {
                    true,
                    { 'TheWorld:PushEvent("ms_forceprecipitation", %s)', { "true" } },
                    { "ConsoleDevTools:ForcePrecipitation():", "true" },
                },
            },
            PushWorldEvent = {
                invalid = { 1000, "1000" },
                valid = {
                    "ms_nextcycle",
                    { 'TheWorld:PushEvent("%s")', { "ms_nextcycle" } },
                    { "ConsoleDevTools:PushWorldEvent():", "ms_nextcycle" },
                },
            },
            SendLightningStrike = {
                world = "forest",
                invalid = { 1000, "1000" },
                valid = {
                    { x = 1, y = 2, z = 3 },
                    {
                        'TheWorld:PushEvent("ms_sendlightningstrike", %s)',
                        { "Point(1.00, 2.00, 3.00)" },
                    },
                    {
                        "ConsoleDevTools:SendLightningStrike():",
                        "(1.00, 2.00, 3.00)",
                    },
                },
            },
            SetSeason = {
                invalid = { 1000, "1000" },
                valid = {
                    "autumn",
                    { 'TheWorld:PushEvent("ms_setseason", "%s")', { "autumn" } },
                    { "ConsoleDevTools:SetSeason():", "autumn" },
                },
            },
            SetSeasonLength = {
                invalid = { { "autumn", "test" }, "autumn, test" },
                valid = {
                    { "autumn", 20 },
                    {
                        'TheWorld:PushEvent("ms_setseasonlength", { season="%s", length=%d })',
                        { "autumn", 20 },
                    },
                    { "ConsoleDevTools:SetSeasonLength():", "autumn, 20" },
                },
            },
            SetSnowLevel = {
                world = "forest",
                invalid = { "test", "test" },
                valid = {
                    .5,
                    { 'TheWorld:PushEvent("ms_setsnowlevel", %0.2f)', { .5 } },
                    { "ConsoleDevTools:SetSnowLevel():", "0.5" },
                },
            },
        }

        for remote, data in pairs(remotes) do
            describe(remote, function()
                local invalid = data.invalid
                local world = data.world

                describe("when the owner is not an admin", function()
                    before_each(function()
                        _G.SDK.Player.IsAdmin = ReturnValueFn(false)
                    end)

                    it("should debug error", function()
                        DebugSpyClear("DebugError")
                        consoledevtools[remote](consoledevtools)
                        DebugSpyAssertWasCalled("DebugError", 1, {
                            string.format("ConsoleDevTools:%s():", remote),
                            "not an admin"
                        })
                    end)

                    it("should return false", function()
                        assert.is_false(
                            consoledevtools[remote](consoledevtools),
                            remote
                        )
                    end)
                end)

                describe("when the owner is an admin", function()
                    if world then
                        local another_world = world == "forest" and "cave" or "forest"

                        describe("and in the " .. another_world, function()
                            before_each(function()
                                _G.SDK.World.IsCave = ReturnValueFn(true)
                            end)

                            it("should debug error", function()
                                DebugSpyClear("DebugError")
                                consoledevtools[remote](consoledevtools)
                                DebugSpyAssertWasCalled("DebugError", 1, {
                                    string.format("ConsoleDevTools:%s():", remote),
                                    string.format("not in the %s world", world)
                                })
                            end)

                            it("should return false", function()
                                assert.is_false(
                                    consoledevtools[remote](consoledevtools),
                                    remote
                                )
                            end)
                        end)
                    end

                    describe("with a valid passed value", function()
                        local console, debug, debug_fn, value

                        before_each(function()
                            console = data.valid[2]
                            debug = data.valid[3]
                            value = data.valid[1]

                            if type(value) == "table" and value.x and value.y and value.z then
                                value = { value }
                            elseif type(value) ~= "table" then
                                value = { value }
                            end

                            debug_fn = data.debug_fn ~= nil and data.debug_fn or "DebugString"
                        end)

                        it("should send the corresponding remote console command", function()
                            assert.spy(_G.ConsoleRemote, remote).was_not_called()
                            consoledevtools[remote](consoledevtools, unpack(value))
                            assert.spy(_G.ConsoleRemote, remote).was_called(1)
                            assert.spy(_G.ConsoleRemote, remote).was_called_with(unpack(console))
                        end)

                        it("should debug string", function()
                            DebugSpyClear(debug_fn)
                            consoledevtools[remote](consoledevtools, unpack(value))
                            DebugSpyAssertWasCalled(debug_fn, 1, debug)
                        end)

                        it("should return true", function()
                            assert.is_true(
                                consoledevtools[remote](consoledevtools, unpack(value)),
                                remote
                            )
                        end)
                    end)

                    if invalid then
                        local error = invalid[2]
                        local value = type(invalid[1]) ~= "table" and { invalid[1] } or invalid[1]

                        describe("with an invalid passed value", function()
                            it("should debug error", function()
                                DebugSpyClear("DebugError")
                                consoledevtools[remote](consoledevtools, unpack(value))
                                DebugSpyAssertWasCalled("DebugError", 1, {
                                    string.format("ConsoleDevTools:%s():", remote),
                                    "invalid value",
                                    string.format("(%s)", error)
                                })
                            end)

                            it("should return false", function()
                                assert.is_false(
                                    consoledevtools[remote](consoledevtools),
                                    remote
                                )
                            end)
                        end)
                    end
                end)
            end)
        end

        describe("MiniQuake", function()
            describe("when the owner is not in the cave", function()
                before_each(function()
                    _G.SDK.World.IsCave = ReturnValueFn(false)
                end)

                it("should debug error", function()
                    DebugSpyClear("DebugError")
                    consoledevtools:MiniQuake()
                    DebugSpyAssertWasCalled("DebugError", 1, {
                        "ConsoleDevTools:MiniQuake():",
                        "not in the cave world"
                    })
                end)

                it("should return false", function()
                    assert.is_false(consoledevtools:MiniQuake())
                end)
            end)

            describe("when the owner is in the cave", function()
                before_each(function()
                    _G.SDK.World.IsCave = ReturnValueFn(true)
                end)

                describe("and the owner is not an admin", function()
                    before_each(function()
                        _G.SDK.Player.IsAdmin = ReturnValueFn(false)
                    end)

                    it("should debug error", function()
                        DebugSpyClear("DebugError")
                        consoledevtools:MiniQuake()
                        DebugSpyAssertWasCalled("DebugError", 1, {
                            "ConsoleDevTools:MiniQuake():",
                            "not an admin"
                        })
                    end)

                    it("should return false", function()
                        assert.is_false(consoledevtools:MiniQuake())
                    end)
                end)

                describe("and the owner is an admin", function()
                    before_each(function()
                        _G.SDK.Player.IsAdmin = ReturnValueFn(true)
                    end)

                    describe("with valid passed values", function()
                        it("should send the corresponding remote console command", function()
                            assert.spy(_G.ConsoleRemote).was_not_called()
                            consoledevtools:MiniQuake(nil, 10, 10, 1)
                            assert.spy(_G.ConsoleRemote).was_called(1)
                            assert.spy(_G.ConsoleRemote).was_called_with(
                                'TheWorld:PushEvent("ms_miniquake", { target = LookupPlayerInstByUserID("%s"), rad = %d, num = %d, duration = %0.2f })', -- luacheck: only
                                { "KU_admin", 10, 10, 1 }
                            )
                        end)

                        it("should debug string", function()
                            DebugSpyClear("DebugString")
                            consoledevtools:MiniQuake(nil, 10, 10, 1)
                            DebugSpyAssertWasCalled("DebugString", 1, {
                                "ConsoleDevTools:MiniQuake():",
                                "KU_admin, 10, 10, 1"
                            })
                        end)

                        it("should return true", function()
                            assert.is_true(consoledevtools:MiniQuake(nil, 10, 10, 1))
                        end)
                    end)

                    describe("with invalid passed values", function()
                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            consoledevtools:MiniQuake(1, "test", "test", "test")
                            DebugSpyAssertWasCalled("DebugError", 1, {
                                "ConsoleDevTools:MiniQuake():",
                                "invalid value",
                                "(1, test, test, test)"
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(
                                consoledevtools:MiniQuake(1, "test", "test", "test")
                            )
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
