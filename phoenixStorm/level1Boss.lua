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
	if movingToStartPoint then 

	else 
		if self.currentPhase == BOSS_PHASE.one then 

		end 
	end 
end 

function Level1Boss:draw()

end 

