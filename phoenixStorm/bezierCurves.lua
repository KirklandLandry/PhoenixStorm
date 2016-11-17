-- just a file of functions that return bezier curves
-- keeps the other files clean
function topLeftBottomRightSCurve(spriteWidth, spriteHeight)
	return {
	-spriteWidth,-spriteHeight,
	0,screenHeight + 200, 
	screenWidth, -333, 
	screenWidth, screenHeight}
end 

function topLeftToCentreCurve()
	return {
	0,-64,
	0,screenHeight/3, 
	screenWidth/2, screenHeight/3}
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
	screenWidth/2, screenHeight/3, 
	screenWidth , -64}
end 