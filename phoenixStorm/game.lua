local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil


local player = nil 

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)


	player = Player:new()
end

-- BASE UPDATE 
function updateGame(dt)	
	if getKeyDown("escape") then love.event.quit() end 


	player:update(dt)

end

-- BASE DRAW 
function drawGame()
	player:draw()
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end