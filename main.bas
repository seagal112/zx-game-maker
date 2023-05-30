#include "vendor/zxbne/nirvana+.bas"
#include "vendor/zxbne/const.bas"
#include "vendor/zxbne/draw.bas"
#include "vendor/zxbne/game.bas"
#include "vendor/zxbne/sound.bas"
#include "vendor/zxbne/enemies.bas"

NIRVANAtiles(@btiles)
NIRVANAstart()

dim generalLoopCounter as UBYTE

load "" CODE ' Load vtplayer
load "" CODE ' Load music

Music_Init()

sub Music_Init()
    asm
    halt
    call 52000
    ld hl,52005
    ld (61947),hl
    ld a,$cd
    ld (61946),a
    end asm
end sub

menu:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentScreen = 0
    NIRVANAstop()
    mapDraw()
    NIRVANAstart()
    drawMenu()
    do
    loop while inkey$=""
    currentScreen=1

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    generalLoopCounter = 0
    currentLife=100
    printLife()
    mapDraw()
    enemiesDraw(0)
    gameLoop()

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm