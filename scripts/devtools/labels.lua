----
-- Labels.
--
-- Includes labels functionality.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod Labels
-- @see DevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"
require "devtools/constants"

local Utils = require "devtools/utils"

-- threads
local _LABEL_UPDATE_THREAD_ID = "mod_dev_tools_label_update_thread"

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @usage local labels = Labels(devtools)
local Labels = Class(function(self, devtools)
    Utils.AddDebugMethods(self)

    -- general
    self.devtools = devtools
    self.font = BODYTEXTFONT
    self.font_size = 18
    self.is_selected_enabled = false
    self.name = "Labels"
    self.selected_entity = nil
    self.username_mode = false

    -- thread
    Utils.ThreadStart(_LABEL_UPDATE_THREAD_ID, function()
        self:OnUpdate()
        Sleep(FRAMES)
    end)

    -- other
    self:DebugInit(self.name)
end)

--- General
-- @section general

--- Gets font.
-- @treturn number
function Labels:GetFont()
    return self.font
end

--- Sets font.
-- @tparam string font
function Labels:SetFont(font)
    if type(font) == "string" then
        self.font = font
        self:OnUpdate()
        self:UpdateUsername()
    end
end

--- Gets font size.
-- @treturn number
function Labels:GetFontSize()
    return self.font_size
end

--- Sets the font size.
-- @tparam number size
function Labels:SetFontSize(size)
    self.font_size = size
    self:OnUpdate()
    self:UpdateUsername()
end

--- Data
-- @section data

--- Adds select label.
-- @tparam EntityScript[opt] inst Entity instance
-- @treturn boolean
function Labels:AddSelect(inst)
    if inst then
        self:RemoveSelect(self.selected_entity)
        if not inst.Label then
            inst.entity:AddLabel()
        end
        inst.Label:Enable(true)
        self.selected_entity = inst
        return true
    end
    return false
end

--- Removes select label.
-- @tparam EntityScript[opt] inst Entity instance
-- @treturn boolean
function Labels:RemoveSelect(inst)
    inst = inst ~= nil and inst or self.selected_entity
    if inst and inst.Label then
        if inst:HasTag("player") and self.username_mode ~= false then
            self:AddUsername(inst)
        else
            inst.Label:Enable(false)
        end
        self.selected_entity = nil
        return true
    end
    return false
end

--- Username
-- @section username

--- Gets username mode.
-- @treturn boolean|string
function Labels:GetUsernameMode()
    return self.username_mode
end

--- Sets username mode.
-- @tparam boolean|string mode
function Labels:SetUsernameMode(mode)
    self.username_mode = mode
    self:UpdateUsername()
end

--- Adds username label to a player.
-- @tparam EntityScript inst Player instance
-- @treturn boolean
function Labels:AddUsername(inst)
    -- label
    if not inst.Label then
        inst.entity:AddLabel()
    end

    inst.Label:SetFont(self.font)
    inst.Label:SetFontSize(self.font_size)
    inst.Label:SetWorldOffset(0, 2.3, 0)
    inst.Label:Enable(true)

    -- update
    self:UpdateUsername()
end

--- Update
-- @section update

--- Updates selected label.
function Labels:UpdateSelected()
    if self.selected_entity and self.selected_entity:IsValid() then
        local inst = self.selected_entity
        local text = ""

        if inst.name then
            text = text .. inst.name .. "\n"
        end

        text = text .. "GUID: " .. inst.GUID .. "\n"
        text = text .. "Prefab: " .. inst.entity:GetPrefabName() .. "\n"

        if inst.sg then
            local sg_name = Utils.GetStateGraphName(inst)
            local sg_state = Utils.GetStateGraphState(inst)
            if sg_name then
                text = text
                    .. "StateGraph: "
                    .. Utils.StringTableSplit({ sg_name, sg_state })
                    .. "\n"
            end
        end

        if inst.AnimState then
            local as_bank = Utils.GetAnimStateBank(inst)
            local as_build = Utils.GetAnimStateBuild(inst)
            local as_anim = Utils.GetAnimStateAnim(inst)
            if as_bank then
                text = text
                    .. "AnimState: "
                    .. Utils.StringTableSplit({ as_bank, as_build, as_anim })
            end
        end

        -- add
        inst.Label:SetColour(unpack(WHITE))
        inst.Label:SetFont(self.font)
        inst.Label:SetFontSize(self.font_size)
        inst.Label:SetText(text)
        inst.Label:SetWorldOffset(0, 0, 0)
    end
end

--- Updates username label.
function Labels:UpdateUsername()
    for _, inst in pairs(self.devtools:GetAllPlayers()) do
        if inst:IsValid() and inst.Label then
            local client = self.devtools:GetClientTableForUser(inst)

            inst.Label:Enable(true)
            inst.Label:SetText(inst.name)
            inst.Label:SetFont(self.font)
            inst.Label:SetFontSize(self.font_size)

            if self.username_mode == "default" then
                inst.Label:SetColour(unpack(WHITE))
            elseif self.username_mode == "coloured" and client and client.colour then
                inst.Label:SetColour(unpack(client.colour))
            elseif not self.username_mode then
                inst.Label:Enable(false)
            end
        end
    end
end

--- Updates on each frame.
--
-- Uses a custom thread for updating which is initialized in the constructor.
function Labels:OnUpdate()
    self:UpdateSelected()
end

return Labels
