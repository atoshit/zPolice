fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'zSquad'
description 'zPolice'
version '1.0.0'

files {
    "zUI/menus/theme.json",
    "zUI/notifications/theme.json",
    "zUI/contextMenus/theme.json",
    "zUI/modals/theme.json",
    "zUI/user-interface/build/index.html",
    "zUI/user-interface/build/**/*"
}

ui_page "zUI/user-interface/build/index.html"

shared_scripts {
    'configuration/mainConfig.lua',
    'shared/debug.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configuration/serverConfig.lua',
    'server/societyRegistration.lua'
}

client_scripts {
    "zUI/*.lua",
    "zUI/items/*.lua",
    "zUI/menus/_init.lua",
    "zUI/menus/menu.lua",
    "zUI/menus/methods/*.lua",
    "zUI/menus/functions/*.lua",
    "zUI/notifications/*.lua",
    "zUI/contextMenus/components/*.lua",
    "zUI/contextMenus/*.lua",
    "zUI/contextMenus/functions/*.lua",
    "zUI/modals/*.lua",

    'client/menu/_init.lua',
    'configuration/clientConfig.lua',
    'client/classes/point.lua',
    'client/menu/receptionMenu.lua',
    'client/receptionCall.lua'
}

escrow_ignore {
    'configuration/*.lua'
}

dependencies {
    'es_extended',
    'esx_society',
    'esx_datastore',
    'esx_skin'
}