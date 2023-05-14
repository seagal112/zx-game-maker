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

sub moveEnemies(loopCounter as Ubyte)
    if loopCounter mod 2 <> 0
        return
    end if

    dim counter as ubyte = 0
    for key=0 TO enemiesCount
        if enemies(key, 5) = currentScreen and enemies(key, 9) = 1 'In the screen and still live
            if counter < 8
                dim tile as UBYTE = enemies(key, 0)
                dim col as UBYTE = PEEK SPRITECOL(1)
                dim lin as UBYTE = PEEK SPRITELIN(1)

                if enemies(key, 6) = 1 and enemies(key, 4) = col
                    enemies(key, 6) = 0
                elseif enemies(key, 6) <> 1 and enemies(key, 2) = col
                    enemies(key, 6) = 1
                end if

                dim pair as ubyte = 0
                if col mod 2 = 0
                    pair = 1
                end if
                    
                if enemies(key, 6) = 1
                    if col < enemies(key, 4)
                        enemies(key, 8) = enemies(key, 8) + 1
                    end if
                else
                    if col > enemies(key, 2)
                        enemies(key, 8) = enemies(key, 8) - 1
                    end if
                end if

                drawToScr(lin, col, pair)
                NIRVANAspriteT(1, tile, lin, enemies(key, 8))
            end if
            counter = counter + 1
        end if
    next key
end sub

' TODO: Pass the sprite to kill and save in enemies structure sprite number
sub killEnemy()
    dim col as UBYTE = PEEK SPRITECOL(1)
    dim lin as UBYTE = PEEK SPRITELIN(1)

    for key=0 TO enemiesCount
        if col > enemies(key, 2) and col < enemies(key, 4)
            enemies(key, 9) = 0 ' Mark as kill
        end if
    next key

    dim pair as ubyte = 0
    if col mod 2 = 0
        pair = 1
    end if
    
    drawToScr(lin, col, pair)
    NIRVANAspriteT(1, 29, 0, 0)
    killEnemySound()
end sub
