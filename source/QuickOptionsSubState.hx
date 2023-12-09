package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
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

	static inline var BOOL=0;
	static inline var INT=1;
	static inline var FLOAT=2;
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	public static var normalSettings:Map<String,QOSetting> = [
			"Inverted chart" => {type:BOOL,value:false},
			"Swap characters" => {type:BOOL,value:false},
			"Opponent arrows" => {type:BOOL,value:true},
			"Song hscripts" => {type:BOOL,value:true},
			"Custom Arrows" => {type:BOOL,value:true},
			"Scroll speed" => {type:FLOAT,value:0,min:-10,max:10
				#if(!hl),lang:[0 => "Chart"] #end

			},
			"Song Speed" => {type:FLOAT,value:1,min:0.1,max:10
				#if(!hl),lang:[1 => "Normal"] #end
			}, // Not a stolen idea, dunno what you mean
			"Flippy mode" => {type:BOOL,value:false
				#if(!hl) ,lang:[false => "off",true => "I love pain"] #end
			},
			"BotPlay" => {type:BOOL,value:false}
		];
	static var defSettings:Map<String,QOSetting> = normalSettings.copy();
	public static var osuSettings:Map<String,QOSetting> = [
			"Scroll speed" => {type:FLOAT,value:0,min:0,max:10
				#if(!hl), lang:[0 => "User Set"] #end
			}
		];
	var settings:Map<String,QOSetting> = [];
	var menuItems:Array<String> = [];
	var curSelected:Int = 0;
	var infotext:FlxText;
	public static function getSetting(setting:String):Dynamic{
		return (if(PlayState.isStoryMode) defSettings[setting].value else normalSettings[setting].value);
	}
	public static function setSetting(setting:String,value:Dynamic){
		normalSettings[setting].value = value;
	}
	inline function setValue(str:String,value:Dynamic){
		settings[str].value = value;
	}
	var _callback:() -> Void;
	var _enabledMouse:Bool = false;
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


	public function new(?callback:() -> Void)
	{
		_callback = callback;
		_enabledMouse = FlxG.mouse.visible;
		FlxG.mouse.visible = false;
		FlxG.mouse.enabled = false;
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
	override function destroy(){
		FlxG.mouse.visible = _enabledMouse;
		FlxG.mouse.enabled = true;
		if(_callback != null) _callback();
		super.destroy();
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

		if (upP) changeSelection(-1);
  		else if (downP) changeSelection(1);
		
		
		if (FlxG.keys.pressed.ESCAPE){saveSettings();close();} 
		#if(mobile)
		if(FlxG.mouse.pressed && FlxG.mouse.screenX < 30){
			saveSettings();
			close();
		}
		// TODO, ADD TOUCH SUPPORT
		#end
		if (accepted && settings[menuItems[curSelected]].type != 1) changeSetting(curSelected);
		if (leftP || rightP) changeSetting(curSelected,rightP);
	}

	function changeSetting(sel:Int,?dir:Bool = true){
		if (settings[menuItems[sel]].type == BOOL) setValue(menuItems[sel],settings[menuItems[sel]].value = !settings[menuItems[sel]].value );
		if (settings[menuItems[sel]].type == INT || settings[menuItems[sel]].type == FLOAT) {
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

		if (curSelected < 0) curSelected = menuItems.length - 1;
		else if (curSelected >= menuItems.length) curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members){
			item.targetY = bullShit - curSelected;
			item.alpha = (item.targetY == 0 ? 1 : 0.6);
			bullShit++;
		}
	}
}