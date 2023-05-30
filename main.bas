#include "vendor/zxbne/zxbne.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()

load "" CODE ' Load vtplayer
load "" CODE ' Load music

dim generalLoopCounter as UBYTE

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
    generalLoopCounter = 0
    currentLife=100
    redrawScreen()
    Music_Init()
    gameLoop()

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm