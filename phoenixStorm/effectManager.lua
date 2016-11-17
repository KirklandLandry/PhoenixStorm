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

			if (self.effectList[i].effectType == EFFECT_TYPE.explosion and self.effectList[i].frameIndex > self.explosionTotalFrameCount)
			 then 
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
			--love.graphics.draw(self.explosionSpriteSheet, self.explosionSpriteSheetQuads[self.effectList[i].frameIndex], self.effectList[i].x, self.effectList[i].y)
		end 
	end
end 