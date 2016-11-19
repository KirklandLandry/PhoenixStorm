-- todo: make player guns (back OR front) rotate in circle? extra, do once complete
-- will want to revamp bullet pattern system to allow higher control over bullets / more advanced behaviour

-- could have a level stack, will just use a static level1

-- TODO: add a global sprite folder path to main?
-- TODO: add a bomb to clear all bullets
-- just draw a circle and despawn anything that goes inside the circle
-- grow the circle from the player position

-- screen shake while the boss is moving into position!!!

-- for saving files as json 
-- https://github.com/craigmj/json4lua
-- https://love2d.org/forums/viewtopic.php?f=4&t=10197
-- https://www.google.ca/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=love2d%20save%20system

local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil


local player = nil 

bulletManager = nil 
enemyManager = nil
effectManager = nil
scoreManager = nil
level1 = nil
level1Boss= nil

local soundManager = "manager1"

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	player = Player:new()

	level1 = Level1:new()
	level1Boss = Level1Boss:new()

	bulletManager = BulletManager:new()
	effectManager = EffectManager:new()
	scoreManager = ScoreManager:new()
	enemyManager = EnemyManager:new()

	spam_newmanager(soundManager)
	spam_newsource(soundManager, audioSources.stage1, audioSources.stage1, 'stream')
	spam_setloopsource(soundManager, audioSources.stage1, false)
	spam_newsource(soundManager, audioSources.boss1, audioSources.boss1, 'stream')
	spam_setloopsource(soundManager, audioSources.boss1, true)
	spam_newsource(soundManager, audioSources.smallExplosion, audioSources.smallExplosion, 'static')
	spam_setloopsource(soundManager, audioSources.smallExplosion, false)

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

	love.audio.update(dt)
end

function updateStage(dt)
	if not spam_issourceplaying(soundManager, audioSources.stage1) then
		spam_playsource(soundManager, audioSources.stage1)
  	end
	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
	effectManager:update(dt)
	scoreManager:update(dt)
	checkIfPlayerDead()
	level1:update(dt)
	if level1:isLevelComplete() then 
		gameState:push(GAME_STATES.boss)
	end 
end 

function updateBoss(dt)
	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
	effectManager:update(dt)
	scoreManager:update(dt)
	checkIfPlayerDead()
	--level1:update(dt)
end 

function updatePaused(dt)

end 

function updateTitle(dt)
	if getKeyDown("j") then 
		--resetInput()
		gameState:push(GAME_STATES.stage)
	end 
end	 

function updateGameOver(dt)
	if getKeyDown("h") then 

	end 
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
end

function drawStage()
	level1:draw()
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
	effectManager:draw()
	scoreManager:draw() 
	drawUi()	

	--love.graphics.circle("line", player:getCentre().x, player:getCentre().y, player.shipHitRadius)
end 

function drawBoss()
	level1:draw()
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()
	level1Boss:draw()
	effectManager:draw()
	scoreManager:draw()
	drawUi()
end 

function drawPaused()

end 

function drawTitle()
	drawText("press j to start", 32, 32)
end	 

function drawGameOver()
	drawText("game over", 32, 32)
	drawText("press h to restart", 32, 64)
end 

function drawUi()
	drawText("score: "..tostring(scoreManager:getCurrentScore()), 16, 16)
	drawText("lives: "..tostring(player.lives), 16, 32)
end 

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end

-- the should really return the player centre position as well
function getCurrentPlayerPosition()
	return {x = player.x, y = player.y, cx = player:getCentre().x, cy = player:getCentre().y, width = player.shipWidth, height = player.shipHeight}
end 

function bulletCurrentPlayerCollision(ex, ey, er)
	local pc = player:getCentre()
	return circleCircleCollision(pc.x,pc.y,player.shipHitRadius, ex,ey,er)
end 

function playerHit()
	player:hitByEnemyBullet()
end 

function checkIfPlayerDead()
	if player.lives < 0 then 
		gameState:push(GAME_STATES.gameOver)
	end 
end 


function playSoundEffect(effect)
	--spam_playsource(soundManager, effect)
	love.audio.play(effect, "static", false)
end 