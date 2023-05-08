dim linInicial, colInicial, tile, protaRight as UBYTE
dim isJumping, goalJumping, landed as UBYTE
dim frameTile as UBYTE = 0
dim shouldDrawSprite as UBYTE = 0
dim lin as UBYTE = 160
dim col as UBYTE = 2
dim jumpSize as UBYTE = 48
dim animateFrame as UBYTE = 0
dim changedDirection as UBYTE = 0
dim swordDrawed as UBYTE = 0
dim linSwordDrawed as UBYTE = 0
dim colSwordDrawed as UBYTE = 0
dim swordTile as UBYTE = 24
dim isColPair as UBYTE = 1


function isSolidTile(lin as UBYTE, col as UBYTE) as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 13 OR tile = 21
		return 1
    else
	    return 0
    end if
end function

function canMoveLeft() as UBYTE
	return (col > 0 AND !isSolidTile(lin, col - 1))
end function

function canMoveRight() as UBYTE
	return col < 30 AND !isSolidTile(lin, col + 1)
end function

function canMoveUp() as UBYTE
	return !isSolidTile(lin - 16, col)
end function

function canFall() as UBYTE
	if (isColPair)
		return !isSolidTile(lin + 16, col)
	else
		return !isSolidTile(lin - 16, col - 1) AND !isSolidTile(lin - 16, col - 1)
    end if
end function

sub checkIsJumping()
	if isJumping
		if lin > goalJumping AND canMoveUp()
			lin = lin - 16
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

	return tile = 13 OR tile = 21 OR preTile = 13 OR preTile = 21 OR postTile = 13 OR postTile = 21
end function

function isFalling() as UBYTE
	return !onTheSolidTile()
end function

sub gravity()
	if !isJumping and isFalling()
		lin = lin + 16
		shouldDrawSprite = 1
	elseif !isJumping and !isFalling()
		landed = 1
	end if
end sub

FUNCTION FASTCALL getLastKey() as uByte
    'return peek 23560
    ' This returns the lastK variable from the Spectrum System variables - telling us what keycode was pressed last.
    ' The below assembly does exactly the same thing, but should be very slightly more streamlined.
    ' For this game remember it's important to be able to pre-select directions - so it’s not the key that’s being pressed now that’s important - it’s the direction key that was pressed last.
    asm
        ld a,(23560)
    end asm
END FUNCTION

sub keyboardListen()
    dim keyPressed as UBYTE
    
    keyPressed = getLastKey()

    if keyPressed=CODE "o"
        if canMoveLeft()
            if protaRight = 1
                changedDirection = 1
            else
                changedDirection = 0
            end if
            protaRight = 0
            col = col - 1
            shouldDrawSprite = 1
        end if
    END IF
    if keyPressed=CODE "p"
        if canMoveRight()
            if protaLeft = 1
                changedDirection = 1
            else
                changedDirection = 0
            end if
            protaRight = 1
            col = col + 1
            shouldDrawSprite = 1
        end if
    END IF
    if keyPressed=CODE "q"
        if !isJumping AND landed
            isJumping = 1
            landed = 0
            goalJumping = lin - jumpSize
        end if
    END IF
    if keyPressed=CODE "p"

    END IF
end sub

function getNextFrameRunning() as UBYTE
	if (protaRight)
		if frameTile = 0
			return 1
        elseif frameTile = 1
			return 2
        elseif frameTile = 2
			return 3
		else
			return 0
		end if
	else
        if frameTile = 6
            return 7
        elseif frameTile = 7
            return 8
        elseif frameTile = 8
            return 9
        else
            return 6
        end if
	end if
end function

function getNextFrameJumpingFalling() as UBYTE
	if (protaRight)
		return 4
	else
		return 10
    end if
end function

sub drawSprite()
	if !shouldDrawSprite
		return
    end if

	shouldDrawSprite = 0

	if col > 30 OR lin < 2 OR lin > 160
		return
    end if

	if (lin mod 2) > 0
		return
    end if

	if !isJumping and !isFalling()
		frameTile = getNextFrameRunning()
	else
		frameTile = getNextFrameJumpingFalling()
    end if

	NIRVANAspriteT(0, frameTile, lin, col)
	drawToScr(linInicial, colInicial, isColPair, protaRight)
END SUB

sub gameLoop()
	init()
    do
		lin = PEEK SPRITELIN(0)
		col = PEEK SPRITECOL(0)
		linInicial = lin
		colInicial = col
        if col mod 2 = 0
		    isColPair = 1
        else
            isColPair = 0
        end if 
		keyboardListen()
		checkIsJumping()
		gravity()
		drawSprite()
	' 	// redrawFlame()
	' 	// animateTiles()
	' 	// drawSword()
	' 	// NIRVANAP_halt()
	' 	// eraseSword()
	' 	NIRVANAP_halt()
	' 	NIRVANAP_halt()
		NIRVANAhalt()
    loop
end sub

sub init()
	tile = PEEK SPRITEVAL(0)
	NIRVANAspriteT(0, tile, 160, 2)
	protaRight = 1
	isJumping = 0
	landed = 1
	animateFrame = 0
end sub