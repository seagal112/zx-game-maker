function isEven(number as ubyte) as ubyte
    return number bAND 1 = 0
end function

sub pauseUntilPressKey()
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
end sub

function xToCol(x as ubyte) as ubyte
    return x / 2
end function

function yToLin(y as ubyte) as ubyte
    return y / 4
end function

function secureXIncrement(x as integer, increment as integer) as integer
    dim result = x + increment

    if result < 0 or result > 60
        return x
    end if

    return result
end function

function secureYIncrement(y as integer, increment as integer) as integer
    dim result = y + increment

    if result < 0 or result > MAX_LINE + 4
        return y
    end if
    
    return result
end function

function isSolidTile(tile as ubyte) as ubyte
	if tile > 0 and tile < 64
		return 1
	else
		return 0
	end if
end function

function InArray(Needle as uByte, Haystack as uInteger, arraySize as ubyte) as ubyte
	dim value as uByte
	for i = 0 to arraySize
		value = peek(Haystack + i)
		if value = Needle
			return value
		end if
	next i

	return 0
end function

function isADamageTile(tile as ubyte) as UBYTE
	for i = 0 to DAMAGE_TILES_ARRAY_SIZE
		if InArray(tile, @damageTiles, DAMAGE_TILES_ARRAY_SIZE)
			return 1
		end if
	next i
	return 0
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile = GetTile(col, lin)

    if isSolidTile(tile)
        if not damagedByCollision
            if lin mod 4 = 0
                if isADamageTile(tile)
                    damagedByCollision = 1
                    decrementLife()
                    damageSound()
                    startJumping()
                end if
            end if
        end if
        return 1
    end if
	return 0
    ' return isSolidTile(tile)
end function

function isSolidTileByXY(x as ubyte, y as ubyte) as ubyte
    dim col as uByte = x >> 1
    dim lin as uByte = y >> 1
    
    dim tile = GetTile(col, lin)

	return isSolidTile(tile)
end function

function flipSpriteHorizontally(sprite as ubyte) as ubyte
    return 1 'sprite bXOR 0b10000000
end function

sub flipSpriteArrayHorizontally(ByRef sprite() as ubyte)
    for i = 0 to 31
        sprite(i) = flipSpriteHorizontally(sprite(i))
    next i
end sub