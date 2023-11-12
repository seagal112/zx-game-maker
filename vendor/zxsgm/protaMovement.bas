#include <keys.bas>

dim landed as UBYTE = 1
dim burnToClean as UBYTE = 0
dim yStepSize as ubyte = 2

function canMoveLeft() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x - 1, y)
		return 0
	end if
	return not CheckCollision(x - 1, y)
end function

function canMoveRight() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x + 1, y)
		return 0
	end if
	return not CheckCollision(x + 1, y)
end function

function canMoveUp() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	return not CheckCollision(x, y - 1)
end function

function canMoveDown() as ubyte
	x = getSpriteCol(PROTA_SPRITE)
	y = getSpriteLin(PROTA_SPRITE)
	return not CheckCollision(x, y + 1)
end function

function getNextFrameJumpingFalling() as UBYTE
	if (getSpriteDirection(PROTA_SPRITE))
		return 3
	else
		return 7
    end if
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getSpriteLin(PROTA_SPRITE) < 2
			moveScreen = 8
		elseif jumpCurrentKey > 0 and not canMoveDown()
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount
			if not CheckCollision(getSpriteCol(PROTA_SPRITE), secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)))
				saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
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
		if landed = 0
			landed = 1
			resetProtaSpriteToRunning()
		end if
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		if getSpriteLin(PROTA_SPRITE) > MAX_LINE
			moveScreen = 2
		else
			saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), yStepSize), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
		end if
		landed = 0
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
        if getSpriteTile(PROTA_SPRITE) = 4
            return 5
        elseif getSpriteTile(PROTA_SPRITE) = 5
            return 6
		else
			return 4
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
	if MultiKeys(KEYSPACE)<>0
		if not bulletInMovement()
			if getSpriteDirection(PROTA_SPRITE)
				bulletPositionX = getSpriteCol(PROTA_SPRITE) + 2
			else
				bulletPositionX = getSpriteCol(PROTA_SPRITE)
			end if
			
			bulletPositionY = getSpriteLin(PROTA_SPRITE) + 1
			bulletDirectionIsRight = getSpriteDirection(PROTA_SPRITE)
		end if
	END IF
end sub

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
	elseif tile = lifeTile and screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
		incrementLife()
		removeScreenObject(SCREEN_OBJECT_LIFE_INDEX)
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
		FillWithTileChecked(0, 1, 1, 7, col, lin + 1)
		return
	elseif checkTileObject(tileRight)
		FillWithTileChecked(0, 1, 1, 7, col + 1, lin + 1)
		return
	end if
end sub

sub checkKeyContact()
	dim sprite as UBYTE = isAKey(getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE))

	if sprite <> 10
		incrementKeys()
	end if
end sub

sub protaMovement()
	keyboardListen()
	checkObjectContact()
	checkIsJumping()
	gravity()
end sub