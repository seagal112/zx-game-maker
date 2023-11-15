CONST ENEMY_TILE as UBYTE = 0
CONST ENEMY_LIN_INI as UBYTE = 1
CONST ENEMY_COL_INI as UBYTE = 2
CONST ENEMY_LIN_END as UBYTE = 3
CONST ENEMY_COL_END as UBYTE = 4
CONST ENEMY_DIRECTION_RIGHT as UBYTE = 5
CONST ENEMY_CURRENT_LIN as UBYTE = 6
CONST ENEMY_CURRENT_COL as UBYTE = 7
CONST ENEMY_ALIVE as UBYTE = 8
CONST ENEMY_SPRITE as UBYTE = 9
CONST ENEMY_DIRECTION_UP as UBYTE = 10

function isAKey(lin as UBYTE, col as UBYTE) as UBYTE
    if lin = key_lin and col = key_col
        return key_sprite
	else
        return 10
    end if
end function

sub setScreenElements()
    screenObjects = screenObjectsInitial
end sub

sub setEnemies()
    enemies = enemiesInitial
    enemiesPerScreen = enemiesPerScreenInitial
end sub

sub moveEnemies()
    if framec bAND %10
        return
    end if

    if animateEnemies <> 1
        return
    end if

    dim counter as ubyte = 0
    dim frame as ubyte = 0
    dim maxEnemiesCount = 0

    if enemiesPerScreen(currentScreen) > 0 then maxEnemiesCount = enemiesPerScreen(currentScreen) - 1
    for enemyId=0 TO maxEnemiesCount
        if enemies(currentScreen, enemyId, ENEMY_TILE) = 0
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) > 0 'In the screen and still live
            if counter < 8
                dim tile as UBYTE
                dim enemyCol as UBYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) 
                dim enemyLin as UBYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) 

                if (enemies(currentScreen, enemyId, ENEMY_COL_INI) <> enemies(currentScreen, enemyId, ENEMY_COL_END))
                    if enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT) = 1 and enemies(currentScreen, enemyId, ENEMY_COL_END) = enemyCol
                        enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT) = 0
                    elseif enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT) <> 1 and enemies(currentScreen, enemyId, ENEMY_COL_INI) = enemyCol
                        enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT) = 1
                    end if
                end if
                    
                if enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT) = 1
                    if enemyCol < enemies(currentScreen, enemyId, ENEMY_COL_END)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) + 1
                    end if
                    tile = enemies(currentScreen, enemyId, ENEMY_TILE)
                else
                    if enemyCol > enemies(currentScreen, enemyId, ENEMY_COL_INI)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) - 1
                    end if
                    tile = enemies(currentScreen, enemyId, ENEMY_TILE) + 2
                end if

                if (enemies(currentScreen, enemyId, ENEMY_LIN_INI) <> enemies(currentScreen, enemyId, ENEMY_LIN_END))
                    if enemies(currentScreen, enemyId, ENEMY_LIN_END) = enemyLin
                        enemies(currentScreen, enemyId, ENEMY_DIRECTION_UP) = 0
                    elseif enemies(currentScreen, enemyId, ENEMY_LIN_INI) = enemyLin
                        enemies(currentScreen, enemyId, ENEMY_DIRECTION_UP) = 1
                    end if
                    
                    if enemies(currentScreen, enemyId, ENEMY_DIRECTION_UP) = 1
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) - 1
                    else
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) + 1
                    end if
                end if

                if getSpriteFrame(enemyId) = 0
                    tile = tile + 1
                end if

                saveSprite(enemyId, enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN), enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), tile, enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT))

                checkProtaCollision(enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN), enemies(currentScreen, enemyId, ENEMY_DIRECTION_RIGHT))
            end if
            counter = counter + 1
        end if
    next enemyId
end sub

sub checkProtaCollision(enemyCol as ubyte, enemyLin as ubyte, enemyDirection as ubyte)
    dim protaX0 as ubyte = getSpriteLin(PROTA_SPRITE)
    dim protaY0 as ubyte = getSpriteCol(PROTA_SPRITE)
    dim protaX1 as ubyte = protaX0 + 2
    dim protaY1 as ubyte = protaY0 + 2

    dim enemyX0 as ubyte = enemyLin
    dim enemyY0 as ubyte = enemyCol
    dim enemyX1 as ubyte = enemyX0 + 2
    dim enemyY1 as ubyte = enemyY0 + 2

    if protaX0 > enemyX1 then return
    if protaX1 < enemyX0 then return
    if protaY0 > enemyY1 then return
    if protaY1 < enemyY0 then return

    protaTouch(enemyDirection)

end sub

sub protaTouch(enemyDirection as ubyte)
    ' protaBounce(enemyDirection)
    startJumping()
    decrementLife()
    damageSound()
end sub
