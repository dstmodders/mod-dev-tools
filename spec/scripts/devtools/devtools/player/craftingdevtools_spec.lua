require "busted.runner"()

describe("CraftingDevTools", function()
    -- before_each initialization
    local devtools, playerdevtools
    local CraftingDevTools, craftingdevtools

    setup(function()
        DebugSpyTerm()
        DebugSpyInit(spy)
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        devtools = MockDevTools(mock)
        playerdevtools = MockPlayerDevTools(mock)
        playerdevtools.crafting = nil

        CraftingDevTools = require "devtools/devtools/player/craftingdevtools"
        craftingdevtools = CraftingDevTools(playerdevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools(mock)
            playerdevtools = MockPlayerDevTools(mock)
            playerdevtools.crafting = nil

            -- initialization
            CraftingDevTools = require "devtools/devtools/player/craftingdevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("CraftingDevTools", self.name)

            -- general
            assert.is_same({}, self.character_recipes)
            assert.is_equal(playerdevtools.console, self.consoledevtools)
            assert.is_equal(playerdevtools.inst, self.inst)
            assert.is_equal(playerdevtools.inventory, self.inventory)
            assert.is_equal(playerdevtools.ismastersim, self.ismastersim)
            assert.is_equal(playerdevtools, self.playerdevtools)

            -- selection
            assert.is_nil(self.selected_recipe)

            -- other
            assert.is_equal(self, self.playerdevtools.crafting)
        end

        describe("using the constructor", function()
            before_each(function()
                craftingdevtools = CraftingDevTools(playerdevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(craftingdevtools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                "BufferBuildPlacer",
                "MakeRecipeFromMenu",
                "GetCharacterRecipes",
                "GetLearnedRecipes",
                "GetLearnedForRecipes",
                "GetNamesForRecipes",
                "GetPlacersForRecipes",
                "GetNonPlacersForRecipes",
                "IsRecipeLearned",
                "CanCraftItem",

                -- selection
                "GetSelectedRecipe",
                "SetSelectedRecipe",

                -- free crafting
                "UnlockCharacterRecipes",
                "LockCharacterRecipes",
                "IsFreeCrafting",
                "ToggleFreeCrafting",
            }

            AssertAddedMethodsBefore(methods, devtools)
            craftingdevtools = CraftingDevTools(playerdevtools, devtools)
            AssertAddedMethodsAfter(methods, craftingdevtools, devtools)
        end)
    end)

    describe("selection", function()
        describe("should have the", function()
            describe("setter", function()
                it("SetSelectedRecipe", function()
                    AssertSetter(craftingdevtools, "selected_recipe", "SetSelectedRecipe")
                end)
            end)

            describe("getter", function()
                it("GetSelectedRecipe", function()
                    AssertGetter(craftingdevtools, "selected_recipe", "GetSelectedRecipe")
                end)
            end)
        end)
    end)
end)
