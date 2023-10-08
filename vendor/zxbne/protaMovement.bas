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

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	if isPair(x)
		col = x / 2 + xOffset
	else
		return 1
	end if

	if isPair(y)
		lin0 = y/2

		if y mod 4 = 0
			return not isSolidTileByColLin(col, lin0)
		else
			return not isSolidTileByColLin(col, lin0 + 2) and isSolidTileByColLin(col, lin0 - 2)
		end if
	else
		prevY = y - y mod 4
		nextY = prevY + 4

		lin0 = prevY / 2
		lin1 = nextY / 2

		return not isSolidTileByColLin(col, lin0) and not isSolidTileByColLin(col, lin1)
	end if
end function

function canMoveVertical(yOffset as integer) as UBYTE
	dim lin, col0, col1, x, y, prevX, nextX, module as integer

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	if isPair(y)
		lin = y / 2 + yOffset
	else
		return 1
	end if

	col0 = x/2

	' if yOffset > 0
	' 	if checkIfDestroyEnemy(col0 + 2, lin) or checkIfDestroyEnemy(col0 - 2, lin)
	' 		return 0
	' 	end if
	' end if

	if isPair(x)
		if x mod 4 = 0
			return not isSolidTileByColLin(col0, lin)
		else
			return not isSolidTileByColLin(col0 + 2, lin) and not isSolidTileByColLin(col0 - 2, lin)
		end if
	else
		prevX = x - x mod 4
		nextX = prevX + 4

		col0 = prevX / 2
		col1 = nextX / 2

		return not isSolidTileByColLin(col0, lin) and not isSolidTileByColLin(col1, lin)
	end if
end function

function canMoveLeft() as ubyte
	return canMoveHorizontal(-1)
end function

function canMoveRight() as ubyte
	return canMoveHorizontal(2)
end function

function canMoveUp() as ubyte
	return canMoveVertical(-1)
end function

function canMoveDown() as ubyte
	return canMoveVertical(2)
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getNewSpriteStateLin(PROTA_SPRITE) < 2
			moveScreen = 8
		elseif jumpCurrentKey > 0 and not canMoveDown()
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount AND canMoveUp()
			updateState(PROTA_SPRITE, secureYIncrement(getNewSpriteStateLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)), getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
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
		if getNewSpriteStateLin(PROTA_SPRITE) > MAX_LINE + 2
			moveScreen = 2
		else
			updateState(PROTA_SPRITE, secureYIncrement(getNewSpriteStateLin(PROTA_SPRITE), yStepSize), getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
		end if
	end if
end sub

function getNextFrameRunning() as UBYTE
	if getNewSpriteStateDirection(PROTA_SPRITE) = 1
		if getOldSpriteStateTile(PROTA_SPRITE) = 0
			return 1
        else
			return 0
		end if
	else
        if getOldSpriteStateTile(PROTA_SPRITE) = 2
            return 3
        else
            return 2
        end if
	end if
end function

sub keyboardListen()
    if MultiKeys(KEYO)<>0
		if onFirstColumn(PROTA_SPRITE)
			moveScreen = 4
		elseif canMoveLeft()
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), secureXIncrement(getNewSpriteStateCol(PROTA_SPRITE), -1), getNextFrameRunning(), 0)
		end if
    END IF
    if MultiKeys(KEYP)<>0
		if onLastColumn(PROTA_SPRITE)
			moveScreen = 6
		elseif canMoveRight()
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), secureXIncrement(getNewSpriteStateCol(PROTA_SPRITE), 1), getNextFrameRunning(), 1)
		end if
    END IF
    if MultiKeys(KEYQ)<>0
		' isFalling()
		' updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) - 1, getNewSpriteStateCol(PROTA_SPRITE), getNextFrameRunning(), 1)
		' if getNewSpriteStateLin(PROTA_SPRITE) < 2
		' 	moveScreen = 8
		' end if
        if isJumping() = 0 and landed
			landed = 0
			startJumping()
        end if
    END IF
    if MultiKeys(KEYA)<>0
		if canMoveDown()
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) + 1, getNewSpriteStateCol(PROTA_SPRITE), getNextFrameRunning(), 1)
		end if
    END IF
end sub

function getNextFrameJumpingFalling() as UBYTE
	if (getNewSpriteStateDirection(PROTA_SPRITE))
		return 58
	else
		return 59
    end if
end function

sub checkItemContact()
	dim sprite as UBYTE = isAnItem(getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE))

	if sprite <> 0
		incrementItems()
		resetItems()
		killEnemy(sprite, 1)
	end if
end sub

sub checkKeyContact()
	dim sprite as UBYTE = isAKey(getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE))

	if sprite <> 0
		incrementKeys()
		resetKeys()
		killEnemy(sprite, 1)
	end if
end sub

sub protaMovement()
	keyboardListen()
	' checkItemContact()
	' checkKeyContact()
	checkIsJumping()
	gravity()
end sub