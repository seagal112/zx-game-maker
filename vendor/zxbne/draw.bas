#include <memcopy.bas>

CONST screenHeight AS UBYTE = 16
CONST screenWidth AS UBYTE = 32
CONST screenCount AS UBYTE = 2
dim cell as ubyte = 0
dim drawing as ubyte = 0

function getTile(x as UBYTE, y as UBYTE) AS UBYTE
	return screens(currentScreen, y, x)
end function

sub mapDraw()
	asm
		di
	end asm
	dim tile, index, y, x, count, offset as integer

	count = screenHeight * screenWidth - 1
	x = 0
	y = 0
	
	offset = screenHeight * screenWidth * currentScreen
	for index=0 to count
		tile = peek (@screens + offset + index)
		if tile <> 0
			SetTile(tile, attrSet(tile), x, y)
		end if
		x = x + 1
		if x = screenWidth
			x = 0
			y = y + 1
		end if
	next index

	' for y=0 to screenHeight - 1
	' 	for x=0 to screenWidth - 1
	' 	    tile = getTile(x, y)
	' 		' tile = 2
	' 		if tile <> 0
	' 			SetTile(tile, attrSet(tile), x, y)
	' 		end if
	' 	next x
	' next y
	asm
		ei
	end asm
end sub

sub redrawScreen()
	memset(22527,0,768)
	ClearScreen(7, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

function getAttr(x as ubyte, y as ubyte) as ubyte
	return PEEK $5800+32*lin+col
end function

function isSolidTile(tile as ubyte) as ubyte
	if tile <> 0
		return 1
	else
		return 0
	end if 
	' if tile > 30
	' 	debugA(tile)
	' 	pauseUntilPressKey()
	' end if
	if tile > 3
		return 1
	end if

	if (tile > 3 and tile < 8) or (tile > 19 and tile < 24)
		return 1
    end if
	    
	return 0
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile = GetTile(col, lin)
	' if currentScreen = 3
	' 	debugA(col)
	' 	debugB(lin)
	' 	debugC(tile)
	' 	pauseUntilPressKey()
	' end if

	return isSolidTile(tile)
end function


function checkCollision(sprite as ubyte, x as ubyte, y as ubyte) as ubyte
    dim col, lin as ubyte

    if isPair(x) and isPair(y)
        col = x/2
        lin = y/2

        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1)
    elseif isPair(x) and not isPair(y)
        col = x/2
        lin = (y - 1)/2

        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) _
            or isSolidTileByColLin(col, lin + 2) or isSolidTileByColLin(col + 1, lin + 2)
	elseif not isPair(x) and isPair(y)
		col = (x - 1)/2
		lin = y/2

		return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) or isSolidTileByColLin(col + 2, lin) _
			or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) or isSolidTileByColLin(col + 2, lin + 1)
    elseif not isPair(x) and not isPair(y)
        col = (x - 1)/2
        lin = (y - 1)/2

        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) or isSolidTileByColLin(col + 2, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) or isSolidTileByColLin(col + 2, lin + 1) _
            or isSolidTileByColLin(col, lin + 2) or isSolidTileByColLin(col + 1, lin + 2) or isSolidTileByColLin(col + 2, lin + 2)
    end if
end function

sub decrementLife()
	if (currentLife = 0)
		return
	end if

	if currentLife > 5 then
		currentLife = currentLife - 5
	else
		currentLife = 0
	end if
	printLife()
end sub

sub incrementKeys()
	currentKeys = currentKeys + 1
	printLife()
end sub

sub incrementItems()
	currentItems = currentItems + 1
	printLife()
end sub

sub printLife()
	PRINT AT 20, 0; "Life:"
	PRINT AT 20, 5; "   "
	PRINT AT 20, 5; currentLife
	PRINT AT 20, 10; "Keys:"
	PRINT AT 20, 15; " "
	PRINT AT 20, 15; currentKeys
	PRINT AT 20, 20; "Items:"
	PRINT AT 20, 26; " "
	PRINT AT 20, 26; currentItems
end sub

sub drawMenu()
	PRINT AT 0, 5; "ZX BASIC NIRVANA ENGINE"
	PRINT AT 5, 5; "PRESS ANY KEY TO START"
end sub

sub debug(message as string)
	PRINT AT 0, 10; "                         "
	PRINT AT 0, 10; message
end sub

sub moveToScreen(direction as Ubyte)
	' removeAllObjects()
	if direction = 6
		saveNewSpriteState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), 2, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen + 1
	elseif direction = 4
		saveNewSpriteState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), 60, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen - 1
	elseif direction = 2
		saveNewSpriteState(PROTA_SPRITE, 0, getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		saveNewSpriteState(PROTA_SPRITE, MAX_LINE, getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		startJumping()
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if
	updateOldSpriteState(PROTA_SPRITE)
	removeScreenObjectFromBuffer()
	redrawScreen()
	resetItemsAndKeys()
    setScreenElements()
end sub

sub drawSprites()
	Draw2x2Sprite(spritesSet(getNewSpriteStateTile(PROTA_SPRITE)), getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateLin(PROTA_SPRITE))
	for i = 0 to 2
		if getNewSpriteStateLin(i)
			if getNewSpriteStateDirection(i) = 1
				Draw2x2Sprite(spriteEnemy1Right, getNewSpriteStateCol(i), getNewSpriteStateLin(i))
			else
				Draw2x2Sprite(spriteEnemy1Left, getNewSpriteStateCol(i), getNewSpriteStateLin(i))
			end if
		end if
	next i
	RenderFrame()
END SUB