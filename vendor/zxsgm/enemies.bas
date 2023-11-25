CONST ENEMY_TILE as UBYTE = 0
CONST ENEMY_LIN_INI as UBYTE = 1
CONST ENEMY_COL_INI as UBYTE = 2
CONST ENEMY_LIN_END as UBYTE = 3
CONST ENEMY_COL_END as UBYTE = 4
CONST ENEMY_HORIZONTAL_DIRECTION as UBYTE = 5
CONST ENEMY_CURRENT_LIN as UBYTE = 6
CONST ENEMY_CURRENT_COL as UBYTE = 7
CONST ENEMY_ALIVE as UBYTE = 8
CONST ENEMY_SPRITE as UBYTE = 9
CONST ENEMY_VERTICAL_DIRECTION as UBYTE = 10

sub setScreenElements()
    screenObjects = screenObjectsInitial
end sub

sub setEnemies()
    enemies = enemiesInitial
    enemiesPerScreen = enemiesPerScreenInitial
end sub

function checkPlatformHasProtaOnTop(x as ubyte, y as ubyte) as ubyte
    dim protaX0 as ubyte = getSpriteCol(PROTA_SPRITE)
    dim protaX1 as ubyte = protaX0 + 2
    dim protaY0 as ubyte = getSpriteLin(PROTA_SPRITE)

    if protaX1 < x then return 0
    if protaX0 > x + 4 then return 0
    if protaY0 <> y - 4 then return 0

    return 1
end function

sub moveEnemies()
    dim counter as ubyte = 0
    dim frame as ubyte = 0
    dim maxEnemiesCount as ubyte = 0
    dim firstXExecuted as ubyte = 0

    if enemiesPerScreen(currentScreen) > 0 then maxEnemiesCount = enemiesPerScreen(currentScreen) - 1
    for enemyId=0 TO maxEnemiesCount
        if enemies(currentScreen, enemyId, ENEMY_TILE) = 0
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) > 0 'In the screen and still live
            dim tile as BYTE
            dim enemyCol as BYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) 
            dim enemyLin as BYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN)

            tile = enemies(currentScreen, enemyId, ENEMY_TILE)

            if enemies(currentScreen, enemyId, ENEMY_COL_INI) = enemies(currentScreen, enemyId, ENEMY_COL_END) then enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
            if enemies(currentScreen, enemyId, ENEMY_LIN_INI) = enemies(currentScreen, enemyId, ENEMY_LIN_END) then enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION) = 0

            if enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION)
                if enemies(currentScreen, enemyId, ENEMY_COL_INI) = enemyCol or enemies(currentScreen, enemyId, ENEMY_COL_END) = enemyCol
                    enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION) = enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION) * -1
                end if
            end if
            
            enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) + enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION)

            if enemies(currentScreen, enemyId, ENEMY_TILE) < 16 ' Is a platform not an enemy, only 2 frames, 1 direction
                if checkPlatformHasProtaOnTop(enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN))
                    saveSpriteCol(PROTA_SPRITE, getSpriteCol(PROTA_SPRITE) + enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION))
                end if
                tile = enemies(currentScreen, enemyId, ENEMY_TILE)
            elseif enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1
                tile = enemies(currentScreen, enemyId, ENEMY_TILE)
            elseif enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1
                tile = enemies(currentScreen, enemyId, ENEMY_TILE) + 2
            end if

            if enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION)
                if enemies(currentScreen, enemyId, ENEMY_LIN_INI) = enemyLin or enemies(currentScreen, enemyId, ENEMY_LIN_END) = enemyLin
                    enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION) = enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION) * -1
                end if
            end if
            
            enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) + enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION)

            ' if enemies(currentScreen, enemyId, ENEMY_TILE) < 16
            '     saveSpriteLin(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + enemies(currentScreen, enemyId, ENEMY_VERTICAL_DIRECTION))
            ' end if

            if enemFrame
                tile = tile + 1
            end if

            saveSprite(enemyId, enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN), enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), tile, enemies(currentScreen, enemyId, ENEMY_HORIZONTAL_DIRECTION))

            if enemies(currentScreen, enemyId, ENEMY_TILE) > 15
                checkProtaCollision(enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN))
            end if
        end if
    next enemyId
end sub

sub checkProtaCollision(enemyCol as ubyte, enemyLin as ubyte)
    dim protaX0 as ubyte = getSpriteLin(PROTA_SPRITE)
    dim protaY0 as ubyte = getSpriteCol(PROTA_SPRITE)
    dim protaX1 as ubyte = protaX0 + 2
    dim protaY1 as ubyte = protaY0 + 2

    dim enemyX0 as ubyte = enemyLin
    dim enemyY0 as ubyte = enemyCol
    dim enemyX1 as ubyte = enemyX0 + 2
    dim enemyY1 as ubyte = enemyY0 + 2

    if protaX1 < enemyX0 then return
    if protaX0 > enemyX1 then return
    if protaY1 < enemyY0 then return
    if protaY0 > enemyY1 then return

    protaTouch()

end sub

sub protaTouch()
    startJumping()
    decrementLife()
    damageSound()
end sub

function allEnemiesKilled() as ubyte
    dim maxEnemiesCount as ubyte = 0
    dim enemiesKilled as ubyte = 1

    if enemiesPerScreen(currentScreen) = 0 then return 1

    for enemyId=0 TO enemiesPerScreen(currentScreen) - 1
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) > 0 'In the screen and still live
            return 0
        end if
    next enemyId

    return 1
end function

function checkPlatformByXY(x as ubyte, y as ubyte) as ubyte
    dim maxEnemiesCount as ubyte = 0
    dim enemiesKilled as ubyte = 1

    if enemiesPerScreen(currentScreen) = 0 then return 0

    for enemyId=0 TO enemiesPerScreen(currentScreen) - 1
        if enemies(currentScreen, enemyId, ENEMY_TILE) < 16 then
            dim enemyCol as ubyte = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) 
            dim enemyLin as ubyte = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN)

            if x < enemyCol - 2 then return 0
            if x > enemyCol + 4 then return 0
            if y <> enemyLin then return 0
            
            return 1
        end if
    next enemyId

    return 0
end function