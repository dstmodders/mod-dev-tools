name = "Dev Tools"
version = "0.7.0-alpha"
description = [[Version: ]] .. version .. "\n\n" ..

    [[An extendable mod, that simplifies the most common tasks for both developers and testers ]] ..
    [[as an alternative to debugkeys.]] .. "\n\n" ..

    [[v]] .. version .. [[:]] .. "\n" ..
    [[- Added support for the dumped data sidebar]] .. "\n" ..
    [[- Changed dump submenu]] .. "\n" ..
    [[- Refactored modinfo]]
author = "Demonblink"
api_version = 10
forumthread = ""

-- We need to load our mod with a higher priority than other, so we use a non-default value (0). The
-- "2220506640" part is the workshop ID of this mod, so other mods had enough "space for manoeuvre".
priority = 1.02220506640

icon = "modicon.tex"
icon_atlas = "modicon.xml"

all_clients_require_mod = false
client_only_mod = true
dont_starve_compatible = false
dst_compatible = true
reign_of_giants_compatible = false
shipwrecked_compatible = false

folder_name = folder_name or "dst-mod-dev-tools"
if not folder_name:find("workshop-") then
    name = name .. " (dev)"
end

--
-- Configuration
--

local function AddConfig(name, label, hover, options, default)
    return { label = label, name = name, options = options, default = default, hover = hover or "" }
end

local function AddBooleanConfig(name, label, hover, default)
    default = default == nil and true or default
    return AddConfig(name, label, hover, {
        { description = "Enabled", data = true },
        { description = "Disabled", data = false },
    }, default)
end

local function AddKeyListConfig(name, label, hover, default)
    if default == nil then
        default = false
    end

    -- helpers
    local function AddDisabled(t)
        t[#t + 1] = { description = "Disabled", data = false }
    end

    local function AddKey(t, key)
        t[#t + 1] = { description = key, data = "KEY_" .. key:gsub(" ", ""):upper() }
    end

    local function AddKeysByName(t, names)
        for i = 1, #names do
            AddKey(t, names[i])
        end
    end

    local function AddAlphabetKeys(t)
        local string = ""
        for i = 1, 26 do
            AddKey(t, string.char(64 + i))
        end
    end

    local function AddTypewriterNumberKeys(t)
        for i = 1, 10 do
            AddKey(t, "" .. (i % 10))
        end
    end

    local function AddTypewriterModifierKeys(t)
        AddKeysByName(t, { "Alt", "Ctrl", "Shift" })
    end

    local function AddTypewriterKeys(t)
        AddAlphabetKeys(t)
        AddKeysByName(t, {
            "Slash",
            "Backslash",
            "Period",
            "Semicolon",
            "Left Bracket",
            "Right Bracket",
        })
        AddKeysByName(t, { "Space", "Tab", "Backspace", "Enter" })
        AddTypewriterModifierKeys(t)
        AddKeysByName(t, { "Tilde" })
        AddTypewriterNumberKeys(t)
        AddKeysByName(t, { "Minus", "Equals" })
    end

    local function AddFunctionKeys(t)
        for i = 1, 12 do
            AddKey(t, "F" .. i)
        end
    end

    local function AddArrowKeys(t)
        AddKeysByName(t, { "Up", "Down", "Left", "Right" })
    end

    local function AddNavigationKeys(t)
        AddKeysByName(t, { "Insert", "Delete", "Home", "End", "Page Up", "Page Down" })
    end

    -- key list
    local list = {}

    AddDisabled(list)
    AddArrowKeys(list)
    AddFunctionKeys(list)
    AddTypewriterKeys(list)
    AddNavigationKeys(list)
    AddKeysByName(list, { "Escape", "Pause", "Print" })

    return AddConfig(name, label, hover, list, default)
end

local function AddNumbersConfig(name, label, hover, first, last, default)
    local list = {}

    for i = first, last do
        list[i - first + 1] = { description = i, data = i }
    end

    return AddConfig(name, label, hover, list, default)
end

local function AddSection(title)
    return AddConfig("", title, nil, { { description = "", data = 0 } }, 0)
end

configuration_options = {
    --
    -- Keybinds
    --

    AddSection("Keybinds"),

    AddKeyListConfig(
        "key_toggle_tools",
        "Toggle tools key",
        "Key used for toggling the tools",
        "KEY_RIGHTBRACKET"
    ),

    AddKeyListConfig(
        "key_switch_data",
        "Switch data key",
        "Key used for switching data sidebar",
        "KEY_X"
    ),

    AddKeyListConfig(
        "key_select",
        "Select key",
        "Key used for selecting between menu and data sidebar",
        "KEY_TAB"
    ),

    AddKeyListConfig(
        "key_movement_prediction",
        "Movement prediction key",
        "Key used for toggling the movement prediction"
    ),

    AddKeyListConfig(
        "key_pause",
        "Pause key",
        "Key used for pausing the game",
        "KEY_P"
    ),

    AddKeyListConfig(
        "key_god_mode",
        "God mode key",
        "Key used for toggling god mode",
        "KEY_G"
    ),

    AddKeyListConfig(
        "key_teleport",
        "Teleport key",
        "Key used for (fake) teleporting on mouse position",
        "KEY_T"
    ),

    AddKeyListConfig(
        "key_select_entity",
        "Select entity key",
        "Key used for selecting an entity under mouse",
        "KEY_Z"
    ),

    AddKeyListConfig(
        "key_time_scale_increase",
        "Increase time scale key",
        [[Key used to speed up the time scale.]] .. "\n" ..
            [[Hold down the Shift key to scale up to the maximum]],
        "KEY_PAGEUP"
    ),

    AddKeyListConfig(
        "key_time_scale_decrease",
        "Decrease time scale key",
        [[Key used to slow down the time scale.]] .. "\n" ..
            [[Hold down the Shift key to scale down to the minimum]],
        "KEY_PAGEDOWN"
    ),

    AddKeyListConfig(
        "key_time_scale_default",
        "Default time scale key",
        "Key used to restore the default time scale",
        "KEY_HOME"
    ),

    AddConfig(
        "reset_combination",
        "Reset combination",
        [[Key combination used for reloading all mods.]] .. "\n" ..
            [[Will restart the game/server to the latest savepoint]],
        {
            { description = "Disabled", hover = "Reset will be completely disabled", data = false },
            { description = "Ctrl + R", data = "ctrl_r" },
            { description = "Alt + R", data = "alt_r", },
            { description = "Shift + R", data = "shift_r" },
        },
        "ctrl_r"
    ),

    --
    -- General
    --

    AddSection("General"),

    AddBooleanConfig(
        "default_god_mode",
        "Default god mode",
        "When enabled, enables god mode by default.\nCan be changed inside in-game menu"
    ),

    AddBooleanConfig(
        "default_free_crafting",
        "Default free crafting mode",
        "When enabled, enables crafting mode by default.\nCan be changed inside in-game menu"
    ),

    AddSection("Labels"),

    AddConfig(
        "default_labels_font",
        "Default labels font",
        "Which labels font should be used by default?\nCan be changed inside in-game menu",
        {
            {
                description = "Belisa... (50)",
                hover = "Belisa Plumilla Manual (50)",
                data = "UIFONT",
            },
            {
                description = "Belisa... (100)",
                hover = "Belisa Plumilla Manual (100)",
                data = "TITLEFONT",
            },
            {
                description = "Belisa... (Button)",
                hover = "Belisa Plumilla Manual (Button)",
                data = "BUTTONFONT",
            },
            {
                description = "Belisa... (Talking)",
                hover = "Belisa Plumilla Manual (Talking)",
                data = "TALKINGFONT",
            },
            {
                description = "Bellefair",
                hover = "Bellefair",
                data = "CHATFONT",
            },
            {
                description = "Bellefair Outline",
                hover = "Bellefair Outline",
                data = "CHATFONT_OUTLINE",
            },
            {
                description = "Hammerhead",
                hover = "Hammerhead",
                data = "HEADERFONT",
            },
            {
                description = "Henny Penny",
                hover = "Henny Penny (Wormwood)",
                data = "TALKINGFONT_WORMWOOD",
            },
            {
                description = "Mountains of...",
                hover = "Mountains of Christmas (Hermit)",
                data = "TALKINGFONT_HERMIT",
            },
            {
                description = "Open Sans",
                hover = "Open Sans",
                data = "DIALOGFONT",
            },
            {
                description = "PT Mono",
                hover = "PT Mono",
                data = "CODEFONT",
            },
            {
                description = "Spirequal Light",
                hover = "Spirequal Light",
                data = "NEWFONT",
            },
            {
                description = "Spirequal... S",
                hover = "Spirequal Light (Small)",
                data = "NEWFONT_SMALL",
            },
            {
                description = "Spirequal... O",
                hover = "Spirequal Light Outline",
                data = "NEWFONT_OUTLINE",
            },
            {
                description = "Spirequal... O/S",
                hover = "Spirequal Light Outline (Small)",
                data = "NEWFONT_OUTLINE_SMALL",
            },
            {
                description = "Stint Ultra...",
                hover = "Stint Ultra Condensed",
                data = "BODYTEXTFONT",
            },
            {
                description = "Stint Ultra... S",
                hover = "Stint Ultra Condensed (Small)",
                data = "SMALLNUMBERFONT",
            },
        },
        "BODYTEXTFONT"
    ),

    AddNumbersConfig(
        "default_labels_font_size",
        "Default labels font size",
        "Which labels font size should be used by default?\nCan be changed inside in-game menu",
        6,
        32,
        18
    ),

    AddBooleanConfig(
        "default_selected_labels",
        "Default selected labels",
        "When enabled, show selected labels by default.\nCan be changed inside in-game menu"
    ),

    AddBooleanConfig(
        "default_username_labels",
        "Default username labels",
        "When enabled, shows username labels by default.\nCan be changed inside in-game menu"
    ),

    AddConfig(
        "default_username_labels_mode",
        "Default username labels mode",
        "Which username labels mode should be used by default?\nCan be changed inside in-game menu",
        {
            {
                description = "Default",
                hover = "Default: white username labels",
                data = "default",
            },
            {
                description = "Coloured",
                hover = "Coloured: coloured username labels",
                data = "coloured",
            },
        },
        "default"
    ),

    --
    -- Player Vision
    --

    AddSection("Player vision"),

    AddBooleanConfig(
        "default_forced_hud_visibility",
        "Default forced HUD visibility",
        [[When enabled, forces HUD visibility when "playerhuddirty" event occurs.]] .. "\n" ..
            [[Can be changed inside in-game menu]]
    ),

    AddBooleanConfig(
        "default_forced_unfading",
        "Default forced unfading",
        [[When enabled, forces unfading when "playerfadedirty" event occurs.]] .. "\n" ..
            [[Can be changed inside in-game menu]]
    ),

    --
    -- Other
    --

    AddSection("Other"),

    AddBooleanConfig(
        "default_mod_warning",
        "Disable mod warning",
        "When enabled, disables the mod warning when starting the game"
    ),

    AddBooleanConfig(
        "hide_changelog",
        "Hide changelog",
        [[When enabled, hides the changelog in the mod description.]] .. "\n" ..
            [[Mods should be reloaded to take effect]]
    ),

    AddBooleanConfig(
        "debug",
        "Debug",
        "When enabled, displays debug data in the console.\nUsed mainly for development",
        false
    ),
}
