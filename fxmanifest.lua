fx_version 'cerulean'
lua54 'yes'
game 'gta5'
name 'lation_mining'
author 'iamlation'
version '2.0.1'
repository 'https://github.com/IamLation/lation_mining'
description 'A mining & smelting activity for FiveM with XP system & more'

client_scripts {
    'config/client.lua',
    'bridge/client.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/shared.lua',
    'bridge/server.lua',
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua',
    'config/icons.lua'
}

files {
    'locales/*.json',
    'install/images/*.png'
}

dependencies {
	'oxmysql',
	'ox_lib'
}

ox_libs {
    'locale',
    'math'
}