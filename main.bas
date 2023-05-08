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

' Set btiles address
NIRVANAtiles(@btiles)

' Activate NIRVANA ENGINE
NIRVANAstart()

mapDraw()

'NIRVANAdrawT(20, 16, 0)

DO

LOOP

btiles:
    asm
        incbin "assets/tiles.btile"
    end asm
