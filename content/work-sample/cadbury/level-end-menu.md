+++
title = "Level End Menu"
subtitle = ""
Description = ""
Tags = []
languages = ["lua"]
project_base_name = "professor-cadbury"
+++
{{< vimeo id="119056653" class="video-container" >}}
{{% section class="section scrollspy" %}}
### Motivation
At the end of each level, our team wanted to give the player a score in order to reinforce that speed and collection were important. We decided that the best way to implement this idea was to have a separate "end level" that would present the score.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
My focus in the design of this class was flexibility. This class was created midway through the project, and I knew we were going to have to make changes to this menu over time.

There are four main elements to the score menu: the title bar, the score table, a star rating, and a short poem based on that rating. Each of these four elements, as well as each element inside the table, can have its font, font size, position, and icons changed independently. We didn't end up using some of this flexibility in the final product, bug having it available was helpful.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### End-of-Level Menu
{{< code-block lua >}}
--JS: File load and execution priority
priority = -1000

dofile( self, APP_PATH .. "scripts/include/AnimationBase.lua")
dofile( self, APP_PATH .. "scripts/include/Time.lua")

-------- UI Variables --------
--General
displayStartX	= 230
displayStartY	= 140
backgroundStr	= "x.lua"

--Title
titleFontString	= "arial"
titleFontSize 	= 24
titleOffsetX 	= 400
titleOffsetY	= 140

--Table
tableFontString = "arial"
tableFontSize 	= 12
tableOffsetX	= 150
tableOffsetY	= 180
tableSpacingX1	= 40
tableSpacingX2	= 100
tableSpacingX3	= 80
tableSpacingX4	= 80
tableSpacingY	= 40
tableRowIcoStr1	= "x.lua"
tableRowIcoStr2	= "x.lua"
tableRowIcoStr3	= "x.lua"

--Total Score
totalFontString = "arial"
totalFontSize	= 30
totalOffsetX	= 175
totalOffsetY	= 300

--Ratings
ratingFontStr	= "arial"
ratingFontSize 	= 14
rateTextOffsetX	= 500
rateTextOffsetY	= 300
rateAnimOffsetX	= 550
rateAnimOffsetY	= 200
rateYGapOffset	= 20
ratingAnimStr1	= "x.lua"
ratingAnimStr2	= "x.lua"
ratingAnimStr3	= "x.lua"

-------- In-game Variables --------
--General
displayPosition	= nil
backgroundAnim	= nil

--Title
titleTextString = "Title:"
titleFontObject = nil
titlePosition 	= nil

--Table
tableFontObject = nil
tablePosition 	= nil
tableRow1Icon	= nil
tableRow2Icon	= nil
tableRow3Icon	= nil

--Total Score
totalTextString = "Final Score: "
totalFontObject	= nil
totalPosition	= nil

--Ratings
ratingFontObj	= nil
ratingAnimPos	= nil
ratingTextPos	= nil
ratingAnim1 	= nil
ratingAnim2 	= nil
ratingAnim3 	= nil
ratingText11 	= "Rating Haiku:"
ratingText12 	= "You seem new at this"
ratingText13 	= "You made too many mistakes"
ratingText14 	= "Play level again"
ratingText21 	= "Rating Haiku:"
ratingText22 	= "You played this quite well"
ratingText23 	= "It was a skillful display"
ratingText24 	= "There is more to learn"
ratingText31 	= "Rating Haiku:"
ratingText32 	= "Your play was the best"
ratingText33 	= "Your actions are without peer"
ratingText34 	= "Your title: master"
scoreForRating2	= 20
scoreForRating3	= 35

--Row Enablers
showTitle	 	= true
showTableHeads 	= true
showPlayerCoins = true
showTargetTime	= true
showPlayerTime  = true
showTotalScore	= true
showScoreRating = true

--Multipliers
coinMultiplier	= 1
timeMultiplier 	= 1

--Score Components
playerCoins		= 0
playerCoinScore	= 0
playerTime 		= 0
targetTime 		= 60
playerTimeScore	= 0
totalScore		= 0

--Distance
displayDistance	= 20

--Animation
animationAngle 	= 0
animationTime 	= 0

scoreSaveName	= "score"

ui = {
	--General
	uiHeadingMain	= { order =  1,  type = "boolean", label = "GENERAL SETTINGS:",				default = false 							},
	displayStartX	= { order =  2,  type = "number",  label = "Display Top Left Corner X:",	default = 230 								},
	displayStartY	= { order =  3,  type = "number",  label = "Display Top Left Corner Y:",	default = 140 								},
	backgroundStr	= { order =  4,  type = "anim",    label = "Background Image:",				default = "x.lua"							},
	displayDistance	= { order =  5,  type = "number",  label = "Rendering Distance Threshold:",	default = 20								},
	scoreSaveName	= { order =  6,  type = "string",  label = "Save Session Variable:",		default = "score"							},

	--Title
	uiHeadingTitle	= { order = 10,  type = "boolean", label = "TITLE SETTINGS:",				default = false 							},
	titleTextString = { order = 11,  type = "string",  label = "Title Text:",					default = "Title:" 							},
	titleFontString = { order = 12,  type = "string",  label = "Title Font:",					default = "arial" 							},
	titleFontSize	= { order = 13,  type = "number",  label = "Title Font Size:",				default = 20 								},
	titleOffsetX	= { order = 14,  type = "number",  label = "Title X Offset:",				default = 400								},
	titleOffsetY	= { order = 15,  type = "number",  label = "Title Y Offset:",				default = 140 								},

	--Table
	uiHeadingTable	= { order = 20,  type = "boolean", label = "TABLE SETTINGS:",				default = false 							},
	tableFontString	= { order = 21,  type = "string",  label = "Table Font:",					default = "arial"							},
	tableFontSize	= { order = 22,  type = "number",  label = "Table Font Size:",				default = 12 								},
	tableOffsetX	= { order = 23,  type = "number",  label = "Table X Offset:",				default = 150 								},
	tableOffsetY	= { order = 24,  type = "number",  label = "Table Y Offset:",				default = 180 								},
	tableSpacingX1	= { order = 25,  type = "number",  label = "Table X Spacing(Icon Column):",	default = 40  								},
	tableSpacingX2	= { order = 26,  type = "number",  label = "Table X Spacing(2nd Column):",	default = 100 								},
	tableSpacingX3	= { order = 27,  type = "number",  label = "Table X Spacing(3rd Column):",	default	= 80  								},
	tableSpacingX4	= { order = 28,  type = "number",  label = "Table X Spacing(4th Column):",	default	= 80  								},
	tableSpacingY	= { order = 29,  type = "number",  label = "Table Y Spacing:",				default = 40 								},
	tableRowIcoStr1	= { order = 30,  type = "anim",    label = "Table Coin Animation:",			default = "x.lua"							},
	tableRowIcoStr2	= { order = 31,  type = "anim",    label = "Table Target Time Animation:",	default = "x.lua"							},
	tableRowIcoStr3	= { order = 32,  type = "anim",    label = "Table Player Time Animation:",	default = "x.lua"							},

	--Data	
	uiHeadingData	= { order = 35,  type = "boolean", label = "DATA SETTINGS:",				default = false 							},
	coinMultiplier	= { order = 36,  type = "number",  label = "Score Multiplier (Coins):",		default = 1 								},
	timeMultiplier	= { order = 37,  type = "number",  label = "Score Multiplier (Time):",		default = 1 								},
	targetTime 		= { order = 38,  type = "number",  label = "Target Time (Seconds):",		default = 60 								},

	--Total
	totalTextString = { order = 40,  type = "string",  label = "Total Score Prefix Text:",		default = "Final Score: "					},
	totalFontString = { order = 41,  type = "string",  label = "Total Score Font:",				default = "arial"							},
	totalFontSize	= { order = 42,  type = "number",  label = "Total Score Font Size:",		default = 30 								},
	totalOffsetX	= { order = 43,  type = "number",  label = "Total Score X Offset:",			default = 175 								},
	totalOffsetY	= { order = 44,  type = "number",  label = "Total Score Y Offset:",			default = 300 								},

	--Ratings
	uiHeadingRate	= { order = 50,  type = "boolean", label = "RATINGS (Low to High):",		default = false 							},
	ratingFontStr 	= { order = 51,  type = "string",  label = "Rating Font:",					default = "arial"							},
	ratingFontSize	= { order = 52,  type = "number",  label = "Rating Font Size:",				default = 14 								},
	rateTextOffsetX	= { order = 53,  type = "number",  label = "Rating Text X Offset:",			default = 500 								},
	rateTextOffsetY	= { order = 54,  type = "number",  label = "Rating Text Y Offset:",			default = 300 								},
	rateAnimOffsetX = { order = 55,  type = "number",  label = "Rating Anim X Offset:",			default = 550 								},
	rateAnimOffsetY = { order = 56,  type = "number",  label = "Rating Anim Y Offset:",			default = 200 								},
	rateYGapOffset	= { order = 57,  type = "number",  label = "Rating Y Gap Offset:",			default = 20								},

	ratingAnimStr1	= { order = 61,  type = "anim",    label = "Low Rating Animation:",			default = "x.lua"							},
	ratingText11 	= { order = 62,  type = "string",  label = "Low Rating Text 1:",			default = "Rating Haiku:"					},
	ratingText12 	= { order = 63,  type = "string",  label = "Low Rating Text 2:",			default = "You seem new at this"			},
	ratingText13 	= { order = 64,  type = "string",  label = "Low Rating Text 3:",			default = "You made too many mistakes"		},
	ratingText14 	= { order = 65,  type = "string",  label = "Low Rating Text 4:",			default = "Play level again"				},

	scoreForRating2	= { order = 71,  type = "number",  label = "Medium Score Threshold:",		default = 20 								},
	ratingAnimStr2	= { order = 72,  type = "anim",    label = "Medium Rating Animation:",		default = "x.lua"							},
	ratingText21 	= { order = 73,  type = "string",  label = "Medium Rating Text 1:",			default = "Rating Haiku:"					},
	ratingText22 	= { order = 74,  type = "string",  label = "Medium Rating Text 2:",			default = "You played this quite well"		},
	ratingText23 	= { order = 75,  type = "string",  label = "Medium Rating Text 3:",			default = "It was a skillful display"		},
	ratingText24 	= { order = 76,  type = "string",  label = "Medium Rating Text 4:",			default = "There is more to learn"			},

	scoreForRating3	= { order = 81,  type = "number",  label = "Best Rating Threshold:",		default = 35 								},
	ratingAnimStr3	= { order = 82,  type = "anim",    label = "Best Rating Animation:",		default = "x.lua"							},
	ratingText31	= { order = 83,  type = "string",  label = "Best Rating Text 1:",			default = "Rating Haiku:"					},
	ratingText32 	= { order = 84,  type = "string",  label = "Best Rating Text 2:",			default = "Your play was the best"			},
	ratingText33 	= { order = 85,  type = "string",  label = "Best Rating Text 3:",			default = "Your actions are without peer"	},
	ratingText34 	= { order = 86,  type = "string",  label = "Best Rating Text 4:",			default = "Your title: master"				},

	--Row Enabling
	uiHeadingEnable	= { order = 90,  type = "boolean", label = "ROW DISABLE SETTINGS:",			default = false 							},
	showTitle		= { order = 91,  type = "boolean", label = "Show Title?",					default = true 								},
	showTableHeads	= { order = 92,  type = "boolean", label = "Show Table Headings?",			default = true 								},
	showPlayerCoins	= { order = 93,  type = "boolean", label = "Show Player Coins?",			default = true 								},
	showTargetTime	= { order = 94,  type = "boolean", label = "Show Target Time?",				default = true 								},
	showPlayerTime	= { order = 95,  type = "boolean", label = "Show Player's Time?",			default	= true 								},
	showTotalScore	= { order = 96,  type = "boolean", label = "Show Total Score?",				default = true 								},
	showScoreRating	= { order = 97,  type = "boolean", label = "Show Rating for Player?",		default = true 								}
}

function removeCollision()
	if ( rigidBody ~= nil ) then
		g.physics:remove( rigidBody )
	end
	rigidBody = g.physics:createBox( x, y, RigidBody_STATIC, iconW/pixelsPerUnit, iconH/pixelsPerUnit, 0 )
	rigidBody:setCollisionCategory( CollisionCategory_NONE )
	rigidBody:setCollisionMask( CollisionMask_NONE )
end

function init()

	removeCollision()

	--Turn off Base icon
	iconVisible = false

	updateAlways = false

	--Initialize animations first ( we need their sizes during position creation )
	backgroundAnim	= initializeAnimationOrReturnNil( backgroundStr )
	ratingAnim1 	= initializeAnimationOrReturnNil( ratingAnimStr1 )
	ratingAnim2 	= initializeAnimationOrReturnNil( ratingAnimStr2 )
	ratingAnim3 	= initializeAnimationOrReturnNil( ratingAnimStr3 )
	tableRow1Icon	= initializeAnimationOrReturnNil( tableRowIcoStr1 )
	tableRow2Icon	= initializeAnimationOrReturnNil( tableRowIcoStr2 )
	tableRow3Icon	= initializeAnimationOrReturnNil( tableRowIcoStr3 )

	--Now figure out our display positions
	displayPosition = { x = displayStartX, 					 y = displayStartY 					 }
	titlePosition 	= { x = displayStartX + titleOffsetX, 	 y = displayStartY + titleOffsetY 	 }
	tablePosition 	= { x = displayStartX + tableOffsetX, 	 y = displayStartY + tableOffsetY 	 }
	totalPosition	= { x = displayStartX + totalOffsetX, 	 y = displayStartY + totalOffsetY 	 }
	ratingAnimPos 	= { x = displayStartX + rateAnimOffsetX, y = displayStartY + rateAnimOffsetY }
	ratingTextPos 	= { x = displayStartX + rateTextOffsetX, y = displayStartY + rateTextOffsetY }

	--Finish it up by initializing the fonts
	titleFontObject = Font( titleFontString, titleFontSize )
	tableFontObject = Font( tableFontString, tableFontSize )
	totalFontObject = Font( totalFontString, totalFontSize )
	ratingFontObj	= Font( ratingFontStr, 	 ratingFontSize )

end

function getDistanceToPlayer()
	playerLocation 	= { x = g.player.rigidBody:posX(), 	y = g.player.rigidBody:posY() }
	ourLocation 	= { x = rigidBody:posX(), 			y = rigidBody:posY() }

	return ( ( ourLocation.x - playerLocation.x ) * ( ourLocation.x - playerLocation.x ) ) + ( ( ourLocation.y - playerLocation.y ) * ( ourLocation.y - playerLocation.y ) )
end

function update( dt )

	if ( getDistanceToPlayer() < ( displayDistance * displayDistance ) ) then
		g.player.timerRunning = false
	else
		g.player.timerRunning = true
	end

	if ( showPlayerCoins ) then
		playerCoins = g.player.score
		playerCoinScore = playerCoins * coinMultiplier
	end

	if ( showPlayerTime ) then
		playerTime  = g.player.timeInLevel
		playerTimeScore = g.math.floor( ( targetTime - playerTime ) * timeMultiplier )
	end

	if ( showTotalScore ) then
		totalScore = playerCoinScore + playerTimeScore
		SetSessionVariable( scoreSaveName, totalScore )
	end

	animationTime = animationTime + dt

end

function render( dt )

	if ( getDistanceToPlayer() > ( displayDistance * displayDistance ) ) then
		return
	end

	if ( backgroundAnim ~= nil ) then
		backgroundAnim:draw( animationTime, displayPosition.x, displayPosition.y, animationAngle, Image_COORDS_SCREEN_TOPLEFT )
	end

	if ( showTitle ) then
		titleFontObject:draw( titlePosition.x, titlePosition.y, titleTextString )
	end

	rowPositionY = tablePosition.y
	if ( showTableHeads ) then
		renderTableRow( tableFontObject, tablePosition.x, rowPositionY, nil, "", "Collected", " Multiplier", "Score" )
	end

	if ( showPlayerCoins ) then
		rowPositionY = rowPositionY + tableSpacingY
		renderTableRow( tableFontObject, tablePosition.x, rowPositionY, tableRow1Icon, "Coins:", g.tostring( playerCoins ), g.tostring( coinMultiplier ), g.tostring( playerCoinScore ) )
	end

	if ( showTargetTime ) then
		rowPositionY = rowPositionY + tableSpacingY
		renderTableRow( tableFontObject, tablePosition.x, rowPositionY, tableRow2Icon, "Target Time:", rawTimeToString( targetTime ), " ", "" )
	end

	if ( showPlayerTime ) then
		rowPositionY = rowPositionY + tableSpacingY
		renderTableRow( tableFontObject, tablePosition.x, rowPositionY, tableRow3Icon, "Time:", rawTimeToString( targetTime - playerTime ), g.tostring( timeMultiplier ), g.tostring( playerTimeScore ) )
	end

	if ( showTotalScore ) then
		totalFontObject:draw( totalPosition.x, totalPosition.y, totalTextString .. g.tostring( totalScore ) )
	end

	if ( showScoreRating ) then
		
		if ( totalScore < scoreForRating2 ) then

			if ( ratingAnim1 ~= nil ) then
				ratingAnim1:draw( animationTime, ratingAnimPos.x, ratingAnimPos.y, animationAngle, Image_COORDS_SCREEN_TOPLEFT )
			end
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y, 							ratingText11 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + rateYGapOffset, 			ratingText12 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 2 *  rateYGapOffset ), ratingText13 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 3 *  rateYGapOffset ), ratingText14 )

		elseif ( totalScore < scoreForRating3 ) then

			if ( ratingAnim2 ~= nil ) then
				ratingAnim2:draw( animationTime, ratingAnimPos.x, ratingAnimPos.y, animationAngle, Image_COORDS_SCREEN_TOPLEFT )
			end
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y, 							ratingText21 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + rateYGapOffset, 			ratingText22 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 2 *  rateYGapOffset ), ratingText23 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 3 *  rateYGapOffset ), ratingText24 )

		else

			if ( ratingAnim3 ~= nil ) then
				ratingAnim3:draw( animationTime, ratingAnimPos.x, ratingAnimPos.y, animationAngle, Image_COORDS_SCREEN_TOPLEFT )
			end

			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y, 							ratingText31 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + rateYGapOffset, 			ratingText32 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 2 *  rateYGapOffset ), ratingText33 )
			ratingFontObj:draw( ratingTextPos.x, ratingTextPos.y + ( 3 *  rateYGapOffset ), ratingText34 )

		end

	end

end

function renderTableRow( fontObject, rowStartX, rowStartY, leftIconAnimation, leadingString, rawScoreString, multiplierString, multipliedScoreString )
	
	drawPositionX = rowStartX
	if ( leftIconAnimation ~= nil ) then
		leftIconAnimation:draw( animationTime, drawPositionX, rowStartY, animationAngle, Image_COORDS_SCREEN )
	end

	drawPositionX = rowStartX + tableSpacingX1
	fontObject:draw( drawPositionX, rowStartY - 10, leadingString )

	drawPositionX = drawPositionX + tableSpacingX2
	fontObject:draw( drawPositionX, rowStartY - 10, rawScoreString )

	drawPositionX = drawPositionX + tableSpacingX3
	--If the first character is a space, don't draw the multiplier. Instead, draw the string without the space.
	if ( multiplierString:sub( 1, 1 ) ~= " ") then
		fontObject:draw( drawPositionX, rowStartY - 10, "x" .. multiplierString )
	else
		fontObject:draw( drawPositionX, rowStartY - 10, multiplierString:sub( 2 ) )
	end

	drawPositionX = drawPositionX + tableSpacingX4
	fontObject:draw( drawPositionX, rowStartY - 10, multipliedScoreString )
end
{{< /code-block >}}
{{% /section %}}