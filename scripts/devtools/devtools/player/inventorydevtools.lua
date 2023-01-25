----
-- Player inventory tools.
--
-- Extends `devtools.DevTools` and includes different inventory functionality.
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
-- @classmod devtools.player.InventoryDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.PlayerDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require "class"

local DevTools = require "devtools/devtools/devtools"
local Utils = require "devtools/utils"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam devtools.PlayerDevTools playerdevtools
-- @tparam DevTools devtools
-- @usage local inventorydevtools = InventoryDevTools(playerdevtools, devtools)
local InventoryDevTools = Class(DevTools, function(self, playerdevtools, devtools)
    DevTools._ctor(self, "InventoryDevTools", devtools)

    -- asserts
    Utils.AssertRequiredField(self.name .. ".playerdevtools", playerdevtools)
    Utils.AssertRequiredField(self.name .. ".ismastersim", playerdevtools.ismastersim)
    Utils.AssertRequiredField(self.name .. ".inst", playerdevtools.inst)

    local inventory = Utils.Chain.Get(playerdevtools, "inst", "replica", "inventory")
    Utils.AssertRequiredField(self.name .. ".inventory", inventory)

    -- general
    self.inst = playerdevtools.inst
    self.inventory = inventory
    self.ismastersim = playerdevtools.ismastersim
    self.playerdevtools = playerdevtools

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Gets inventory.
--
-- Returns an owner's inventory replica.
--
-- @treturn table
function InventoryDevTools:GetInventory()
    return self.inventory
end

--- Gets an equipped item by slot.
-- @tparam string slot `EQUIPSLOTS`
-- @treturn table
function InventoryDevTools:GetEquippedItem(slot)
    return self.inventory:GetEquippedItem(slot)
end

--- Checks if a player has an equipped items.
-- @treturn boolean
function InventoryDevTools:HasEquippedItem(slot)
    return self:GetEquippedItem(slot) and true or false
end

--- Checks if Moggles are equipped.
-- @treturn boolean
function InventoryDevTools:HasEquippedMoggles()
    local item = self:GetEquippedItem(EQUIPSLOTS.HEAD)
    return item and item:HasTag("nightvision")
end

--- Checks if an item is a light source.
-- @tparam table item
-- @treturn boolean
function InventoryDevTools:IsEquippableLightSource(item) -- luacheck: only
    if not item:HasTag("_equippable") or item:HasTag("fueldepleted") then
        return false
    end

    return item:HasTag(FUELTYPE.CAVE .. "_fueled")
        or item:HasTag(FUELTYPE.WORMLIGHT .. "_fueled")
        or item:HasTag("light")
        or item:HasTag("lighter")
        or Utils.Chain.Get(item, "prefab") == "nightstick"
end

--- Gets an edible item from the inventory.
--
-- Returns 2 values: slot and item. The "slot" is an item index in the inventory and the "item" is
-- an item itself.
--
-- @treturn number Slot
-- @treturn table Item
function InventoryDevTools:GetInventoryEdible()
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

--- Equips an active item.
-- @tparam boolean the_net Use `TheNet:SendRPCToServer()` instead of the `SendRPCToServer()`
-- @treturn boolean
function InventoryDevTools:EquipActiveItem(the_net)
    local item = self.inventory:GetActiveItem()
    if not item then
        return false
    end

    local _SendRPCToServer = the_net and function(...)
        return TheNet:SendRPCToServer(...)
    end or SendRPCToServer

    if item:HasTag("_equippable") then
        if Utils.Chain.Get(item, "replica", "equippable", "EquipSlot", true) then
            _SendRPCToServer(RPC.SwapEquipWithActiveItem)
        end
        _SendRPCToServer(RPC.EquipActiveItem)
        return true
    else
        self:DebugError(
            self:GetFnFullName("EquipActiveItem") .. ":",
            "not equippable",
            "(" ..  Utils.Constant.GetStringName(item.prefab) .. ")"
        )
    end

    return false
end

--- Backpack
-- @section backpack

--- Checks if a backpack is equipped.
-- @treturn boolean
function InventoryDevTools:HasEquippedBackpack()
    local item = self:GetEquippedItem(EQUIPSLOTS.BODY)
    return item and item:HasTag("backpack")
end

--- Gets a backpack from an inventory.
-- @treturn table
function InventoryDevTools:GetBackpack()
    local item = self:GetEquippedItem(EQUIPSLOTS.BODY)
    return item and item:HasTag("backpack") and item
end

--- Gets a container from a backpack.
-- @treturn table
function InventoryDevTools:GetBackpackContainer()
    local backpack = self:GetBackpack()
    if not backpack then
        return
    end

    if self.ismastersim then
        return backpack.components and backpack.components.container
    else
        return backpack ~= nil
            and backpack.replica
            and backpack.replica.container ~= nil
            and backpack.replica.container.classified
    end
end

--- Gets items from the backpack container.
-- @treturn table
function InventoryDevTools:GetBackpackItems()
    local container = self:GetBackpackContainer()
    if container then
        return self.ismastersim and container.slots or container:GetItems()
    end
end

--- Gets a backpack slot number for an item.
-- @tparam table item
-- @treturn number
function InventoryDevTools:GetBackpackSlotByItem(item)
    local items = self:GetBackpackItems()
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
function InventoryDevTools:SelectEquippedItem(slot)
    local item = self:GetEquippedItem(slot)
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
function InventoryDevTools:DoInit()
    DevTools.DoInit(self, self.playerdevtools, "inventory", {
        -- general
        "GetInventory",
        "GetEquippedItem",
        "HasEquippedItem",
        "HasEquippedMoggles",
        "IsEquippableLightSource",
        "GetInventoryEdible",
        "EquipActiveItem",

        -- backpack
        "HasEquippedBackpack",
        "GetBackpack",
        "GetBackpackContainer",
        "GetBackpackItems",
        "GetBackpackSlotByItem",

        -- selection
        "SelectEquippedItem",
    })
end

return InventoryDevTools
