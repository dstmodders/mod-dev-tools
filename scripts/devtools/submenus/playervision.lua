----
-- Map submenu.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module submenus.PlayerVision
-- @see menu.Submenu
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "devtools/constants"

local SDK = require "devtools/sdk/sdk/sdk"
local Toggle = require "devtools/submenus/option/toggle"

return {
    label = "Player Vision",
    name = "PlayerVisionSubmenu",
    options = {
        Toggle(
            "vision",
            "Forced HUD Visibility",
            "IsForcedHUDVisibility",
            "ToggleForcedHUDVisibility"
        ),
        Toggle(
            "vision",
            "Spawners Visibility",
            "IsSpawnersVisibility",
            "ToggleSpawnersVisibility"
        ),
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            options = {
                label = "Unfading",
                get = {
                    src = SDK.Vision,
                    name = "IsUnfading",
                    args = {},
                },
                set = {
                    src = SDK.Vision,
                    name = "ToggleUnfading",
                    args = {},
                },
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Hide Ground Overlay",
                on_accept_fn = function()
                    for i = 0, 2 do
                        TheWorld.Map["SetOverlayColor" .. i](TheWorld.Map, 0, 0, 0, 0)
                    end
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "CCT",
                choices = {
                    { name = "Default", value = tostring(MOD_DEV_TOOLS.CCT.DEFAULT) },
                    { name = "Empty", value = {} },
                    { name = "Beaver-Vision", value = MOD_DEV_TOOLS.CCT.BEAVER_VISION },
                    { name = "Ghost-Vision", value = MOD_DEV_TOOLS.CCT.GHOST_VISION },
                    { name = "Nightmare", value = MOD_DEV_TOOLS.CCT.NIGHTMARE },
                    { name = "Night-Vision", value = MOD_DEV_TOOLS.CCT.NIGHT_VISION },
                },
                on_get_fn = function()
                    return SDK.Player.Vision.GetCCTableOverride() or "nil"
                end,
                on_set_fn = function(_, _, value)
                    SDK.Player.Vision.SetCCTableOverride(value)
                end,
            },
        },
    },
}
