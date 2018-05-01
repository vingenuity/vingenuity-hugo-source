+++
title = "Multiplayer Menus"
subtitle = ""
date = 2014-11-29
Description = ""
Tags = []
languages = ["actionscript"]
project_base_name = "super-slash-n-grab"
file_links = ["https://github.com/vingenuity/ssng-source/blob/master/Flash/ThiefSelectionMenu/ThiefSelectionMenu.fla"]
+++
{{% section class="section scrollspy" %}}
### Motivation
From the moment our team decided to create a local multiplayer game, we knew we would have to work around the limits of the basic Flash input system, which only supports a single controller.

Thankfully, we discovered that Scaleform had an extension called the FocusManager that handled the difficult parts for us. Our final implementation uses this extension extensively for the four-player input.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
In general, our multiplayer menus start up by using the stage actions to set up the FocusManager masks for the controllers and the objects on stage.

From then on, each masked object can act as if it were a normal Scaleform object dealing with a single player input.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Menu Startup
{{< code-block actionscript >}}
//Set Controllers to focus groups
FocusManager.setControllerFocusGroup(0, 0); 
FocusManager.setControllerFocusGroup(1, 1);
FocusManager.setControllerFocusGroup(2, 2);
FocusManager.setControllerFocusGroup(3, 3);

//mask each selection area movieclip to only one group
FocusManager.setFocusGroupMask( mc_player_1_selection, 0x1 );
FocusManager.setFocusGroupMask( mc_player_2_selection, 0x2 );
FocusManager.setFocusGroupMask( mc_player_3_selection, 0x4 );
FocusManager.setFocusGroupMask( mc_player_4_selection, 0x8 );

//set the movieclips to not jump to each other when selection is moved past the end
FocusManager.setModalClip( mc_player_1_selection, 0 );
FocusManager.setModalClip( mc_player_2_selection, 1 );
FocusManager.setModalClip( mc_player_3_selection, 2 );
FocusManager.setModalClip( mc_player_4_selection, 3 );
{{< /code-block >}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Individual Selection Menu
{{< code-block actionscript >}}
	public class ThiefSelectionArea extends MovieClip
	{
		public var text_player_title:TextField;
		public var mc_frame_press_start:MovieClip;
		public var mc_frame_name_entry:MovieClip;
		public var mc_frame_ready:MovieClip;
		public var mc_card_background:MovieClip;
		public var mc_invisible:MovieClip;
		
		public var controller_id:uint;
		private var current_frame:uint;
		private static const FRAME_None = 0;
		private static const FRAME_PressA = 1;
		private static const FRAME_NameEntry = 2;
		private static const FRAME_Ready = 3;
		
		public var background_color:ColorTransform;
		
		private static const TRANSITION_IN_SECONDS:Number = 0.3;
		private static const TRANSITION_OUT_SECONDS:Number = 0.3;
		private var transition_in_alpha:Tween;
		private var transition_out_alpha:Tween;
		
		
		// Constructor
		public function ThiefSelectionArea()
		{
			controller_id = 0;
			
			mc_frame_press_start.alpha = 0.0;
			mc_frame_name_entry.alpha = 0.0;
			mc_frame_ready.alpha = 0.0;
			
			background_color = new ColorTransform();
			background_color.color = 0xFFFFFF;
		}
		
		
		
		// ++++++++++++++++++++++++++++++++++++++++++ Setters +++++++++++++++++++++++++++++++++++++++++++++//
		//---------------------------------------------------------------------------------------------------
		public function DisableButtonInput()
		{
			//Remove all previous event watchers
			InputDelegate.getInstance().removeEventListener( InputEvent.INPUT, HandlePressAButtonPresses );
			InputDelegate.getInstance().removeEventListener( InputEvent.INPUT, HandleReadyButtonPresses );
			mc_frame_name_entry.removeEventListener( NameEntryEvent.ENTRY_ACCEPTED, HandleNameEntryEvent );
			mc_frame_name_entry.removeEventListener( NameEntryEvent.ENTRY_REJECTED, HandleNameEntryEvent );
			
			//Don't let them select by giving them no focus
			FocusManager.setModalClip( mc_invisible, controller_id );
			FocusManager.setFocus( mc_invisible, controller_id );
		}

		//---------------------------------------------------------------------------------------------------
		private function EnableButtonInput( tween_event:TweenEvent )
		{
			switch( current_frame )
			{
			case FRAME_PressA:
				InputDelegate.getInstance().addEventListener( InputEvent.INPUT, HandlePressAButtonPresses );
				FocusManager.setModalClip( mc_frame_press_start, controller_id );
				FocusManager.setFocus( mc_frame_press_start, controller_id );
				break;
			case FRAME_NameEntry:
				mc_frame_name_entry.text_input_name.text = "";
				mc_frame_name_entry.addEventListener( NameEntryEvent.ENTRY_ACCEPTED, HandleNameEntryEvent );
				mc_frame_name_entry.addEventListener( NameEntryEvent.ENTRY_REJECTED, HandleNameEntryEvent );
				FocusManager.setModalClip( mc_frame_name_entry, controller_id );
				FocusManager.setFocus( mc_frame_name_entry.mc_keyboard.mc_a_button, controller_id );
				break;
			case FRAME_Ready:
				mc_frame_ready.mc_swords.gotoAndPlay( 0 );
				InputDelegate.getInstance().addEventListener( InputEvent.INPUT, HandleReadyButtonPresses );
				FocusManager.setModalClip( mc_frame_ready, controller_id );
				FocusManager.setFocus( mc_frame_ready, controller_id );
				break;
			case FRAME_None:
			default:
				return;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:uint = 255, green:uint = 255, blue:uint = 255 )
		{
			background_color.redOffset = red;
			background_color.greenOffset = green;
			background_color.blueOffset = blue;
			
			mc_card_background.transform.colorTransform = background_color;
		}
		
		
		// +++++++++++++++++++++++++++++++++++++++ Event Handling +++++++++++++++++++++++++++++++++++++++++//
		//---------------------------------------------------------------------------------------------------
		private function HandleNameEntryEvent( name_entry_event:NameEntryEvent )
		{
			trace( "Received Event" );
			switch( name_entry_event.type )
			{
			case NameEntryEvent.ENTRY_ACCEPTED:
				{
					if( controller_id == 0 )
						ExternalInterface.call( "AddNewThiefPlayer1" );
					else if( controller_id == 1 )
						ExternalInterface.call( "AddNewThiefPlayer2" );
					else if( controller_id == 2 )
						ExternalInterface.call( "AddNewThiefPlayer3" );
					else if( controller_id == 3 )
						ExternalInterface.call( "AddNewThiefPlayer4" );
					
					TransitionToPlayerReady( mc_frame_name_entry.text_input_name.text );
					
					if( controller_id == 0 )
						ExternalInterface.call( "ReadyPlayer1" );
					else if( controller_id == 1 )
						ExternalInterface.call( "ReadyPlayer2" );
					else if( controller_id == 2 )
						ExternalInterface.call( "ReadyPlayer3" );
					else if( controller_id == 3 )
						ExternalInterface.call( "ReadyPlayer4" );
				}
				break;
			case NameEntryEvent.ENTRY_REJECTED:
				if( controller_id != 0 )
					TransitionToPressA();
				break;
			default:
				return;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function HandlePressAButtonPresses( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
			
			if( input_event.details.controllerIndex != controller_id )
				return;

			switch( input_event.details.navEquivalent )
			{
			case NavigationCode.GAMEPAD_A:
			case NavigationCode.GAMEPAD_START:
				PlayUDKSound( "MenuSounds", "ThiefCardOpened" );
				TransitionToNameEntry();
				removeEventListener( InputEvent.INPUT, HandlePressAButtonPresses );
				break;
			default:
				return;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function HandleReadyButtonPresses( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
			
			if( input_event.details.controllerIndex != controller_id )
				return;

			switch( input_event.details.navEquivalent )
			{
			case NavigationCode.GAMEPAD_B:
				TransitionToNameEntry();
				removeEventListener( InputEvent.INPUT, HandleReadyButtonPresses );
				
				switch( controller_id )
				{
				case 0:
					ExternalInterface.call( "UnreadyPlayer1" );
					break;
				case 1:
					ExternalInterface.call( "UnreadyPlayer2" );
					break;
				case 2:
					ExternalInterface.call( "UnreadyPlayer3" );
					break;
				case 3:
					ExternalInterface.call( "UnreadyPlayer4" );
					break;
				default:
					break;
				}
				break;
			default:
				return;
			}
		}
		
		
		
		// ++++++++++++++++++++++++++++++++++++++++ Transitions +++++++++++++++++++++++++++++++++++++++++++//
		//---------------------------------------------------------------------------------------------------
		function TransitionOutPreviousFrame()
		{
			DisableButtonInput();
			switch( current_frame )
			{
			case FRAME_PressA:
				transition_out_alpha = new Tween( mc_frame_press_start, "alpha", Regular.easeOut, 1.0, 0.0, TRANSITION_OUT_SECONDS, true );
				break;
			case FRAME_NameEntry:
				transition_out_alpha = new Tween( mc_frame_name_entry, "alpha", Regular.easeOut, 1.0, 0.0, TRANSITION_OUT_SECONDS, true );
				break;
			case FRAME_Ready:
				transition_out_alpha = new Tween( mc_frame_ready, "alpha", Regular.easeOut, 1.0, 0.0, TRANSITION_OUT_SECONDS, true );
				break;
			case FRAME_None:
			default:
				TransitionInNextFrame( null );
				return;
			}
			transition_out_alpha.addEventListener( TweenEvent.MOTION_FINISH, TransitionInNextFrame );
		}
		
		//---------------------------------------------------------------------------------------------------
		function TransitionInNextFrame( tween_event:TweenEvent )
		{
			switch( current_frame )
			{
			case FRAME_PressA:
				transition_in_alpha = new Tween( mc_frame_press_start, "alpha", Regular.easeOut, 0.0, 1.0, TRANSITION_IN_SECONDS, true );
				break;
			case FRAME_NameEntry:
				transition_in_alpha = new Tween( mc_frame_name_entry, "alpha", Regular.easeOut, 0.0, 1.0, TRANSITION_IN_SECONDS, true );
				break;
			case FRAME_Ready:
				transition_in_alpha = new Tween( mc_frame_ready, "alpha", Regular.easeOut, 0.0, 1.0, TRANSITION_IN_SECONDS, true );
				break;
			case FRAME_None:
				if( controller_id == 0 )
					transition_in_alpha = new Tween( mc_frame_name_entry, "alpha", Regular.easeOut, 0.0, 1.0, TRANSITION_IN_SECONDS, true );
				else
					transition_in_alpha = new Tween( mc_frame_press_start, "alpha", Regular.easeOut, 0.0, 1.0, TRANSITION_IN_SECONDS, true );
				break;
			default:
				return;
			}
			transition_in_alpha.addEventListener( TweenEvent.MOTION_FINISH, EnableButtonInput );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function TransitionToPressA()
		{
			ExternalInterface.call( "LocalizePressAFrame" );
			PlayUDKSound( "MenuSounds", "ThiefCardTransition" );
			TransitionOutPreviousFrame();
			current_frame = FRAME_PressA;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function TransitionToNameEntry()
		{
			ExternalInterface.call( "LocalizeNameEntryFrame" );
			PlayUDKSound( "MenuSounds", "ThiefCardTransition" );
			TransitionOutPreviousFrame();
			current_frame = FRAME_NameEntry;
			
		}
		
		//---------------------------------------------------------------------------------------------------
		public function TransitionToPlayerReady( player_name:String )
		{
			ExternalInterface.call( "LocalizePlayerReadyFrame" );
			PlayUDKSound( "MenuSounds", "ThiefCardTransition" );
			TransitionOutPreviousFrame();
			current_frame = FRAME_Ready;
			mc_frame_ready.text_player_name.text = player_name;
			mc_frame_ready.mc_swords.gotoAndStop( 0 );
		}		
	}
{{< /code-block >}}
{{% /section %}}
