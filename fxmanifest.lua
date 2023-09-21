fx_version  'cerulean'
game        'gta5'

name        'qb-vehiclehandler'
description 'QBCore - Vehicle Handler'
version     '1.0.0'

shared_scripts {
    '@ox_lib/init.lua', -- disable if not using
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/class/vehicle.lua',
    'client/function.lua',
    'client/damage.lua',
    'client/seatbelt.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

lua54 'yes'
