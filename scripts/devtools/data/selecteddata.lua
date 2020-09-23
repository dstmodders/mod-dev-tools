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
-- @release 0.5.0
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @tparam DevTools devtools
-- @tparam EntityScript player
-- @tparam boolean is_entity_visible
-- @usage local selecteddata = SelectedData(screen, devtools, player, is_entity_visible)
local SelectedData = Class(Data, function(self, screen, devtools, player, is_entity_visible)
    Data._ctor(self, screen)

    -- general
    self.craftingdevtools = devtools.player.crafting
    self.devtools = devtools
    self.entity = devtools.world:GetSelectedEntity()
    self.is_entity_visible = is_entity_visible
    self.player = player
    self.playerdevtools = devtools.player
    self.worlddevtools = devtools.world

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

--- Updates lines stack.
function SelectedData:Update()
    Data.Update(self)

    local is_synced = self.devtools.ismastersim or self.playerdevtools:IsSelectedInSync()
    self:PushTitleLine("Selected Player " .. (is_synced and "(Client/Server)" or "(Client)"))
    self:PushEmptyLine()
    self:PushPlayerData()

    if self.entity and self.player.GUID ~= self.entity.GUID then
        self:PushEmptyLine()
        self:PushTitleLine("Selected Entity")
        self:PushEmptyLine()
        self:PushEntityData()
    end
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

    self:PushLine("GUID", player.GUID)
    self:PushLine("Prefab", player.entity:GetPrefabName())
    self:PushLine("Display Name", player:GetDisplayName())

    local state_name, state = GetStateGraph(self, player)
    if state_name ~= false then
        self:PushLine("StateGraph", { state_name, state })
    end

    local bank, build, anim = GetAnimState(self, player)
    if bank ~= false then
        self:PushLine("AnimState", { bank, build, anim })
    end

    if playerdevtools:IsOwner(player) or playerdevtools:IsReal(player) == false then
        if devtools.inst == player or (devtools.ismastersim or playerdevtools:IsAdmin()) then
            local health = Utils.String.ValuePercent(playerdevtools:GetHealthPercent(player) or 0)
            local health_max = Utils.String.ValuePercent(
                playerdevtools:GetMaxHealthPercent(player) or 0
            )

            self:PushLine("Health / Maximum", { health, health_max })

            self:PushLine(
                "Hunger",
                Utils.String.ValuePercent(playerdevtools:GetHungerPercent(player))
            )

            self:PushLine(
                "Sanity",
                Utils.String.ValuePercent(playerdevtools:GetSanityPercent(player))
            )

            self:PushLine(
                "Moisture",
                Utils.String.ValuePercent(playerdevtools:GetMoisturePercent(player))
            )

            self:PushLine(
                "Temperature",
                Utils.String.ValueScale(playerdevtools:GetTemperature(player))
            )
        end
    end

    if devtools.ismastersim or playerdevtools:IsAdmin() then
        local is_god_mode = playerdevtools:IsGodMode(player)
        if is_god_mode ~= nil then
            self:PushLine("God Mode", (is_god_mode and "enabled" or "disabled"))
        end

        local is_free_crafting = craftingdevtools:IsFreeCrafting(player)
        if is_free_crafting ~= nil then
            self:PushLine("Free Crafting", is_free_crafting and "enabled" or "disabled")
        end
    end
end

--- Pushes entity data.
function SelectedData:PushEntityData()
    Utils.AssertRequiredField("SelectedData.entity", self.entity)

    local name, physics

    local entity = self.entity
    if not entity then
        return
    end

    self:PushLine("GUID", entity.GUID)
    self:PushLine("Prefab", entity.entity:GetPrefabName())

    name = entity:GetDisplayName()
    if name and name ~= "MISSING NAME" then
        self:PushLine("Display Name", entity:GetDisplayName())
    end

    local state_name, state = GetStateGraph(self, entity)
    if state_name ~= false then
        self:PushLine("StateGraph", { state_name, state })
    end

    local bank, build, anim = GetAnimState(self, entity)
    if bank ~= false then
        self:PushLine("AnimState", { bank, build, anim })
    end

    physics = entity.Physics
    if physics then
        self:PushLine(
            "Collision Group / Mask",
            { physics:GetCollisionGroup(), physics:GetCollisionMask() }
        )

        self:PushLine("Radius", tostring(physics:GetRadius()))
        self:PushLine("Mass", tostring(physics:GetMass()))
    end
end

return SelectedData
