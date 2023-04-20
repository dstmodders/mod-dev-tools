----
-- Dump submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod submenus.DumpSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0
----
require("class")

local Submenu = require("devtools/menu/submenu")
local Utils = require("devtools/utils")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local dumpsubmenu = DumpSubmenu(devtools, root)
local DumpSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Dump", "DumpSubmenu", MOD_DEV_TOOLS.DATA_SIDEBAR.DUMPED)

    -- options
    self:AddOptions()
    self:AddToRoot()
end)

--- General
-- @section general

--- Adds field option.
-- @tparam string name
-- @tparam table values
-- @tparam[opt] table root
function DumpSubmenu:AddFieldOption(name, values, root)
    if type(values) == "table" and #values > 0 then
        self:AddActionOption({
            label = name,
            on_accept_fn = function()
                self.screen:SetDumped({ name = "Fields (" .. name .. ")", values = values })
                print(string.format("Dumping fields (%s)...", string.lower(name)))
                for _, field in pairs(values) do
                    print(field)
                end
            end,
        }, root)
    end
end

--- Adds fields submenu.
-- @tparam string name
-- @tparam table object
-- @tparam[opt] table root
function DumpSubmenu:AddFieldsSubmenu(name, object, root)
    local fields = Utils.Dump.GetFields(object, true)

    local options = {}
    local booleans = {}
    local functions = {}
    local numbers = {}
    local strings = {}
    local tables = {}
    local userdata = {}

    for _, field in pairs(fields) do
        if object[field] then
            if type(object[field]) == "boolean" then
                table.insert(booleans, field)
            elseif type(object[field]) == "function" then
                table.insert(functions, field)
            elseif type(object[field]) == "number" then
                table.insert(numbers, field)
            elseif type(object[field]) == "string" then
                table.insert(strings, field)
            elseif type(object[field]) == "table" then
                table.insert(tables, field)
            elseif type(object[field]) == "userdata" then
                table.insert(userdata, field)
            end
        end
    end

    self:AddActionOption({
        label = "All",
        on_accept_fn = function()
            self.screen:SetDumped({ name = "Fields", values = fields })
            Utils.Dump.Fields(object)
        end,
    }, options)

    if #booleans > 0 or #functions > 0 or #numbers > 0 or #strings > 0 or #userdata > 0 then
        self:AddDividerOption(options)
        self:AddFieldOption("Booleans", booleans, options)
        self:AddFieldOption("Functions", functions, options)
        self:AddFieldOption("Numbers", numbers, options)
        self:AddFieldOption("Strings", strings, options)
        self:AddFieldOption("Tables", tables, options)
        self:AddFieldOption("Userdata", userdata, options)
    end

    self:AddSubmenuOption({
        label = name,
        options = options,
    }, root)
end

--- Adds dump options.
-- @tparam string name
-- @tparam table options
-- @tparam[opt] table object
function DumpSubmenu:AddDumpOptions(name, options, object)
    object = object ~= nil and object or _G[name]

    if type(object) == "function" then
        return
    end

    local components = Utils.Dump.GetComponents(object, true)
    local event_listeners = Utils.Dump.GetEventListeners(object, true)
    local fields = Utils.Dump.GetFields(object, true)
    local functions = Utils.Dump.GetFunctions(object, true)

    if #fields > 0 then
        self:AddFieldsSubmenu("Fields", object, options)
        if type(object) == "table" then
            if #components > 0 or #event_listeners > 0 or #functions > 0 then
                self:AddDividerOption(options)
            end
        end
    end

    if #components > 0 then
        self:AddActionOption({
            label = "Components",
            on_accept_fn = function()
                Utils.Dump.Components(object, name)
                self.screen:SetDumped({ name = "Components", values = components })
            end,
        }, options)
    end

    if #event_listeners > 0 then
        self:AddActionOption({
            label = "Event Listeners",
            on_accept_fn = function()
                Utils.Dump.EventListeners(object, name)
                self.screen:SetDumped({ name = "Event Listeners", values = event_listeners })
            end,
        }, options)
    end

    if #functions > 0 then
        self:AddActionOption({
            label = "Functions", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                Utils.Dump.Functions(object, name)
                self.screen:SetDumped({ name = "Functions", values = functions })
            end,
        }, options)
    end

    if type(object) == "table" then
        if #components > 0 or #event_listeners > 0 or #fields > 0 or #functions > 0 then
            self:AddDividerOption(options)
        end

        self:AddActionOption({
            label = "dumptable", -- those are "Methods" logically, but it's Lua, so who cares
            on_accept_fn = function()
                dumptable(object)
                self.screen:SetDumped({ name = "Table", values = { "[CHECK CONSOLE FOR DATA]" } })
            end,
        }, options)
    end
end

--- Adds dump submenu.
-- @tparam string name
-- @tparam table object
-- @tparam[opt] table root
function DumpSubmenu:AddDumpSubmenu(name, object, root)
    if object then
        local _options = {}
        self:AddDumpOptions(name, _options, object)
        self:AddSubmenuOption({
            label = name,
            options = _options,
        }, root)
    end
end

--- Adds managers submenu.
-- @tparam[opt] table root
function DumpSubmenu:AddManagersSubmenu(root)
    local options = {}
    self:AddDumpSubmenu("AccountManager", AccountManager, options)
    self:AddDumpSubmenu("BrainManager", BrainManager, options)
    self:AddDumpSubmenu("EmitterManager", EmitterManager, options)
    self:AddDumpSubmenu("EnvelopeManager", EnvelopeManager, options)
    self:AddDumpSubmenu("FontManager", FontManager, options)
    self:AddDumpSubmenu("MapLayerManager", MapLayerManager, options)
    self:AddDumpSubmenu("ModManager", EmitterManager, options)
    self:AddDumpSubmenu("RoadManager", RoadManager, options)
    self:AddDumpSubmenu("SGManager", SGManager, options)
    self:AddDumpSubmenu("ShadowManager", ShadowManager, options)
    self:AddSubmenuOption({
        label = "Managers",
        options = options,
    }, root)
end

--- Adds proxy submenu.
-- @tparam[opt] table root
function DumpSubmenu:AddProxySubmenu(root)
    local options = {}
    self:AddDumpSubmenu("EventLeaderboardProxy", EventLeaderboardProxy, options)
    self:AddDumpSubmenu("InputProxy", InputProxy, options)
    self:AddDumpSubmenu("InventoryProxy", InventoryProxy, options)
    self:AddDumpSubmenu("ItemServerProxy", ItemServerProxy, options)
    self:AddDumpSubmenu("NetworkProxy", NetworkProxy, options)
    self:AddDumpSubmenu("ShardProxy", ShardProxy, options)
    self:AddSubmenuOption({
        label = "Proxies",
        options = options,
    }, root)
end

--- Adds "The" submenu.
-- @tparam[opt] table root
function DumpSubmenu:AddTheSubmenu(root)
    local options = {}
    self:AddDumpSubmenu("TheCamera", TheCamera, options)
    self:AddDumpSubmenu("TheConfig", TheConfig, options)
    self:AddDumpSubmenu("TheCookbook", TheCookbook, options)
    self:AddDumpSubmenu("TheFocalPoint", TheFocalPoint, options)
    self:AddDumpSubmenu("TheFrontEnd", TheFrontEnd, options)
    self:AddDumpSubmenu("TheGameService", TheGameService, options)
    self:AddDumpSubmenu("TheGlobalInstance", TheGlobalInstance, options)
    self:AddDumpSubmenu("TheInput", TheInput, options)
    self:AddDumpSubmenu("TheInventory", TheInventory, options)
    self:AddDumpSubmenu("TheItems", TheInput, options)
    self:AddDumpSubmenu("TheLeaderboards", TheInput, options)
    self:AddDumpSubmenu("TheMixer", TheMixer, options)
    self:AddDumpSubmenu("TheNet", TheNet, options)
    self:AddDumpSubmenu("ThePlayer", ThePlayer, options)
    self:AddDumpSubmenu("TheRawImgui", TheMixer, options)
    self:AddDumpSubmenu("TheRecipeBook", TheRecipeBook, options)
    self:AddDumpSubmenu("TheShard", TheShard, options)
    self:AddDumpSubmenu("TheSim", TheSim, options)
    self:AddDumpSubmenu("TheSystemService", TheSystemService, options)
    self:AddDumpSubmenu("TheWorld", TheWorld, options)
    self:AddSubmenuOption({
        label = "The",
        options = options,
    }, root)
end

--- Adds other submenu.
-- @tparam[opt] table root
function DumpSubmenu:AddOtherSubmenu(root)
    local options = {}
    self:AddDumpSubmenu("Account", Account, options)
    self:AddDumpSubmenu("AllRecipes", AllRecipes, options)
    self:AddDumpSubmenu("AnimState", AnimState, options)
    self:AddDumpSubmenu("Entity", Entity, options)
    self:AddDumpSubmenu("EntityScript", EntityScript, options)
    self:AddDumpSubmenu("KnownModIndex", KnownModIndex, options)
    self:AddDumpSubmenu("LOC", LOC, options)
    self:AddDumpSubmenu("PostProcessor", PostProcessor, options)
    self:AddDumpSubmenu("Profile", Profile, options)
    self:AddDumpSubmenu("Transform", Transform, options)
    self:AddDumpSubmenu("Translator", Translator, options)
    self:AddDumpSubmenu("Vector3", Vector3, options)
    self:AddDumpSubmenu("Video", Video, options)
    self:AddDumpSubmenu("VideoWidget", VideoWidget, options)
    self:AddSubmenuOption({
        label = "Other",
        options = options,
    }, root)
end

--- Adds first level submenu.
-- @tparam string name
-- @tparam table object
-- @tparam[opt] table root
function DumpSubmenu:AddFirstLevelSubmenu(name, object, root)
    local fields = Utils.Dump.GetFields(object, true)

    local options = {}
    local tables = {}
    local userdata = {}

    for _, field in pairs(fields) do
        if type(object[field]) == "table" then
            table.insert(tables, field)
        elseif type(object[field]) == "userdata" then
            table.insert(userdata, field)
        end
    end

    self:AddDumpSubmenu(name, object, options)

    self:AddDividerOption(options)
    for _, v in pairs(userdata) do
        self:AddDumpSubmenu(name .. "." .. v, object[v], options)
    end

    self:AddDividerOption(options)
    for _, v in pairs(tables) do
        self:AddDumpSubmenu(name .. "." .. v, object[v], options)
    end

    self:AddSubmenuOption({
        label = name,
        options = options,
    }, root)
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

    self:AddFieldsSubmenu("Globals", _G)
    self:AddManagersSubmenu()
    self:AddProxySubmenu()
    self:AddTheSubmenu()
    self:AddOtherSubmenu()

    if self.player or self.world then
        self:AddDividerOption()
        self:AddFirstLevelSubmenu("ThePlayer", ThePlayer)
        self:AddFirstLevelSubmenu("TheWorld", TheWorld)
    end

    self:AddDividerOption()
    self:AddDumpSubmenu("DevTools", DevTools)
    self:AddDumpSubmenu("DevToolsAPI", DevToolsAPI)
end

return DumpSubmenu
