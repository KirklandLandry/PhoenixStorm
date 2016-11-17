-- todo: make player guns (back OR front) rotate in circle? extra, do once complete
-- will want to revamp bullet pattern system to allow higher control over bullets / more advanced behaviour

-- could have a level stack, will just use a static level1

-- TODO: add a global sprite folder path to main?
-- TODO: add a bomb to clear all bullets
-- just draw a circle and despawn anything that goes inside the circle
-- grow the circle from the player position


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
	if getKeyPress("escape") then love.event.quit() end 

	if gameState:peek() == GAME_STATES.stage then 
		updateStage(dt)
	elseif gameState:peek() == GAME_STATES.boss then 
		updateBoss(dt)
	elseif gameState:peek() == GAME_STATES.paused then 
		updatePaused(dt)
	elseif gameState:peek() == GAME_STATES.title then 
		updateTitle(dt)
	elseif gameState:peek() == GAME_STATES.gameOver then 
		updateGameOver(dt)
	end 
end

function updateStage(dt)
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

function updateBoss(dt)
	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
	effectManager:update(dt)
	scoreManager:update(dt)
end 

function updatePaused(dt)

end 

function updateTitle(dt)
	if getKeyDown("j") then 
		resetInput()
		gameState:push(GAME_STATES.stage)
	end 
end	 

function updateGameOver(dt)

end 


-- BASE DRAW 
function drawGame()

	if gameState:peek() == GAME_STATES.stage then 
		drawStage()
	elseif gameState:peek() == GAME_STATES.boss then 
		drawBoss()
	elseif gameState:peek() == GAME_STATES.paused then 
		drawPaused()
	elseif gameState:peek() == GAME_STATES.title then 
		drawTitle()
	elseif gameState:peek() == GAME_STATES.gameOver then 
		drawGameOver()
	end 


	--drawText("0123456789",0,0)
end

function drawStage(dt)
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
	effectManager:draw()
	scoreManager:draw()
end 

function drawBoss(dt)
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
	effectManager:draw()
	scoreManager:draw()
end 

function drawPaused(dt)

end 

function drawTitle(dt)
	drawText("press j to start", 32, 32)
end	 

function drawGameOver(dt)

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
	player:hitByEnemyBullet()
end 

