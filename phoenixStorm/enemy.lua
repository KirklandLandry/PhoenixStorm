-- enemy event queue
ENEMY_MOVEMENT_EVENTS = {move = "move", wait = "wait"}
ENEMY_SHOOT_OPTIONS	 = {shootWhileMoving = "shootWhileMoving", shootWhileWaiting = "shootWhileWaiting"}


-- enemy will have an event queue
-- it'll be able to do things like
-- move (along curve with a speed) to pt -> wait (for a period of time) -> move (along curve with a speed) -> despawn (queue empty)
function newEnemyEvent(_eventType, args)
	assert(_eventType == ENEMY_MOVEMENT_EVENTS.wait or _eventType == ENEMY_MOVEMENT_EVENTS.move, "make sure to send a valid event type")
	-- event type must be of ENEMY_EVENTS type
	-- arg must be an even numbered list of points comprising a bezier curve

	print(#args)


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

function newWaitEventArgs(_time)
	return {
		time = _time
	}
end 

function newMoveEventArgs(_curvePoints)
	return {
		curvePoints = _curvePoints
	}
end 

Enemy = {}
function Enemy:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = -100
	o.y = -100
	o.moveSpeed = 1/2.5


	-- bad. take an index, enemy manager will keep 1 instance of the sprite for each ship
	o.shipSprite = love.graphics.newImage("assets/sprites/32x32orbEnemy.png")
	o.shipSprite:setFilter("nearest", "nearest")
	o.shipWidth = o.shipSprite:getWidth()
	o.shipHeight = o.shipSprite:getHeight()

	o.fireOption = ENEMY_SHOOT_OPTIONS.shootWhileMoving
	o.bulletSpeed = 350
	o.fireRate = 0.5
	o.fireTimer = Timer:new(o.fireRate, TimerModes.repeating)

	o.renderPath = true

	o.eventQueue = Queue:new()
	--[[o.eventQueue:enqueue(newEnemyEvent(
		ENEMY_MOVEMENT_EVENTS.move, 
		newMoveEventArgs(topLeftBottomRightSCurve(o.shipWidth, o.shipHeight))
		))]]


	o.eventQueue:enqueue(newEnemyEvent(
		ENEMY_MOVEMENT_EVENTS.move, 
		newMoveEventArgs(
			{
			-o.shipWidth,-o.shipHeight,
			0,screenHeight/2, 
			screenWidth/2, screenHeight/2
			})
		))

	o.eventQueue:enqueue(newEnemyEvent(
		ENEMY_MOVEMENT_EVENTS.wait, 
		newWaitEventArgs(1)
		))


	o.eventQueue:enqueue(newEnemyEvent(
		ENEMY_MOVEMENT_EVENTS.move, 
		newMoveEventArgs(
			{
			screenWidth/2, screenHeight/2,
			screenWidth, screenHeight/2, 
			screenWidth , -o.shipHeight
			})
		))

	

	


	return o
end 


function Enemy:update(dt)
	if self.eventQueue:length() > 0 then 
		-- if the currenet event is movement 
		if self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.move then 
			-- if enemy is set to shoot while moving then  
			if self.fireOption == ENEMY_SHOOT_OPTIONS.shootWhileMoving then 
				-- if it's time to fire a new bullet
				if self.fireTimer:isComplete(dt) then 
					-- have an enum for shot type
					self:scattershotTowardsPlayer()
				end 
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
					-- if it's time to fire a new bullet
					if self.fireTimer:isComplete(dt) then 
						-- have an enum for shot type
						self:scattershotTowardsPlayer()
					end 
				end 
			end 
		end 
	end 
end 

function Enemy:draw()
	love.graphics.draw(self.shipSprite, self.x, self.y)

	if self.eventQueue:length() > 0 and self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.move and self.renderPath then 
		love.graphics.line(self.eventQueue:peek().curve:render())
	end 
end 	


-- write out a list of common bezier curve patterns  
function topLeftBottomRightSCurve(spriteWidth, spriteHeight)
	return {
	-spriteWidth,-spriteHeight,
	0,screenHeight + 200, 
	screenWidth, -333, 
	screenWidth, screenHeight}
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