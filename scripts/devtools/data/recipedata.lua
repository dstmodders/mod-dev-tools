----
-- Recipe data.
--
-- Includes recipe data in data sidebar.
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod data.RecipeData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local Data = require "devtools/data/data"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevToolsScreen screen
-- @tparam DevTools devtools
-- @usage local recipedata = RecipeData(screen, devtools)
local RecipeData = Class(Data, function(self, screen, devtools)
    Data._ctor(self, screen)

    -- general
    self.devtools = devtools
    self.playerinventorytools = devtools.player.inventory
    self.recipe = SDK.TemporaryData.Get("selected_recipe")

    -- other
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function RecipeData:Update()
    Data.Update(self)

    self:PushTitleLine("Recipe")
    self:PushEmptyLine()
    self:PushRecipeData()

    if self.recipe.ingredients then
        self:PushEmptyLine()
        self:PushTitleLine("Ingredients")
        self:PushEmptyLine()
        self:PushIngredientsData()
    end
end

--- Pushes ingredient line.
-- @tparam string type
-- @tparam number amount
function RecipeData:PushIngredientLine(type, amount)
    local inventory = SDK.Player.Inventory.GetInventory()
    local name = SDK.Constant.GetStringName(type)

    if inventory then
        local state = inventory:Has(type, amount)
        table.insert(self.stack, string.format("x%d %s", amount, table.concat({
            name,
            state and "yes" or "no",
        }, " | ")))
    else
        table.insert(self.stack, string.format("x%d %s", amount, name))
    end
end

--- Pushes recipe data.
function RecipeData:PushRecipeData()
    SDK.Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    SDK.Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    local recipe = self.recipe

    self:PushLine("RPC ID", recipe.rpc_id)

    if recipe.nounlock ~= nil and type(recipe.nounlock) == "boolean" then
        self:PushLine("Unlockable", tostring(not recipe.nounlock and "yes" or "no"))
    end

    self:PushLine("Name", recipe.name)

    if recipe.product then
        if recipe.numtogive and recipe.numtogive > 1 then
            self:PushLine("Product", { recipe.product, recipe.numtogive })
        else
            self:PushLine("Product", recipe.product)
        end
    end

    self:PushLine("Placer", recipe.placer)
    self:PushLine("Builder Tag", recipe.builder_tag)

    if recipe.build_mode then
        local mode = "NONE"
        if recipe.build_mode == BUILDMODE.LAND then
            mode = "LAND"
        elseif recipe.build_mode == BUILDMODE.WATER then
            mode = "WATER"
        end
        self:PushLine("Build Mode", mode)
    end

    self:PushLine("Build Distance", recipe.build_distance)
end

--- Pushes ingredients data.
function RecipeData:PushIngredientsData()
    SDK.Utils.AssertRequiredField("RecipeData.playerinventorytools", self.playerinventorytools)
    SDK.Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    SDK.Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    for _, ingredient in pairs(self.recipe.ingredients) do
        self:PushIngredientLine(ingredient.type, ingredient.amount)
    end
end

return RecipeData
