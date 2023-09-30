#include <keys.bas>

dim landed as UBYTE
dim burnToClean as UBYTE = 0
dim yStepSize as ubyte = 16

function canMoveLeft() as UBYTE
	dim col as ubyte = getOldSpriteStateCol(PROTA_SPRITE)
	if isPair(col) = 0
		col = col + 1
	end if
	if getOldSpriteStateCol(PROTA_SPRITE) > 0 AND isSolidTile(getOldSpriteStateLin(PROTA_SPRITE), col - 2) <> 1
		return 1
	else
		return 0
	end if
end function

function canMoveRight() as UBYTE
	dim col as ubyte = getOldSpriteStateCol(PROTA_SPRITE)
	if isPair(col) = 0
		col = col - 1
	end if
	if getOldSpriteStateCol(PROTA_SPRITE) < 30 AND isSolidTile(getOldSpriteStateLin(PROTA_SPRITE), col + 2) <> 1
		return 1
	else
		return 0
	end if
end function

function underSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) - yStepSize, getNewSpriteStateCol(PROTA_SPRITE))

	if tile = 1 OR tile = 2
		landed = 1
		return 1
	else
		if isPair(getNewSpriteStateCol(PROTA_SPRITE)) = 1
			return 0
		end if

		dim preTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) - yStepSize, getNewSpriteStateCol(PROTA_SPRITE) - 1)
		dim postTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) - yStepSize, getNewSpriteStateCol(PROTA_SPRITE) + 1)
		if preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
			return 1
		else
			return 0
		end if
	end if
end function

function onTheSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) + yStepSize, getNewSpriteStateCol(PROTA_SPRITE))

	if tile = 1 OR tile = 2
		landed = 1
		return 1
	else
		if isPair(getNewSpriteStateCol(0)) = 1
			return 0
		end if

		dim preTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) + yStepSize, getNewSpriteStateCol(PROTA_SPRITE) - 1)
		dim postTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(PROTA_SPRITE) + yStepSize, getNewSpriteStateCol(PROTA_SPRITE) + 1)
		if preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
			landed = 1
			return 1
		else
			return 0
		end if
	end if
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getNewSpriteStateLin(PROTA_SPRITE) = 0
			moveScreen = 8
		elseif jumpCurrentKey > 0 and onTheSolidTile() = 1
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount AND underSolidTile() = 0
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey), getNewSpriteStateCol(PROTA_SPRITE), getNewSpriteStateTile(PROTA_SPRITE), getNewSpriteStateDirection(PROTA_SPRITE))
			jumpCurrentKey = jumpCurrentKey + 1
		else
			stopJumping()
        end if
	end if
end sub

function isFalling() as UBYTE
	if onTheSolidTile() <> 1
		return 1
	else
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		'debug ("falling")
		if getNewSpriteStateLin(0) = MAX_LINE
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
	if (getNewSpriteStateDirection(PROTA_SPRITE))
		if getOldSpriteStateTile(PROTA_SPRITE) = 50
			return 51
        elseif getOldSpriteStateTile(PROTA_SPRITE) = 51
			return 52
        elseif getOldSpriteStateTile(PROTA_SPRITE) = 52
			return 53
		else
			return 50
		end if
	else
        if getOldSpriteStateTile(PROTA_SPRITE) = 54
            return 55
        elseif getOldSpriteStateTile(PROTA_SPRITE) = 55
            return 56
        elseif getOldSpriteStateTile(PROTA_SPRITE) = 56
            return 57
        else
            return 54
        end if
	end if
end function

sub keyboardListen()
    if MultiKeys(KEYO)<>0
		if canMoveLeft()
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) - 1, getNextFrameRunning(), 0)
        end if
		if onFirstColumn(PROTA_SPRITE)
			moveScreen = 4
		end if
    END IF
    if MultiKeys(KEYP)<>0
		if canMoveRight()
			updateState(PROTA_SPRITE, getNewSpriteStateLin(PROTA_SPRITE), getNewSpriteStateCol(PROTA_SPRITE) + 1, getNextFrameRunning(), 1)
        end if
		if onLastColumn(PROTA_SPRITE)
			moveScreen = 6
		end if
    END IF
    if MultiKeys(KEYQ)<>0
        if !isJumping() and landed
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
	NIRVANAspriteT(PROTA_SPRITE, 29, 0, 0)
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
	if drawing = 0
		keyboardListen()
		checkItemContact()
		checkKeyContact()
		checkIsJumping()
		gravity()
	end if
end sub