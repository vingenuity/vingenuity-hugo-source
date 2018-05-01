+++
title = "Player Physics"
subtitle = ""
Description = ""
Tags = []
languages = ["lua"]
project_base_name = "professor-cadbury"
+++
{{< vimeo id="119056652" class="video-container" >}}
{{% section class="section scrollspy" %}}
### Motivation
From the outset, we wanted our game to be a platformer focused on speed and agility. Thus, our player character has the ability to run, jump, wall jump, and wall slide. My primary focus during development was on making all of the physics for these actions "feel right."
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
GuildEd had a solid integration setup for its physics, but its collision system had some small issues. In particular, the detection for the 'on ground' state was glitchy, and there was no detection for whether the player was touching a wall or not.

Fortunately, GuildEd did provide a very useful raytracing function, which I used for my solution. I created a pair of raytracing 'sensors' on the bottom and both sides of the character. As you can see in the video, they are designed to be very tight to the collision box and shoot in both directions. If either one of the raycasts impacts the environment for that side of the character, it sets the 'on ground' or 'on wall' state. This setup worked well enough to make it into the final game build.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Wall Sliding Detection
{{< code-block lua >}}
--Wall-Sliding
local westSideRay = nil
local eastSideRay = nil
local slightlyWestOfObject   = 0
local slightlyEastOfObject   = 0
local verticalColliderStart  = 0
local verticalColliderLength = 0
timeDirectionHeldWhileSliding = 0
directionHeldWhileSliding = false

function isNextToWall()
	slightlyInsideWest	= rigidBody:posX() - ( 0.498 * iconWidthInWorldUnits() )
	slightlyOutsideWest	= rigidBody:posX() - ( 0.508 * iconWidthInWorldUnits() )

	slightlyInsideEast	= rigidBody:posX() + ( 0.498 * iconWidthInWorldUnits() )
	slightlyOutsideEast	= rigidBody:posX() + ( 0.508 * iconWidthInWorldUnits() )

	colliderUpperPoint	= rigidBody:posY() - ( 0.49 * iconHeightInWorldUnits() )
	colliderLowerPoint	= rigidBody:posY() + ( 0.49 * iconHeightInWorldUnits() )

	westSideDownRay = RayB.new( slightlyInsideWest, colliderUpperPoint, slightlyOutsideWest, colliderLowerPoint )
	westSideUpRay 	= RayB.new( slightlyInsideWest, colliderLowerPoint, slightlyOutsideWest, colliderUpperPoint )
	eastSideDownRay = RayB.new( slightlyInsideEast, colliderUpperPoint, slightlyOutsideEast, colliderLowerPoint )
	eastSideUpRay 	= RayB.new( slightlyInsideEast, colliderLowerPoint, slightlyOutsideEast, colliderUpperPoint )

	if ( westSideDownRay:IsCollidingWithWorld() or westSideUpRay:IsCollidingWithWorld() or eastSideDownRay:IsCollidingWithWorld() or eastSideUpRay:IsCollidingWithWorld() ) then
		return true
	end

	return false
end
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Grounding Detection
{{< code-block lua >}}

function isOnGround()

	slightlyInsideBottom  = rigidBody:posY() + ( 0.496 * iconHeightInWorldUnits() )
	slightlyOutsideBottom = rigidBody:posY() + ( 0.506 * iconHeightInWorldUnits() )

	colliderWestPoint	= rigidBody:posX() - ( 0.49 * iconWidthInWorldUnits() )
	colliderEastPoint	= rigidBody:posX() + ( 0.49 * iconWidthInWorldUnits() )

	footWestRay = RayB.new( colliderEastPoint, slightlyInsideBottom, colliderWestPoint, slightlyOutsideBottom )
	footEastRay = RayB.new( colliderWestPoint, slightlyInsideBottom, colliderEastPoint, slightlyOutsideBottom )

	if ( footEastRay:IsCollidingWithWorld() or footWestRay:IsCollidingWithWorld() ) then
		return true
	end

	return false
end
{{< /code-block >}}
{{% /section %}}
