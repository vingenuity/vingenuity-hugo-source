+++
title = "In-Game HUD"
subtitle = ""
Description = ""
Tags = []
languages = ["lua"]
project_base_name = "professor-cadbury"
+++
{{< vimeo id="119056654" class="video-container" >}}
{{% section class="section scrollspy" %}}
### Motivation
One of the less developed features in GuildEd was the UI system. As a result, even though our game needed a minimal UI, I needed to write a custom UI class for our game.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
As with the end-of-level menu, my main focus in the writing of this class was flexibility. Each UI Element is able to be set to a specific corner of the screen, given an independent offset, linked to a specific piece of game data, rendered as a number or bar, and given a specific icon. This flexibility allowed us to quickly set up our HUD and modify it when necessary.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### In-Game HUD
{{< code-block lua >}}
--JS: File load and execution priority
priority = -850

dofile( self, APP_PATH .. "scripts/include/Time.lua")

--=================== Constants ===================--
--HUD Types
local HUD_NONE		= 0
local HUD_ICON 		= 1
local HUD_TEXT 		= 2
local HUD_BAR 		= 4

--Item Types
local LINKED_WITH_NADA	 = 0
local LINKED_WITH_HEALTH = 1
local LINKED_WITH_SUGAR  = 2
local LINKED_WITH_TIMER	 = 4
local LINKED_WITH_SCORE	 = 8

--Location Types
local LOCATION_CENTER		= 0
local LOCATION_NORTH 		= 1
local LOCATION_SOUTH 		= 2
local LOCATION_WEST  		= 4
local LOCATION_NORTH_WEST 	= 5
local LOCATION_SOUTH_WEST 	= 6
local LOCATION_EAST  		= 8
local LOCATION_NORTH_EAST 	= 9
local LOCATION_SOUTH_EAST 	= 10




--=================== UI Variables ===================--
local uiHeadingGeneral	= false
local uiHeadingLabel	= false
local uiHeadingData 	= false
displayPosString  		= "CENTER"

--Label Variables
hudLabelTypeString	= "NONE"
labelOffsetXMinus 	= false
labelOffsetX 		= 0
labelOffsetYMinus 	= false
labelOffsetY 		= 0
labelFontTypeString = "arial"
labelFontSize 		= 12
labelAnimString		= "x.lua"

--Data Variables
hudDataTypeString 	= "TEXT"
linkedWithString  	= "NOTHING"
dataOffsetXMinus 	= false
dataOffsetX 		= 0
dataOffsetYMinus 	= false
dataOffsetY 		= 0
dataFontSize		= 12
dataFontTypeString  = "arial"
--dataAnimString		= "x.lua" --this could be useful for animated bars
timeUpImageStr		= "x.lua"
timeUpPosX			= 0
timeUpPosY			= 0

--=================== In-Game Variables ===================--
--General HUD Variables
hudPosition     = nil

--Label Variables
hudLabelHasType	= HUD_NONE
labelPosition 	= nil
labelTextString = ""
labelFontObject	= nil
labelAnimation  = nil

--Animation Variables
hudDataHasType 		= HUD_TEXT
hudLinkedWith   	= LINKED_WITH_NADA
dataPosition 		= nil
dataFontObject		= nil
dataBarHeight		= 20
dataBarLength		= 100
haveDataBarBacking	= true
dataBarBackingSize	= 2
 --dataAnimation = nil --this could be useful for animated bars

 --count up or down
 timeTicksDown 		= false
 countDownMaxTime	= 60
 showTimeUpImage	= false
 timeUpImage 		= nil
 timeUpPosition		= nil

 --Window Width and Height
 windowWidth = 0
 windowHeight = 0

--time used to animate icon sprites
animationTime = 0

ui = {
	--General variables
	uiHeadingGeneral  	= { order = 1,  type = "boolean", label = "GENERAL SETTINGS:",				default = false },
	displayPosString  	= { order = 2,  type = "list",    label = "Where is the HUD positioned?",	default = "WEST", 	 values = { "CENTER", "NORTHWEST", "NORTH", "NORTHEAST", "WEST", "EAST", "SOUTHWEST", "SOUTH", "SOUTHEAST" } }, 

	--Label variables
	uiHeadingLabel	  	= { order = 10, type = "boolean", label = "LABEL SETTINGS:",				default = false },
	hudLabelTypeString	= { order = 11, type = "list",    label = "What is the label HUD Type?",  	default = "NONE",    values = { "NONE", "ICON", "TEXT" } },
	labelOffsetX 	  	= { order = 12, type = "number",  label = "Label X-axis offset", 			default = 0 },
	labelOffsetXMinus  	= { order = 13, type = "boolean", label = "Is label X offset negative?",	default = false },
	labelOffsetY 	  	= { order = 14, type = "number",  label = "Label Y-axis offset", 			default = 0 },
	labelOffsetYMinus  	= { order = 15, type = "boolean", label = "Is label Y offset negative?", 	default = false },

	labelTextString 	= { order = 21, type = "string",  label = "(Text Only) Label Text: ",		default = "Label: " },
	labelFontTypeString = { order = 22, type = "string",  label = "(Text Only) Label Font: ",		default = "arial" },
	labelFontSize    	= { order = 23, type = "number",  label = "(Text Only) Label Font Size:",	default = 12 },

	labelAnimString		= { order = 31, type = "anim",    label = "(Icon Only) Icon Image: ",		default = "x.lua" },

	--Data variables
	uiHeadingData	  	= { order = 40, type = "boolean", label = "DATA SETTINGS:",					default = false },
	hudDataTypeString	= { order = 41, type = "list",    label = "What is the data HUD Type?",  	default = "TEXT",    values = { "NONE", "TEXT", "BAR"  } },
	linkedWithString  	= { order = 42, type = "list",	  label = "Link to what variable?",			default = "NOTHING", values = { "NOTHING", "HEALTH", "SCORE", "SUGAR", "TIMER" } },
	dataOffsetX       	= { order = 43, type = "number",  label = "Data X-axis offset",				default = 0 },
	dataOffsetXMinus  	= { order = 44, type = "boolean", label = "Is data X offset negative?",		default = false },
	dataOffsetY    	  	= { order = 45, type = "number",  label = "Data Y-axis offset", 			default = 0 },
	dataOffsetYMinus  	= { order = 46, type = "boolean", label = "Is data Y Offset negative?",		default = false },

	dataFontTypeString  = { order = 51, type = "string",  label = "(Text Only) Data Font: ",		default = "arial" },
	dataFontSize    	= { order = 52, type = "number",  label = "(Text Only) Data Font Size:",	default = 12 },

	dataBarHeight		= { order = 61, type = "number",  label = "(Bar Only) Bar Height:",			default = 20 },
	dataBarLength		= { order = 62, type = "number",  label = "(Bar Only) Bar Length:",			default = 100 },
	haveDataBarBacking	= { order = 63, type = "boolean", label = "(Bar Only) Have Bar Background?",default = true },
	dataBarBackingSize 	= { order = 64, type = "number",  label = "(Bar Only) Bar Background Size:",default = 2 },
	timeTicksDown		= { order = 65, type = "boolean", label = "(Timer Only) Count Down?",		default = false },
	countDownMaxTime	= { order = 66, type = "number",  label = "If countdown, starting time?",	default = 60 },
	showTimeUpImage		= { order = 67, type = "boolean", label = "If countdown, show image at 0?",	default = false },
	timeUpImageStr		= { order = 68, type = "anim",    label = "If countdown, time up image? ",	default = "x.lua" },
	timeUpPosX	 	  	= { order = 69, type = "number",  label = "Time up image X Position",		default = 0 },
	timeUpPosY 		  	= { order = 70, type = "number",  label = "Time up image Y Position",		default = 0 },
}

function getHUDTypeFromString( hudTypeStr )

	if 		( hudTypeStr == "ICON" ) then

		return HUD_ICON

	elseif  ( hudTypeStr == "TEXT" ) then

		return HUD_TEXT

	elseif  ( hudTypeStr == "BAR" ) then

		return HUD_BAR

	else

		return HUD_NONE

	end
end

function getVariableLinkFromString( linkedWithStr )

	if 		( linkedWithStr == "HEALTH" ) then

		return LINKED_WITH_HEALTH

	elseif  ( linkedWithStr == "SUGAR" ) then

		return LINKED_WITH_SUGAR

	elseif  ( linkedWithStr == "TIMER" ) then

		return LINKED_WITH_TIMER

	elseif  ( linkedWithStr == "SCORE" ) then

		return LINKED_WITH_SCORE

	else 

		return LINKED_WITH_NADA

	end
end

function getHUDPositionOnScreen( screenPosStr )

	local hudPos = { x = 0, y = 0 }

	--Start with X position
	if 	   ( screenPosStr == "WEST" or screenPosStr == "NORTHWEST" or screenPosStr == "SOUTHWEST" ) then

		hudPos.x = 0

	elseif ( screenPosStr == "NORTH" or screenPosStr == "CENTER" or screenPosStr == "SOUTH" ) then

		hudPos.x = windowWidth * 0.5

	elseif ( screenPosStr == "EAST" or screenPosStr == "NORTHEAST" or screenPosStr == "SOUTHEAST" ) then

		hudPos.x = windowWidth - 150

	end

	--Then do Y position
	if 	   ( screenPosStr == "NORTH" or screenPosStr == "NORTHWEST" or screenPosStr == "NORTHEAST" ) then

		hudPos.y = 0

	elseif ( screenPosStr == "WEST" or screenPosStr == "CENTER" or screenPosStr == "EAST" ) then

		hudPos.y = windowHeight * 0.5

	elseif ( screenPosStr == "SOUTH" or screenPosStr == "SOUTHWEST" or screenPosStr == "SOUTHEAST" ) then

		hudPos.y = windowHeight

	end

	return hudPos

end

function getOffsetPositionFrom( startPosition, offsetX, minusXOffset, offsetY, minusYOffset )

	local offsetPos = { x = 0, y = 0 }

	if minusXOffset then
		offsetPos.x = startPosition.x - offsetX
	else
		offsetPos.x = startPosition.x + offsetX
	end
	
	if minusYOffset then
		offsetPos.y = startPosition.y - offsetY
	else
		offsetPos.y = startPosition.y + offsetY
	end

	return offsetPos
end

function removeCollision()
	rigidBody:setCollisionCategory( CollisionCategory_NONE )
	rigidBody:setCollisionMask( CollisionMask_NONE )
end


function init()
	removeCollision()

	--Turn off Base icon
	iconVisible = false

	--Object HUD is attached to may not always be on screen, so update always is necessary.
	updateAlways = true

	if ( g.session.gotWindowSize == nil ) then 
 		-- this part is executed once PER GAME, not between different levels
 		g.session.gotWindowSize = 0;
 		g.session.windowWidth = width()
 		g.session.windowHeight = height()
 		windowWidth = width()
 		windowHeight = height()
 	else
 		windowWidth = g.session.windowWidth
 		windowHeight = g.session.windowHeight
	end

	--Set HUD Types
	hudLabelHasType = getHUDTypeFromString( hudLabelTypeString )
	hudDataHasType  = getHUDTypeFromString( hudDataTypeString )
	hudLinkedWith	= getVariableLinkFromString( linkedWithString )

	--Set the positions for the HUD
	hudPosition 	= getHUDPositionOnScreen( displayPosString )
	labelPosition	= getOffsetPositionFrom( hudPosition, labelOffsetX,	labelOffsetXMinus, labelOffsetY, labelOffsetYMinus )
	dataPosition	= getOffsetPositionFrom( hudPosition, dataOffsetX, 	dataOffsetXMinus,  dataOffsetY,  dataOffsetYMinus  )
	timeUpPosition	= { x = timeUpPosX, y = timeUpPosY }

	--Setup icon
	labelAnimation	= ImageAnim( labelAnimString )
	timeUpImage 	= ImageAnim( timeUpImageStr  )

	--Setup fonts for text
	--labelFontSize   = g.math.clamp( labelFontSize, 1.0, 100.0 ) -- clamping is causing some issue, not sure what
	if ( labelFontObject == nil ) then
		labelFontObject = Font( labelFontTypeString, labelFontSize )
	end
	--dataFontSize    = g.math.clamp( dataFontSize, 1, 100 )
	if ( dataFontObject == nil ) then
		dataFontObject 	= Font( dataFontTypeString, dataFontSize )
	end

	if timeTicksDown then
		g.maxLevelTime = countDownMaxTime
	end
end

function update( dt )
	--Update animation time so that icons will animate properly
	getHUDPositionOnScreen()
	animationTime = animationTime + dt
end

function render( dt )
	local animationAngle = 0
	if ( showTimeUpImage and g.player.timeInLevel > g.maxLevelTime ) then
		timeUpImage:draw( animationTime, timeUpPosition.x, timeUpPosition.y, animationAngle, Image_COORDS_SCREEN_TOPLEFT )
	end
	--Render UI object label
	if ( hudLabelHasType == HUD_TEXT ) then

		drawLine( 0, 0, 0, 0, 1, 1, 1 )
		if ( labelFontObject ~= nil ) then
			labelFontObject:draw( labelPosition.x, labelPosition.y, labelTextString )
		end

	elseif ( hudLabelHasType == HUD_ICON ) then

		if ( labelAnimation ~= nil ) then
			labelAnimation:draw( animationTime, labelPosition.x, labelPosition.y, animationAngle, Image_COORDS_SCREEN )
		end

	end

	--Render UI object data
	drawLine( 0, 0, 0, 0, 1, 1, 1 )
	if ( hudDataHasType == HUD_TEXT ) then

		local dataText = ""

		if 	   ( hudLinkedWith == LINKED_WITH_HEALTH ) then

			dataText = g.tostring( g.player.health.current )

		elseif ( hudLinkedWith == LINKED_WITH_SUGAR ) then

			dataText = g.tostring( g.math.floor( g.player.maxSpeed.x ) )

		elseif ( hudLinkedWith == LINKED_WITH_TIMER ) then

			currentTime = 0

			if timeTicksDown then
				currentTime = g.maxLevelTime - g.player.timeInLevel	
			else
				currentTime = g.player.timeInLevel	
			end

			if currentTime < 0 then currentTime = 0 end
			dataText = rawTimeToString( currentTime )

		elseif ( hudLinkedWith == LINKED_WITH_SCORE ) then

			dataText = g.tostring( g.player.score )

		end

		if ( dataFontObject ~= nil ) then
			dataFontObject:draw( dataPosition.x, dataPosition.y, dataText )
		end

	elseif ( hudDataHasType == HUD_BAR ) then

		local dataRatio = 0.0
		local barColor	= { red = 0, green = 0, blue = 0, alpha = 1 }

		if 	   ( hudLinkedWith == LINKED_WITH_HEALTH ) then

			dataRatio = g.player.currentHealth / g.player.maxHealth

			if ( dataRatio < 0.2 ) then
				barColor.red = 1
			elseif ( dataRatio < 0.4 ) then
				barColor.red = 1
				barColor.green = 1
			else
				barColor.blue = 1
			end

		elseif ( hudLinkedWith == LINKED_WITH_SUGAR ) then

			dataRatio = ( g.player.maxSpeed.x - g.player.moveSpeed + 1 ) / ( g.player.moveSpeedCap - g.player.moveSpeed + 1 )

			if ( dataRatio < 0.5 ) then
				barColor.green = 1
			elseif ( dataRatio < 0.70 ) then
				barColor.green = 1
			else
				barColor.red = 1
			end

		else

			dataRatio = 0

		end

			local barUpperSide 	= dataPosition.y - ( dataBarHeight * 0.5 )
			local barLowerSide 	= barUpperSide + ( dataBarHeight * 2 ) - dataPosition.y -- do te multiplication times two minus data position because of GuildEd weirdness.
			local barLeftSide  	= dataPosition.x
			local barRightSide 	= barLeftSide + ( dataRatio * dataBarLength ) - dataPosition.x -- subtract dataPosition.x because of GuildEd weirdness.

			local backingColor	= { red = 1, green = 1, blue = 1, alpha = 1 }
			local backUpperSide	= barUpperSide - dataBarBackingSize
			local backLowerSide	= barLowerSide + dataBarBackingSize * 2
			local backLeftSide	= barLeftSide - dataBarBackingSize
			local backRightSide	= dataBarLength + dataBarBackingSize

			--draw the bar background
			fillRect( backLeftSide, backUpperSide, backRightSide, backLowerSide, backingColor.red, backingColor.green, backingColor.blue, backingColor.alpha )

			--draw the bar itself
			fillRect( barLeftSide, barUpperSide, barRightSide, barLowerSide, barColor.red, barColor.green, barColor.blue, barColor.alpha )

	end
end
{{< /code-block >}}
{{% /section %}}
