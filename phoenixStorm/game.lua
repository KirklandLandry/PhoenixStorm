
-- maybe: add a bomb to clear all bullets
-- just draw a circle and despawn anything that goes inside the circle
-- grow the circle from the player position

local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver", stageWin = "stageWin"}
local gameState = nil

local player = nil 

bulletManager = nil 
enemyManager = nil
effectManager = nil
scoreManager = nil
level1 = nil
level1Boss= nil

local gameIcon = nil

local soundManager = "manager1"

local screenShakeBounds = {min = -5, max = 5}
local screenShakeActive = false
local bossExploding = false
local bossExposionTimer = nil
local fadeToWhiteDelayTimer = nil
local fadeToWhiteTimer = nil
local fadeToWhitePercentage = 0


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
	spam_setvolume(soundManager, audioSources.stage1, 0.9)
	spam_newsource(soundManager, audioSources.boss1, audioSources.boss1, 'stream')
	spam_setloopsource(soundManager, audioSources.boss1, true)
	--spam_setvolume(soundManager, audioSources.boss1, 0.9)
	spam_newsource(soundManager, audioSources.rumble, audioSources.rumble, 'static')
	spam_setloopsource(soundManager, audioSources.rumble, true)
	spam_newsource(soundManager, audioSources.rumbleComplete, audioSources.rumbleComplete, 'static')
	spam_setloopsource(soundManager, audioSources.rumbleComplete, false)

	gameIcon = love.graphics.newImage("assets/sprites/firepunch_alpha.png")
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
	elseif gameState:peek() == GAME_STATES.stageWin then 
		updateStageWin(dt)
	end 
	love.audio.update(dt)
end

function resetGame()
	screenShakeActive = false
	bossExploding = false
	bossExposionTimer = nil
	fadeToWhiteDelayTimer = nil
	fadeToWhiteTimer = nil
	fadeToWhitePercentage = 0


	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	player = Player:new()

	level1 = Level1:new()
	level1Boss = Level1Boss:new()

	bulletManager = BulletManager:new()
	effectManager = EffectManager:new()
	scoreManager = ScoreManager:new()
	enemyManager = EnemyManager:new()
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
		spam_stopsource(soundManager, audioSources.stage1)
		gameState:push(GAME_STATES.boss)
		level1Boss.movingToStartPoint = true
	end 
end 

function updateBoss(dt)
	bulletManager:updateBullets(dt)
	player:update(dt)
	enemyManager:update(dt)
	effectManager:update(dt)
	scoreManager:update(dt)
	checkIfPlayerDead()
	level1Boss:update(dt)

	if not bossExploding and level1Boss:isDefeated() then 
		bossExploding = true 
		bossExposionTimer = Timer:new(0.3, TimerModes.repeating)
		screenShakeActive = true 
		spam_playsource(soundManager, audioSources.rumble)
		spam_stopsource(soundManager, audioSources.boss1)
		-- setup white fade overlay timers 
		fadeToWhiteDelayTimer = Timer:new(5, TimerModes.single)
		fadeToWhiteTimer = Timer:new(5, TimerModes.single)
	end 


	if level1Boss:isMovingToStartPosition() and not bossExploding then 
		if not spam_issourceplaying(soundManager, audioSources.rumble) then
			spam_playsource(soundManager, audioSources.rumble)
  		end
		screenShakeActive = true
	elseif not level1Boss:isMovingToStartPosition() and not bossExploding then 
		spam_stopsource(soundManager, audioSources.rumble)
		if screenShakeActive then 
			spam_playsource(soundManager, audioSources.rumbleComplete)
			spam_playsource(soundManager, audioSources.boss1)
		end 
		screenShakeActive = false
	end 

	if bossExploding then 
		if bossExposionTimer:isComplete(dt) then 
			local pos = level1Boss:getHitbox()
			effectManager:addEffect(EFFECT_TYPE.explosion, math.random(pos.x, pos.x + pos.width), math.random(pos.y, pos.y + pos.height))
			playSoundEffect(audioSources.smallExplosion)
		end 

		if fadeToWhiteDelayTimer:isComplete(dt) then 
			if fadeToWhiteTimer:isComplete(dt) then 
				gameState:push(GAME_STATES.stageWin)
				spam_stopsource(soundManager, audioSources.rumble)
				scoreManager:saveHighScores()
			else 
				fadeToWhitePercentage = fadeToWhiteTimer:percentComplete()			
			end 
		end 
	end 
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
	if getKeyDown("r") then 
		resetGame()
	end 
end 

function updateStageWin(dt)
	if getKeyDown("r") then 
		resetGame()
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
	elseif gameState:peek() == GAME_STATES.stageWin then 
		drawStageWin()
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
	if screenShakeActive then 
		love.graphics.translate(math.random(screenShakeBounds.min, screenShakeBounds.max), math.random(screenShakeBounds.min, screenShakeBounds.max))
	end 

	level1:draw()
	level1Boss:draw()
	player:draw()
	bulletManager:drawBullets()
	enemyManager:draw()	
	effectManager:draw()
	scoreManager:draw()
	love.graphics.origin()
	drawUi()
	love.graphics.setColor(255, 255, 255, 255*fadeToWhitePercentage)
	love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
end 

function drawPaused()

end 

function drawTitle()
	drawText("phoenix storm", 144, 64)
	drawText("press j to start", 122, 96)
	love.graphics.draw(gameIcon, 180, 128)
	drawText("use wasd to move", 122, 288)
	drawText("use j to shoot", 144, 320)
end	 

function drawGameOver()
	drawText("game over", 32, 32)
	drawText("press r to restart", 32, 64)
	drawText("high scores", 32, 96)
	-- list off top 5 high scores
	for i=1,5 do
		drawText(tostring(i)..": "..scoreManager.highScoresList[i], 32, 128+((i-1)*32))
	end
end 

function drawStageWin()
	drawText("stage complete!", 32, 32)
	drawText("press r to restart", 32, 64)
	drawText("high scores", 32, 96)
	-- list off top 5 high scores
	for i=1,5 do
		drawText(tostring(i)..": "..scoreManager.highScoresList[i], 32, 128+((i-1)*32))
	end
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
		spam_stopsource(soundManager, audioSources.stage1)
		spam_stopsource(soundManager, audioSources.boss1)
		scoreManager:saveHighScores()
	end 
end 


function playSoundEffect(effect)
	--spam_playsource(soundManager, effect)
	love.audio.play(effect, "static", false)
end 