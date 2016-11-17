
Level1 = {}



function Level1:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.backgroundElementList = {}

    return o
end

function Level1:update(dt)

end 

function Level1:draw()
    for i=1,#self.backgroundElementList do
        print(i)
    end
end 

function Level1:addSpawnPoint(enemy, count, spawnDelayTime)

end 

function Level1:addBackgroundElement(type)

end 