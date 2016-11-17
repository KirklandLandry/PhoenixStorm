-- enemy event queue
ENEMY_MOVEMENT_EVENTS = {move = "move", wait = "wait"}
ENEMY_SHOOT_OPTIONS	 = {shootWhileMoving = "shootWhileMoving", shootWhileWaiting = "shootWhileWaiting"}

-- enemy will have an event queue
-- it'll be able to do things like
-- move (along curve with a speed) to pt -> wait (for a period of time) -> move (along curve with a speed) -> despawn (queue empty)
function newEnemyEvent(eventType, arg)
	-- event type must be of ENEMY_EVENTS type
	-- arg must be an even numbered list of points comprising a bezier curve

	if eventType == ENEMY_MOVEMENT_EVENTS.wait then 

	elseif eventType == ENEMY_MOVEMENT_EVENTS.move then 

	end 
end 


Enemy = {}
function Enemy:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = 0
	o.y = 0
	o.moveSpeed = 310
	o.originalMoveSpeed = 310
	o.firingMoveSpeed = o.originalMoveSpeed * 0.55
	
	--[[o.currentlyFiring = false
	o.bulletSpeed = 650
	o.fireRate = 0.08
	o.fireTimer = Timer:new(o.fireRate, TimerModes.single)
	o.canFire = true 

	o.shipHitRadius = 5
	o.shipSprite = love.graphics.newImage("assets/sprites/96x96playerShip.png")
	o.shipSprite:setFilter("nearest", "nearest")
	o.shipWidth = o.shipSprite:getWidth()
	o.shipHeight = o.shipSprite:getHeight()]]

	return o
end 


-- write out a list of common bezier curve functions  