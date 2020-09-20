exclude_files = {
  "workshop/",
}

std = {
  max_code_line_length = 100,
  max_comment_line_length = 150,
  max_line_length = 100,
  max_string_line_length = 100,

  -- std.read_globals should include only the "native" Lua-related stuff
  read_globals = {
    "arg",
    "assert",
    "Class",
    "debug",
    "env",
    "getmetatable",
    "ipairs",
    "json",
    "math",
    "next",
    "os",
    "pairs",
    "print",
    "rawset",
    "require",
    "string",
    "table",
    "tonumber",
    "tostring",
    "type",
    "unpack",
  },
}

files["modinfo.lua"] = {
  max_code_line_length = 250,
  max_comment_line_length = 100,
  max_line_length = 100,
  max_string_line_length = 250,

  -- globals
  globals = {
    "all_clients_require_mod",
    "api_version",
    "author",
    "client_only_mod",
    "configuration_options",
    "description",
    "dont_starve_compatible",
    "dst_compatible",
    "folder_name",
    "forumthread",
    "icon",
    "icon_atlas",
    "name",
    "priority",
    "reign_of_giants_compatible",
    "shipwrecked_compatible",
    "version",
  },
}

files["modmain.lua"] = {
  max_code_line_length = 100,
  max_comment_line_length = 250,
  max_line_length = 100,
  max_string_line_length = 100,

  -- globals
  globals = {
    "GLOBAL",
  },
  read_globals = {
    "AddClassPostConstruct",
    "AddComponentPostInit",
    "GetModConfigData",
    "modname",
  },
}

files["scripts/**/*.lua"] = {
  max_code_line_length = 100,
  max_comment_line_length = 250,
  max_line_length = 100,
  max_string_line_length = 100,

  -- globals
  globals = {
    -- general
    "_G",
    "Networking_Say",
    "Point",
    "SendRPCToServer",
    "STRINGS",
    "TheWorld",

    -- project (general)
    "Debug",
    "DevTools",
    "DevToolsAPI",
    "MOD_DEV_TOOLS",

    -- project (console)
    "d_decodefile",
    "d_decodesavedata",
    "d_doaction",
    "d_dumpcomponents",
    "d_dumpeventlisteners",
    "d_dumpfields",
    "d_dumpfunctions",
    "d_dumpreplicas",
    "d_emote",
    "d_emotepose",
    "d_emotestop",
    "d_findinventoryitem",
    "d_findinventoryitems",
    "d_getanim",
    "d_getanimbank",
    "d_getanimbuild",
    "d_getcomponents",
    "d_geteventlisteners",
    "d_getfields",
    "d_getfunctions",
    "d_getreplicas",
    "d_getsg",
    "d_getsgstate",
    "d_gettags",
    "d_say",
    "d_says",
    "d_tablecompare",
    "d_tablecount",
    "d_tablehasvalue",
    "d_tablekeybyvalue",
    "d_tablemerge",
    "dumptable",
  },
  read_globals = {
    -- general
    "AccountManager",
    "AllPlayers",
    "AllRecipes",
    "BufferedAction",
    "ConsoleCommandPlayer",
    "Entity",
    "EntityScript",
    "GetDebugEntity",
    "GetTime",
    "GetValidRecipe",
    "global_error_widget",
    "global_loading_widget",
    "InGamePlay",
    "IsSpecialEventActive",
    "kleifileexists",
    "KnownModIndex",
    "Profile",
    "RPC",
    "RunInSandboxSafe",
    "SavePersistentString",
    "SetDebugEntity",
    "SetPause",
    "shallowcopy",
    "StartNextInstance",
    "TheCamera",
    "TheConfig",
    "TheCookbook",
    "TheFrontEnd",
    "TheGameService",
    "TheGlobalInstance",
    "TheInput",
    "TheInputProxy",
    "TheInventory",
    "TheMixer",
    "TheNet",
    "ThePlayer",
    "TheRecipeBook",
    "TheShard",
    "TheSim",
    "TheSystemService",
    "TrackedAssert",
    "Vector3",

    -- constants
    "ACTIONS",
    "ANCHOR_LEFT",
    "ANCHOR_MIDDLE",
    "ANCHOR_RIGHT",
    "ANCHOR_TOP",
    "BODYTEXTFONT",
    "BRANCH",
    "BUILDMODE",
    "BUTTONFONT",
    "CHATFONT",
    "CHATFONT_OUTLINE",
    "CODEFONT",
    "CONTROL_PRIMARY",
    "CONTROL_SECONDARY",
    "DEGREES",
    "DIALOGFONT",
    "ENCODE_SAVES",
    "EQUIPSLOTS",
    "FRAMES",
    "FUELTYPE",
    "GROUND",
    "HEADERFONT",
    "KEY_DOWN",
    "KEY_ENTER",
    "KEY_ESCAPE",
    "KEY_LEFT",
    "KEY_RIGHT",
    "KEY_SHIFT",
    "KEY_TAB",
    "KEY_UP",
    "LANGUAGE",
    "LOC",
    "NEWFONT",
    "NEWFONT_OUTLINE",
    "NEWFONT_OUTLINE_SMALL",
    "NEWFONT_SMALL",
    "PREFAB_SKINS_IDS",
    "SCALEMODE_FILLSCREEN",
    "SCALEMODE_PROPORTIONAL",
    "SMALLNUMBERFONT",
    "SPECIAL_EVENTS",
    "TALKINGFONT",
    "TALKINGFONT_HERMIT",
    "TALKINGFONT_WORMWOOD",
    "TITLEFONT",
    "TUNING",
    "UIFONT",
    "USER_HISTORY_EXPIRY_TIME",
    "WHITE",

    -- threads
    "KillThreadsWithID",
    "scheduler",
    "Sleep",
    "StartThread",
  },
}

files["spec/**/*.lua"] = {
  max_code_line_length = 100,
  max_comment_line_length = 250,
  max_line_length = 100,
  max_string_line_length = 100,

  -- globals
  globals = {
    -- general
    "_G",
    "Class",
    "ClassRegistry",
    "package",
    "rawget",
    "table",

    -- project
    "AssertAddedMethodsAfter",
    "AssertAddedMethodsBefore",
    "AssertChainNil",
    "AssertGetter",
    "AssertMethodExists",
    "AssertMethodIsMissing",
    "AssertSetter",
    "DebugSpy",
    "DebugSpyAssert",
    "DebugSpyAssertWasCalled",
    "DebugSpyClear",
    "DebugSpyInit",
    "DebugSpyTerm",
    "Empty",
    "MockDevTools",
    "MockInventoryReplica",
    "MockPlayerDevTools",
    "MockPlayerInst",
    "MockRPCClear",
    "MockRPCInit",
    "MockRPCTerm",
    "MockTheNet",
    "MockTheSim",
    "MockWorldDevTools",
    "MockWorldInst",
    "ReturnValueFn",
    "ReturnValues",
    "ReturnValuesFn",
    "TableCount",
    "TableCountFunctions",
    "TableHasValue",
  },
  read_globals = {
    -- general
    "ConsoleCommandPlayer",
    "GetDebugEntity",
    "SetDebugEntity",
    "setmetatable",
    "shallowcopy",
    "TheInput",
    "TheNet",
    "TheSim",

    -- project (console)
    "d_decodefile",
  },
}
