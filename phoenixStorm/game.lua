-- todo: make player guns (back OR front) rotate in circle? extra, do once complete

local GAME_STATES = {stage = "stage", boss = "boss", paused = "paused", title = "title", gameOver = "gameOver"}
local gameState = nil



local player = nil 

bulletManager = nil 


local testRect = nil

local bcurve = nil

-- BASE LOAD
function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	player = Player:new()
	bulletManager = BulletManager:new()

	testRect = {x = screenWidth, y = 0, i = 0}
	bcurve = love.math.newBezierCurve({0,0,
	0,screenHeight, 
	screenWidth, 0, 
	screenWidth, screenHeight})
end


-- BASE UPDATE 
function updateGame(dt)	
	if getKeyDown("escape") then love.event.quit() end 


	testRect.i = testRect.i + dt / 5
	local x,y = bcurve:evaluate(testRect.i)
	testRect.x = x
	testRect.y = y

	bulletManager:updateBullets(dt)
	player:update(dt)
end

-- BASE DRAW 
function drawGame()
	player:draw()
	bulletManager:drawBullets()
	love.graphics.line(bcurve:render())

	love.graphics.rectangle("fill", testRect.x, testRect.y, 32,32)
end

-- window focus callback
function love.focus(f)
	if not f then
	else
	end
end

function circleCircleCollision(x1,y1,r1, x2,y2,r2)
	-- if the distance between the 2 centres is less thena the sum of the 2 radii, the circles overlap
	return (x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2
end 

-- http://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
-- http://www.wildbunny.co.uk/blog/2011/04/20/collision-detection-for-dummies/
function rectCircleCollision(bx,by,bw,bh, cx,cy,cr)
	-- find the closest edge to the circle within the rectangle
	local closestX = math.clamp(circle.collider.pos.x, bx, bx + bw)
	local closestY = math.clamp(circle.collider.pos.y, by, by + bh)
	
	-- calculate the distance between the circle's centre and this closest point 
	local distanceX = cx - closestX 
	local distanceY = cy - closestY	
	
	-- if the distance is less the n the circle's radius, intersection 
	local distanceSquared = math.pow(distanceX,2) + math.pow(distanceY,2)
	if distanceSquared < math.pow(cr,2) then 
		return true 
	else 
		return false
	end  
end
