----
-- Menu.
--
-- Includes menu functionality holding all existing submenus and some additional options.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.Menu
-- @see menu.submenu.CharacterRecipesSubmenu
-- @see menu.submenu.DebugSubmenu
-- @see menu.submenu.DumpSubmenu
-- @see menu.submenu.LabelsSubmenu
-- @see menu.submenu.MapSubmenu
-- @see menu.submenu.PlayerBarsSubmenu
-- @see menu.submenu.PlayerVisionSubmenu
-- @see menu.submenu.SelectSubmenu
-- @see menu.submenu.TeleportSubmenu
-- @see menu.submenu.TimeControlSubmenu
-- @see menu.submenu.WeatherControlSubmenu
-- @see menu.TextMenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"
require "consolecommands"

local TextMenu = require "devtools/menu/textmenu"

-- submenus
local CharacterRecipesSubmenu = require "devtools/menu/submenu/characterrecipessubmenu"
local DebugSubmenu = require "devtools/menu/submenu/debugsubmenu"
local DumpSubmenu = require "devtools/menu/submenu/dumpsubmenu"
local LabelsSubmenu = require "devtools/menu/submenu/labelssubmenu"
local MapSubmenu = require "devtools/menu/submenu/mapsubmenu"
local PlayerBarsSubmenu = require "devtools/menu/submenu/playerbarssubmenu"
local PlayerVisionSubmenu = require "devtools/menu/submenu/playervisionsubmenu"
local SelectSubmenu = require "devtools/menu/submenu/selectsubmenu"
local TeleportSubmenu = require "devtools/menu/submenu/teleportsubmenu"
local TimeControlSubmenu = require "devtools/menu/submenu/timecontrolsubmenu"
local WeatherControlSubmenu = require "devtools/menu/submenu/weathercontrolsubmenu"

-- options
local DividerOption = require "devtools/menu/option/divideroption"
local DoActionOption = require "devtools/menu/option/doactionoption"
local ToggleCheckboxOption = require "devtools/menu/option/togglecheckboxoption"

--- Constructor.
-- @function _ctor
-- @tparam screen.DevToolsScreen screen
-- @tparam DevTools devtools
-- @usage local menu = Menu(screen, devtools)
local Menu = Class(function(self, screen, devtools)
    -- general
    self.devtools = devtools
    self.menu = nil
    self.options = {}
    self.screen = screen

    local title = "Front-End Developer Tools"
    if self.devtools:IsInCharacterSelect() then
        title = "Character Selection Developer Tools"
    elseif InGamePlay() then
        title = "In-Game Developer Tools"
    end

    self.title = title
end)

--- Helpers
-- @section helpers

local function AddDividerOption(self)
    table.insert(self.options, DividerOption())
end

local function AddToggleOption(self, label, get, set, idx)
    if not get.src or not set.src then
        return
    end

    table.insert(self.options, ToggleCheckboxOption({
        label = label,
        get = get,
        set = set,
        on_accept_fn = function()
            return idx and self.screen:UpdateMenu(idx)
        end,
    }))
end

local function AddGrabProfileOption(self)
    table.insert(self.options, DoActionOption({
        label = "Grab Profile",
        on_accept_fn = function()
            TheSim:Profile()
            self.screen:Close()
        end,
    }))
end

--- General
-- @section general

--- Gets menu.
-- @treturn TextMenu
function Menu:GetMenu()
    return self.menu
end

--- Gets menu index.
-- @treturn number
function Menu:GetMenuIndex()
    return self.menu:GetIndex()
end

--- Sets menu index.
-- @tparam number idx
function Menu:SetMenuIndex(idx)
    self.menu:SetIndex(idx)
end

--- Clears menu and options.
function Menu:Clear()
    self.menu = nil
    self.options = {}
end

--- Adds submenu.
-- @tparam menu.submenu.Submenu submenu Class submenu (not an instance)
function Menu:AddSubmenu(submenu)
    if submenu._ctor then
        submenu(self.devtools, self.options)
    end
end

--- Update
-- @section update

--- Updates menu.
--
-- Clears both menu (`menu.TextMenu`) and options and recreates them.
--
-- @see menu.TextMenu
function Menu:Update()
    self:Clear()

    self.menu = TextMenu(self.title)

    local devtools = self.devtools
    local playerdevtools = devtools.player
    local worlddevtools = devtools.world

    if devtools and worlddevtools and playerdevtools then
        local craftingdevtools = playerdevtools.crafting

        -- select
        self:AddSubmenu(SelectSubmenu)
        AddDividerOption(self)

        -- player
        if playerdevtools:IsAdmin() then
            local player = playerdevtools:GetSelected()
            local prefix = #devtools:GetAllPlayers() > 1
                and string.format("[ %s ]  ", player:GetDisplayName())
                or ""

            AddToggleOption(
                self,
                { name = "God Mode", prefix = prefix },
                { src = playerdevtools, name = "IsGodMode" },
                { src = playerdevtools, name = "ToggleGodMode" }
            )

            AddToggleOption(
                self,
                { name = "Free Crafting", prefix = prefix },
                { src = craftingdevtools, name = "IsFreeCrafting" },
                { src = craftingdevtools, name = "ToggleFreeCrafting" },
                3
            )

            self:AddSubmenu(PlayerBarsSubmenu)
            self:AddSubmenu(TeleportSubmenu)
            AddDividerOption(self)
        end

        -- self
        if not worlddevtools:IsMasterSim() then
            AddToggleOption(
                self,
                { name = "Movement Prediction" },
                { src = playerdevtools, name = "IsMovementPrediction" },
                { src = playerdevtools, name = "ToggleMovementPrediction" }
            )
        end

        self:AddSubmenu(CharacterRecipesSubmenu)
        self:AddSubmenu(LabelsSubmenu)
        self:AddSubmenu(MapSubmenu)
        self:AddSubmenu(PlayerVisionSubmenu)
        AddDividerOption(self)

        -- world
        if playerdevtools:IsAdmin() then
            self:AddSubmenu(TimeControlSubmenu)
            self:AddSubmenu(WeatherControlSubmenu)
            AddDividerOption(self)
        end
    end

    -- general
    self:AddSubmenu(DebugSubmenu)
    self:AddSubmenu(DumpSubmenu)
    AddGrabProfileOption(self)

    self.menu:PushOptions(self.options, "")
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Menu:__tostring()
    return tostring(self.menu)
end

return Menu
