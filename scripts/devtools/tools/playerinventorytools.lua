----
-- Player inventory tools.
--
-- Extends `tools.Tools` and includes different inventory functionality.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.inventory
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod tools.PlayerInventoryTools
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
-- @usage local playerinventorytools = PlayerInventoryTools(playertools, devtools)
local PlayerInventoryTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerInventoryTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)

    local inventory = SDK.Utils.Chain.Get(playertools, "inst", "replica", "inventory")
    SDK.Utils.AssertRequiredField(self.name .. ".inventory", inventory)

    -- general
    self.inst = playertools.inst
    self.inventory = inventory
    self.playertools = playertools

    -- other
    self:DoInit()
end)

--- General
-- @section general

--- Checks if an item is a light source.
-- @tparam table item
-- @treturn boolean
function PlayerInventoryTools:IsEquippableLightSource(item) -- luacheck: only
    if not item:HasTag("_equippable") or item:HasTag("fueldepleted") then
        return false
    end

    return item:HasTag(FUELTYPE.CAVE .. "_fueled")
        or item:HasTag(FUELTYPE.WORMLIGHT .. "_fueled")
        or item:HasTag("light")
        or item:HasTag("lighter")
        or SDK.Utils.Chain.Get(item, "prefab") == "nightstick"
end

--- Gets an edible item from the inventory.
--
-- Returns 2 values: slot and item. The "slot" is an item index in the inventory and the "item" is
-- an item itself.
--
-- @treturn number Slot
-- @treturn table Item
function PlayerInventoryTools:GetInventoryEdible()
    local items = self.inventory:GetItems()
    for slot, item in pairs(items) do
        if item:HasTag("cookable")
            or item:HasTag("edible_MEAT")
            or item:HasTag("edible_VEGGIE")
        then
            return slot, item
        end
    end
end

--- Backpack
-- @section backpack

--- Gets a backpack slot number for an item.
-- @tparam table item
-- @treturn number
function PlayerInventoryTools:GetBackpackSlotByItem(item) -- luacheck: only
    local items = SDK.Inventory.GetEquippedBackpackItems()
    if items and item then
        for k, v in pairs(items) do
            if v == item then
                return k
            end
        end
    end
end

--- Selection
-- @section selection

--- Selects an equipped item.
-- @treturn boolean Always true
function PlayerInventoryTools:SelectEquippedItem(slot)
    local item = SDK.Inventory.GetEquippedItem(slot)
    if item then
        SetDebugEntity(item)
        self.devtools.labels:AddSelected(item)
        self:DebugString("Selected equipped item", "(" .. slot .. ")")
        return true
    end
    return false
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerInventoryTools:DoInit()
    DevTools.DoInit(self, self.playertools, "inventory", {
        -- general
        "IsEquippableLightSource",
        "GetInventoryEdible",

        -- backpack
        "GetBackpackSlotByItem",

        -- selection
        "SelectEquippedItem",
    })
end

return PlayerInventoryTools
