name = "Dev Tools"
version = "0.2.0-alpha"
description = [[Version: ]] .. version .. "\n\n" ..
    [[An extendable mod, that simplifies the most common tasks for both developers and testers as an alternative to debugkeys.]] .. "\n\n" ..
    [[v]] .. version .. [[:]] .. "\n" ..
    [[- Added support for the hide changelog configuration]] .. "\n" ..
    [[- Changed mod loading priority to be higher than the default]] .. "\n" ..
    [[- Enabled player vision submenu on non-admin servers]]
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
-- Helpers
--

local function AddConfig(label, name, options, default, hover)
    return { label = label, name = name, options = options, default = default, hover = hover or "" }
end

local function AddSection(title)
    return AddConfig(title, "", { { description = "", data = 0 } }, 0)
end

local function CreateKeyList()
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

    return list
end

local function CreateNumbersBetweenList(first, last)
    local list = {}
    for i = first, last do
        list[i - first + 1] = { description = i, data = i }
    end
    return list
end

--
-- Configuration
--

local key_list = CreateKeyList()
local labels_font_size_list = CreateNumbersBetweenList(6, 32)

local boolean = {
    { description = "Yes", data = true },
    { description = "No", data = false },
}

local labels_font_list = {
    { description = "Belisa... (50)", data = "UIFONT", hover = "Belisa Plumilla Manual (50)", },
    { description = "Belisa... (100)", data = "TITLEFONT", hover = "Belisa Plumilla Manual (100)" },
    { description = "Belisa... (Button)", data = "BUTTONFONT", hover = "Belisa Plumilla Manual (Button)" },
    { description = "Belisa... (Talking)", data = "TALKINGFONT", hover = "Belisa Plumilla Manual (Talking)" },
    { description = "Bellefair", data = "CHATFONT", hover = "Bellefair" },
    { description = "Bellefair Outline", data = "CHATFONT_OUTLINE", hover = "Bellefair Outline" },
    { description = "Hammerhead", data = "HEADERFONT", hover = "Hammerhead" },
    { description = "Henny Penny", data = "TALKINGFONT_WORMWOOD", hover = "Henny Penny (Wormwood)" },
    { description = "Mountains of...", data = "TALKINGFONT_HERMIT", hover = "Mountains of Christmas (Hermit)" },
    { description = "Open Sans", data = "DIALOGFONT", hover = "Open Sans" },
    { description = "PT Mono", data = "CODEFONT", hover = "PT Mono" },
    { description = "Spirequal Light", data = "NEWFONT", hover = "Spirequal Light" },
    { description = "Spirequal... S", data = "NEWFONT_SMALL", hover = "Spirequal Light (Small)" },
    { description = "Spirequal... O", data = "NEWFONT_OUTLINE", hover = "Spirequal Light Outline" },
    { description = "Spirequal... O/S", data = "NEWFONT_OUTLINE_SMALL", hover = "Spirequal Light Outline (Small)" },
    { description = "Stint Ultra...", data = "BODYTEXTFONT", hover = "Stint Ultra Condensed" },
    { description = "Stint Ultra... S", data = "SMALLNUMBERFONT", hover = "Stint Ultra Condensed (Small)" },
}

local reset_combinations = {
    { description = "Disabled", data = false, hover = "Reset will be completely disabled" },
    { description = "Ctrl + R", data = "ctrl_r" },
    { description = "Alt + R", data = "alt_r", },
    { description = "Shift + R", data = "shift_r" },
}

local username_labels_modes = {
    { description = "Default", data = "default", hover = "Default: white username labels" },
    { description = "Coloured", data = "coloured", hover = "Coloured: coloured username labels" },
}

configuration_options = {
    AddSection("Keybinds"),
    AddConfig("Toggle menu key", "key_menu_toggle", key_list, "KEY_RIGHTBRACKET", "Key used for toggling the in-game menu"),
    AddConfig("Movement prediction key", "key_movement_prediction", key_list, false, "Key used for toggling the movement prediction"),
    AddConfig("Pause key", "key_pause", key_list, "KEY_P", "Key used for pausing the game"),
    AddConfig("God mode key", "key_god_mode", key_list, "KEY_G", "Key used for toggling god mode"),
    AddConfig("Teleport key", "key_teleport", key_list, "KEY_T", "Key used for (fake) teleporting on mouse position"),
    AddConfig("Select entity key", "key_select_entity", key_list, "KEY_Z", "Key used for selecting an entity under mouse"),
    AddConfig("Increase time scale key", "key_time_scale_increase", key_list, "KEY_PAGEUP", "Key used to speed up the time scale.\nHold down the Shift key to scale up to the maximum"),
    AddConfig("Decrease time scale key", "key_time_scale_decrease", key_list, "KEY_PAGEDOWN", "Key used to slow down the time scale.\nHold down the Shift key to scale down to the minimum"),
    AddConfig("Default time scale key", "key_time_scale_default", key_list, "KEY_HOME", "Key used to restore the default time scale"),
    AddConfig("Reset combination", "reset_combination", reset_combinations, "ctrl_r", "Key combination used for reloading all mods.\nWill restart the game/server to the latest savepoint"),

    AddSection("General"),
    AddConfig("Default god mode", "default_god_mode", boolean, true, "Should the god mode be enabled by default?"),
    AddConfig("Default free crafting mode", "default_free_crafting", boolean, true, "Should the free crafting mode be enabled by default?"),

    AddSection("Labels"),
    AddConfig("Default labels font", "default_labels_font", labels_font_list, "BODYTEXTFONT", "Which labels font should be used by default?"),
    AddConfig("Default labels font size", "default_labels_font_size", labels_font_size_list, 18, "Which labels font size should be used by default?"),
    AddConfig("Default selected labels", "default_selected_labels", boolean, true, "Should the selected labels be enabled by default?"),
    AddConfig("Default username labels", "default_username_labels", boolean, true, "Should the username labels be enabled by default?"),
    AddConfig("Default username labels mode", "default_username_labels_mode", username_labels_modes, "default", "Which username labels mode should be used by default?"),

    AddSection("Player vision"),
    AddConfig("Default forced HUD visibility", "default_forced_hud_visibility", boolean, true, "Should the forced HUD visibility be enabled by default?"),
    AddConfig("Default forced unfading", "default_forced_unfading", boolean, true, "Should the forced unfading be enabled by default?"),

    AddSection("Other"),
    AddConfig("Disable mod warning", "default_mod_warning", boolean, true, "Should the mod warning be disabled?"),
    AddConfig("Hide changelog", "hide_changelog", boolean, true, "Should the changelog in the mod description be hidden?"),
    AddConfig("Debug", "debug", boolean, false, "Should the debug mode be enabled?"),
}
