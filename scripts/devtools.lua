----
-- General tools.
--
-- The globally exposed module which can be called directly through the console. Includes indirectly
-- both player and world functionality. Besides including some general methods this class doesn't do
-- much except passing data to the submodules which then add their methods to this class.
--
-- For example, when loading the world only the world-related methods are added. As soon as the
-- owner chooses the character, player-related ones are added as well. When the player decides to
-- leave the game, all earlier added methods are removed.
--
-- This approach is especially handy when playing around in the in-game console as the global
-- `DevTools` may include some methods that can help out in testing some ideas without bothering
-- "diving too deep".
--
-- All world (when available) functionality can be accessed directly as:
--
--    DevTools.world
--
-- All player (when available) functionality can be accessed directly as:
--
--    DevTools.player
--
-- _Below is the list of some self-explanatory methods which have been added using SDK._
--
-- **Getters:**
--
--   - `GetAPI`
--   - `GetDebug`
--   - `GetScreen`
--   - `GetSubmenusData`
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod DevTools
-- @see Labels
-- @see tools.PlayerTools
-- @see tools.WorldTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
require "consolecommands"
require "devtools/constants"

local API = require "devtools/api"
local Config = require "devtools/config"
local Debug = require "devtools/debug/debug"
local Labels = require "devtools/labels"
local PlayerTools = require "devtools/tools/playertools"
local SDK = require "devtools/sdk/sdk/sdk"
local Submenu = require "devtools/menu/submenu"
local WorldTools = require "devtools/tools/worldtools"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @usage local devtools = DevTools()
local DevTools = Class(function(self)
    SDK.Debug.AddMethods(self)
    SDK.Method
        .SetClass(self)
        .AddToString("DevTools")
        .AddGetters({
            api = "GetAPI",
            debug = "GetDebug",
            screen = "GetScreen",
            submenus_data = "GetSubmenusData",
        })

    -- general
    self.api = API(self)
    self.config = Config()
    self.debug = Debug()
    self.inst = nil
    self.labels = Labels(self)
    self.name = "DevTools"
    self.player = nil
    self.screen = nil -- set in DevToolsScreen:DoInit()
    self.submenus_data = {}
    self.world = nil

    -- config
    self.config:SetDefault("font", BODYTEXTFONT)
    self.config:SetDefault("font_size", 16)
    self.config:SetDefault("key_select", KEY_TAB)
    self.config:SetDefault("key_switch_data", KEY_X)
    self.config:SetDefault("locale_text_scale", false)
    self.config:SetDefault("size_height", 26)
    self.config:SetDefault("size_width", 1280)

    -- other
    self:DebugInit(tostring(self))
end)

--- General
-- @section general

--- Gets config.
-- @tparam[opt] string name Config name
-- @treturn any
function DevTools:GetConfig(name)
    if name ~= nil then
        return self.config:GetValue(name)
    end
    return self.config:GetValues()
end

--- Sets config.
-- @tparam string name Config name
-- @tparam any value Config value
function DevTools:SetConfig(name, value)
    self.config:SetValue(name, value)
    self.config:Save()
end

--- Resets config.
-- @tparam string name Config name
-- @treturn boolean
function DevTools:ResetConfig(name)
    self.config:ResetValue(name)
    self.config:Save()
end

--- API
-- @section api

--- Adds submenu data.
-- @tparam table data
function DevTools:AddSubmenusData(data)
    table.insert(self.submenus_data, data)
end

--- Submenu
-- @section submenu

local function SetOnAddToRootFn(on_add_to_root_fn, submenu, root)
    if type(on_add_to_root_fn) == "function" then
        submenu:SetOnAddToRootFn(on_add_to_root_fn)
    elseif type(on_add_to_root_fn) == "table" then
        local result = true

        for _, fn in pairs(on_add_to_root_fn) do
            submenu:SetOnAddToRootFn(fn)

            if type(fn) == "function" then
                result = submenu:OnOnAddToRoot(root)
            end

            if result == false then
                break
            end
        end

        submenu:SetOnAddToRootFn(function()
            return result
        end)
    else
        submenu:SetOnAddToRootFn(nil)
    end
end

--- Creates a submenu instance from data.
-- @tparam table data
-- @tparam table root
-- @treturn menu.Submenu
-- @usage local devtools = DevTools()
-- local submenu = devtools:CreateSubmenuInstFromData({
--     label = "Map",
--     name = "MapSubmenu",
--     on_init_fn = function(self, devtools)
--         self.map = devtools.player and devtools.player.map
--         self.player = devtools.player
--         self.world = devtools.world
--     end,
--     on_add_to_root_fn = {
--         MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
--         MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_MASTER_SIM,
--     },
--     options = {
--         {
--             type = MOD_DEV_TOOLS.OPTION.ACTION,
--             options = {
--                 label = "Reveal",
--                 on_accept_fn = function(_, submenu)
--                     submenu.map:Reveal()
--                     submenu.screen:Close()
--                 end,
--             },
--         },
--         { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
--         {
--             type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
--             options = {
--                 label = "Clearing",
--                 get = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "IsMapClearing",
--                 },
--                 set = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "ToggleMapClearing",
--                 },
--             },
--         },
--         {
--             type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
--             options = {
--                 label = "Fog of War",
--                 get = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "IsMapFogOfWar",
--                 },
--                 set = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "ToggleMapFogOfWar",
--                 },
--             },
--         },
--     },
-- })
function DevTools:CreateSubmenuInstFromData(data, root)
    local submenu = Submenu(self, root, data.label, data.name, data.data_sidebar, data.menu_idx)

    if type(data.on_init_fn) == "function" then
        submenu:SetOnInitFn(data.on_init_fn)
        submenu:OnInit()
    end

    local options = data.options

    if type(options) == "function" then
        options = options(submenu)
    end

    if type(options) == "table" and #options > 0 then
        for _, option in pairs(options) do
            SetOnAddToRootFn(option.on_add_to_root_fn, submenu, root)

            if option.type == MOD_DEV_TOOLS.OPTION.ACTION then
                submenu:AddActionOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.CHECKBOX then
                submenu:AddCheckboxOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.CHOICES then
                submenu:AddChoicesOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.DIVIDER then
                submenu:AddDividerOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.FONT then
                submenu:AddFontOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.NUMERIC then
                submenu:AddNumericOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.SUBMENU then
                self:CreateSubmenuInstFromData(option.options, submenu.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX then
                submenu:AddToggleCheckboxOption(option.options)
            end
        end
    end

    SetOnAddToRootFn(data.on_add_to_root_fn, submenu)

    submenu:AddToRoot()

    return submenu
end

--- Lifecycle
-- @section lifecycle

--- Initializes when the world is initialized.
-- @tparam table inst World instance
function DevTools:DoInitWorld(inst)
    self.world = WorldTools(inst, self)
end

--- Initializes when the player is initialized.
-- @tparam table inst Player instance
function DevTools:DoInitPlayer(inst)
    local msg = "Required DevTools.world is missing. Did you forget to DevTools:DoInitWorld()?"
    assert(self.world ~= nil, msg)
    self.player = PlayerTools(inst, self.world, self)
    self.debug:DoInitGame()
end

--- Terminates when the world is terminated.
-- @tparam table inst World instance
function DevTools:DoTermWorld()
    if self.world then
        self.world:DoTerm()
    end
end

--- Terminates when the player is terminated.
-- @tparam table inst Player instance
function DevTools:DoTermPlayer()
    if self.player then
        self.player:DoTerm()
    end
end

return DevTools
