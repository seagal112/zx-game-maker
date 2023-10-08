#include <memcopy.bas>

CONST screenHeight AS UBYTE = 8
CONST screenWidth AS UBYTE = 16
CONST screenCount AS UBYTE = 2
dim cell as ubyte = 0
dim drawing as ubyte = 0

function getCell(row as UBYTE, col as UBYTE) AS UBYTE
	return screens(currentScreen, row, col)
end function

sub mapDraw()
	dim x, y, cell as ubyte
	dim row, col as ubyte
	x = 0
	y = 0
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    cell = getCell(row, col)
			if cell = 2
				SetTiledObject(32, 2, 2, 40, x, y)
			elseif cell = 13
				SetTiledObject(12, 2, 2, 104, x, y)
			elseif cell = 3
				SetTiledObject(16, 2, 2, 112, x, y)
			elseif cell = 4
				SetTile(24, 1, x, y)
				SetTile(25, 6, x + 1, y)
				SetTile(26, 6, x, y + 1)
				SetTile(27, 1, x + 1, y + 1)
			elseif cell = 1
				SetTile(29, 96, x, y)
				SetTile(29, 96, x + 1, y)
				SetTile(29, 16, x, y + 1)
				SetTile(29, 16, x + 1, y + 1)
			' else
			' 	SetTile(8, 61, x, y)
            '     SetTile(8, 61, x + 1, y)
            '     SetTile(8, 61, x, y + 1)
            '     SetTile(8, 61, x + 1, y + 1)
			end if
			x = x + 2
			if x = 32
				x = 0
				y = y + 2
			end if
		next col
	next row
end sub

sub redrawScreen()
	memset(22527,0,768)
	ClearScreen(7, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

function getCellByNirvanaPosition(lin as UBYTE, col as UBYTE) AS UBYTE
	lin = (lin / 16) - 1
	col = col / 2

	return getCell(lin, col)
end function

function getAttr(x as ubyte, y as ubyte) as ubyte
	return PEEK $5800+32*lin+col
end function

function isSolidTile(tile as ubyte) as ubyte
	' if tile > 30
	' 	debugA(tile)
	' 	pauseUntilPressKey()
	' end if
	if (tile > 31 and tile < 35) or tile = 29
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
	if getNewSpriteStateLin(0) <> 0
		if getNewSpriteStateDirection(0) = 1
			Draw2x2Sprite(spriteEnemy1Right, getNewSpriteStateCol(0), getNewSpriteStateLin(0))
		else
			Draw2x2Sprite(spriteEnemy1Left, getNewSpriteStateCol(0), getNewSpriteStateLin(0))
		end if
	end if
	RenderFrame()
END SUB