package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;

class MusicBeatSubstate extends FlxSubState {

	private var oldBeat:Int = 0;
	private var oldStep:Int = -1000;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curStepProgress:Float = 0;
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

	// Have to keep track of steps, else they'll try to hit multiple times
	override function update(elapsed:Float) {
		updateSteps();


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
	@:keep inline public function updateSteps(){
		updateCurStep();
		updateBeat();
		if (oldStep != curStep && curStep > 0){
			if(oldStep > curStep && Conductor.bpmChangeMap != null){ // Gotta resync the 
				// var position = Conductor.songPosition;
				var newStep = curStep;
				for(ev in Conductor.bpmChangeMap){
					if(ev.stepTime < newStep){
						curStep = ev.stepTime;
						updateCurStep();
						updateBPMChange();
					}else break;
				}
				curStep = newStep;
				// Conductor.songPosition = position;
			}
			oldStep = curStep;
			stepHit();
			updateBPMChange();
		}
	}
	private function updateBeat():Void {
		oldBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}


	public var lastBPMChange:BPMChangeEvent = {
		stepTime: 0,
		songTime: 0,
		bpm: Conductor.bpm
	};
	private function updateCurStep():Void {
		// if(Conductor.bpmChangeMap != null){
			
		// 	for (i in 0...Conductor.bpmChangeMap.length)
		// 	{
		// 		if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime){
		// 			lastChange = Conductor.bpmChangeMap[i];
		// 		}else break;
		// 	}
		// }


		var prog = (Conductor.offset + Conductor.songPosition - lastBPMChange.songTime) / Conductor.stepCrochet;
		curStepProgress = prog % 1;
		curStep = lastBPMChange.stepTime + Math.floor(prog);
		
	}
	@:keep inline function updateBPMChange(){
		if(Conductor.songPosition > 0 && Conductor.bpmChangeMapSteps != null && Conductor.bpmChangeMapSteps[curStep] != null){
			Conductor.changeBPM((lastBPMChange = Conductor.bpmChangeMapSteps[curStep]).bpm);
		}
	}

	public function stepHit():Void {
		if (curStep % 4 == 0 && oldBeat != curBeat){
			oldBeat = curBeat;
			beatHit();
		}
	}

	public function beatHit():Void {
		//do literally nothing dumbass
	}
}
