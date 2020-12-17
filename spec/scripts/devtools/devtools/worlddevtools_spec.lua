require "busted.runner"()

describe("WorldDevTools", function()
    -- setup
    local match

    -- before_each initialization
    local devtools, inst
    local WorldDevTools, worlddevtools

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyInit()
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.ConsoleRemote = nil
        _G.GetDebugEntity = nil
        _G.SetDebugEntity = nil
        _G.StartThread = nil
        _G.TheInput = nil
        _G.TheSim = nil
    end)

    before_each(function()
        -- globals
        _G.ConsoleRemote = spy.new(Empty)
        _G.GetDebugEntity = spy.new(ReturnValueFn("GetDebugEntity"))
        _G.SetDebugEntity = spy.new(Empty)
        _G.StartThread = spy.new(Empty)
        _G.TheInput = spy.new(Empty)
        _G.TheSim = MockTheSim()

        -- initialization
        devtools = MockDevTools()
        inst = MockWorldInst()

        WorldDevTools = require "devtools/devtools/worlddevtools"
        worlddevtools = WorldDevTools(inst, devtools)

        WorldDevTools.StartPrecipitationThread = spy.new(Empty)
        WorldDevTools.GuessMapKeyPositions = spy.new(Empty)
        WorldDevTools.GuessNrOfWalrusCamps = spy.new(Empty)
        WorldDevTools.LoadSaveData = spy.new(Empty)
        WorldDevTools.StartPrecipitationThread = spy.new(Empty)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            WorldDevTools = require "devtools/devtools/worlddevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("WorldDevTools", self.name)

            -- general
            assert.is_equal(inst, self.inst)
            assert.is_equal(inst.ismastersim, self.inst.ismastersim)

            -- map
            assert.is_false(self.is_map_clearing)
            assert.is_true(self.is_map_fog_of_war)

            -- precipitation
            assert.is_nil(self.precipitation_ends)
            assert.is_nil(self.precipitation_starts)
            assert.is_nil(self.precipitation_thread)

            -- upvalues
            assert.is_nil(self.weathermoisturefloor)
            assert.is_nil(self.weathermoisturerate)
            assert.is_nil(self.weatherpeakprecipitationrate)
            assert.is_nil(self.weatherwetrate)

            -- spies
            assert.spy(self.StartPrecipitationThread).was_called(1)
            assert.spy(self.StartPrecipitationThread).was_called_with(match.is_ref(self))

            -- DevTools
            assert.is_equal(self.inst.ismastersim, self.devtools.ismastersim)
        end

        describe("using the constructor", function()
            before_each(function()
                worlddevtools = WorldDevTools(inst, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(worlddevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                SelectWorld = "Select",
                SelectWorldNet = "SelectNet",

                -- general
                "IsMasterSim",
                "GetWorld",
                "GetWorldNet",

                -- selection
                "GetSelectedEntity",
                "SelectEntityUnderMouse",

                -- map
                "IsMapClearing",
                "IsMapFogOfWar",
                "ToggleMapClearing",
                "ToggleMapFogOfWar",

                -- weather
                "GetPrecipitationStarts",
                "GetPrecipitationEnds",
                "StartPrecipitationThread",
                "ClearPrecipitationThread",
            }

            AssertAddedMethodsBefore(methods, devtools)
            worlddevtools = WorldDevTools(inst, devtools)
            AssertAddedMethodsAfter(methods, worlddevtools, devtools)
        end)
    end)

    describe("general", function()
        it("should have the getter GetWorld", function()
            AssertGetter(worlddevtools, "inst", "GetWorld")
        end)

        describe("GetWorldNet", function()
            it("should return TheWorld.net", function()
                assert.is_equal(worlddevtools.inst.net, worlddevtools:GetWorldNet())
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(worlddevtools:GetWorldNet())
                    end, worlddevtools, "inst", "net")
                end)
            end)
        end)
    end)

    describe("selection", function()
        describe("GetSelectedEntity", function()
            it("should call the GetDebugEntity()", function()
                assert.spy(GetDebugEntity).was_not_called()
                worlddevtools:GetSelectedEntity()
                assert.spy(GetDebugEntity).was_called(1)
                assert.spy(GetDebugEntity).was_called_with()
            end)

            it("should return GetDebugEntity() value", function()
                assert.is_equal("GetDebugEntity", worlddevtools:GetSelectedEntity())
            end)
        end)

        describe("Select", function()
            it("should call the SetDebugEntity()", function()
                assert.spy(SetDebugEntity).was_not_called()
                worlddevtools:Select()
                assert.spy(SetDebugEntity).was_called(1)
                assert.spy(SetDebugEntity).was_called_with(match.is_ref(worlddevtools.inst))
            end)

            it("should debug string", function()
                worlddevtools:Select()
                DebugSpyAssertWasCalled("DebugString", 1, {
                    "Selected TheWorld"
                })
            end)

            it("should return true", function()
                assert.is_true(worlddevtools:Select())
            end)
        end)

        describe("SelectNet", function()
            it("should call the SetDebugEntity()", function()
                assert.spy(SetDebugEntity).was_not_called()
                worlddevtools:SelectNet()
                assert.spy(SetDebugEntity).was_called(1)
                assert.spy(SetDebugEntity).was_called_with(match.is_ref(worlddevtools.inst.net))
            end)

            it("should debug string", function()
                worlddevtools:SelectNet()
                DebugSpyAssertWasCalled("DebugString", 1, {
                    "Selected TheWorld.net"
                })
            end)

            it("should return true", function()
                assert.is_true(worlddevtools:SelectNet())
            end)
        end)

        describe("SelectEntityUnderMouse", function()
            local GetWorldEntityUnderMouse

            before_each(function()
                GetWorldEntityUnderMouse = spy.new(
                    ReturnValueFn({ GetDisplayName = ReturnValueFn("Test") })
                )

                _G.TheInput.GetWorldEntityUnderMouse = GetWorldEntityUnderMouse
            end)

            it("should call the TheInput:GetWorldEntityUnderMouse()", function()
                assert.spy(GetWorldEntityUnderMouse).was_not_called()
                worlddevtools:SelectEntityUnderMouse()
                assert.spy(GetWorldEntityUnderMouse).was_called(1)
                assert.spy(GetWorldEntityUnderMouse).was_called_with(match.is_ref(TheInput))
            end)

            describe("when there is an entity under mouse", function()
                it("should debug string", function()
                    worlddevtools:SelectEntityUnderMouse()
                    DebugSpyAssertWasCalled("DebugString", 1, {
                        "Selected",
                        "Test"
                    })
                end)

                it("should return true", function()
                    assert.is_true(worlddevtools:SelectEntityUnderMouse())
                end)
            end)

            describe("when there is no entity under mouse", function()
                before_each(function()
                    GetWorldEntityUnderMouse = ReturnValueFn(nil)
                    _G.TheInput.GetWorldEntityUnderMouse = GetWorldEntityUnderMouse
                end)

                it("should return false", function()
                    assert.is_false(worlddevtools:SelectEntityUnderMouse())
                end)
            end)
        end)
    end)

    describe("map", function()
        describe("should have the getter", function()
            local getters = {
                is_map_clearing = "IsMapClearing",
                is_map_fog_of_war = "IsMapFogOfWar",
            }

            for field, getter in pairs(getters) do
                it(getter, function()
                    AssertGetter(worlddevtools, field, getter)
                end)
            end
        end)
    end)

    describe("weather", function()
        describe("should have the", function()
            describe("getter", function()
                local getters = {
                    precipitation_starts = "GetPrecipitationStarts",
                    precipitation_ends = "GetPrecipitationEnds",
                }

                for field, getter in pairs(getters) do
                    it(getter, function()
                        AssertGetter(worlddevtools, field, getter)
                    end)
                end
            end)
        end)
    end)
end)
