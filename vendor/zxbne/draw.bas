#include <memcopy.bas>

CONST screenHeight AS UBYTE = 8
CONST screenWidth AS UBYTE = 16
CONST screenCount AS UBYTE = 2
dim cell as ubyte = 0
dim drawing as ubyte = 0

function getCell(row as UBYTE, col as UBYTE) AS UBYTE
	return screens(currentScreen, row, col) - 1
end function

sub mapDraw()
	dim counter as ubyte = 0
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    dim cell as UBYTE = getCell(row, col)
			counter = counter + 1
			if cell = 0
				NIRVANAfillT(0, (row + 1) * 16, col * 2)
			else
				NIRVANAdrawT(cell, (row + 1) * 16, col * 2)
			end if
		next col
	next row
end sub

sub redrawScreen()
	NIRVANAstop()
	memset(22527,0,768)
	mapDraw()
	NIRVANAstart()
	printLife()
	enemiesDraw(currentScreen)
end sub

function getCellByNirvanaPosition(lin as UBYTE, col as UBYTE) AS UBYTE
	lin = (lin / 16) - 1
	col = col / 2

	return getCell(lin, col)
end function

function isSolidTile(lin as UBYTE, col as UBYTE) as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 1 OR tile = 2
		return 1
    end if
	    
	return 0
end function

SUB drawCell(lin as UBYTE, col as UBYTE)
	if isPair(col) = 1
		if col >= 0 and col <= 30 and lin >= 0 and lin <= MAX_LINE
			cell = getCellByNirvanaPosition(lin, col)
			if cell = 0
				NIRVANAfillT(0, lin, col)
			else
				drawTile(cell, lin, col)
			end if
		end if
	end if
end sub

sub drawToScr(lin as UBYTE, col as UBYTE, isColPair AS UBYTE)
	NIRVANAhalt()
	' drawCell(lin, col)
	if isColPair
		drawCell(lin, col)
	else
		drawCell(lin, col - 1)
		drawCell(lin, col + 1)
	end if
end sub

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
	PRINT AT 0, 0; "Life:"
	PRINT AT 0, 5; "   "
	PRINT AT 0, 5; currentLife
	PRINT AT 0, 10; "Keys:"
	PRINT AT 0, 15; " "
	PRINT AT 0, 15; currentKeys
	PRINT AT 0, 20; "Items:"
	PRINT AT 0, 26; " "
	PRINT AT 0, 26; currentItems
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
	removeAllObjects()
	if direction = 6
		saveNewSpriteState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), 0, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen + 1
	elseif direction = 4
		saveNewSpriteState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), 30, getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen - 1
	elseif direction = 2
		saveNewSpriteState(PROTA_SPRITE, 0, getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		saveNewSpriteState(PROTA_SPRITE, MAX_LINE, getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		startJumping()
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if
	drawSprites()
	updateOldSpriteState(PROTA_SPRITE)
	redrawScreen()
    setScreenElements()
end sub

sub restoreScr(lin as UBYTE, col as UBYTE)
	if isPair(col) = 0
		drawCell(lin, col - 1)
		drawCell(lin, col + 1)
		if checkVerticalMovement(PROTA_SPRITE) = 1
			if newSpriteStateDirectionIsRight(PROTA_SPRITE)
				drawCell(lin, col - 3)
			else
				drawCell(lin, col + 3)
			end if
		end if
	else
		drawCell(lin, col)
		if checkVerticalMovement(PROTA_SPRITE) = 1
			if newSpriteStateDirectionIsRight(PROTA_SPRITE)
				drawCell(lin, col - 2)
			else
				drawCell(lin, col + 2)
			end if
		end if
	end if
	' if isColPair = 0
	' 	NIRVANAfillT(1, lin, col)
	' 	NIRVANAfillT(1, lin, col - 1)
	' else
	' 	NIRVANAfillT(2, lin, col - 1)
	' 	NIRVANAfillT(2, lin, col + 1)
	' end if
end sub

sub drawSprites()
	drawing = 1
	for key = 0 to 7
		if getNewSpriteStateTile(key) <> 0
			if key mod 2 = 0
				NIRVANAhalt()
			end if
			NIRVANAspriteT(key, getNewSpriteStateTile(key), getNewSpriteStateLin(key), getNewSpriteStateCol(key))
			restoreScr(getOldSpriteStateLin(key), getOldSpriteStateCol(key))
			updateOldSpriteState(key)
		end if
	next
	drawing = 0
END SUB