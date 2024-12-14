fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zSquad'
description 'zPolice'
version '1.0.0'

server_scripts {
    'configuration/serverConfig.lua'
}

client_scripts {
    'configuration/clientConfig.lua'
}

escrow_ignore {
    'configuration/*.lua'
}
