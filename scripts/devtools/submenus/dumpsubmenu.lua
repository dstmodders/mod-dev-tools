----
-- Dump submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.DumpSubmenu
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
-- @usage local dumpsubmenu = DumpSubmenu(devtools, root)
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
        self:AddActionOption({
            label = "Components",
            on_accept_fn = function()
                Utils.DumpComponents(object, name)
            end,
        }, options)
    end

    if nr_of_event_listeners > 0 then
        self:AddActionOption({
            label = "Event Listeners",
            on_accept_fn = function()
                Utils.DumpEventListeners(object, name)
            end,
        }, options)
    end

    if nr_of_fields > 0 then
        self:AddActionOption({
            label = "Fields",
            on_accept_fn = function()
                Utils.DumpFields(object, name)
            end,
        }, options)
    end

    if nr_of_functions > 0 then
        self:AddActionOption({
            label = "Functions", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                Utils.DumpFunctions(object, name)
            end,
        }, options)
    end

    if type(object) == "table" then
        if nr_of_components > 0
            or nr_of_event_listeners > 0
            or nr_of_fields > 0
            or nr_of_functions > 0
        then
            self:AddDividerOption(options)
        end

        self:AddActionOption({
            label = "dumptable", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                dumptable(object)
            end,
        }, options)
    end
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

    if self.world then
        AddDumpSubmenu(self, "TheWorld")
        AddDumpSubmenu(self, "TheWorld.Map", TheWorld.Map)
        AddDumpSubmenu(self, "TheWorld.meta", TheWorld.meta)
        AddDumpSubmenu(self, "TheWorld.net", TheWorld.net)
        AddDumpSubmenu(self, "TheWorld.state", TheWorld.state)
        AddDumpSubmenu(self, "TheWorld.topology", TheWorld.topology)
        AddDumpSubmenu(self, "TheWorld.topology.ids", TheWorld.topology.ids)
        self:AddDividerOption()
    end

    if self.player then
        AddDumpSubmenu(self, "ThePlayer", ThePlayer)
        AddDumpSubmenu(self, "ThePlayer.AnimState", ThePlayer.AnimState)
        AddDumpSubmenu(self, "ThePlayer.Physics", ThePlayer.Physics)
        AddDumpSubmenu(self, "ThePlayer.player_classified", ThePlayer.player_classified)
        AddDumpSubmenu(self, "ThePlayer.sg", ThePlayer.sg)
        AddDumpSubmenu(self, "ThePlayer.Transform", ThePlayer.Transform)
        self:AddDividerOption()
    end

    AddDumpSubmenu(self, "AccountManager")
    AddDumpSubmenu(self, "AllRecipes")
    AddDumpSubmenu(self, "Entity")
    AddDumpSubmenu(self, "EntityScript")
    AddDumpSubmenu(self, "KnownModIndex")
    AddDumpSubmenu(self, "LOC")
    AddDumpSubmenu(self, "Profile")

    self:AddDividerOption()
    AddDumpSubmenu(self, "TheCamera")
    AddDumpSubmenu(self, "TheConfig")
    AddDumpSubmenu(self, "TheCookbook")
    AddDumpSubmenu(self, "TheFrontEnd")
    AddDumpSubmenu(self, "TheGameService")
    AddDumpSubmenu(self, "TheGlobalInstance")
    AddDumpSubmenu(self, "TheInput")
    AddDumpSubmenu(self, "TheInputProxy")
    AddDumpSubmenu(self, "TheInventory")
    AddDumpSubmenu(self, "TheMixer")
    AddDumpSubmenu(self, "TheNet")
    AddDumpSubmenu(self, "TheRecipeBook")
    AddDumpSubmenu(self, "TheShard")
    AddDumpSubmenu(self, "TheSim")
    AddDumpSubmenu(self, "TheSystemService")

    self:AddDividerOption()
    AddDumpSubmenu(self, "DevTools")
end

return DumpSubmenu
