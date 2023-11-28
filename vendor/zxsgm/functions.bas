function isEven(number as ubyte) as ubyte
    return number bAND 1 = 0
end function

sub pauseUntilPressKey()
    WHILE INKEY$<>"":WEND
    WHILE INKEY$="":WEND
end sub

function secureXIncrement(x as integer, increment as integer) as integer
    dim result as integer = x + increment

    if result < 0 or result > 60
        return x
    end if

    return result
end function

function secureYIncrement(y as integer, increment as integer) as integer
    dim result as integer = y + increment

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
	dim tile as ubyte = GetTile(col, lin)

    if isSolidTile(tile)
        if not damagedByCollision
            if isADamageTile(tile)
                damagedByCollision = 1
                decrementLife()
                damageSound()
                startJumping()
            end if
        end if
        return 1
    end if
	return 0
    ' return isSolidTile(tile)
end function

function CheckCollision(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    elseif xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
        if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    	if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
	elseif not xIsEven and yIsEven
		if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
		if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
    elseif not xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
        if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
		if isSolidTileByColLin(col + 2, lin + 2) then return 1
    end if
	return 0
end function

function isSolidTileByXY(x as ubyte, y as ubyte) as ubyte
    dim col as uByte = x >> 1
    dim lin as uByte = y >> 1
    
    dim tile as ubyte = GetTile(col, lin)

	return isSolidTile(tile)
end function

Function fastcall hMirror (number as uByte) as uByte
asm
;17 bytes and 66 clock cycles
Reverse:
    ld b,a       ;b=ABCDEFGH
    rrca         ;a=HABCDEFG
    rrca         ;a=GHABCDEF
    xor b
    and %10101010
    xor b        ;a=GBADCFEH
    ld b,a       ;b=GBADCFEH
    rrca         ;a=HGBADCFE
    rrca         ;a=EHGBADCF
    rrca         ;a=FEHGBADC
    rrca         ;a=CFEHGBAD
    xor b
    and %01100110
    xor b        ;a=GFEDCBAH
    rrca         ;a=HGFEDCBA
end asm
end function