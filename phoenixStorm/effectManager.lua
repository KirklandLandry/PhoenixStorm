EFFECT_TYPE = {explosion = "explosion", hit = "hit"}

EffectManager = {}
function EffectManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	

	o.explosionSpriteSheet = love.graphics.newImage("assets/sprites/256x256explosion.png")
	o.explosionSpriteSheet:setFilter("nearest", "nearest")
	o.explosionSpriteSheetWidth = o.explosionSpriteSheet:getWidth()
	o.explosionSpriteSheetHeight = o.explosionSpriteSheet:getHeight()
	o.explosionSpriteSheetQuads = {}
	local counter = 0
	for y=1,4 do
		for x=1,4 do
			counter = counter + 1
			o.explosionSpriteSheetQuads[counter] = love.graphics.newQuad((x-1)*64, (y-1)*64, 64, 64, o.explosionSpriteSheetWidth, o.explosionSpriteSheetHeight)
		end
	end
	o.explosionTotalFrameCount = counter
	o.effectList = {}	



	o.hitSpriteSheet = love.graphics.newImage("assets/sprites/160x32hitSpriteSheet.png")
	o.hitSpriteSheet:setFilter("nearest", "nearest")
	o.hitSpriteSheetWidth = o.hitSpriteSheet:getWidth()
	o.hitSpriteSheetHeight = o.hitSpriteSheet:getHeight()
	o.hitSpriteSheetQuads = {}
	o.hitTotalFrameCount = 5
	for i=1,o.hitTotalFrameCount do
		o.hitSpriteSheetQuads[i] = love.graphics.newQuad((i-1)*32, 0, 64, 64, o.hitSpriteSheetWidth, o.hitSpriteSheetHeight)
	end
	
	o.effectList = {}	


	return o
end


function EffectManager:addEffect(_effectType, _x, _y)
	assert(_effectType == EFFECT_TYPE.explosion or _effectType == EFFECT_TYPE.hit)
	table.insert(self.effectList, {
		effectType = _effectType,
		x = _x,
		y = _y,
		frameTimer = Timer:new(0.07, TimerModes.repeating),
		frameIndex = 1	
	})
end 

function EffectManager:update(dt)
	local count = #self.effectList
	for i=count,1,-1 do
		if self.effectList[i].frameTimer:isComplete(dt) then
			self.effectList[i].frameIndex = self.effectList[i].frameIndex + 1

			if (self.effectList[i].effectType == EFFECT_TYPE.explosion and self.effectList[i].frameIndex > self.explosionTotalFrameCount) or 
				(self.effectList[i].effectType == EFFECT_TYPE.hit and self.effectList[i].frameIndex > self.hitTotalFrameCount) then 
				table.remove(self.effectList, i)
			end 
		end 
	end
end 

function EffectManager:draw()
	local count = #self.effectList
	for i=count,1,-1 do
		if self.effectList[i].effectType == EFFECT_TYPE.explosion then 
			love.graphics.draw(self.explosionSpriteSheet, self.explosionSpriteSheetQuads[self.effectList[i].frameIndex], self.effectList[i].x, self.effectList[i].y)
		elseif self.effectList[i].effectType == EFFECT_TYPE.hit then 
			love.graphics.draw(self.hitSpriteSheet, self.hitSpriteSheetQuads[self.effectList[i].frameIndex], self.effectList[i].x, self.effectList[i].y)
		end 
	end
end 