----
-- Player crafting tools.
--
-- Extends `devtools.DevTools` and includes different crafting functionality some of which can be
-- accessed from the "Character Recipes..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.crafting
--
-- @classmod devtools.player.CraftingDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.PlayerDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0-alpha
----
require "class"

local DevTools = require "devtools/devtools/devtools"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam devtools.PlayerDevTools playerdevtools
-- @tparam DevTools devtools
-- @usage local craftingdevtools = CraftingDevTools(playerdevtools, devtools)
local CraftingDevTools = Class(DevTools, function(self, playerdevtools, devtools)
    DevTools._ctor(self, "CraftingDevTools", devtools)

    -- asserts
    Utils.AssertRequiredField(self.name .. ".playerdevtools", playerdevtools)
    Utils.AssertRequiredField(self.name .. ".console", playerdevtools.console)
    Utils.AssertRequiredField(self.name .. ".inst", playerdevtools.inst)
    Utils.AssertRequiredField(self.name .. ".inventory", playerdevtools.inventory)
    Utils.AssertRequiredField(self.name .. ".ismastersim", playerdevtools.ismastersim)

    -- general
    self.character_recipes = {}
    self.consoledevtools = playerdevtools.console
    self.inst = playerdevtools.inst
    self.inventory = playerdevtools.inventory
    self.ismastersim = playerdevtools.ismastersim
    self.playerdevtools = playerdevtools

    -- selection
    self.selected_recipe = nil

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Starts the buffered build placement.
-- @tparam table recipe
function CraftingDevTools:BufferBuildPlacer(recipe)
    if recipe and recipe.rpc_id then
        SendRPCToServer(RPC.BufferBuild, recipe.rpc_id)
        self.playerdevtools.controller:StartBuildPlacementMode(recipe)
    end
end

--- Makes a recipe from menu.
-- @tparam table recipe Recipe
-- @tparam[opt] number idx Skin index
function CraftingDevTools:MakeRecipeFromMenu(recipe, idx) -- luacheck: only
    if recipe and recipe.rpc_id then
        SendRPCToServer(RPC.MakeRecipeFromMenu, recipe.rpc_id, idx)
    end
end

--- Gets character-specific recipes.
--
-- Returns only recipes that only some characters can craft/build.
--
-- @treturn table Recipes
function CraftingDevTools:GetCharacterRecipes()
    if not self.inst
        or not self.inst.player_classified
        or not self.inst.player_classified.recipes
    then
        return
    end

    local recipes = {}

    for recipe, data in pairs(AllRecipes) do
        if data.builder_tag then
            table.insert(recipes, recipe)
        end
    end

    return recipes
end

--- Gets learned recipes.
--
-- **NB!** Free crafting doesn't affect this as it contains only recipes that were learned when it
-- was disabled.
--
-- @treturn table Recipes
function CraftingDevTools:GetLearnedRecipes()
    if not self.inst then
        return
    end

    if self.ismastersim then
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

--- Gets only learned recipes.
--
-- @tparam table recipes Recipes
-- @treturn table Learned recipes
function CraftingDevTools:GetLearnedForRecipes(recipes)
    local result = {}
    for _, v in pairs(recipes) do
        if self:IsRecipeLearned(v) then
            table.insert(result, v)
        end
    end
    return result
end

--- Gets names for provided recipes.
--
-- @tparam table recipes Recipes
-- @tparam[opt] boolean sort Sort alphabetically
-- @treturn table Names
-- @treturn table Recipes
function CraftingDevTools:GetNamesForRecipes(recipes, sort) -- luacheck: only
    recipes = sort and Utils.Table.SortAlphabetically(recipes) or recipes

    local result = {}
    local recipe

    for _, v in pairs(recipes) do
        recipe = GetValidRecipe(v)
        if recipe and recipe.name then
            table.insert(result, Utils.Constant.GetStringName(recipe.name))
        end
    end

    return result, recipes
end

--- Gets only placers for recipes.
--
-- Returns only recipes for buildings and not for items.
--
-- @tparam table recipes Recipes
-- @treturn table Placers
function CraftingDevTools:GetPlacersForRecipes(recipes) -- luacheck: only
    if type(recipes) ~= "table" then
        return
    end

    local result = {}
    local recipe

    for _, v in pairs(recipes) do
        recipe = GetValidRecipe(v)
        if recipe and recipe.placer then
            table.insert(result, v)
        end
    end

    return result
end

--- Gets only non-placers for recipes.
--
-- Returns only recipes for items and not for buildings.
--
-- @tparam table recipes Recipes
-- @treturn table Placers
function CraftingDevTools:GetNonPlacersForRecipes(recipes) -- luacheck: only
    if type(recipes) ~= "table" then
        return
    end

    local result = {}
    local recipe

    for _, v in pairs(recipes) do
        recipe = GetValidRecipe(v)
        if recipe and not recipe.placer then
            table.insert(result, v)
        end
    end

    return result
end

--- Checks if a recipe is learned.
--
-- The learned recipes are retrieved using the `GetLearnedRecipes`.
--
-- **NB!** Free crafting doesn't affect this so it should be handled separately.
--
-- @tparam string name Item name
-- @treturn boolean
function CraftingDevTools:IsRecipeLearned(name)
    local recipes = self:GetLearnedRecipes()
    if type(recipes) == "table" and #recipes > 0 then
        return Utils.Table.HasValue(recipes, name)
    end
end

--- Checks if an item can be crafted.
--
-- Verifies if an owner has enough ingredients to craft an item by checking the inventory.
--
-- **NB!** Free crafting doesn't affect this so it should be handled separately.
--
-- @tparam string name Item name
-- @treturn boolean
function CraftingDevTools:CanCraftItem(name)
    if type(name) ~= "string" or not GetValidRecipe(name) then
        return false
    end

    local recipe = GetValidRecipe(name)
    local inventory = self.inventory:GetInventory()
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
function CraftingDevTools:GetSelectedRecipe()
    return self.selected_recipe
end

--- Sets selected recipe.
-- @tparam table recipe
function CraftingDevTools:SetSelectedRecipe(recipe)
    self.selected_recipe = recipe
end

--- Free Crafting
-- @section free-crafting

--- Unlocks all character-specific recipes.
--
-- It stores the originally learned recipes in order to restore them when using the corresponding
-- `LockCharacterRecipes` method and then unlocks all character-specific recipes.
function CraftingDevTools:UnlockCharacterRecipes()
    if #self.character_recipes == 0 then
        local recipes = self:GetCharacterRecipes()
        local learned = self:GetLearnedForRecipes(recipes)

        if #self.character_recipes == 0 and type(learned) == "table" then
            self:DebugString("Storing", #learned, "learned character recipes...")
            self.character_recipes = learned
        end

        if type(recipes) == "table" and #recipes > 0 then
            self:DebugString("Unlocking character recipes...")
            for _, recipe in pairs(recipes) do
                self.consoledevtools:UnlockRecipe(recipe, self.inst)
            end
        end
    else
        self:DebugString(
            "Already",
            #self.character_recipes,
            (#self.character_recipes > 1 or #self.character_recipes == 0)
                and "recipes are stored."
                or "recipe is stored.",
            "Use CraftingDevTools:LockCharacterRecipes() before unlocking"
        )
    end
end

--- Locks all character-specific recipes.
--
-- It locks all character-specific recipes except those stored earlier by the
-- `UnlockCharacterRecipes` method.
function CraftingDevTools:LockCharacterRecipes()
    local recipes = self:GetCharacterRecipes()

    self:DebugString("Locking and restoring character recipes...")
    if type(recipes) == "table" and #recipes > 0 then
        for _, recipe in pairs(recipes) do
            if not Utils.Table.HasValue(self.character_recipes, recipe) then
                self.consoledevtools:LockRecipe(recipe, self.inst)
            end
        end
        self.character_recipes = {}
    end
end

--- Returns free crafting status.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function CraftingDevTools:IsFreeCrafting(player)
    player = player == nil and self.playerdevtools:GetSelected() or player
    if player and player.player_classified and player.player_classified.isfreebuildmode then
        return player.player_classified.isfreebuildmode:value()
    end
end

--- Toggles free crafting mode.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function CraftingDevTools:ToggleFreeCrafting(player)
    player = player == nil and self.playerdevtools:GetSelected() or player
    if player and self:IsFreeCrafting(player) ~= nil then
        if self.playerdevtools:IsOwner(player) then
            if not self:IsFreeCrafting(player) then
                self:UnlockCharacterRecipes()
            else
                self:LockCharacterRecipes()
            end
        end

        self.consoledevtools:ToggleFreeCrafting(player)

        local is_free_crafting = self:IsFreeCrafting(player)
        self:DebugSelectedPlayerString(
            "Free Crafting is",
            (is_free_crafting and "enabled" or "disabled")
        )

        return is_free_crafting
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function CraftingDevTools:DoInit()
    DevTools.DoInit(self, self.playerdevtools, "crafting", {
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
    })
end

return CraftingDevTools
