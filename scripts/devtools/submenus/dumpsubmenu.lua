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
-- @release 0.5.0-alpha
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

    -- options
    self:AddOptions()
    self:AddToRoot()
end)

--- General
-- @section general

--- Adds dump options.
-- @tparam string name
-- @tparam table options
-- @tparam[opt] table object
function DumpSubmenu:AddDumpOptions(name, options, object)
    object = object ~= nil and object or _G[name]

    local nr_of_components =#Utils.Dump.GetComponents(object)
    local nr_of_event_listeners = #Utils.Dump.GetEventListeners(object)
    local nr_of_fields = #Utils.Dump.GetFields(object)
    local nr_of_functions = #Utils.Dump.GetFunctions(object)

    if nr_of_components > 0 then
        self:AddActionOption({
            label = "Components",
            on_accept_fn = function()
                Utils.Dump.Components(object, name)
            end,
        }, options)
    end

    if nr_of_event_listeners > 0 then
        self:AddActionOption({
            label = "Event Listeners",
            on_accept_fn = function()
                Utils.Dump.EventListeners(object, name)
            end,
        }, options)
    end

    if nr_of_fields > 0 then
        self:AddActionOption({
            label = "Fields",
            on_accept_fn = function()
                Utils.Dump.Fields(object, name)
            end,
        }, options)
    end

    if nr_of_functions > 0 then
        self:AddActionOption({
            label = "Functions", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                Utils.Dump.Functions(object, name)
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

--- Adds dump submenu.
-- @tparam string name
-- @tparam table object
function DumpSubmenu:AddDumpSubmenu(name, object)
    if object then
        local _options = {}
        self:AddDumpOptions(name, _options, object)
        self:AddSubmenuOption({
            label = name,
            options = _options,
        })
    end
end

--- Adds options.
function DumpSubmenu:AddOptions()
    if self.player then
        local selected_entity = self.world:GetSelectedEntity()
        local player = self.player:GetPlayer()
        if player and selected_entity and player ~= selected_entity then
            self:AddDumpSubmenu("Selected Entity", selected_entity)
            self:AddDividerOption()
        end
    end

    if self.world then
        self:AddDumpSubmenu("TheWorld", TheWorld)
        self:AddDumpSubmenu("TheWorld.Map", TheWorld.Map)
        self:AddDumpSubmenu("TheWorld.meta", TheWorld.meta)
        self:AddDumpSubmenu("TheWorld.net", TheWorld.net)
        self:AddDumpSubmenu("TheWorld.state", TheWorld.state)
        self:AddDumpSubmenu("TheWorld.topology", TheWorld.topology)
        self:AddDumpSubmenu("TheWorld.topology.ids", TheWorld.topology.ids)
        self:AddDividerOption()
    end

    if self.player then
        self:AddDumpSubmenu("ThePlayer", ThePlayer)
        self:AddDumpSubmenu("ThePlayer.AnimState", ThePlayer.AnimState)
        self:AddDumpSubmenu("ThePlayer.Physics", ThePlayer.Physics)
        self:AddDumpSubmenu("ThePlayer.player_classified", ThePlayer.player_classified)
        self:AddDumpSubmenu("ThePlayer.sg", ThePlayer.sg)
        self:AddDumpSubmenu("ThePlayer.Transform", ThePlayer.Transform)
        self:AddDividerOption()
    end

    self:AddDumpSubmenu("AccountManager", AccountManager)
    self:AddDumpSubmenu("AllRecipes", AllRecipes)
    self:AddDumpSubmenu("Entity", Entity)
    self:AddDumpSubmenu("EntityScript", EntityScript)
    self:AddDumpSubmenu("KnownModIndex", KnownModIndex)
    self:AddDumpSubmenu("LOC", LOC)
    self:AddDumpSubmenu("Profile", Profile)

    self:AddDividerOption()
    self:AddDumpSubmenu("TheCamera", TheCamera)
    self:AddDumpSubmenu("TheConfig", TheConfig)
    self:AddDumpSubmenu("TheCookbook", TheCookbook)
    self:AddDumpSubmenu("TheFrontEnd", TheFrontEnd)
    self:AddDumpSubmenu("TheGameService", TheGameService)
    self:AddDumpSubmenu("TheGlobalInstance", TheGlobalInstance)
    self:AddDumpSubmenu("TheInput", TheInput)
    self:AddDumpSubmenu("TheInputProxy", TheInputProxy)
    self:AddDumpSubmenu("TheInventory", TheInventory)
    self:AddDumpSubmenu("TheMixer", TheMixer)
    self:AddDumpSubmenu("TheNet", TheNet)
    self:AddDumpSubmenu("TheRecipeBook", TheRecipeBook)
    self:AddDumpSubmenu("TheShard", TheShard)
    self:AddDumpSubmenu("TheSim", TheSim)
    self:AddDumpSubmenu("TheSystemService", TheSystemService)

    self:AddDividerOption()
    self:AddDumpSubmenu("DevTools", DevTools)
    self:AddDumpSubmenu("DevToolsAPI", DevToolsAPI)
end

return DumpSubmenu
