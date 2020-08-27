project = "Dev Tools"
title = "DST Mod Dev Tools | LDoc"
description = "dst-mod-dev-tools"
full_description = "Mod for the game [Don\'t Starve Together](https://www.klei.com/games/dont-starve-together) to improve the development process."

dir = "doc"
file = "./scripts/"
format = "markdown"
readme = "readme"
sort_modules = true
style = "./doc/ldoc/"
use_markdown_titles = true

custom_see_handler("^MOD_STATUS_BADGES\.(.*)$", function(name)
    name = "MOD_STATUS_BADGES." .. name
    return name, "../modules/Constants.html#" .. name
end)
