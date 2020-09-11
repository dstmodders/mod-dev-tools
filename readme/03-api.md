# API

_**NB!** As the project matures, API will be extended to give you more control
over the mod._

API allows you to add you own submenu on the fly without bothering much with
dependencies as long as the global `DevToolsAPI` is available. For example, you
can create your mod-specific submenu from your mod with all the options you may
need throughout the development/testing, and it will be displayed along with
other Dev Tools submenus.

You can see how this API can be used from another mod by checking out my
[Auto-Join](https://steamcommunity.com/sharedfiles/filedetails/?id=1903101575)
mod as a real example:

- **Source Code**: [https://github.com/victorpopkov/dst-mod-auto-join/blob/master/scripts/autojoin/devtoolssubmenu.lua](https://github.com/victorpopkov/dst-mod-auto-join/blob/master/scripts/autojoin/devtoolssubmenu.lua)
- **Steam Workshop**: [https://steamcommunity.com/sharedfiles/filedetails/?id=1903101575](https://steamcommunity.com/sharedfiles/filedetails/?id=1903101575)

## Example

### 1. Get API and compare its version

The first step is to check whether the global `DevToolsAPI` is declared and
verify the version of our API:

```lua
if getmetatable(_G).__declared.DevToolsAPI then
    local API = _G.DevToolsAPI
    if API and API:GetAPIVersion() <= 1 then
        -- your call to add your submenu
    end
end
```

The API version is just a simple float number which will be increased upon
introducing new changes into the existing API. As long as there are no breaking
changes any upcoming version will either be equal or below `1` and the most
minor changes will be just a `0.01` increase.

For example, the current API version is `0.1` as I don't consider the API to be
stable enough since this mod is still in active development. As soon as it
becomes stable, its version will be marked as `1`.

If at some point a completely new API is introduced, it will be marked as `2` so
you could target that as `API:GetAPIVersion() > 1 and API:GetAPIVersion() <= 2`.

### 2. Add your submenu

There are 2 ways of creating a submenu:

1. Create a class extending `menu.Submenu`
2. Create a submenu data table

Each method has its own set of advantages, and you should choose the one that
fits you best.

For example, using the first method, you can create your submenu class:

```lua
require "class"

local Submenu = require "devtools/menu/submenu"

local YourSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Your Submenu", "YourSubmenu")

    -- options
    self:AddOptions()
    self:AddToRoot()
end)

function YourSubmenu:AddOptions()
    self:AddActionOption({
        label = "Your Option",
        on_accept_fn = function()
            print("Hello World!")
        end,
    })
end

return YourSubmenu
```

Then just require it:

```lua
API:AddSubmenu(require("path/to/your/automationsubmenu"))
```

The same submenu you can create using the 2nd method by using the data table:

```lua
API:AddSubmenu({
    label = "Your Submenu",
    name = "YourSubmenu",
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Your Option",
                on_accept_fn = function()
                    print("Hello World!")
                end,
            },
        },
    },
})
```

You can find plenty of examples just by exploring the current mod submenus:

[https://github.com/victorpopkov/dst-mod-dev-tools/tree/master/scripts/devtools/submenus](https://github.com/victorpopkov/dst-mod-dev-tools/tree/master/scripts/devtools/submenus)
