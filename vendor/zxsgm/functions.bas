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

SUB paint (x as uByte,y as uByte, width as uByte, height as uByte, attribute as ubyte)
REM Copyleft Britlion. Feel free to use as you will. Please attribute me if you use this, however!

Asm
    ld      a,(IX+7)   ;ypos
    rrca
    rrca
    rrca               ; Multiply by 32
    ld      l,a        ; Pass to L
    and     3          ; Mask with 00000011
    add     a,88       ; 88 * 256 = 22528 - start of attributes. Change this if you are working with a buffer or somesuch.
    ld      h,a        ; Put it in the High Byte
    ld      a,l        ; We get y value *32
    and     224        ; Mask with 11100000
    ld      l,a        ; Put it in L
    ld      a,(IX+5)   ; xpos
    add     a,l        ; Add it to the Low byte
    ld      l,a        ; Put it back in L, and we're done. HL=Address.

    push HL            ; save address
    LD A, (IX+13)      ; attribute
    LD DE,32
    LD c,(IX+11)       ; height

    BLPaintHeightLoop:
    LD b,(IX+9)        ; width

    BLPaintWidthLoop:
    LD (HL),a          ; paint a character
    INC L              ; Move to the right (Note that we only would have to inc H if we are crossing from the right edge to the left, and we shouldn't be needing to do that)
    DJNZ BLPaintWidthLoop

    BLPaintWidthExitLoop:
    POP HL             ; recover our left edge
    DEC C
    JR Z, BLPaintHeightExitLoop

    ADD HL,DE          ; move 32 down
    PUSH HL            ; save it again
    JP BLPaintHeightLoop

    BLPaintHeightExitLoop:
end asm
END SUB