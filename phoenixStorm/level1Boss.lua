Level1Boss = {}
BOSS_PHASE = {one = "phase1"}

function Level1Boss:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self
 

    o.moveSpeed = 50
 	o.shipImage = love.graphics.newImage("assets/sprites/boss1.png")
	o.shipImage:setFilter("nearest", "nearest")
	o.width = o.shipImage:getWidth()
	o.height = o.shipImage:getHeight()
	o.halfWidth = o.width / 2 
	o.halfHeight = o.height / 2

    o.x = (screenWidth/2) - o.halfWidth
    o.y = -o.height

    o.movingToStartPoint = true
    o.currentPhase = BOSS_PHASE.one

    o.eventQueue = Queue:new()

    return o
end

function Level1Boss:update(dt)
	-- the initial action, move to the starting position
	if self.movingToStartPoint then 
		self.y = self.y + (self.moveSpeed * dt)
		if self.y >= 0 then 
			self.movingToStartPoint = false
		end 
	else 
		if self.currentPhase == BOSS_PHASE.one then 

		end 
	end 
end 

function Level1Boss:draw()
	love.graphics.draw(self.shipImage, self.x, self.y)
end 

-- don't let player move to start pos
function Level1Boss:isMovingToStartPosition()
	return self.movingToStartPoint
end 

function Level1Boss:getCentre()
	return {x = (self.x + self.halfWidth), y = (self.y + self.halfHeight)}
end 
