BulletManager = {}
BULLET_OWNER_TYPES = {player = "player", enemy = "enemy"}

function BulletManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.bullets = {}

	o.purpleBulletSpriteSheet = love.graphics.newImage("assets/sprites/16x16purpleBulletSpriteSheet.png")
	o.purpleBulletSpriteSheet:setFilter("nearest", "nearest")
	o.purpleBulletSpriteSheetWidth = o.purpleBulletSpriteSheet:getWidth()
	o.purpleBulletSpriteSheetHeight = o.purpleBulletSpriteSheet:getHeight()
	o.purpleBulletSpriteSheetQuads = {}
	for i=1,4 do
		o.purpleBulletSpriteSheetQuads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, o.purpleBulletSpriteSheetWidth, o.purpleBulletSpriteSheetHeight)
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
		owner = _owner
	}
	table.insert(self.bullets, nb)
end 



function BulletManager:updateBullets(dt)
	for i=1,#self.bullets do
		-- update position
		self.bullets[i].x = self.bullets[i].x + (self.bullets[i].vx * dt) 
		self.bullets[i].y = self.bullets[i].y + (self.bullets[i].vy * dt) 
		-- check if it went off screen
	end
end 

function BulletManager:drawBullets()
	for i=1,#self.bullets do
		love.graphics.draw(self.purpleBulletSpriteSheet, self.purpleBulletSpriteSheetQuads[1], math.round(self.bullets[i].x), math.round(self.bullets[i].y))
	end
end 