-- todo: make player guns (back OR front) rotate in circle? extra, do once complete
-- will want to revamp bullet pattern system to allow higher control over bullets / more advanced behaviour


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

	initText()

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
	drawText("0123456789",0,0)
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




local textTileset = nil 
local textTilesetQuads = nil

function initText()
	textTileset = love.graphics.newImage("assets/sprites/16x16sonicFont.png")
	textTileset:setFilter("nearest", "nearest")

	local tilesetWidth = textTileset:getWidth()
	local tilesetHeight = textTileset:getHeight()

	textTilesetQuads = {}

	textTilesetQuads[" "] = love.graphics.newQuad(0, 0, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["."] = love.graphics.newQuad(6*16, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["?"] = love.graphics.newQuad(16*7, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[":"] = love.graphics.newQuad(16*2, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["!"] = love.graphics.newQuad(16*1, 0, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["\""] = love.graphics.newQuad(16*2, 0, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["#"] = love.graphics.newQuad(16*3, 0, 16, 16, tilesetWidth, tilesetHeight)

    local counter = 1
    for i=string.byte("a"),string.byte("g") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 64, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end
    counter = 0
    for i=string.byte("h"),string.byte("o") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 80, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end
    counter = 0
    for i=string.byte("p"),string.byte("w") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 96, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end
    counter = 0
    for i=string.byte("x"),string.byte("z") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 112, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end

    -- map numbers 
    for i=0,7 do
		textTilesetQuads[tostring(i)] = love.graphics.newQuad(i*16, 32, 16, 16, tilesetWidth, tilesetHeight)
    end
	textTilesetQuads["8"] = love.graphics.newQuad(0, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["9"] = love.graphics.newQuad(16, 48, 16, 16, tilesetWidth, tilesetHeight)

end 

function drawText(word, x, y)
	local counter = 0
	for c in word:gmatch"." do
		love.graphics.draw(textTileset, textTilesetQuads[c], x + (counter*16), y)
		counter = counter + 1
	end
end 



