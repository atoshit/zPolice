fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zSquad'
description 'zPolice'
version '1.0.0'

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
    'configuration/clientConfig.lua'
}

escrow_ignore {
    'configuration/*.lua'
}

dependencies {
    'es_extended',
    'esx_society',
    'esx_datastore'
}