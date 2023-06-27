fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iamlation'
description 'A fun mining, smelting & selling resource for FiveM'
version '1.0.0'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}