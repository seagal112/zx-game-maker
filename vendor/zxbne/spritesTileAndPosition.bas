const screenSpritesCount as ubyte = 8
const spritesDataCount as ubyte = 4

DIM spritesLinColAndTile0(screenSpritesCount - 1, spritesDataCount - 1) as ubyte => { _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0} _
}

DIM spritesLinColAndTile1(screenSpritesCount - 1, spritesDataCount - 1) as ubyte => { _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0} _
}

const jumpStopValue as ubyte = 255
const jumpStepsCount as ubyte = 6
dim jumpCurrentKey as ubyte = jumpStopValue
dim jumpArray(jumpStepsCount - 1) AS byte = {-2, -2, -2, -4, -2, -2}

function isJumping() as ubyte
    if jumpCurrentKey <> jumpStopValue
        return 1
    else
        return 0
    end if
end function

function stopJumping()
    jumpCurrentKey = jumpStopValue
end function

function startJumping()
    jumpCurrentKey = 0
end function

sub initProta()
    saveOldSpriteState(PROTA_SPRITE, 24, 10, 0, 1)
    saveNewSpriteState(PROTA_SPRITE, 24, 10, 0, 1)
end sub

sub saveOldSpriteState(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    spritesLinColAndTile0(sprite, 0) = lin
    spritesLinColAndTile0(sprite, 1) = col
    spritesLinColAndTile0(sprite, 2) = tile
    spritesLinColAndTile0(sprite, 3) = directionRight
end sub

sub saveNewSpriteState(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    spritesLinColAndTile1(sprite, 0) = lin
    spritesLinColAndTile1(sprite, 1) = col
    spritesLinColAndTile1(sprite, 2) = tile
    spritesLinColAndTile1(sprite, 3) = directionRight
end sub

function getOldSpriteStateLin(sprite as ubyte) as ubyte
    return spritesLinColAndTile0(sprite, 0)
end function

function getOldSpriteStateCol(sprite as ubyte) as ubyte
    return spritesLinColAndTile0(sprite, 1)
end function

function getOldSpriteStateTile(sprite as ubyte) as ubyte
    return spritesLinColAndTile0(sprite, 2)
end function

function getOldSpriteStateDirection(sprite as ubyte) as ubyte
    return spritesLinColAndTile0(sprite, 3)
end function

function getNewSpriteStateLin(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 0)
end function

function getNewSpriteStateCol(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 1)
end function

function getNewSpriteStateTile(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 2)
end function

function getNewSpriteStateDirection(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 3)
end function

function newSpriteStateDirectionIsRight(sprite) as ubyte
    return getNewSpriteStateDirection(sprite)
end function

function checkMovement(sprite as ubyte) as ubyte
    if getOldSpriteStateCol(sprite) <> getNewSpriteStateCol(sprite) or getOldSpriteStateLin(sprite) <> getNewSpriteStateLin(sprite)
        return 1
    else
        return 0
    end if
end function

function checkVerticalMovement(sprite)
    if getOldSpriteStateLin(sprite) <> getNewSpriteStateLin(sprite)
        return 1
    else
        return 0
    end if
end function

function checkHorizontalMovement(sprite)
    if getOldSpriteStateCol(sprite) <> getNewSpriteStateCol(sprite)
        return 1
    else
        return 0
    end if
end function

sub updateOldSpriteState(sprite)
    saveOldSpriteState(sprite, getNewSpriteStateLin(sprite), getNewSpriteStateCol(sprite), getNewSpriteStateTile(sprite), getNewSpriteStateDirection(sprite))
end sub

function onLastColumn(sprite) as ubyte
    if getNewSpriteStateCol(sprite) = 60
        return 1
    else
        return 0
    end if
end function

function onFirstColumn(sprite) as ubyte
    if getNewSpriteStateCol(sprite) = 0
        return 1
    else
        return 0
    end if
end function

sub updateState(sprite as ubyte, lin as ubyte, col as ubyte, frameTile as ubyte, directionRight as ubyte)
    saveNewSpriteState(sprite, lin, col, frameTile, directionRight)
end sub

sub restoreState(sprite as ubyte)
    saveNewSpriteState(sprite, getOldSpriteStateLin(sprite), getOldSpriteStateCol(sprite), getOldSpriteStateTile(sprite), getOldSpriteStateDirection(sprite))
end sub

sub protaBounce(toRight as ubyte)
    dim x as integer = getNewSpriteStateCol(PROTA_SPRITE)
    dim y as integer = getNewSpriteStateLin(PROTA_SPRITE)

    if not isEven(x)
        x = x - 1
    end if

    if not isEven(y)
        y = y - 1
    end if
     
    if toRight = 1
        updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) - PROTA_BOUNCE_Y_SIZE, getNewSpriteStateCol(PROTA_SPRITE) + PROTA_BOUNCE_X_SIZE, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
    else
        updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) - PROTA_BOUNCE_Y_SIZE, getNewSpriteStateCol(PROTA_SPRITE) - PROTA_BOUNCE_X_SIZE, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
    end if
end sub

sub removeScreenObjectFromBuffer()
    for i = 0 to 4
        for j = 0 to spritesDataCount - 1
            spritesLinColAndTile0(i, j) = 0
            spritesLinColAndTile1(i, j) = 0
        next j
    next i
end sub