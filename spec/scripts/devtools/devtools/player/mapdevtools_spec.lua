require "busted.runner"()

describe("MapDevTools", function()
    -- before_each initialization
    local devtools, playerdevtools
    local MapDevTools, mapdevtools

    setup(function()
        DebugSpyTerm()
        DebugSpyInit(spy)
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        devtools = MockDevTools()
        playerdevtools = MockPlayerDevTools()

        MapDevTools = require "devtools/devtools/player/mapdevtools"
        mapdevtools = MapDevTools(playerdevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playerdevtools = MockPlayerDevTools()

            -- initialization
            MapDevTools = require "devtools/devtools/player/mapdevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("MapDevTools", self.name)

            -- general
            assert.is_equal(playerdevtools.inst, self.inst)
            assert.is_equal(playerdevtools, self.playerdevtools)
            assert.is_equal(playerdevtools.world, self.world)

            -- other
            assert.is_equal(self, self.playerdevtools.map)
        end

        describe("using the constructor", function()
            before_each(function()
                mapdevtools = MapDevTools(playerdevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(mapdevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "IsMapScreenOpen",
                "Reveal",
            }

            local before = TableCountFunctions(devtools)
            AssertAddedMethodsBefore(methods, devtools)

            mapdevtools = MapDevTools(playerdevtools, devtools)
            AssertAddedMethodsAfter(methods, mapdevtools, devtools)
            assert.is_equal(before + TableCount(methods), TableCountFunctions(devtools))
        end)
    end)

    describe("reveal", function()
        describe("Reveal", function()
            local GetSize, RevealArea

            before_each(function()
                GetSize = spy.new(ReturnValuesFn(300, 300))
                RevealArea = spy.new(Empty)

                mapdevtools.world.inst.Map.GetSize = GetSize
                mapdevtools.inst.player_classified.MapExplorer.RevealArea = RevealArea
            end)

            describe("when the map can be revealed", function()
                it("should call the Map:GetSize()", function()
                    assert.spy(GetSize).was_not_called()
                    mapdevtools:Reveal()
                    assert.spy(GetSize).was_called(1)
                    assert.spy(GetSize).was_called_with(mapdevtools.world.inst.Map)
                end)

                it("should call the MapExplorer:RevealArea()", function()
                    assert.spy(RevealArea).was_not_called()
                    mapdevtools:Reveal()
                    assert.spy(RevealArea).was_called(1681)
                end)

                it("should debug string", function()
                    mapdevtools:Reveal()

                    DebugSpyAssertWasCalled("DebugString", 2, {
                        "Revealing map..."
                    })

                    DebugSpyAssertWasCalled("DebugString", 2, {
                        "Map revealing has been completed"
                    })
                end)

                it("should return true", function()
                    assert.is_true(mapdevtools:Reveal())
                end)
            end)

            describe("when some inst chain fields are missing", function()
                it("should return nil", function()
                    mapdevtools.inst.player_classified.MapExplorer.RevealArea = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.inst.player_classified.MapExplorer = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.inst.player_classified = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.inst = nil
                    assert.is_nil(mapdevtools:Reveal())
                end)
            end)

            describe("when some world chain fields are missing", function()
                it("should return nil", function()
                    mapdevtools.world.inst.Map.GetSize = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.world.inst.Map = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.world.inst = nil
                    assert.is_nil(mapdevtools:Reveal())
                    mapdevtools.world = nil
                    assert.is_nil(mapdevtools:Reveal())
                end)
            end)
        end)
    end)
end)
