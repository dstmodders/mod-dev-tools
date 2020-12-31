require "busted.runner"()

describe("PlayerMapTools", function()
    -- before_each initialization
    local devtools, playertools
    local PlayerMapTools, playermaptools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        devtools = MockDevTools()
        playertools = MockPlayerTools()

        PlayerMapTools = require "devtools/tools/playermaptools"
        playermaptools = PlayerMapTools(playertools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playertools = MockPlayerTools()

            -- initialization
            PlayerMapTools = require "devtools/tools/playermaptools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerMapTools", self.name)

            -- general
            assert.is_equal(playertools.inst, self.inst)
            assert.is_equal(playertools, self.playertools)
            assert.is_equal(playertools.world, self.world)

            -- other
            assert.is_equal(self, self.playertools.map)
        end

        describe("using the constructor", function()
            before_each(function()
                playermaptools = PlayerMapTools(playertools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playermaptools)
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

            playermaptools = PlayerMapTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playermaptools, devtools)
            assert.is_equal(before + TableCount(methods), TableCountFunctions(devtools))
        end)
    end)

    describe("reveal", function()
        describe("Reveal", function()
            local GetSize, RevealArea

            before_each(function()
                GetSize = spy.new(ReturnValuesFn(300, 300))
                RevealArea = spy.new(Empty)

                playermaptools.world.inst.Map.GetSize = GetSize
                playermaptools.inst.player_classified.MapExplorer.RevealArea = RevealArea
            end)

            describe("when the map can be revealed", function()
                it("should call the Map:GetSize()", function()
                    assert.spy(GetSize).was_not_called()
                    playermaptools:Reveal()
                    assert.spy(GetSize).was_called(1)
                    assert.spy(GetSize).was_called_with(playermaptools.world.inst.Map)
                end)

                it("should call the MapExplorer:RevealArea()", function()
                    assert.spy(RevealArea).was_not_called()
                    playermaptools:Reveal()
                    assert.spy(RevealArea).was_called(1681)
                end)

                it("should debug string", function()
                    playermaptools:Reveal()

                    AssertDebugSpyWasCalled("DebugString", 2, {
                        "Revealing map..."
                    })

                    AssertDebugSpyWasCalled("DebugString", 2, {
                        "Map revealing has been completed"
                    })
                end)

                it("should return true", function()
                    assert.is_true(playermaptools:Reveal())
                end)
            end)

            describe("when some inst chain fields are missing", function()
                it("should return nil", function()
                    playermaptools.inst.player_classified.MapExplorer.RevealArea = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.inst.player_classified.MapExplorer = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.inst.player_classified = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.inst = nil
                    assert.is_nil(playermaptools:Reveal())
                end)
            end)

            describe("when some world chain fields are missing", function()
                it("should return nil", function()
                    playermaptools.world.inst.Map.GetSize = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.world.inst.Map = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.world.inst = nil
                    assert.is_nil(playermaptools:Reveal())
                    playermaptools.world = nil
                    assert.is_nil(playermaptools:Reveal())
                end)
            end)
        end)
    end)
end)
