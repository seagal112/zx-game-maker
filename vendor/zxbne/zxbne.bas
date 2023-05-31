#include "nirvana+.bas"
#include "const.bas"
#include "draw.bas"
#include "game.bas"
#include "sound.bas"
#include "enemies.bas"
#include "music.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()

load "" CODE ' Load vtplayer
load "" CODE ' Load music

menu:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentScreen = 0
    mapDraw()
    drawMenu()
    do
    loop while inkey$=""
    currentScreen=1

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentLife=INITIAL_LIFE
    redrawScreen()
    Music_Init()
    gameLoop()

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm