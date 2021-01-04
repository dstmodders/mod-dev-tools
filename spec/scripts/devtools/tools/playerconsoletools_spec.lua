require "busted.runner"()

describe("PlayerConsoleTools", function()
    -- before_each initialization
    local PlayerConsoleTools, playerconsoletools
    local devtools, playertools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = nil
        _G.RemoteSend = nil
        _G.TheNet = nil
        _G.TheSim = nil
    end)

    before_each(function()
        -- general
        devtools = MockDevTools()
        playertools = MockPlayerTools()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = true
        _G.RemoteSend = spy.new(Empty)
        _G.TheNet = MockTheNet()
        _G.TheSim = MockTheSim()

        -- sdk
        _G.SDK.Player.IsAdmin = ReturnValueFn(true)
        _G.SDK.World.IsCave = ReturnValueFn(false)

        -- initialization
        PlayerConsoleTools = require "devtools/tools/playerconsoletools"
        playerconsoletools = PlayerConsoleTools(playertools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playertools = MockPlayerTools()

            -- initialization
            PlayerConsoleTools = require "devtools/tools/playerconsoletools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerConsoleTools", self.name)

            -- general
            assert.is_equal(playertools.inst, self.inst)
            assert.is_equal(playertools, self.playertools)
            assert.is_equal(playertools.world, self.worldtools)

            -- other
            --assert.is_equal(self, self.playertools.console)
        end

        describe("using the constructor", function()
            before_each(function()
                playerconsoletools = PlayerConsoleTools(playertools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playerconsoletools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- player
                "SetMaxHealthPercent",
                "SetMoisturePercent",
                "SetTemperature",
                "SetWerenessPercent",

                -- teleport
                "GoNext",

                -- world
                "MiniQuake",
                "PushWorldEvent",
                "SetTimeScale",

                -- crafting
                --"ToggleFreeCrafting",
                "UnlockRecipe",
                "LockRecipe",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playerconsoletools = PlayerConsoleTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playerconsoletools, devtools)
        end)
    end)

    describe("remote", function()
        local remotes = {
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
            PushWorldEvent = {
                invalid = { 1000, "1000" },
                valid = {
                    "ms_nextcycle",
                    { 'TheWorld:PushEvent("%s")', { "ms_nextcycle" } },
                    { "PlayerConsoleTools:PushWorldEvent():", "ms_nextcycle" },
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
                        playerconsoletools[remote](playerconsoletools)
                        AssertDebugSpyWasCalled("DebugError", 1, {
                            string.format("PlayerConsoleTools:%s():", remote),
                            "not an admin"
                        })
                    end)

                    it("should return false", function()
                        assert.is_false(
                            playerconsoletools[remote](playerconsoletools),
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
                                playerconsoletools[remote](playerconsoletools)
                                AssertDebugSpyWasCalled("DebugError", 1, {
                                    string.format("PlayerConsoleTools:%s():", remote),
                                    string.format("not in the %s world", world)
                                })
                            end)

                            it("should return false", function()
                                assert.is_false(
                                    playerconsoletools[remote](playerconsoletools),
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
                            assert.spy(_G.RemoteSend, remote).was_not_called()
                            playerconsoletools[remote](playerconsoletools, unpack(value))
                            assert.spy(_G.RemoteSend, remote).was_called(1)
                            assert.spy(_G.RemoteSend, remote).was_called_with(unpack(console))
                        end)

                        it("should debug string", function()
                            DebugSpyClear(debug_fn)
                            playerconsoletools[remote](playerconsoletools, unpack(value))
                            AssertDebugSpyWasCalled(debug_fn, 1, debug)
                        end)

                        it("should return true", function()
                            assert.is_true(
                                playerconsoletools[remote](playerconsoletools, unpack(value)),
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
                                playerconsoletools[remote](playerconsoletools, unpack(value))
                                AssertDebugSpyWasCalled("DebugError", 1, {
                                    string.format("PlayerConsoleTools:%s():", remote),
                                    "invalid value",
                                    string.format("(%s)", error)
                                })
                            end)

                            it("should return false", function()
                                assert.is_false(
                                    playerconsoletools[remote](playerconsoletools),
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
                    playerconsoletools:MiniQuake()
                    AssertDebugSpyWasCalled("DebugError", 1, {
                        "PlayerConsoleTools:MiniQuake():",
                        "not in the cave world"
                    })
                end)

                it("should return false", function()
                    assert.is_false(playerconsoletools:MiniQuake())
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
                        playerconsoletools:MiniQuake()
                        AssertDebugSpyWasCalled("DebugError", 1, {
                            "PlayerConsoleTools:MiniQuake():",
                            "not an admin"
                        })
                    end)

                    it("should return false", function()
                        assert.is_false(playerconsoletools:MiniQuake())
                    end)
                end)

                describe("and the owner is an admin", function()
                    before_each(function()
                        _G.SDK.Player.IsAdmin = ReturnValueFn(true)
                    end)

                    describe("with valid passed values", function()
                        it("should send the corresponding remote console command", function()
                            assert.spy(_G.RemoteSend).was_not_called()
                            playerconsoletools:MiniQuake(nil, 10, 10, 1)
                            assert.spy(_G.RemoteSend).was_called(1)
                            assert.spy(_G.RemoteSend).was_called_with(
                                'TheWorld:PushEvent("ms_miniquake", { target = LookupPlayerInstByUserID("%s"), rad = %d, num = %d, duration = %0.2f })', -- luacheck: only
                                { "KU_admin", 10, 10, 1 }
                            )
                        end)

                        it("should debug string", function()
                            DebugSpyClear("DebugString")
                            playerconsoletools:MiniQuake(nil, 10, 10, 1)
                            AssertDebugSpyWasCalled("DebugString", 1, {
                                "PlayerConsoleTools:MiniQuake():",
                                "KU_admin, 10, 10, 1"
                            })
                        end)

                        it("should return true", function()
                            assert.is_true(playerconsoletools:MiniQuake(nil, 10, 10, 1))
                        end)
                    end)

                    describe("with invalid passed values", function()
                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            playerconsoletools:MiniQuake(1, "test", "test", "test")
                            AssertDebugSpyWasCalled("DebugError", 1, {
                                "PlayerConsoleTools:MiniQuake():",
                                "invalid value",
                                "(1, test, test, test)"
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(
                                playerconsoletools:MiniQuake(1, "test", "test", "test")
                            )
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
