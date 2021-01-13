----
-- Selected data.
--
-- Includes selected player and entity in data sidebar.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.SelectedData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local Data = require "devtools/data/data"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevToolsScreen screen
-- @tparam DevTools devtools
-- @tparam EntityScript player
-- @tparam boolean is_entity_visible
-- @usage local selecteddata = SelectedData(screen, devtools, player, is_entity_visible)
local SelectedData = Class(Data, function(self, screen, devtools, player, is_entity_visible)
    Data._ctor(self, screen)

    -- general
    self.playercraftingtools = devtools.player.crafting
    self.devtools = devtools
    self.entity = devtools.world:GetSelectedEntity()
    self.is_entity_visible = is_entity_visible
    self.player = player
    self.playertools = devtools.player
    self.worldtools = devtools.world

    -- other
    self:Update()
end)

local function GetAnimState(self, entity)
    if not self or not entity or not entity.AnimState then
        return false
    end

    local bank = SDK.Entity.GetAnimStateBank(entity)
    local build = SDK.Entity.GetAnimStateBuild(entity)
    local anim = SDK.Entity.GetAnimStateAnim(entity)

    return bank, build, anim
end

local function GetStateGraph(self, entity)
    if not self or not entity or not entity.sg then
        return false
    end
    return SDK.Entity.GetStateGraphName(entity), SDK.Entity.GetStateGraphState(entity)
end

--- General
-- @section general

--- Updates lines stack.
function SelectedData:Update()
    Data.Update(self)

    local is_synced = SDK.World.IsMasterSim() or self.playertools:IsSelectedInSync()
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
    SDK.Utils.AssertRequiredField("SelectedData.playercraftingtools", self.playercraftingtools)
    SDK.Utils.AssertRequiredField("SelectedData.devtools", self.devtools)
    SDK.Utils.AssertRequiredField("SelectedData.player", self.player)
    SDK.Utils.AssertRequiredField("SelectedData.playertools", self.playertools)

    local devtools = self.devtools
    local player = self.player
    local playertools = self.playertools

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

    if SDK.Player.IsOwner(player) or SDK.Player.IsReal(player) == false then
        if devtools.inst == player or (SDK.World.IsMasterSim() or SDK.Player.IsAdmin()) then
            local health = SDK.Utils.Value.ToPercentString(
                SDK.Player.Attribute.GetHealthPercent() or 0
            )

            local health_max = SDK.Utils.Value.ToPercentString(
                SDK.Player.Attribute.GetHealthLimitPercent(player) or 0
            )

            self:PushLine("Health / Maximum", { health, health_max })

            self:PushLine(
                "Hunger",
                SDK.Utils.Value.ToPercentString(SDK.Player.Attribute.GetHungerPercent(player))
            )

            self:PushLine(
                "Sanity",
                SDK.Utils.Value.ToPercentString(SDK.Player.Attribute.GetSanityPercent(player))
            )

            self:PushLine(
                "Moisture",
                SDK.Utils.Value.ToPercentString(SDK.Player.Attribute.GetMoisturePercent(player))
            )

            self:PushLine(
                "Temperature",
                SDK.Utils.Value.ToDegreeString(SDK.Player.Attribute.GetTemperature(player))
            )
        end
    end

    if SDK.World.IsMasterSim() or SDK.Player.IsAdmin() then
        local is_god_mode = playertools:IsGodMode(player)
        if is_god_mode ~= nil then
            self:PushLine("God Mode", (is_god_mode and "enabled" or "disabled"))
        end

        local is_free_crafting = SDK.Player.Craft.HasFreeCrafting(player)
        if is_free_crafting ~= nil then
            self:PushLine("Free Crafting", is_free_crafting and "enabled" or "disabled")
        end
    end
end

--- Pushes entity data.
function SelectedData:PushEntityData()
    SDK.Utils.AssertRequiredField("SelectedData.entity", self.entity)

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
