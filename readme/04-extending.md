# Extending

This mod has been designed to be extendable in mind allowing any developer to
override pretty much any crucial part of it. You can completely override the
menu or data without bothering implementing your own user interface (UI).

Just load your mod right after this mod by setting the priority less than `0` in
your `modinfo` and just use `AddClassPostConstruct` on any part as you would
usually do in your `modmain`.

You can use this guide, to help you get started alongside the mod source code.
However, the recommended way of adding your own submenus is by using an `API`
approach. Check it out first to see if it matches your needs before proceeding.

## DevTools

First of all, we need to understand the structure behind the globally exposed
`DevTools` module which can be called directly through the console. It consists
of both world and player submodules which are initialized and added dynamically
based on the current game loading state.

For example, upon loading the world, all world-related submodules are
initialized and added as fields:

```
DevTools.world
DevTools.world.savedata
```

The same goes for the player. As soon as the user chooses the character, all
player-related submodules are initialized and added as fields as well:

```
DevTools.player
DevTools.player.console
DevTools.player.crafting
DevTools.player.inventory
DevTools.player.map
DevTools.player.vision
```

When the player decides to leave the game, all earlier added submodules with
their corresponding fields will be removed depending on their availability. For
example, despawning a character will terminate player-related submodules but
won't affect the world ones. However, disconnected from the current game will
terminate both of them.

Moreover, most of the methods within our submodules are dynamically added as
well, allowing you to directly call them right from the globally exposed
`DevTools`.

This approach allows you to have access to all possible features depending on
the game state from within a single entry point and have access to all the
methods from the in-game console directly.

## Example

To understand better, let's take a look at the following example where we extend
the current mod behaviour by introducing additional changes to existing
`devtools.player.MapDevTools` class by overriding it and by adding a new
`devtools.PlayerDevTools` submodule:

1. [Create your class](#1-create-your-class)
2. [Override parent class](#2-override-parent-class)
3. [Create your submenu](#3-create-your-submenu)
4. [Create your menu class](#4-create-your-menu-class)
5. [Override parent menu class](#5-override-parent-menu-class)

### 1. Create your class

As a first step, let's extend the class we are interested in. For example, let's
take a look at `devtools.player.MapDevTools` which instance we can already
access globally as `DevTools.player.map`:

```lua
local BaseMapDevTools = require "devtools/devtools/player/mapdevtools"
local DevTools = require "devtools/devtools/devtools"

local MapDevTools = Class(BaseMapDevTools, function(self, playerdevtools, devtools)
    BaseMapDevTools._ctor(self, playerdevtools, devtools)

    -- your logic and fields go here

    -- self
    self:DoInit()

    -- override PlayerDevTools:DoTerm()
    local OldDoTerm = playerdevtools.DoTerm
    playerdevtools.DoTerm = function(...)
        self:DoTerm()
        OldDoTerm(...)
    end
end)

-- your methods go here

function MapDevTools:DoInit()
    -- your initialization logic goes here
    DevTools.DoInit(self, self.playerdevtools, "map", {
        -- your methods to be added to global DevTools
    })
end

function MapDevTools:DoTerm()
    -- your termination logic goes here
    BaseMapDevTools.DoTerm(self)
end

return MapDevTools
```

Or we can add our class with our new functionality. For example let's create
`AutomationDevTools` class, an instance of which we will be able to access
globally as `DevTools.player.automation` as well:

```lua
local DevTools = require "devtools/devtools/devtools"

local AutomationDevTools = Class(DevTools, function(self, playerdevtools, devtools)
    DevTools._ctor(self, "AutomationDevTools", devtools)

    -- your logic and fields go here

    -- self
    self:DoInit()

    -- override PlayerDevTools:DoTerm()
    local OldDoTerm = playerdevtools.DoTerm
    playerdevtools.DoTerm = function(...)
        playerdevtools.automation:DoTerm()
        OldDoTerm(...)
    end
end)

-- your methods go here

function AutomationDevTools:DoInit()
    -- your initialization logic goes here
    DevTools.DoInit(self, self.playerdevtools, "automation", {
        -- your methods to be added to global DevTools
    })
end

function AutomationDevTools:DoTerm()
    -- your termination logic goes here
    DevTools.DoTerm(self)
end

return AutomationDevTools
```

We should end up with 2 classes:

- `AutomationDevTools`
- `MapDevTools`

The next step is that we need to initialize them so that we could integrate them
both into this mod.

### 2. Override parent class

In your `modmain`, use `AddClassPostConstruct` to initialize your classes. Since
in our example we are dealing with player-related classes we should attach to
`devtools.PlayerDevTools`:

```lua
AddClassPostConstruct("devtools/devtools/playerdevtools", function(playerdevtools, _, _, devtools)
    local AutomationDevTools = require "path/to/your/automationdevtools"
    local MapDevTools = require "path/to/your/mapdevtools"

    -- initialize
    AutomationDevTools(playerdevtools, devtools)
    MapDevTools(playerdevtools, devtools)
end)
```

After that we should have access to all our newly created methods directly
from the global `DevTools`. You can verify that they are there using the
in-game console.

You should have access to your submodules as well:

```
DevTools.player.automation
DevTools.player.map
```

As your next step, you will most likely want to extend the existing menu by
creating your submenus.

### 3. Create your submenu

There are 2 ways of creating a submenu:

1. Create a class extending `menu.Submenu`
2. Create a submenu data table

Each method has its own set of advantages, and you should choose the one that
fits you best.

For example, let's create "Automation..." submenu by extending `menu.Submenu`:

```lua
require "class"

local Submenu = require "devtools/menu/submenu"

local AutomationSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Automation", "AutomationSubmenu")

    -- options
    if self.automation then
        self:AddOptions()
        self:AddToRoot()
    end
end)

function AutomationSubmenu:AddOptions()
    -- your options go here
end

return AutomationSubmenu
```

As for the "Map..." submenu, let's create it using the submenu data table:

```lua
require "devtools/constants"

local Toggle = require "devtools/submenus/option/toggle"

return {
    label = "Map",
    name = "MapSubmenu",
    on_add_to_root_fn = {
        MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
        MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_MASTER_SIM,
    },
    options = {
        -- your options go here
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Reveal",
                on_accept_fn = function(_, submenu)
                    submenu.map:Reveal()
                    submenu.screen:Close()
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        Toggle("world", "Clearing", "IsMapClearing", "ToggleMapClearing"),
        Toggle("world", "Fog of War", "IsMapFogOfWar", "ToggleMapFogOfWar"),
    },
}
```

By the end of this step, we should end up with 2 submenu modules:

1. `AutomationSubmenu`
2. `Map`

In the next step, we should create our menu class, where we override the already
existing menu.

### 4. Create your menu class

Extend the existing `menu.Menu` by creating our child class:

```lua
require "class"
require "consolecommands"

local BaseMenu = require "devtools/menu/menu"

-- submenus
local AutomationSubmenu = require "path/to/your/automationsubmenu" -- our submenu path goes here
local CharacterRecipesSubmenu = require "devtools/submenus/characterrecipessubmenu"
local Labels = require "devtools/submenus/labels"
local Map = require "path/to/your/map" -- our submenu path goes here
local PlayerVision = require "devtools/submenus/playervision"

local Menu = Class(BaseMenu, function(self, screen, devtools)
    BaseMenu._ctor(self, screen, devtools)
end)

function Menu:AddPlayerSubmenus()
    local devtools = self.devtools
    local playerdevtools = devtools.player
    local worlddevtools = devtools.world

    if not worlddevtools:IsMasterSim() then
        self:AddToggleOption(
            { name = "Movement Prediction" },
            { src = playerdevtools, name = "IsMovementPrediction" },
            { src = playerdevtools, name = "ToggleMovementPrediction" }
        )
    end

    self:AddSubmenu(AutomationSubmenu) -- our submenu
    self:AddSubmenu(CharacterRecipesSubmenu)
    self:AddSubmenu(Labels)
    self:AddSubmenu(Map) -- our submenu
    self:AddSubmenu(PlayerVision)
    self:AddDividerOption()
end

return Menu
```

We will override `menu.Menu.AddPlayerSubmenus` method so that we only change the
general player-related submenus. You can always override `menu.Menu.AddMenu` if
you want to completely recreate the existing menu.

### 5. Override parent menu class

As a final step, we need to initialize our newly created menu by hooking into
the `screens.DevToolsScreen.UpdateMenu`:

```lua
AddClassPostConstruct("screens/devtoolsscreen", function(devtoolsscreen)
    local Menu = require "path/to/your/menu"

    -- override DevToolsScreen:UpdateMenu()
    devtoolsscreen.UpdateMenu = function(self, root_idx)
        local previous_idx = self.menu_text
            and self.menu_text:GetMenuIndex()
            or nil

        self.menu_text = Menu(self, self.devtools)
        self.menu_text:Update()

        local menu = self.menu_text:GetMenu()
        if root_idx and previous_idx and menu:GetMenu():AtRoot() then
            menu:GetMenu().index = root_idx
            menu:GetMenu():Accept()
            menu:GetMenu().index = previous_idx
        end
    end
end)
```

And yes, that's it. You should end up with your own general player-related set
of submenus where you will find both your "Automation..." and "Map..." submenus.

If you find difficulties and need an additional set of examples let me know but
in general, this should be enough to get you started.

Consider checking out `API` where you can add you own submenus on the fly.
