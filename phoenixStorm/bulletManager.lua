BulletManager = {}
BULLET_OWNER_TYPES = {player = "player", enemy = "enemy"}
-- should have something for bullet types 

function BulletManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.bullets = {}
	o.bulletRadius = 8
	o.bulletdiameter = 16

	o.purpleBulletSpriteSheet = love.graphics.newImage("assets/sprites/16x16purpleBulletSpriteSheet.png")
	o.purpleBulletSpriteSheet:setFilter("nearest", "nearest")
	o.purpleBulletSpriteSheetWidth = o.purpleBulletSpriteSheet:getWidth()
	o.purpleBulletSpriteSheetHeight = o.purpleBulletSpriteSheet:getHeight()
	o.purpleBulletSpriteSheetQuads = {}
	for i=1,4 do
		o.purpleBulletSpriteSheetQuads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, o.purpleBulletSpriteSheetWidth, o.purpleBulletSpriteSheetHeight)
	end

	o.greenBulletSpriteSheet = love.graphics.newImage("assets/sprites/16x16greenBulletSpriteSheet.png")
	o.greenBulletSpriteSheet:setFilter("nearest", "nearest")
	o.greenBulletSpriteSheetWidth = o.greenBulletSpriteSheet:getWidth()
	o.greenBulletSpriteSheetHeight = o.greenBulletSpriteSheet:getHeight()
	o.greenBulletSpriteSheetQuads = {}
	for i=1,4 do
		o.greenBulletSpriteSheetQuads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, o.greenBulletSpriteSheetWidth, o.greenBulletSpriteSheetHeight)
	end

	return o
end

function BulletManager:newBullet(_x, _y, _vx, _vy, _owner)
	assert(_owner == BULLET_OWNER_TYPES.player or _owner == BULLET_OWNER_TYPES.enemy, "must pass correct bullet owner type")
	local nb = {
		x = _x,
		y = _y,
		vx = _vx,
		vy = _vy,
		owner = _owner,
		animationIndex = 1,
		animationTimer = Timer:new(0.1,TimerModes.repeating)
	}
	table.insert(self.bullets, nb)
end 

function BulletManager:updateBullets(dt)
	local bulletCount = #self.bullets
	print(bulletCount)
	for i=bulletCount,1,-1 do	
		-- update position
		self.bullets[i].x = self.bullets[i].x + (self.bullets[i].vx * dt) 
		self.bullets[i].y = self.bullets[i].y + (self.bullets[i].vy * dt) 
		-- update animation 
		if self.bullets[i].animationTimer:isComplete(dt) then 
			self.bullets[i].animationIndex = self.bullets[i].animationIndex + 1
			if self.bullets[i].animationIndex > 4 then 
				self.bullets[i].animationIndex = 1
			end 
		end 
		-- check if it went off screen, despawn if it did
		if self.bullets[i].x > screenWidth or self.bullets[i].x + self.bulletdiameter < 0 or 
		   self.bullets[i].y > screenHeight or self.bullets[i].y + self.bulletdiameter < 0	then 
		   table.remove(self.bullets, i)
		end  

		-- check if an enemy bullet hit the player
		if self.bullets[i] ~= nil and self.bullets[i].owner == BULLET_OWNER_TYPES.enemy then 
			if bulletCurrentPlayerCollision(self.bullets[i].x + self.bulletRadius, self.bullets[i].y + self.bulletRadius, self.bulletRadius) then 
				print("enemy hit player")
				playerHit()
				table.remove(self.bullets, i)
			end 
		end 

		-- check if a player bullet hit an enemy
		if self.bullets[i] ~= nil and self.bullets[i].owner == BULLET_OWNER_TYPES.player then 
			local enemyCount = enemyManager:getEnemyCount()
			for j=enemyCount,1,-1 do
				local temp = enemyManager:getElementAt(j)
				if rectCircleCollision(temp.x,temp.y,temp.shipWidth,temp.shipHeight, self.bullets[i].x + self.bulletRadius, self.bullets[i].y + self.bulletRadius, self.bulletRadius) then 
					print("player hit enemy")
					enemyManager:decreaseHealth(j)
					table.remove(self.bullets, i)
				end 
			end
		end 

	end
end 

function BulletManager:drawBullets()
	for i=1,#self.bullets do
		if self.bullets[i].owner == BULLET_OWNER_TYPES.player then 
			love.graphics.draw(self.greenBulletSpriteSheet, self.greenBulletSpriteSheetQuads[self.bullets[i].animationIndex], math.round(self.bullets[i].x), math.round(self.bullets[i].y))
		end 
		if self.bullets[i].owner == BULLET_OWNER_TYPES.enemy then 
			love.graphics.draw(self.purpleBulletSpriteSheet, self.purpleBulletSpriteSheetQuads[self.bullets[i].animationIndex], math.round(self.bullets[i].x), math.round(self.bullets[i].y))
		end 
		--love.graphics.circle("line", self.bullets[i].x + self.bulletRadius, self.bullets[i].y + self.bulletRadius, self.bulletRadius)
	end
end 