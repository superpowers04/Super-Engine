package se.substates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

@:structInit @:publicFields class QLoption{
	var max:Float = 1;
	var min:Float = 0;
	var type:Int = 0; // 0 = bool, 1 = int, 2 = float
	var value:Dynamic;
	var description:String = "";
	var name:String = "";
}
class QuickList extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var settings:Array<QLoption> = [];
	var curSelected:Int = 0;
	var infotext:FlxText;
	var toptext:FlxText;

	function reloadList():Void{
		grpMenuShit.clear();
		var i = 0;
		for (name => value in settings) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, '${value.name}', true, false,70,false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			i++;
		}
		changeSelection();
	}


	override public function create(){
		super.create();
		FlxG.state.persistentUpdate = false;
		FlxG.state.persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.0;
		bg.scrollFactor.set();
		add(bg);
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		var infotexttxt:String = "";
		infotext = new FlxText(5, FlxG.height - 40, FlxG.width - 100, infotexttxt, 16);
		infotext.wordWrap = true;
		infotext.scrollFactor.set();
		infotext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		toptext = new FlxText(5, 40, FlxG.width - 100, "< Switch mode", 16);
		toptext.scrollFactor.set();
		toptext.setFormat(CoolUtil.font, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		toptext.screenCenter(X);
		add(toptext);
		var blackBorder = new FlxSprite(-30,FlxG.height - 40).makeGraphic((Std.int(FlxG.width)),Std.int(50),FlxColor.BLACK);
		blackBorder.alpha = 0.5;
		add(blackBorder);
		add(infotext);
		FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
		reloadList();
		changeSelection(0);
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float) {

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;
		if(FlxG.mouse.justReleased){
			if(!FlxG.mouse.overlaps(toptext)){
				settings[curSelected].value();
			}
			close();
		}
		if(FlxG.mouse.wheel != 0){
			changeSelection(FlxG.mouse.wheel);
		}
		if (upP){
			changeSelection(-1);
		}else if (downP){
			changeSelection(1);
		}
		
		if (FlxG.keys.pressed.ESCAPE){
			quit();
		}

		if (accepted && settings[curSelected].type != 1) {settings[curSelected].value();close();}
	}
	function quit(){
		close();
	}
	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0) curSelected = settings.length - 1;
		if (curSelected >= settings.length) curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = ((item.targetY == 0) ? 1 : 0.6);
		}
		infotext.text = settings[curSelected]?.description ?? "No description";
	}
}