----
-- Dump submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.DumpSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"
local Utils = require "devtools/utils"

local DumpSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Dump", "DumpSubmenu")

    -- general
    self.player = devtools.player
    self.world = devtools.world

    -- options
    self:AddOptions()
    self:AddToRoot()
end)

--- Helpers
-- @section helpers

local function AddDumpOptions(self, name, object, options)
    object = object ~= nil and object or _G[name]

    local nr_of_components =#Utils.GetComponents(object)
    local nr_of_event_listeners = #Utils.GetEventListeners(object)
    local nr_of_fields = #Utils.GetFields(object)
    local nr_of_functions = #Utils.GetFunctions(object)

    if nr_of_components > 0 then
        self:AddDoActionOption({
            label = "Components",
            on_accept_fn = function()
                Utils.DumpComponents(object, name)
            end,
        }, options)
    end

    if nr_of_event_listeners > 0 then
        self:AddDoActionOption({
            label = "Event Listeners",
            on_accept_fn = function()
                Utils.DumpEventListeners(object, name)
            end,
        }, options)
    end

    if nr_of_fields > 0 then
        self:AddDoActionOption({
            label = "Fields",
            on_accept_fn = function()
                Utils.DumpFields(object, name)
            end,
        }, options)
    end

    if nr_of_functions > 0 then
        self:AddDoActionOption({
            label = "Functions", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                Utils.DumpFunctions(object, name)
            end,
        }, options)
    end

    if nr_of_components > 0
        or nr_of_event_listeners > 0
        or nr_of_fields > 0
        or nr_of_functions > 0
    then
        self:AddDividerOption(options)
    end

    self:AddDoActionOption({
        label = "dumptable", -- those are "Methods" logically, but it's Lua, so who cares
        on_accept_fn = function()
            dumptable(object)
        end,
    }, options)
end

local function AddDumpSubmenu(self, name, object)
    object = object ~= nil and object or _G[name]
    if object then
        local _options = {}
        AddDumpOptions(self, name, object, _options)
        self:AddSubmenuOption({
            label = name,
            options = _options,
        })
    end
end

--- General
-- @section general

--- Adds options.
function DumpSubmenu:AddOptions()
    if self.player then
        local selected_entity = self.world:GetSelectedEntity()
        local player = self.player:GetPlayer()
        if player and selected_entity and player ~= selected_entity then
            AddDumpSubmenu(self, "Selected Entity", selected_entity)
            self:AddDividerOption()
        end
    end

    AddDumpSubmenu(self, "AllRecipes")
    AddDumpSubmenu(self, "Profile")
    AddDumpSubmenu(self, "TheCamera")
    AddDumpSubmenu(self, "TheFrontEnd")
    AddDumpSubmenu(self, "TheSim")
    AddDumpSubmenu(self, "TheNet")

    if self.world then
        self:AddDividerOption()
        AddDumpSubmenu(self, "TheWorld")
        AddDumpSubmenu(self, "TheWorld.Map", TheWorld.Map)
        AddDumpSubmenu(self, "TheWorld.meta", TheWorld.meta)
        AddDumpSubmenu(self, "TheWorld.net", TheWorld.net)
        AddDumpSubmenu(self, "TheWorld.state", TheWorld.state)
        AddDumpSubmenu(self, "TheWorld.topology", TheWorld.topology)
        AddDumpSubmenu(self, "TheWorld.topology.ids", TheWorld.topology.ids)
    end

    if self.player then
        self:AddDividerOption()
        AddDumpSubmenu(self, "ThePlayer", ThePlayer)
        AddDumpSubmenu(self, "ThePlayer.Physics", ThePlayer.Physics)
        AddDumpSubmenu(self, "ThePlayer.player_classified", ThePlayer.player_classified)
    end

    self:AddDividerOption()
    AddDumpSubmenu(self, "DevTools")
end

return DumpSubmenu
