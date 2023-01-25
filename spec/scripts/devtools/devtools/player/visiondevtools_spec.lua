require("busted.runner")()

describe("VisionDevTools", function()
    -- setup
    local match
    local NIGHTVISION_COLOUR_CUBES

    -- before_each initialization
    local devtools, playerdevtools
    local VisionDevTools, visiondevtools

    setup(function()
        -- match
        match = require("luassert.match")

        -- debug
        DebugSpyTerm()
        DebugSpyInit(spy)

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
        playerdevtools = MockPlayerDevTools()
        playerdevtools.vision = nil

        VisionDevTools = require("devtools/devtools/player/visiondevtools")
        visiondevtools = VisionDevTools(playerdevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playerdevtools = MockPlayerDevTools()
            playerdevtools.vision = nil

            -- initialization
            VisionDevTools = require("devtools/devtools/player/visiondevtools")
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("VisionDevTools", self.name)

            -- general
            assert.is_nil(self.cct)
            assert.is_equal(playerdevtools.inst, self.inst)
            assert.is_equal(playerdevtools.inventory, self.inventory)
            assert.is_equal(playerdevtools, self.playerdevtools)

            -- HUD
            assert.is_false(self.is_forced_hud_visibility)

            -- unfading
            assert.is_false(self.is_forced_unfading)

            -- other
            assert.is_equal(visiondevtools, visiondevtools.playerdevtools.vision)
        end

        describe("using the constructor", function()
            before_each(function()
                visiondevtools = VisionDevTools(playerdevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(visiondevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "GetCCT",
                "SetCCT",
                "GetPlayerVisionCCT",
                "UpdatePlayerVisionCCT",

                -- forced HUD visibility
                "IsForcedHUDVisibility",
                "ToggleForcedHUDVisibility",

                -- forced unfading
                "IsForcedUnfading",
                "ToggleForcedUnfading",
            }

            AssertAddedMethodsBefore(methods, devtools)
            visiondevtools = VisionDevTools(playerdevtools, devtools)
            AssertAddedMethodsAfter(methods, visiondevtools, devtools)
        end)
    end)

    describe("general", function()
        local playervision

        before_each(function()
            playervision = visiondevtools.inst.components.playervision
            playervision.inst = visiondevtools.inst
        end)

        describe("should have the", function()
            describe("setter", function()
                it("SetCCT", function()
                    AssertSetter(visiondevtools, "cct", "SetCCT")
                end)
            end)

            describe("getter", function()
                it("GetCCT", function()
                    AssertGetter(visiondevtools, "cct", "GetCCT")
                end)
            end)
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
                    visiondevtools:GetPlayerVisionCCT()
                    assert.spy(GetCCTable).was_called(1)
                    assert.spy(GetCCTable).was_called_with(match.is_ref(playervision))
                end)

                it("should return the colour cubes table", function()
                    assert.is_equal(0, #visiondevtools:GetPlayerVisionCCT())
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(visiondevtools:GetPlayerVisionCCT())
                    end, visiondevtools, "inst", "components", "playervision", "GetCCTable")
                end)
            end)
        end)

        describe("GetPlayerVisionCCT", function()
            describe("when the colour cubes table is available", function()
                before_each(function()
                    playervision.currentcctable = NIGHTVISION_COLOUR_CUBES
                end)

                it("should return the colour cubes table", function()
                    assert.is_equal(NIGHTVISION_COLOUR_CUBES, visiondevtools:GetPlayerVisionCCT())
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(visiondevtools:GetPlayerVisionCCT())
                    end, visiondevtools, "inst", "components", "playervision", "currentcctable")
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
                    visiondevtools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES)
                    assert.spy(PushEvent).was_called(1)
                    assert
                        .spy(PushEvent)
                        .was_called_with(match.is_ref(playervision.inst), "ccoverrides", NIGHTVISION_COLOUR_CUBES)
                end)

                it("should return true", function()
                    assert.is_true(visiondevtools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES))
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_false(
                            visiondevtools:UpdatePlayerVisionCCT(NIGHTVISION_COLOUR_CUBES)
                        )
                    end, visiondevtools, "inst", "components", "playervision")
                end)
            end)
        end)
    end)
end)
