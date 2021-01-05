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
                -- crafting
                "UnlockRecipe",
                "LockRecipe",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playerconsoletools = PlayerConsoleTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playerconsoletools, devtools)
        end)
    end)
end)
