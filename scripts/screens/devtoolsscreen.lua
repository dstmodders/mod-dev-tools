----
-- Mod screen.
--
-- Includes a mod screen overlay holding both main menu and data widgets both of which are just
-- plain text ones.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod screens.DevToolsScreen
-- @see data.RecipeData
-- @see data.SelectedData
-- @see data.WorldData
-- @see menu.Menu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local Image = require "widgets/image"
local Menu = require "devtools/menu/menu"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Utils = require "devtools/utils"

local FrontEndData = require "devtools/data/frontenddata"
local RecipeData = require "devtools/data/recipedata"
local SelectedData = require "devtools/data/selecteddata"
local WorldData = require "devtools/data/worlddata"

local _SCREEN_NAME = "ModDevToolsScreen"

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @usage local devtoolsscreen = DevToolsScreen(screen, devtools)
local DevToolsScreen = Class(Screen, function(self, devtools)
    Screen._ctor(self, _SCREEN_NAME)

    -- widgets
    self.overlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.overlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.overlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.overlay:SetVAnchor(ANCHOR_MIDDLE)
    self.overlay:SetHAnchor(ANCHOR_MIDDLE)
    self.overlay:SetClickable(false)
    self.overlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.overlay:SetTint(0, 0, 0, .75)

    self.menu = self:AddChild(Text(BODYTEXTFONT, 16, ""))
    self.menu:SetHAlign(ANCHOR_LEFT)
    self.menu:SetHAnchor(ANCHOR_MIDDLE)
    self.menu:SetVAlign(ANCHOR_TOP)
    self.menu:SetVAnchor(ANCHOR_MIDDLE)
    self.menu:SetPosition(0, 0, 0)
    self.menu:SetRegionSize(640, 480)
    self.menu:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.data = self:AddChild(Text(BODYTEXTFONT, 16, ""))
    self.data:SetHAlign(ANCHOR_RIGHT)
    self.data:SetHAnchor(ANCHOR_MIDDLE)
    self.data:SetVAlign(ANCHOR_TOP)
    self.data:SetVAnchor(ANCHOR_MIDDLE)
    self.data:SetPosition(0, 0, 0)
    self.data:SetRegionSize(640, 480)
    self.data:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- self
    self:DoInit(devtools)

    -- TheFrontEnd
    TheFrontEnd:HideConsoleLog()
end)

--- General
-- @section general

--- Checks if screen can be toggled.
-- @treturn boolean
function DevToolsScreen:CanToggle() -- luacheck: only
    if global_error_widget then
        return false
    end

    if global_loading_widget and global_loading_widget.is_enabled then
        return false
    end

    if TheFrontEnd and TheFrontEnd.GetActiveScreen then
        local screen = TheFrontEnd:GetActiveScreen()
        if screen then
            if screen.name == "ConsoleScreen" then
                return false
            elseif screen.name == "ModConfigurationScreen" and TheFrontEnd.GetFocusWidget then
                local focusWidget = TheFrontEnd:GetFocusWidget()
                return focusWidget
                    and focusWidget.texture
                    and not (focusWidget.texture:find("spinner")
                    or (focusWidget.texture:find("arrow")
                    and not focusWidget.texture:find("scrollbar")))
            elseif screen.name == "ServerListingScreen"
                and screen.searchbox
                and screen.searchbox.textbox
                and screen.searchbox.textbox.editing
            then
                return false
            end
        end
    end

    local devtools = self.devtools

    if InGamePlay()
        and devtools
        and not devtools:IsInCharacterSelect()
    then
        local playerdevtools = devtools.player
        if playerdevtools and playerdevtools:IsHUDChatInputScreenOpen() then
            return false
        end
    end

    return true
end

--- Checks if screen is in open state.
-- @treturn boolean
function DevToolsScreen:IsOpen()
    local screen = TheFrontEnd:GetActiveScreen()
    return screen ~= nil and screen.name == self.name
end

--- Opens screen.
-- @treturn boolean
function DevToolsScreen:Open()
    self:DebugString(self.name, "opened")
    TheFrontEnd:PushScreen(self(self.devtools))
    return true
end

--- Closes screen.
-- @treturn boolean
function DevToolsScreen:Close()
    self:DebugString(self.name, "closed")
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

--- Switches data to front-end.
-- @see menu.submenu.Submenu.UpdateScreen
function DevToolsScreen:SwitchDataToFrontEnd()
    self.data_name = "front-end"
    self:UpdateData()
end

--- Switches data to recipe.
-- @see menu.submenu.Submenu.UpdateScreen
function DevToolsScreen:SwitchDataToRecipe()
    self.data_name = "recipe"
    self:UpdateData()
end

--- Switches data to selected.
-- @see menu.submenu.Submenu.UpdateScreen
function DevToolsScreen:SwitchDataToSelected()
    self.data_name = "selected"
    self:UpdateData()
end

--- Switches data to world.
-- @see menu.submenu.Submenu.UpdateScreen
function DevToolsScreen:SwitchDataToWorld()
    self.data_name = "world"
    self:UpdateData()
end

--- Switches data to nil.
-- @see menu.submenu.Submenu.UpdateScreen
function DevToolsScreen:SwitchDataToNil()
    self.data_name = nil
    self.data_text = nil
end

--- Update
-- @section update

--- Updates on each frame.
function DevToolsScreen:OnUpdate()
    if self:IsOpen() and self.devtools and not self.devtools:IsPaused() then
        self:UpdateData()
        self:UpdateChildren(true)
    end
end

--- Updates children.
-- @tparam boolean silent
function DevToolsScreen:UpdateChildren(silent)
    if self.menu_text ~= nil then
        self.menu:SetString(tostring(self.menu_text))
    end

    if self.data_text ~= nil then
        self.data:SetString(tostring(self.data_text))
    end

    if silent ~= true then
        self:DebugString("DevToolsScreen children updated")
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

--- Updates recipe data.
function DevToolsScreen:UpdateRecipeData()
    self.data_text = RecipeData(
        self.devtools,
        self.devtools.player.inventory,
        self.devtools.player.crafting:GetSelectedRecipe()
    )
end

--- Updates front-end data.
function DevToolsScreen:UpdateFrontEndData()
    self.data_text = FrontEndData(self.screen)
end

--- Updates selected data.
function DevToolsScreen:UpdateSelectedData()
    self.data_text = SelectedData(
        self.devtools,
        self.devtools.world,
        self.devtools.player,
        self.devtools.player.crafting,
        self.devtools.player:GetSelected(),
        self.is_selected_entity_data_visible
    )
end

--- Updates world data.
function DevToolsScreen:UpdateWorldData()
    self.data_text = WorldData(self.devtools.world)
end

--- Updates data.
-- @treturn data.RecipeData|data.SelectedData|data.WorldData
function DevToolsScreen:UpdateData()
    local devtools = self.devtools
    local playerdevtools = devtools.player
    local worlddevtools = devtools.world

    if self.data_name == "front-end" then
        self:UpdateFrontEndData()
    elseif self.data_name == "recipe"
        and playerdevtools
        and playerdevtools.crafting
        and playerdevtools.crafting:GetSelectedRecipe()
    then
        self:UpdateRecipeData()
    elseif self.data_name == "selected"
        and worlddevtools
        and playerdevtools
        and playerdevtools.crafting
        and playerdevtools:GetSelected()
    then
        self:UpdateSelectedData()
    elseif self.data_name == "world" and worlddevtools then
        self:UpdateWorldData()
    end

    return self.data_text
end

--- Input
-- @section input

--- Triggers when raw key is pressed.
-- @tparam number key
-- @tparam boolean down
-- @treturn boolean
function DevToolsScreen:OnRawKey(key, down)
    if DevToolsScreen._base.OnRawKey(self, key, down) then
        return true
    end

    local menu = self.menu_text:GetMenu()
    local option = menu and menu:GetOption()
    local option_name = option and option:GetName()

    if not down then
        if key == KEY_ESCAPE then
            if not menu:Cancel() then
                self:Close()
            end

            if menu:AtRoot() then
                if InGamePlay() then
                    self:SwitchDataToWorld()
                else
                    self:SwitchDataToNil()
                end
            end

            self:UpdateChildren(true)
        elseif key == KEY_ENTER then
            if InGamePlay() then
                if menu:AtRoot() and option_name == "LearnedBuilderRecipesSubmenu" then
                    self:SwitchDataToRecipe()
                elseif menu:AtRoot() and option_name == "SelectSubmenu" then
                    self.is_selected_entity_data_visible = true
                    self:SwitchDataToSelected()
                elseif menu:AtRoot()
                    and (option_name == "PlayerBarsSubmenu"
                    or option_name == "TeleportSubmenu")
                then
                    self.is_selected_entity_data_visible = false
                    self:SwitchDataToSelected()
                else
                    self:SwitchDataToWorld()
                end
            else
                self:SwitchDataToNil()
            end

            menu:Accept()

            self:UpdateData()
            self:UpdateChildren(true)
        else
            return false
        end
    else
        if key == KEY_UP then
            menu:Up()
            self:UpdateChildren(true)
        elseif key == KEY_DOWN then
            menu:Down()
            self:UpdateChildren(true)
        elseif key == KEY_LEFT then
            menu:Left()
            self:UpdateData()
            self:UpdateChildren(true)
        elseif key == KEY_RIGHT then
            menu:Right()
            self:UpdateData()
            self:UpdateChildren(true)
        else
            return false
        end
    end

    return true
end

--- Callbacks
-- @section callbacks

--- Triggers on becoming active.
function DevToolsScreen:OnBecomeActive()
    Utils.AssertRequiredField("DevToolsScreen.devtools", self.devtools)

    DevToolsScreen._base.OnBecomeActive(self)

    self:UpdateMenu()
    self:UpdateData()
    self:UpdateChildren()
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
-- @tparam DevTools devtools
function DevToolsScreen:DoInit(devtools)
    Utils.AddDebugMethods(self)

    -- general
    self.data_name = InGamePlay() and "world" or "front-end"
    self.data_text = nil
    self.devtools = devtools
    self.is_selected_entity_data_visible = true
    self.menu_text = nil
    self.name = _SCREEN_NAME

    -- devtools
    if devtools then
        devtools.screen = self
    end
end

return DevToolsScreen
