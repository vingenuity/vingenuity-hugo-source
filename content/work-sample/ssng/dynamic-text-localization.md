+++
title = "Dynamic Text Localization"
subtitle = ""
Description = ""
Tags = []
languages = ["actionscript", "unrealscript"]
project_base_name = "super-slash-n-grab"
file_links = ["https://github.com/vingenuity/ssng-source/blob/master/Unrealscript/SuperSlashNGrab/Classes/Text_Localizer.uc"]
+++
{{< image src="/images/ssng/dynamic-text-localization.jpg" class="responsive-img materialboxed" >}}
{{% section class="section scrollspy" %}}
### Motivation
UDK has a very well-made localization system that can handle localizing text, images, and even video files. However, in order to localize all of these assets, it performs this localization during the initial engine load. Unfortunately, this means that changing the localization in UDK normally requires a game restart.

For our game, we wanted to work around this limitation and allow our users to change the localization on-the-fly using our menus. We accomplished that using this custom static class.
{{% /section %}}
{{% section class="section scrollspy" %}}
### Design
Our text localizer works on top of UDK's localizer using its parsing functionality. The game keeps its localization language set to International, and inside of the international localization file directory lie the localization files for every language. Thus, on startup, UDK will load localization text for all our supported languages. 

Each language's file has a specific name that is registered in the localizer with that language option in the menus. When a text localization is requested, the localizer calls for UDK to find the localization that it would normally, but to look in that specific file.
{{% /section %}}
### Code
{{% section class="section scrollspy" %}}
#### Localizer
{{< code-block unrealscript >}}
class Text_Localizer extends Object
	config(Game);

//----------------------------------------------------------------------------------------------------------
enum Language
{
    /* 0*/LANGUAGE_ENG,
    /* 1*/LANGUAGE_ESM,
    /* 2*/LANGUAGE_FRA,
    /* 3*/LANGUAGE_XXX
};

//----------------------------------------------------------------------------------------------------------
var config Language GameLanguage;

var string localizationFile_ENG;
var string localizationFile_ESM;
var string localizationFile_FRA;
var string localizationFile_XXX;


//----------------------------------------------------------------------------------------------------------
static function string ConvertLanguageToString( Language Lang )
{
    local string LanguageString;

    switch( Lang )
    {
    case LANGUAGE_ENG:
        LanguageString = "English";
        break;
    case LANGUAGE_ESM:
        LanguageString = "Espanol";
        break;
    case LANGUAGE_FRA:
        LanguageString = "Francais";
        break;
    case LANGUAGE_XXX:
        default:
        LanguageString = "Test Language Xx";
    }

    return LanguageString;
}

//----------------------------------------------------------------------------------------------------------
static function string GetLocalizedStringWithName( string sectionName, string stringName )
{
    local string currentFile;

    switch( Default.GameLanguage )
    {
    case LANGUAGE_ENG:
        currentFile = Default.localizationFile_ENG;
        break;
    case LANGUAGE_ESM:
        currentFile = Default.localizationFile_ESM;
        break;
    case LANGUAGE_FRA:
        currentFile = Default.localizationFile_FRA;
        break;
    case LANGUAGE_XXX:
        default:
        currentFile = Default.localizationFile_XXX;
    }

    return ParseLocalizedPropertyPath( currentFile $ "." $ sectionName $ "." $ stringName );
}

//----------------------------------------------------------------------------------------------------------
static function Language GetCurrentLocalizationLanguage()
{
    return Default.GameLanguage;
}

//----------------------------------------------------------------------------------------------------------
static function string GetCurrentLocalizationName()
{
    return ConvertLanguageToString( GetCurrentLocalizationLanguage() );
}

//----------------------------------------------------------------------------------------------------------
static function SetLocalizationLanguage( Language newLanguage )
{
	Default.GameLanguage = newLanguage;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static function array< string > GetSupportedLanguages()
{
    local array< string > SupportedLanguages;
    local int i;

    for( i = 0; i < Language.EnumCount - 1; ++i )
    {
        SupportedLanguages.AddItem( ConvertLanguageToString( Language( i ) ) );
    }

    return SupportedLanguages;
}

DefaultProperties
{
    localizationFile_ENG = "SSG_ENG"
    localizationFile_ESM = "SSG_ESM"
    localizationFile_FRA = "SSG_FRA"
    localizationFile_XXX = "SSG_XXX"
}
{{< /code-block>}}
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Example Localization File
{{< code-block cfg >}}
[SSG_Main_Menu]

menuButtonNewGame="New Game"
menuButtonContinueGame="Continue Game"
menuButtonOptions="Options"
menuButtonCredits="Credits"
menuButtonQuit="Quit"


[SSG_Options_Menu]

menuTitleOptions="Options"
menuButtonOptionsVideo="Video"
menuButtonOptionsAudio="Audio"
menuButtonOptionsGameplay="Gameplay"
menuButtonBackMainMenu="Back"

menuTitleVideoOptions="Video"
menuLabelVideoSettingResolution="Resolution"
menuLabelVideoSettingGraphicsLevel="Graphics Quality"
menuLabelVideoSettingFullscreen="Fullscreen"
menuLabelVideoSettingGamma="Gamma"
menuButtonCancel="Cancel"
menuButtonAccept="Accept"
menuStepperGraphicsLevel0="Lowest"
menuStepperGraphicsLevel1="Low"
menuStepperGraphicsLevel2="Medium"
menuStepperGraphicsLevel3="High"
menuStepperGraphicsLevel4="Highest"

menuTitleAudioOptions="Audio Options"
menuLabelAudioVolumeMusic="Music Volume"
menuLabelAudioVolumeSound="Sound Volume"
menuLabelAudioVolumeVoice="Voice Volume"

menuTitleGameOptions="Gameplay Options"
menuLabelGameLanguage="Language"
menuLabelGameRumble="Rumble On"
menuLabelGameGoreLevel="Gore Level"
menuLabelGameGoreMaximum="Maximum"
{{< /code-block >}}
{{% /section %}}
