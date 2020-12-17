require "busted.runner"()

describe("InventoryDevTools", function()
    -- initialization
    local devtools, playerdevtools
    local InventoryDevTools, inventorydevtools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        devtools = MockDevTools()
        playerdevtools = MockPlayerDevTools()
        playerdevtools.inventory = nil

        InventoryDevTools = require "devtools/devtools/player/inventorydevtools"
        inventorydevtools = InventoryDevTools(playerdevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playerdevtools = MockPlayerDevTools()
            playerdevtools.inventory = nil

            -- initialization
            InventoryDevTools = require "devtools/devtools/player/inventorydevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("InventoryDevTools", self.name)

            -- general
            assert.is_equal(playerdevtools.inst, self.inst)
            assert.is_equal(playerdevtools.ismastersim, self.ismastersim)
            assert.is_equal(playerdevtools, self.playerdevtools)

            -- other
            assert.is_equal(self, self.playerdevtools.inventory)
        end

        describe("using the constructor", function()
            before_each(function()
                inventorydevtools = InventoryDevTools(playerdevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(inventorydevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "GetInventory",
                "GetEquippedItem",
                "HasEquippedItem",
                "HasEquippedMoggles",
                "IsEquippableLightSource",
                "GetInventoryEdible",
                "EquipActiveItem",

                -- backpack
                "HasEquippedBackpack",
                "GetBackpack",
                "GetBackpackContainer",
                "GetBackpackItems",
                "GetBackpackSlotByItem",

                -- selection
                "SelectEquippedItem",
            }

            AssertAddedMethodsBefore(methods, devtools)
            inventorydevtools = InventoryDevTools(playerdevtools, devtools)
            AssertAddedMethodsAfter(methods, inventorydevtools, devtools)
        end)

        describe("when the PlayerDevTools is missing", function()
            before_each(function()
                playerdevtools = nil
            end)

            it("should error", function()
                assert.is_error(function()
                    InventoryDevTools(playerdevtools, devtools)
                end, "Required InventoryDevTools.playerdevtools is missing")
            end)
        end)

        local asserts = {
            "inst",
            "ismastersim",
        }

        for _, _assert in pairs(asserts) do
            describe("when the PlayerDevTools." .. _assert .. " is missing", function()
                before_each(function()
                    playerdevtools[_assert] = nil
                end)

                it("should error", function()
                    assert.is_error(function()
                        InventoryDevTools(playerdevtools, devtools)
                    end, "Required InventoryDevTools." .. _assert .. " is missing")
                end)
            end)
        end
    end)

    describe("general", function()
        local inventory

        describe("GetInventory", function()
            before_each(function()
                inventory = inventorydevtools.inst.replica.inventory
            end)

            it("should return the inventory", function()
                assert.is_equal(inventory, inventorydevtools:GetInventory())
            end)
        end)
    end)
end)
