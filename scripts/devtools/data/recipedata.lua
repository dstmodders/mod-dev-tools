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
-- @release 0.3.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam devtools.player.InventoryDevTools inventorydevtools
-- @tparam table recipe
-- @usage local recipedata = RecipeData(devtools, inventorydevtools, recipe)
local RecipeData = Class(Data, function(self, devtools, inventorydevtools, recipe)
    Data._ctor(self)

    -- general
    self.devtools = devtools
    self.ingredients_lines_stack = {}
    self.inventorydevtools = inventorydevtools
    self.recipe = recipe
    self.recipe_lines_stack = {}

    -- self
    self:Update()
end)

--- General
-- @section general

--- Clears lines stack.
function RecipeData:Clear()
    self.ingredients_lines_stack = {}
    self.recipe_lines_stack = {}
end

--- Updates lines stack.
function RecipeData:Update()
    self:Clear()
    self:PushRecipeData()
    self:PushIngredientsData()
end

--- Recipe
-- @section recipe

--- Pushes recipe line.
-- @tparam string name
-- @tparam string value
function RecipeData:PushRecipeLine(name, value)
    self:PushLine(self.recipe_lines_stack, name, value)
end

--- Pushes recipe data.
function RecipeData:PushRecipeData()
    Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    local recipe = self.recipe

    self:PushRecipeLine("RPC ID", recipe.rpc_id)

    if recipe.nounlock ~= nil and type(recipe.nounlock) == "boolean" then
        self:PushRecipeLine("Unlockable", tostring(not recipe.nounlock and "yes" or "no"))
    end

    self:PushRecipeLine("Name", recipe.name)

    if recipe.product then
        if recipe.numtogive and recipe.numtogive > 1 then
            self:PushRecipeLine("Product", { recipe.product, recipe.numtogive })
        else
            self:PushRecipeLine("Product", recipe.product)
        end
    end

    self:PushRecipeLine("Placer", recipe.placer)
    self:PushRecipeLine("Builder Tag", recipe.builder_tag)

    if recipe.build_mode then
        local mode = "NONE"
        if recipe.build_mode == BUILDMODE.LAND then
            mode = "LAND"
        elseif recipe.build_mode == BUILDMODE.WATER then
            mode = "WATER"
        end
        self:PushRecipeLine("Build Mode", mode)
    end

    self:PushRecipeLine("Build Distance", recipe.build_distance)
end

--- Ingredients
-- @section ingredients

--- Pushes ingredient line.
-- @tparam string type
-- @tparam number amount
function RecipeData:PushIngredientLine(type, amount)
    local inventory = self.inventorydevtools:GetInventory()
    local name = Utils.Constant.GetStringName(type)

    if inventory then
        local state = inventory:Has(type, amount)
        table.insert(self.ingredients_lines_stack, string.format(
            "x%d %s",
            amount,
            Utils.String.TableSplit({ name, state and "yes" or "no" })
        ))
    else
        table.insert(self.ingredients_lines_stack, string.format("x%d %s", amount, name))
    end
end

--- Pushes ingredients data.
function RecipeData:PushIngredientsData()
    Utils.AssertRequiredField("RecipeData.inventorydevtools", self.inventorydevtools)
    Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    if self.recipe.ingredients then
        for _, ingredient in pairs(self.recipe.ingredients) do
            self:PushIngredientLine(ingredient.type, ingredient.amount)
        end
    end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function RecipeData:__tostring()
    if #self.recipe_lines_stack == 0 then
        return
    end

    local t = {}

    self:TableInsertTitle(t, "Recipe")
    self:TableInsertData(t, self.recipe_lines_stack)
    table.insert(t, "\n")

    if #self.ingredients_lines_stack > 0 then
        self:TableInsertTitle(t, "Ingredients")
        self:TableInsertData(t, self.ingredients_lines_stack)
    end

    return table.concat(t)
end

return RecipeData
