
Level1 = {}

BACKGROUND_ELEMENT_TYPE = {yellowSun = "512x512yellowSun.png", speedLine = "speedLine"}

-- add white speed lines for the illusion of speed

function Level1:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.backgroundElementSprites = {}
    o.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun] = love.graphics.newImage("assets/sprites/512x512yellowSun.png")
    o.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun]:setFilter("nearest", "nearest")



    o.backgroundElementList = {
        bottomLayer = {},
        topLayer = {}
    }


    return o
end

function Level1:update(dt)
    -- update all the scrolling for background visuals
    local count = #self.backgroundElementList.bottomLayer
    for i=count,1,-1 do
        self.backgroundElementList.bottomLayer[i].y = self.backgroundElementList.bottomLayer[i].y + (self.backgroundElementList.bottomLayer[i].scrollSpeed * dt)
        print(self.backgroundElementList.bottomLayer[i].y, self.backgroundElementList.bottomLayer[i].x)
        if self.backgroundElementList.bottomLayer[i].y > screenHeight then 
            table.remove(self.backgroundElementList.bottomLayer, i)
        end 
    end
    local count = #self.backgroundElementList.topLayer
    for i=count,1,-1 do
        self.backgroundElementList.topLayer[i].y = self.backgroundElementList.topLayer[i].y + (self.backgroundElementList.topLayer[i].scrollSpeed * dt)
        print(self.backgroundElementList.topLayer[i].y, self.backgroundElementList.topLayer[i].x)
        if self.backgroundElementList.topLayer[i].y > screenHeight then 
            table.remove(self.backgroundElementList.topLayer, i)
        end 
    end
    -- update spawn points
end 

function Level1:draw()
    -- draw scrolling background elements
    for i=1,#self.backgroundElementList.bottomLayer do
        love.graphics.draw(self.backgroundElementSprites[self.backgroundElementList.bottomLayer[i].spriteIndex], self.backgroundElementList.bottomLayer[i].x, self.backgroundElementList.bottomLayer[i].y)
    end
    for i=1,#self.backgroundElementList.topLayer do
        love.graphics.draw(self.backgroundElementSprites[self.backgroundElementList.topLayer[i].spriteIndex], self.backgroundElementList.topLayer[i].x, self.backgroundElementList.topLayer[i].y)
    end
end 

function Level1:addSpawnPoint(enemy, count, spawnDelayTime)

end 

function Level1:addBackgroundElement(type, speed)
    if type == BACKGROUND_ELEMENT_TYPE.yellowSun then 
        table.insert(self.backgroundElementList.bottomLayer, {
                x = 0,--math.random(0, screenWidth/3),
                y = -self.backgroundElementSprites[BACKGROUND_ELEMENT_TYPE.yellowSun]:getHeight(),
                spriteIndex = BACKGROUND_ELEMENT_TYPE.yellowSun,
                scrollSpeed = speed
        })
    end 
end 