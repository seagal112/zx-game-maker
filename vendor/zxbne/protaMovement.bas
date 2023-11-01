#include <keys.bas>

dim landed as UBYTE = 1
dim burnToClean as UBYTE = 0
dim yStepSize as ubyte = 2

function checkIfDestroyEnemy(col as ubyte, lin as ubyte) as ubyte
	sprite = isAnEnemy(lin, col)	
	if sprite <> 10
		killEnemy(sprite, 1)
		startJumping()
		burnToClean = sprite
		return 1
	end if
	return 0
end function

function canMoveHorizontal(xOffset as integer) as UBYTE
	dim col, lin0, lin1, x, y, prevY, nextY, module as integer

	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)

	if isEven(x)
		col = x / 2 + xOffset
	else
		return 1
	end if

	if isEven(y)
		lin0 = y/2
		debugC(lin0)
		return not isSolidTileByColLin(col, lin0) and not isSolidTileByColLin(col, lin0 + 1)
	else
		prevY = y - 1

		lin0 = prevY / 2

		return not isSolidTileByColLin(col, lin0) and not isSolidTileByColLin(col, lin0 + 1) and not isSolidTileByColLin(col, lin0 + 2)
	end if
end function

function canMoveVertical(yOffset as integer) as UBYTE
	dim lin, col0, col1, x, y, prevX, nextX, module as integer

	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)

	if isEven(y)
		lin = y / 2 + yOffset
	else
		return 1
	end if

	col0 = x/2

	if yOffset > 0
		if checkIfDestroyEnemy(col0, lin) or checkIfDestroyEnemy(col0 + 2, lin) or checkIfDestroyEnemy(col0 - 2, lin)
			return 0
		end if
	end if

	if isEven(x)
		return not isSolidTileByColLin(col0, lin) and not isSolidTileByColLin(col0 + 1, lin)
	else
		prevX = x - 1

		col0 = prevX / 2

		return not isSolidTileByColLin(col0, lin) and not isSolidTileByColLin(col + 1, lin) and not isSolidTileByColLin(col + 2, lin)
	end if
end function

function canMoveLeft() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x - 1, y)
		return 0
	end if
	return not CheckCollision(x - 1, y, @solidTiles, SOLID_TILES_ARRAY_SIZE)
end function

function canMoveRight() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x + 1, y)
		return 0
	end if
	return not CheckCollision(x + 1, y, @solidTiles, SOLID_TILES_ARRAY_SIZE)
end function

function canMoveUp() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	return not CheckCollision(x, y - 1, @solidTiles, SOLID_TILES_ARRAY_SIZE)
end function

function canMoveDown() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	return not CheckCollision(x, y + 1, @solidTiles, SOLID_TILES_ARRAY_SIZE)
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getSpriteLin(PROTA_SPRITE) < 2
			moveScreen = 8
		elseif jumpCurrentKey > 0 and not canMoveDown()
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount
			if not CheckCollision(getSpriteCol(PROTA_SPRITE), secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)), @solidTiles, SOLID_TILES_ARRAY_SIZE)
				saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)), getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
			end if
			jumpCurrentKey = jumpCurrentKey + 1
		else
			stopJumping()
        end if
	end if
end sub

function isFalling() as UBYTE
	if canMoveDown()
		return 1
	else
		landed = 1
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		if getSpriteLin(PROTA_SPRITE) > MAX_LINE + 2
			moveScreen = 2
		else
			saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), yStepSize), getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		end if
	end if
end sub

function getNextFrameRunning() as UBYTE
	if getSpriteDirection(PROTA_SPRITE) = 1
		if getSpriteTile(PROTA_SPRITE) = 0
			return 1
        elseif getSpriteTile(PROTA_SPRITE) = 1
			return 2
		else
			return 0
		end if
	else
        if getSpriteTile(PROTA_SPRITE) = 5
            return 6
        elseif getSpriteTile(PROTA_SPRITE) = 6
            return 7
		else
			return 5
        end if
	end if
end function

sub keyboardListen()
    if MultiKeys(KEYO)<>0
		if onFirstColumn(PROTA_SPRITE)
			moveScreen = 4
		elseif canMoveLeft()
			saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), secureXIncrement(getSpriteCol(PROTA_SPRITE), -1), getNextFrameRunning(), 0)
		end if
    END IF
    if MultiKeys(KEYP)<>0
		if onLastColumn(PROTA_SPRITE)
			moveScreen = 6
		elseif canMoveRight()
			saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), secureXIncrement(getSpriteCol(PROTA_SPRITE), 1), getNextFrameRunning(), 1)
		end if
    END IF
    if MultiKeys(KEYQ)<>0
		' if canMoveUp()
		' 	saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) - 1, getSpriteCol(PROTA_SPRITE), getNextFrameRunning(), 1)
		' 	if getSpriteLin(PROTA_SPRITE) < 2
		' 		moveScreen = 8
		' 	end if
		' end if
        if isJumping() = 0 and landed
			landed = 0
			startJumping()
        end if
    END IF
    if MultiKeys(KEYA)<>0
		if canMoveDown()
			saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + 1, getSpriteCol(PROTA_SPRITE), getNextFrameRunning(), 1)
		end if
    END IF
end sub

function getNextFrameJumpingFalling() as UBYTE
	if (getSpriteDirection(PROTA_SPRITE))
		return 58
	else
		return 59
    end if
end function

function checkTileObject(tile as ubyte) as ubyte
	if tile = itemTile and screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
		incrementItems()
		removeScreenObject(SCREEN_OBJECT_ITEM_INDEX)
		itemSound()
		return 1
	elseif tile = keyTile and screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
		incrementKeys()
		removeScreenObject(SCREEN_OBJECT_KEY_INDEX)
		keySound()
		return 1
	end if
	return 0
end function

sub checkObjectContact()
	Dim col as uByte = getSpriteCol(PROTA_SPRITE) >> 1
    Dim lin as uByte = getSpriteLin(PROTA_SPRITE) >> 1

	dim tile as UBYTE = getTile(col, lin + 1)
	dim tileRight as UBYTE = getTile(col + 1, lin + 1)

	if checkTileObject(tile)
		redrawScreen()
		'SetTileColor(col, lin + 1, 0)
		return
	elseif checkTileObject(tileRight)
		redrawScreen()
		'SetTileColor(col + 1, lin + 1, 0)
		return
	end if
end sub

sub checkKeyContact()
	dim sprite as UBYTE = isAKey(getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE))

	if sprite <> 10
		incrementKeys()
		resetKeys()
		killEnemy(sprite, 1)
	end if
end sub

sub protaMovement()
	keyboardListen()
	checkObjectContact()
	checkIsJumping()
	gravity()
end sub