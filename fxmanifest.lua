fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iamlation'
description 'A fun mining & smelting job for FiveM'
version '1.1.1'

client_scripts {
    'bridge/client.lua',
    'client/*.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/*.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}