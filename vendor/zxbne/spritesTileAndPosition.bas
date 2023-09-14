DIM spritesLinColAndTile0(7,2) as ubyte => { _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0} _
}

DIM spritesLinColAndTile1(7,2) as ubyte => { _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0}, _
    {0, 0, 0} _
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
    saveNewSpriteState(0, MAX_LINE, 4, 50)
end sub

sub saveOldSpriteState(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte)
    spritesLinColAndTile0(sprite, 0) = lin
    spritesLinColAndTile0(sprite, 1) = col
    spritesLinColAndTile0(sprite, 2) = tile
end sub

sub saveNewSpriteState(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte)
    spritesLinColAndTile1(sprite, 0) = lin
    spritesLinColAndTile1(sprite, 1) = col
    spritesLinColAndTile1(sprite, 2) = tile
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

function getNewSpriteStateLin(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 0)
end function

function getNewSpriteStateCol(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 1)
end function

function getNewSpriteStateTile(sprite as ubyte) as ubyte
    return spritesLinColAndTile1(sprite, 2)
end function