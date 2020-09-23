----
-- Base submenu.
--
-- Includes base submenu functionality and must be extended by other submenu classes.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.Submenu
-- @see submenus.CharacterRecipesSubmenu
-- @see submenus.Debug
-- @see submenus.DumpSubmenu
-- @see submenus.Labels
-- @see submenus.Language
-- @see submenus.Map
-- @see submenus.PlayerBarsSubmenu
-- @see submenus.PlayerVision
-- @see submenus.SeasonControl
-- @see submenus.SelectSubmenu
-- @see submenus.TeleportSubmenu
-- @see submenus.TimeControl
-- @see submenus.WeatherControl
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.6.0-alpha
----
require "class"

local Utils = require "devtools/utils"

local ActionOption = require "devtools/menu/option/actionoption"
local CheckboxOption = require "devtools/menu/option/checkboxoption"
local ChoicesOption = require "devtools/menu/option/choicesoption"
local DividerOption = require "devtools/menu/option/divideroption"
local FontOption = require "devtools/menu/option/fontoption"
local NumericOption = require "devtools/menu/option/numericoption"
local SubmenuOption = require "devtools/menu/option/submenuoption"
local ToggleCheckboxOption = require "devtools/menu/option/togglecheckboxoption"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @tparam string label
-- @tparam string name
-- @tparam[opt] number menu_idx
-- @usage local submenu = Submenu(devtools, root)
local Submenu = Class(function(self, devtools, root, label, name, menu_idx)
    Utils.Debug.AddMethods(self)

    -- general
    self.label = label
    self.menu_idx = menu_idx
    self.name = name
    self.options = {}
    self.root = root

    -- devtools
    self.console = devtools.player and devtools.player.console
    self.crafting = devtools.player and devtools.player.crafting
    self.debug = devtools.debug
    self.devtools = devtools
    self.inventory = devtools.player and devtools.player.inventory
    self.labels = devtools.labels
    self.map = devtools.player and devtools.player.map
    self.player = devtools.player
    self.screen = devtools.screen
    self.vision = devtools.player and devtools.player.vision
    self.world = devtools.world

    -- callbacks
    self.on_add_to_root_fn = nil
    self.on_init_fn = nil

    -- self
    self:OnInit()
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
-- @tparam string data Data name
-- @tparam boolean unpause Should the world be resumed if paused?
function Submenu:UpdateScreen(data, unpause)
    if unpause and self.devtools then
        if self.devtools:IsPaused() then
            self.devtools:Unpause()
        end
    end

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
function Submenu:AddToRoot(root, option)
    root = root ~= nil and root or self.root
    option = option ~= nil and option or SubmenuOption({
        label = self.label,
        name = self.name,
        options = self.options,
    })

    if type(root) == "table" and type(self.on_add_to_root_fn) ~= "function" then
        table.insert(root, option)
    elseif type(root) == "table" and type(self.on_add_to_root_fn) == "function" then
        if type(self.on_add_to_root_fn) == "function" then
            if self:OnOnAddToRoot(root) ~= false then
                table.insert(root, option)
            end
            return
        end
    end
end

--- Adds do action option.
-- @see menu.option.ActionOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddActionOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, ActionOption(options, self))
end

--- Adds checkbox option.
-- @see menu.option.CheckboxOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddCheckboxOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, CheckboxOption(options, self))
end

--- Adds choices option.
-- @see menu.option.ChoicesOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddChoicesOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, ChoicesOption(options, self))
end

--- Adds divider option.
-- @see menu.option.DividerOption
-- @tparam[opt] table root
function Submenu:AddDividerOption(root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, DividerOption(self))
end

--- Adds font option.
-- @see menu.option.FontOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddFontOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, FontOption(options, self))
end

--- Adds numeric toggle option.
-- @see menu.option.NumericOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddNumericOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, NumericOption(options, self))
end

--- Adds submenu option.
-- @see menu.option.SubmenuOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddSubmenuOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, SubmenuOption(options, self))
end

--- Adds toggle checkbox option.
-- @see menu.option.ToggleCheckboxOption
-- @tparam table options
-- @tparam[opt] table root
function Submenu:AddToggleCheckboxOption(options, root)
    root = root ~= nil and root or self.options
    self:AddToRoot(root, ToggleCheckboxOption(options, self))
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
    }, self))
end

--- Callbacks
-- @section callbacks

--- Gets on add to root function.
-- @see OnOnAddToRoot
-- @treturn function
function Submenu:GetOnAddToRootFn()
    return self.on_add_to_root_fn
end

--- Sets on add to root function.
-- @see MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN
-- @see OnOnAddToRoot
-- @tparam function fn
function Submenu:SetOnAddToRootFn(fn)
    self.on_add_to_root_fn = fn
end

--- Triggers when adding to the root.
-- @see GetOnAddToRootFn
-- @see SetOnAddToRootFn
-- @tparam table root
-- @usage function Submenu:OnOnAddToRoot()
--     Submenu.OnOnAddToRoot(self)
--     -- your logic
-- end
function Submenu:OnOnAddToRoot(root)
    if type(self.on_add_to_root_fn) == "function" then
        return self:on_add_to_root_fn(root)
    end
end

--- Gets on init function.
-- @see OnInit
-- @treturn function
function Submenu:GetOnInitFn()
    return self.on_init_fn
end

--- Sets on init function.
-- @see OnInit
-- @tparam function fn
function Submenu:SetOnInitFn(fn)
    self.on_init_fn = fn
end

--- Triggers when initializing.
-- @see GetOnInitFn
-- @see SetOnInitFn
-- @usage function Submenu:OnInit()
--     Submenu.OnInit(self)
--     -- your logic
-- end
function Submenu:OnInit()
    if type(self.on_init_fn) == "function" then
        self:on_init_fn(self.devtools, self.root, self.label, self.name, self.menu_idx)
    end
end

return Submenu
