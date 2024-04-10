const PROTA_SPRITE as ubyte = 6
const BULLET_SPRITE_RIGHT_ID as ubyte = 48
const BULLET_SPRITE_LEFT_ID as ubyte = 49
const LEFT as uByte = 0
const RIGHT as uByte = 1
const UP as uByte = 2
const DOWN as uByte = 3
const FIRE as uByte = 4

dim currentLife as UBYTE = 100
dim currentKeys as UBYTE = 0
dim currentItems as UBYTE = 0
dim moveScreen as ubyte
dim currentScreen as UBYTE = 0
dim currentBulletSpriteId as ubyte

dim protaFrame as ubyte = 0 
dim enemFrame as ubyte = 0 

dim kempston as uByte
dim keyOption as String
dim keyArray(4) as uInteger

dim framec AS ubyte AT 23672

dim lastFrameProta as ubyte = 0
dim lastFrameOthers as ubyte = 0

const INVINCIBLE_FRAMES as ubyte = 25
dim invincible as ubyte = 0
dim invincibleFrame as ubyte = 0
dim invincibleBlink as ubyte = 0

#include "../../output/config.bas"

load "" CODE ' Load fx
load "" CODE ' Load files

#ifdef MUSIC_ENABLED
    #include "128/im2.bas"
    #include "128/vortexTracker.bas"
    #include "128/functions.bas"
    PaginarMemoria(4)
    load "" CODE ' Load vtplayer
    load "" CODE ' Load music
    PaginarMemoria(0)
#endif

#include "GuSprites.zxbas"

dim tileSet(191, 7) as ubyte at TILESET_DATA_ADDRESS
dim attrSet(191) as ubyte at ATTR_DATA_ADDRESS
dim sprites(47, 31) as ubyte at SPRITES_DATA_ADDRESS
dim screenObjectsInitial(SCREENS_COUNT, 3) as ubyte at SCREEN_OBJECTS_DATA_ADDRESS
dim screensOffsets(SCREENS_COUNT) as uInteger at SCREEN_OFFSETS_DATA_ADDRESS
dim enemiesInScreenOffsets(SCREENS_COUNT) as uInteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
dim animatedTilesInScreen(SCREENS_COUNT, MAX_ANIMATED_TILES_PER_SCREEN, 3) as ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS

InitGFXLib()
SetTileset(@tileSet)

dim spritesSet(49) as ubyte
dim spriteAddressIndex as uInteger = 0
for i = 0 to 47
    spritesSet(i) = Create2x2Sprite(@sprites + (32 * spriteAddressIndex))
    Draw2x2Sprite(spritesSet(i), 20, 20)
    spriteAddressIndex = spriteAddressIndex + 1
next i

#include "beepFx.bas"

#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include "functions.bas"
#include "spritesTileAndPosition.bas"
#include "enemies.bas"
#include "bullet.bas"
#include "draw.bas"
#include "protaMovement.bas"

menu:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    #ifdef MUSIC_ENABLED
        VortexTracker_Stop()
    #endif

    dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)

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

    #ifdef INIT_TEXTS
        for i=0 to 2
            showInitTexts(initTexts(i))
        next i
    #endif

    #ifdef MUSIC_ENABLED
        VortexTracker_Inicializar(1)
    #endif

    swapScreen()
    
    resetValues()

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

        protaMovement()
        moveEnemies()
        moveBullet()
        drawSprites()
        checkMoveScreen()
        checkRemainLife()
        checkInvincible()
    loop

ending:
    #ifdef MUSIC_ENABLED
        VortexTracker_Stop()
    #endif

    dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
    pause 300
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
    go to menu

gameOver:
    #ifdef MUSIC_ENABLED
        VortexTracker_Stop()
    #endif

    print at 7, 12; "GAME OVER"
    pause 300
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
    go to menu

sub resetValues()
    swapScreen()

    bulletPositionX = 0
    jumpCurrentKey = jumpStopValue

    invincible = 0
    invincibleFrame = 0
    invincibleBlink = 0

    currentLife = INITIAL_LIFE
    currentKeys = 2 mod 2
    currentKeys = 0
    currentItems = 0
    ' removeScreenObjectFromBuffer()
    saveSprite(PROTA_SPRITE, INITIAL_MAIN_CHARACTER_Y, INITIAL_MAIN_CHARACTER_X, 0, 1)
    setScreenElements()
    setEnemies()
    dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    for i = 0 to SCREENS_COUNT
        screensWon(i) = 0
    next i
    redrawScreen()
    ' drawSprites()
end sub

sub checkInvincible()
    if invincible = 1
        if framec - invincibleFrame >= INVINCIBLE_FRAMES
            invincible = 0
            invincibleFrame = 0
        end if
    end if
end sub

sub animateProta()
    protaFrame = getNextFrameRunning()
end sub

sub animateOthers()
    enemFrame = not enemFrame
    animateAnimatedTiles()
end sub

sub swapScreen()
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), @decompressedMap)
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), @decompressedEnemiesScreen)
    bulletPositionX = 0
end sub

sub animateAnimatedTiles()
    for i=0 to MAX_ANIMATED_TILES_PER_SCREEN:
        if animatedTilesInScreen(currentScreen, i, 0) <> 0
            dim tile as ubyte = animatedTilesInScreen(currentScreen, i, 0) + animatedTilesInScreen(currentScreen, i, 3) + 1
            SetTileChecked(tile, attrSet(tile), animatedTilesInScreen(currentScreen, i, 1), animatedTilesInScreen(currentScreen, i, 2))
            let animatedTilesInScreen(currentScreen, i, 3) = not animatedTilesInScreen(currentScreen, i, 3)
        end if
    next i
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
        ' if ENEMIES_RESPAWN
        '     setEnemies()
        ' end if
    end if
end sub

' sub debugA(value as UBYTE)
'     PRINT AT 18, 10; "----"
'     PRINT AT 18, 10; value
' end sub

' sub debugB(value as UBYTE)
'     PRINT AT 18, 15; "  "
'     PRINT AT 18, 15; value
' end sub

' sub debugC(value as UBYTE)
'     PRINT AT 18, 20; "  "
'     PRINT AT 18, 20; value
' end sub

' sub debugD(value as UBYTE)
'     PRINT AT 18, 25; "  "
'     PRINT AT 18, 25; value
' end sub