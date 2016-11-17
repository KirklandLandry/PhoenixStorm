-- todo: make player guns (back OR front) rotate in circle? extra, do once complete
-- will want to revamp bullet pattern system to allow higher control over bullets / more advanced behaviour


-- TODO: add a global sprite folder path to main?


local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil


local player = nil 

bulletManager = nil 
enemyManager = nil
effectManager = nil
scoreManager = nil

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	player = Player:new()
	bulletManager = BulletManager:new()

	effectManager = EffectManager:new()

	scoreManager = ScoreManager:new()

	enemyManager = EnemyManager:new()
	enemyManager:addEnemy(
		1/2,
		0.5,
		ENEMY_SHOOT_OPTIONS.shootWhileMoving,
		SHOT_PATTERNS.circleBurstOutwards,
		ENEMY_SHIP_SPRITES.mediumEnemy1,
		5,
		{
			newEnemyEvent(
				ENEMY_MOVEMENT_EVENTS.move, 
				newMoveEventArgs(topLeftToCentreCurve())),
			newEnemyEvent(
				ENEMY_MOVEMENT_EVENTS.move, 
				newMoveEventArgs(centreToTopRightCurve()))
		}
	)

end


-- BASE UPDATE 
function updateGame(dt)	
	if getKeyDown("escape") then love.event.quit() end 

	if getKeyPress("h") then 
	enemyManager:addEnemy(
		1/2,
		0.5,
		ENEMY_SHOOT_OPTIONS.shootWhileWaiting,
		SHOT_PATTERNS.circleBurstOutwards,
		ENEMY_SHIP_SPRITES.orbEnemy,
		5,
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
	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
	effectManager:update(dt)
	scoreManager:update(dt)
end

-- BASE DRAW 
function drawGame()
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
	effectManager:draw()
	scoreManager:draw()
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end

function getCurrentPlayerPosition()
	return {x = player.x, y = player.y, width = player.shipWidth, height = player.shipHeight}
end 

function bulletCurrentPlayerCollision(ex, ey, er)
	local pc = player:getCentre()
	return circleCircleCollision(pc.x,pc.y,player.shipHitRadius, ex,ey,er)
end 

function playerHit()

end 