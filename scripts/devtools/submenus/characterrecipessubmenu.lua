----
-- Character recipes submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.CharacterRecipesSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu"
local Utils = require "devtools/utils"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local characterrecipessubmenu = CharacterRecipesSubmenu(devtools, root)
local CharacterRecipesSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Character Recipes", "CharacterRecipesSubmenu")

    -- options
    if self.devtools and self.crafting and devtools.screen then
        local recipes = self.crafting:GetCharacterRecipes()
        local learned = self.crafting:GetLearnedForRecipes(recipes)
        if learned and #learned > 0 then
            self:AddOptions()
            self:AddToRoot()
        end
    end
end)

--- Helpers
-- @section helpers

local function AddRecipeOption(self, label, item)
    local recipe
    self:AddActionOption({
        label = label,
        on_accept_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:MakeRecipeFromMenu(recipe)
            end
            self:UpdateScreen("recipe")
        end,
        on_cursor_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:SetSelectedRecipe(recipe)
                self:UpdateScreen("recipe")
            end
        end,
    })
end

local function AddRecipeSkinsOption(self, label, item, skins)
    local skin_name, skin_idx, recipe

    local choices = {}
    for _, skin in pairs(skins) do
        skin_name = Utils.Constant.GetStringSkinName(skin)
        skin_idx = Utils.Constant.GetSkinIndex(item, skin)
        table.insert(choices, {
            name = skin_name and skin_name or "Classic",
            value = skin_idx and skin_idx or 0
        })
    end

    self:AddChoicesOption({
        label = label,
        choices = choices,
        on_accept_fn = function()
            self:UpdateScreen("recipe")
        end,
        on_cursor_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:SetSelectedRecipe(recipe)
                self:UpdateScreen("recipe")
            end
        end,
        on_set_fn = function(_, _, value)
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:MakeRecipeFromMenu(recipe, value)
            end
        end,
    })
end

local function AddPlacerOption(self, label, placer)
    local recipe
    self:AddActionOption({
        label = label,
        on_accept_fn = function()
            recipe = GetValidRecipe(placer)
            if recipe then
                self.crafting:BufferBuildPlacer(recipe)
            end
            self.screen:Close()
        end,
    })
end

--- General
-- @section general

--- Adds options.
function CharacterRecipesSubmenu:AddOptions()
    local names, name, items, item, placers, placer, skins

    local crafting = self.crafting
    local recipes = crafting:GetCharacterRecipes()
    local learned = crafting:GetLearnedForRecipes(recipes)

    items = crafting:GetNonPlacersForRecipes(learned)
    if type(items) == "table" and #items > 0 then
        names, items = crafting:GetNamesForRecipes(items, true)
        for i = 1, #names, 1 do
            name = names[i]
            item = items[i]
            skins = Profile and Profile:GetSkinsForPrefab(item)
            if skins and #skins > 1 then
                AddRecipeSkinsOption(self, name, item, skins)
            else
                AddRecipeOption(self, name, item)
            end
        end
    end

    placers = crafting:GetPlacersForRecipes(learned)
    if type(placers) == "table" and #placers > 0 then
        self:AddDividerOption()
        names, placers = crafting:GetNamesForRecipes(placers, true)
        for i = 1, #names, 1 do
            name = names[i]
            placer = placers[i]
            AddPlacerOption(self, name, placer)
        end
    end
end

return CharacterRecipesSubmenu
