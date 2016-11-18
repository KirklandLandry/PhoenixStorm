Player = {}
function Player:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	

	o.shipHitRadius = 2
	o.lives = 3 
	o.playerSpawning = false
	o.respawnTimer = Timer:new(1, TimerModes.single)
	o.invincibilityTimer = Timer:new(2, TimerModes.single)
	o.invincibilityTimer:maxOut()
	o.bombs = 3
	o.shipSprite = love.graphics.newImage("assets/sprites/96x96playerShip.png")
	o.shipSprite:setFilter("nearest", "nearest")
	o.shipWidth = o.shipSprite:getWidth()
	o.shipHeight = o.shipSprite:getHeight()

	o.x = screenWidth/2 - o.shipWidth/2
	o.y = screenHeight - o.shipHeight
	o.moveSpeed = 340
	o.originalMoveSpeed = 340
	o.firingMoveSpeed = o.originalMoveSpeed * 0.35
	
	o.currentlyFiring = false
	o.bulletSpeed = 650
	o.fireRate = 0.07
	o.fireTimer = Timer:new(o.fireRate, TimerModes.single)
	o.canFire = true 

	o.gunSpriteSheet = love.graphics.newImage("assets/sprites/64x32playerGunsSpritesheet.png")
	o.gunSpriteSheet:setFilter("nearest", "nearest")

	o.gunSpriteSheetWidth = o.gunSpriteSheet:getWidth()
	o.gunSpriteSheetHeight = o.gunSpriteSheet:getHeight()

	o.gunSpriteSheetQuads = {}
	o.gunSpriteSheetQuads["lowerLeft"] = love.graphics.newQuad(0, 0, 16, 32, o.gunSpriteSheetWidth, o.gunSpriteSheetHeight)
	o.gunSpriteSheetQuads["lowerRight"] = love.graphics.newQuad(16, 0, 16, 32, o.gunSpriteSheetWidth, o.gunSpriteSheetHeight)
	o.gunSpriteSheetQuads["upperLeft"] = love.graphics.newQuad(32, 0, 16, 32, o.gunSpriteSheetWidth, o.gunSpriteSheetHeight)
	o.gunSpriteSheetQuads["upperRight"] = love.graphics.newQuad(48, 0, 16, 32, o.gunSpriteSheetWidth, o.gunSpriteSheetHeight)

	o.guns = {}
	o.guns["lowerLeft"] = newGun("lowerLeft", -o.shipWidth/2- 16 - 16, 0)
	o.guns["lowerRight"] = newGun("lowerRight", o.shipWidth/2 + 16, 0)
	o.guns["upperLeft"] = newGun("upperLeft", -o.shipWidth/2 + 4, -48)
	o.guns["upperRight"] = newGun("upperRight", o.shipWidth/2 - 16 - 4, -48)

	return o
end

function newGun(name, _xOffset, _yOffset)
	return {
		quadIndex = name,
		xOffset = _xOffset,
		yOffset = _yOffset
	}
end 

function Player:update(dt)

	self.invincibilityTimer:isComplete(dt)

	if self.playerSpawning then 
		self:updateRespawn(dt)
	else 
		self:updatePosition(dt)
		self:boundaryCollisions()
		self:updateFiring(dt)
	end 
end 

function Player:respawn()
	self.playerSpawning = true 
	self.x = screenWidth/2 - self.shipWidth/2
	self.y = screenHeight + self.shipHeight
	self.respawnTimer:reset()
end 

function Player:updateRespawn(dt)
	-- if it's time to respawn
	if self.respawnTimer:isComplete(dt) then 
		-- lerp towards starting position 
		if not math.approxEqual(self.y,screenHeight-self.shipHeight - 10,8) then 
			self.y = self.y + ((((screenHeight-self.shipHeight - 10) - self.y) * 0.07) * 80 * dt)
		else 
			self.playerSpawning = false
			self.invincibilityTimer:reset()
		end 
	end 
end 

function Player:hitByEnemyBullet()
	if not self.playerSpawning and self.invincibilityTimer:percentComplete() >= 1 then 
		effectManager:addEffect(EFFECT_TYPE.explosion128, self.x, self.y)
		self.lives = self.lives - 1
		self:respawn()
	end 
end

function Player:draw()
	if self.invincibilityTimer:percentComplete() < 1 or self.playerSpawning then 
		love.graphics.setColor(150,150,150,255)
	end 
	-- the centre of the ship for reference
	local centre = self:getCentre()
	-- draw the player sprite
	love.graphics.draw(self.shipSprite, self.x, self.y)
	-- draw the guns 
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["lowerLeft"]	, centre.x + self.guns["lowerLeft"].xOffset 	, centre.y + self.guns["lowerLeft"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["lowerRight"]	, centre.x + self.guns["lowerRight"].xOffset 	, centre.y + self.guns["lowerRight"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["upperLeft"]	, centre.x + self.guns["upperLeft"].xOffset 	, centre.y + self.guns["upperLeft"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["upperRight"]	, centre.x + self.guns["upperRight"].xOffset 	, centre.y + self.guns["upperRight"].yOffset)
	-- draw the player hit circle
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill", centre.x, centre.y, self.shipHitRadius+1)
	resetColor()
end 

function Player:updatePosition(dt)
	-- move left / right
	if getKeyDown("a") then 
		self.x = self.x - (self.moveSpeed * dt)
	elseif getKeyDown("d") then 
		self.x = self.x + (self.moveSpeed * dt)
	end 
	-- move up / down
	if getKeyDown("w") then 
		self.y = self.y - (self.moveSpeed * dt)
	elseif getKeyDown("s") then 
		self.y = self.y + (self.moveSpeed * dt)
	end 
end 

function Player:boundaryCollisions()
	local centre = self:getCentre()
	-- check and resolve collision with left and right wall
	--[[if self.x < 0 then 
		self.x = 0
	elseif self.x + self.shipWidth > screenWidth then 
		self.x = screenWidth - self.shipWidth
	end 	
	-- check and resolve collision with top and bottom wall
	if self.y < 0 then 
		self.y = 0
	elseif self.y + self.shipHeight > screenHeight then 
		self.y = screenHeight - self.shipHeight
	end ]]

	if self.x + self.shipWidth/2 < 0 then 
		self.x = -self.shipWidth/2
	elseif self.x + self.shipWidth/2 > screenWidth then 
		self.x = screenWidth - self.shipWidth/2
	end 	
	-- check and resolve collision with top and bottom wall
	if self.y  + self.shipWidth/2 < 0 then 
		self.y = - self.shipWidth/2
	elseif self.y + self.shipHeight/2 > screenHeight then 
		self.y = screenHeight - self.shipHeight/2
	end

end 

function Player:updateFiring(dt)
	if self.fireTimer:isComplete(dt) then 
		self.canFire = true 
	end 

	if getKeyDown("j") then 
		-- only fire if the fire rate timer has expired 
		if self.canFire then 
			self.canFire = false
			self.fireTimer:reset()
			-- spawn bullets at each of the 4 guns
			self:SpawnBullets()
		end 
		-- move slower when firing
		self.currentlyFiring = true
		self.moveSpeed = self.firingMoveSpeed

	else 
		self.currentlyFiring = false
		self.moveSpeed = self.originalMoveSpeed
	end 
end 

function Player:SpawnBullets()
	local centre = self:getCentre()

	bulletManager:newBullet(
		centre.x + self.guns["lowerLeft"].xOffset, 
		centre.y + self.guns["lowerLeft"].yOffset,
		0,
		-self.bulletSpeed,
		BULLET_OWNER_TYPES.player)

	bulletManager:newBullet(
		centre.x + self.guns["lowerRight"].xOffset, 
		centre.y + self.guns["lowerRight"].yOffset,
		0,
		-self.bulletSpeed,
		BULLET_OWNER_TYPES.player)

	bulletManager:newBullet(
		centre.x + self.guns["upperLeft"].xOffset, 
		centre.y + self.guns["upperLeft"].yOffset,
		0,
		-self.bulletSpeed,
		BULLET_OWNER_TYPES.player)

	bulletManager:newBullet(
		centre.x + self.guns["upperRight"].xOffset, 
		centre.y + self.guns["upperRight"].yOffset,
		0,
		-self.bulletSpeed,
		BULLET_OWNER_TYPES.player)	

end 

-- get the centre relative to the centre of the ship sprite based on current position
function Player:getCentre()
	return {x = self.x + (self.shipWidth/2), y = self.y + (self.shipHeight/2)}
end 