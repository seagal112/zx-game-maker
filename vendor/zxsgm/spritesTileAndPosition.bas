const screenSpritesCount as ubyte = 8
const spritesDataCount as ubyte = 5
const FIRST_RUNNING_PROTA_SPRITE_RIGHT as ubyte = 0
const FIRST_RUNNING_PROTA_SPRITE_LEFT as ubyte = 4

DIM spritesLinColTileAndFrame(screenSpritesCount - 1, spritesDataCount - 1) as ubyte => { _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0}, _
    {0, 0, 0, 0, 0} _
}

const jumpStopValue as ubyte = 255
const jumpStepsCount as ubyte = 5
dim jumpCurrentKey as ubyte = jumpStopValue
dim jumpArray(jumpStepsCount - 1) AS byte = {-2, -2, -2, -2, -2}

function isJumping() as ubyte
    if jumpCurrentKey <> jumpStopValue
        return 1
    else
        return 0
    end if
end function

sub stopJumping()
    jumpCurrentKey = jumpStopValue
end sub

sub startJumping()
    jumpCurrentKey = 0
end sub

sub initProta()
    saveSprite(PROTA_SPRITE, INITIAL_MAIN_CHARACTER_Y, INITIAL_MAIN_CHARACTER_X, 0, 1)
end sub

sub saveSprite(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    spritesLinColTileAndFrame(sprite, 0) = lin
    spritesLinColTileAndFrame(sprite, 1) = col
    spritesLinColTileAndFrame(sprite, 2) = tile
    spritesLinColTileAndFrame(sprite, 3) = directionRight
    if spritesLinColTileAndFrame(sprite, 4) = 6
        spritesLinColTileAndFrame(sprite, 4) = 0
    else
        spritesLinColTileAndFrame(sprite, 4) = spritesLinColTileAndFrame(sprite, 4) + 1
    end if
end sub

function getSpriteLin(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 0)
end function

function getSpriteCol(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 1)
end function

function getSpriteTile(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 2)
end function

function getSpriteDirection(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 3)
end function

function getSpriteFrame(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 4)
end function

sub resetProtaSpriteToRunning()
    if getSpriteDirection(PROTA_SPRITE)
        saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE), FIRST_RUNNING_PROTA_SPRITE_RIGHT, getSpriteDirection(PROTA_SPRITE))
    else
        saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE), FIRST_RUNNING_PROTA_SPRITE_LEFT, getSpriteDirection(PROTA_SPRITE))
    end if
end sub

function onLastColumn(sprite) as ubyte
    if getSpriteCol(sprite) = 60
        return 1
    else
        return 0
    end if
end function

function onFirstColumn(sprite) as ubyte
    if getSpriteCol(sprite) = 0
        return 1
    else
        return 0
    end if
end function

sub protaBounce(toRight as ubyte)
    dim x as integer = getSpriteCol(PROTA_SPRITE)
    dim y as integer = getSpriteLin(PROTA_SPRITE)

    if not isEven(x)
        x = x - 1
    end if

    if not isEven(y)
        y = y - 1
    end if
    
    if toRight = 1
        saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE) + PROTA_BOUNCE_X_SIZE, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
    else
        saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE) - PROTA_BOUNCE_X_SIZE, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
    end if
end sub

sub removeScreenObjectFromBuffer()
    for i = 0 to 4
        for j = 0 to spritesDataCount - 1
            spritesLinColTileAndFrame(i, j) = 0
        next j
    next i
end sub