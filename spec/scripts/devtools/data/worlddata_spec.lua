require "busted.runner"()

describe("WorldData", function()
    -- before_each initialization
    local worldtools
    local WorldData, worlddata

    setup(function()
        -- debug
        DebugSpyInit()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = true
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = nil
        _G.GetTime = nil
    end)

    before_each(function()
        -- global
        _G.GetTime = spy.new(ReturnValueFn(0))
        _G.TheWorld = MockWorldInst()

        -- sdk
        _G.SDK.World.IsCave = ReturnValueFn(false)
        _G.SDK.World.Weather.GetMoistureFloor = ReturnValueFn(250)
        _G.SDK.World.Weather.GetMoistureRate = ReturnValueFn(1.5)
        _G.SDK.World.Weather.GetPeakPrecipitationRate = ReturnValueFn(2)
        _G.SDK.World.Weather.HasPrecipitation = ReturnValueFn(true)

        -- initialization
        worldtools = MockWorldTools()

        WorldData = require "devtools/data/worlddata"
        worlddata = WorldData(nil, worldtools)
        worlddata.stack = {}
    end)

    insulate("should be initialized with the default values", function()
        before_each(function()
            WorldData = require "devtools/data/worlddata"
        end)

        local function AssertDefaults(self)
            -- data
            assert.is_nil(self.screen)
            assert.is_table(self.stack)

            -- general
            assert.is_nil(self.worldsavedatatools)
            assert.is_equal(worldtools, self.worldtools)
        end

        it("by using the constructor", function()
            worlddata = WorldData(nil, worldtools)
            AssertDefaults(worlddata)
        end)
    end)

    describe("world", function()
        describe("PushWorldMoistureLine", function()
            before_each(function()
                worlddata.stack = {}
            end)

            describe("when one of the required values is missing", function()
                it("shouldn't push the corresponding line to the world lines stack", function()
                    _G.TheWorld.state.moisture = nil
                    worlddata:PushWorldMoistureLine()
                    assert.is_nil(worlddata.stack[1])

                    _G.TheWorld.state.moistureceil = nil
                    worlddata:PushWorldMoistureLine()
                    assert.is_nil(worlddata.stack[1])

                    _G.SDK.World.Weather.GetMoistureFloor = ReturnValueFn(nil)
                    worlddata:PushWorldMoistureLine()
                    assert.is_nil(worlddata.stack[1])

                    _G.SDK.World.Weather.GetMoistureRate = ReturnValueFn(nil)
                    worlddata:PushWorldMoistureLine()
                    assert.is_nil(worlddata.stack[1])
                end)
            end)

            describe("when precipitation", function()
                before_each(function()
                    _G.SDK.World.Weather.HasPrecipitation = ReturnValueFn(true)
                end)

                it("should prepend + to the moisture rate", function()
                    worlddata:PushWorldMoistureLine()
                    assert.is_equal(
                        "Moisture: 250.00 | 500.00 (-1.50) | 750.00",
                        worlddata.stack[1]
                    )
                end)
            end)

            describe("when no precipitation", function()
                before_each(function()
                    _G.SDK.World.Weather.HasPrecipitation = ReturnValueFn(false)
                end)

                it("should prepend + to the moisture rate", function()
                    worlddata:PushWorldMoistureLine()
                    assert.is_equal(
                        "Moisture: 250.00 | 500.00 (+1.50) | 750.00",
                        worlddata.stack[1]
                    )
                end)
            end)

            describe("when the moisture floor is available", function()
                before_each(function()
                    _G.SDK.World.Weather.GetMoistureFloor = ReturnValueFn(250)
                end)

                it("should push the world line", function()
                    worlddata:PushWorldMoistureLine()
                    assert.is_equal(
                        "Moisture: 250.00 | 500.00 (-1.50) | 750.00",
                        worlddata.stack[1]
                    )
                end)
            end)

            describe("when the moisture floor is not available", function()
                before_each(function()
                    _G.SDK.World.Weather.GetMoistureFloor = ReturnValueFn(nil)
                end)

                it("should push the world line", function()
                    worlddata:PushWorldMoistureLine()
                    assert.is_equal("Moisture: 500.00 (-1.50) | 750.00", worlddata.stack[1])
                end)
            end)
        end)

        describe("PushWorldMoistureLine", function()
            before_each(function()
                worlddata.stack = {}
            end)

            describe("when one of the required values is missing", function()
                it("shouldn't push the corresponding line to the world lines stack", function()
                    _G.SDK.World.GetPhase = ReturnValueFn(nil)
                    worlddata:PushWorldPhaseLine()
                    assert.is_nil(worlddata.stack[1])

                    _G.SDK.World.GetPhaseNext = ReturnValueFn(nil)
                    worlddata:PushWorldPhaseLine()
                    assert.is_nil(worlddata.stack[1])
                end)
            end)

            describe(
                "when the WorldDevTools:GetTimeUntilPhase() returns the valid value",
                function()
                    before_each(function()
                        _G.SDK.World.GetPhase = ReturnValueFn("day")
                        _G.SDK.World.GetPhaseNext = ReturnValueFn("dusk")
                        _G.SDK.World.GetTimeUntilPhase = ReturnValueFn(60)
                    end)

                    it("should push the world line", function()
                        worlddata:PushWorldPhaseLine()
                        assert.is_equal("Phase: day | 01:00", worlddata.stack[1])
                    end)
                end
            )

            describe("when the WorldDevTools:GetTimeUntilPhase() returns nil", function()
                before_each(function()
                    _G.SDK.World.GetPhase = ReturnValueFn("day")
                    _G.SDK.World.GetPhaseNext = ReturnValueFn("dusk")
                    _G.SDK.World.GetTimeUntilPhase = ReturnValueFn(nil)
                end)

                it("should push the world line", function()
                    worlddata:PushWorldPhaseLine()
                    assert.is_equal("Phase: day", worlddata.stack[1])
                end)
            end)
        end)

        describe("PushWorldPrecipitationLines", function()
            before_each(function()
                worlddata.stack = {}
            end)

            describe("when the precipitation rate is available", function()
                before_each(function()
                    _G.TheWorld.state.precipitationrate = 1.5
                end)

                describe("and the peak precipitation rate is also available", function()
                    before_each(function()
                        _G.SDK.World.Weather.GetPeakPrecipitationRate = ReturnValueFn(2)
                    end)

                    it("should push the world line", function()
                        worlddata:PushWorldPrecipitationLines()
                        assert.is_equal("Precipitation Rate: 1.50 | 2.00", worlddata.stack[1])
                    end)
                end)

                describe("and the peak precipitation rate is not available", function()
                    before_each(function()
                        _G.SDK.World.Weather.GetPeakPrecipitationRate = ReturnValueFn(nil)
                    end)

                    it("should push the world line", function()
                        worlddata:PushWorldPrecipitationLines()
                        assert.is_equal("Precipitation Rate: 1.50", worlddata.stack[1])
                    end)
                end)
            end)

            describe("when the rain starts value is not available", function()
                before_each(function()
                    worldtools.GetPrecipitationStarts = ReturnValueFn(nil)
                    worlddata.worldtools = worldtools
                end)

                it("shouldn't push the world line", function()
                    assert.is_equal(0, #worlddata.stack)
                    worlddata:PushWorldPrecipitationLines()
                    assert.is_equal(1, #worlddata.stack)
                end)
            end)

            describe("when the rain ends value is not available", function()
                before_each(function()
                    worldtools.GetPrecipitationEnds = ReturnValueFn(nil)
                    worlddata.worldtools = worldtools
                end)

                it("shouldn't push the world line", function()
                    worlddata:PushWorldPrecipitationLines()
                    assert.is_equal(1, #worlddata.stack)
                end)
            end)

            describe("when both rain starts and ends values are available,", function()
                before_each(function()
                    worldtools.GetPrecipitationEnds = ReturnValueFn(90)
                    worldtools.GetPrecipitationStarts = ReturnValueFn(30)
                    worlddata.worldtools = worldtools
                end)

                describe("precipitation", function()
                    before_each(function()
                        _G.SDK.World.Weather.HasPrecipitation = ReturnValueFn(true)
                    end)

                    describe("and it is snowing", function()
                        before_each(function()
                            _G.TheWorld.state.issnowing = true
                        end)

                        it("should push the world line", function()
                            worlddata:PushWorldPrecipitationLines()
                            assert.is_equal("Snow Ends: ~00:01:30", worlddata.stack[2])
                        end)
                    end)

                    describe("and it is not snowing", function()
                        before_each(function()
                            _G.TheWorld.state.issnowing = false
                        end)

                        it("should push the world line", function()
                            worlddata:PushWorldPrecipitationLines()
                            assert.is_equal("Rain Ends: ~00:01:30", worlddata.stack[2])
                        end)
                    end)
                end)

                describe("no precipitation", function()
                    before_each(function()
                        _G.SDK.World.Weather.HasPrecipitation = ReturnValueFn(false)
                    end)

                    describe("and it is snowing", function()
                        before_each(function()
                            _G.TheWorld.state.issnowing = true
                        end)

                        it("should push the world line", function()
                            worlddata:PushWorldPrecipitationLines()
                            assert.is_equal("Snow Starts: ~00:00:30", worlddata.stack[2])
                        end)
                    end)

                    describe("and it is not snowing", function()
                        before_each(function()
                            _G.TheWorld.state.issnowing = false
                        end)

                        it("should push the world line", function()
                            worlddata:PushWorldPrecipitationLines()
                            assert.is_equal("Rain Starts: ~00:00:30", worlddata.stack[2])
                        end)
                    end)
                end)
            end)

            describe("when it is snowing", function()
                before_each(function()
                    _G.TheWorld.state.issnowing = true
                    _G.TheWorld.state.precipitationrate = .5
                end)

                it("should push the world line", function()
                    worlddata:PushWorldPrecipitationLines()
                    assert.is_equal("Snow Level: 50.00%", worlddata.stack[3])
                end)
            end)

            describe("when it is not snowing", function()
                before_each(function()
                    _G.TheWorld.state.issnowing = false
                    _G.TheWorld.state.precipitationrate = 0
                end)

                it("should push the world line", function()
                    worlddata:PushWorldPrecipitationLines()
                    assert.is_nil(worlddata.stack[3])
                end)
            end)
        end)
    end)

    describe("save data", function()
        before_each(function()
            worlddata.stack = {}
        end)

        describe("PushDeerclopsSpawnerLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushDeerclopsSpawnerLine()
                    assert.is_equal("Deerclops: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            deerclopsspawner = true,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushDeerclopsSpawnerLine()
                        assert.is_equal("Deerclops: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with spawner", function()
                    describe("and warning", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                deerclopsspawner = {
                                    warning = true,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushDeerclopsSpawnerLine()
                            assert.is_equal("Deerclops: warning", worlddata.stack[1])
                        end)
                    end)

                    describe("and without warning", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                deerclopsspawner = {
                                    warning = false,
                                },
                            })
                        end)

                        describe("but with an activehassler", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    deerclopsspawner = {
                                        activehassler = 100000,
                                        warning = false,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushDeerclopsSpawnerLine()
                                assert.is_equal("Deerclops: yes", worlddata.stack[1])
                            end)
                        end)

                        describe("but without an activehassler", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    deerclopsspawner = {
                                        activehassler = nil,
                                        warning = false,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushDeerclopsSpawnerLine()
                                assert.is_equal("Deerclops: no", worlddata.stack[1])
                            end)
                        end)
                    end)
                end)
            end)
        end)

        describe("PushBeargerSpawnerLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushBeargerSpawnerLine()
                    assert.is_equal("Bearger: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            beargerspawner = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushBeargerSpawnerLine()
                        assert.is_equal("Bearger: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            beargerspawner = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushBeargerSpawnerLine()
                        assert.is_equal("Bearger: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and warning", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                beargerspawner = {
                                    warning = true,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushBeargerSpawnerLine()
                            assert.is_equal("Bearger: warning", worlddata.stack[1])
                        end)
                    end)

                    describe("and without warning", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                beargerspawner = {
                                    warning = false,
                                },
                            })
                        end)

                        describe("but with empty activehasslers and with lastKillDay", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    beargerspawner = {
                                        activehasslers = {},
                                        lastKillDay = 10,
                                        warning = false,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushBeargerSpawnerLine()
                                assert.is_equal("Bearger: killed | day 10", worlddata.stack[1])
                            end)
                        end)

                        describe("but with activehasslers", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    beargerspawner = {
                                        activehasslers = { 100000, 100001 },
                                        warning = false,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushBeargerSpawnerLine()
                                assert.is_equal("Bearger: yes", worlddata.stack[1])
                            end)
                        end)

                        describe("but with empty activehasslers", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    beargerspawner = {
                                        activehasslers = {},
                                        warning = false,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushBeargerSpawnerLine()
                                assert.is_equal("Bearger: no", worlddata.stack[1])
                            end)
                        end)
                    end)

                    describe("but warning is invalid", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                beargerspawner = {
                                    warning = "test",
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushBeargerSpawnerLine()
                            assert.is_equal("Bearger: error", worlddata.stack[1])
                        end)
                    end)

                    describe("but activehasslers is invalid", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                beargerspawner = {
                                    activehasslers = "test",
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushBeargerSpawnerLine()
                            assert.is_equal("Bearger: error", worlddata.stack[1])
                        end)
                    end)
                end)
            end)
        end)

        describe("PushMalbatrossSpawnerLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushMalbatrossSpawnerLine()
                    assert.is_equal("Malbatross: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            malbatrossspawner = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushMalbatrossSpawnerLine()
                        assert.is_equal("Malbatross: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            malbatrossspawner = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushMalbatrossSpawnerLine()
                        assert.is_equal("Malbatross: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and activeguid", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                malbatrossspawner = {
                                    activeguid = 100000,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushMalbatrossSpawnerLine()
                            assert.is_equal("Malbatross: yes", worlddata.stack[1])
                        end)
                    end)

                    describe("and without activeguid", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                malbatrossspawner = {
                                    activeguid = nil,
                                },
                            })
                        end)

                        describe("but with both _firstspawn and _time_until_spawn", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    malbatrossspawner = {
                                        activeguid = nil,
                                        _firstspawn = true,
                                        _time_until_spawn = 30,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushMalbatrossSpawnerLine()
                                assert.is_equal("Malbatross: waiting", worlddata.stack[1])
                            end)
                        end)

                        describe("and _firstspawn", function()
                            describe("but with a valid _time_until_spawn", function()
                                before_each(function()
                                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                        malbatrossspawner = {
                                            activeguid = nil,
                                            _firstspawn = false,
                                            _time_until_spawn = 30,
                                        },
                                    })
                                end)

                                it("should push the save data line", function()
                                    worlddata:PushMalbatrossSpawnerLine()
                                    assert.is_equal("Malbatross: 00:00:30", worlddata.stack[1])
                                end)
                            end)
                        end)

                        describe("but _time_until_spawn is nil", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    malbatrossspawner = {
                                        _time_until_spawn = nil,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushMalbatrossSpawnerLine()
                                assert.is_equal("Malbatross: error", worlddata.stack[1])
                            end)
                        end)

                        describe("but _time_until_spawn is invalid", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    malbatrossspawner = {
                                        _time_until_spawn = "test",
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushMalbatrossSpawnerLine()
                                assert.is_equal("Malbatross: error", worlddata.stack[1])
                            end)
                        end)
                    end)
                end)
            end)
        end)

        describe("PushDeersSpawnerLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushDeersSpawnerLine()
                    assert.is_equal("Deers: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            deerherdspawner = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushDeersSpawnerLine()
                        assert.is_equal("Deers: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            deerherdspawner = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushDeersSpawnerLine()
                        assert.is_equal("Deers: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and _timetospawn value is <= 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                deerherdspawner = {
                                    _timetospawn = 0,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushDeersSpawnerLine()
                            assert.is_equal("Deers: waiting", worlddata.stack[1])
                        end)
                    end)

                    describe("and _timetospawn value", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                deerherdspawner = {
                                    _timetospawn = 30,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushDeersSpawnerLine()
                            assert.is_equal("Deers: 00:00:30", worlddata.stack[1])
                        end)
                    end)

                    describe("and _timetospawn is not available", function()
                        describe("without _activedeer", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    deerherdspawner = {
                                        _timetospawn = nil,
                                        _activedeer = nil,
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushDeersSpawnerLine()
                                assert.is_equal("Deers: error", worlddata.stack[1])
                            end)
                        end)

                        describe("with _activedeer", function()
                            before_each(function()
                                _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                    deerherdspawner = {
                                        _timetospawn = nil,
                                        _activedeer = { 1, 2, 3 },
                                    },
                                })
                            end)

                            it("should push the save data line", function()
                                worlddata:PushDeersSpawnerLine()
                                assert.is_equal("Deers: 3", worlddata.stack[1])
                            end)
                        end)
                    end)
                end)
            end)
        end)

        describe("PushKlausSackSpawnerLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushKlausSackSpawnerLine()
                    assert.is_equal("Klaus Sack: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            klaussackspawner = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushKlausSackSpawnerLine()
                        assert.is_equal("Klaus Sack: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            klaussackspawner = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushKlausSackSpawnerLine()
                        assert.is_equal("Klaus Sack: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and timetorespawn is a number > 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                klaussackspawner = {
                                    timetorespawn = 30,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushKlausSackSpawnerLine()
                            assert.is_equal("Klaus Sack: 00:00:30", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetorespawn is a number = 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                klaussackspawner = {
                                    timetorespawn = 0,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushKlausSackSpawnerLine()
                            assert.is_equal("Klaus Sack: no", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetorespawn is a number < 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                klaussackspawner = {
                                    timetorespawn = -30,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushKlausSackSpawnerLine()
                            assert.is_equal("Klaus Sack: no", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetorespawn is a boolean false", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                klaussackspawner = {
                                    timetorespawn = false,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushKlausSackSpawnerLine()
                            assert.is_equal("Klaus Sack: yes", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetorespawn is an invalid value", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                klaussackspawner = {
                                    timetorespawn = "test",
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushKlausSackSpawnerLine()
                            assert.is_equal("Klaus Sack: error", worlddata.stack[1])
                        end)
                    end)
                end)
            end)
        end)

        describe("PushHoundedLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushHoundedLine()
                    assert.is_equal("Hounds Attack: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            hounded = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushHoundedLine()
                        assert.is_equal("Hounds Attack: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            hounded = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushHoundedLine()
                        assert.is_equal("Hounds Attack: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and timetoattack is a number > 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                hounded = {
                                    timetoattack = 30,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushHoundedLine()
                            assert.is_equal("Hounds Attack: 00:00:30", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetoattack is a number = 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                hounded = {
                                    timetoattack = 0,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushHoundedLine()
                            assert.is_equal("Hounds Attack: no", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetoattack is a number < 0", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                hounded = {
                                    timetoattack = -30,
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushHoundedLine()
                            assert.is_equal("Hounds Attack: no", worlddata.stack[1])
                        end)
                    end)

                    describe("and timetoattack is an invalid value", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                hounded = {
                                    timetoattack = "test",
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushHoundedLine()
                            assert.is_equal("Hounds Attack: error", worlddata.stack[1])
                        end)
                    end)
                end)
            end)

            describe("when in the cave", function()
                before_each(function()
                    _G.SDK.World.IsCave = ReturnValueFn(true)
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushHoundedLine()
                    assert.is_equal("Worms Attack: unavailable", worlddata.stack[1])
                end)
            end)
        end)

        describe("PushChessUnlocksLine", function()
            describe("when the persistdata is not passed", function()
                before_each(function()
                    _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn(nil)
                end)

                it("should push the save data line", function()
                    worlddata:PushChessUnlocksLine()
                    assert.is_equal("Chess Unlocks: unavailable", worlddata.stack[1])
                end)
            end)

            describe("when the persistdata is passed", function()
                describe("without spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            chessunlocks = nil,
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushChessUnlocksLine()
                        assert.is_equal("Chess Unlocks: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with an invalid spawner", function()
                    before_each(function()
                        _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                            chessunlocks = "test",
                        })
                    end)

                    it("should push the save data line", function()
                        worlddata:PushChessUnlocksLine()
                        assert.is_equal("Chess Unlocks: unavailable", worlddata.stack[1])
                    end)
                end)

                describe("with a valid spawner", function()
                    describe("and unlocks is an empty table", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                chessunlocks = {
                                    unlocks = {},
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushChessUnlocksLine()
                            assert.is_equal("Chess Unlocks: no", worlddata.stack[1])
                        end)
                    end)

                    describe("and unlocks is a table with a single value", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                chessunlocks = {
                                    unlocks = { "pawn" },
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushChessUnlocksLine()
                            assert.is_equal("Chess Unlocks: pawn", worlddata.stack[1])
                        end)
                    end)

                    describe("and unlocks is a table with values", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                chessunlocks = {
                                    unlocks = { "bishop", "pawn", "rook" },
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushChessUnlocksLine()
                            assert.is_equal("Chess Unlocks: bishop, pawn, rook", worlddata.stack[1])
                        end)
                    end)

                    describe("and unlocks is an invalid value", function()
                        before_each(function()
                            _G.SDK.World.SaveData.GetMapPersistData = ReturnValueFn({
                                chessunlocks = {
                                    unlocks = "test",
                                },
                            })
                        end)

                        it("should push the save data line", function()
                            worlddata:PushChessUnlocksLine()
                            assert.is_equal("Chess Unlocks: error", worlddata.stack[1])
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
