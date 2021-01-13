require "busted.runner"()

describe("PlayerCraftingTools", function()
    -- before_each initialization
    local devtools, playertools
    local PlayerCraftingTools, playercraftingtools

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
        playertools.crafting = nil

        PlayerCraftingTools = require "devtools/tools/playercraftingtools"
        playercraftingtools = PlayerCraftingTools(playertools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()
            playertools = MockPlayerTools()
            playertools.crafting = nil

            -- initialization
            PlayerCraftingTools = require "devtools/tools/playercraftingtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerCraftingTools", self.name)

            -- general
            assert.is_same({}, self.character_recipes)
            assert.is_equal(playertools.inst, self.inst)
            assert.is_equal(playertools.inventory, self.inventory)
            assert.is_equal(playertools, self.playertools)

            -- selection
            assert.is_nil(self.selected_recipe)

            -- other
            assert.is_equal(self, self.playertools.crafting)
        end

        describe("using the constructor", function()
            before_each(function()
                playercraftingtools = PlayerCraftingTools(playertools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playercraftingtools)
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
            }

            AssertAddedMethodsBefore(methods, devtools)
            playercraftingtools = PlayerCraftingTools(playertools, devtools)
            AssertAddedMethodsAfter(methods, playercraftingtools, devtools)
        end)
    end)

    describe("selection", function()
        describe("should have the", function()
            describe("setter", function()
                it("SetSelectedRecipe", function()
                    AssertClassSetter(playercraftingtools, "selected_recipe", "SetSelectedRecipe")
                end)
            end)

            describe("getter", function()
                it("GetSelectedRecipe", function()
                    AssertClassGetter(playercraftingtools, "selected_recipe", "GetSelectedRecipe")
                end)
            end)
        end)
    end)
end)
