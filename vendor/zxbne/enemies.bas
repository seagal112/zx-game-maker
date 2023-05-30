CONST ENEMY_TILE = 0
CONST ENEMY_LIN_INI = 1
CONST ENEMY_COL_INI = 2
CONST ENEMY_LIN_END = 3
CONST ENEMY_COL_END = 4
CONST ENEMY_RIGHT = 5
CONST ENEMY_CURRENT_LIN = 6
CONST ENEMY_CURRENT_COL = 7
CONST ENEMY_ALIVE = 8
CONST ENEMY_SPRITE = 9

sub checkEnemyContact()
	if ((isColPair = 1 and isAnEnemy(lin, col + 2) = 1) or (isColPair <> 1 and isAnEnemy(lin, col + 1) = 1))
		col = col - 2
		shouldDrawSprite = 1
		decrementLife()
		damageSound()
	end if

	if ((isColPair = 1 and isAnEnemy(lin, col - 2) = 1) or (isColPair <> 1 and isAnEnemy(lin, col - 1) = 1))
		col = col + 2
		shouldDrawSprite = 1
		decrementLife()
		damageSound()
	end if

	' if isAnEnemy(lin + 16, col)
		' isJumping = 1
		' landed = 0
		' shouldDrawSprite = 1
		' decrementLife()
		' damageSound()
	' end if
	
	if isAnEnemy(lin - 16, col)
		decrementLife()
		damageSound()
	end if
end sub

sub moveEnemies(isColPair as Ubyte)
    ' if framec bAND %10
    '     return
    ' end if

    dim counter as ubyte = 0
    for key=0 TO 2
        if enemies(currentScreen, key, ENEMY_TILE) = 0
            continue for
        end if
        if enemies(currentScreen, key, ENEMY_ALIVE) = 1 'In the screen and still live
            if counter < 8
                dim tile as UBYTE = enemies(currentScreen, key, ENEMY_TILE)
                dim col as UBYTE = PEEK SPRITECOL(enemies(currentScreen, key, ENEMY_SPRITE))
                dim lin as UBYTE = PEEK SPRITELIN(enemies(currentScreen, key, ENEMY_SPRITE))

                if enemies(currentScreen, key, ENEMY_RIGHT) = 1 and enemies(currentScreen, key, ENEMY_COL_END) = col
                    enemies(currentScreen, key, ENEMY_RIGHT) = 0
                elseif enemies(currentScreen, key, ENEMY_RIGHT) <> 1 and enemies(currentScreen, key, ENEMY_COL_INI) = col
                    enemies(currentScreen, key, ENEMY_RIGHT) = 1
                end if
                    
                if enemies(currentScreen, key, ENEMY_RIGHT) = 1
                    if col < enemies(currentScreen, key, ENEMY_COL_END)
                        enemies(currentScreen, key, ENEMY_CURRENT_COL) = enemies(currentScreen, key, ENEMY_CURRENT_COL) + 1
                    end if
                else
                    if col > enemies(currentScreen, key, ENEMY_COL_INI)
                        enemies(currentScreen, key, ENEMY_CURRENT_COL) = enemies(currentScreen, key, ENEMY_CURRENT_COL) - 1
                    end if
                end if

                drawToScr(lin, col, isColPair)
                NIRVANAspriteT(1, tile, lin, enemies(currentScreen, key, ENEMY_CURRENT_COL))
            end if
            counter = counter + 1
        end if
    next key
end sub

sub killEnemy(enemyToKill as Ubyte, isColPair as Ubyte)
    dim col as UBYTE = PEEK SPRITECOL(enemyToKill)
    dim lin as UBYTE = PEEK SPRITELIN(enemyToKill)
    
    enemies(currentScreen, enemyToKill - 1, ENEMY_ALIVE) = 0
    
    drawToScr(lin, col, isColPair)
    NIRVANAspriteT(enemyToKill, 29, 0, 0)
    killEnemySound()
end sub

sub enemiesDraw(delete as ubyte)
    dim tile as Ubyte = 29
	for key=0 TO 2
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
