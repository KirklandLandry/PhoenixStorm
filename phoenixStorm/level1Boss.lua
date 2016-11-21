Level1Boss = {}
BOSS_PHASE = {one = "phase1", two = "phase2", three = "phase3"}

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

    o.movingToStartPoint = false
    o.currentPhase = BOSS_PHASE.one
    o.phaseDelayTimer = Timer:new(10, TimerModes.single)
    o.phaseDelayActive = false

    -- phase 1 variables 
    o.phase1Health = 1200
    o.phase1CircleTimer = Timer:new(0.3, TimerModes.repeating)
    o.phase1DegreeIncrement = 0
    -- phase 2 variables 
    o.phase2Health = 1900
    o.phase2BurstTimer = Timer:new(0.1, TimerModes.repeating)
    o.phase2OffsetTimer = Timer:new(0.2, TimerModes.repeating)
    o.phase2Offset = 0
    o.phase2BurstTimer:maxOut()
    o.phase2Horizontal = false
    o.phase2HorizontalTimer = Timer:new(0.85, TimerModes.repeating)
    o.phase2SwitchTimer = Timer:new(4, TimerModes.repeating)
    o.phase2BulletSpeed = 230
    -- phase 3 variables (unused)
    o.phase3Health = 2000

    o.defeated = false

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
		if self.phaseDelayActive then 
			if self.phaseDelayTimer:isComplete(dt) then 
				self.phaseDelayActive = false
			end 
		else 
			if self.currentPhase == BOSS_PHASE.one then 
				self:updatePhase1(dt)
			elseif self.currentPhase == BOSS_PHASE.two then 
				self:updatePhase2(dt) 
			end
		end 	 
	end 
end 

-- an easy circle pattern. can get away with not moving pretty easily if you find a sweet spot.
function Level1Boss:updatePhase1(dt)
	if self.phase1CircleTimer:isComplete(dt) then 
		self.phase1DegreeIncrement = self.phase1DegreeIncrement + 5
		self:circleBurstOutwards(11.25,self.phase1DegreeIncrement, 50)
		self:circleBurstOutwards(-15,0, 50)
	end 
end 

function Level1Boss:updatePhase2(dt)
	if self.phase2SwitchTimer:isComplete(dt) then 
		self.phase2Horizontal = not self.phase2Horizontal
		self.phase2HorizontalTimer:reset()
		self.phase2BurstTimer:reset(dt)
	end 

	if self.phase2Horizontal then 
		if self.phase2HorizontalTimer:isComplete(dt) then 
			self:horizontalWithGap(self.phase2BulletSpeed)
		end  
	else 
		if self.phase2BurstTimer:isComplete(dt) then 
			if self.phase2OffsetTimer:isComplete(dt) then 
				if self.phase2Offset == 0 then 
					self.phase2Offset = 32
				else 
					self.phase2Offset = 0
				end 
			end 	
			self:straightDownLine(64, self.phase2Offset, self.phase2BulletSpeed)
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

function Level1Boss:getHitbox()
	return {x = self.x + 16, y = self.y, width = self.width - 32, height = self.height - 96}
end 

function Level1Boss:takeDamage()
	-- don't decrease heath if it's moving between phases
	if self.phaseDelayActive then return end 

	if self.currentPhase == BOSS_PHASE.one then 
		self.phase1Health = self.phase1Health - 1
		if self.phase1Health <= 0 then 
			self.currentPhase = BOSS_PHASE.two
			self.phaseDelayActive = true 
			self.phaseDelayTimer:reset()
		end 
	elseif self.currentPhase == BOSS_PHASE.two then
		self.phase2Health = self.phase2Health - 1
		if self.phase2Health <= 0 then 
			self.currentPhase = BOSS_PHASE.three
			--self.phaseDelayActive = true 
			--self.phaseDelayTimer:reset(3)
			self.defeated = true 
		end 
	--elseif self.currentPhase == BOSS_PHASE.three then 
	end 
end 

function Level1Boss:circleBurstOutwards(degree, offset, speed)
	local count = math.abs(360/degree)
	local centre = self:getCentre()
	for i=1,count do
		local vx = math.cos(((i-1)*degree + offset) * math.pi/180) * speed
		local vy = math.sin(((i-1)*degree + offset) * math.pi/180) * speed
		bulletManager:newBullet(centre.x, centre.y, vx, vy, BULLET_OWNER_TYPES.enemy)
	end
end 

function Level1Boss:straightDownLine(division, offset, speed)
	local count = screenWidth / division
	for i=0,count + 2 do
		bulletManager:newBullet((i-1)*division + offset, 1, 0, speed, BULLET_OWNER_TYPES.enemy)
	end
end 

function Level1Boss:horizontalWithGap(speed)
	local gapStart = math.random(bulletManager.bulletdiameter, screenWidth - bulletManager.bulletdiameter * 7)
	local gapEnd = gapStart + (bulletManager.bulletdiameter * 5)
	for i=1,screenWidth / bulletManager.bulletdiameter do
		local x = (i-1) * bulletManager.bulletdiameter
		if x < gapStart or x > gapEnd then 
			bulletManager:newBullet(x, 1, 0, speed, BULLET_OWNER_TYPES.enemy)
		end 
		
	end
end 

function Level1Boss:isDefeated()
	return self.defeated
end 