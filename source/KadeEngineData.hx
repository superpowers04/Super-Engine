import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
    public static function initSave()
    {

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap < 30)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null) // Dammit, disabing botplay broke stuff
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		
		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = "dad";


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
		if (FlxG.save.data.charAuto == null)
			FlxG.save.data.charAuto = false;

		if (FlxG.save.data.lastServer == null)
			FlxG.save.data.lastServer = "";
		if (FlxG.save.data.lastServerPort == null)
			FlxG.save.data.lastServerPort = "";
		if (FlxG.save.data.nickname == null)
			FlxG.save.data.nickname = "";

		if (FlxG.save.data.guiGap == null) FlxG.save.data.guiGap = 0;

		if (FlxG.save.data.inputHandler == null) FlxG.save.data.inputHandler = 0;

		if (FlxG.save.data.hitSound == null) FlxG.save.data.hitSound = false;

		if (FlxG.save.data.noteAsset == null) FlxG.save.data.noteAsset = "default";

		if (FlxG.save.data.noterating == null) FlxG.save.data.noterating = true;
		if (FlxG.save.data.camMovement == null) FlxG.save.data.camMovement = true;
		if (FlxG.save.data.practiceMode == null) FlxG.save.data.practiceMode = false;
		if (FlxG.save.data.dadShow == null) FlxG.save.data.dadShow = true;
		if (FlxG.save.data.bfShow == null) FlxG.save.data.bfShow = true;
		if (FlxG.save.data.gfShow == null) FlxG.save.data.gfShow = true;
		if (FlxG.save.data.bfShow == null) FlxG.save.data.bfShow = true;

		if (FlxG.save.data.playVoices == null) FlxG.save.data.playVoices = false;
		if (FlxG.save.data.updateCheck == null) FlxG.save.data.updateCheck = true;
		if (FlxG.save.data.songUnload == null) FlxG.save.data.songUnload = true;
		if (FlxG.save.data.useBadArrowTex == null) FlxG.save.data.useBadArrowTex = true;
		if (FlxG.save.data.middleScroll == null) FlxG.save.data.middleScroll = false;
		if (FlxG.save.data.oppStrumLine == null) FlxG.save.data.oppStrumLine = true;
		if (FlxG.save.data.playMisses == null) FlxG.save.data.playMisses = true;
	 

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}