dim noKeyPressed as UBYTE = 0

function canMoveLeft() as ubyte
	if CheckDoor(protaX - 1, protaY)
		return 0
	end if
	return not CheckCollision(protaX - 1, protaY)
end function

function canMoveRight() as ubyte
	if CheckDoor(protaX + 1, protaY)
		return 0
	end if
	return not CheckCollision(protaX + 1, protaY)
end function

function canMoveUp() as ubyte
	if CheckDoor(protaX, protaY - 1)
		return 0
	end if
	return not CheckCollision(protaX, protaY - 1)
end function

function canMoveDown() as ubyte
	if CheckDoor(protaX, protaY + 1)
		return 0
	end if
	if CheckCollision(protaX, protaY + 1) return 0
	#ifdef SIDE_VIEW
		if checkPlatformByXY(protaX, protaY + 4) return 0
		if CheckStaticPlatform(protaX, protaY + 4) return 0
		if CheckStaticPlatform(protaX + 1, protaY + 4) return 0
		if CheckStaticPlatform(protaX + 2, protaY + 4) return 0
	#endif
	return 1
end function

#ifdef SIDE_VIEW
	function getNextFrameJumpingFalling() as ubyte
		if (getSpriteDirection(PROTA_SPRITE))
			return 3
		else
			return 7
		end if
	end function

	sub checkIsJumping()
		if jumpCurrentKey <> jumpStopValue
			if protaY < 2
				moveScreen = 8 ' stop jumping
			elseif jumpCurrentKey < jumpStepsCount
				if CheckStaticPlatform(protaX, protaY + jumpArray(jumpCurrentKey))
					saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
				else
					if not CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey))
						saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
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
				if protaY bAND 1 <> 0
					' saveSpriteLin(PROTA_SPRITE, protaY - 1)
					protaY = protaY - 1
				end if
				resetProtaSpriteToRunning()
			end if
			return 0
		end if
	end function

	sub gravity()
		if jumpCurrentKey = jumpStopValue and isFalling()
			if protaY >= MAX_LINE
				moveScreen = 2
			else
				saveSprite(PROTA_SPRITE, protaY + 2, protaX, getNextFrameJumpingFalling(), getSpriteDirection(PROTA_SPRITE))
			end if
			landed = 0
		end if
	end sub
#endif

function getNextFrameRunning() as UBYTE
	#ifdef SIDE_VIEW
		if getSpriteDirection(PROTA_SPRITE) = 1 ' right
			if protaFrame = 0
				return 1
			else
				return 0
			end if
		else
			if protaFrame = 4
				return 5
			else
				return 4
			end if
		end if
	#else
		if getSpriteDirection(PROTA_SPRITE) = 1 ' right
			if protaFrame = 0
				return 1
			else
				return 0
			end if
		elseif getSpriteDirection(PROTA_SPRITE) = 0 ' left
			if protaFrame = 2
				return 3
			else
				return 2
			end if
		elseif getSpriteDirection(PROTA_SPRITE) = 8 ' up
			if protaFrame = 4
				return 5
			else
				return 4
			end if
		else ' down
			if protaFrame = 6
				return 7
			else
				return 6
			end if
		end if
	#endif
end function

#ifdef SIDE_VIEW
	sub shoot()
		if not noKeyPressedForShoot return

		noKeyPressedForShoot = 0
		
		if bulletPositionX <> 0 return ' bullet in movement

		currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
		if getSpriteDirection(PROTA_SPRITE)
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
		elseif getSpriteDirection(PROTA_SPRITE) = 0
			currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
			bulletPositionX = protaX
		end if

		bulletPositionY = protaY + 1
		bulletDirection = getSpriteDirection(PROTA_SPRITE)
		BeepFX_Play(2)
	end sub
#endif

#ifdef OVERHEAD_VIEW
	sub shoot()
		if not noKeyPressedForShoot return

		noKeyPressedForShoot = 0

		if bulletPositionX <> 0 return ' bullet in movement

		if getSpriteDirection(PROTA_SPRITE) = 1
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
			bulletPositionY = protaY + 1
		elseif getSpriteDirection(PROTA_SPRITE) = 0
			currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
			bulletPositionX = protaX
			bulletPositionY = protaY + 1
		elseif getSpriteDirection(PROTA_SPRITE) = 8
			currentBulletSpriteId = BULLET_SPRITE_UP_ID
			bulletPositionX = protaX + 1
			bulletPositionY = protaY + 1
		else
			currentBulletSpriteId = BULLET_SPRITE_DOWN_ID
			bulletPositionX = protaX + 1
			bulletPositionY = protaY + 2
		end if

		bulletDirection = getSpriteDirection(PROTA_SPRITE)
		BeepFX_Play(2)
	end sub
#endif

sub leftKey()
	if getSpriteDirection(PROTA_SPRITE) <> 0
		if noKeyPressed = 1
			noKeyPressed = 0
			#ifdef SIDE_VIEW
				protaFrame = 4
			#else
				protaFrame = 2
			#endif
		end if
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 0
	end if

	if onFirstColumn(PROTA_SPRITE)
		moveScreen = 4
	elseif canMoveLeft()
		saveSprite(PROTA_SPRITE, protaY, protaX - 1, protaFrame, 0)
	end if
end sub

sub rightKey()
	if getSpriteDirection(PROTA_SPRITE) <> 1
		if noKeyPressed = 1
			noKeyPressed = 0
			protaFrame = 0
		end if
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 1
	end if

	if onLastColumn(PROTA_SPRITE)
		moveScreen = 6
	elseif canMoveRight()
		saveSprite(PROTA_SPRITE, protaY, protaX + 1, protaFrame, 1)
	end if
end sub

sub upKey()
	#ifdef SIDE_VIEW
		jump()
	#else
		if getSpriteDirection(PROTA_SPRITE) <> 8
			if noKeyPressed = 1
				noKeyPressed = 0
				protaFrame = 4
			end if
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 8
		end if
		if canMoveUp()
			saveSprite(PROTA_SPRITE, protaY - 1, protaX, protaFrame, 8)
			if protaY < 2
				moveScreen = 8
			end if
		end if
	#endif
end sub

sub downKey()
	#ifdef OVERHEAD_VIEW
		if getSpriteDirection(PROTA_SPRITE) <> 2
			if noKeyPressed = 1
				noKeyPressed = 0
				protaFrame = 6
			end if
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 2
		end if
		if canMoveDown()
			if protaY >= MAX_LINE
				moveScreen = 2
			else
				saveSprite(PROTA_SPRITE, protaY + 1, protaX, protaFrame, 2)
			end if
		end if
	#else
		if CheckStaticPlatform(protaX, protaY + 4) or CheckStaticPlatform(protaX + 1, protaY + 4) or CheckStaticPlatform(protaX + 2, protaY + 4)
			protaY = protaY + 2
		end if
	#endif
end sub

sub fireKey()
	#ifdef SHOOTING_ENABLED
		shoot()
	#endif
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
	Dim col as uByte = protaX >> 1
    Dim lin as uByte = protaY >> 1

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
    
    Dim col as uByte = protaX >> 1
    Dim lin as uByte = protaY >> 1

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
	if GetKeyScanCode()=0
		noKeyPressed = 1
	end if
	if MultiKeys(keyArray(FIRE)) = 0
		noKeyPressedForShoot = 1
	end if
	keyboardListen()
	checkObjectContact()

	#ifdef SIDE_VIEW
		checkIsJumping()
		gravity()
	#endif
end sub