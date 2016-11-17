-- todo: make player guns (back OR front) rotate in circle? extra, do once complete

local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil



local player = nil 

bulletManager = nil 

local enemyManager = nil

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	player = Player:new()
	bulletManager = BulletManager:new()

	enemyManager = EnemyManager:new()
	enemyManager:addEnemy(
		1/2,
		0.5,
		ENEMY_SHOOT_OPTIONS.shootWhileWaiting,
		SHOT_PATTERNS.circleBurstOutwards,
		{
			newEnemyEvent(
				ENEMY_MOVEMENT_EVENTS.move, 
				newMoveEventArgs(topLeftToCentreCurve())),
			newEnemyEvent(
				ENEMY_MOVEMENT_EVENTS.wait, 
				newWaitEventArgs(1)),
			newEnemyEvent(
				ENEMY_MOVEMENT_EVENTS.move, 
				newMoveEventArgs(centreToTopRightCurve()))
		}
	)

end


-- BASE UPDATE 
function updateGame(dt)	
	if getKeyDown("escape") then love.event.quit() end 


	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
end

-- BASE DRAW 
function drawGame()
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end

function getCurrentPlayerPosition()
	return {x = player.x, y = player.y}
end 

