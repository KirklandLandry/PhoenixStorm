Player = {}
function Player:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = 0
	o.y = 0
	o.moveSpeed = 310
	o.shipHitRadius = 5
	o.shipSprite = love.graphics.newImage("assets/sprites/96x96playerShip.png")
	o.shipSprite:setFilter("nearest", "nearest")
	o.shipWidth = o.shipSprite:getWidth()
	o.shipHeight = o.shipSprite:getHeight()

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
	o.guns["lowerLeft"] = newGun("lowerLeft", -o.shipWidth/2, 0)
	o.guns["lowerRight"] = newGun("lowerRight", o.shipWidth/2, 0)
	o.guns["upperLeft"] = newGun("upperLeft", -o.shipWidth/2 + 16, -48)
	o.guns["upperRight"] = newGun("upperRight", o.shipWidth/2 - 16, -48)


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

	self:updatePosition(dt)
	self:boundaryCollisions()


end 

function Player:draw()
	-- the centre of the ship for reference
	local centre = self:getCentre()
	-- draw the player sprite
	love.graphics.draw(self.shipSprite, self.x, self.y)
	-- draw the player hit circle
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill", centre.x, centre.y, self.shipHitRadius)
	resetColor()
	-- draw the guns 
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["lowerLeft"]	, centre.x - 16 + self.guns["lowerLeft"].xOffset 	, centre.y + self.guns["lowerLeft"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["lowerRight"]	, centre.x 		+ self.guns["lowerRight"].xOffset 	, centre.y + self.guns["lowerRight"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["upperLeft"]	, centre.x - 16 + self.guns["upperLeft"].xOffset 	, centre.y + self.guns["upperLeft"].yOffset)
	love.graphics.draw(self.gunSpriteSheet, self.gunSpriteSheetQuads["upperRight"]	, centre.x 		+ self.guns["upperRight"].xOffset 	, centre.y + self.guns["upperRight"].yOffset)
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
	-- check and resolve collision with left and right wall
	if self.x < 0 then 
		self.x = 0
	elseif self.x + self.shipWidth > screenWidth then 
		self.x = screenWidth - self.shipWidth
	end 	
	-- check and resolve collision with top and bottom wall
	if self.y < 0 then 
		self.y = 0
	elseif self.y + self.shipHeight > screenHeight then 
		self.y = screenHeight - self.shipHeight
	end 
end 


function Player:getCentre()
	return {x = self.x + (self.shipWidth/2), y = self.y + (self.shipHeight/2)}
end 