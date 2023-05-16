CONST ENEMY_TILE = 0
CONST ENEMY_LIN_INI = 1
CONST ENEMY_COL_INI = 2
CONST ENEMY_LIN_END = 3
CONST ENEMY_COL_END = 4
CONST ENEMY_SCREEN = 5
CONST ENEMY_RIGHT = 6
CONST ENEMY_CURRENT_LIN = 7
CONST ENEMY_CURRENT_COL = 8
CONST ENEMY_ALIVE = 9
CONST ENEMY_SPRITE = 10

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

sub moveEnemies(loopCounter as Ubyte, isColPair as Ubyte)
    ' if framec bAND %10
    '     return
    ' end if

    dim counter as ubyte = 0
    for key=0 TO enemiesCount
        if enemies(key, 5) = currentScreen and enemies(key, ENEMY_ALIVE) = 1 'In the screen and still live
            if counter < 8
                dim tile as UBYTE = enemies(key, ENEMY_TILE)
                dim col as UBYTE = PEEK SPRITECOL(enemies(key, ENEMY_SPRITE))
                dim lin as UBYTE = PEEK SPRITELIN(enemies(key, ENEMY_SPRITE))

                if enemies(key, ENEMY_RIGHT) = 1 and enemies(key, ENEMY_COL_END) = col
                    enemies(key, ENEMY_RIGHT) = 0
                elseif enemies(key, ENEMY_RIGHT) <> 1 and enemies(key, ENEMY_COL_INI) = col
                    enemies(key, ENEMY_RIGHT) = 1
                end if
                    
                if enemies(key, ENEMY_RIGHT) = 1
                    if col < enemies(key, ENEMY_COL_END)
                        enemies(key, ENEMY_CURRENT_COL) = enemies(key, ENEMY_CURRENT_COL) + 1
                    end if
                else
                    if col > enemies(key, ENEMY_COL_INI)
                        enemies(key, ENEMY_CURRENT_COL) = enemies(key, ENEMY_CURRENT_COL) - 1
                    end if
                end if

                drawToScr(lin, col, isColPair)
                NIRVANAspriteT(1, tile, lin, enemies(key, ENEMY_CURRENT_COL))
            end if
            counter = counter + 1
        end if
    next key
end sub

sub killEnemy(enemyToKill as Ubyte, isColPair as Ubyte)
    dim col as UBYTE = PEEK SPRITECOL(enemyToKill)
    dim lin as UBYTE = PEEK SPRITELIN(enemyToKill)

    for key=0 TO enemiesCount
        if enemies(key, 5) = currentScreen and enemies(key, ENEMY_ALIVE) = 1
            if col > enemies(key, ENEMY_COL_INI) and col < enemies(key, ENEMY_COL_END)
                enemies(key, ENEMY_ALIVE) = 0 ' Mark as kill
            end if
        end if
    next key
    
    drawToScr(lin, col, isColPair)
    NIRVANAspriteT(enemyToKill, 29, 0, 0)
    killEnemySound()
end sub

sub enemiesDraw(delete as ubyte)
	dim counter as ubyte = 1

	for key=0 TO enemiesCount
		if enemies(key, ENEMY_SCREEN) = currentScreen and enemies(key, ENEMY_ALIVE) = 1 'In the screen and still live
			if counter < 3
                enemies(key, ENEMY_SPRITE) = counter
				if delete = 1
					NIRVANAspriteT(counter, 29, enemies(key, 7), enemies(key, 8))
				else
					NIRVANAspriteT(counter, enemies(key, 0), enemies(key, 7), enemies(key, 8))
				end if
			end if
			counter = counter + 1
		end if
	next key
end sub
