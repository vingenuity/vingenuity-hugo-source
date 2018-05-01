+++
title = "Scarab Gun"
subtitle = ""
Description = ""
Tags = []
languages = ["unrealscript"]
project_base_name = "akhet"
file_links = ["https://github.com/vingenuity/akhet-source/blob/master/Unrealscript/Classes/AK_Weapon_ScarabGun.uc"]
+++
{{< vimeo id="118780095" class="video-container" >}}
{{% section class="section scrollspy" %}}
### Motivation
When we came up with the design for this game, we wanted to create futuristic weapons that had interesting Egyptian designs. One idea that we had was a gun that shot deadly scarabs, inspired by the movie The Mummy.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
The Scarab Gun needed to fulfill two roles for our game. First, it needed to be our shotgun weapon. Second, it was to fulfill our need for a zoning weapon, so it also needed to place traps. I wanted both of these functions to have great gameplay feel.

For the primary fire mode, the initial spread is a normal shotgun blast like what comes out of the UT3's scattergun. However, on each ensuing update after the projectiles are released, each projectile generates a random deviation and moves in that direction. This gives the Scarab Gun's blasts a "skittering" buglike motion, which is exactly what I wanted.

For the secondary fire mode, we decided to create particle swarms when the projectile hits the ground. These are essentially a large particle emitter on top of a collision volume that actually causes the damage effects. Finally, when a player enters the swarm, they begin to take damage over time, and the swarm particle effect is transferred to them to indicate this.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Weapon Class
{{< code-block unrealscript >}}
class AK_Weapon_ScarabGun extends AK_Weapon_Base;

var float shotSpreadConeAngle;
var float burstTimer;
var float burstTime;
var int currentBurstCount;
var int burstCount;

//--------------------------------------------- Firing Modes -----------------------------------------------//
simulated function CustomFire()
{
	local int offsetY, offsetZ;
   	local vector positionWhereWeaponFired;
   	local Rotator instigatorAimRotation;
   	local vector instigatorAimDirectionX, instigatorAimDirectionY, instigatorAimDirectionZ;
	local class< Projectile > projectileClass;

	local Projectile firedProjectile;
	local vector randomizedYVector, randomizedZVector;

	IncrementFlashCount();

	if (Role == ROLE_Authority)
	{
		// fire position is where the projectile will be spawned
		positionWhereWeaponFired = GetPhysicalFireStartLoc();

		// get direction our instigator is aiming
		instigatorAimRotation = GetAdjustedAim( positionWhereWeaponFired );
		GetAxes( instigatorAimRotation, instigatorAimDirectionX, instigatorAimDirectionY, instigatorAimDirectionZ );

		// get the projectile we are firing 
		projectileClass = GetProjectileClass();

		for ( offsetZ = -1; offsetZ <= 1; ++offsetZ )
		{
			for ( offsetY = -1; offsetY <= 1; ++offsetY )
			{
				firedProjectile = Spawn( projectileClass, /*ownerOfSpawnedActor*/, /*stringNameOfSpawnedActor*/, positionWhereWeaponFired, /*rotationOfSpawnedActor*/, /*actorTemplateForSpawnedActor*/, /*boolShouldSpawnFailIfColliding*/);
				
				//Offset the projectile's direction by a set amount
				if( firedProjectile != None )
				{
					//Set Projectile's direction to the player's direction plus a little bit of randomness because BUG BULLETS
					randomizedYVector = ( 0.2 + 0.8 * FRand() ) * shotSpreadConeAngle * offsetY * instigatorAimDirectionY;
					randomizedZVector = ( 0.2 + 0.8 * FRand() ) * shotSpreadConeAngle * offsetZ * instigatorAimDirectionZ;

					firedProjectile.Init( instigatorAimDirectionX + randomizedYVector + randomizedZVector );
				}
			}
	    }
	}
}

//--------------------------------------------------------------------------------------------------------
simulated function Projectile ProjectileFire()
{
	local vector					positionWhereWeaponFired;
	local AK_Projectile_ScarabNest  SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		positionWhereWeaponFired = GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn( class'AK_Projectile_ScarabNest',,, positionWhereWeaponFired );
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector( GetAdjustedAim( positionWhereWeaponFired ) ) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}



//--------------------------------------------------------------------------------------------------------
DefaultProperties
{
	localizationSection = "AK_Weapon_ScarabGun"
	
	CrosshairImage=Texture2D'AK_hud.AK_HUD_Reticles'
	CrossHairCoordinates=( U=0, V=0, UL=256, VL=256 )

	//Key to press to switch to weapon
	InventoryGroup=3 

	//---------------------------- Firing Mode ----------------------------//
	shotSpreadConeAngle = 0.08				//JL: Changed from 0.1
	WeaponFireTypes(0)=EWFT_Custom
	WeaponProjectiles(0)=class'AK_Projectile_Scarab'
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(1)=class'AK_Projectile_ScarabNest'

	
	WeaponFireSnd[0] = SoundCue'AK_Weapon_Sounds.AK_Weap_Scarab.AK_Weap_ScarabFire_Cue' //This is the sound of the gun firing
	WeaponFireSnd[1] = SoundCue'AK_Weapon_Sounds.AK_Weap_Scarab.AK_Weap_ScarabFire_Cue' //This is the sound of the gun firing

	//---------------------------- Ammunition ----------------------------//
	ShotCost(0)=1
	ShotCost(1)=3

	AmmoCount=12
	LockerAmmoCount=12
	MaxAmmoCount=12
	burstCount = 1
	burstTime = 0.3
	maxAmmoRechargedPerSecond = 2
	secondsBeforeStartingRecharge = 3
	bAutoCharge=true

	FireInterval(0)=+1.2                                 
	FireInterval(1)=+0.7


	//---------------------------- Appearance ----------------------------//
	// Mesh and animations used in player's view
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'AK_ScarabGun.Meshes.AK_Scarabgun_Mesh_01'
		AnimSets(0)=AnimSet'AK_ScarabGun.AK_ScarabGun_ANIMSET_01'
		Animations=MeshSequenceA
		Translation = (X=70.0,Y=25.0,Z=-30.0)
		Rotation=(Yaw=-16384)
		Scale= 2.5
		FOV=60.0
	End Object

	TeamMaterials(0) = MaterialInstanceConstant'AK_ScarabGun.Textures.AK_ScarabGun_MAT_Ra_INST'
	TeamMaterials(1) = MaterialInstanceConstant'AK_ScarabGun.Textures.AK_ScarabGun_MAT_Anubis_INST'

	//X = how far down the barrel ( positive = out of the screen )
	//Y = where it is spawned left/right ( positive = right )
	//Z = where it is spawned up/down ( positive = up )
	FireOffset = ( X = 7, Y = 12, Z = -5.0 )
	PlayerViewOffset=(X=16.0,Y=-5,Z=-3.0)

	WeaponFireAnim(0)=WeaponFire
	WeaponFireAnim(1)=WeaponAltFire

	InstantHitDamage(0)=100
	InstantHitDamage(1)=100
	InstantHitDamageTypes(0)=class'AK_DamageType_ScarabShot'
	InstantHitDamageTypes(1)=class'AK_DamageType_Jar'

	//Mesh and animations used in 3rd person view
	AttachmentClass = class'AK_Attachment_ScarabGun'

	MuzzleFlashSocket=Muzzle
	MuzzleFlashPSCTemplate=ParticleSystem'AK_Particle.Muzzle_Flashes.AK_GenericMuzzleFlash_PS_01'
	MuzzleFlashAltPSCTemplate=ParticleSystem'AK_Particle.Muzzle_Flashes.AK_GenericMuzzleFlash_PS_01'
	// Mesh used in the inventory pickup zone
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'AK_ScarabGun.Meshes.AK_Scarabgun_Mesh_01'
	End Object
	PivotTranslation = ( Y = 10.0 )
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Primary Projectile
{{< code-block unrealscript >}}
class AK_Projectile_Scarab extends UTProjectile;

var vector initialFlightVector;
var float timeSinceLaunch;

function Init(vector Direction)
{
	timeSinceLaunch = 0.0;
	SetRotation(rotator(Direction));
	initialFlightVector = Direction;
	Velocity = Speed * Direction;
	Acceleration = AccelRate * Normal(Velocity);
}

//Every time we get new time, move the projectile a little bit, to simulate the scarabs "flying."
simulated function Tick(float DeltaTime)
{
	local vector newFlightVector;

	timeSinceLaunch += DeltaTime;
	if( timeSinceLaunch < 0.1 )
	{
		initialFlightVector = Normal( Velocity );
		return;
	}

	newFlightVector.X = initialFlightVector.X;
	newFlightVector.Y = initialFlightVector.Y * 2 * FRand();
	newFlightVector.Z = initialFlightVector.Z * 2 * FRand();

	Velocity = Speed * newFlightVector;
}

DefaultProperties
{
	Speed=2500 						//DH: Changed from 1400
	MaxSpeed=5000					//DH: Changed from 5000
	AccelRate=1000 					//DH: Changed from 3000

	MyDamageType = class'AKHET.AK_DamageType_ScarabShot'
	Damage=12						//DH: Changed from 26
	DamageRadius=0
	MomentumTransfer=0

	ProjFlightTemplate=ParticleSystem'AK_WeaponParticles.Scarab_Bullet.AK_ScarabBullet_PS_01'
	ProjExplosionTemplate=ParticleSystem'AK_Particle.ImpactParticle.AK_BulletImpact_PS_01'
	LifeSpan=3.0

	AmbientSound = SoundCue'AK_Weapon_Sounds.AK_Weap_Scarab.AK_Weap_ScarabPri_Cue' //XS:this is the scarab primary projectile sound. 

	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=false
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Damage and Effects
{{< code-block unrealscript >}}
simulated function SwarmWithScarabs()
{
	SetTimer( secondsBetweenSwarmDamage, true, 'SwarmDamageOverTime' );
	timeSinceSwarmHitSeconds = 0;

	WorldInfo.MyEmitterPool.SpawnEmitter(
		ParticleSystem'AK_Particle.PawnSwarm',  //Spawn the swarm emitter
		self.Location, 							//at our position
		rot( 0, 0, 0 ),							//with normal rotation
		self ); 								//and attach it to us in case we move
}

function SwarmDamageOverTime()
{
	local float damageThisTick;
	local Controller damageInstigator;
	local vector momentumFromHit;

	damageThisTick = swarmDamagePerSecond * secondsBetweenSwarmDamage;
	damageInstigator = None; //This ideally should come from the original shooter.
	momentumFromHit = vect( 0, 0, 0 ); //Bugs are too small to give momentum!
	TakeDamage( damageThisTick, damageInstigator, self.location, momentumFromHit, class 'UTDmgType_Burning' );

	timeSinceSwarmHitSeconds += secondsBetweenSwarmDamage;
	if( timeSinceSwarmHitSeconds >= swarmLifetimeSeconds )
		ClearTimer( 'SwarmDamageOverTime' );
}
{{< /code-block >}}
{{% /section %}}
