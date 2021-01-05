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
-- @release 0.7.0
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
    SDK.Utils.AssertRequiredField(self.name .. ".console", playertools.console)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)
    SDK.Utils.AssertRequiredField(self.name .. ".inventory", playertools.inventory)

    -- general
    self.character_recipes = {}
    self.playerconsoletools = playertools.console
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

--- Gets character-specific recipes.
--
-- Returns only recipes that only some characters can craft/build.
--
-- @treturn table Recipes
function PlayerCraftingTools:GetCharacterRecipes()
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

--- Gets only learned recipes.
--
-- @tparam table recipes Recipes
-- @treturn table Learned recipes
function PlayerCraftingTools:GetLearnedForRecipes(recipes)
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

--- Gets only placers for recipes.
--
-- Returns only recipes for buildings and not for items.
--
-- @tparam table recipes Recipes
-- @treturn table Placers
function PlayerCraftingTools:GetPlacersForRecipes(recipes) -- luacheck: only
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
function PlayerCraftingTools:GetNonPlacersForRecipes(recipes) -- luacheck: only
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
function PlayerCraftingTools:IsRecipeLearned(name)
    local recipes = self:GetLearnedRecipes()
    if type(recipes) == "table" and #recipes > 0 then
        return SDK.Utils.Table.HasValue(recipes, name)
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
function PlayerCraftingTools:CanCraftItem(name) -- luacheck: only
    if type(name) ~= "string" or not GetValidRecipe(name) then
        return false
    end

    local recipe = GetValidRecipe(name)
    local inventory = SDK.Inventory.GetInventory()
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

--- Free Crafting
-- @section free-crafting

--- Unlocks all character-specific recipes.
--
-- It stores the originally learned recipes in order to restore them when using the corresponding
-- `LockCharacterRecipes` method and then unlocks all character-specific recipes.
function PlayerCraftingTools:UnlockCharacterRecipes()
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
                SDK.Remote.Player.UnlockRecipe(recipe, self.inst)
            end
        end
    else
        self:DebugString(
            "Already",
            #self.character_recipes,
            (#self.character_recipes > 1 or #self.character_recipes == 0)
                and "recipes are stored."
                or "recipe is stored.",
            "Use PlayerCraftingTools:LockCharacterRecipes() before unlocking"
        )
    end
end

--- Locks all character-specific recipes.
--
-- It locks all character-specific recipes except those stored earlier by the
-- `UnlockCharacterRecipes` method.
function PlayerCraftingTools:LockCharacterRecipes()
    local recipes = self:GetCharacterRecipes()

    self:DebugString("Locking and restoring character recipes...")
    if type(recipes) == "table" and #recipes > 0 then
        for _, recipe in pairs(recipes) do
            if not SDK.Utils.Table.HasValue(self.character_recipes, recipe) then
                SDK.Remote.Player.LockRecipe(recipe, self.inst)
            end
        end
        self.character_recipes = {}
    end
end

--- Returns free crafting status.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function PlayerCraftingTools:IsFreeCrafting(player)
    player = player == nil and self.playertools:GetSelected() or player
    if player and player.player_classified and player.player_classified.isfreebuildmode then
        return player.player_classified.isfreebuildmode:value()
    end
end

--- Toggles free crafting mode.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function PlayerCraftingTools:ToggleFreeCrafting(player)
    player = player == nil and self.playertools:GetSelected() or player
    if player and self:IsFreeCrafting(player) ~= nil then
        if SDK.Player.IsOwner(player) then
            if not self:IsFreeCrafting(player) then
                self:UnlockCharacterRecipes()
            else
                self:LockCharacterRecipes()
            end
        end

        SDK.Remote.Player.ToggleFreeCrafting(player)

        local is_free_crafting = self:IsFreeCrafting(player)
        self:DebugString(
            player and "(" .. player:GetDisplayName() .. ")",
            "Free Crafting is",
            (is_free_crafting and "enabled" or "disabled")
        )

        return is_free_crafting
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerCraftingTools:DoInit()
    DevTools.DoInit(self, self.playertools, "crafting", {
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

return PlayerCraftingTools
