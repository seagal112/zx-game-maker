DIM spritesLinColAndTile0(7,3) as ubyte => { _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0}, _
    {0, 0, 0, 0} _
}

DIM spritesLinColAndTile1(7,3) as ubyte => { _
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
const jumpStepsCount as ubyte = 2
dim jumpCurrentKey as ubyte = jumpStopValue
dim jumpArray(jumpStepsCount - 1) AS byte = {-16, -16}

function isJumping() as ubyte
    return jumpCurrentKey <> jumpStopValue
end function

function stopJumping()
    jumpCurrentKey = jumpStopValue
end function

function startJumping()
    jumpCurrentKey = 0
end function

sub initProta()
    saveOldSpriteState(PROTA_SPRITE, MAX_LINE, INITIAL_COL, 50, 1)
    saveNewSpriteState(PROTA_SPRITE, MAX_LINE, INITIAL_COL, 50, 1)
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
    if getNewSpriteStateCol(sprite) = 30
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
    saveOldSpriteState(sprite, getNewSpriteStateLin(sprite), getNewSpriteStateCol(sprite), getNewSpriteStateTile(sprite), getNewSpriteStateDirection(sprite))
    saveNewSpriteState(sprite, lin, col, frameTile, directionRight)
end sub

sub protaBounce(toRight as ubyte)
    if toRight = 1
        updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) + PROTA_BOUNCE_SIZE, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
    else
        updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) - PROTA_BOUNCE_SIZE, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
    end if
end sub