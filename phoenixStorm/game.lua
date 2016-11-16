local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil


local player = nil 

bulletManager = nil 

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)


	player = Player:new()

	bulletManager = BulletManager:new()

end



-- BASE UPDATE 
function updateGame(dt)	
	if getKeyDown("escape") then love.event.quit() end 

	bulletManager:updateBullets(dt)

	player:update(dt)

end

-- BASE DRAW 
function drawGame()
	player:draw()
	bulletManager:drawBullets()
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end

