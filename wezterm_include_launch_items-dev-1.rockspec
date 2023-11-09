package = "wezterm_include_launch_items"
version = "1.0-1"
source = {
   url = "git://github.com/yourusername/yourrepository.git"
}
description = {
   summary = "A Lua script to include launch items in WezTerm",
   detailed = "This script updates the launch_menu.lua file in WezTerm to include new menu items based on the directories in a specified path.",
   homepage = "http://github.com/yourusername/yourrepository",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luafilesystem"
}
build = {
   type = "builtin",
   modules = {
      wezterm_include_launch_items = "wezterm_include_launch_items.lua"
   }
}
