ScoreManager = {}
function ScoreManager:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self


    o.scoreTokenSpriteSheet = love.graphics.newImage("assets/sprites/96x16coinSpriteSheet.png")
    o.scoreTokenSpriteSheet:setFilter("nearest", "nearest")
    o.scoreTokenSpriteSheetWidth = o.scoreTokenSpriteSheet:getWidth()
    o.scoreTokenSpriteSheetHeight = o.scoreTokenSpriteSheet:getHeight()
    o.scoreTokenSpriteSheetQuads = {}
    o.scoreTokenTotalFrameCount = 6
    o.scoreTokenWidth = 16
    o.scoreTokenHeight = 16
    o.scoreTokenMoveSpeed = 90
    for i=1,6 do
        o.scoreTokenSpriteSheetQuads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, o.scoreTokenSpriteSheetWidth, o.scoreTokenSpriteSheetHeight)
    end

    o.scoreTokenList = {}
    o.currentScore = 0
    return o
end


function ScoreManager:update(dt)
    local count = #self.scoreTokenList
    for i=count,1,-1 do
        -- update animation
        if self.scoreTokenList[i].frameTimer:isComplete(dt) then
            self.scoreTokenList[i].frameIndex = self.scoreTokenList[i].frameIndex + 1
            if self.scoreTokenList[i].frameIndex > self.scoreTokenTotalFrameCount then 
                self.scoreTokenList[i].frameIndex = 1
            end 
        end 
        -- update position (score tokens slowly move towards player)
        local playerPos = getCurrentPlayerPosition()
        local nvx = playerPos.x - self.scoreTokenList[i].x
        local nvy = playerPos.y - self.scoreTokenList[i].y
        local mag = math.sqrt(math.pow(nvx,2) + math.pow(nvy,2))
        nvx = nvx / mag 
        nvy = nvy / mag 
        self.scoreTokenList[i].vx = nvx * self.scoreTokenMoveSpeed * dt
        self.scoreTokenList[i].vy = nvy * self.scoreTokenMoveSpeed * dt
        self.scoreTokenList[i].x = self.scoreTokenList[i].x + self.scoreTokenList[i].vx 
        self.scoreTokenList[i].y = self.scoreTokenList[i].y + self.scoreTokenList[i].vy
        
        -- check if player collected a score token
        local tempToken = self.scoreTokenList[i]
        if rectRectCollision(playerPos.x, playerPos.y, playerPos.width, playerPos.height, tempToken.x, tempToken.y, tempToken.width, tempToken.height) then 
            self.currentScore = self.currentScore + self.scoreTokenList[i].value
            table.remove(self.scoreTokenList,i)
            playSoundEffect(audioSources.scoreToken)
        -- else update lifetime and remove if it's done
        elseif self.scoreTokenList[i].lifetimeTimer:isComplete(dt) then
            table.remove(self.scoreTokenList, i)
        -- else fade the colour if it's almost done
        else
            if self.scoreTokenList[i].lifetimeTimer:percentComplete() > 0.7 then 
                self.scoreTokenList[i].fadeColour = 100
            end 
        end 
    end 
end 

function ScoreManager:draw()
    local count = #self.scoreTokenList
    for i=1,count do
        love.graphics.setColor(self.scoreTokenList[i].fadeColour,self.scoreTokenList[i].fadeColour,self.scoreTokenList[i].fadeColour,255)
        love.graphics.draw(self.scoreTokenSpriteSheet, self.scoreTokenSpriteSheetQuads[self.scoreTokenList[i].frameIndex], self.scoreTokenList[i].x, self.scoreTokenList[i].y)
    end
    resetColor()
end 

function ScoreManager:getCurrentScore()
    return self.currentScore
end 

function ScoreManager:newScoreToken(_x, _y, _value)
    table.insert(self.scoreTokenList, 
    {
        x = _x,
        y = _y,
        vx = 0,
        vy = 0,
        width = 16,
        height = 16,
        value = _value,
        frameIndex = 1,
        frameTimer = Timer:new(0.08, TimerModes.repeating),
        lifetimeTimer = Timer:new(5, TimerModes.single),
        fadeColour = 255
    })
end 

function ScoreManager:newScoreTokenGroup(_x, _y, _value)
    for i=1,10 do
        self:newScoreToken(_x + math.random(-20, 20), _y + math.random(-20,20), _value)
    end
end 