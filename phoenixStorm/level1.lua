
Level1 = {}

BACKGROUND_ELEMENT_TYPE = {asteroid = "asteroid"}


function Level1:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.backgroundElementList = {}


    --o.asteroidList = {}

    return o
end

function Level1:update(dt)

end 

function Level1:draw()
    for i=1,#self.backgroundElementList do
        
    end
end 

function Level1:addSpawnPoint(enemy, count, spawnDelayTime)

end 

function Level1:addBackgroundElement(type, speed)
    --[[table.insert(self.backgroundElementList, {

    })]]
end 