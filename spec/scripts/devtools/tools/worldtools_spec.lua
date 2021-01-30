require "busted.runner"()

describe("WorldTools", function()
    -- setup
    local match

    -- before_each initialization
    local devtools, inst
    local WorldTools, worldtools

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

        WorldTools = require "devtools/tools/worldtools"
        worldtools = WorldTools(inst, devtools)

        WorldTools.StartPrecipitationThread = spy.new(Empty)
        WorldTools.GuessMapKeyPositions = spy.new(Empty)
        WorldTools.GuessNrOfWalrusCamps = spy.new(Empty)
        WorldTools.LoadSaveData = spy.new(Empty)
        WorldTools.StartPrecipitationThread = spy.new(Empty)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            WorldTools = require "devtools/tools/worldtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("WorldTools", self.name)

            -- general
            assert.is_equal(inst, self.inst)

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
        end

        describe("using the constructor", function()
            before_each(function()
                worldtools = WorldTools(inst, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(worldtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                SelectWorld = "Select",
                SelectWorldNet = "SelectNet",

                -- general
                "GetWorld",
                "GetWorldNet",

                -- selection
                "GetSelectedEntity",
                "SelectEntityUnderMouse",

                -- map
                "IsMapFogOfWar",
                "ToggleMapFogOfWar",

                -- weather
                "GetPrecipitationStarts",
                "GetPrecipitationEnds",
                "StartPrecipitationThread",
                "ClearPrecipitationThread",
            }

            AssertAddedMethodsBefore(methods, devtools)
            worldtools = WorldTools(inst, devtools)
            AssertAddedMethodsAfter(methods, worldtools, devtools)
        end)
    end)

    describe("general", function()
        it("should have the getter GetWorld", function()
            AssertClassGetter(worldtools, "inst", "GetWorld")
        end)

        describe("GetWorldNet", function()
            it("should return TheWorld.net", function()
                assert.is_equal(worldtools.inst.net, worldtools:GetWorldNet())
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(worldtools:GetWorldNet())
                    end, worldtools, "inst", "net")
                end)
            end)
        end)
    end)

    describe("selection", function()
        describe("GetSelectedEntity", function()
            it("should call the GetDebugEntity()", function()
                assert.spy(GetDebugEntity).was_not_called()
                worldtools:GetSelectedEntity()
                assert.spy(GetDebugEntity).was_called(1)
                assert.spy(GetDebugEntity).was_called_with()
            end)

            it("should return GetDebugEntity() value", function()
                assert.is_equal("GetDebugEntity", worldtools:GetSelectedEntity())
            end)
        end)

        describe("Select", function()
            it("should call the SetDebugEntity()", function()
                assert.spy(SetDebugEntity).was_not_called()
                worldtools:Select()
                assert.spy(SetDebugEntity).was_called(1)
                assert.spy(SetDebugEntity).was_called_with(match.is_ref(worldtools.inst))
            end)

            it("should debug string", function()
                worldtools:Select()
                AssertDebugSpyWasCalled("DebugString", 1, {
                    "Selected TheWorld"
                })
            end)

            it("should return true", function()
                assert.is_true(worldtools:Select())
            end)
        end)

        describe("SelectNet", function()
            it("should call the SetDebugEntity()", function()
                assert.spy(SetDebugEntity).was_not_called()
                worldtools:SelectNet()
                assert.spy(SetDebugEntity).was_called(1)
                assert.spy(SetDebugEntity).was_called_with(match.is_ref(worldtools.inst.net))
            end)

            it("should debug string", function()
                worldtools:SelectNet()
                AssertDebugSpyWasCalled("DebugString", 1, {
                    "Selected TheWorld.net"
                })
            end)

            it("should return true", function()
                assert.is_true(worldtools:SelectNet())
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
                worldtools:SelectEntityUnderMouse()
                assert.spy(GetWorldEntityUnderMouse).was_called(1)
                assert.spy(GetWorldEntityUnderMouse).was_called_with(match.is_ref(TheInput))
            end)

            describe("when there is an entity under mouse", function()
                it("should debug string", function()
                    worldtools:SelectEntityUnderMouse()
                    AssertDebugSpyWasCalled("DebugString", 1, {
                        "Selected",
                        "Test"
                    })
                end)

                it("should return true", function()
                    assert.is_true(worldtools:SelectEntityUnderMouse())
                end)
            end)

            describe("when there is no entity under mouse", function()
                before_each(function()
                    GetWorldEntityUnderMouse = ReturnValueFn(nil)
                    _G.TheInput.GetWorldEntityUnderMouse = GetWorldEntityUnderMouse
                end)

                it("should return false", function()
                    assert.is_false(worldtools:SelectEntityUnderMouse())
                end)
            end)
        end)
    end)

    describe("map", function()
        describe("should have the getter", function()
            local getters = {
                is_map_fog_of_war = "IsMapFogOfWar",
            }

            for field, getter in pairs(getters) do
                it(getter, function()
                    AssertClassGetter(worldtools, field, getter)
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
                        AssertClassGetter(worldtools, field, getter)
                    end)
                end
            end)
        end)
    end)
end)
