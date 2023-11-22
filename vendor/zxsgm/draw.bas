dim cell as ubyte = 0
dim drawing as ubyte = 0

function removeScreenObject(type as ubyte) AS UBYTE
	screenObjects(currentScreen, type) = 0
end function

sub mapDraw()
	asm
		di
	end asm
	dim tile, index, y, x as integer

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		tile = decompressedMap(index) - 1
		if tile <> 0
			if tile = itemTile
				if screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			elseif tile = keyTile
				if screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			elseif tile = doorTile
				if screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX)
					SetTileChecked(tile, attrSet(tile), x, y)
				end if
			elseif tile = lifeTile
				if screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
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

function CheckCollision(x as uByte, y as uByte) as uByte
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

sub incrementLife()
	currentLife = currentLife + LIFE_AMOUNT
	printLife()
end sub

sub decrementLife()
	if (currentLife = 0)
		return
	end if

	if currentLife > DAMAGE_AMOUNT then
		currentLife = currentLife - DAMAGE_AMOUNT
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

	swapScreen()
	removeScreenObjectFromBuffer()
	redrawScreen()
end sub

sub drawSprites()
	Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
	if enemiesPerScreen(currentScreen) > 0
		for i = 0 to enemiesPerScreen(currentScreen) - 1
			if getSpriteLin(i)
				dim tile as ubyte = getSpriteTile(i)
				Draw2x2Sprite(spritesSet(tile), getSpriteCol(i), getSpriteLin(i))
			end if
		next i
	end if

	if bulletPositionX <> 0
		Draw1x1Sprite(spritesSet(currentBulletSpriteId), bulletPositionX, bulletPositionY)
	end if

	RenderFrame()
END SUB

sub drawBurst(x as ubyte, y as ubyte)
	Draw2x2Sprite(spritesSet(BURST_SPRITE_ID), x, y)
end sub