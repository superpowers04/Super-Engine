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

typedef QOSetting={
	var ?max:Float;
	var ?min:Float;
	var ?lang:Map<Dynamic,String>;
	var value:Dynamic;
	var type:Int;
}

class QuickOptionsSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	public static var normalSettings:Map<String,QOSetting> = [
			"Inverted chart" => {type:0,value:false},
			"Swap characters" => {type:0,value:false},
			"Opponent arrows" => {type:0,value:true},
			"Song hscripts" => {type:0,value:true},
			"Custom Arrows" => {type:0,value:true},
			"Scroll speed" => {type:2,value:0,min:0,max:10,lang:[0 => "Chart"]},
			"Flippy mode" => {type:0,value:false,lang:[false => "off",true => "I love pain"]}
		];
	public static var osuSettings:Map<String,QOSetting> = [
			"Scroll speed" => {type:2,value:0,min:0,max:10,lang:[0 => "User Set"]}
		];
	var settings:Map<String,QOSetting> = [];
	var menuItems:Array<String> = [];
	var curSelected:Int = 0;
	var infotext:FlxText;
	public static function getSetting(setting:String):Dynamic{
		return normalSettings[setting].value;
	}
	public static function setSetting(setting:String,value:Dynamic){
		normalSettings[setting].value = value;
	}
	inline function setValue(str:String,value:Dynamic){
		settings[str].value = value;
	}

	function reloadList():Void{
		if(grpMenuShit != null) grpMenuShit.destroy();
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		menuItems = [];
		var i = 0;
		for (name => setting in settings)
		{
			menuItems.push(name);
			var val = setting.value;
			if (setting.lang != null && setting.lang[setting.value] != null) val = setting.lang[setting.value];
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, '${name}: ${val}', true, false,70);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			i++;
		}
		changeSelection();
	}


	public function new()
	{
		super();
		loadSettings();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.5}, 0.4, {ease: FlxEase.quartInOut});
		reloadList();
		changeSelection(0);


		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	function saveSettings(){
		normalSettings = settings;
	}
	function loadSettings(){
		settings = normalSettings;
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
		
		if (FlxG.keys.pressed.ESCAPE){saveSettings();close();} 

		if (accepted && settings[menuItems[curSelected]].type != 1) changeSetting(curSelected);
		if (leftP || rightP) changeSetting(curSelected,rightP);
	}

	function changeSetting(sel:Int,?dir:Bool = true){
		if (settings[menuItems[sel]].type == 0) setValue(menuItems[sel],settings[menuItems[sel]].value = !settings[menuItems[sel]].value );
		if (settings[menuItems[sel]].type == 1 || settings[menuItems[sel]].type == 2) {
			var val = settings[menuItems[sel]].value;
			var inc:Float = 1;
			if(settings[menuItems[sel]].type == 2 && FlxG.keys.pressed.SHIFT) inc=0.1;
			val += if(dir) inc else -inc;
			if (val > settings[menuItems[sel]].max) val = settings[menuItems[sel]].min; 
			if (val < settings[menuItems[sel]].min) val = settings[menuItems[sel]].max - 1; 
			setValue(menuItems[sel],val);
		}


		reloadList();
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