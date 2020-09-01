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

local function Label(is_reversed, name, title)
    local label = string.format("%s (%s)", title, name)
    return is_reversed and string.format("%s (%s)", name, title) or label
end

local function AddDumpOption(self, label, object)
    if object then
        self:AddDoActionOption({
            label = label,
            on_accept_fn = function()
                dumptable(object)
            end,
        })
    end
end

local function AddDumpComponentsOption(self, name, object, is_reversed)
    if object and Utils.DumpComponents then
        self:AddDoActionOption({
            label = Label(is_reversed, name, "Components"),
            on_accept_fn = function()
                Utils.DumpComponents(object, name)
            end,
        })
    end
end

local function AddDumpEventListenersOption(self, name, object, is_reversed)
    if object and Utils.DumpEventListeners then
        self:AddDoActionOption({
            label = Label(is_reversed, name, "Event Listeners"),
            on_accept_fn = function()
                Utils.DumpEventListeners(object, name)
            end,
        })
    end
end

local function AddDumpFieldsOption(self, name, object, is_reversed)
    if object and Utils.DumpFields then
        self:AddDoActionOption({
            label = Label(is_reversed, name, "Fields"),
            on_accept_fn = function()
                Utils.DumpFields(object, name)
            end,
        })
    end
end

local function AddDumpFunctionsOption(self, name, object, is_reversed)
    if object and Utils.DumpFunctions then
        self:AddDoActionOption({
            label = Label(is_reversed, name, "Functions"),
            on_accept_fn = function()
                Utils.DumpFunctions(object, name)
            end,
        })
    end
end

local function AddDumpReplicasOption(self, name, object, is_reversed)
    if object and Utils.DumpReplicas then
        self:AddDoActionOption({
            label = Label(is_reversed, name, "Replicas"),
            on_accept_fn = function()
                Utils.DumpReplicas(object, name)
            end,
        })
    end
end

local function AddDumpSelectedEntityOption(self, fn, is_reversed)
    local entity = self.world:GetSelectedEntity()
    if entity then
        fn(self, "Selected Entity", entity, is_reversed)
    end
end

--- General
-- @section general

--- Adds options.
function DumpSubmenu:AddOptions()
    AddDumpOption(self, "AllRecipes", AllRecipes)
    AddDumpOption(self, "Profile", Profile)

    if self.world then
        local selected_entity = self.world:GetSelectedEntity()
        local world = self.world:GetWorld()
        local world_net = self.world:GetWorldNet()

        if world then
            AddDumpOption(self, "TheWorld.meta", self.world:GetMeta())
            AddDumpOption(self, "TheWorld.state", self.world:GetState())

            if world and world.topology and world.topology.ids then
                AddDumpOption(self, "TheWorld.topology.ids", world.topology.ids)
            end

            self:AddDividerOption()
        end

        if self.player then
            local player = self.player:GetPlayer()

            if player and selected_entity and player ~= selected_entity then
                AddDumpSelectedEntityOption(self, AddDumpComponentsOption, true)
                AddDumpSelectedEntityOption(self, AddDumpEventListenersOption, true)
                AddDumpSelectedEntityOption(self, AddDumpFieldsOption, true)
                AddDumpSelectedEntityOption(self, AddDumpFunctionsOption, true)
                AddDumpSelectedEntityOption(self, AddDumpReplicasOption, true)
                self:AddDividerOption()
            end

            AddDumpComponentsOption(self, "ThePlayer", player)
        end

        AddDumpComponentsOption(self, "TheWorld", world)
        AddDumpComponentsOption(self, "TheWorld.net", world_net)

        self:AddDividerOption()

        if self.player then
            local player = self.player:GetPlayer()
            if player then
                AddDumpEventListenersOption(self, "ThePlayer", player)
                AddDumpEventListenersOption(
                    self,
                    "ThePlayer.player_classified",
                    player.player_classified
                )
            end
        end

        AddDumpEventListenersOption(self, "TheWorld", world)
        AddDumpEventListenersOption(self, "TheWorld.net", world_net)

        self:AddDividerOption()
    end

    AddDumpFieldsOption(self, "DevTools", DevTools)
    AddDumpFieldsOption(self, "TheCamera", TheCamera)
    AddDumpFieldsOption(self, "TheFrontEnd", TheFrontEnd)
    AddDumpFieldsOption(self, "Profile", Profile)

    if self.player then
        local player = self.player:GetPlayer()
        if player then
            AddDumpFieldsOption(self, "ThePlayer", player)
            AddDumpFieldsOption(self, "ThePlayer.player_classified", player.player_classified)
        end
    end

    if self.world then
        local world = self.world:GetWorld()
        AddDumpFieldsOption(self, "TheWorld", world)
        AddDumpFieldsOption(self, "TheWorld.net", self.world:GetWorldNet())
    end

    self:AddDividerOption()

    AddDumpFunctionsOption(self, "DevTools", DevTools)
    AddDumpFunctionsOption(self, "Profile", Profile)
    AddDumpFunctionsOption(self, "TheCamera", TheCamera)
    AddDumpFunctionsOption(self, "TheFrontEnd", TheFrontEnd)
    AddDumpFunctionsOption(self, "TheInventory", TheInventory)
    AddDumpFunctionsOption(self, "TheNet", TheNet)

    if self.player then
        local player = self.player:GetPlayer()
        if player then
            AddDumpFunctionsOption(self, "ThePlayer", player)
            AddDumpFunctionsOption(self, "ThePlayer.Physics", player.Physics)
            AddDumpFunctionsOption(self, "ThePlayer.player_classified", player.player_classified)
        end
    end

    AddDumpFunctionsOption(self, "TheSim", TheSim)

    if self.world then
        local world = self.world:GetWorld()
        local world_net = self.world:GetWorldNet()

        AddDumpFunctionsOption(self, "TheWorld", world)

        if world and world.Map then
            AddDumpFunctionsOption(self, "TheWorld.Map", world.Map)
        end

        AddDumpFunctionsOption(self, "TheWorld.net", world_net)
    end

    if self.player then
        self:AddDividerOption()
        AddDumpReplicasOption(self, "ThePlayer", self.player:GetPlayer())
    end
end

return DumpSubmenu
