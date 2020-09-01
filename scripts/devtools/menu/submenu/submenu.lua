----
-- Base submenu.
--
-- Includes base submenu functionality and must be extended by other submenu classes.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.Submenu
-- @see menu.submenu.CharacterRecipesSubmenu
-- @see menu.submenu.DebugSubmenu
-- @see menu.submenu.DumpSubmenu
-- @see menu.submenu.LabelsSubmenu
-- @see menu.submenu.LanguageSubmenu
-- @see menu.submenu.MapSubmenu
-- @see menu.submenu.PlayerBarsSubmenu
-- @see menu.submenu.PlayerVisionSubmenu
-- @see menu.submenu.SeasonControlSubmenu
-- @see menu.submenu.SelectSubmenu
-- @see menu.submenu.TeleportSubmenu
-- @see menu.submenu.TimeControlSubmenu
-- @see menu.submenu.WeatherControlSubmenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Utils = require "devtools/utils"

local CheckboxOption = require "devtools/menu/option/checkboxoption"
local ChoicesOption = require "devtools/menu/option/choicesoption"
local DividerOption = require "devtools/menu/option/divideroption"
local DoActionOption = require "devtools/menu/option/doactionoption"
local NumericToggleOption = require "devtools/menu/option/numerictoggleoption"
local SubmenuOption = require "devtools/menu/option/submenuoption"
local ToggleCheckboxOption = require "devtools/menu/option/togglecheckboxoption"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam devtools.DevTools devtools
-- @tparam Widget root
-- @tparam string label
-- @tparam string name
-- @tparam[opt] number menu_idx
-- @usage local submenu = Submenu(devtools, root)
local Submenu = Class(function(self, devtools, root, label, name, menu_idx)
    Utils.AddDebugMethods(self)

    -- general
    self.devtools = devtools
    self.label = label
    self.menu_idx = menu_idx
    self.name = name
    self.options = {}
    self.root = root
    self.screen = devtools.screen
end)

--- General
-- @section general

--- Gets label.
-- @treturn string
function Submenu:GetLabel()
    return self.label
end

--- Gets name.
-- @treturn string
function Submenu:GetName()
    return self.name
end

--- Adds prefix for the selected player.
-- @tparam DevTools devtools
-- @tparam devtools.PlayerDevTools playerdevtools
function Submenu:AddSelectedPlayerLabelPrefix(devtools, playerdevtools)
    if type(self.label) == "string" and devtools and playerdevtools then
        local player = playerdevtools:GetSelected()
        if player and #devtools:GetAllPlayers() > 1 then
            local prefix = string.format("[ %s ]  ", player:GetDisplayName()) or ""
            self.label = prefix .. self.label
        end
    end
end

--- Updates screen.
--
-- Switches data based on the provided data string and updates the screen:
--
-- - "front-end"
-- - "recipe"
-- - "selected"
-- - "world"
--
-- @see screens.DevToolsScreen
-- @see screens.DevToolsScreen.SwitchDataToFrontEnd
-- @see screens.DevToolsScreen.SwitchDataToNil
-- @see screens.DevToolsScreen.SwitchDataToRecipe
-- @see screens.DevToolsScreen.SwitchDataToSelected
-- @see screens.DevToolsScreen.SwitchDataToWorld
-- @tparam string data
function Submenu:UpdateScreen(data)
    if self.screen then
        if data == "front-end" then
            self.screen:SwitchDataToFrontEnd()
        elseif data == "recipe" then
            self.screen:SwitchDataToRecipe()
        elseif data == "selected" then
            self.screen:SwitchDataToSelected()
        elseif data == "world" then
            self.screen:SwitchDataToWorld()
        else
            self.screen:SwitchDataToNil()
        end

        if self.menu_idx then
            self.screen:UpdateMenu(self.menu_idx)
        end
    end
end

--- Options
-- @section options

--- Adds to root.
function Submenu:AddToRoot()
    if type(self.root) == "table" then
        table.insert(self.root, SubmenuOption({
            label = self.label,
            name = self.name,
            options = self.options,
        }))
    end
end

--- Adds checkbox option.
-- @see menu.option.CheckboxOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddCheckboxOption(options, root)
    root = root ~= nil and root or self.options
    table.insert(root, CheckboxOption(options))
end

--- Adds choices option.
-- @see menu.option.ChoicesOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddChoicesOption(options, root)
    root = root ~= nil and root or self.options
    table.insert(root, ChoicesOption(options))
end

--- Adds divider option.
-- @see menu.option.DividerOption
-- @tparam[opt] table root
function Submenu:AddDividerOption(root)
    root = root ~= nil and root or self.options
    table.insert(root, DividerOption())
end

--- Adds do action option.
-- @see menu.option.DoActionOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddDoActionOption(options, root)
    root = root ~= nil and root or self.options
    table.insert(root, DoActionOption(options))
end

--- Adds numeric toggle option.
-- @see menu.option.NumericToggleOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddNumericToggleOption(options, root)
    root = root ~= nil and root or self.options
    table.insert(root, NumericToggleOption(options))
end

--- Adds submenu option.
-- @see menu.option.SubmenuOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddSubmenuOption(options, root)
    root = root ~= nil and root or self.options
    table.insert(root, SubmenuOption(options))
end

--- Adds toggle option.
-- @see menu.option.ToggleCheckboxOption
-- @tparam table label
-- @tparam table get
-- @tparam table set
-- @tparam number idx
-- @tparam[opt] table root
function Submenu:AddToggleOption(label, get, set, idx, root)
    root = root ~= nil and root or self.options

    if not get.src or not set.src then
        return
    end

    table.insert(root, ToggleCheckboxOption({
        label = label,
        get = get,
        set = set,
        on_accept_fn = function()
            return idx and self.screen:UpdateMenu(idx)
        end,
    }))
end

return Submenu
