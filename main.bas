#include "vendor/zxbne/nirvana+.bas"
#include "vendor/zxbne/draw.bas"
#include "vendor/zxbne/game.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()

INK 1: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS

currentScreen = 0

asm
    TOTAL_ROWS      EQU 20
end asm

'print enemies(1, 0, 1)
mapDraw()
enemiesDraw(0)
gameLoop()
btiles:
    asm
        incbin "assets/tiles.btile"
    end asm