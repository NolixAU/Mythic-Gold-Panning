fx_version 'cerulean'

game 'gta5'
lua54 'yes'

client_script '@mythic-base/components/cl_error.lua'
client_script '@mythic-pwnzor/client/check.lua'

shared_scripts {
    'config/sh_goldpanning.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}