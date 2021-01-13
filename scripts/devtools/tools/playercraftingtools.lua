----
-- Player crafting tools.
--
-- Extends `tools.Tools` and includes different crafting functionality some of which can be accessed
-- from the "Character Recipes..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.crafting
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod tools.PlayerCraftingTools
-- @see DevTools
-- @see tools.PlayerTools
-- @see tools.Tools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local DevTools = require "devtools/tools/tools"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam PlayerTools playertools
-- @tparam DevTools devtools
-- @usage local playercraftingtools = PlayerCraftingTools(playertools, devtools)
local PlayerCraftingTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerCraftingTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)
    SDK.Utils.AssertRequiredField(self.name .. ".inventory", playertools.inventory)

    -- general
    self.character_recipes = {}
    self.inst = playertools.inst
    self.inventory = playertools.inventory
    self.playertools = playertools

    -- selection
    self.selected_recipe = nil

    -- other
    self:DoInit()
end)

--- General
-- @section general

--- Starts the buffered build placement.
-- @tparam table recipe
function PlayerCraftingTools:BufferBuildPlacer(recipe)
    if recipe and recipe.rpc_id then
        SendRPCToServer(RPC.BufferBuild, recipe.rpc_id)
        self.playertools.controller:StartBuildPlacementMode(recipe)
    end
end

--- Makes a recipe from menu.
-- @tparam table recipe Recipe
-- @tparam[opt] number idx Skin index
function PlayerCraftingTools:MakeRecipeFromMenu(recipe, idx) -- luacheck: only
    if recipe and recipe.rpc_id then
        SendRPCToServer(RPC.MakeRecipeFromMenu, recipe.rpc_id, idx)
    end
end

--- Gets learned recipes.
--
-- **NB!** Free crafting doesn't affect this as it contains only recipes that were learned when it
-- was disabled.
--
-- @treturn table Recipes
function PlayerCraftingTools:GetLearnedRecipes()
    if not self.inst then
        return
    end

    if SDK.World.IsMasterSim() then
        if self.inst.components
            and self.inst.components.builder
            and self.inst.components.builder.recipes
        then
            return self.inst.components.builder.recipes
        end
    else
        if self.inst.replica.builder
            and self.inst.replica.builder.classified
            and self.inst.replica.builder.classified.recipes
        then
            local result = {}
            local recipe
            local recipes = self.inst.replica.builder.classified.recipes
            for name, v in pairs(recipes) do
                if v:value() then
                    recipe = GetValidRecipe(name)
                    if recipe then
                        table.insert(result, name)
                    end
                end
            end
            return result
        end
    end
end

--- Gets names for provided recipes.
--
-- @tparam table recipes Recipes
-- @tparam[opt] boolean sort Sort alphabetically
-- @treturn table Names
-- @treturn table Recipes
function PlayerCraftingTools:GetNamesForRecipes(recipes, sort) -- luacheck: only
    recipes = sort and SDK.Utils.Table.SortAlphabetically(recipes) or recipes

    local result = {}
    local recipe

    for _, v in pairs(recipes) do
        recipe = GetValidRecipe(v)
        if recipe and recipe.name then
            table.insert(result, SDK.Constant.GetStringName(recipe.name))
        end
    end

    return result, recipes
end

--- Checks if an item can be crafted.
--
-- Verifies if an owner has enough ingredients to craft an item by checking the inventory.
--
-- **NB!** Free crafting doesn't affect this so it should be handled separately.
--
-- @tparam string name Item name
-- @treturn boolean
function PlayerCraftingTools:CanCraftItem(name) -- luacheck: only
    if type(name) ~= "string" or not GetValidRecipe(name) then
        return false
    end

    local recipe = GetValidRecipe(name)
    local inventory = SDK.Player.Inventory.GetInventory()
    if inventory and recipe then
        for _, ingredient in pairs(recipe.ingredients) do
            if not inventory:Has(ingredient.type, ingredient.amount) then
                return false
            end
        end

        return true
    end

    return false
end

--- Selection
-- @section selection

--- Gets selected recipe.
-- @treturn table
function PlayerCraftingTools:GetSelectedRecipe()
    return self.selected_recipe
end

--- Sets selected recipe.
-- @tparam table recipe
function PlayerCraftingTools:SetSelectedRecipe(recipe)
    self.selected_recipe = recipe
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerCraftingTools:DoInit()
    DevTools.DoInit(self, self.playertools, "crafting", {
        -- general
        "BufferBuildPlacer",
        "MakeRecipeFromMenu",
        "GetLearnedRecipes",
        "GetNamesForRecipes",
        "CanCraftItem",

        -- selection
        "GetSelectedRecipe",
        "SetSelectedRecipe",
    })
end

return PlayerCraftingTools
