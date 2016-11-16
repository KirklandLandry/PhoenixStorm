local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

end

-- BASE UPDATE 
function updateGame(dt)	

end

-- BASE DRAW 
function drawGame()
	
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end