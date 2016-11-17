-- enemy event queue
ENEMY_MOVEMENT_EVENTS = {move = "move", wait = "wait"}
ENEMY_SHOOT_OPTIONS	 = {shootWhileMoving = "shootWhileMoving", shootWhileWaiting = "shootWhileWaiting"}

-- can you index functions? something to look up later. would be much better
SHOT_PATTERNS = {scattershotTowardsPlayer = "scattershotTowardsPlayer", circleBurstOutwards = "circleBurstOutwards", singleShotTowardsPlayer = "singleShotTowardsPlayer"}

-- enemy will have an event queue
-- it'll be able to do things like
-- move (along curve with a speed) to pt -> wait (for a period of time) -> move (along curve with a speed) -> despawn (queue empty)
function newEnemyEvent(_eventType, args)
		-- event type must be of ENEMY_EVENTS type
	-- arg must be an even numbered list of points comprising a bezier curve
	assert(_eventType == ENEMY_MOVEMENT_EVENTS.wait or _eventType == ENEMY_MOVEMENT_EVENTS.move, "make sure to send a valid event type")

	-- check event type and return a suitable table
	if _eventType == ENEMY_MOVEMENT_EVENTS.wait then 
		return {
			eventType = ENEMY_MOVEMENT_EVENTS.wait,
			timer = Timer:new(args.time, TimerModes.single)
		}
	elseif _eventType == ENEMY_MOVEMENT_EVENTS.move then 
		return {
			eventType = ENEMY_MOVEMENT_EVENTS.move,
			percentComplete = 0,
			curve = love.math.newBezierCurve(args.curvePoints)
		}
	end 

	-- if this happens, not good. assert should catch, so this shouldn't matter
	return nil
end 

-- a defined wait event args format
function newWaitEventArgs(_time)
	return {
		time = _time
	}
end 

-- a defined move event args format
function newMoveEventArgs(_curvePoints)
	return {
		curvePoints = _curvePoints
	}
end 

Enemy = {}
function Enemy:new(_moveSpeed, _fireRate, _fireOption, _shotPattern, _sprite, _health, eventList)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = -100
	o.y = -100
	o.moveSpeed = _moveSpeed
	o.health = _health

	o.spriteIndex = _sprite
	o.shipWidth = 32--o.shipSprite:getWidth()
	o.shipHeight = 32--o.shipSprite:getHeight()

	o.fireOption = _fireOption
	o.shotPattern = _shotPattern
	o.bulletSpeed = 100
	o.fireRate = _fireRate
	o.fireTimer = Timer:new(o.fireRate, TimerModes.repeating)
	-- max out the timer right off the bat so it fire immediately
	o.fireTimer:maxOut()
	o.renderPath = GLOBAL_DEBUG

	o.eventQueue = Queue:new()
	for i=1,#eventList do
		o.eventQueue:enqueue(eventList[i])
	end

	return o
end 

function Enemy:update(dt)
	if self.eventQueue:length() > 0 then 
		-- if the currenet event is movement 
		if self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.move then 
			-- if enemy is set to shoot while moving then  
			if self.fireOption == ENEMY_SHOOT_OPTIONS.shootWhileMoving then 
				self:updateShooting(dt)
			end 
			-- update percent completion of bezier curve
			self.eventQueue:peek().percentComplete = self.eventQueue:peek().percentComplete + (self.moveSpeed * dt)
			-- if done -> next event, else udpate position
			if self.eventQueue:peek().percentComplete > 1 then 
				self.eventQueue:dequeue()
			else 
				local x,y = self.eventQueue:peek().curve:evaluate(self.eventQueue:peek().percentComplete)
				self.x = x
				self.y = y
			end 
		-- if the current event is waiting 
		elseif self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.wait then 
			-- just sit around until the wait event is over
			if self.eventQueue:peek().timer:isComplete(dt) then 
				self.eventQueue:dequeue()
			else 
				-- if the enemy is set to shoot while waiting 
				if self.fireOption == ENEMY_SHOOT_OPTIONS.shootWhileWaiting then 
					self:updateShooting(dt)
				end 
			end 
		end 
	end 
end 

function Enemy:draw(sprite)
	-- draw the ship sprite
	love.graphics.draw(sprite, self.x, self.y)
	-- draw the current movement path, if there is one and if it's in debug mode
	if self.eventQueue:length() > 0 and self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.move and self.renderPath then 
		love.graphics.line(self.eventQueue:peek().curve:render())
	end 
end 	

function Enemy:updateShooting(dt)
	-- if it's time to fire a new bullet! How exciting.
	if self.fireTimer:isComplete(dt) then 
		if self.shotPattern == SHOT_PATTERNS.circleBurstOutwards then 
			self:circleBurstOutwards(7.5)
		elseif self.shotPattern == SHOT_PATTERNS.scattershotTowardsPlayer then 
			self:scattershotTowardsPlayer()
		elseif self.shotPattern == SHOT_PATTERNS.singleShotTowardsPlayer then 
			self:singleShotTowardsPlayer()
		end 
	end 
end 

-- write out a list of bullet patterns 
function Enemy:scattershotTowardsPlayer()
	for i=1,10 do
		local playerPos = getCurrentPlayerPosition()
		playerPos.x = playerPos.x + math.random(-32, 32)
		playerPos.y = playerPos.y + math.random(-32, 32)
		vx = playerPos.x - self.x
		vy = playerPos.y - self.y
		local mag = math.sqrt(math.pow(vx,2) + math.pow(vy,2))
		vx = vx/mag * self.bulletSpeed
		vy = vy/mag * self.bulletSpeed
		bulletManager:newBullet(self.x + math.random(-24,24), self.y+ math.random(-24,24), vx, vy, BULLET_OWNER_TYPES.enemy)
	end
end 

function Enemy:circleBurstOutwards(degree)
	local count = 360/degree
	for i=1,count do
		local vx = math.cos((i-1)*degree * math.pi/180) * self.bulletSpeed
		local vy = math.sin((i-1)*degree * math.pi/180) * self.bulletSpeed
		bulletManager:newBullet(self.x, self.y, vx, vy, BULLET_OWNER_TYPES.enemy)
	end
end 

function Enemy:singleShotTowardsPlayer()
	local playerPos = getCurrentPlayerPosition()
	vx = playerPos.x - self.x
	vy = playerPos.y - self.y
	local mag = math.sqrt(math.pow(vx,2) + math.pow(vy,2))
	vx = vx/mag * self.bulletSpeed
	vy = vy/mag * self.bulletSpeed
	bulletManager:newBullet(self.x, self.y, vx, vy, BULLET_OWNER_TYPES.enemy)
end 