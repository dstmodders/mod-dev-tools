----
-- Character recipes submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod submenus.CharacterRecipesSubmenu
-- @see menu.Submenu
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
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
        if SDK.Utils.Table.Count(self:GetRecipes()) > 0 then
            self:AddOptions()
            self:AddToRoot()
        end
    end
end)

--- General
-- @section general

--- Gets recipes.
-- @treturn table
function CharacterRecipesSubmenu:GetRecipes() -- luacheck: only
    local recipes
    recipes = SDK.Player.Craft.FilterRecipesBy(function(_, data)
        return data.builder_tag and data.tab and data.nounlock ~= true
    end)
    recipes = SDK.Player.Craft.FilterRecipesByLearned(recipes)
    return recipes
end

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
                SDK.TemporaryData.Set("selected_recipe", recipe)
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
                SDK.TemporaryData.Set("selected_recipe", recipe)
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
        on_cursor_fn = function()
            recipe = GetValidRecipe(placer)
            if recipe then
                SDK.TemporaryData.Set("selected_recipe", recipe)
                self:UpdateScreen()
            end
        end,
    })
end

--- Adds options.
function CharacterRecipesSubmenu:AddOptions()
    local recipes, keys, keys_names, skins

    recipes = self:GetRecipes()

    local non_placers = SDK.Player.Craft.FilterRecipesWithout("placer", recipes)
    if SDK.Utils.Table.Count(non_placers) > 0 then
        keys = SDK.Utils.Table.Keys(non_placers)
        keys_names = SDK.Constant.AddStringNamesToTable(keys, true)
        for _, key in pairs(keys_names) do
            skins = Profile and Profile:GetSkinsForPrefab(key.value)
            if skins and #skins > 1 then
                self:AddRecipeSkinsOption(key.name, key.value, skins)
            else
                self:AddRecipeOption(key.name, key.value)
            end
        end
    end

    local placers = SDK.Player.Craft.FilterRecipesWith("placer", recipes)
    if SDK.Utils.Table.Count(placers) > 0 then
        self:AddDividerOption()
        keys = SDK.Utils.Table.Keys(placers)
        keys_names = SDK.Constant.AddStringNamesToTable(keys, true)
        for _, key in pairs(keys_names) do
            self:AddPlacerOption(key.name, key.value)
        end
    end
end

return CharacterRecipesSubmenu
