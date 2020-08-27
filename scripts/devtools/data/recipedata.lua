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
-- @release 0.1.0-alpha
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

local function PushRecipeLine(self, name, value)
    self:PushLine(self.recipe_lines_stack, name, value)
end

--- Pushes recipe data.
function RecipeData:PushRecipeData()
    Utils.AssertRequiredField("RecipeData.devtools", self.devtools)
    Utils.AssertRequiredField("RecipeData.recipe", self.recipe)

    local recipe = self.recipe

    PushRecipeLine(self, "RPC ID", recipe.rpc_id)

    if recipe.nounlock ~= nil and type(recipe.nounlock) == "boolean" then
        PushRecipeLine(self, "Unlockable", tostring(not recipe.nounlock and "yes" or "no"))
    end

    PushRecipeLine(self, "Name", recipe.name)

    if recipe.product then
        if recipe.numtogive and recipe.numtogive > 1 then
            PushRecipeLine(self, "Product", { recipe.product, recipe.numtogive })
        else
            PushRecipeLine(self, "Product", recipe.product)
        end
    end

    PushRecipeLine(self, "Placer", recipe.placer)
    PushRecipeLine(self, "Builder Tag", recipe.builder_tag)

    if recipe.build_mode then
        local mode = "NONE"
        if recipe.build_mode == BUILDMODE.LAND then
            mode = "LAND"
        elseif recipe.build_mode == BUILDMODE.WATER then
            mode = "WATER"
        end
        PushRecipeLine(self, "Build Mode", mode)
    end

    PushRecipeLine(self, "Build Distance", recipe.build_distance)
end

--- Ingredients
-- @section ingredients

local function PushIngredientLine(self, type, amount)
    local inventory = self.inventorydevtools:GetInventory()
    local name = Utils.GetStringName(type)

    if inventory then
        local state = inventory:Has(type, amount)
        table.insert(self.ingredients_lines_stack, string.format(
            "x%d %s",
            amount,
            self:ToValueSplit({ name, state and "yes" or "no" })
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
            PushIngredientLine(self, ingredient.type, ingredient.amount)
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
