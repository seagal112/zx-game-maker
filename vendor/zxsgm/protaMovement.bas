dim landed as UBYTE = 1

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
	if CheckStaticPlatform(x, y + 4) return 0
	if CheckStaticPlatform(x + 1, y + 4) return 0
	if CheckStaticPlatform(x + 2, y + 4) return 0
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
			moveScreen = 8 ' stop jumping
		elseif jumpCurrentKey < jumpStepsCount
			if CheckStaticPlatform(getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey))
				saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
			else
				if not CheckCollision(getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey))
					saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + jumpArray(jumpCurrentKey), getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
				end if
			end if
			jumpCurrentKey = jumpCurrentKey + 1
		else
			jumpCurrentKey = jumpStopValue ' stop jumping
        end if
	end if
end sub

function isFalling() as UBYTE
	if canMoveDown()
		return 1
	else
		if landed = 0
			landed = 1
			if getSpriteLin(PROTA_SPRITE) bAND 1 <> 0
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
			moveScreen = 2
		else
			saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE) + 2, getSpriteCol(PROTA_SPRITE), getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
		end if
		landed = 0
	end if
end sub

function getNextFrameRunning() as UBYTE
	if getSpriteDirection(PROTA_SPRITE) = 1
		if getSpriteTile(PROTA_SPRITE) = 0
			return 1
		else
			return 0
		end if
	else
        if getSpriteTile(PROTA_SPRITE) = 4
            return 5
		else
			return 4
        end if
	end if
end function

sub jump()
	if jumpCurrentKey = jumpStopValue and landed
		landed = 0
		jumpCurrentKey = 0
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
		BeepFX_Play(2)
	end if
end sub

sub leftKey()
	spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 0
	protaFrame = getNextFrameRunning()
	if onFirstColumn(PROTA_SPRITE)
		moveScreen = 4
	elseif canMoveLeft()
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE) - 1, protaFrame, 0)
	end if
end sub

sub rightKey()
	spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 1
	protaFrame = getNextFrameRunning()
	if onLastColumn(PROTA_SPRITE)
		moveScreen = 6
	elseif canMoveRight()
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), getSpriteCol(PROTA_SPRITE) + 1, protaFrame, 1)
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
		dim n as ubyte = IN(31)
		if n bAND %10 then leftKey()
		if n bAND %1 then rightKey()
		if n bAND %1000 then upKey()
		if n bAND %100 then downKey()
		if n bAND %10000 then fireKey() 
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
		currentItems = currentItems + 1
		#ifdef HISCORE_ENABLED
			score = score + 100
		#endif
		printLife()
		if currentItems >= GOAL_ITEMS
			go to ending
		end if
		screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 0
		BeepFX_Play(5)
		return 1
	elseif tile = keyTile and screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
		currentKeys = currentKeys + 1
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
		BeepFX_Play(3)
		return 1
	elseif tile = lifeTile and screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
		currentLife = currentLife + LIFE_AMOUNT
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
		BeepFX_Play(6)
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
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin)
		return
	elseif checkTileObject(tile01)
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin)
		return
	elseif checkTileObject(tile10)
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin + 1)
		return
	elseif checkTileObject(tile11)
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin + 1)
		return
	end if
end sub

sub checkDamageByTile()
    if invincible then return
    
    Dim col as uByte = getSpriteCol(PROTA_SPRITE) >> 1
    Dim lin as uByte = getSpriteLin(PROTA_SPRITE) >> 1

	if isADamageTile(GetTile(col, lin))
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col + 1, lin))
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col, lin + 1))
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col + 1, lin + 1))
		protaTouch()
		return
	end if
end sub

sub protaMovement()
	keyboardListen()
	checkObjectContact()
	checkIsJumping()
	gravity()
end sub