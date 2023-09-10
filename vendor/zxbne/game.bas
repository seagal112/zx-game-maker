#include <keys.bas>

dim linInicial, colInicial, protaRight as UBYTE
dim isJumping, goalJumping, landed as UBYTE
dim frameTile as UBYTE = 0
dim shouldDrawSprite as UBYTE = 0
dim lin as UBYTE = MAX_LINE
dim col as UBYTE = 4
dim jumpSize as UBYTE = 48
dim isColPair as UBYTE = 1
dim redrawMap as UBYTE = 0
dim enemyToKill as UBYTE = 0
dim burnToClean as UBYTE = 0
dim yStepSize = 16

function isSolidTile(lin as UBYTE, col as UBYTE) as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 1 OR tile = 2
		return 1
    end if
	    
	return 0
end function

function canMoveLeft() as UBYTE
	if (isColPair)
		return col > 0 AND isSolidTile(lin, col - 2) <> 1
	end if
		
	return col > 0 AND isSolidTile(lin, col - 1) <> 1
end function

function canMoveRight() as UBYTE
	if (isColPair)
		return col < 30 AND isSolidTile(lin, col + 2) <> 1
	end if

	return col < 30 AND isSolidTile(lin, col + 1) <> 1
end function

function canMoveUp() as UBYTE
	return isSolidTile(lin - 16, col) <> 1
end function

sub checkIsJumping()
	if isJumping = 1
		if lin = 0
			moveToScreen(8)
		elseif lin > goalJumping AND canMoveUp()
			lin = lin - yStepSize
			shouldDrawSprite = 1
		else
			isJumping = 0
        end if
	end if
end sub

function onTheSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(lin + 16, col)
	dim preTile as UBYTE = getCellByNirvanaPosition(lin + 16, col - 1)
	dim postTile as UBYTE = getCellByNirvanaPosition(lin + 16, col + 1)

	if tile = 1 OR tile = 2 OR preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
		landed = 1
		return 1
	else
		return 0
	end if 
end function

function onTheEnemy() as UBYTE
	' if (isAnEnemy(lin + 16, col) = 1 or isAnEnemy(lin + 16, col + 1) = 1 or isAnEnemy(lin + 16, col - 1) = 1)' and isFalling <> 0
	' 	killEnemy(enemyToKill, isColPair)
	' 	jump()
	' 	return 1
	' end if
		
	return 0
end function

function isFalling() as UBYTE
	return onTheSolidTile() <> 1 and onTheEnemy() <> 1
end function

sub gravity()
	if isJumping <> 1 and isFalling()
		'debug ("falling")
		if lin = MAX_LINE
			moveToScreen(2)
		else
			lin = lin + yStepSize
			shouldDrawSprite = 1
		end if
	end if
end sub

sub moveToScreen(direction as Ubyte)
	removeAllObjects()
	if direction = 6
		col = 2
		shouldDrawSprite = 1
		currentScreen = currentScreen + 1
		redrawMap = 1
	elseif direction = 4
		col = 28
		shouldDrawSprite = 1
		currentScreen = currentScreen - 1
		redrawMap = 1
	elseif direction = 2
		lin = 0
		shouldDrawSprite = 1
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
		redrawMap = 1
	elseif direction = 8
		lin = MAX_LINE + 16
		jump()
		shouldDrawSprite = 1
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
		redrawMap = 1
	end if
end sub

sub keyboardListen()
    if MultiKeys(KEYO)<>0
		if col = 0
			moveToScreen(4)
        elseif canMoveLeft()
            protaRight = 0
            col = col - 1
            shouldDrawSprite = 1
        end if
    END IF
    if MultiKeys(KEYP)<>0
		if col = 30
			moveToScreen(6)
        elseif canMoveRight()
            protaRight = 1
            col = col + 1
            shouldDrawSprite = 1
        end if
    END IF
    if MultiKeys(KEYQ)<>0
        if !isJumping AND landed AND canMoveUp()
			jump()
        end if
    END IF
    if MultiKeys(KEYA)<>0

    END IF
end sub

sub jump()
	isJumping = 1
	landed = 0
	if lin >= jumpSize
		goalJumping = lin - jumpSize
	else
		goalJumping = 0
	end if
	'jumpSound()
end sub

function getNextFrameRunning() as UBYTE
	if (protaRight)
		if frameTile = 50
			return 51
        elseif frameTile = 51
			return 52
        elseif frameTile = 52
			return 53
		else
			return 50
		end if
	else
        if frameTile = 54
            return 55
        elseif frameTile = 55
            return 56
        elseif frameTile = 56
            return 57
        else
            return 54
        end if
	end if
end function

function getNextFrameJumpingFalling() as UBYTE
	if (protaRight)
		return 58
	else
		return 59
    end if
end function

sub drawSprite()
	if shouldDrawSprite <> 1
		return
    end if

	shouldDrawSprite = 0

	' if col > 30 OR lin < 2 OR lin > MAX_LINE
	' 	return
    ' end if

	if (!isJumping and !isFalling()) or (1 = 1)
		frameTile = getNextFrameRunning()
	else
		frameTile = getNextFrameJumpingFalling()
    end if

	drawToScr(linInicial, colInicial, isColPair)
	NIRVANAspriteT(0, frameTile, lin, col)
END SUB

sub removePlayer()
	NIRVANAspriteT(0, 29, 0, 0)
end sub

sub refreshColAndLine()
	lin = PEEK SPRITELIN(0)
	col = PEEK SPRITECOL(0)
	linInicial = lin
	colInicial = col
	if col mod 2 = 0
		isColPair = 1
	else
		isColPair = 0
	end if
end sub

sub checkItemContact()
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 18
		incrementItems()
	end if
end sub

sub checkKeyContact()
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 19
		incrementKeys()
	end if
end sub

sub gameLoop()
	init()
    do
		refreshColAndLine()

		keyboardListen()

		if burnToClean <> 0
			cleanBurst(burnToClean, isColPair)
			enemyToKill = 0
			burnToClean = 0
		end if

		checkItemContact()
		checkKeyContact()
		checkIsJumping()
		gravity()
		moveEnemies(isColPair)
		drawSprite()

		if redrawMap = 1
			redrawMap = 0
			redrawScreen()
		end if

		if currentLife = 0
			removePlayer()
			enemiesDraw(1)
			go to ending
		end if
    loop
end sub

sub init()
	NIRVANAspriteT(0, 50, MAX_LINE, 4)
	protaRight = 1
	isJumping = 0
	landed = 1
end sub