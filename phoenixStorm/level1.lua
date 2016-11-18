
Level1 = {}

BACKGROUND_ELEMENT_TYPE = {yellowSun = "512x512yellowSun.png", speedLine = "speedLine"}

ENEMY_TYPE = {
enemy1 = "enemy1", 
enemy2 = "enemy2", 
enemy3Left = "enemy3Left", 
enemy3Right = "enemy3Right", 
enemy4 = "enemy4",
enemy5Left = "enemy5Left",
enemy5Right = "enemy5Right",
enemy6Left = "enemy6Left",
enemy6Right = "enemy6Right"}

-- add white speed lines for the illusion of speed
-- would need a table reverse function (special since it would have to flip every 2)

-- NOTE: Boss entry will occur at 70 seconds. by then the sun is at the bottom

function Level1:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- level time 
    o.levelProgress = 0
    -- enemy spawn points
    o.levelTriggers = {
    	-- left to right arc through centre
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy1, 5, 0.5, 1),
    	-- right to left arc through centre
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy2, 5, 0.5, 5),
    	-- pop up in each coner and fire circle
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy3Left, 1, 0.3, 7),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy3Right, 1, 0.3, 7),
    	-- repeat first 2
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy1, 3, 0.3, 15),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy2, 3, 0.3, 15),
    	-- stick an enemy in the centre and just shoot single shots
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy4, 1, 0.3, 17),
    	-- s curve from both corners 
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy5Left, 1, 0.3, 27),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy5Right, 1, 0.3, 27),
    	-- pop up in each coner and fire circle
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy3Left, 1, 0.3, 39),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy3Right, 1, 0.3, 39),
    	-- stick an enemy in the centre and just shoot single shots
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy4, 1, 0.3, 42),
    	-- left to right arc through centre
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy1, 3, 0.5, 48),
    	-- right to left arc through centre
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy2, 3, 0.5, 48),
    	-- s curve an shoot singles 
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy6Left, 4, 0.4, 55),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy6Right, 4, 0.4, 55),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy6Left, 7, 0.2, 60),
    	self:addSpawnPointTrigger(ENEMY_TYPE.enemy6Right, 7, 0.2, 60)
	}
	o.activeLevelTriggers = {}	

    o.backgroundElementSprites = {}
    o.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun] = love.graphics.newImage("assets/sprites/512x512yellowSun.png")
    o.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun]:setFilter("nearest", "nearest")



    o.backgroundElementList = {
        bottomLayer = {},
        topLayer = {}
    }


    return o
end

function Level1:update(dt)
	-- update the level time 
	self.levelProgress = self.levelProgress + dt
	print(self.levelProgress)
	-- check spawn triggers 
    local count = #self.levelTriggers
    for i=count,1,-1 do  
        if self.levelProgress >= self.levelTriggers[i].entryTime then 
        	local temp = self.levelTriggers[i]
        	self:addSpawnPoint(temp.enemy, temp.count, temp.spawnDelayTime)
            table.remove(self.levelTriggers, i)
        end 
    end
    -- check active spawn points
    count = #self.activeLevelTriggers
    for i=count,1,-1 do 
    	if self.activeLevelTriggers[i].spawnTimer:isComplete(dt) then 
    		self.activeLevelTriggers[i].currentCount = self.activeLevelTriggers[i].currentCount + 1
    		-- if you've spawned all your enemies, die
    		if self.activeLevelTriggers[i].currentCount > self.activeLevelTriggers[i].maxCount then 
    			table.remove(self.activeLevelTriggers,i)
    		-- otherwise keep spawning
    		else 
    			enemySpawnSelector(self.activeLevelTriggers[i].enemyType)
    		end 
    	end 
    end 


    -- update all the scrolling for background visuals
    count = #self.backgroundElementList.bottomLayer
    for i=count,1,-1 do
        self.backgroundElementList.bottomLayer[i].y = self.backgroundElementList.bottomLayer[i].y + (self.backgroundElementList.bottomLayer[i].scrollSpeed * dt)
        if self.backgroundElementList.bottomLayer[i].y > screenHeight then 
            table.remove(self.backgroundElementList.bottomLayer, i)
        end 
    end
    count = #self.backgroundElementList.topLayer
    for i=count,1,-1 do
        self.backgroundElementList.topLayer[i].y = self.backgroundElementList.topLayer[i].y + (self.backgroundElementList.topLayer[i].scrollSpeed * dt)
        if self.backgroundElementList.topLayer[i].y > screenHeight then 
            table.remove(self.backgroundElementList.topLayer, i)
        end 
    end
    -- update spawn points
end 

function Level1:draw()
    -- draw scrolling background elements
    for i=1,#self.backgroundElementList.bottomLayer do
        love.graphics.draw(self.backgroundElementSprites[self.backgroundElementList.bottomLayer[i].spriteIndex], self.backgroundElementList.bottomLayer[i].x, self.backgroundElementList.bottomLayer[i].y)
    end
    for i=1,#self.backgroundElementList.topLayer do
        love.graphics.draw(self.backgroundElementSprites[self.backgroundElementList.topLayer[i].spriteIndex], self.backgroundElementList.topLayer[i].x, self.backgroundElementList.topLayer[i].y)
    end
end 

-- the enemyType, how many to spawn, delay between spawns, what time in the level they spawn
function Level1:addSpawnPointTrigger(_enemy, _count, _spawnDelayTime, _entryTime)
	return {
		enemy = _enemy,
		count = _count,
		spawnDelayTime = _spawnDelayTime,
		entryTime = _entryTime
	}
end 

function Level1:addSpawnPoint(_enemy, _count, _spawnDelayTime)
	table.insert(self.activeLevelTriggers, {
		enemyType = _enemy,
		maxCount = _count,
		currentCount = 0,
		spawnTimer = Timer:new(_spawnDelayTime, TimerModes.repeating),
	})
end 

function Level1:addBackgroundElement(enemyType, speed)
    if enemyType == BACKGROUND_ELEMENT_TYPE.yellowSun then 
        table.insert(self.backgroundElementList.bottomLayer, {
                x = 0,--math.random(0, screenWidth/3),
                y = -self.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun]:getHeight(),
                spriteIndex = BACKGROUND_ELEMENT_TYPE.yellowSun,
                scrollSpeed = speed
        })
    end 
end 


function enemySpawnSelector(enemyType)
	if enemyType == ENEMY_TYPE.enemy1 then 
		SpawnEnemy1()
	elseif enemyType == ENEMY_TYPE.enemy2 then 
		SpawnEnemy2()
	elseif enemyType == ENEMY_TYPE.enemy3Left then 
		SpawnEnemy3(leftCorner(), leftCornerReverse())
	elseif enemyType == ENEMY_TYPE.enemy3Right then 
		SpawnEnemy3(rightCorner(), rightCornerReverse())
	elseif enemyType == ENEMY_TYPE.enemy4 then 
		SpawnEnemy4()
	elseif enemyType == ENEMY_TYPE.enemy5Left then 
		SpawnEnemy5(topLeftBottomRightSCurve(0, -96))
	elseif enemyType == ENEMY_TYPE.enemy5Right then 
		SpawnEnemy5(topRightBottomLeftSCurve(0, -96))
	elseif enemyType == ENEMY_TYPE.enemy6Left then 
		SpawnEnemy6(topLeftBottomRightSCurve(0, -96))
	elseif enemyType == ENEMY_TYPE.enemy6Right then 
		SpawnEnemy6(topRightBottomLeftSCurve(0, -96))
	end 
end 



function SpawnEnemy1()
enemyManager:addEnemy(
			1/3,
			0.7,
			400,
			ENEMY_SHOOT_OPTIONS.shootWhileMoving,
			SHOT_PATTERNS.scattershotTowardsPlayer,
			ENEMY_SHIP_SPRITES.orbEnemy,
			5,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(arcThroughCentre()))
			}
		)
end 

function SpawnEnemy2()
enemyManager:addEnemy(
			1/3,
			0.7,
			400,
			ENEMY_SHOOT_OPTIONS.shootWhileMoving,
			SHOT_PATTERNS.scattershotTowardsPlayer,
			ENEMY_SHIP_SPRITES.orbEnemy,
			5,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(arcThroughCentreRightToLeft()))
			}
		)
end 

function SpawnEnemy3(curve1, curve2)
enemyManager:addEnemy(
			1/0.5,
			0.6,
			400,
			ENEMY_SHOOT_OPTIONS.shootWhileWaiting,
			SHOT_PATTERNS.circleTowardsPlayer,
			ENEMY_SHIP_SPRITES.orbEnemy,
			15,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(curve1)),
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.wait, 
					newWaitEventArgs(6)),
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(curve2))
			}
		)
end 

function SpawnEnemy4()
enemyManager:addEnemy(
			1/3,
			0.3,
			450,
			ENEMY_SHOOT_OPTIONS.shootWhileWaiting,
			SHOT_PATTERNS.singleShotTowardsPlayer,
			ENEMY_SHIP_SPRITES.mediumEnemy1,
			85,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(topLeftToCentreCurve())),
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.wait, 
					newWaitEventArgs(8)),
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(centreToBottomRightCurve())),
			}
		)
end 

function SpawnEnemy5(curve)
enemyManager:addEnemy(
			1/4,
			0.9,
			50,
			ENEMY_SHOOT_OPTIONS.shootWhileMoving,
			SHOT_PATTERNS.circleBurstOutwards,
			ENEMY_SHIP_SPRITES.mediumEnemy1,
			20,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(curve))
			}
		)
end 

function SpawnEnemy6(curve)
enemyManager:addEnemy(
			1/2.5,
			0.25,
			200,
			ENEMY_SHOOT_OPTIONS.shootWhileMoving,
			SHOT_PATTERNS.singleShotTowardsPlayer,
			ENEMY_SHIP_SPRITES.orbEnemy,
			7,
			{
				newEnemyEvent(
					ENEMY_MOVEMENT_EVENTS.move, 
					newMoveEventArgs(curve)),
			}
		)
end 

