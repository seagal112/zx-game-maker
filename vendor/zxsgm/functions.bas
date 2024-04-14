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

sub printLife()
	PRINT AT 22, 5; "  "  
	PRINT AT 22, 5; currentLife
	PRINT AT 22, 16; currentKeys
    #ifdef HISCORE_ENABLED
	    PRINT AT 23, 25 - LEN(STR$(score)); score
    #endif
	PRINT AT 22, 30; currentItems
end sub

function isADamageTile(tile as ubyte) as UBYTE
    for i = 0 to DAMAGE_TILES_ARRAY_SIZE
        if peek(@damageTiles + i) = tile
            return 1
        end if
    next i
	return 0
end function

function allEnemiesKilled() as ubyte
    if enemiesPerScreen(currentScreen) = 0 then return 1

    for enemyId=0 TO enemiesPerScreen(currentScreen) - 1
        if decompressedEnemiesScreen(enemyId, 0) < 16
            continue for
        end if
        if decompressedEnemiesScreen(enemyId, 8) <> 99 'is not invincible'
            if decompressedEnemiesScreen(enemyId, 8) > 0 'In the screen and still live
                return 0
            end if
        end if
    next enemyId

    return 1
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile as ubyte = GetTile(col, lin)

    if tile > 0 and tile < 63 then return 1

    #ifdef SHOULD_KILL_ENEMIES_ENABLED
        if screensWon(currentScreen) then return 0
    #endif

    if tile = 63 then
        if allEnemiesKilled()
            return 0
        else
            return 1
        end if
    end if
	return 0
end function

sub protaTouch()
    invincible = 1
    invincibleFrame = framec
    decrementLife()
    BeepFX_Play(1)
end sub

function CheckStaticPlatform(x as uByte, y as uByte) as uByte
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    dim tile as ubyte = GetTile(col, lin)

    if tile > 63 and tile < 80 return 1

    return 0
end function

function CheckCollision(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    elseif xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
        if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    	if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
	elseif not xIsEven and yIsEven
		if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
		if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
    elseif not xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
        if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
		if isSolidTileByColLin(col + 2, lin + 2) then return 1
    end if
	return 0
end function

function isSolidTileByXY(x as ubyte, y as ubyte) as ubyte
    dim col as uByte = x >> 1
    dim lin as uByte = y >> 1
    
    dim tile as ubyte = GetTile(col, lin)

	return tile > 0 and tile < 64 ' is solid tile
end function

#ifdef INIT_TEXTS
    sub showInitTexts(Text as String)
        dim n as uByte
        dim line = ""
        dim word = ""
        dim y = 1
        dim x = 0
        cls
        for n=0 to len(Text)-1
            let c = Text(n to n)
            if c = " " or n = len(Text) - 1 then
                if len(line + word) > 31 then
                    print at y, 0; line
                    beep .01,0
                    let line = word
                    if c = " " then
                        let line = line + " "
                    end if
                    let y = y + 1
                    let x = 0
                else
                    let line = line + word
                    if c = " " then
                        let line = line + " "
                    end if
                end if
                let word = ""
            else
                let word = word + c
            end if
        next n
        if line <> "" then
            print at y, x; line
        end if
        while INKEY$<>"":wend
        while INKEY$="":wend
    end sub
#endif