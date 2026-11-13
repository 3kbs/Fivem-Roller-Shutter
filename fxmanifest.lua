fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'roller_shutter'
description 'Animated storefront roller shutters (prop_roller_shutter) with synced open/closed state'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'stream/roller_shutter.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/roller_shutter.ytyp'
