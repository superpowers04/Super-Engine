import openfl.Lib;
import flixel.FlxG;

typedef ObjectInfo = {
	var x:Float;
	var y:Float;
	// var isGroup:Bool;
	var ?subObjects:Map<String,ObjectInfo>;
}


class KadeEngineData
{
	static var defaultOptions:Map<String,Dynamic> = [
		// Performance
		'fpsCap' => 120,
		'preformance' => false,
		// Gameplay
		'downscroll' => false,
		'offset' => 0,
		'changedHitX' => -1,
		'changedHitY' => -1,
		'changedHit' => false,
		'seenForcedText' => false,
		'scrollSpeed' => 1,
		'ghost' => false,
		'frames' => 10,
		// Display
		'watermark' => true,
		'accuracyDisplay' => true,
		'songPosition' => true,
		'fps' => false,
		'flashing' => true,
		'npsDisplay' => false,
		'accuracyMod' => 2,
		'distractions' => true,
		'resetButton' => false,
		'botplay' => false,
		'cpuStrums' => true,
		'strumline' => false,
		// Modification stuff
		'opponent' => "bf",
		'playerChar' => "bf",
		'gfChar' => "gf",
		'selStage' => "default",
		'animDebug' => false,
		'noteSplash' => true,
		'charAuto' => true,
		'stageAuto' => true,
		'charAutoBF' => false,
		'lastServer' => "",
		'lastServerPort' => "",
		'nickname' => "",
		'guiGap' => 0,
		'inputEngine' => 1,
		'hitSound' => false,
		'noteAsset' => "default",
		'noterating' => true,
		'camMovement' => true,
		'practiceMode' => false,
		'dadShow' => true,
		'bfShow' => true,
		'gfShow' => true,
		'playVoices' => false,
		'updateCheck' => true,
		'songUnload' => true,
		'useBadArrowTex' => true,
		'middleScroll' => #if(android) true #else false #end ,
		'oppStrumLine' => true,
		'playMisses' => true,
		'scripts' => [],
		'songInfo' => 0,
		'mainMenuChar' => false,
		'useFontEverywhere' => false,
		'accurateNoteSustain' => true,
		'undlaSize' => 0,
		'undlaTrans' => 0.1,
		'instVol' => 0.8,
		'masterVol' => 1,
		'voicesVol' => 1,
		'missVol' => 0.1,
		'hitVol' => 0.6,
		'otherVol' => 0.6,
		'allowServerScripts' => false,
		'shittyMiss' => false,
		'badMiss' => false,
		'goodMiss' => false,
		'beatBouncing' => true,
		'scrollOSUSpeed' => 2,
		'packScripts' => true,
		'luaScripts' => true,
		'judgeSick' => Ratings.getDefRating("sick"),
		'judgeGood' => Ratings.getDefRating("good"),
		'judgeBad' => Ratings.getDefRating("bad"),
		'judgeShit' => Ratings.getDefRating("shit"),
		'skipToFirst' => true,
		'debounce' => false,
		'legacyCharter' => false,
		'savedServers' => [],
		'discordDRP' => true,
		'doCoolLoading' => false,
		'fullscreen' => false,
		'persistBF' => false,
		'persistGF' => false,
		'menuScripts' => false,
		'easterEggs' => true,
		'useTouch' => true,
		'useStrumsAsButtons' => true,
		'chartRepo'=>'https://raw.githubusercontent.com/superpowers04/FNFBR-Repo/main/charts.json',
		'charRepo'=>'https://raw.githubusercontent.com/superpowers04/FNFBR-Repo/main/characters.json',
		"upBind" => "W",
		"downBind" => "S",
		"leftBind" => "A",
		"rightBind" => "D",
		"killBind" => "R",
		"gpupBind" => "DPAD_UP",
		"gpdownBind" => "DPAD_DOWN",
		"gpleftBind" => "DPAD_LEFT",
		"gprightBind" => "DPAD_RIGHT",
		"AltupBind" => "N",
		"AltdownBind" => "X",
		"AltleftBind" => "Z",
		"AltrightBind" => "M",
		'lastUpdateID' => MainMenuState.versionIdentifier,
		'useHurtArrows' => false,
		// 'persistOpp' => false,
		// 'mainMenuChar' => FlxG.save.data.mainMenuChar = false,
		// 'playStateObjectLocations' = new Map<String,ObjectInfo>(),
	];
    public static function initSave()
    {

    	
    	FlxG.save.bind('superengine', 'superpowers04');
    	SEFlxSaveWrapper.load();
		var _data = FlxG.save.data; 
		for(key => value in defaultOptions) if(Reflect.field(_data,key) == null) {Reflect.setField(_data,key,value);trace('Updated ${key} to ${value}');}

		MainMenuState.lastVersionIdentifier = FlxG.save.data.lastUpdateID;
		FlxG.save.data.lastUpdateID = MainMenuState.versionIdentifier;
		if(MainMenuState.lastVersionIdentifier != MainMenuState.versionIdentifier){ // This is going to be ugly but only executed every time the game's updated
			var lastVersionIdentifier = MainMenuState.lastVersionIdentifier;
			if(lastVersionIdentifier < 1)
				FlxG.save.data.inputEngine = 1; // Update to new input
		}


	 

		Conductor.recalculateTimings();
		// KeyBinds.keyCheck();
		PlayerSettings.init();
		
		// PlayerSettings.player1.controls.loadKeyBinds();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}