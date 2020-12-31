require "busted.runner"()

describe("PlayerInventoryTools", function()
    -- initialization
    local devtools, playertools
    local PlayerInventoryTools, playerinventorytools

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
        playertools.inventory = nil

        PlayerInventoryTools = require "devtools/tools/playerinventorytools"
        playerinventorytools = PlayerInventoryTools(playertools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playertools = MockPlayerTools()
            playertools.inventory = nil

            -- initialization
            PlayerInventoryTools = require "devtools/tools/playerinventorytools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerInventoryTools", self.name)

            -- general
            assert.is_equal(playertools.inst, self.inst)
            assert.is_equal(playertools, self.playertools)

            -- other
            assert.is_equal(self, self.playertools.inventory)
        end

        describe("using the constructor", function()
            before_each(function()
                playerinventorytools = PlayerInventoryTools(playertools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playerinventorytools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "IsEquippableLightSource",
                "GetInventoryEdible",

                -- backpack
                "GetBackpackSlotByItem",

                -- selection
                "SelectEquippedItem",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playerinventorytools = PlayerInventoryTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playerinventorytools, devtools)
        end)

        describe("when the PlayerTools is missing", function()
            before_each(function()
                playertools = nil
            end)

            it("should error", function()
                assert.is_error(function()
                    PlayerInventoryTools(playertools, devtools)
                end, "Required PlayerInventoryTools.playertools is missing")
            end)
        end)

        local asserts = {
            "inst",
        }

        for _, _assert in pairs(asserts) do
            describe("when the PlayerTools." .. _assert .. " is missing", function()
                before_each(function()
                    playertools[_assert] = nil
                end)

                it("should error", function()
                    assert.is_error(function()
                        PlayerInventoryTools(playertools, devtools)
                    end, "Required PlayerInventoryTools." .. _assert .. " is missing")
                end)
            end)
        end
    end)
end)
