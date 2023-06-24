-- FX Information --
fx_version "cerulean"
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game "gta5"

-- Resource Information --
name 'hanescripts-core'
author 'zeixna'
version '1.0.0'
repository 'https://github.com/berkormanli/hanescripts-core'
description 'A core script to reduce repetitive code and minimize configuration in Hane Scripts which aims to increase both efficiency and productivity.'

-- Manifest  --
dependencies {
    '/server:5848',                -- requires at least server build 5848
    '/onesync',                    -- requires state awareness to be enabled
    '/gameBuild:mpsum2',           -- requires at least game build 2189
}

files {
    'init.lua'
}

shared_scripts {
    "config.lua"
}

server_scripts {
    "server/main.lua",
    "server/functions.lua",
    "bridge/**/server.lua"
}

client_scripts {
    "client/main.lua",
    "client/functions.lua",
    "bridge/**/client.lua"
}
