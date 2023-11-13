const BURST_SPRITE_ID as ubyte = 15
const BULLET_SPEED as ubyte = 2

dim bulletPositionX as ubyte = 0
dim bulletPositionY as ubyte = 0
dim bulletDirectionIsRight as ubyte = 0

dim bulletRight(7) as ubyte

bulletRight(0) = tileSet(1, 0)
bulletRight(1) = tileSet(1, 1)
bulletRight(2) = tileSet(1, 2)
bulletRight(3) = tileSet(1, 3)
bulletRight(4) = tileSet(1, 4)
bulletRight(5) = tileSet(1, 5)
bulletRight(6) = tileSet(1, 6)
bulletRight(7) = tileSet(1, 7)

dim bulletLeft(7) as ubyte

bulletLeft(0) = hMirror(tileSet(1, 0))
bulletLeft(1) = hMirror(tileSet(1, 1))
bulletLeft(2) = hMirror(tileSet(1, 2))
bulletLeft(3) = hMirror(tileSet(1, 3))
bulletLeft(4) = hMirror(tileSet(1, 4))
bulletLeft(5) = hMirror(tileSet(1, 5))
bulletLeft(6) = hMirror(tileSet(1, 6))
bulletLeft(7) = hMirror(tileSet(1, 7))

spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletRight)
spritesSet(BULLET_SPRITE_LEFT_ID) = Create1x1Sprite(@bulletLeft)

' sub createBullet(directionRight as ubyte)
'     if directionRight
'         spritesSet(BULLET_SPRITE_ID) = Create1x1Sprite(@bulletRight)
'     else
'         spritesSet(BULLET_SPRITE_ID) = Create1x1Sprite(@bulletLeft)
'     end if
' end sub

function bulletInMovement() as ubyte
    return bulletPositionX <> 0
end function

sub moveBullet()
    dim maxXScreenRight as ubyte = 60
    dim maxXScreenLeft as ubyte = 2
    dim limit as ubyte = 0

    if bulletPositionX <> 0
        if BULLET_DISTANCE <> 0
            dim protaX = getSpriteCol(PROTA_SPRITE)
            if bulletDirectionIsRight = 1
                if protaX + BULLET_DISTANCE > maxXScreenRight
                    limit = maxXScreenRight
                else
                    limit = protaX + BULLET_DISTANCE
                end if
                if bulletPositionX > limit
                    bulletPositionX = 0
                else
                    bulletPositionX = bulletPositionX + BULLET_SPEED
                end if
            else
                if protaX - BULLET_DISTANCE < maxXScreenLeft
                    limit = maxXScreenLeft
                else
                    limit = protaX - BULLET_DISTANCE + 1
                end if
                if bulletPositionX < limit
                    bulletPositionX = 0
                else
                    bulletPositionX = bulletPositionX - BULLET_SPEED
                end if
            end if
        else
            if bulletDirectionIsRight = 1
                if bulletPositionX > maxXScreenRight
                    bulletPositionX = 0
                else
                    bulletPositionX = bulletPositionX + BULLET_SPEED
                end if
            else
                if bulletPositionX < maxXScreenLeft
                    bulletPositionX = 0
                else
                    bulletPositionX = bulletPositionX - BULLET_SPEED
                end if
            end if
        end if

        checkBulletCollision()
    end if
end sub

sub checkBulletCollision()
    if isSolidTileByXY(bulletPositionX, bulletPositionY) or isSolidTileByXY(bulletPositionX, bulletPositionY + 1)
        resetBullet()
    end if

    for enemyId=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, enemyId, OBJECT_TYPE) <> OBJECT_TYPE_ENEMY then continue for
        if enemies(currentScreen, enemyId, ENEMY_TILE) = 0 then continue for
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) = 0 then continue for

        dim enemyY = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN)

        if enemyY <> bulletPositionY - 1 and enemyY <> bulletPositionY and enemyY <> bulletPositionY + 1 and enemyY <> bulletPositionY + 2 then continue for

        dim enemyX = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL)

        if enemyX = bulletPositionX or enemyX - 1 = bulletPositionX or enemyX + 1 = bulletPositionX
            damageEnemy(enemyId)
            resetBullet()
        end if
    next enemyId
end sub

sub resetBullet()
    bulletPositionX = 0
    bulletPositionY = 0
    bulletDirectionIsRight = 0
end sub

sub damageEnemy(enemyToKill as Ubyte)
    enemies(currentScreen, enemyToKill, ENEMY_ALIVE) = enemies(currentScreen, enemyToKill, ENEMY_ALIVE) - 1

    if enemies(currentScreen, enemyToKill, ENEMY_ALIVE) = 0
        saveSprite(enemyToKill, 0, 0, 0, 0)
        drawBurst(enemies(currentScreen, enemyToKill, ENEMY_CURRENT_COL), enemies(currentScreen, enemyToKill, ENEMY_CURRENT_LIN))
    end if
    killEnemySound()
end sub
