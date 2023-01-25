project = "Dev Tools"
title = "DST Mod Dev Tools | LDoc"
description = "mod-dev-tools"
full_description = "Mod for the game [Don\'t Starve Together](https://www.klei.com/games/dont-starve-together) to improve the development/testing experience." .. "\n\n" ..
    [[- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)]] .. "\n" ..
    [[- **Steam Workshop:** [https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640](https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640)]]

dir = "doc"
file = "./scripts/"
format = "markdown"
readme = "readme"
sort_modules = true
style = "./doc/ldoc/"
use_markdown_titles = true

custom_see_handler("^MOD_DEV_TOOLS\.(.*)$", function(name)
    name = "MOD_DEV_TOOLS." .. name
    return name, "../modules/Constants.html#" .. name
end)
