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
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod tools.PlayerCraftingTools
-- @see DevTools
-- @see tools.PlayerTools
-- @see tools.Tools
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local DevTools = require("devtools/tools/tools")
local SDK = require("devtools/sdk/sdk/sdk")

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

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerCraftingTools:DoInit()
    DevTools.DoInit(self, self.playertools, "crafting", {
        -- general
        "BufferBuildPlacer",
        "MakeRecipeFromMenu",
    })
end

return PlayerCraftingTools
