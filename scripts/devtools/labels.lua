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
-- @release 0.7.0-alpha
----
require "class"
require "devtools/constants"

local Utils = require "devtools/utils"

-- threads
local _LABEL_UPDATE_THREAD_ID = "mod_dev_tools_label_update_thread"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @usage local labels = Labels(devtools)
local Labels = Class(function(self, devtools)
    Utils.Debug.AddMethods(self)

    -- general
    self.default_font = nil
    self.default_font_size = nil
    self.default_username_mode = nil
    self.devtools = devtools
    self.font = BODYTEXTFONT
    self.font_size = 18
    self.is_selected_enabled = false
    self.is_username_enabled = false
    self.name = "Labels"
    self.selected_entity = nil
    self.username_mode = "default"

    -- thread
    Utils.Thread.Start(_LABEL_UPDATE_THREAD_ID, function()
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
        if not self.default_font then
            self.default_font = font
        end
        self.font = font
        self:OnUpdate()
        self:UpdateUsername()
    end
end

--- Gets default font.
-- @treturn number
function Labels:GetDefaultFont()
    return self.default_font
end

--- Gets font size.
-- @treturn number
function Labels:GetFontSize()
    return self.font_size
end

--- Sets the font size.
-- @tparam number size
function Labels:SetFontSize(size)
    if type(size) == "number" then
        if not self.default_font_size then
            self.default_font_size = size
        end
        self.font_size = size
        self:OnUpdate()
        self:UpdateUsername()
    end
end

--- Gets default font size.
-- @treturn number
function Labels:GetDefaultFontSize()
    return self.default_font_size
end

--- Selected
-- @section selected

--- Checks if selected is enabled state.
-- @treturn boolean
function Labels:IsSelectedEnabled()
    return self.is_selected_enabled
end

--- Sets selected enabled state.
-- @treturn boolean enabled
function Labels:SetIsSelectedEnabled(enabled)
    self.is_selected_enabled = enabled
    self:OnUpdate()
end

--- Toggles selected enabled state.
function Labels:ToggleSelectedEnabled()
    self.is_selected_enabled = not self.is_selected_enabled
    self:OnUpdate()
end

--- Adds selected label.
-- @tparam EntityScript[opt] inst Entity instance
-- @treturn boolean
function Labels:AddSelected(inst)
    if self.is_selected_enabled and inst then
        self:RemoveSelected(self.selected_entity)
        if not inst.Label then
            inst.entity:AddLabel()
        end
        self.selected_entity = inst
    else
        self:RemoveSelected(inst)
    end
    self:UpdateSelected()
    return self.is_selected_enabled
end

--- Removes selected label.
-- @tparam EntityScript[opt] inst Entity instance
-- @treturn boolean
function Labels:RemoveSelected(inst)
    inst = inst ~= nil and inst or self.selected_entity
    if inst and inst.Label then
        if inst:HasTag("player") and self.username_mode then
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

--- Checks if username is enabled state.
-- @treturn boolean
function Labels:IsUsernameEnabled()
    return self.is_username_enabled
end

--- Sets username enabled state.
-- @treturn boolean enabled
function Labels:SetIsUsernameEnabled(enabled)
    self.is_username_enabled = enabled
    self:UpdateUsername()
end

--- Toggles username enabled state.
function Labels:ToggleUsernameEnabled()
    self.is_username_enabled = not self.is_username_enabled
    self:UpdateUsername()
end

--- Gets username mode.
-- @treturn boolean|string
function Labels:GetUsernameMode()
    return self.username_mode
end

--- Sets username mode.
-- @tparam boolean|string mode
function Labels:SetUsernameMode(mode)
    if self.default_username_mode == nil then
        self.default_username_mode = mode
    end
    self.username_mode = mode
    self:UpdateUsername()
end

--- Gets default username mode.
-- @treturn boolean|string
function Labels:GetDefaultUsernameMode()
    return self.default_username_mode
end

--- Adds username label to a player.
-- @tparam EntityScript inst Player instance
-- @treturn boolean
function Labels:AddUsername(inst)
    if self.is_username_enabled and inst and inst:HasTag("player") then
        -- label
        if not inst.Label then
            inst.entity:AddLabel()
        end
    end
    self:UpdateUsername()
    return self.is_username_enabled
end

--- Update
-- @section update

--- Updates selected label.
function Labels:UpdateSelected()
    local inst = self.selected_entity
    if self.is_selected_enabled and inst and inst:IsValid() then
        local text = ""

        if inst.name then
            text = text .. inst.name .. "\n"
        end

        text = text .. "GUID: " .. inst.GUID .. "\n"
        text = text .. "Prefab: " .. inst.entity:GetPrefabName() .. "\n"

        if inst.sg then
            local sg_name = Utils.Entity.GetStateGraphName(inst)
            local sg_state = Utils.Entity.GetStateGraphState(inst)
            if sg_name then
                text = text
                    .. "StateGraph: "
                    .. Utils.String.TableSplit({ sg_name, sg_state })
                    .. "\n"
            end
        end

        if inst.AnimState then
            local as_bank = Utils.Entity.GetAnimStateBank(inst)
            local as_build = Utils.Entity.GetAnimStateBuild(inst)
            local as_anim = Utils.Entity.GetAnimStateAnim(inst)
            if as_bank then
                text = text
                    .. "AnimState: "
                    .. Utils.String.TableSplit({ as_bank, as_build, as_anim })
            end
        end

        -- add
        inst.Label:Enable(true)
        inst.Label:SetColour(unpack(WHITE))
        inst.Label:SetFont(self.font)
        inst.Label:SetFontSize(self.font_size)
        inst.Label:SetText(text)
        inst.Label:SetWorldOffset(0, 0, 0)
    elseif not self.is_selected_enabled and inst and inst:IsValid() and inst.Label then
        inst.Label:Enable(false)
    end
end

--- Updates username label.
function Labels:UpdateUsername()
    for _, inst in pairs(self.devtools:GetAllPlayers()) do
        if inst:IsValid() and inst.Label then
            if self.is_username_enabled then
                local client = self.devtools:GetClientTableForUser(inst)

                inst.Label:Enable(true)
                inst.Label:SetFont(self.font)
                inst.Label:SetFontSize(self.font_size)
                inst.Label:SetText(inst.name)
                inst.Label:SetWorldOffset(0, 2.3, 0)

                if self.username_mode == "default" then
                    inst.Label:SetColour(unpack(WHITE))
                elseif self.username_mode == "coloured" and client and client.colour then
                    inst.Label:SetColour(unpack(client.colour))
                end
            else
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
