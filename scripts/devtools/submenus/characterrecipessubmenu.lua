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
-- @release 0.7.0
----
local SDK = require "devtools/sdk/sdk/sdk"
local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local characterrecipessubmenu = CharacterRecipesSubmenu(devtools, root)
local CharacterRecipesSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(
        self,
        devtools,
        root,
        "Character Recipes",
        "CharacterRecipesSubmenu",
        MOD_DEV_TOOLS.DATA_SIDEBAR.RECIPE
    )

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

--- General
-- @section general

--- Adds recipe option.
-- @tparam table|string label
-- @tparam table item
function CharacterRecipesSubmenu:AddRecipeOption(label, item)
    local recipe
    self:AddActionOption({
        label = label,
        on_accept_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:MakeRecipeFromMenu(recipe)
            end
            self:UpdateScreen()
        end,
        on_cursor_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:SetSelectedRecipe(recipe)
                self:UpdateScreen()
            end
        end,
    })
end

--- Adds recipe with skins option.
-- @tparam table|string label
-- @tparam table item
-- @tparam table skins
function CharacterRecipesSubmenu:AddRecipeSkinsOption(label, item, skins)
    local skin_name, skin_idx, recipe

    local choices = {}
    for _, skin in pairs(skins) do
        skin_name = SDK.Constant.GetStringSkinName(skin)
        skin_idx = SDK.Constant.GetSkinIndex(item, skin)
        table.insert(choices, {
            name = skin_name and skin_name or "Classic",
            value = skin_idx and skin_idx or 0
        })
    end

    self:AddChoicesOption({
        label = label,
        choices = choices,
        on_accept_fn = function()
            self:UpdateScreen()
        end,
        on_cursor_fn = function()
            recipe = GetValidRecipe(item)
            if recipe then
                self.crafting:SetSelectedRecipe(recipe)
                self:UpdateScreen()
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

--- Adds placer option.
-- @tparam table|string label
-- @tparam table placer
function CharacterRecipesSubmenu:AddPlacerOption(label, placer)
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
                self:AddRecipeSkinsOption(name, item, skins)
            else
                self:AddRecipeOption(name, item)
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
            self:AddPlacerOption(name, placer)
        end
    end
end

return CharacterRecipesSubmenu
