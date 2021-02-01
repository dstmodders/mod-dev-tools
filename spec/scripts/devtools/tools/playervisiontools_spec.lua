require "busted.runner"()

describe("PlayerVisionTools", function()
    -- before_each initialization
    local devtools, playertools
    local PlayerVisionTools, playervisiontools

    setup(function()
        DebugSpyInit()
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
                -- forced HUD visibility
                "IsForcedHUDVisibility",
                "ToggleForcedHUDVisibility",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playervisiontools = PlayerVisionTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playervisiontools, devtools)
        end)
    end)
end)
