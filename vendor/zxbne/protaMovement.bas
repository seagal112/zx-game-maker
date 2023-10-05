#include <keys.bas>

dim landed as UBYTE = 1
dim burnToClean as UBYTE = 0
dim yStepSize as ubyte = 1

function checkNoSolidOffset(xOffset as ubyte, yOffset as ubyte) as ubyte
	dim col as integer = getNewSpriteStateCol(PROTA_SPRITE)/2 + xOffset
	dim lin as integer = getNewSpriteStateLin(PROTA_SPRITE)/2 + yOffset

	dim tile as ubyte = GetTile(col, lin)

	if isSolidTile(tile) <> 1
		return 1
	else
		return 0
	end if
end function

function canMoveLeft() as UBYTE
	dim col, lin0, lin1, x, y, prevY, nextY, module as integer

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	module = x mod 2
	if module = 0
		col = x / 2 - 1
	else
		return 1
	end if

	module = y mod 2

	if module = 0
		lin0 = y/2

		if y mod 4 = 0
			if isSolidTileByColLin(col, lin0) <> 1
				return 1
			else
				return 0
			end if
		else
			if isSolidTileByColLin(col, lin0 + 2) <> 1 and isSolidTileByColLin(col, lin0 - 2) <> 1
				return 1
			else
				return 0
			end if
		end if
	else
		prevY = y - y mod 4
		nextY = prevY + 4

		lin0 = prevY / 2
		lin1 = nextY / 2

		if isSolidTileByColLin(col, lin0) <> 1 and isSolidTileByColLin(col, lin1) <> 1
			return 1
		else
			return 0
		end if
	end if
end function

function canMoveRight() as UBYTE
	dim col, lin0, lin1, x, y, prevY, nextY, module as integer

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	module = x mod 2
	if module = 0
		col = x / 2 + 2
	else
		return 1
	end if

	module = y mod 2

	if module = 0
		lin0 = y/2

		if y mod 4 = 0
			if isSolidTileByColLin(col, lin0) <> 1
				return 1
			else
				return 0
			end if
		else
			if isSolidTileByColLin(col, lin0 + 2) <> 1 and isSolidTileByColLin(col, lin0 - 2) <> 1
				return 1
			else
				return 0
			end if
		end if
	else
		prevY = y - y mod 4
		nextY = prevY + 4

		lin0 = prevY / 2
		lin1 = nextY / 2

		if isSolidTileByColLin(col, lin0) <> 1 and isSolidTileByColLin(col, lin1) <> 1
			return 1
		else
			return 0
		end if
	end if
end function

function canMoveUp() as UBYTE
	dim lin, col0, col1, x, y, prevX, nextX, module as integer

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	module = y mod 2
	if module = 0
		lin = y / 2 - 1
	else
		return 1
	end if

	module = x mod 2

	if module = 0
		col0 = x/2

		if x mod 4 = 0
			if isSolidTileByColLin(col0, lin) <> 1
				return 1
			else
				return 0
			end if
		else
			if isSolidTileByColLin(col0 + 2, lin) <> 1 and isSolidTileByColLin(col0 - 2, lin) <> 1
				return 1
			else
				return 0
			end if
		end if
	else
		prevX = x - x mod 4
		nextX = prevX + 4

		col0 = prevX / 2
		col1 = nextX / 2

		if isSolidTileByColLin(col0, lin) <> 1 and isSolidTileByColLin(col1, lin) <> 1
			return 1
		else
			return 0
		end if
	end if
end function

function canMoveDown() as UBYTE
	dim lin, col0, col1, x, y, prevX, nextX, module as integer

	x = getNewSpriteStateCol(PROTA_SPRITE)
	y = getNewSpriteStateLin(PROTA_SPRITE)

	module = y mod 2
	if module = 0
		lin = y / 2 + 2
	else
		return 1
	end if

	module = x mod 2

	if module = 0
		col0 = x/2

		if x mod 4 = 0
			if isSolidTileByColLin(col0, lin) <> 1
				return 1
			else
				return 0
			end if
		else
			if isSolidTileByColLin(col0 + 2, lin) <> 1 and isSolidTileByColLin(col0 - 2, lin) <> 1
				return 1
			else
				return 0
			end if
		end if
	else
		prevX = x - x mod 4
		nextX = prevX + 4

		col0 = prevX / 2
		col1 = nextX / 2

		if isSolidTileByColLin(col0, lin) <> 1 and isSolidTileByColLin(col1, lin) <> 1
			return 1
		else
			return 0
		end if
	end if
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getNewSpriteStateLin(PROTA_SPRITE) < 2
			moveScreen = 8
		elseif jumpCurrentKey > 0 and canMoveDown() = 0
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount AND canMoveUp() = 1
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey), getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
			jumpCurrentKey = jumpCurrentKey + 1
		else
			stopJumping()
        end if
	end if
end sub

function isFalling() as UBYTE
	if canMoveDown() = 1
		return 1
	else
		landed = 1
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		if getNewSpriteStateLin(PROTA_SPRITE) = MAX_LINE
			moveScreen = 2
		else
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) + yStepSize, getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
			sprite = isAnEnemy(getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE))
			if sprite
				killEnemy(sprite, 1)
				startJumping()
				burnToClean = sprite
			end if
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
		if canMoveLeft() = 1
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) - 1, getNextFrameRunning(), 0)
			if onFirstColumn(PROTA_SPRITE)
				moveScreen = 4
			end if
		end if
    END IF
    if MultiKeys(KEYP)<>0
		if canMoveRight() = 1
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) + 1, getNextFrameRunning(), 1)
			if onLastColumn(PROTA_SPRITE)
				moveScreen = 6
			end if
		end if
    END IF
    if MultiKeys(KEYQ)<>0
        if isJumping() = 0 and landed = 1
			landed = 0
			startJumping()
        end if
    END IF
    if MultiKeys(KEYA)<>0
    END IF
end sub

function getNextFrameJumpingFalling() as UBYTE
	if (getNewSpriteStateDirection(PROTA_SPRITE))
		return 58
	else
		return 59
    end if
end function

sub removePlayer()
	' NIRVANAspriteT(PROTA_SPRITE, 29, 0, 0)
end sub

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