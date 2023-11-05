const BULLET_SPRITE_ID as ubyte = 14
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

spritesSet(BULLET_SPRITE_ID) = Create1x1Sprite(@bullet)

function bulletInMovement() as ubyte
    return bulletPositionX <> 0
end function

sub moveBullet()
    if bulletPositionX <> 0
        if bulletDirectionIsRight = 1
            if bulletPositionX > 60
                bulletPositionX = 0
            else
                bulletPositionX = bulletPositionX + BULLET_SPEED
            end if
        else
            if bulletPositionX < 1
                bulletPositionX = 0
            else
                bulletPositionX = bulletPositionX - BULLET_SPEED
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
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) <> 1 then continue for

        dim enemyY = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN)

        if enemyY <> bulletPositionY - 1 and enemyY <> bulletPositionY and enemyY <> bulletPositionY + 1 and enemyY <> bulletPositionY + 2 then continue for

        dim enemyX = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL)

        if enemyX = bulletPositionX or enemyX - 1 = bulletPositionX or enemyX + 1 = bulletPositionX
            killEnemy(enemyId)
            resetBullet()
        end if
    next enemyId
end sub

sub resetBullet()
    bulletPositionX = 0
    bulletPositionY = 0
    bulletDirectionIsRight = 0
end sub

sub killEnemy(enemyToKill as Ubyte)
    enemies(currentScreen, enemyToKill, ENEMY_ALIVE) = 0
    saveSprite(enemyToKill, 0, 0, 0, 0)
    drawBurst(enemies(currentScreen, enemyToKill, ENEMY_CURRENT_COL), enemies(currentScreen, enemyToKill, ENEMY_CURRENT_LIN))
    killEnemySound()
end sub
