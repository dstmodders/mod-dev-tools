require "busted.runner"()

describe("WorldData", function()
    -- before_each initialization
    local worlddevtools
    local WorldData, worlddata

    setup(function()
        -- debug
        DebugSpyTerm()
        DebugSpyInit(spy)

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

        -- initialization
        worlddevtools = MockWorldDevTools(mock)

        WorldData = require "devtools/data/worlddata"
        worlddata = WorldData(worlddevtools)
        worlddata.world_lines_stack = {}
    end)

    insulate("should be initialized with the default values", function()
        before_each(function()
            WorldData = require "devtools/data/worlddata"
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_table(self.save_data_lines_stack)
            assert.is_nil(self.savedatadevtools)
            assert.is_equal(worlddevtools, self.worlddevtools)
            assert.is_table(self.world_lines_stack)
        end

        it("by using the constructor", function()
            worlddata = WorldData(worlddevtools)
            AssertDefaults(worlddata)
        end)
    end)

    describe("world", function()
        describe("helper", function()
            describe("PushWorldLine", function()
                local PushWorldLine

                before_each(function()
                    PushWorldLine = worlddata._PushWorldLine
                end)

                it("should push the world line", function()
                    assert.is_equal(0, #worlddata.world_lines_stack)
                    PushWorldLine(worlddata, "name", "value")
                    assert.is_equal(1, #worlddata.world_lines_stack)
                end)
            end)

            describe("PushWorldMoistureLine", function()
                local PushWorldMoistureLine

                before_each(function()
                    PushWorldMoistureLine = worlddata._PushWorldMoistureLine
                end)

                describe("when one of the required values is missing", function()
                    it("shouldn't push the corresponding line to the world lines stack", function()
                        worlddata.worlddevtools.GetStateMoisture = ReturnValueFn(nil)
                        PushWorldMoistureLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])

                        worlddata.worlddevtools.GetStateMoistureCeil = ReturnValueFn(nil)
                        PushWorldMoistureLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])

                        worlddata.worlddevtools.GetMoistureFloor = ReturnValueFn(nil)
                        PushWorldMoistureLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])

                        worlddata.worlddevtools.GetMoistureRate = ReturnValueFn(nil)
                        PushWorldMoistureLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])
                    end)
                end)

                describe("when precipitation", function()
                    before_each(function()
                        worlddevtools.IsPrecipitation = ReturnValueFn(true)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should prepend + to the moisture rate", function()
                        PushWorldMoistureLine(worlddata)
                        assert.is_equal(
                            "Moisture: 250.00 | 500.00 (-1.50) | 750.00",
                            worlddata.world_lines_stack[1]
                        )
                    end)
                end)

                describe("when no precipitation", function()
                    before_each(function()
                        worlddevtools.IsPrecipitation = ReturnValueFn(false)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should prepend + to the moisture rate", function()
                        PushWorldMoistureLine(worlddata)
                        assert.is_equal(
                            "Moisture: 250.00 | 500.00 (+1.50) | 750.00",
                            worlddata.world_lines_stack[1]
                        )
                    end)
                end)

                describe("when the moisture floor is available", function()
                    before_each(function()
                        worlddevtools.GetMoistureFloor = ReturnValueFn(250)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should push the world line", function()
                        PushWorldMoistureLine(worlddata)
                        assert.is_equal(
                            "Moisture: 250.00 | 500.00 (-1.50) | 750.00",
                            worlddata.world_lines_stack[1]
                        )
                    end)
                end)

                describe("when the moisture floor is not available", function()
                    before_each(function()
                        worlddevtools.GetMoistureFloor = ReturnValueFn(nil)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should push the world line", function()
                        PushWorldMoistureLine(worlddata)
                        assert.is_equal(
                            "Moisture: 500.00 (-1.50) | 750.00",
                            worlddata.world_lines_stack[1]
                        )
                    end)
                end)
            end)

            describe("PushWorldMoistureLine", function()
                local PushWorldPhaseLine

                before_each(function()
                    PushWorldPhaseLine = worlddata._PushWorldPhaseLine
                end)

                describe("when one of the required values is missing", function()
                    it("shouldn't push the corresponding line to the world lines stack", function()
                        worlddata.worlddevtools.GetPhase = ReturnValueFn(nil)
                        PushWorldPhaseLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])

                        worlddata.worlddevtools.GetNextPhase = ReturnValueFn(nil)
                        PushWorldPhaseLine(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[1])
                    end)
                end)

                describe(
                    "when the WorldDevTools:GetTimeUntilPhase() returns the valid value",
                    function()
                        local GetTimeUntilPhase

                        before_each(function()
                            GetTimeUntilPhase = ReturnValueFn(60)
                            worlddevtools.GetTimeUntilPhase = GetTimeUntilPhase
                            worlddata.worlddevtools = worlddevtools
                        end)

                        it("should push the world line", function()
                            PushWorldPhaseLine(worlddata)
                            assert.is_equal("Phase: day | 01:00", worlddata.world_lines_stack[1])
                        end)
                    end
                )

                describe("when the WorldDevTools:GetTimeUntilPhase() returns nil", function()
                    local GetTimeUntilPhase

                    before_each(function()
                        GetTimeUntilPhase = ReturnValueFn(nil)
                        worlddevtools.GetTimeUntilPhase = GetTimeUntilPhase
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should push the world line", function()
                        PushWorldPhaseLine(worlddata)
                        assert.is_equal("Phase: day", worlddata.world_lines_stack[1])
                    end)
                end)
            end)

            describe("PushWorldPrecipitationLines", function()
                local PushWorldPrecipitationLines

                before_each(function()
                    PushWorldPrecipitationLines = worlddata._PushWorldPrecipitationLines
                end)

                describe("when the precipitation rate is available", function()
                    local GetStatePrecipitationRate

                    before_each(function()
                        GetStatePrecipitationRate = ReturnValueFn(1.5)
                        worlddevtools.GetStatePrecipitationRate = GetStatePrecipitationRate
                        worlddata.worlddevtools = worlddevtools
                    end)

                    describe("and the peak precipitation rate is also available", function()
                        before_each(function()
                            worlddevtools.GetPeakPrecipitationRate = ReturnValueFn(2)
                            worlddata.worlddevtools = worlddevtools
                        end)

                        it("should push the world line", function()
                            PushWorldPrecipitationLines(worlddata)
                            assert.is_equal(
                                "Precipitation Rate: 1.50 | 2.00",
                                worlddata.world_lines_stack[1]
                            )
                        end)
                    end)

                    describe("and the peak precipitation rate is not available", function()
                        before_each(function()
                            worlddevtools.GetPeakPrecipitationRate = ReturnValueFn(nil)
                            worlddata.worlddevtools = worlddevtools
                        end)

                        it("should push the world line", function()
                            PushWorldPrecipitationLines(worlddata)
                            assert.is_equal(
                                "Precipitation Rate: 1.50",
                                worlddata.world_lines_stack[1]
                            )
                        end)
                    end)
                end)

                describe("when the rain starts value is not available", function()
                    before_each(function()
                        worlddevtools.GetPrecipitationStarts = ReturnValueFn(nil)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("shouldn't push the world line", function()
                        assert.is_equal(0, #worlddata.world_lines_stack)
                        PushWorldPrecipitationLines(worlddata)
                        assert.is_equal(1, #worlddata.world_lines_stack)
                    end)
                end)

                describe("when the rain ends value is not available", function()
                    before_each(function()
                        worlddevtools.GetPrecipitationEnds = ReturnValueFn(nil)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("shouldn't push the world line", function()
                        assert.is_equal(0, #worlddata.world_lines_stack)
                        PushWorldPrecipitationLines(worlddata)
                        assert.is_equal(1, #worlddata.world_lines_stack)
                    end)
                end)

                describe("when both rain starts and ends values are available,", function()
                    before_each(function()
                        worlddevtools.GetPrecipitationEnds = ReturnValueFn(90)
                        worlddevtools.GetPrecipitationStarts = ReturnValueFn(30)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    describe("precipitation", function()
                        before_each(function()
                            worlddevtools.IsPrecipitation = ReturnValueFn(true)
                            worlddata.worlddevtools = worlddevtools
                        end)

                        describe("and it is snowing", function()
                            before_each(function()
                                worlddevtools.GetStateIsSnowing = ReturnValueFn(true)
                                worlddata.worlddevtools = worlddevtools
                            end)

                            it("should push the world line", function()
                                PushWorldPrecipitationLines(worlddata)
                                assert.is_equal(
                                    "Snow Ends: ~00:01:30",
                                    worlddata.world_lines_stack[2]
                                )
                            end)
                        end)

                        describe("and it is not snowing", function()
                            before_each(function()
                                worlddevtools.GetStateIsSnowing = ReturnValueFn(false)
                                worlddata.worlddevtools = worlddevtools
                            end)

                            it("should push the world line", function()
                                PushWorldPrecipitationLines(worlddata)
                                assert.is_equal(
                                    "Rain Ends: ~00:01:30",
                                    worlddata.world_lines_stack[2]
                                )
                            end)
                        end)
                    end)

                    describe("no precipitation", function()
                        before_each(function()
                            worlddevtools.IsPrecipitation = ReturnValueFn(false)
                            worlddata.worlddevtools = worlddevtools
                        end)

                        describe("and it is snowing", function()
                            before_each(function()
                                worlddevtools.GetStateIsSnowing = ReturnValueFn(true)
                                worlddata.worlddevtools = worlddevtools
                            end)

                            it("should push the world line", function()
                                PushWorldPrecipitationLines(worlddata)
                                assert.is_equal(
                                    "Snow Starts: ~00:00:30",
                                    worlddata.world_lines_stack[2]
                                )
                            end)
                        end)

                        describe("and it is not snowing", function()
                            before_each(function()
                                worlddevtools.GetStateIsSnowing = ReturnValueFn(false)
                                worlddata.worlddevtools = worlddevtools
                            end)

                            it("should push the world line", function()
                                PushWorldPrecipitationLines(worlddata)
                                assert.is_equal(
                                    "Rain Starts: ~00:00:30",
                                    worlddata.world_lines_stack[2]
                                )
                            end)
                        end)
                    end)
                end)

                describe("when it is snowing", function()
                    before_each(function()
                        worlddevtools.GetStateIsSnowing = ReturnValueFn(true)
                        worlddevtools.GetStatePrecipitationRate = ReturnValueFn(.5)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should push the world line", function()
                        PushWorldPrecipitationLines(worlddata)
                        assert.is_equal("Snow Level: 50.00%", worlddata.world_lines_stack[3])
                    end)
                end)

                describe("when it is not snowing", function()
                    before_each(function()
                        worlddevtools.GetStateIsSnowing = ReturnValueFn(false)
                        worlddata.worlddevtools = worlddevtools
                    end)

                    it("should push the world line", function()
                        PushWorldPrecipitationLines(worlddata)
                        assert.is_nil(worlddata.world_lines_stack[3])
                    end)
                end)
            end)
        end)
    end)

    describe("world", function()
        describe("helper", function()
            describe("PushSaveDataLine", function()
                local PushSaveDataLine

                before_each(function()
                    PushSaveDataLine = worlddata._PushSaveDataLine
                end)

                it("should push the savedata line", function()
                    assert.is_equal(0, #worlddata.save_data_lines_stack)
                    PushSaveDataLine(worlddata, "name", "value")
                    assert.is_equal(1, #worlddata.save_data_lines_stack)
                end)
            end)

            --describe("GetDeerclopsSpawnerValue", function()
            --    local GetDeerclopsSpawnerValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetDeerclopsSpawnerValue = worlddata._GetDeerclopsSpawnerValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal("unavailable", GetDeerclopsSpawnerValue(persistdata))
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.deerclopsspawner = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal("unavailable", GetDeerclopsSpawnerValue(persistdata))
            --            end)
            --        end)
            --
            --        describe("with spawner", function()
            --            before_each(function()
            --                persistdata.deerclopsspawner = {}
            --            end)
            --
            --            describe("and warning", function()
            --                before_each(function()
            --                    persistdata.deerclopsspawner.warning = true
            --                end)
            --
            --                it('should return "warning"', function()
            --                    assert.is_equal("warning", GetDeerclopsSpawnerValue(persistdata))
            --                end)
            --            end)
            --
            --            describe("and without warning", function()
            --                before_each(function()
            --                    persistdata.deerclopsspawner.warning = false
            --                end)
            --
            --                describe("but with an activehassler", function()
            --                    before_each(function()
            --                        persistdata.deerclopsspawner.activehassler = 100000
            --                    end)
            --
            --                    it('should return "yes"', function()
            --                        assert.is_equal("yes", GetDeerclopsSpawnerValue(persistdata))
            --                    end)
            --                end)
            --
            --                describe("but without an activehassler", function()
            --                    before_each(function()
            --                        persistdata.deerclopsspawner.activehassler = nil
            --                    end)
            --
            --                    it('should return "no"', function()
            --                        assert.is_equal("no", GetDeerclopsSpawnerValue(persistdata))
            --                    end)
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
            --
            --describe("GetBeargerSpawnerValue", function()
            --    local GetBeargerSpawnerValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetBeargerSpawnerValue = worlddata._GetBeargerSpawnerValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal(
            --                "unavailable",
            --                GetBeargerSpawnerValue(worlddata, persistdata)
            --            )
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.beargerspawner = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetBeargerSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.beargerspawner = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetBeargerSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.beargerspawner = {}
            --            end)
            --
            --            describe("and warning", function()
            --                before_each(function()
            --                    persistdata.beargerspawner.warning = true
            --                end)
            --
            --                it('should return "warning"', function()
            --                    assert.is_equal(
            --                        "warning",
            --                        GetBeargerSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and without warning", function()
            --                before_each(function()
            --                    persistdata.beargerspawner.warning = false
            --                end)
            --
            --                describe(
            --                    "but with empty activehasslers and with lastKillDay",
            --                    function()
            --                        before_each(function()
            --                            persistdata.beargerspawner.activehasslers = {}
            --                            persistdata.beargerspawner.lastKillDay = 10
            --                        end)
            --
            --                        it("should return the killed day", function()
            --                            assert.is_equal(
            --                                "killed | day 10",
            --                                GetBeargerSpawnerValue(worlddata, persistdata)
            --                            )
            --                        end)
            --                    end
            --                )
            --
            --                describe("but with activehasslers", function()
            --                    before_each(function()
            --                        persistdata.beargerspawner.activehasslers = { 100000, 100001 }
            --                    end)
            --
            --                    it('should return "yes"', function()
            --                        assert.is_equal(
            --                            "yes",
            --                            GetBeargerSpawnerValue(worlddata, persistdata)
            --                        )
            --                    end)
            --                end)
            --
            --                describe("but with empty activehasslers", function()
            --                    before_each(function()
            --                        persistdata.beargerspawner.activehasslers = {}
            --                    end)
            --
            --                    it('should return "no"', function()
            --                        assert.is_equal(
            --                            "no",
            --                            GetBeargerSpawnerValue(worlddata, persistdata)
            --                        )
            --                    end)
            --                end)
            --            end)
            --
            --            describe("but some required data is invalid", function()
            --                it('should return "error"', function()
            --                    persistdata.beargerspawner.warning = "test"
            --                    assert.is_equal(
            --                        "error",
            --                        GetBeargerSpawnerValue(worlddata, persistdata)
            --                    )
            --                    persistdata.beargerspawner.activehasslers = "test"
            --                    assert.is_equal(
            --                        "error",
            --                        GetBeargerSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
            --
            --describe("GetMalbatrossSpawnerValue", function()
            --    local GetMalbatrossSpawnerValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetMalbatrossSpawnerValue = worlddata._GetMalbatrossSpawnerValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal(
            --                "unavailable",
            --                GetMalbatrossSpawnerValue(worlddata, persistdata)
            --            )
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.malbatrossspawner = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.malbatrossspawner = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.malbatrossspawner = {}
            --            end)
            --
            --            describe("and activeguid", function()
            --                before_each(function()
            --                    persistdata.malbatrossspawner.activeguid = 100000
            --                end)
            --
            --                it('should return "yes"', function()
            --                    assert.is_equal(
            --                        "yes",
            --                        GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and without activeguid", function()
            --                before_each(function()
            --                    persistdata.malbatrossspawner.activeguid = nil
            --                end)
            --
            --                describe("but with both _firstspawn and _time_until_spawn", function()
            --                    before_each(function()
            --                        persistdata.malbatrossspawner._firstspawn = true
            --                        persistdata.malbatrossspawner._time_until_spawn = 30
            --                    end)
            --
            --                    it('should return "waiting"', function()
            --                        assert.is_equal(
            --                            "waiting",
            --                            GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                        )
            --                    end)
            --                end)
            --
            --                describe("and _firstspawn", function()
            --                    before_each(function()
            --                        persistdata.malbatrossspawner._firstspawn = false
            --                    end)
            --
            --                    describe("but with a valid _time_until_spawn", function()
            --                        before_each(function()
            --                            persistdata.malbatrossspawner._time_until_spawn = 30
            --                        end)
            --
            --                        it("should return time", function()
            --                            assert.is_equal(
            --                                "00:00:30",
            --                                GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                            )
            --                        end)
            --                    end)
            --                end)
            --
            --                describe("but some required data is invalid", function()
            --                    it('should return "error"', function()
            --                        persistdata.malbatrossspawner._time_until_spawn = nil
            --                        assert.is_equal(
            --                            "error",
            --                            GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                        )
            --                        persistdata.malbatrossspawner._time_until_spawn = "test"
            --                        assert.is_equal(
            --                            "error",
            --                            GetMalbatrossSpawnerValue(worlddata, persistdata)
            --                        )
            --                    end)
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
            --
            --describe("GetDeersSpawnerValue", function()
            --    local GetDeersSpawnerValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetDeersSpawnerValue = worlddata._GetDeersSpawnerValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal("unavailable", GetDeersSpawnerValue(worlddata, persistdata))
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.deerherdspawner = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetDeersSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.deerherdspawner = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetDeersSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.deerherdspawner = {}
            --            end)
            --
            --            describe("and _timetospawn value is <= 0", function()
            --                before_each(function()
            --                    persistdata.deerherdspawner._timetospawn = 0
            --                end)
            --
            --                it('should return "waiting"', function()
            --                    assert.is_equal(
            --                        "waiting",
            --                        GetDeersSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and _timetospawn value", function()
            --                before_each(function()
            --                    persistdata.deerherdspawner._timetospawn = 30
            --                end)
            --
            --                it("should return time", function()
            --                    assert.is_equal(
            --                        "00:00:30",
            --                        GetDeersSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and _timetospawn is not available", function()
            --                before_each(function()
            --                    persistdata.deerherdspawner._timetospawn = nil
            --                end)
            --
            --                describe("without _activedeer", function()
            --                    before_each(function()
            --                        persistdata.deerherdspawner._activedeer = nil
            --                    end)
            --
            --                    it('should return "error"', function()
            --                        assert.is_equal(
            --                            "error",
            --                            GetDeersSpawnerValue(worlddata, persistdata)
            --                        )
            --                    end)
            --                end)
            --
            --                describe("with _activedeer", function()
            --                    before_each(function()
            --                        persistdata.deerherdspawner._activedeer = { 1, 2, 3 }
            --                    end)
            --
            --                    it("should return the _activedeer number", function()
            --                        assert.is_equal(3, GetDeersSpawnerValue(worlddata, persistdata))
            --                    end)
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
            --
            --describe("GetKlausSackSpawnerValue", function()
            --    local GetKlausSackSpawnerValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetKlausSackSpawnerValue = worlddata._GetKlausSackSpawnerValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal(
            --                "unavailable",
            --                GetKlausSackSpawnerValue(worlddata, persistdata)
            --            )
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.klaussackspawner = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetKlausSackSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.klaussackspawner = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal(
            --                    "unavailable",
            --                    GetKlausSackSpawnerValue(worlddata, persistdata)
            --                )
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.klaussackspawner = {}
            --            end)
            --
            --            describe("and timetorespawn is a number > 0", function()
            --                before_each(function()
            --                    persistdata.klaussackspawner.timetorespawn = 30
            --                end)
            --
            --                it('should return time"', function()
            --                    assert.is_equal(
            --                        "00:00:30",
            --                        GetKlausSackSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and timetorespawn is a number = 0", function()
            --                before_each(function()
            --                    persistdata.klaussackspawner.timetorespawn = 0
            --                end)
            --
            --                it('should return "no"', function()
            --                    assert.is_equal(
            --                        "no",
            --                        GetKlausSackSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and timetorespawn is a number < 0", function()
            --                before_each(function()
            --                    persistdata.klaussackspawner.timetorespawn = -30
            --                end)
            --
            --                it('should return "no"', function()
            --                    assert.is_equal(
            --                        "no",
            --                        GetKlausSackSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and timetorespawn is a boolean false", function()
            --                before_each(function()
            --                    persistdata.klaussackspawner.timetorespawn = false
            --                end)
            --
            --                it('should return "yes"', function()
            --                    assert.is_equal(
            --                        "yes",
            --                        GetKlausSackSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and timetorespawn is an invalid value", function()
            --                before_each(function()
            --                    persistdata.klaussackspawner.timetorespawn = "test"
            --                end)
            --
            --                it('should return "error"', function()
            --                    assert.is_equal(
            --                        "error",
            --                        GetKlausSackSpawnerValue(worlddata, persistdata)
            --                    )
            --                end)
            --            end)
            --        end)
            --    end)
            --end)

            --describe("GetHoundedValue", function()
            --    local GetHoundedValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetHoundedValue = worlddata._GetHoundedValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal("unavailable", GetHoundedValue(worlddata, persistdata))
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.hounded = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal("unavailable", GetHoundedValue(worlddata, persistdata))
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.hounded = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal("unavailable", GetHoundedValue(worlddata, persistdata))
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.hounded = {}
            --            end)
            --
            --            describe("and timetoattack is a number > 0", function()
            --                before_each(function()
            --                    persistdata.hounded.timetoattack = 30
            --                end)
            --
            --                it('should return time"', function()
            --                    assert.is_equal("00:00:30", GetHoundedValue(worlddata, persistdata))
            --                end)
            --            end)
            --
            --            describe("and timetoattack is a number = 0", function()
            --                before_each(function()
            --                    persistdata.hounded.timetoattack = 0
            --                end)
            --
            --                it('should return "no"', function()
            --                    assert.is_equal("no", GetHoundedValue(worlddata, persistdata))
            --                end)
            --            end)
            --
            --            describe("and timetoattack is a number < 0", function()
            --                before_each(function()
            --                    persistdata.hounded.timetoattack = -30
            --                end)
            --
            --                it('should return "no"', function()
            --                    assert.is_equal("no", GetHoundedValue(worlddata, persistdata))
            --                end)
            --            end)
            --
            --            describe("and timetoattack is an invalid value", function()
            --                before_each(function()
            --                    persistdata.hounded.timetoattack = "test"
            --                end)
            --
            --                it('should return "error"', function()
            --                    assert.is_equal("error", GetHoundedValue(worlddata, persistdata))
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
            --
            --describe("GetChessUnlocksValue", function()
            --    local GetChessUnlocksValue
            --    local persistdata
            --
            --    before_each(function()
            --        GetChessUnlocksValue = worlddata._GetChessUnlocksValue
            --    end)
            --
            --    describe("when the persistdata is not passed", function()
            --        before_each(function()
            --            persistdata = nil
            --        end)
            --
            --        it('should return "unavailable"', function()
            --            assert.is_equal("unavailable", GetChessUnlocksValue(persistdata))
            --        end)
            --    end)
            --
            --    describe("when the persistdata is passed", function()
            --        before_each(function()
            --            persistdata = {}
            --        end)
            --
            --        describe("without spawner", function()
            --            before_each(function()
            --                persistdata.chessunlocks = nil
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal("unavailable", GetChessUnlocksValue(persistdata))
            --            end)
            --        end)
            --
            --        describe("with an invalid spawner", function()
            --            before_each(function()
            --                persistdata.chessunlocks = "test"
            --            end)
            --
            --            it('should return "unavailable"', function()
            --                assert.is_equal("unavailable", GetChessUnlocksValue(persistdata))
            --            end)
            --        end)
            --
            --        describe("with a valid spawner", function()
            --            before_each(function()
            --                persistdata.chessunlocks = {}
            --            end)
            --
            --            describe("and unlocks is an empty table", function()
            --                before_each(function()
            --                    persistdata.chessunlocks.unlocks = {}
            --                end)
            --
            --                it('should return "no"', function()
            --                    assert.is_equal("no", GetChessUnlocksValue(persistdata))
            --                end)
            --            end)
            --
            --            describe("and unlocks is a table with a single value", function()
            --                before_each(function()
            --                    persistdata.chessunlocks.unlocks = { "pawn" }
            --                end)
            --
            --                it("should return the value", function()
            --                    assert.is_equal("pawn", GetChessUnlocksValue(persistdata))
            --                end)
            --            end)
            --
            --            describe("and unlocks is a table with values", function()
            --                before_each(function()
            --                    persistdata.chessunlocks.unlocks = { "bishop", "pawn", "rook" }
            --                end)
            --
            --                it("should return the values separated by comma", function()
            --                    assert.is_equal(
            --                        "bishop, pawn, rook",
            --                        GetChessUnlocksValue(persistdata)
            --                    )
            --                end)
            --            end)
            --
            --            describe("and unlocks is an invalid value", function()
            --                before_each(function()
            --                    persistdata.chessunlocks.unlocks = "test"
            --                end)
            --
            --                it('should return "error"', function()
            --                    assert.is_equal("error", GetChessUnlocksValue(persistdata))
            --                end)
            --            end)
            --        end)
            --    end)
            --end)
        end)
    end)
end)
