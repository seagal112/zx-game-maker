Dim currentLife as UBYTE = 100
Dim currentKeys as UBYTE = 0
Dim currentItems as UBYTE = 0
dim moveScreen as ubyte
Dim currentScreen as UBYTE = 0
dim animateEnemies as ubyte = 1

dim key_lin as ubyte = 0
dim key_col as ubyte = 0
dim key_sprite as ubyte = 0

dim item_lin as ubyte = 0
dim item_col as ubyte = 0
dim item_sprite as ubyte = 0

' #include "nirvana+.bas"
#include "GuSprites.zxbas"

InitGFXLib()

Dim tileSet(11,7) as uByte => { _ 
    {0, 0, 0, 0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0, 0, 0, 0}, _
    {255, 255, 192, 192, 192, 192, 192, 192}, _
    {192, 192, 192, 192, 192, 192, 255, 255}, _
    {255, 255, 3, 3, 3, 3, 3, 3}, _
    {3, 3, 3, 3, 3, 3, 255, 255}, _
    {255, 128, 128, 128, 128, 128, 128, 128}, _
    {128, 128, 128, 128, 128, 128, 128, 255}, _
    {255, 1, 1, 1, 1, 1, 1, 1}, _
    {1, 1, 1, 1, 1, 1, 1, 255} _
}

SetTileset(@tileSet)

#include "../../assets/sprites.bas"

#include "const.bas"
#include "functions.bas"
#include "spritesTileAndPosition.bas"
#include "../../output/maps.bas"
#include "../../output/enemies.bas"
#include "screenRender.bas"
#include "enemies.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "sound.bas"
#include "music.bas"
#include <zx0.bas>

menu:
    ' stopMusicAndNirvana()
    dzx0Standard(@titleScreen, $4000)
    pauseUntilPressKey()
    currentScreen = INITIAL_SCREEN

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentLife = INITIAL_LIFE
    currentKeys = 0
    initProta()
    mapDraw()
    drawSprites()
    ' setScreenElements()
    do
        protaMovement()
        ' moveEnemies()
        drawSprites()
        checkMoveScreen()
        ' checkRemainLife()
    loop

ending:
    ' stopMusicAndNirvana()
    ' dzx0Standard(@endingScreen, $4000)
    ' do
    ' loop while inkey$ = ""
    go to menu


sub stopMusicAndNirvana()
    musicStop()
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
end sub

sub checkRemainLife()
    if currentLife = 0
        removePlayer()
        ' enemiesDraw(1)
        go to ending
    end if
end sub

sub checkMoveScreen()
    if moveScreen <> 0
        moveToScreen(moveScreen)
        moveScreen = 0
    end if
end sub

' btiles:
'     asm
'         incbin "assets/tiles.btile"
'     end asm

titleScreen:
    asm
        incbin "output/title.png.scr.zx0"
    end asm

' endingScreen:
'     asm
'         incbin "output/ending.png.scr.zx0"
'     end asm

sub debugA(value as UBYTE)
    PRINT AT 18, 10; "----"
    PRINT AT 18, 10; value
end sub

sub debugB(value as UBYTE)
    PRINT AT 18, 15; "  "
    PRINT AT 18, 15; value
end sub

sub debugC(value as UBYTE)
    PRINT AT 18, 20; "  "
    PRINT AT 18, 20; value
end sub

sub debugD(value as UBYTE)
    PRINT AT 18, 25; "  "
    PRINT AT 18, 25; value
end sub

sub resetItems()
    item_lin = 0
    item_col = 0
    item_sprite = 0
end sub

sub resetKeys()
    key_lin = 0
    key_col = 0
    key_sprite = 0
end sub

sub resetItemsAndKeys()
    resetItems()
    resetKeys()
end sub