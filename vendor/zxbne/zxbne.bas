#include "nirvana+.bas"
#include "const.bas"
#include "draw.bas"
#include "game.bas"
#include "sound.bas"
#include "enemies.bas"
#include "music.bas"
#include <zx0.bas>

NIRVANAtiles(@btiles)

load "" CODE ' Load vtplayer
load "" CODE ' Load music

menu:
    musicStop()
    NIRVANAstop()
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    dzx0Standard(@titleScreen, $4000)
    do
    loop while inkey$ = ""
    currentScreen = INITIAL_SCREEN

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    NIRVANAstart()
    currentLife = INITIAL_LIFE
    currentKeys = 0
    redrawScreen()
    musicStart()
    gameLoop()

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm

titleScreen:
    asm
        incbin "output/title.png.scr.zx0"
    end asm