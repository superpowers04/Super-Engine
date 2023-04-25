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
    public static function initSave()
    {

    	
    	FlxG.save.bind('superengine', 'superpowers04');
    	SEFlxSaveWrapper.load();

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = true;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}




		if (FlxG.save.data.seenForcedText == null) FlxG.save.data.seenForcedText = false;
		if (FlxG.save.data.fpsCap == null || FlxG.save.data.fpsCap < 30)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine
		if (FlxG.save.data.upsCap == null || FlxG.save.data.upsCap < 30)
			FlxG.save.data.upsCap = 144;
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 2;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = false;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = true;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		

		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = "bf";


		if (FlxG.save.data.playerChar == null)
			FlxG.save.data.playerChar = "bf";

		if (FlxG.save.data.gfChar == null)
			FlxG.save.data.gfChar = "gf";

		if (FlxG.save.data.selStage == null)
			FlxG.save.data.selStage = "default";

		if (FlxG.save.data.animDebug == null)
			FlxG.save.data.animDebug = false;
		// Note Splash
		if (FlxG.save.data.noteSplash == null)
			FlxG.save.data.noteSplash = true;

		// Preformance
		if (FlxG.save.data.preformance == null)
			FlxG.save.data.preformance = false;
		// View Character on Character Select
		if (FlxG.save.data.charAuto == null) FlxG.save.data.charAuto = true;
		if (FlxG.save.data.charAutoBF == null) FlxG.save.data.charAutoBF= false;

		if (FlxG.save.data.lastServer == null)
			FlxG.save.data.lastServer = "";
		if (FlxG.save.data.lastServerPort == null)
			FlxG.save.data.lastServerPort = "";
		if (FlxG.save.data.nickname == null)
			FlxG.save.data.nickname = "";

		if (FlxG.save.data.guiGap == null) FlxG.save.data.guiGap = 0;

		if (FlxG.save.data.inputEngine == null) FlxG.save.data.inputEngine = 0;

		if (FlxG.save.data.hitSound == null) FlxG.save.data.hitSound = false;

		if (FlxG.save.data.noteAsset == null) FlxG.save.data.noteAsset = "default";

		if (FlxG.save.data.noterating == null) FlxG.save.data.noterating = true;
		if (FlxG.save.data.camMovement == null) FlxG.save.data.camMovement = true;
		if (FlxG.save.data.practiceMode == null) FlxG.save.data.practiceMode = false;
		if (FlxG.save.data.dadShow == null) FlxG.save.data.dadShow = true;
		if (FlxG.save.data.bfShow == null) FlxG.save.data.bfShow = true;
		if (FlxG.save.data.gfShow == null) FlxG.save.data.gfShow = true;

		if (FlxG.save.data.playVoices == null) FlxG.save.data.playVoices = false;
		if (FlxG.save.data.updateCheck == null) FlxG.save.data.updateCheck = true;
		if (FlxG.save.data.songUnload == null) FlxG.save.data.songUnload = true;
		if (FlxG.save.data.useBadArrowTex == null) FlxG.save.data.useBadArrowTex = true;
		if (FlxG.save.data.middleScroll == null) FlxG.save.data.middleScroll = #if(android) true #else false #end ;
		if (FlxG.save.data.oppStrumLine == null) FlxG.save.data.oppStrumLine = true;
		if (FlxG.save.data.playMisses == null) FlxG.save.data.playMisses = true;
		if (FlxG.save.data.scripts == null) FlxG.save.data.scripts = [];
		if (FlxG.save.data.songInfo == null) FlxG.save.data.songInfo = 0;
		if (FlxG.save.data.mainMenuChar == null) FlxG.save.data.mainMenuChar = false;
		if (FlxG.save.data.useFontEverywhere == null) FlxG.save.data.useFontEverywhere = false;
		if (FlxG.save.data.accurateNoteSustain == null) FlxG.save.data.accurateNoteSustain = true;
		if (FlxG.save.data.undlaSize == null) FlxG.save.data.undlaSize = 0;
		if (FlxG.save.data.undlaTrans == null) FlxG.save.data.undlaTrans = 0.1;


		if (FlxG.save.data.instVol == null) FlxG.save.data.instVol = 0.8;
		if (FlxG.save.data.masterVol == null) FlxG.save.data.masterVol = 1;
		if (FlxG.save.data.voicesVol == null) FlxG.save.data.voicesVol = 1;
		if (FlxG.save.data.missVol == null) FlxG.save.data.missVol = 0.1;
		if (FlxG.save.data.hitVol == null) FlxG.save.data.hitVol = 0.6;
		if (FlxG.save.data.otherVol == null) FlxG.save.data.otherVol = 0.6;
		if(FlxG.save.data.allowServerScripts == null) FlxG.save.data.allowServerScripts = false;
		if(FlxG.save.data.shittyMiss == null) FlxG.save.data.shittyMiss = false;
		if(FlxG.save.data.badMiss == null) FlxG.save.data.badMiss = false;
		if(FlxG.save.data.goodMiss == null) FlxG.save.data.goodMiss = false;
		if(FlxG.save.data.beatBouncing == null) FlxG.save.data.beatBouncing = true;
		if(FlxG.save.data.scrollOSUSpeed == null) FlxG.save.data.scrollOSUSpeed = 2;
		if(FlxG.save.data.packScripts == null) FlxG.save.data.packScripts = true;
		if(FlxG.save.data.luaScripts == null) FlxG.save.data.luaScripts = true;
		
		if(FlxG.save.data.judgeSick == null) FlxG.save.data.judgeSick = Ratings.getDefRating("sick");
		if(FlxG.save.data.judgeGood == null) FlxG.save.data.judgeGood = Ratings.getDefRating("good");
		if(FlxG.save.data.judgeBad == null) FlxG.save.data.judgeBad = Ratings.getDefRating("bad");
		if(FlxG.save.data.judgeShit== null) FlxG.save.data.judgeShit = Ratings.getDefRating("shit");
		if(FlxG.save.data.skipToFirst == null) FlxG.save.data.skipToFirst = true;
		if(FlxG.save.data.debounce == null) FlxG.save.data.debounce = false;
		if(FlxG.save.data.legacyCharter == null) FlxG.save.data.legacyCharter = false;
		if(FlxG.save.data.savedServers == null) FlxG.save.data.savedServers = [];

		if(FlxG.save.data.vlcSound == null) FlxG.save.data.vlcSound = true;

		#if discord_rpc
		if(FlxG.save.data.discordDRP == null) FlxG.save.data.discordDRP = true;
		#end
		if(FlxG.save.data.doCoolLoading == null) FlxG.save.data.doCoolLoading = false;
		if(FlxG.save.data.fullscreen == null) FlxG.save.data.fullscreen = false;


		if(FlxG.save.data.persistBF == null) FlxG.save.data.persistBF = false;
		if(FlxG.save.data.persistGF == null) FlxG.save.data.persistGF = false;
		if(FlxG.save.data.menuScripts == null) FlxG.save.data.menuScripts = false;

		#if android
			if(FlxG.save.data.useTouch == null) FlxG.save.data.useTouch = true;
			if(FlxG.save.data.useStrumsAsButtons == null) FlxG.save.data.useStrumsAsButtons = true;
		#end
		// if(FlxG.save.data.persistOpp == null) FlxG.save.data.persistOpp = false;

		// if(FlxG.save.data.mainMenuChar == null) FlxG.save.data.mainMenuChar = false;

		// if(FlxG.save.data.playStateObjectLocations == null) FlxG.save.data.playStateObjectLocations = new Map<String,ObjectInfo>();

	 

		Conductor.recalculateTimings();
		KeyBinds.keyCheck();
		PlayerSettings.init();
		
		// PlayerSettings.player1.controls.loadKeyBinds();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}