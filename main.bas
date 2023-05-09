#include "vendor/zxbne/nirvana+.bas"
#include "vendor/zxbne/draw.bas"
#include "vendor/zxbne/game.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()

INK 1: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS

mapDraw()
gameLoop()
'NIRVANAdrawT(20, 16, 0)

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm
