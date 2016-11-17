-- basically, I want to be able to say
-- "I want an enemy with this sprite, to move with this pattern, to fire this bullet pattern"


-- enemy manager should have "add enemy of type x" functions to save repititions
-- when you get to the actual game structuring start making enemy types 

EnemyManager = {}
function EnemyManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.enemyList = {}


	return o
end

function EnemyManager:addEnemy(_moveSpeed, _fireRate, _fireOption, _shotPattern, eventList)
	table.insert(
		self.enemyList, Enemy:new(_moveSpeed, _fireRate, _fireOption, _shotPattern, eventList)
	)
end 

function EnemyManager:update(dt)
	for i=1,#self.enemyList do
		self.enemyList[i]:update(dt)
	end
end 

function EnemyManager:draw()
	for i=1,#self.enemyList do
		self.enemyList[i]:draw()
	end
end 