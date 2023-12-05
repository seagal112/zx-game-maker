const BURST_SPRITE_ID as ubyte = 15
const BULLET_SPEED as ubyte = 2

dim bulletPositionX as ubyte = 0
dim bulletPositionY as ubyte = 0
dim bulletDirectionIsRight as ubyte = 0

dim bullet(7) as ubyte

bullet(0) = tileSet(1, 0)
bullet(1) = tileSet(1, 1)
bullet(2) = tileSet(1, 2)
bullet(3) = tileSet(1, 3)
bullet(4) = tileSet(1, 4)
bullet(5) = tileSet(1, 5)
bullet(6) = tileSet(1, 6)
bullet(7) = tileSet(1, 7)

spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bullet)

bullet(0) = hMirror(tileSet(1, 0))
bullet(1) = hMirror(tileSet(1, 1))
bullet(2) = hMirror(tileSet(1, 2))
bullet(3) = hMirror(tileSet(1, 3))
bullet(4) = hMirror(tileSet(1, 4))
bullet(5) = hMirror(tileSet(1, 5))
bullet(6) = hMirror(tileSet(1, 6))
bullet(7) = hMirror(tileSet(1, 7))

spritesSet(BULLET_SPRITE_LEFT_ID) = Create1x1Sprite(@bullet)

' sub createBullet(directionRight as ubyte)
'     if directionRight
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletRight)
'     else
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletLeft)
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
            dim protaX as byte = getSpriteCol(PROTA_SPRITE)
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

    for enemyId=0 TO MAX_ENEMIES_PER_SCREEN - 1
        if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then continue for ' not enemy
        if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = 0 then continue for

        dim bulletX0, bulletX1, bulletY0, bulletY1, enemyX0, enemyX1, enemyY0, enemyY1 as ubyte

        bulletX0 = bulletPositionX
        bulletX1 = bulletPositionX + 1
        bulletY0 = bulletPositionY
        bulletY1 = bulletPositionY + 1
        enemyX0 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
        enemyX1 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) + 2
        enemyY0 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
        enemyY1 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + 2

        if bulletX1 < enemyX0 then continue for
        if bulletX0 > enemyX1 then continue for
        if bulletY1 < enemyY0 then continue for
        if bulletY0 > enemyY1 then continue for

        damageEnemy(enemyId)
        resetBullet()
    next enemyId
end sub

sub resetBullet()
    bulletPositionX = 0
    bulletPositionY = 0
    bulletDirectionIsRight = 0
end sub

sub damageEnemy(enemyToKill as Ubyte)
    decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) - 1

    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 0
        saveSprite(enemyToKill, 0, 0, 0, 0)
        drawBurst(decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN))
        if decompressedEnemiesScreen(enemyToKill, ENEMY_HORIZONTAL_DIRECTION)
            paint(decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL) / 2 - 1, decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN) / 2, 4, 2, 7)
        else
            paint(decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL) / 2 + 1, decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN) / 2, 4, 2, 7)
        end if
        
        killEnemySound()
    else
        damageSound()
    end if
end sub
