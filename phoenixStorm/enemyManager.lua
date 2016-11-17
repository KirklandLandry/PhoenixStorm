-- basically, I want to be able to say
-- "I want an enemy with this sprite, to move with this pattern, to fire this bullet pattern"


EnemyManager = {}
function EnemyManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	


	return o
end
