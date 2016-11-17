-- basically, I want to be able to say
-- "I want an enemy with this sprite, to move with this pattern, to fire this bullet pattern"


-- enemy manager should have "add enemy of type x" functions to save repititions
-- when you get to the actual game structuring start making enemy types 

ENEMY_SHIP_SPRITES = {orbEnemy = "32x32orbEnemy.png", }
local spritePath = "assets/sprites/"

EnemyManager = {}
function EnemyManager:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.enemySprites = {}
	o.enemySprites[ENEMY_SHIP_SPRITES.orbEnemy] = love.graphics.newImage("assets/sprites/32x32orbEnemy.png")
	o.enemySprites[ENEMY_SHIP_SPRITES.orbEnemy]:setFilter("nearest", "nearest")

	o.enemyList = {}

	return o
end

function EnemyManager:addEnemy(_moveSpeed, _fireRate, _fireOption, _shotPattern, _sprite, _health, eventList)
	table.insert(self.enemyList, Enemy:new(_moveSpeed, _fireRate, _fireOption, _shotPattern, _sprite, _health, eventList) )
end 

function EnemyManager:update(dt)
	for i=#self.enemyList,1,-1 do
		-- update enemy
		self.enemyList[i]:update(dt)
		-- if an enemy is exhausted all it's actions, despawn it
		if self.enemyList[i].eventQueue:length() <= 0 or self.enemyList[i].health <= 0  then 
			if self.enemyList[i].health <= 0  then 
				effectManager:addEffect(EFFECT_TYPE.explosion, self.enemyList[i].x, self.enemyList[i].y)
				-- enemy score value should come from the enemy, not just 10
				scoreManager:newScoreTokenGroup(self.enemyList[i].x, self.enemyList[i].y, 10)
			end 
			table.remove(self.enemyList, i)
		end 	
	end
end 

function EnemyManager:draw()
	-- draw enemy
	for i=1,#self.enemyList do
		self.enemyList[i]:draw(self.enemySprites[self.enemyList[i].spriteIndex])
	end
end 

function EnemyManager:getEnemyCount()
	return #self.enemyList
end 

function EnemyManager:getElementAt(index)
	return self.enemyList[index]
end 

function EnemyManager:decreaseHealth(index)
	self.enemyList[index].health = self.enemyList[index].health -1
end 