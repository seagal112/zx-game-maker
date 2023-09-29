CONST ENEMY_TILE as UBYTE = 0
CONST ENEMY_LIN_INI as UBYTE = 1
CONST ENEMY_COL_INI as UBYTE = 2
CONST ENEMY_LIN_END as UBYTE = 3
CONST ENEMY_COL_END as UBYTE = 4
CONST ENEMY_RIGHT as UBYTE = 5
CONST ENEMY_CURRENT_LIN as UBYTE = 6
CONST ENEMY_CURRENT_COL as UBYTE = 7
CONST ENEMY_ALIVE as UBYTE = 8
CONST ENEMY_SPRITE as UBYTE = 9
CONST OBJECT_TYPE as UBYTE = 9
CONST ENEMY_BURST_CELL as UBYTE = 14
CONST OBJECT_TYPE_EMPTY = 0
CONST OBJECT_TYPE_ENEMY = 1
CONST OBJECT_TYPE_KEY = 2
CONST OBJECT_TYPE_ITEM = 3

function isAnEnemy(lin as UBYTE, col as UBYTE) as UBYTE
    for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, key, ENEMY_ALIVE) = 1 and enemies(currentScreen, key, OBJECT_TYPE) = OBJECT_TYPE_ENEMY and enemies(currentScreen, key, ENEMY_CURRENT_LIN) = lin and enemies(currentScreen, key, ENEMY_CURRENT_COL) = col 
            return enemies(currentScreen, key, ENEMY_SPRITE)
        end if
    next key
	return 0
end function

function isAKey(lin as UBYTE, col as UBYTE) as UBYTE
    for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, key, ENEMY_ALIVE) = 1 and enemies(currentScreen, key, OBJECT_TYPE) = OBJECT_TYPE_KEY and enemies(currentScreen, key, ENEMY_CURRENT_LIN) = lin and enemies(currentScreen, key, ENEMY_CURRENT_COL) = col 
            return enemies(currentScreen, key, ENEMY_SPRITE)
        end if
    next key
	return 0
end function

function isAnItem(lin as UBYTE, col as UBYTE) as UBYTE
    for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, key, ENEMY_ALIVE) = 1 and enemies(currentScreen, key, OBJECT_TYPE) = OBJECT_TYPE_ITEM and enemies(currentScreen, key, ENEMY_CURRENT_LIN) = lin and enemies(currentScreen, key, ENEMY_CURRENT_COL) = col 
            return enemies(currentScreen, key, ENEMY_SPRITE)
        end if
    next key
	return 0
end function

sub moveEnemies(isColPair as Ubyte)
    ' if framec bAND %10
    '     return
    ' end if

    dim counter as ubyte = 0
    for enemyId=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, enemyId, OBJECT_TYPE) <> OBJECT_TYPE_ENEMY
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_TILE) = 0
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) = 1 'In the screen and still live
            if counter < 8
                dim tile as UBYTE = enemies(currentScreen, enemyId, ENEMY_TILE)
                dim enemyCol as UBYTE = PEEK SPRITECOL(enemies(currentScreen, enemyId, ENEMY_SPRITE))
                dim enemyLin as UBYTE = PEEK SPRITELIN(enemies(currentScreen, enemyId, ENEMY_SPRITE))

                if enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1 and enemies(currentScreen, enemyId, ENEMY_COL_END) = enemyCol
                    enemies(currentScreen, enemyId, ENEMY_RIGHT) = 0
                elseif enemies(currentScreen, enemyId, ENEMY_RIGHT) <> 1 and enemies(currentScreen, enemyId, ENEMY_COL_INI) = enemyCol
                    enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1
                end if
                    
                if enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1
                    if enemyCol < enemies(currentScreen, enemyId, ENEMY_COL_END)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) + 1
                    end if
                else
                    if enemyCol > enemies(currentScreen, enemyId, ENEMY_COL_INI)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) - 1
                    end if
                end if

                protaLin = PEEK SPRITELIN(0)
                protaCol = PEEK SPRITECOL(0)
                if (protaLin = enemyLin and protaCol = enemyCol)
                    decrementLife()
                    damageSound()
                end if

                drawToScr(enemyLin, enemyCol, isColPair)
                NIRVANAspriteT(1, tile, enemyLin, enemies(currentScreen, enemyId, ENEMY_CURRENT_COL))
            end if
            counter = counter + 1
        end if
    next enemyId
end sub

sub killEnemy(enemyToKill as Ubyte, isColPair as Ubyte, burst as Ubyte)
    dim col as UBYTE = PEEK SPRITECOL(enemyToKill)
    dim lin as UBYTE = PEEK SPRITELIN(enemyToKill)
    
    enemies(currentScreen, enemyToKill - 1, ENEMY_ALIVE) = 0
    if burst
        NIRVANAspriteT(enemyToKill, ENEMY_BURST_CELL, lin, col)
    else
        NIRVANAspriteT(enemyToKill, 29, 0, 0)
        drawToScr(lin, col, isColPair)
    end if
    'killEnemySound()
end sub

sub cleanBurst(enemyToKill as Ubyte, isColPair as Ubyte)
    dim col as UBYTE = PEEK SPRITECOL(enemyToKill)
    dim lin as UBYTE = PEEK SPRITELIN(enemyToKill)

    NIRVANAspriteT(enemyToKill, 29, 0, 0)
    drawToScr(lin, col, isColPair)
end sub

sub enemiesDraw(delete as ubyte)
    dim tile as Ubyte = 29
	for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, key, ENEMY_TILE) = 0
            continue for
        end if
		if enemies(currentScreen, key, ENEMY_ALIVE) = 1 'In the screen and still live
            if delete = 1
                tile = 29
            else
                tile = enemies(currentScreen, key, ENEMY_TILE)
            end if
            NIRVANAspriteT(enemies(currentScreen, key, ENEMY_SPRITE), tile, enemies(currentScreen, key, ENEMY_CURRENT_LIN), enemies(currentScreen, key, ENEMY_CURRENT_COL))
		end if
	next key
end sub

sub removeAllObjects()
    for i = 1 to 6
        dim col as UBYTE = PEEK SPRITECOL(i)
        dim lin as UBYTE = PEEK SPRITELIN(i)
    
        NIRVANAspriteT(i, 28, 0, 0)
        drawToScr(lin, col, isColPair)
	next i
end sub
