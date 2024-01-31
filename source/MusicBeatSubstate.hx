package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;

class MusicBeatSubstate extends FlxSubState {

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	public var controls(get, never):Controls;

	@:keep inline public function get_controls():Controls return PlayerSettings.player1.controls;
	var hasTextInputFocus = false;
	public var toggleVolKeys:Bool = true; 

	override function onFocus() {
		super.onFocus();
		CoolUtil.setFramerate(true);
	}
	override function onFocusLost(){
		super.onFocusLost();
		CoolUtil.setFramerate(24,false,true);
	}
	public function onTextInputFocus(object:Dynamic){
		if(toggleVolKeys) CoolUtil.toggleVolKeys(false);
	}
	public function onTextInputUnfocus(object:Dynamic){
		if(toggleVolKeys) CoolUtil.toggleVolKeys(true);
	}
	override function tryUpdate(elapsed:Float):Void
	{
		if(FlxG.keys.justPressed.F1){
			MainMenuState.handleError("Manually triggered force exit from substate");
		}

		if(Overlay.Console.showConsole) return; // trol
		update(elapsed);
	}
	override function update(elapsed:Float) {
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		if(FlxG.keys.justPressed.F1){
			MainMenuState.handleError("Manually triggered force exit");
		}
		super.update(elapsed);
		if(FlxG.mouse.justPressed){
			var hasPressed = false;

			var i:Int = 0;
			var basic:Dynamic = null;
			forEach(function(basic:Dynamic){
				if(!Std.isOfType(basic,flixel.addons.ui.FlxUITabMenu) && !Std.isOfType(basic,flixel.addons.ui.FlxUI) && Reflect.field(basic,"HasFocus") != null && Reflect.field(basic,"HasFocus")){
					hasPressed = true;
				}
			},true);

			// while (i < length)
			// {
			// 	basic = members[i++];

			// 	if (basic != null)
			// 	{
					
			// 	}
			// }
			if(hasTextInputFocus != hasPressed){
				hasTextInputFocus = hasPressed;
				if(hasPressed) onTextInputFocus(basic);
				else onTextInputUnfocus(basic);

			}
		}
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
