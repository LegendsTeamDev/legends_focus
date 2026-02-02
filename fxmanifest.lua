fx_version 'cerulean'
game 'gta5'

name 'Legends Focus'
author 'Legends Scripts'
version '1.0.2'
description 'FOV Focus with key hold functionality'

lua54 'yes'

shared_scripts {
    'config/*.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua'
}

escrow_ignore {
  'config/*.lua'

}

