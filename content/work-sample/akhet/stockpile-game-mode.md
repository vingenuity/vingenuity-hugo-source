+++
title = "Stockpile Game Mode"
subtitle = ""
date = 2014-04-28
Description = ""
Tags = []
languages = ["unrealscript"]
project_base_name = "akhet"
file_links = ["https://github.com/vingenuity/akhet-source/blob/master/Unrealscript/Classes/AK_Game.uc"]
+++
{{< vimeo id="118780465" class="video-container" >}}
{{% section class="section scrollspy" %}}
### Motivation
In our second Team Game Project, teams were required to make some variant of the Capture the Flag gametype. We prototyped a few different modes and ultimately decided that the classic Stockpile game mode would work best for our game.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
The stockpile game mode logic is split mainly across three classes: the game class, the flag class and the score zone class.
The game class manages the game timer, scoring timer and victory conditions for the game, but knows nothing about how points are scored.
The flag class manages the core gameplay, including attaching itself to the flag carriers and determining when the flag is in the correct location to score.
The score zone class mostly handles the visual effects that occur when the flag is placed and/or scores, but also functions as an attachable actor for the flag.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Game Mode Class
{{< code-block unrealscript >}}
`define GetAll(Class, ListVar, IterVar) ForEach AllActors(class'`Class', `IterVar) { `ListVar.AddItem(`IterVar); }

class AK_Game extends UTCTFGame;

var const int NUMBER_OF_FLAGS;
var const int NUMBER_OF_SCORE_ZONES;

var AK_Game_ScoreZone scoreZones[ 2 ];

//"States" of the game
var bool gameHasStarted;
var bool gameIsRestarting;
var float secondsToWaitBeforeRestartingGame;

//Stockpile timers
var int timeBetweenScoresSeconds;
var int secondsBeforeFlagResets;

var int defaultNumberOfScoresToWin;

//--------------------------------------------- Clocks and Timers ---------------------------------------------//
function Timer()
{
	local int i;

	if( !gameHasStarted || gameIsRestarting )
		return;


	if( AK_GameReplicationInfo( GameReplicationInfo ).timeLeftUntilScoringSeconds <= 0 )
	{
		CheckFlagsAndScore();
		if( CheckEndGame( None, "" ) == true )
		{
			EndTheGame();
		}
		else
		{
			ResetFlagsAndBases();
			TriggerGlobalEventClass(class'AK_Kismet_FlagReset',self, 0);        //RW: Code added to trigger Kismet event
		}
	}

	for( i = 0; i < NUMBER_OF_SCORE_ZONES; ++i )
	{
		if( !scoreZones[ i ].hostingFlag )
			continue;
		CheckAndMaybeTickFlagTimer( scoreZones[ i ], AK_GameReplicationInfo( GameReplicationInfo ) );
	}
}

function CheckAndMaybeTickFlagTimer( AK_Game_ScoreZone scoreZone, AK_GameReplicationInfo timerOwner )
{
	local int i;
	local AK_Pawn pawnIterator;
	local array< AK_Pawn > allPawnsInLevel;
	local bool enemyTeamInZone;
	local AK_Pawn enemyPawn;

	enemyTeamInZone = false;
	`GetAll( AK_Pawn, allPawnsInLevel, pawnIterator )
	for( i = 0; i < allPawnsInLevel.Length; ++i )
	{
		//If the pawn is too far away, we don't care
		if( vsize( scoreZone.Location - allPawnsInLevel[ i ].Location ) > scoreZone.radiusOfScoreZone )
			continue;

		//If defenders are in the zone, then reset the timer and don't do anything else
		if( allPawnsInLevel[ i ].GetTeamNum() == scoreZone.DefenderTeamIndex )
		{
			timerOwner.timeLeftUntilFlagIsReturned[ scoreZone.DefenderTeamIndex ] = secondsBeforeFlagResets;
			return;
		}

		enemyTeamInZone = true;
		enemyPawn = allPawnsInLevel[ i ];
	}

	if( enemyTeamInZone )
	{
		`log( "TICK");
		--timerOwner.timeLeftUntilFlagIsReturned[ scoreZone.DefenderTeamIndex ];
	}

	if( timerOwner.timeLeftUntilFlagIsReturned[ scoreZone.DefenderTeamIndex ] <= 0 )
	{
		`log( "SENDING FLAG HOME");
		scoreZone.SendHostedFlagHome( enemyPawn );
		timerOwner.timeLeftUntilFlagIsReturned[ scoreZone.DefenderTeamIndex ] = secondsBeforeFlagResets;
	}
}








//---------------------------------------------- Game State Handling ----------------------------------------------//
//These are in order of their usage!
function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	AK_GameReplicationInfo( GameReplicationInfo ).timeBetweenFlagScoresSeconds = timeBetweenScoresSeconds;
	AK_GameReplicationInfo( GameReplicationInfo ).timeLeftUntilScoringSeconds = timeBetweenScoresSeconds;
	AK_GameReplicationInfo( GameReplicationInfo ).timeLeftUntilFlagIsReturned[ 0 ] = secondsBeforeFlagResets;
	AK_GameReplicationInfo( GameReplicationInfo ).timeLeftUntilFlagIsReturned[ 1 ] = secondsBeforeFlagResets;
	AK_GameReplicationInfo( GameReplicationInfo ).goalScore = defaultNumberOfScoresToWin;
}

function PostBeginPlay()
{
	local int i;
	local AK_Game_ScoreZone zoneIterator;
	local array< AK_Game_ScoreZone > allScoreZonesInLevel;

	Super.PostBeginPlay();

	`GetAll( AK_Game_ScoreZone, allScoreZonesInLevel, zoneIterator )
	`assert( allScoreZonesInLevel.Length == NUMBER_OF_SCORE_ZONES );

	for( i = 0; i < allScoreZonesInLevel.Length; ++i )
	{
		scoreZones[ allScoreZonesInLevel[ i ].DefenderTeamIndex ] = allScoreZonesInLevel[ i ];
	}
}

function StartMatch()
{
	Super.StartMatch();
	gameHasStarted = true;
}

function bool CheckEndGame( PlayerReplicationInfo Winner, string Reason )
{
	local UTCTFFlag winningTeamsFlag;
	local Controller gameController;

	if( Teams[ 0 ].Score < GoalScore && Teams[ 1 ].Score < GoalScore )
		return false;
	//Check against mutator win conditions. If they say we can't win, we can't win.
	if ( CheckModifiedEndGame(Winner, Reason) )
		return false;

	//-----Past this point, we are assuming the game is over -----//
	if ( Teams[1].Score > Teams[0].Score )
	{
		GameReplicationInfo.Winner = Teams[1];
	}
	else if( Teams[1].Score < Teams[0].Score )
	{
		GameReplicationInfo.Winner = Teams[0];
	}
	else
	{
		GameReplicationInfo.Winner = Teams[0];
	}

	//Find the winning team's flag and focus the camera on it
	winningTeamsFlag = UTCTFTeamAI(UTTeamInfo(GameReplicationInfo.Winner).AI).FriendlyFlag;
	EndGameFocus = winningTeamsFlag.HomeBase;

	//Tell all players the game is over and to focus their camera on the winning team.
	EndTime = WorldInfo.RealTimeSeconds + EndTimeDelay;
	foreach WorldInfo.AllControllers(class'Controller', gameController)
	{
		gameController.GameHasEnded( EndGameFocus, (gameController.PlayerReplicationInfo != None) && (gameController.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
	winningTeamsFlag.HomeBase.SetHidden(False);

	return true;
}

function EndTheGame()
{
	gameIsRestarting = true;
	setTimer( secondsToWaitBeforeRestartingGame, false, nameof( PerformEndGameHandling ) );
}

function PerformEndGameHandling()
{
	super.PerformEndGameHandling();
	RestartGame();
}

function Reset()
{
	AK_GameReplicationInfo( GameReplicationInfo ).timeBetweenFlagScoresSeconds = timeBetweenScoresSeconds;
	AK_GameReplicationInfo( GameReplicationInfo ).timeLeftUntilScoringSeconds = timeBetweenScoresSeconds;
}





//---------------------------------------------- Score Checking ----------------------------------------------//
simulated function CheckFlagsAndScore()
{
	local int i;

	for( i = 0; i < NUMBER_OF_FLAGS; ++i )
	{
		if( Flags[ i ].IsInState( 'Home' ) )
			Teams[ i ].Score += 1;
		else if( Flags[ i ].IsInState( 'PlacedInZone' ) )
			Teams[ 1 - i ].Score += 1;
	}
}

simulated function ResetFlagsAndBases()
{
	local int i;

	for( i = 0; i < NUMBER_OF_FLAGS; ++i )
	{
		Flags[ i ].SendHome( None );
	}

	for( i = 0; i < NUMBER_OF_SCORE_ZONES; ++i )
	{
		scoreZones[ i ].hostingFlag = false;
	}
}

DefaultProperties
{
	NUMBER_OF_FLAGS = 2
	NUMBER_OF_SCORE_ZONES = 2

	Acronym = "AK"
	MapPrefixes(0)="AK"

	MaxPlayersAllowed = 8

	gameHasStarted = false
	gameIsRestarting = false
	secondsToWaitBeforeRestartingGame = 15;

	timeBetweenScoresSeconds = 60			//DH: Changed from 40
	secondsBeforeFlagResets = 5
	defaultNumberOfScoresToWin = 10

	DefaultPawnClass=class'AKHET.AK_Pawn'
    DefaultInventory(0)=class'AKHET.AK_Weapon_WristGun'
    PlayerControllerClass=class'AKHET.AK_PlayerController'
	Hudtype=class'AKHET.AK_Hud_UI'
	GameReplicationInfoClass=class'AKHET.AK_GameReplicationInfo'
    PlayerReplicationInfoClass=class'AKHET.AK_PlayerReplicationInfo'
	bUseClassicHud = true
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Flag Class
{{< code-block unrealscript >}}
class AK_Stockpile_Flag extends UTCTFFlag
	abstract;

var AK_Stockpile_ScoreZone holdingZone;
var bool inScoreZone;
var int flagIndex;

var class< LocalMessage > flagMessageClass;

var SkeletalMeshComponent OverlayMesh;
var MaterialInstanceConstant OverlayMaterial[2];

replication
{
	if ( bNetDirty )
		flagIndex;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if( Role == NM_DedicatedServer )
		return;

	overlayMesh.SetMaterial( 0, OverlayMaterial[0] );
}


//----------------------------------------- States -----------------------------------------//
auto state Home
{
	ignores SendHome, Score, Drop;

	function BeginState( Name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagAtSpawn( flagIndex );
		WorldInfo.GRI.bForceNetUpdate = TRUE;
	}

	function EndState( Name NextStateName )
	{
		Super.EndState( NextStateName );
	}

	function SameTeamTouch( Controller C )
	{
		//Touching the flag with the enemy flag does nothing!
	}
}

state Held
{
	ignores SetHolder;

	function SendHome(Controller Returner)
	{
		super.SendHome( Returner );
	}

	function KismetSendHome()
	{
		super.KismetSendHome();
	}

	function Timer()
	{
		super.Timer();
	}

	function BeginState( Name PreviousStateName )
	{
		super.BeginState( PreviousStateName );

		if( holder.GetTeamNum() == 0 )
			AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagHeldByRa( flagIndex );
		else
			AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagHeldByAnubis( flagIndex );

		WorldInfo.GRI.bForceNetUpdate = TRUE;
	}

	function EndState( Name NextStateName )
	{
		super.EndState( NextStateName );
	}
}

//---------------------------------------------------------------------------------
state Dropped
{
	ignores Drop;

	function BeginState( Name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagDropped( flagIndex );
		WorldInfo.GRI.bForceNetUpdate = TRUE;
	}

	function EndState( Name NextStateName )
	{
		Super.EndState( NextStateName );
	}

	function SameTeamTouch( Controller C )
	{
		super.SameTeamTouch( C );
	}

	function Timer() // TODO: Look into resetting scalars on endstate too, just in case picked up mid-fade
	{
		super.Timer();
	}
}

//---------------------------------------------------------------------------------
state PlacedInZone
{
	ignores Touch, Drop;

	function BeginState( Name PreviousStateName )
	{
		if( holdingZone.DefenderTeamIndex == 0 )
			AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagPlacedInRaZone( flagIndex );
		else
			AK_Stockpile_GRI( WorldInfo.GRI ).SetFlagPlacedInAnubisZone( flagIndex );

		SetFlagPropertiesToStationaryFlagState();

		SetRotation( holdingZone.Rotation );
		SetBase( holdingZone );
		SetPhysics(PHYS_None);
		inScoreZone = true;
		holdingZone.bForceNetUpdate = true;
		bForceNetUpdate = true;
	}

	function EndState( Name NextStateName )
	{
		inScoreZone = false;
	}

	function SameTeamTouch( Controller C )
	{
		//Touching the flag in this state does nothing!
	}
}




//----------------------------------------- State Changing Functions -----------------------------------------//
function PlaceFlag( AK_Stockpile_ScoreZone scoreZone, Vector locationToPlace )
{
	local PlayerController playerControl;

	playerControl = PlayerController( holder.Controller );
	if( playerControl != None )
	{
		playerControl.ReceiveLocalizedMessage( flagMessageClass, 2 ); //2 is flag placed message
	}

	ClearHolder();
	holdingZone = scoreZone;

	SetLocation( locationToPlace );

	GotoState( 'PlacedInZone' );
}

function SendHome( Controller Returner )
{
	--holdingZone.numberOfHostedFlags;
	holdingZone = None;

	super.SendHome( Returner );
}

function Drop(optional Controller Killer)
{
	//Note to self: holder variable must not be being set
	if( PlayerController( holder.Controller ) != None )
	{
		PlayerController( holder.Controller ).ReceiveLocalizedMessage( flagMessageClass, 1 ); //1 is flag dropped message
	}

	Super.Drop(Killer);
}

//This function is a direct copy of UTCTFFlag's function of the same name; we just don't need the translation.
function SetFlagPropertiesToStationaryFlagState()
{
	//SkelMesh.SetTranslation( vect(0.0,0.0,-40.0) );
	LightEnvironment.bDynamic = TRUE;
	SkelMesh.SetShadowParent( None );
	SetTimer( 5.0f, FALSE, 'SetFlagDynamicLightToNotBeDynamic' );
}


//Most of this function is copied from UTCTFFlag; we have just removed the translation set because it's bad.
function SetHolder( Controller newHolder )
{
	local UTCTFSquadAI S;
	local UTPawn UTP;
	local UTBot B;

	holdingZone = None;

	if( PlayerController( newHolder ) != None )
	{
		PlayerController( newHolder ).ReceiveLocalizedMessage( flagMessageClass, 0 ); //0 is flag taken message
	}

	// when the flag is picked up we need to set the flag translation so it doesn't stick in the ground
	//SkelMesh.SetTranslation( vect(0.0,0.0,0.0) ); //No we don't.
	UTP = UTPawn( newHolder.Pawn );
	LightEnvironment.bDynamic = TRUE;
	SkelMesh.SetShadowParent( UTP.Mesh );

	ClearTimer( 'SetFlagDynamicLightToNotBeDynamic' );

	// AI Related
	B = UTBot( newHolder );
	if ( B != None )
	{
		S = UTCTFSquadAI(B.Squad);
	}
	else if ( PlayerController( newHolder ) != None )
	{
		S = UTCTFSquadAI(UTTeamInfo(newHolder.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	}

	if ( S != None )
	{
		S.EnemyFlagTakenBy(newHolder);
	}

	Super( UTCarriedObject ).SetHolder( newHolder );
	if ( B != None )
	{
		B.SetMaxDesiredSpeed();
	}
}


function bool ValidHolder( Actor Other )
{
    if ( !Super( UTCarriedObject ).ValidHolder(Other) )
	{
		return false;
	}

	if( UTPlayerReplicationInfo( Pawn( Other ).Controller.PlayerReplicationInfo ).bHasFlag )
	{
		return false;
	}

    return true;
}




DefaultProperties
{
	bAlwaysRelevant = true

	flagMessageClass = class'AK_Message_Flag'

	inScoreZone = false

	//Point light on the flag
	Begin Object name=FlagLightComponent
		Brightness=1.25
		LightColor=(R=255,G=255,B=255)
		Radius=192
		CastShadows=false
		bEnabled=true
		LightingChannels=(Dynamic=FALSE,CompositeDynamic=FALSE)
	End Object
	FlagLight=FlagLightComponent
	Components.Add(FlagLightComponent)

	//Overlay mesh used when flag is not visible
	Begin Object Class=SkeletalMeshComponent Name=OverlayMeshComponent
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bPerBoneMotionBlur=true
		DepthPriorityGroup = SDPG_Foreground
		Scale=1.01
	End Object
	Components.Add( OverlayMeshComponent )
	OverlayMesh = OverlayMeshComponent
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Score Zone Class
{{< code-block unrealscript >}}
class AK_Stockpile_ScoreZone extends UTGameObjective
	abstract;

var array< AK_Stockpile_Flag > hostedFlags;
var repnotify int numberOfHostedFlags;

var const float radiusOfScoreZone;
var const float flagOffsetRadius;

var StaticMeshComponent pedestalMesh;
var MaterialInstanceConstant pedestalMaterial;
var MaterialInstanceConstant pedestalColor;

var StaticMeshComponent outerRingMesh;
var StaticMeshComponent siphonTunnelMesh;

var class< LocalMessage > stockpileMessageClass;

var SoundCue placeFlagSound;
var SoundCue takeFlagSound;

replication
{
    if ( Role == ROLE_Authority )
		numberOfHostedFlags;
}

simulated event ReplicatedEvent ( name eventName )
{
	if( eventName == 'numberOfHostedFlags' )
	{
		SpawnOrDespawnSiphonCircle();
	}
	else
	{
		Super.ReplicatedEvent( eventName );
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Role < ROLE_Authority )
		return;

	siphonTunnelMesh.SetHidden( true );
	AK_Stockpile_Game( WorldInfo.Game ).RegisterScoreZone( self, DefenderTeamIndex );

	pedestalColor = new(Outer) class'MaterialInstanceConstant';
	pedestalColor.SetParent( pedestalMaterial );
	pedestalMesh.SetMaterial( 0, pedestalColor );
}


reliable server function ServerHandleSiphonCircle()
{
	SpawnOrDespawnSiphonCircle();
}

simulated function SpawnOrDespawnSiphonCircle()
{
	//local vector topOfCylinder, bottomOfCylinder;
	//topOfCylinder = self.location;
	//topOfCylinder.z += 60.0;
	//bottomOfCylinder = self.location;
	//bottomOfCylinder.z -= 60.0;

	if( numberOfHostedFlags > 0 )
	{
		//DrawDebugCylinder( bottomOfCylinder, topOfCylinder, radiusOfScoreZone, 40, 255, 255, 255, true );
		siphonTunnelMesh.SetHidden( false );
	}
	else
	{
		//FlushPersistentDebugLines();
		siphonTunnelMesh.SetHidden( true );
	}
}

simulated function Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local int lastFlagIndex;
	local UTPawn stockpilePawn;
	local bool pawnHasFlag;
	local AK_Stockpile_Flag heldFlag;
	local float fractionOfTotalFlags;
	local vector flagOffsetFromZoneCenter;

	stockpilePawn = UTPawn( Other );
    if ( stockpilePawn != None )
    {
    	pawnHasFlag = stockpilePawn.GetUTPlayerReplicationInfo().bHasFlag;

    	if( stockpilePawn.GetTeamNum() == DefenderTeamIndex )
    	{
	    	if( pawnHasFlag )
	    	{
	    		heldFlag = AK_Stockpile_Flag( stockpilePawn.GetUTPlayerReplicationInfo().GetFlag() );
	    		if ( heldFlag == None )
	    		 	return;
	    		heldFlag.ClearHolder();
	    		hostedFlags.AddItem( heldFlag );

	    		fractionOfTotalFlags = float( numberOfHostedFlags ) / AK_Stockpile_GRI( WorldInfo.GRI ).totalNumberOfFlags;
	    		flagOffsetFromZoneCenter.X = flagOffsetRadius * cos( fractionOfTotalFlags * 2 * PI );
	    		flagOffsetFromZoneCenter.Y = flagOffsetRadius * sin( fractionOfTotalFlags * 2 * PI );
				heldFlag.PlaceFlag( self, self.Location + flagOffsetFromZoneCenter );

				PlaySound( placeFlagSound );

				numberOfHostedFlags += 1;
				if( role == ROLE_Authority )
				{
					ServerHandleSiphonCircle();
				}
	    	}
    	}
    	else
    	{
	    	if( ( numberOfHostedFlags > 0 ) && !pawnHasFlag )
	    	{
	    		lastFlagIndex = hostedFlags.Length - 1;
	    		hostedFlags[ lastFlagIndex ].SetHolder( stockpilePawn.Controller );

	    		PlaySound( takeFlagSound );

	    		hostedFlags.Remove( lastFlagIndex, 1 );
				numberOfHostedFlags -= 1;
				if( role == ROLE_Authority )
				{
					ServerHandleSiphonCircle();

					//Flag stolen messages start at index 8, and you want the opposite team's from yours
					BroadcastLocalizedMessage( stockpileMessageClass, 8 + ( 1 - stockpilePawn.GetTeamNum() ), stockpilePawn.PlayerReplicationInfo );
				}
	    	}
    	}
    }
}




DefaultProperties
{
	bAlwaysRelevant=true
	NetUpdateFrequency=1
	RemoteRole=ROLE_SimulatedProxy
    stockpileMessageClass = class'AKHET.AK_Message_Stockpile'

	radiusOfScoreZone = 300.0;
	flagOffsetRadius = 20.0;

    bCollideActors=true
	Begin Object Name=CollisionCylinder
		CollisionRadius=+30.0
		CollisionHeight=+60.0

        CollideActors=true        
        BlockActors=false
        BlockNonZeroExtent=true
        BlockZeroExtent=true
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=FlagBaseLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add( FlagBaseLightEnvironment )



	Begin Object Class=StaticMeshComponent Name=PedestalMeshComponent
		StaticMesh=StaticMesh'AK_Flags.Meshes.AK_FlagStand_Mesh_01'
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=( BSP=TRUE, Dynamic=TRUE, Static=TRUE, CompositeDynamic=TRUE )

		CollideActors=false
		MaxDrawDistance=7000
		Translation=( X=0.0, Y=0.0, Z=-42.0 )
		Rotation=(Roll=32768)
		Scale = 1.0
	End Object
 	Components.Add( PedestalMeshComponent )
 	pedestalMesh = PedestalMeshComponent
	pedestalMaterial = MaterialInstanceConstant'AK_Flags.Textures.AK_FlagStand_MAT_Nuetral_01_CONST'

	Begin Object Class=StaticMeshComponent Name=OuterRingMeshComponent
		StaticMesh=StaticMesh'AK_Decoration_Pieces.capture_ring.AK_CaptureRing_Mesh_01'
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=FALSE
		bForceDirectLightMap=TRUE
		LightingChannels=( BSP=TRUE, Dynamic=TRUE, Static=TRUE, CompositeDynamic=TRUE )

		CollideActors=false
		MaxDrawDistance=7000
		Translation=( X=0.0, Y=0.0, Z=-44.0 )		    //DH:Z changed from -50
		Scale3D=(X=1.015,Y=1.015,Z=1.0)				//DH: Changed from Scale=1.2
	End Object
 	Components.Add( OuterRingMeshComponent )
 	outerRingMesh = OuterRingMeshComponent

 	
	Begin Object Class=StaticMeshComponent Name=SiphonTunnelMeshComponent
		StaticMesh=StaticMesh'AK_Decoration_Pieces.Siphon_Circle.AK_SiphonCircle_Mesh_Purple_01'
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=( BSP=TRUE, Dynamic=TRUE, Static=TRUE, CompositeDynamic=TRUE )

		CollideActors=false
		MaxDrawDistance=7000
		Translation=( X=0.0, Y=0.0, Z=-62.0 )
		Scale = 1.0 							//DH: Changed from 1.2
	End Object
 	Components.Add( SiphonTunnelMeshComponent )
 	siphonTunnelMesh = SiphonTunnelMeshComponent

	placeFlagSound = SoundCue'AK_AmbNoise.ak_music_noise.AK_SiphonParticle_Cue'
	takeFlagSound = SoundCue'AK_AmbNoise.AK_Jar_Pickup_Cue' //sames as picking up from original jar loc.
}
{{< /code-block >}}
{{% /section %}}
