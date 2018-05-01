+++
title = "Opening Cutscene"
subtitle = ""
Description = ""
Tags = []
languages = ["actionscript", "unrealscript"]
project_base_name = "super-slash-n-grab"
file_links = ["https://github.com/vingenuity/ssng-source/blob/master/Flash/SSG_Opening_Cutscene/SSG_Opening_Cutscene.fla"]
+++
{{% section class="section scrollspy" %}}
### Motivation
For playing cutscenes, UDK requires using the Bink format and its native player. However, as students with no native code access, UDK's Bink player has a major downside: the only play function is an exec command called MOVIETEST.

The MOVIETEST function loads the movie and then stops the engine completely to play it. This means that the cutscenes are unskippable (input has been stopped) and can't have subtitles (the message system is also stopped.) Our team believed that lacking those two features in our cutscene would make for a bad player experience, so we made a custom cutscene player in flash to fix this problem.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
Our flash file template for cutscenes is devised of four layers:

   * An object that watches for button presses and fires an event to Unreal on any button press to end the cutscene.
   * A text container that is used to display subtitle data on top of the cutscene.
   * The cutscene itself, hand-animated by our amazing artists.
   * An event layer, where we manually timed when to fire subtitles.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Cutscene Skip
{{< code-block actionscript >}}
//timer to prevent the cutscene from being skipped for the first two seconds (also hides the frame)
const ONE_SECOND_IN_MS = 1000;
var skip_allowed_timer:Timer = new Timer( ONE_SECOND_IN_MS, 2 );
skip_allowed_timer.addEventListener( TimerEvent.TIMER_COMPLETE, AllowSkipping );

var fade_in_skip_tween:Tween;

function AllowSkipping( timer_event:TimerEvent )
{
	// fade in our skip prompt so that we're not distracting, and attach the event listener so they can skip
	fade_in_skip_tween = new Tween( mc_skip_clip, "alpha", Regular.easeOut, 0.0, 1.0, FADE_LENGTH_SECONDS, true );
	fade_in_skip_tween.start();
	InputDelegate.getInstance().addEventListener(InputEvent.INPUT, HandleSkipInput );
}

function HandleSkipInput( input_event:InputEvent )
{
	if( input_event.details.value != InputValue.KEY_UP )
		return;

	switch( input_event.details.navEquivalent )
	{
	case NavigationCode.GAMEPAD_A:
	case NavigationCode.GAMEPAD_START:
		InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, HandleSkipInput );
		ExternalInterface.call( "EndCutscene" );
		break;
	default:
		return;
	}
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Subtitle Display
{{< code-block actionscript >}}
const FADE_LENGTH_SECONDS = 0.3;
const ONE_SECOND_IN_MILLIS = 1000;

var fade_in_tween:Tween;
var fade_out_tween:Tween;

var subtitle_timer:Timer = new Timer( ONE_SECOND_IN_MILLIS, 1 );
subtitle_timer.addEventListener( TimerEvent.TIMER_COMPLETE, HideSubtitle );

var subtitle_seconds_shown:Number = 1.0;

function ShowSubtitle()
{
	//mc_subtitle.text_subtitle.text = subtitle_text;
	fade_in_tween = new Tween( mc_subtitle, "alpha", Regular.easeOut, 0.0, 1.0, FADE_LENGTH_SECONDS, true );
	subtitle_timer.start();
}

function HideSubtitle( timer_event:TimerEvent )
{
	fade_out_tween = new Tween( mc_subtitle, "alpha", Regular.easeOut, 1.0, 0.0, FADE_LENGTH_SECONDS, true );
	//fade_out_tween.addEventListener( TweenEvent.MOTION_FINISH, ClearSubtitle );
}

function ClearSubtitle()
{
	mc_subtitle.text_subtitle.text = "";
}

function PlayMessage( message_number:uint, message_length:Number )
{
	ExternalInterface.call( "PlayCutsceneMessage", message_number );
	if( Extensions.isGFxPlayer )
	{
		mc_subtitle.Show( "Subtitle will show here.", message_length );
	}
}
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Unrealscript Backend
{{< code-block unrealscript >}}
class SSG_Cutscene_Opening extends GfxMoviePlayer;

var class<SSG_Message_Cutscene_Opening> MessageClass;
var string NextLevelName;
var SSG_Cutscene_Subtitle_Object Subtitle;
var string LocalizationSection;


//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	super.Start();

	SetViewScaleMode(SM_ExactFit);
	SetAlignment(Align_TopLeft);
	
	return true;
}

//----------------------------------------------------------------------------------------------------------
function Init( optional LocalPlayer playerController )
{
	Start();
	Advance(0.f);

	SetViewScaleMode(SM_ExactFit);
	SetAlignment(Align_TopLeft);

	Subtitle = SSG_Cutscene_Subtitle_Object( GetVariableObject( "_root.mc_subtitle", class'SSG_Cutscene_Subtitle_Object' ) );
}

//----------------------------------------------------------------------------------------------------------
function LocalizeSkipFrame()
{
	local GFxObject SkipFrameText;
	local string SkipFrameTextString;

	SkipFrameText = GetVariableObject("_root.mc_skip_clip.text_press");
	SkipFrameTextString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "cutsceneClipPress");
	SkipFrameText.SetText(SkipFrameTextString);

	SkipFrameText = GetVariableObject("_root.mc_skip_clip.text_to_skip");
	SkipFrameTextString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "cutsceneClipToSkip");
	SkipFrameText.SetText(SkipFrameTextString);
}

//----------------------------------------------------------------------------------------------------------
function PlayCutsceneMessage( int MessageNumber )
{
	SSG_PlayerController( GetPC() ).Announcer.PlayAnnouncement( MessageClass, MessageNumber );
	Subtitle = SSG_Cutscene_Subtitle_Object( GetVariableObject( "_root.mc_subtitle", class'SSG_Cutscene_Subtitle_Object' ) );
	Subtitle.Show( MessageClass.static.GetString( MessageNumber ), MessageClass.static.GetSubtitleLengthSeconds( MessageNumber ) );
}


//----------------------------------------------------------------------------------------------------------
function EndCutscene()
{
	SetPause( true );
	ConsoleCommand( "open " $ NextLevelName );
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MovieInfo=SwfMovie'SSG_Opening_Cutscene.SSG_Opening_Cutscene'
	TimingMode=TM_Real
	Priority=10

	bBlurLesserMovies=true

	bDisplayWithHudOff=true
	bPauseGameWhileActive=false

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	LocalizationSection="SSG_Cutscene"
	MessageClass=class'SSG_Message_Cutscene_Opening'
	NextLevelName="SGS-MapMenu.udk";

	//SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
{{< /code-block >}}
{{% /section %}}
