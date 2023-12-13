const UNPAINT_WIDTH as ubyte = 1

function removeScreenObject(type as ubyte) AS UBYTE
	screenObjects(currentScreen, type) = 0
end function

sub mapDraw()
	dim tile, index, y, x as integer

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		tile = decompressedMap(index) - 1
		drawTile(tile, x, y)
		x = x + 1
		if x = screenWidth
			x = 0
			y = y + 1
		end if
	next index
end sub

sub drawTile(tile as ubyte, x as ubyte, y as ubyte)
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
			SetTile(tile, attrSet(tile), x, y)
		end if
	end if
end sub

sub redrawScreen()
	' memset(22527,0,768)
	ClearScreen(7, 0, 0)
	dzx0Standard(@hudScreen, $4000)
	FillWithTile(0, 32, 22, 7, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

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
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), 0, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
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

dim unpaintWidth as byte
dim unpaintHeight as byte

sub drawSprites()
	if not invincible
		Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
	else
		if isEven(framec)
			Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
		end if
	end if
	if enemiesPerScreen(currentScreen) > 0
		dim xToPaint, yToPaint as float
		dim paintWidth as byte
		dim paintHeight as byte
		dim tile as ubyte
		for i = 0 to enemiesPerScreen(currentScreen) - 1
			if not getSpriteLin(i) then continue for
			
			tile = getSpriteTile(i)
			Draw2x2Sprite(spritesSet(tile), getSpriteCol(i), getSpriteLin(i))
			if tile < 16 then continue for
			if not decompressedEnemiesScreen(i, ENEMY_COLOR) then continue for
			if decompressedEnemiesScreen(i, ENEMY_COLOR) = 7 then continue for

			if getSpriteCol(i) mod 2 = 0
				paintWidth = 2
			else
				paintWidth = 3
			end if

			if getSpriteLin(i) mod 2 = 0
				paintHeight = 2
			else
				paintHeight = 3
			end if

			xToPaint = getSpriteCol(i) / 2
			yToPaint = getSpriteLin(i) / 2

			unpaintEnemiesArray(i, 0) = xToPaint
			unpaintEnemiesArray(i, 1) = yToPaint

			if spriteHadHorizontalMovement(i)
				if decompressedEnemiesScreen(i, ENEMY_HORIZONTAL_DIRECTION) = 1
					unpaintEnemiesArray(i, 0) = xToPaint - 1
				else
					unpaintEnemiesArray(i, 0) = xToPaint + paintWidth
				end if
				paint(xToPaint, yToPaint, paintWidth, 2, decompressedEnemiesScreen(i, ENEMY_COLOR))
			end if

			if spriteHadVerticalMovement(i)
				if decompressedEnemiesScreen(i, ENEMY_VERTICAL_DIRECTION) = 1
					unpaintEnemiesArray(i, 1) = yToPaint - 1
				else
					unpaintEnemiesArray(i, 1) = yToPaint + paintHeight
				end if
				paint(xToPaint, yToPaint, 2, paintHeight, decompressedEnemiesScreen(i, ENEMY_COLOR))
			end if
		next i
	end if

	if bulletPositionX <> 0
		Draw1x1Sprite(spritesSet(currentBulletSpriteId), bulletPositionX, bulletPositionY)
	end if

	RenderFrame()

	unpaintEnemiesBack()
END SUB

sub unpaintEnemiesBack()
	if enemiesPerScreen(currentScreen) <= 0 then return

	dim tile, attr as ubyte
	for i = 0 to enemiesPerScreen(currentScreen) - 1
		if getSpriteLin(i) = 0 then continue for
		if getSpriteTile(i) < 16 then continue for
		if not decompressedEnemiesScreen(i, ENEMY_COLOR) then continue for
		if decompressedEnemiesScreen(i, ENEMY_COLOR) = 7 then continue for

		tile = GetTile(unpaintEnemiesArray(i, 0), unpaintEnemiesArray(i, 1))

		if tile = 0
			attr = 7
		else
			attr = attrSet(tile)
		end if
		if spriteHadHorizontalMovement(i)
			paint(unpaintEnemiesArray(i, 0), unpaintEnemiesArray(i, 1), 1, 2, attr)	
		end if

		if spriteHadVerticalMovement(i) and not getSwitchVerticalMovement(i)
			paint(unpaintEnemiesArray(i, 0), unpaintEnemiesArray(i, 1), 2, 1, attr)
		end if
					
	next i
end sub

sub drawBurst(x as ubyte, y as ubyte)
	Draw2x2Sprite(spritesSet(BURST_SPRITE_ID), x, y)
end sub