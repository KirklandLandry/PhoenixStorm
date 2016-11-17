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
			timer = Timer:new(args.time, args.mode)
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

function newWaitEventArgs(_time, _mode)
	return {
		time = _time,
		mode = _mode
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

	o.renderPath = true

	o.eventQueue = Queue:new()
	o.eventQueue:enqueue(newEnemyEvent(
		ENEMY_MOVEMENT_EVENTS.move, 
		newMoveEventArgs(topLeftBottomRightSCurve(o.shipWidth, o.shipHeight))
		))



	--[[
	o.bulletSpeed = 650
	o.fireRate = 0.08
	o.fireTimer = Timer:new(o.fireRate, TimerModes.single)
	]]


	return o
end 


function Enemy:update(dt)

	print(self.eventQueue:length())

	if self.eventQueue:length() > 0 then 
		if self.eventQueue:peek().eventType == ENEMY_MOVEMENT_EVENTS.move then 
			self.eventQueue:peek().percentComplete = self.eventQueue:peek().percentComplete + (self.moveSpeed * dt)

			print(self.eventQueue:peek().percentComplete)

			if self.eventQueue:peek().percentComplete > 1 then 
				self.eventQueue:dequeue()
			else 
				local x,y = self.eventQueue:peek().curve:evaluate(self.eventQueue:peek().percentComplete)
				self.x = x
				self.y = y
			end 

		end 
	end 
	
	
end 

function Enemy:draw()
	love.graphics.draw(self.shipSprite, self.x, self.y)
end 	


-- write out a list of common bezier curve functions  


function topLeftBottomRightSCurve(spriteWidth, spriteHeight)
	return {
	-spriteWidth,-spriteHeight,
	0,screenHeight + 200, 
	screenWidth, -333, 
	screenWidth, screenHeight}
end 


-- write out a list of bullet patterns 