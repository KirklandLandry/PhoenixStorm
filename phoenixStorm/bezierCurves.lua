-- just a file of functions that return bezier curves
-- keeps the other files clean
function topLeftBottomRightSCurve(spriteWidth, spriteHeight)
	return {
	-spriteWidth,-spriteHeight,
	0,screenHeight + 200, 
	screenWidth, -333, 
	screenWidth, screenHeight}
end 

function topRightBottomLeftSCurve(spriteWidth, spriteHeight)
	return {
	screenWidth,-spriteHeight,
	screenWidth,screenHeight + 200, 
	0, -333, 
	0, screenHeight}
end 

function topLeftToCentreCurve()
	return {
	0,-64,
	0,screenHeight/3, 
	screenWidth/2, screenHeight/3}
end 

function centreToBottomRightCurve()
	return {
	screenWidth/2, screenHeight/3,
	screenWidth,screenHeight/3 + 200, 
	screenWidth, screenHeight
	}
end 


function centreToTopRightCurve()
	return {
	screenWidth/2, screenHeight/3,
	screenWidth, screenHeight/3, 
	screenWidth , -64}
end 

function arcThroughCentre()
	return {
	0,-64,
	screenWidth/2, screenHeight/1.5, 
	screenWidth , -64}
end 

function arcThroughCentreRightToLeft()
	return {
	screenWidth , -64,
	screenWidth/2, screenHeight/1.5, 
	0,-64,}
end 

function leftCorner()
	return {
	0, -100, 
	100, screenWidth/3
	}
end 
function leftCornerReverse()
	return {
	100, screenWidth/3,
	0, -100
	}
end 



function rightCorner()
	return {
	screenWidth, -100, 
	screenWidth -96, screenWidth/3
	}
end 
function rightCornerReverse()
	return {
	screenWidth -96, screenWidth/3,
	screenWidth, -100
	}
end 


