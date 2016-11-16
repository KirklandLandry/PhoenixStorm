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

	local gunSpriteSheetWidth = o.gunSpriteSheet:getWidth()
	local gunSpriteSheetHeight = o.gunSpriteSheet:getHeight()

	o.gunSpriteSheetQuads = {

	}
	o.gunSpriteSheetQuads["lowerLeft"] = love.graphics.newQuad(0, 0, 0, 32, gunSpriteSheetWidth, gunSpriteSheetHeight)

	return o
end

function Player:update(dt)

	self:updatePosition(dt)
	self:boundaryCollisions()


end 

function Player:draw()
	-- draw the player sprite
	love.graphics.draw(self.shipSprite, self.x, self.y)
	-- draw the player hit circle
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill", self:getCentre().x, self:getCentre().y, self.shipHitRadius)
	resetColor()
	-- draw the guns 

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