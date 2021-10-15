----
-- Mod screen.
--
-- Includes a mod screen overlay holding both main menu and data widgets both of which are just
-- plain text ones.
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod DevToolsScreen
-- @see data.FrontEndData
-- @see data.RecipeData
-- @see data.SelectedData
-- @see data.SelectedTagsData
-- @see data.WorldData
-- @see menu.Menu
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local Image = require "widgets/image"
local Menu = require "devtools/menu/menu"
local Screen = require "widgets/screen"
local SDK = require "devtools/sdk/sdk/sdk"
local Text = require "widgets/text"

local DumpedData = require "devtools/data/dumpeddata"
local FrontEndData = require "devtools/data/frontenddata"
local RecipeData = require "devtools/data/recipedata"
local SelectedData = require "devtools/data/selecteddata"
local SelectedTagsData = require "devtools/data/selectedtagsdata"
local WorldData = require "devtools/data/worlddata"
local WorldStateData = require "devtools/data/worldstatedata"

local _SCREEN_NAME = "ModDevToolsScreen"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @usage local devtoolsscreen = DevToolsScreen(screen, devtools)
local DevToolsScreen = Class(Screen, function(self, devtools)
    Screen._ctor(self, _SCREEN_NAME)

    -- general
    self.font = devtools:GetConfig("font")
    self.font_size = devtools:GetConfig("font_size")
    self.locale_text_scale = devtools:GetConfig("locale_text_scale")
    self.size_height = devtools:GetConfig("size_height")
    self.size_width = devtools:GetConfig("size_width")

    -- overlay
    self.overlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.overlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.overlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.overlay:SetVAnchor(ANCHOR_MIDDLE)
    self.overlay:SetHAnchor(ANCHOR_MIDDLE)
    self.overlay:SetClickable(false)
    self.overlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.overlay:SetTint(0, 0, 0, .75)

    -- menu
    self.menu = self:AddChild(Text(
        self.font,
        self.font_size / (self.locale_text_scale and 1 or LOC.GetTextScale()),
        ""
    ))

    self.menu:SetHAlign(ANCHOR_LEFT)
    self.menu:SetHAnchor(ANCHOR_MIDDLE)
    self.menu:SetVAlign(ANCHOR_TOP)
    self.menu:SetVAnchor(ANCHOR_MIDDLE)
    self.menu:SetPosition(0, 0, 0)
    self.menu:SetRegionSize(self.size_width / 2 , self.size_height * self.font_size)
    self.menu:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- data
    self.data = self:AddChild(Text(
        self.font,
        self.font_size / (self.locale_text_scale and 1 or LOC.GetTextScale()),
        ""
    ))

    self.data:SetHAlign(ANCHOR_RIGHT)
    self.data:SetHAnchor(ANCHOR_MIDDLE)
    self.data:SetVAlign(ANCHOR_TOP)
    self.data:SetVAnchor(ANCHOR_MIDDLE)
    self.data:SetPosition(0, 0, 0)
    self.data:SetRegionSize(self.size_width / 2, self.size_height * self.font_size)
    self.data:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- other
    self:DoInit(devtools)

    -- TheFrontEnd
    TheFrontEnd:HideConsoleLog()
end)

--- General
-- @section general

--- Gets dumped.
-- @treturn table
function DevToolsScreen:GetDumped()
    return self.dumped
end

--- Sets dumped.
-- @tparam table dumped
function DevToolsScreen:SetDumped(dumped)
    self.dumped = dumped
    self:ResetDataSidebarIndex()
end

--- Checks if screen can be toggled.
-- @treturn boolean
function DevToolsScreen:CanToggle()
    if global_error_widget then
        return false
    end

    if global_loading_widget and global_loading_widget.is_enabled then
        return false
    end

    if SDK.FrontEnd.IsScreenOpen("ConsoleScreen") then
        return false
    end

    local devtools = self.devtools
    if InGamePlay() and devtools and not SDK.IsInCharacterSelect() then
        local playertools = devtools.player
        if playertools and SDK.Player.IsHUDChatInputScreenOpen() then
            return false
        end
    end

    return true
end

--- Checks if screen is in open state.
-- @treturn boolean
function DevToolsScreen:IsOpen()
    return SDK.FrontEnd.IsScreenOpen(self.name)
end

--- Opens screen.
-- @treturn boolean
function DevToolsScreen:Open()
    TheFrontEnd:PushScreen(self(self.devtools))
    return true
end

--- Closes screen.
-- @treturn boolean
function DevToolsScreen:Close() -- luacheck: only
    TheFrontEnd:PopScreen()
    return true
end

--- Toggles screen.
-- @treturn boolean
function DevToolsScreen:Toggle()
    if self:IsOpen() then
        self:Close()
    else
        self:Open()
    end
end

--- Data
-- @section data

--- Gets data sidebar.
-- @see MOD_DEV_TOOLS.DATA_SIDEBAR
-- @treturn number
function DevToolsScreen:GetDataSidebar()
    return self.data_sidebar
end

--- Resets data sidebar index.
function DevToolsScreen:ResetDataSidebarIndex()
    self.data_sidebar_idx = 1
    self:UpdateDataSidebar()
    self:UpdateChildren()
end

--- Changes data sidebar.
-- @see menu.Submenu.UpdateScreen
-- @tparam[opt] number data_sidebar Constant `MOD_DEV_TOOLS.DATA_SIDEBAR`
function DevToolsScreen:ChangeDataSidebar(data_sidebar)
    self.data_sidebar = data_sidebar
    if data_sidebar ~= nil then
        self:UpdateDataSidebar()
    else
        self.data_text = nil
    end
end

--- Switches data.
-- @tparam[opt] number dir
function DevToolsScreen:SwitchData(dir)
    dir = dir ~= nil and dir or 1
    if InGamePlay() then
        self.data_sidebar_idx = 1
        self.data_sidebar = dir > 0
            and SDK.Utils.Table.NextValue(self.in_game_play_data_sidebars, self.data_sidebar)
            or SDK.Utils.Table.PrevValue(self.in_game_play_data_sidebars, self.data_sidebar)
        self:ResetDataSidebarIndex()
    end
end

--- Update
-- @section update

--- Updates.
function DevToolsScreen:UpdateFromConfig()
    self.font = self.devtools:GetConfig("font")
    self.font_size = self.devtools:GetConfig("font_size")
    self.locale_text_scale = self.devtools:GetConfig("locale_text_scale")
    self.size_height = self.devtools:GetConfig("size_height")
    self.size_width = self.devtools:GetConfig("size_width")

    -- menu
    self.menu:SetRegionSize(self.size_width / 2, self.size_height * self.font_size)
    self.menu:SetFont(self.font)
    self.menu:SetSize(self.font_size / (self.locale_text_scale and 1 or LOC.GetTextScale()))

    -- data
    self.data:SetRegionSize(self.size_width / 2, self.size_height * self.font_size)
    self.data:SetFont(self.font)
    self.data:SetSize(self.font_size / (self.locale_text_scale and 1 or LOC.GetTextScale()))
end

--- Updates.
function DevToolsScreen:Update()
    if self:IsOpen() and self.devtools and not SDK.Time.IsPaused() then
        self:UpdateDataSidebar()
        self:UpdateChildren()
    end
end

--- Updates on each frame.
function DevToolsScreen:OnUpdate()
    self:Update()
end

--- Updates children.
function DevToolsScreen:UpdateChildren()
    local selected = "[SELECTED]"
    local unselected = string.format(
        "[PRESS %s TO SELECT]",
        string.upper(STRINGS.UI.CONTROLSSCREEN.INPUTS[1][self.devtools:GetConfig("key_select")])
    )

    if self.menu_text ~= nil and self.menu then
        self.menu:SetString((self.selected == MOD_DEV_TOOLS.SELECT.MENU and selected or unselected)
            .. "\n\n"
            .. tostring(self.menu_text))
    end

    if self.data_text ~= nil and self.data then
        local total_sidebar_data = 1
        local sidebar_data_idx = 1

        if InGamePlay() then
            total_sidebar_data = #self.in_game_play_data_sidebars
            sidebar_data_idx = SDK.Utils.Table.KeyByValue(
                self.in_game_play_data_sidebars,
                self.data_sidebar
            )
        end

        local number = (total_sidebar_data and sidebar_data_idx)
            and string.format(" [%d/%d]", sidebar_data_idx, total_sidebar_data)
            or ""

        self.data:SetString((self.selected == MOD_DEV_TOOLS.SELECT.DATA and selected or unselected)
            .. number
            .. "\n\n"
            .. tostring(self.data_text))
    end
end

--- Updates menu.
-- @tparam number root_idx Root index
-- @treturn menu.Menu
function DevToolsScreen:UpdateMenu(root_idx)
    local previous_idx = self.menu_text and self.menu_text:GetMenuIndex() or nil

    self.menu_text = Menu(self, self.devtools)
    self.menu_text:Update()

    local menu = self.menu_text:GetMenu()
    if root_idx and previous_idx and menu:AtRoot() then
        menu.index = root_idx
        menu:Accept()
        menu.index = previous_idx
    end

    return self.menu_text
end

--- Updates dumped data.
function DevToolsScreen:UpdateDumpedData()
    self.data_text = DumpedData(self)
end

--- Updates front-end data.
function DevToolsScreen:UpdateFrontEndData()
    self.data_text = FrontEndData(self)
end

--- Updates recipe data.
function DevToolsScreen:UpdateRecipeData()
    self.data_text = RecipeData(self, self.devtools)
end

--- Updates selected data.
function DevToolsScreen:UpdateSelectedData()
    self.data_text = SelectedData(
        self,
        self.devtools,
        self.devtools.player:GetSelected(),
        self.is_selected_entity_data_visible
    )
end

--- Updates selected tags data.
function DevToolsScreen:UpdateSelectedTagsData()
    self.data_text = SelectedTagsData(
        self,
        self.devtools,
        self.devtools.world,
        self.devtools.player:GetSelected()
    )
end

--- Updates world data.
function DevToolsScreen:UpdateWorldData()
    self.data_text = WorldData(self, self.devtools.world)
end

--- Updates world state data.
function DevToolsScreen:UpdateWorldStateData()
    self.data_text = WorldStateData(self, self.devtools.world:GetWorld())
end

--- Updates data.
-- @treturn data.RecipeData|data.SelectedData|data.WorldData
function DevToolsScreen:UpdateDataSidebar()
    local devtools = self.devtools
    local playertools = devtools.player
    local worldtools = devtools.world

    if self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.DUMPED then
        self:UpdateDumpedData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.FRONT_END then
        self:UpdateFrontEndData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.RECIPE
        and SDK.Utils.Chain.Get(playertools, "crafting")
    then
        self:UpdateRecipeData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED
        and worldtools
        and SDK.Utils.Chain.Get(playertools, "crafting")
    then
        self:UpdateSelectedData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED_TAGS
        and worldtools
        and playertools
    then
        self:UpdateSelectedTagsData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD and worldtools then
        self:UpdateWorldData()
    elseif self.data_sidebar == MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD_STATE and worldtools then
        self:UpdateWorldStateData()
    end

    return self.data_text
end

--- Input
-- @section input

--- Triggers when accept raw key is pressed.
-- @see OnRawKey
function DevToolsScreen:OnAccept()
    local menu = self.menu_text:GetMenu()

    if menu:AtRoot() then
        self.data_sidebar_root = self.data_sidebar
        self:ChangeDataSidebar(self.data_sidebar)
    end

    menu:Accept()

    if menu:AtRoot() then
        self:ChangeDataSidebar(self.data_sidebar_root)
    end

    self:UpdateDataSidebar()
    self:UpdateChildren()
end

--- Triggers when escape raw key is pressed.
-- @see OnRawKey
function DevToolsScreen:OnEscape()
    if self.selected == MOD_DEV_TOOLS.SELECT.DATA then
        self:Close()
    elseif self.selected == MOD_DEV_TOOLS.SELECT.MENU then
        local menu = self.menu_text:GetMenu()

        if not menu:Cancel() then
            self:Close()
        end

        if menu:AtRoot() then
            self:ChangeDataSidebar(self.data_sidebar_root)
        end

        self:UpdateChildren()
    end
end

--- Triggers when select raw key is pressed.
-- @see OnRawKey
function DevToolsScreen:OnSelect()
    self.selected = SDK.Utils.Table.NextValue({
        MOD_DEV_TOOLS.SELECT.MENU,
        MOD_DEV_TOOLS.SELECT.DATA,
    }, self.selected)
    self:UpdateChildren()
end

--- Triggers when control key is pressed.
-- @tparam number control
-- @tparam boolean down
function DevToolsScreen:OnControl(control, down)
    Screen.OnControl(self, control, down)
    if control == CONTROL_SCROLLBACK and down then
        self.data_sidebar_idx = self.data_text:Up(self.data_sidebar_idx)
        self:UpdateDataSidebar()
        self:UpdateChildren()
    elseif control == CONTROL_SCROLLFWD and down then
        self.data_sidebar_idx = self.data_text:Down(self.data_sidebar_idx)
        self:UpdateDataSidebar()
        self:UpdateChildren()
    end
end

--- Triggers when raw key is pressed.
-- @see OnAccept
-- @see OnEscape
-- @see OnSelect
-- @tparam number key
-- @tparam boolean down
-- @treturn boolean
function DevToolsScreen:OnRawKey(key, down)
    if Screen.OnRawKey(self, key, down) then
        return true
    end

    if not down then
        if key == KEY_ESCAPE then
            self:OnEscape()
        elseif key == KEY_ENTER and self.selected == MOD_DEV_TOOLS.SELECT.MENU then
            self:OnAccept()
        elseif key == self.key_switch_data then
            self:SwitchData()
        elseif key == self.key_select then
            self:OnSelect()
        else
            return false
        end
    else
        if self.selected == MOD_DEV_TOOLS.SELECT.DATA then
            if key == KEY_UP then
                self.data_sidebar_idx = self.data_text:Up(self.data_sidebar_idx)
                self:UpdateDataSidebar()
                self:UpdateChildren()
            elseif key == KEY_DOWN then
                self.data_sidebar_idx = self.data_text:Down(self.data_sidebar_idx)
                self:UpdateDataSidebar()
                self:UpdateChildren()
            elseif key == KEY_LEFT then
                self:SwitchData(-1)
            elseif key == KEY_RIGHT then
                self:SwitchData()
            else
                return false
            end
        elseif self.selected == MOD_DEV_TOOLS.SELECT.MENU then
            local menu = self.menu_text:GetMenu()
            if key == KEY_UP then
                menu:Up()
                self:UpdateChildren()
            elseif key == KEY_DOWN then
                menu:Down()
                self:UpdateChildren()
            elseif key == KEY_LEFT then
                menu:Left()
                self:UpdateDataSidebar()
                self:UpdateChildren()
            elseif key == KEY_RIGHT then
                menu:Right()
                self:UpdateDataSidebar()
                self:UpdateChildren()
            else
                return false
            end
        end
    end

    return true
end

--- Callbacks
-- @section callbacks

--- Triggers on becoming active.
function DevToolsScreen:OnBecomeActive()
    SDK.Utils.AssertRequiredField("DevToolsScreen.devtools", self.devtools)

    Screen.OnBecomeActive(self)

    self:UpdateMenu()
    self:UpdateDataSidebar()
    self:UpdateChildren()
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
-- @tparam DevTools devtools
function DevToolsScreen:DoInit(devtools)
    -- general
    self.data_text = nil
    self.devtools = devtools
    self.is_selected_entity_data_visible = true
    self.key_select = devtools:GetConfig("key_select")
    self.key_switch_data = self.devtools:GetConfig("key_switch_data")
    self.menu_text = nil
    self.name = _SCREEN_NAME
    self.selected = MOD_DEV_TOOLS.SELECT.MENU

    -- data sidebar
    self.data_sidebar = InGamePlay()
        and MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD
        or MOD_DEV_TOOLS.DATA_SIDEBAR.FRONT_END

    self.in_game_play_data_sidebars = {
        MOD_DEV_TOOLS.DATA_SIDEBAR.FRONT_END,
        MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED,
        MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED_TAGS,
        MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
        MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD_STATE,
    }

    self.data_sidebar_idx = 1
    self.data_sidebar_root = self.data_sidebar

    -- dumped
    self.dumped = {
        name = "",
        values = {},
    }

    -- devtools
    if devtools then
        devtools.screen = self
    end
end

return DevToolsScreen
