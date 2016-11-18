Level1Boss = {}
BOSS_PHASE = {one = "phase1"}

function Level1Boss:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self
 

    o.movingToStartPoint = true
    o.currentPhase = BOSS_PHASE.one

    o.eventQueue = Queue:new()

    return o
end

function Level1Boss:update(dt)
	-- the initial action, lerp to the starting position
	if movingToStartPoint then 

	else 
		if self.currentPhase == BOSS_PHASE.one then 

		end 
	end 
end 

function Level1Boss:draw()

end 

-- don't let player move to start pos
function Level1Boss:isMovingToStartPosition()
	return self.isMovingToStartPosition
end 