dim landed as UBYTE = 1
dim yStepSize as ubyte = 2

function canMoveLeft() as ubyte
	dim x as ubyte = getSpriteCol(PROTA_SPRITE)
	dim y as ubyte = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x - 1, y)
		return 0
	end if
	return not CheckCollision(x - 1, y)
end function

function canMoveRight() as ubyte
	dim x as ubyte = getSpriteCol(PROTA_SPRITE)
	dim y as ubyte = getSpriteLin(PROTA_SPRITE)
	if CheckDoor(x + 1, y)
		return 0
	end if
	return not CheckCollision(x + 1, y)
end function

function canMoveUp() as ubyte
	dim x as ubyte = getSpriteCol(PROTA_SPRITE)
	dim y as ubyte = getSpriteLin(PROTA_SPRITE)
	return not CheckCollision(x, y - 1)
end function

function canMoveDown() as ubyte
	dim x as ubyte = getSpriteCol(PROTA_SPRITE)
	dim y as ubyte = getSpriteLin(PROTA_SPRITE)
	if CheckCollision(x, y + 1) return 0
	if checkPlatformByXY(x, y + 4) return 0
	return 1
end function

function getNextFrameJumpingFalling() as ubyte
	if (getSpriteDirection(PROTA_SPRITE))
		return 3
	else
		return 7
    end if
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getSpriteLin(PROTA_SPRITE) < 2
			if SHOULD_KILL_ENEMIES
				if allEnemiesKilled()
					moveScreen = 8
				else
					stopJumping()
					damageSound()
				end if
			else
				moveScreen = 8
			end if
		elseif jumpCurrentKey > 0 and not canMoveDown()
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount
			if not CheckCollision(getSpriteCol(PROTA_SPRITE), secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)))
				saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), jumpArray(jumpCurrentKey)), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
			end if
			jumpCurrentKey = jumpCurrentKey + 1
		else
			stopJumping()
        end if
	end if
end sub

function isFalling() as UBYTE
	if canMoveDown()
		return 1
	else
		if landed = 0
			landed = 1
			if not isEven(getSpriteLin(PROTA_SPRITE))
				saveSpriteLin(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) - 1)
			end if
			resetProtaSpriteToRunning()
		end if
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		if getSpriteLin(PROTA_SPRITE) >= MAX_LINE
			if SHOULD_KILL_ENEMIES
				if allEnemiesKilled()
					moveScreen = 2
				else
					startJumping()
					damageSound()
				end if
			else
				moveScreen = 2
			end if
		else
			saveSprite(PROTA_SPRITE, secureYIncrement(getSpriteLin(PROTA_SPRITE), yStepSize), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
		end if
		landed = 0
	end if
end sub

function getNextFrameRunning() as UBYTE
	if getSpriteDirection(PROTA_SPRITE) = 1
		if getSpriteTile(PROTA_SPRITE) = 0
			return 1
        elseif getSpriteTile(PROTA_SPRITE) = 1
			return 2
		else
			return 0
		end if
	else
        if getSpriteTile(PROTA_SPRITE) = 4
            return 5
        elseif getSpriteTile(PROTA_SPRITE) = 5
            return 6
		else
			return 4
        end if
	end if
end function

sub jump()
	if isJumping() = 0 and landed
		landed = 0
		startJumping()
	end if
end sub

sub shoot()
	if not bulletInMovement()
		if getSpriteDirection(PROTA_SPRITE)
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = getSpriteCol(PROTA_SPRITE) + 2
		else
			currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
			bulletPositionX = getSpriteCol(PROTA_SPRITE)
		end if

		bulletPositionY = getSpriteLin(PROTA_SPRITE) + 1
		bulletDirectionIsRight = getSpriteDirection(PROTA_SPRITE)
		fireSound()
	end if
end sub

sub leftKey()
	saveSpriteDirection(PROTA_SPRITE, 0)
	if onFirstColumn(PROTA_SPRITE)
		if SHOULD_KILL_ENEMIES
			if allEnemiesKilled()
				moveScreen = 4
			else
				damageSound()
			end if
		else
			moveScreen = 4
		end if
	elseif canMoveLeft()
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), secureXIncrement(getSpriteCol(PROTA_SPRITE), -1), protaFrame, 0)
	end if
end sub

sub rightKey()
	saveSpriteDirection(PROTA_SPRITE, 1)
	if onLastColumn(PROTA_SPRITE)
		if SHOULD_KILL_ENEMIES
			if allEnemiesKilled()
				moveScreen = 6
			else
				damageSound()
			end if
		else
			moveScreen = 6
		end if
	elseif canMoveRight()
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), secureXIncrement(getSpriteCol(PROTA_SPRITE), 1), protaFrame, 1)
	end if
end sub

sub upKey()
	' if canMoveUp()
	' 	saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) - 1, getSpriteCol(PROTA_SPRITE), protaFrame, 1)
	' 	if getSpriteLin(PROTA_SPRITE) < 2
	' 		moveScreen = 8
	' 	end if
	' end if
	jump()
end sub

sub downKey()
	if canMoveDown()
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + 1, getSpriteCol(PROTA_SPRITE), protaFrame, 1)
	end if
end sub

sub fireKey()
	if SHOOTING
		shoot()
	else
		jump()
	end if
end sub

sub keyboardListen()
	if kempston
		if IN(31) bAND %00010 then leftKey()
		if IN(31) bAND %00001 then rightKey()
		if IN(31) bAND %01000 then upKey()
		if IN(31) bAND %00100 then downKey()
		if IN(31) bAND %10000 then fireKey() 
	else
		if MultiKeys(keyArray(LEFT))<>0 then leftKey()
		if MultiKeys(keyArray(RIGHT))<>0 then rightKey()
		if MultiKeys(keyArray(UP))<>0 then upKey()
		if MultiKeys(keyArray(DOWN))<>0 then downKey()
		if MultiKeys(keyArray(FIRE))<>0 then fireKey()
	end if
end sub

function checkTileObject(tile as ubyte) as ubyte
	if tile = itemTile and screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
		incrementItems()
		removeScreenObject(SCREEN_OBJECT_ITEM_INDEX)
		itemSound()
		return 1
	elseif tile = keyTile and screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
		incrementKeys()
		removeScreenObject(SCREEN_OBJECT_KEY_INDEX)
		keySound()
		return 1
	elseif tile = lifeTile and screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
		incrementLife()
		removeScreenObject(SCREEN_OBJECT_LIFE_INDEX)
		lifeSound()
		return 1
	end if
	return 0
end function

sub checkObjectContact()
	Dim col as uByte = getSpriteCol(PROTA_SPRITE) >> 1
    Dim lin as uByte = getSpriteLin(PROTA_SPRITE) >> 1

	dim tile00 as UBYTE = GetTile(col, lin)
	dim tile01 as UBYTE = GetTile(col + 1, lin)
	dim tile10 as UBYTE = GetTile(col, lin + 1)
	dim tile11 as UBYTE = GetTile(col + 1, lin + 1)

	if checkTileObject(tile00)
		FillWithTileChecked(0, 1, 1, 7, col, lin)
		return
	elseif checkTileObject(tile01)
		FillWithTileChecked(0, 1, 1, 7, col + 1, lin)
		return
	elseif checkTileObject(tile10)
		FillWithTileChecked(0, 1, 1, 7, col, lin + 1)
		return
	elseif checkTileObject(tile11)
		FillWithTileChecked(0, 1, 1, 7, col + 1, lin + 1)
		return
	end if
end sub

sub protaMovement()
	keyboardListen()
	checkObjectContact()
	checkIsJumping()
	gravity()
end sub