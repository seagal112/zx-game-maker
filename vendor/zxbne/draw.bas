#include <memcopy.bas>

dim cell as ubyte = 0
dim drawing as ubyte = 0

function getTile(x as UBYTE, y as UBYTE) AS UBYTE
	return screens(currentScreen, y, x)
end function

function removeScreenObject(type as ubyte) AS UBYTE
	screenObjects(currentScreen, type) = 0
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
			if tile = itemTile
				if screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 1
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			elseif tile = keyTile
				if screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 1
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			elseif tile = doorTile
				if screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) = 1
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			else
				SetTileChecked(tile, attrSet(tile), x, y)
			end if
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
	' memset(22527,0,768)
	' ClearScreen(7, 0, 0)
	FillWithTile(0, 32, 22, 7, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

function getAttr(x as ubyte, y as ubyte) as ubyte
	return PEEK $5800+32*lin+col
end function

function isSolidTile(tile as ubyte) as ubyte
	if tile > 0 and tile < 64
		return 1
	else
		return 0
	end if
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile = GetTile(col, lin)

	return isSolidTile(tile)
end function

function InArray(Needle as uByte, Haystack as uInteger, arraySize as ubyte)
	dim value as uByte
	for i = 0 to arraySize
		value = peek(Haystack + i)
		if value = Needle
			return value
		end if
	next i

	return 0
end function

function CheckCollision(x as uByte, y as uByte, colidableTilesArray as uInteger, collidableTilesArraySize as ubyte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1)
    elseif xIsEven and not yIsEven
        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) _
            or isSolidTileByColLin(col, lin + 2) or isSolidTileByColLin(col + 1, lin + 2)
	elseif not xIsEven and yIsEven
		return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) or isSolidTileByColLin(col + 2, lin) _
			or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) or isSolidTileByColLin(col + 2, lin + 1)
    elseif not xIsEven and not yIsEven
        return isSolidTileByColLin(col, lin) or isSolidTileByColLin(col + 1, lin) or isSolidTileByColLin(col + 2, lin) _
            or isSolidTileByColLin(col, lin + 1) or isSolidTileByColLin(col + 1, lin + 1) or isSolidTileByColLin(col + 2, lin + 1) _
            or isSolidTileByColLin(col, lin + 2) or isSolidTileByColLin(col + 1, lin + 2) or isSolidTileByColLin(col + 2, lin + 2)
    end if
end function

function checkTileIsDoor(col as ubyte, lin as ubyte) as ubyte
	if GetTile(col, lin) = doorTile
		if currentKeys <> 0
			decrementKeys()
			removeScreenObject(SCREEN_OBJECT_DOOR_INDEX)
			doorSound()
			FillWithTileChecked(0, 1, 1, 7, col, lin)
			FillWithTileChecked(0, 1, 1, 7, col, lin + 1)
		end if
		return 1
	else
		return 0
	end if
end function

function CheckDoor(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1)
    elseif xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2)
	elseif not xIsEven and yIsEven
		return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
			or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1)
    elseif not xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2) or checkTileIsDoor(col + 2, lin + 2)
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

sub decrementKeys()
	currentKeys = currentKeys - 1
	printLife()
end sub

sub incrementItems()
	currentItems = currentItems + 1
	printLife()
	if currentItems >= GOAL_ITEMS
		go to ending
	end if
end sub

sub printLife()
	PRINT AT 22, 5; "  "  
	PRINT AT 22, 5; currentLife
	PRINT AT 22, 16; currentKeys
	PRINT AT 22, 30; currentItems
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
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), 2, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen + 1
	elseif direction = 4
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), 60, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen - 1
	elseif direction = 2
		saveSprite(PROTA_SPRITE, 0, getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		saveSprite(PROTA_SPRITE, MAX_LINE, getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		startJumping()
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if

	removeScreenObjectFromBuffer()
	redrawScreen()
end sub

sub drawSprites()
	Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
	for i = 0 to 2
		if getSpriteLin(i)
			dim tile as ubyte = getSpriteTile(i)
			Draw2x2Sprite(spritesSet(tile), getSpriteCol(i), getSpriteLin(i))
		end if
	next i
	RenderFrame()
END SUB