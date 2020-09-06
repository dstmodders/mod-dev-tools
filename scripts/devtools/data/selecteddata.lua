----
-- Selected data.
--
-- Includes selected data functionality which aim is to display some info about both the selected
-- player and the selected entity.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.SelectedData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam devtools.WorldDevTools worlddevtools
-- @tparam devtools.PlayerDevTools playerdevtools
-- @tparam devtools.player.CraftingDevTools craftingdevtools
-- @tparam EntityScript player
-- @tparam boolean is_entity_visible
-- @usage local selecteddata = SelectedData(
--     devtools,
--     worlddevtools,
--     playerdevtools,
--     craftingdevtools,
--     player,
--     is_entity_visible
-- )
local SelectedData = Class(Data, function(
    self,
    devtools,
    worlddevtools,
    playerdevtools,
    craftingdevtools,
    player,
    is_entity_visible
)
    Data._ctor(self)

    -- general
    self.craftingdevtools = craftingdevtools
    self.devtools = devtools
    self.entity = worlddevtools:GetSelectedEntity()
    self.entity_lines_stack = {}
    self.is_entity_visible = is_entity_visible
    self.player = player
    self.player_lines_stack = {}
    self.playerdevtools = playerdevtools
    self.worlddevtools = worlddevtools

    -- self
    self:Update()
end)

local function GetAnimState(self, entity)
    if not self or not entity or not entity.AnimState then
        return false
    end

    local bank = Utils.Entity.GetAnimStateBank(entity)
    local build = Utils.Entity.GetAnimStateBuild(entity)
    local anim = Utils.Entity.GetAnimStateAnim(entity)

    return bank, build, anim
end

local function GetStateGraph(self, entity)
    if not self or not entity or not entity.sg then
        return false
    end
    return Utils.Entity.GetStateGraphName(entity), Utils.Entity.GetStateGraphState(entity)
end

--- General
-- @section general

--- Clears lines stack.
function SelectedData:Clear()
    self.player_lines_stack = {}
end

--- Updates lines stack.
function SelectedData:Update()
    self:Clear()
    self:PushPlayerData()

    if self.entity and self.player.GUID ~= self.entity.GUID then
        self:PushEntityData()
    end
end

--- Player
-- @section player

--- Pushes player line.
-- @tparam string name
-- @tparam string value
function SelectedData:PushPlayerLine(name, value)
    self:PushLine(self.player_lines_stack, name, value)
end

--- Pushes player data.
function SelectedData:PushPlayerData()
    Utils.AssertRequiredField("SelectedData.craftingdevtools", self.craftingdevtools)
    Utils.AssertRequiredField("SelectedData.devtools", self.devtools)
    Utils.AssertRequiredField("SelectedData.player", self.player)
    Utils.AssertRequiredField("SelectedData.playerdevtools", self.playerdevtools)

    local craftingdevtools = self.craftingdevtools
    local devtools = self.devtools
    local player = self.player
    local playerdevtools = self.playerdevtools

    self:PushPlayerLine("GUID", player.GUID)
    self:PushPlayerLine("Prefab", player.entity:GetPrefabName())
    self:PushPlayerLine("Display Name", player:GetDisplayName())

    local state_name, state = GetStateGraph(self, player)
    if state_name ~= false then
        self:PushPlayerLine("StateGraph", { state_name, state })
    end

    local bank, build, anim = GetAnimState(self, player)
    if bank ~= false then
        self:PushPlayerLine("AnimState", { bank, build, anim })
    end

    if playerdevtools:IsOwner(player) or playerdevtools:IsReal(player) == false then
        if devtools.inst == player or (devtools.ismastersim or playerdevtools:IsAdmin()) then
            local health = Utils.String.ValuePercent(playerdevtools:GetHealthPercent(player) or 0)
            local health_max = Utils.String.ValuePercent(
                playerdevtools:GetMaxHealthPercent(player) or 0
            )

            self:PushPlayerLine("Health / Maximum", { health, health_max })

            self:PushPlayerLine(
                "Hunger",
                Utils.String.ValuePercent(playerdevtools:GetHungerPercent(player))
            )

            self:PushPlayerLine(
                "Sanity",
                Utils.String.ValuePercent(playerdevtools:GetSanityPercent(player))
            )

            self:PushPlayerLine(
                "Moisture",
                Utils.String.ValuePercent(playerdevtools:GetMoisturePercent(player))
            )

            self:PushPlayerLine(
                "Temperature",
                Utils.String.ValueScale(playerdevtools:GetTemperature(player))
            )
        end
    end

    if devtools.ismastersim or playerdevtools:IsAdmin() then
        local is_god_mode = playerdevtools:IsGodMode(player)
        if is_god_mode ~= nil then
            self:PushPlayerLine("God Mode", (is_god_mode and "enabled" or "disabled"))
        end

        local is_free_crafting = craftingdevtools:IsFreeCrafting(player)
        if is_free_crafting ~= nil then
            self:PushPlayerLine("Free Crafting", is_free_crafting and "enabled" or "disabled")
        end
    end
end

--- Entity
-- @section entity

local function PushEntityLine(self, name, value)
    self:PushLine(self.entity_lines_stack, name, value)
end

--- Pushes entity data.
function SelectedData:PushEntityData()
    Utils.AssertRequiredField("SelectedData.entity", self.entity)

    local name, physics

    local entity = self.entity
    if not entity then
        return
    end

    PushEntityLine(self, "GUID", entity.GUID)
    PushEntityLine(self, "Prefab", entity.entity:GetPrefabName())

    name = entity:GetDisplayName()
    if name and name ~= "MISSING NAME" then
        PushEntityLine(self, "Display Name", entity:GetDisplayName())
    end

    local state_name, state = GetStateGraph(self, entity)
    if state_name ~= false then
        PushEntityLine(self, "StateGraph", { state_name, state })
    end

    local bank, build, anim = GetAnimState(self, entity)
    if bank ~= false then
        PushEntityLine(self, "AnimState", { bank, build, anim })
    end

    physics = entity.Physics
    if physics then
        PushEntityLine(
            self,
            "Collision Group / Mask",
            { physics:GetCollisionGroup(), physics:GetCollisionMask() }
        )

        PushEntityLine(self, "Radius", tostring(physics:GetRadius()))
        PushEntityLine(self, "Mass", tostring(physics:GetMass()))
    end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function SelectedData:__tostring()
    if #self.player_lines_stack == 0 then
        return
    end

    local t = {}
    local is_synced = self.devtools.ismastersim or self.playerdevtools:IsSelectedInSync()

    self:TableInsertTitle(t, "Selected Player " .. (is_synced and "(Client/Server)" or "(Client)"))
    self:TableInsertData(t, self.player_lines_stack)
    table.insert(t, "\n")

    if self.is_entity_visible and #self.entity_lines_stack > 0 then
        self:TableInsertTitle(t, "Selected Entity")
        self:TableInsertData(t, self.entity_lines_stack)
    end

    return table.concat(t)
end

return SelectedData
