#include "vendor/zxbne/nirvana+.bas"
#include "vendor/zxbne/draw.bas"
#include "vendor/zxbne/game.bas"
#include "vendor/zxbne/sound.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()


menu:
    INK 2: PAPER 1: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentScreen = 0
    mapDraw()
    drawMenu()
    do
    loop while inkey$=""
    currentScreen=1

playGame:
    INK 1: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentLife=100
    printLife()
    mapDraw()
    enemiesDraw(0)
    gameLoop()

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm