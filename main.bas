' ----------------------------------------------------------------
' NIRVANA+ ENGINE DEMO - Boriel's ZX BASIC Compiler
'
' This program can be compiled as follows:
'
' zxb.exe nirvanadem.bas -t -O3
'
' After compiling it, use the following loader to execute:
'
' 10 CLEAR VAL "32767"
' 20 LOAD "NIRVANA+"CODE
' 30 LOAD ""CODE
' 40 RANDOMIZE USR VAL "32768"
' ----------------------------------------------------------------
#include "nirvana+.bas"
#include "lib/draw.bas"
#include "lib/game.bas"

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
