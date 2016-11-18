
local textTileset = nil 
local textTilesetQuads = nil

function loadFonts()
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
    textTilesetQuads["-"] = love.graphics.newQuad(16*5, 16, 16, 16, tilesetWidth, tilesetHeight)


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

function drawText(word, _x, _y)
    local x = _x or 0
    local y = _y or 0
    local counter = 0
    for c in word:gmatch"." do
        love.graphics.draw(textTileset, textTilesetQuads[c], x + (counter*16), y)
        counter = counter + 1
    end
end 
