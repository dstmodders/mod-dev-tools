----
-- Recipe data.
--
-- Includes recipe data functionality which aim is to display some info about a recipe.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.RecipeData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.4.0
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @tparam DevTools devtools
-- @usage local recipedata = RecipeData(screen, devtools)
local RecipeData = Class(Data, function(self, screen, devtools)
    Data._ctor(self, screen)

    -- general
    self.devtools = devtools
    self.inventorydevtools = devtools.player.inventory
    self.recipe = devtools.player.crafting:GetSelectedRecipe()

    -- self
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
    local inventory = self.inventorydevtools:GetInventory()
    local name = Utils.Constant.GetStringName(type)

    if inventory then
        local state = inventory:Has(type, amount)
        table.insert(self.stack, string.format(
            "x%d %s",
            amount,
            Utils.String.TableSplit({ name, state and "yes" or "no" })
        ))
    else
        table.insert(self.stack, string.format("x%d %s", amount, name))
    end
end

--- Pushes recipe data.
function RecipeData:PushRecipeData()
    Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

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
    Utils.AssertRequiredField("RecipeData.inventorydevtools", self.inventorydevtools)
    Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    for _, ingredient in pairs(self.recipe.ingredients) do
        self:PushIngredientLine(ingredient.type, ingredient.amount)
    end
end

return RecipeData
