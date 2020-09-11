----
-- Select submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.SelectSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0
----
require "class"

local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local selectsubmenu = SelectSubmenu(devtools, root)
local SelectSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Select", "SelectSubmenu", #root + 1)

    -- options
    if self.devtools and self.world and self.player and self.inventory and self.screen then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- General
-- @section general

--- Appends selected prefix.
-- @tparam table|string label Label
-- @tparam EntityScript entity Entity to match the selected one
-- @tparam EntityScript except Entity to ignore prefix addition
function SelectSubmenu:AppendSelected(label, entity, except)
    local selected = self.world:GetSelectedEntity()
    if entity and selected then
        if entity.GUID == selected.GUID then
            if except then
                if not except.GUID then
                    for _, v in pairs(except) do
                        if v.GUID == entity.GUID then
                            return label
                        end
                    end
                else
                    if entity.GUID == except.GUID then
                        return label
                    end
                end
            end
            return label .. " [selected]"
        end
    end
    return label
end

--- Select
-- @section select

--- Adds select player options.
function SelectSubmenu:AddSelectPlayerOptions()
    for _, v in pairs(self.devtools:GetAllPlayers()) do
        self:AddActionOption({
            label = self:AppendSelected(v:GetDisplayName(), v, self.player:GetSelected()),
            on_accept_fn = function()
                self.player:Select(v)
                self:UpdateScreen("selected")
            end,
        })
    end
end

--- Adds select entity under mouse option.
function SelectSubmenu:AddSelectEntityUnderMouseOption()
    self:AddActionOption({
        label = self:AppendSelected("Entity Under Mouse", self.world:GetSelectedEntity(), {
            self.player:GetSelected(),
            self.world:GetWorld(),
            self.world:GetWorldNet(),
            self.inventory:GetEquippedItem(EQUIPSLOTS.HEAD),
            self.inventory:GetEquippedItem(EQUIPSLOTS.BODY),
            self.inventory:GetEquippedItem(EQUIPSLOTS.HANDS),
        }),
        on_accept_fn = function()
            self.world:SelectEntityUnderMouse()
            self:UpdateScreen("selected")
        end,
    })
end

--- Adds select equipped item option.
-- @tparam number slot
function SelectSubmenu:AddSelectEquippedItem(slot)
    if self.inventory:HasEquippedItem(slot) then
        self:AddActionOption({
            label = self:AppendSelected(
                string.format("Equipped Item (%s)", slot:gsub("^%l", string.upper)),
                self.inventory:GetEquippedItem(slot)
            ),
            on_accept_fn = function()
                self.inventory:SelectEquippedItem(slot)
                self:UpdateScreen("selected")
            end,
        })
    end
end

--- Adds select `TheWorld` option.
function SelectSubmenu:AddSelectWorldOptions()
    self:AddActionOption({
        label = self:AppendSelected("TheWorld", self.world:GetWorld()),
        on_accept_fn = function()
            self.world:Select()
            self:UpdateScreen("selected")
        end,
    })
end

--- Adds select `TheWorld.net` option.
function SelectSubmenu:AddSelectWorldNetOptions()
    self:AddActionOption({
        label = self:AppendSelected("TheWorld.net", self.world:GetWorldNet()),
        on_accept_fn = function()
            self.world:SelectNet()
            self:UpdateScreen("selected")
        end,
    })
end

--- Adds options.
function SelectSubmenu:AddOptions()
    self:AddSelectPlayerOptions()

    self:AddDividerOption()
    self:AddSelectEntityUnderMouseOption()
    self:AddSelectEquippedItem(EQUIPSLOTS.BODY)
    self:AddSelectEquippedItem(EQUIPSLOTS.HANDS)
    self:AddSelectEquippedItem(EQUIPSLOTS.HEAD)

    self:AddDividerOption()
    self:AddSelectWorldOptions()
    self:AddSelectWorldNetOptions()
end

return SelectSubmenu
