const BULLET_SPRITE_RIGHT_ID as ubyte = 32
const BULLET_SPRITE_LEFT_ID as ubyte = 33
CONST LEFT as uByte = 0
CONST RIGHT as uByte = 1
CONST UP as uByte = 2
CONST DOWN as uByte = 3
CONST FIRE as uByte = 4

dim currentLife as UBYTE = 100
dim currentKeys as UBYTE = 0
dim currentItems as UBYTE = 0
dim moveScreen as ubyte
dim currentScreen as UBYTE = 0
dim animateEnemies as ubyte = 1
dim damagedByCollision as ubyte
dim currentBulletSpriteId as ubyte

dim protaFrame as ubyte = 0 
dim enemFrame as ubyte = 0 
dim animatedTilesFrame as ubyte = 0 

dim kempston as uByte
dim keyOption as String
dim keyArray(4) as uInteger

dim framec AS ubyte AT 23672

dim lastFrameProta as ubyte = 0
dim lastFrameOthers as ubyte = 0

#include "im2.bas"
#include "vortexTracker.bas"

load "" CODE ' Load vtplayer
load "" CODE ' Load music

#include "GuSprites.zxbas"
#include "../../output/tiles.bas"

InitGFXLib()

SetTileset(@tileSet)

#include "../../output/sprites.bas"
#include "../../output/config.bas"
#include "../../output/enemies.bas"
#include "../../output/soundEffects.bas"

#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include <memcopy.bas>
#include "const.bas"
#include "functions.bas"
#include "spritesTileAndPosition.bas"
#include "enemies.bas"
#include "bullet.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "sound.bas"
#include "music.bas"

menu:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    VortexTracker_Stop()
    dzx0Standard(@titleScreen, $4000)

    do
        let keyOption = Inkey$
    loop until keyOption = "1" OR keyOption = "2" OR keyOption = "3" 

    if keyOption = "1"
        let keyArray(LEFT) = KEYO
        let keyArray(RIGHT) = KEYP
        let keyArray(UP) = KEYQ
        let keyArray(DOWN) = KEYA
        let keyArray(FIRE) = KEYSPACE
    elseif keyOption = "2"
        kempston = 1
    elseif keyOption = "3"
        let keyArray(LEFT)=KEY6
        let keyArray(RIGHT)=KEY7
        let keyArray(UP)=KEY9
        let keyArray(DOWN)=KEY8
        let keyArray(FIRE)=KEY0
    end if

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentScreen = INITIAL_SCREEN

    VortexTracker_Inicializar(1)

    swapScreen()

    currentLife = INITIAL_LIFE
    currentKeys = 0
    currentItems = 0
    removeScreenObjectFromBuffer()
    initProta()
    setScreenElements()
    setEnemies()
    dzx0Standard(@hudScreen, $4000)
    redrawScreen()
    drawSprites()

    let lastFrameProta = framec
    let lastFrameOthers = framec
    do
        waitretrace

        if framec - lastFrameProta >= 3
            animateProta()
            let lastFrameProta = framec
        end if

        if framec - lastFrameOthers >= 10
            animateOthers()
            let lastFrameOthers = framec
        end if

        if not isJumping and landed
            damagedByCollision = 0
        end if
        protaMovement()
        moveEnemies()
        moveBullet()
        drawSprites()
        checkMoveScreen()
        checkRemainLife()
    loop

ending:
    VortexTracker_Stop()
    dzx0Standard(@endingScreen, $4000)
    pause 300
    pauseUntilPressKey()
    go to menu

gameOver:
    VortexTracker_Stop()
    PrintString("GAME OVER", 7, 12, 10)
    pause 300
    pauseUntilPressKey()
    go to menu

sub animateProta()
    protaFrame = getNextFrameRunning()
end sub

sub animateOthers()
    enemFrame = not enemFrame
    animateAnimatedTiles()
end sub

sub swapScreen()
    dzx0Standard(@map + screensOffsets(currentScreen), @decompressedMap)
end sub

sub animateAnimatedTiles()
    for i=0 to 2:
        if screenAnimatedTiles(currentScreen, i, 0) <> 0
            dim tile as ubyte = screenAnimatedTiles(currentScreen, i, 0) + screenAnimatedTiles(currentScreen, i, 3) + 1
            SetTileChecked(tile, attrSet(tile), screenAnimatedTiles(currentScreen, i, 1), screenAnimatedTiles(currentScreen, i, 2))
            let screenAnimatedTiles(currentScreen, i, 3) = not screenAnimatedTiles(currentScreen, i, 3)
        end if
    next i
end sub

sub stopMusicAndNirvana()
    musicStop()
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
end sub

sub checkRemainLife()
    if currentLife = 0
        ' enemiesDraw(1)
        go to gameOver
    end if
end sub

sub checkMoveScreen()
    if moveScreen <> 0
        moveToScreen(moveScreen)
        moveScreen = 0
        if ENEMIES_RESPAWN
            setEnemies()
        end if
    end if
end sub

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

stop

titleScreen:
    asm
        incbin "output/title.png.scr.zx0"
    end asm

hudScreen:
    asm
        incbin "output/hud.png.scr.zx0"
    end asm

endingScreen:
    asm
        incbin "output/ending.png.scr.zx0"
    end asm

map:
    asm
        incbin "output/map.bin.zx0"
    end asm