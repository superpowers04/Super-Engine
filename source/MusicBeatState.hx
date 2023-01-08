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
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import flixel.FlxBasic;

import flixel.group.FlxGroup.FlxTypedGroup;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curStepProgress:Float = 0;
	public var curBeat:Int = 0;
	private var controls(get, never):Controls;
	var forceQuit = true;
	public static var instance:MusicBeatState;

	var loading = true;
	public function onFileDrop(file:String):Null<Bool>{
		return true;
	}
	var mouseEnabledTmr:FlxTimer;
	override function onFocus() {
		super.onFocus();
		CoolUtil.setFramerate(true);
		mouseEnabledTmr = new FlxTimer().start(0.25,function(_){FlxG.mouse.enabled = true;});
	}
	override function onFocusLost(){
		super.onFocusLost();
		CoolUtil.setFramerate(24,false,true);
		if(mouseEnabledTmr != null)mouseEnabledTmr.cancel();
		FlxG.mouse.enabled = false;
	}
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	override function create()
	{
		CoolUtil.setFramerate(true);

		instance = this;
		super.create();

		tranIn();
	}
	
	var tempMessBacking:FlxSprite;
	var tempMessage:FlxText;
	var tempMessTimer:FlxTimer;
	public function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME,?time = 5,?center:Bool = true,?trac:Bool = true){
		if (tempMessage != null){
			remove(tempMessage);
			tempMessage.destroy();

		}
		if (tempMessage != null && tempMessTimer != null){
			tempMessTimer.cancel();}
		if(tempMessBacking != null){
			remove(tempMessBacking);
			tempMessBacking.destroy();
		}
		if(trac) trace(str);
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
		tempMessBacking = new FlxSprite(tempMessage.x - 2,tempMessage.y - 2).loadGraphic(FlxGraphic.fromRectangle(Std.int(tempMessage.width + 4),Std.int(tempMessage.height + 4),0xaa000000));
		tempMessBacking.scrollFactor.set();
		if(FlxG.cameras.list[FlxG.cameras.list.length - 1] != null){
			tempMessBacking.cameras = tempMessage.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}
		add(tempMessBacking);
		add(tempMessage);
		tempMessTimer = new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (tempMessage != null) tempMessage.destroy();
			if (tempMessBacking != null) tempMessBacking.destroy();
		},1);
	}

	var skippedFrames = 0;
	var checkInputFocus:Bool = true;
	var hasTextInputFocus = false;
	public var toggleVolKeys:Bool = true; 
	public function onTextInputFocus(object:Dynamic){
		if(toggleVolKeys) CoolUtil.toggleVolKeys(false);
	}
	public function onTextInputUnfocus(object:Dynamic){
		if(toggleVolKeys) CoolUtil.toggleVolKeys(true);
	}

	// public var UIElements:Array<Dynamic> = [];
	public var uiMap:Map<String,Dynamic> = new Map<String,Dynamic>(); 
	inline function clearUIMap(){
		for (i => v in uiMap){
			if (v != null && v.destroy != null) v.destroy();
			uiMap[i] = null;
		}
	}
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();
		if(FlxG.keys.justPressed.F3){
			var mess = 'Global Mouse pos: ${FlxG.mouse.x},${FlxG.mouse.y}; Screen mouse pos: ${FlxG.mouse.screenX},${FlxG.mouse.screenY}; member count: ${members.length}'; 
			// trace(mess);
			showTempmessage(mess);
		}
		if(FlxG.keys.justPressed.F4 && forceQuit){
			throw("Manually triggered error");
		}

		if (oldStep != curStep && curStep > 0)
			stepHit();
		if(FlxG.mouse.justPressed && checkInputFocus && FlxG.mouse.visible){
			var hasPressed = false;

			var i:Int = 0;
			var obj:Dynamic = null;
			try{

				forEach(function(basic:Dynamic){
					try{

						if(!Std.isOfType(basic,flixel.addons.ui.FlxUITabMenu) && !Std.isOfType(basic,flixel.addons.ui.FlxUI) && Reflect.field(basic,"HasFocus") != null && Reflect.field(basic,"HasFocus")){
							obj = basic;
							hasPressed = true;
						}
					}catch(e){trace('oh no i errored while checking for a item');}
				},true);
				if(!hasPressed){
					for (i => obj in uiMap){
						if(obj != null && Reflect.field(obj,"HasFocus") != null && Reflect.field(obj,"HasFocus")) hasPressed = true; break;
					}
					
				}
			}catch(e){trace('oh no i errored while checking for a item');}

			// while (i < length)
			// {
			// 	basic = members[i++];

			// 	if (basic != null)
			// 	{
					
			// 	}
			// }
			if(hasTextInputFocus != hasPressed){
				hasTextInputFocus = hasPressed;
				if(hasPressed) onTextInputFocus(obj);
				else onTextInputUnfocus(obj);

			}
		}
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
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime){
				lastChange = Conductor.bpmChangeMap[i];
			}else break;
		}

		var prog = (Conductor.offset + Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet;
		curStepProgress = prog % 1;
		curStep = lastChange.stepTime + Math.floor(prog);
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
		FlxG.mouse.enabled = true;
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


	public var debugMode:Bool = false;
	public var debugOverlay:DebugOverlay;
	override function tryUpdate(elapsed:Float):Void
	{
		if(FlxG.keys.justPressed.F1 && forceQuit){
			MainMenuState.handleError("Manually triggered force exit");
		}
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F8){
			debugMode = !debugMode;
			if(debugMode){
				debugOverlay = new DebugOverlay();
			}else{
				debugOverlay.destroy();
			}
		}
		if(debugMode)
			debugOverlay.update(elapsed);
		else 
			if ((persistentUpdate || subState == null))
				update(elapsed);

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
		{
			subState.tryUpdate(elapsed);
		}
	}


	override function draw(){
		super.draw();
		if(debugMode)
			debugOverlay.draw();
	}
}




class DebugOverlay extends FlxTypedGroup<FlxSprite>{
	var bg:FlxSprite;
	override public function new(){
		mouseEnabled = FlxG.mouse.visible;
		FlxG.mouse.visible = true;
		super();
		MusicBeatState.instance.showTempmessage('Entered Debug mode');
	}
	
	var obj:FlxObject;
	var ox:Float = 0;
	var oy:Float = 0;
	var mx:Float = 0;
	var my:Float = 0;
	var mouseEnabled:Bool = false;
	override function update(el:Float){
		super.update(el);
		if(FlxG.mouse.justPressed){
			var id = MusicBeatState.instance.members.length - 1;
			mx=FlxG.mouse.x;
			my=FlxG.mouse.y;
			while (id >= 0 && obj == null) {
				try{
					var _ob:Dynamic = MusicBeatState.instance.members[id];
					if(_ob != null  && FlxG.mouse.overlaps(_ob)){
						obj = cast (_ob,FlxSprite);
						// trace('Funni click on ${obj}');
							// break;
					}

				}catch(e){obj = null;}
				id--;
			}
			if(obj != null){
				ox=obj.x;
				oy=obj.y;
			}
			
		}else if (FlxG.mouse.pressed && obj != null){
			// if(!FlxG.keys.pressed.SHIFT){
			obj.x = ox - mx + FlxG.mouse.x;
			obj.y = oy - my + FlxG.mouse.y;

			// }
			MusicBeatState.instance.showTempmessage('Obj pos: ${obj.x},${obj.y}');
			if(FlxG.mouse.wheel != 0){
				obj.angle += FlxG.mouse.wheel;
			}

		}else if(obj != null){
			// if(FlxG.keys.pressed.SHIFT){
			// 	obj.velocity.x = (mx - FlxG.mouse.x) * 0.01;
			// 	obj.velocity.y = (my - FlxG.mouse.y) * 0.01;
			// }
			obj = null;
		}
	}
	override function destroy(){
		FlxG.mouse.visible = mouseEnabled;
		super.destroy();
		MusicBeatState.instance.showTempmessage('Exited Debug mode');
	}
}