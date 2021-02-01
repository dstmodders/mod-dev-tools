require "busted.runner"()

describe("PlayerVisionTools", function()
    -- setup
    local match
    local NIGHTVISION_COLOUR_CUBES

    -- before_each initialization
    local devtools, playertools
    local PlayerVisionTools, playervisiontools

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyInit()

        -- other
        NIGHTVISION_COLOUR_CUBES = {
            day = "images/colour_cubes/mole_vision_off_cc.tex",
            dusk = "images/colour_cubes/mole_vision_on_cc.tex",
            full_moon = "images/colour_cubes/mole_vision_off_cc.tex",
            night = "images/colour_cubes/mole_vision_on_cc.tex",
        }
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.TheSim = nil
    end)

    before_each(function()
        -- globals
        _G.TheSim = MockTheSim()

        -- initialization
        devtools = MockDevTools()
        playertools = MockPlayerTools()
        playertools.vision = nil

        PlayerVisionTools = require "devtools/tools/playervisiontools"
        playervisiontools = PlayerVisionTools(playertools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playertools = MockPlayerTools()
            playertools.vision = nil

            -- initialization
            PlayerVisionTools = require "devtools/tools/playervisiontools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerVisionTools", self.name)

            -- general
            assert.is_nil(self.cct)
            assert.is_equal(playertools.inst, self.inst)
            assert.is_equal(playertools.inventory, self.inventory)
            assert.is_equal(playertools, self.playertools)

            -- HUD
            assert.is_false(self.is_forced_hud_visibility)

            -- unfading
            assert.is_false(self.is_forced_unfading)

            -- other
            assert.is_equal(playervisiontools, playervisiontools.playertools.vision)
        end

        describe("using the constructor", function()
            before_each(function()
                playervisiontools = PlayerVisionTools(playertools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playervisiontools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "GetPlayerVisionCCT",
                "UpdatePlayerVisionCCT",

                -- forced HUD visibility
                "IsForcedHUDVisibility",
                "ToggleForcedHUDVisibility",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playervisiontools = PlayerVisionTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playervisiontools, devtools)
        end)
    end)

    describe("general", function()
        local playervision

        before_each(function()
            playervision = playervisiontools.inst.components.playervision
            playervision.inst = playervisiontools.inst
        end)

        describe("GetPlayerVisionCCT", function()
            local GetCCTable

            describe("when the colour cubes table is available", function()
                before_each(function()
                    GetCCTable = spy.new(ReturnValueFn({}))
                    playervision.GetCCTable = GetCCTable
                end)

                it("should call the PlayerVision:GetCCTable()", function()
                    assert.spy(GetCCTable).was_not_called()
                    playervisiontools:GetPlayerVisionCCT()
                    assert.spy(GetCCTable).was_called(1)
                    assert.spy(GetCCTable).was_called_with(match.is_ref(playervision))
                end)

                it("should return the colour cubes table", function()
                    assert.is_equal(0, #playervisiontools:GetPlayerVisionCCT())
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(playervisiontools:GetPlayerVisionCCT())
                    end, playervisiontools, "inst", "components", "playervision", "GetCCTable")
                end)
            end)
        end)

        describe("GetPlayerVisionCCT", function()
            describe("when the colour cubes table is available", function()
                before_each(function()
                    playervision.currentcctable = NIGHTVISION_COLOUR_CUBES
                end)

                it("should return the colour cubes table", function()
                    assert.is_equal(
                        NIGHTVISION_COLOUR_CUBES,
                        playervisiontools:GetPlayerVisionCCT()
                    )
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(
                        function()
                            assert.is_nil(playervisiontools:GetPlayerVisionCCT())
                        end,
                        playervisiontools,
                        "inst",
                        "components",
                        "playervision",
                        "currentcctable"
                    )
                end)
            end)
        end)

        describe("UpdatePlayerVisionCCT", function()
            local PushEvent

            describe("when the colour cubes table is passed", function()
                before_each(function()
                    PushEvent = playervision.inst.PushEvent
                end)

                it("should call the PushEvent()", function()
                    assert.spy(PushEvent).was_not_called()
                    playervisiontools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES)
                    assert.spy(PushEvent).was_called(1)
                    assert.spy(PushEvent).was_called_with(
                        match.is_ref(playervision.inst),
                        "ccoverrides",
                        NIGHTVISION_COLOUR_CUBES
                    )
                end)

                it("should return true", function()
                    assert.is_true(
                        playervisiontools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES)
                    )
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_false(
                            playervisiontools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES)
                        )
                    end, playervisiontools, "inst", "components", "playervision")
                end)
            end)
        end)
    end)
end)
