package;


import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.tweens.FlxEase;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;
	var forceQuit = true;
	public static var instance:MusicBeatState;

	var tempMessage:FlxText;
	var tempMessTimer:FlxTimer;
	var loading = true;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		if (transIn != null)
			trace('reg ' + transIn.region);
		instance = this;
		super.create();

		tranIn();
	}
	

	public function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME,?time = 5,?center:Bool = true){
		if (tempMessage != null && tempMessTimer != null){tempMessage.destroy();tempMessTimer.cancel();}
		trace(str);
		tempMessage = new FlxText(40,60,1000,str,24);
		tempMessage.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		tempMessage.scrollFactor.set();
		tempMessage.autoSize = false;
		tempMessage.width = 1280;
		tempMessage.height = 720;
		tempMessage.textField.width = 1280;
		tempMessage.textField.height = 720;
		if(center){
			tempMessage.alignment = CENTER;
			tempMessage.screenCenter(X);
		}
		// tempMessage.wordWrap = false;
		add(tempMessage);
		tempMessTimer = new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (tempMessage != null) tempMessage.destroy();
		},1);
	}

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();
		if(FlxG.keys.justPressed.F1 && forceQuit){
			MainMenuState.handleError("Manually triggered force exit");
		}

		if (oldStep != curStep && curStep > 0)
			stepHit();


		if ((cast (Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		if(FlxG.save.data.animDebug){
			Overlay.debugVar = '\nBPM:${Conductor.bpm}/${HelperFunctions.truncateFloat(Conductor.crochet,2)}MS(S:${HelperFunctions.truncateFloat(Conductor.stepCrochet,2)}MS)\ncurBeat:${curBeat}\ncurStep:${curStep}';
		}

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{

		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}
	override function switchTo(nextState:FlxState):Bool{
		tranOut();
		FlxG.mouse.visible = false;
		return super.switchTo(nextState);
	}

	function tranIn(){ // Replace with empty functions to disable
		
		var oldY = FlxG.camera.x;
		FlxG.camera.x -= 300;
		FlxTween.tween(FlxG.camera, {x:oldY},0.7,{ease: FlxEase.expoOut});
		var oldZoom = FlxG.camera.zoom;
		FlxG.camera.zoom += 1;
		FlxTween.tween(FlxG.camera, {zoom:oldZoom},0.7,{ease: FlxEase.expoOut});
		LoadingScreen.hide();
		
	}
	function tranOut(){
		// active = false;
		
		if(loading) LoadingScreen.show();
		
		
		
		FlxTween.tween(FlxG.camera, {x:FlxG.width},0.9,{ease: FlxEase.expoIn});
		FlxTween.tween(FlxG.camera, {zoom:2},1,{ease: FlxEase.expoIn});

	}
}
