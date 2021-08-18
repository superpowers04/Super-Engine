package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

class QuickOptionsSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	public static var settings:Map<String,Bool> = ["Inverted chart" => false,"Opponent Arrows" => true,"Hurt notes" => true];
	var menuItems:Array<String> = [];
	var curSelected:Int = 0;
	public static function getSetting(str:String){
		if (settings[str] == null || !settings[str]) return false;
		return true;
	}

	function reloadList():Void{
		if(grpMenuShit != null) grpMenuShit.destroy();
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		menuItems = [];
		var i = 0;
		for (name => value in settings)
		{
			menuItems.push(name);
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, '${name} ${if (value) "on" else "off"}', true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			i++;
		}
		changeSelection();
	}


	public function new(x:Float, y:Float)
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.0;
		bg.scrollFactor.set();
		add(bg);


		FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
		reloadList();


		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;

		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}
		
		if (FlxG.keys.pressed.ESCAPE) close(); 

		if (accepted)
		{
			changeSetting(curSelected);
			reloadList();
		}
	}

	inline function changeSetting(sel:Int){
		settings[menuItems[sel]] = !settings[menuItems[sel]];
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}