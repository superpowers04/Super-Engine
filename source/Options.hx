package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import hscript.Interp;
import flixel.system.scaleModes.*;
import se.stores.CharacterStore;

import QuickOptionsSubState;

using StringTools;

// TODO: Simplify every option that doesn't have a special function or whatever 

class OptionCategory
{
	public var options(default,null):Array<Option> = new Array<Option>();
	public var modded:Bool = false;
	public var description:String = "";
	@:keep inline public final function getOptions():Array<Option>
	{
		return options;
	}

	@:keep inline public final function addOption(opt:Option)
	{
		options.push(opt);
	}

	
	@:keep inline public final function removeOption(opt:Option)
	{
		options.remove(opt);
	}

	public var name(default,null):String = "New Category";

	public function new(catName:String, options:Array<Option>,?desc:String = "",?mod:Bool = false)
	{
		description = desc;
		name = catName;
		this.options = options;
		this.modded = mod;
	}
	public function update(e:Float){}
	public function draw(){}
}

class Option
{
	public function new(){
		display = updateDisplay();
	}
	public var description(default,null):String = "";
	public var display(default,null):String = "";
	public var acceptValues(default,null):Bool = false;
	public var isVisible(default,null):Bool = true;
	public function offline():Option{
		if(onlinemod.OnlinePlayMenuState.socket != null) isVisible = false;
		return this;
	}

	public function getValue():String { return throw "stub!"; };
	
	// Returns whether the label is to be updated.
	// why the fuck would *all* of these throw an error
	public function press():Bool { return right(); }
	public function updateDisplay():String { return display; }
	public function left():Bool { return false; }
	public function right():Bool { return false; }
	public function update(e:Float){}
	public function draw(){}
}



class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls){
		super();
		this.controls = controls;
		description = 'Change your controls';
		display = "Key Bindings >";
		// acceptValues = true;
	}

	public override function press():Bool{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}
}




class SEJudgement extends Option
{
	var name = "";
	var def:Float = 0.1;
	var glob:Float = 0;
	public function new(name:String)
	{
		this.name = name;
		display = '$name hit window';
		// this.def = def;
		super();
		description = 'Adjust your hit window for $name';
		acceptValues = true;
		glob = Reflect.getProperty(SESave.data,"judge" + name);
		// trace('$name - $glob');
	}
	function setVal(val:Float){
		if(val > 1){val = 0.01;}
		if(val < 0.01){val = 0.99;}
		// trace('' + glob + ' -> ' + val);
		glob = val;
		Reflect.setField(SESave.data,"judge" + name,val);
	}
	public override function press():Bool
	{
		var _def:Float = 0.0;

		_def = Ratings.getDefRating(name);
		setVal(_def);
		return true;
	}

	override function updateDisplay():String return name + " hit timing";

	override function right():Bool {

		setVal(glob - (FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT ? 0.01 : 0.1));
		return true;
	}

	override function left():Bool {

		setVal(glob + (FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT ? 0.01 : 0.1));
		return true;
	}

	override function getValue():String {
		return '${name} hit Window: ${Ratings.ratingMS("",glob)} MS, ${100 - Math.round(glob * 100)}% of ${Math.round((166 * Conductor.timeScale) * 100) * 0.01} MS';
	}
}
class Judgement extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Safe Frames";
	}

	override function left():Bool {
		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		SESave.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames +
		" TOTAL:" +    CoolUtil.truncateFloat(Conductor.safeZoneOffset,0) + "ms" +
		" | SICK: " +  CoolUtil.truncateFloat(45 * Conductor.timeScale, 0) +
		"ms, GOOD: " + CoolUtil.truncateFloat(90 * Conductor.timeScale, 0) +
		"ms, BAD: " +  CoolUtil.truncateFloat(125 * Conductor.timeScale, 0) + 
		"ms, SHIT: " + CoolUtil.truncateFloat(156 * Conductor.timeScale, 0) +
		"ms";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		SESave.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}


// TODO: Seperate into FPS and UPS
class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		display = "FPS Cap";
		acceptValues = true;
	}

	public override function press():Bool
	{
		CoolUtil.setFramerate(Application.current.window.displayMode.refreshRate);
		return true;
	}
	override function right():Bool {
		CoolUtil.setFramerate(CoolUtil.Framerate + 1);
		return true;
	}

	override function left():Bool {
		CoolUtil.setFramerate(CoolUtil.Framerate - 1);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + CoolUtil.Framerate + ((CoolUtil.Framerate == Application.current.window.displayMode.refreshRate) ? " (Refresh Rate)" : (CoolUtil.Framerate == Application.current.window.frameRate) ? " (Frame Rate)" : " (Software)");
	}
}



class AccuracyDOption extends Option {
	final names:Array<String> = ["Simple","Etterna",'SE'];
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool {
		SESave.data.accuracyMod++;
		if(SESave.data.accuracyMod > names.length) SESave.data.accuracyMod = 0;
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String return "Accuracy Mode: " + names[SESave.data.accuracyMod];
}

class CustomizeGameplay extends Option
{
	public function new(desc:String) {
		super();
		description = desc;
		display = "Customize Gameplay";
	}

	public override function press():Bool{
		LoadingScreen.loadAndSwitchState(new GameplayCustomizeState());
		return false;
	}
}
	
	
// Added options
class PlayerOption extends Option
{
	public static var playerEdit:Int = 0;
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Player Character >";
	}

	public override function press():Bool
	{
		playerEdit = 0;
		FlxG.switchState(new CharSelection());
		return true;
	}


	override function getValue():String {
		return "Current Player: " + ('${SESave.data.playerChar}').replace('null|',"");
	}
}
class GFOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "GF Character >";
	}
	public override function press():Bool
	{
		PlayerOption.playerEdit = 2;
		FlxG.switchState(new CharSelection());
		return true;
	}

	override function getValue():String {
		return "Current GF: " + ('${SESave.data.gfChar}').replace('null|',"");
	}
}
class OpponentOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Opponent Character >";
	}
	public override function press():Bool
	{
		PlayerOption.playerEdit = 1;
		FlxG.switchState(new CharSelection());
		return true;
	}


	override function getValue():String {
		return "Current Opponent: " + ('${SESave.data.opponent}').replace('null|',"");
	}

}


class GUIGapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "GUI Gap";
	}

	public override function press():Bool {
		SESave.data.guiGap = 0;
		return true;
	}

	override function right():Bool {
		SESave.data.guiGap += 1;

		return true;
	}

	override function left():Bool {
		SESave.data.guiGap -= 1;
		return true;
	}

	override function getValue():String
	{
		return 'Hud distance: ${SESave.data.guiGap}, Press enter to reset to 0';
	}
}
class SelStageOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Selected Stage >";

	}
	public override function press():Bool
	{
		FlxG.switchState(new StageSelection());
		return true;
	}

	override function getValue():String {
		return "Current Stage: " + SESave.data.selStage;
	}

}
class ReloadCharlist extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Reload Char/Stage List";
	}
	public static function RELOAD(){
		SELoader.AssetPathCache = [];
		TitleState.registerCustomContent();
		TitleState.loadNoteAssets(true,true);
	}
	public override function press():Bool
	{
		RELOAD();

		// SickMenuState.reloadMusic = true;
		return true;
	}

	override function getValue():String {
		return '${CharacterStore.characters.length} char${CoolUtil.multiInt(CharacterStore.characters.length)}, and ${TitleState.stages.length} stage${CoolUtil.multiInt(TitleState.stages.length)} recognized';
	}

}
class InputEngineOption extends Option
{
	var ies:Array<String> = ["Super Engine Legacy", "Super Engine (Keyboard only)"];
	var iesDesc:Array<String> = ["Legacy input; A custom input engine based off of Kade 1.4/1.5.", "A new input engine that is based off of key events; Usually faster"];
	public function new(desc:String)
	{
		acceptValues = true;
		super();
		if (SESave.data.inputEngine >= ies.length) SESave.data.inputEngine = 0;
		description = desc;
		display = 'Input Engine';
		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[SESave.data.inputEngine];
	}

	override function right():Bool {
		SESave.data.inputEngine += 1;
		if (SESave.data.inputEngine >= ies.length) SESave.data.inputEngine = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		SESave.data.inputEngine -= 1;
		if (SESave.data.inputEngine < 0) SESave.data.inputEngine = ies.length - 1;
		display = updateDisplay();
		return true;
	}
}
class NoteSelOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Note Style Selection >";

	}
	public override function press():Bool
	{
		FlxG.switchState(new ArrowSelection());
		return true;
	}

	override function getValue():String {
		return "Current note style: " + SESave.data.noteAsset;
	}
}

class SongInfoOption extends Option
{
	var ies:Array<String> = ["Opposite of scroll direction","side","Advanced Side","vanilla + misses","Disabled"];
	var iesDesc:Array<String> = ["Kade 1.7 styled","Show on the side","Also shows judgements","Vanilla styled with misses","Disabled altogether"];
	public function new(desc:String)
	{
		super();
		if (SESave.data.songInfo >= ies.length) SESave.data.songInfo = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[SESave.data.songInfo];
	}

	override function right():Bool {
		SESave.data.songInfo += 1;
		if (SESave.data.songInfo >= ies.length) SESave.data.songInfo = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		SESave.data.songInfo -= 1;
		if (SESave.data.songInfo < 0) SESave.data.songInfo = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	override function updateDisplay():String{
		return 'Song Info: ${ies[SESave.data.songInfo]}';
	}
}
class FullscreenOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		SESave.data.fullscreen = (FlxG.fullscreen = !FlxG.fullscreen);
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String
	{
		return "Fullscreen " + (!SESave.data.fullscreen ? "off" : "on");
	}

}


class SelScriptOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Toggle scripts >";
	}
	public override function press():Bool
	{
		FlxG.switchState(new ScriptSel());
		return true;
	}


	override function getValue():String {
		return "Current Script count: " + SESave.data.scripts.length;
	}

}
class ScrollSpeedOption extends HCFloatOption{
	public var note:Note;
	public var strum:StrumArrow;
	var hasLoaded:Bool = false;
	var pressed:Bool = true;
	override public function new(){
		super('Scroll Speed',"Change your scroll speed (1 = Chart dependent)","scrollSpeed",0.1,10,0.1);
	}
	override public function update(e:Float){
		if(!hasLoaded){
			hasLoaded = true;
			try{
				note = new Note(0,SESave.data.downscroll ? 1 : 2);
				strum = new StrumArrow(SESave.data.downscroll ? 1 : 2);
				note.parentSprite = strum;
				note.inCharter = note.visible = note.showNote = true;
				strum.init();
				strum.playStatic();
				strum.x = 1000;
				note.x = strum.x + (strum.width * 0.5);
				strum.y = SESave.data.downscroll ? 360 : 120;
			}catch(e){
				trace('Failed to load note for Scroll Speed ${e}');
			}
		}
		if(note == null || strum == null) return;
		Conductor.update();

		strum.update(e);
		note.update(e);
		note.y = 1920;
		// trace(dist);

	}
	override public function draw(){
		if(note == null || strum == null) return;
		var dist = ((Conductor.songPosition+FlxG.elapsed*0.001) - note.strumTime);
		var _scrollSpeed = SESave.data.scrollSpeed;
		Conductor.update();
		if(dist > 1000 || dist < -3000 || pressed){
			pressed = false;
			note.strumTime = (Std.int(Conductor.songPosition / Conductor.crochet)+2)*Conductor.crochet;
		}
		if(!pressed && dist > -20 && dist < 100){
			strum.confirm();
			note.alpha = 0.5;
			pressed=true;
		}else if(pressed && dist > 100){
			pressed=false;
			strum.playStatic();
		}

		note.distanceToSprite = (0.45 * dist * _scrollSpeed);
		if(SESave.data.downscroll){
			strum.y = 360;
			note.y = strum.y + note.distanceToSprite;
		}else{
			strum.y = 120;
			note.y = strum.y - note.distanceToSprite;
		}

		strum.draw();
		note.draw();
	}

}
class IntOption extends Option{
	var min:Int = 0;
	var max:Int;
	var script:String;
	var name:String;

	public function new(desc:String,name:String,min:Int,max:Int,mod:String)
	{
		this.name = display = name;
		script = mod;
		this.min = min;
		this.max = max;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String {
		return '${OptionsMenu.modOptions[script][name]}';
	}

	override function right():Bool {

		OptionsMenu.modOptions[script][name] += 1;
		if (OptionsMenu.modOptions[script][name] > max) OptionsMenu.modOptions[script][name] = min;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		OptionsMenu.modOptions[script][name] -= 1;
		if (OptionsMenu.modOptions[script][name] < min) OptionsMenu.modOptions[script][name] = max;
		display = updateDisplay();
		return true;
	}
	override function updateDisplay():String return name + ": " + getValue();
}
class FloatOption extends Option{
	var min:Float = 0;
	var max:Float;
	var script:String;
	var name:String;

	public function new(desc:String,name:String,min:Float,max:Float,mod:String)
	{
		this.name = display = name;
		script = mod;
		this.min = min;
		this.max = max;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String return '${OptionsMenu.modOptions[script][name]}';
	override function updateDisplay():String return name + ": " + getValue();

	override function right():Bool {

		OptionsMenu.modOptions[script][name] += 0.1;
		if(OptionsMenu.modOptions[script][name] < 0.1 && OptionsMenu.modOptions[script][name] > -0.1) OptionsMenu.modOptions[script][name] = 0;
		if (OptionsMenu.modOptions[script][name] > max) OptionsMenu.modOptions[script][name] = min;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		OptionsMenu.modOptions[script][name] -= 0.1;
		if(OptionsMenu.modOptions[script][name] < 0.1 && OptionsMenu.modOptions[script][name] > -0.1) OptionsMenu.modOptions[script][name] = 0;
		if (OptionsMenu.modOptions[script][name] < min) OptionsMenu.modOptions[script][name] = max;
		display = updateDisplay();
		return true;
	}
}
class BoolOption extends Option{
	var script:String;
	var name:String;

	public function new(desc:String,name:String,mod:String) {
		// acceptValues = true;
		this.name = name;
		// display = name;
		script = mod;
		super();
		description = desc;

	}
	override function getValue():String {
		return '${OptionsMenu.modOptions[script][name]}';
	}
	public override function press():Bool{
		OptionsMenu.modOptions[script][name] = !OptionsMenu.modOptions[script][name];
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String return name + ": " + getValue();
}


class HCArrayOption extends Option{
	var id:String;
	var name:String;
	var inc:Int = 0;
	var arr:Array<Dynamic>;
	var callback:()->Void;

	public function new(name:String,desc:String,id:String,options:Array<Array<Dynamic>>,?callback:()->Void){
		acceptValues = true;
		this.name = name;
		this.id = id;
		this.callback = callback;
		super();
		acceptValues = true;
		description = desc;
		inc = options.indexOf(Reflect.getProperty(SESave.data,id));
		if(inc == -1) inc = 0;

	}
	override function getValue():String return '${arr == null ? 'null' : arr[inc][0]}';
	inline function inRange(){
		if(inc < 0) inc = arr.length-1;
		if(inc >= arr.length) inc = 0;
	}
	public override function left():Bool{
		inc--;
		inRange();
		Reflect.setProperty(SESave.data,id,arr[inc][1] ?? arr[inc][0]);
		display = updateDisplay();
		return true;
	}
	public override function right():Bool{
		inc++;
		inRange();
		Reflect.setProperty(SESave.data,id,arr[inc][1] ?? arr[inc][0]);
		display = updateDisplay();
		return true;
	}
	override function updateDisplay():String return name + ": " + getValue();
}
class HCIntOption extends Option{
	var id:String;
	var name:String;
	var max:Int = 0;
	var min:Int = 0;
	var inc:Int = 0;
	var callback:()->Void;

	public function new(name:String,desc:String,id:String,?min:Int = 0,?max:Int = 100,?inc:Int = 1,?callback:()->Void){
		this.max = max;
		this.min = min;
		this.inc = inc;
		acceptValues = true;
		this.name = name;
		this.id = id;
		this.callback = callback;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String return '${Reflect.getProperty(SESave.data,id)}';

	public override function left():Bool{
		var ince:Float = inc;
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT) ince *= 0.01;
		else if(FlxG.keys.pressed.SHIFT) ince *= 10;
		else if(FlxG.keys.pressed.CONTROL) ince *= 0.1;
		Reflect.setProperty(SESave.data,id,Math.max(cast (Reflect.getProperty(SESave.data,id),Int) - Std.int(ince),min));
		display = updateDisplay();
		return true;
	}
	public override function right():Bool{
		var ince:Float = inc;
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT) ince *= 0.01;
		else if(FlxG.keys.pressed.SHIFT) ince *= 10;
		else if(FlxG.keys.pressed.CONTROL) ince *= 0.1;
		Reflect.setProperty(SESave.data,id,Math.min(cast (Reflect.getProperty(SESave.data,id),Int) + Std.int(ince),max));
		display = updateDisplay();
		return true;
	}
	override function updateDisplay():String return name + ": " + getValue();
}
class HCFloatOption extends Option{
	var id:String;
	var name:String;
	var max:Float = 0;
	var min:Float = 0;
	var inc:Float = 0.1;
	var callback:()->Void;

	public function new(name:String,desc:String,id:String,?min:Float = 0,?max:Float = 1,?inc:Float = 0.1,?callback:()->Void){
		this.max = max;
		this.min = min;
		this.inc = inc;
		acceptValues = true;
		this.name = name;
		this.id = id;
		this.callback = callback;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String {
		return '${Reflect.getProperty(SESave.data,id)}';
	}
	public override function left():Bool{
		var ince = inc;
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT) ince *= 0.01;
		else if(FlxG.keys.pressed.SHIFT) ince *= 10;
		else if(FlxG.keys.pressed.CONTROL) ince *= 0.1;
		Reflect.setProperty(SESave.data,id,Math.max(cast (Reflect.getProperty(SESave.data,id),Float) - ince,min));
		display = updateDisplay();
		if(callback!=null)callback();
		return true;
	}
	public override function right():Bool{
		var ince = inc;
		if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT) ince *= 0.01;
		else if(FlxG.keys.pressed.SHIFT) ince *= 10;
		else if(FlxG.keys.pressed.CONTROL) ince *= 0.1;
		Reflect.setProperty(SESave.data,id,Math.min(cast (Reflect.getProperty(SESave.data,id),Float) + ince,max));
		display = updateDisplay();
		if(callback!=null)callback();
		return true;
	}
	override function updateDisplay():String return name + ": " + getValue();
}
class HCBoolOption extends Option{
	var id:String;
	var name:String;
	var trueText:String = "";
	var falseText:String = "";
	var callback:()->Void;

	public function new(name:String,desc:String,id:String,?trueText:String = "",falseText:String = "",?callback:()->Void)
	{
		// acceptValues = true;
		this.name = name;
		this.id = id;
		this.trueText = trueText;
		this.falseText = falseText;
		this.callback = callback;
		super();
		description = desc;

	}
	override function getValue():String return '${Reflect.getProperty(SESave.data,id) == true}';
	public override function press():Bool{
		try{

			Reflect.setProperty(SESave.data,id,Reflect.getProperty(SESave.data,id) != true);
			display = updateDisplay();
			if(callback!=null)callback();
		}catch(e){
			FuckState.FUCK(e,'options.press');
		}
		return true;
	}

	override function updateDisplay():String
	{
		var ret:Bool = Reflect.getProperty(SESave.data,id) == true;
		if(trueText == "" || falseText == ""){
			return '$name: $ret';
		}
		return (if(ret) trueText else falseText); 
	}
}
class BackTransOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		display = "Underlay opacity";
	}

	override function right():Bool {
		SESave.data.undlaTrans += 0.1;

		if (SESave.data.undlaTrans > 1)
			SESave.data.undlaTrans = 1;
		return true;
	}

	override function getValue():String return "Underlay opacity: " + CoolUtil.truncateFloat(SESave.data.undlaTrans,1);
	

	override function left():Bool {
		SESave.data.undlaTrans -= 0.1;

		if (SESave.data.undlaTrans < 0)
			SESave.data.undlaTrans = 0;

		if (SESave.data.undlaTrans > 1)
			SESave.data.undlaTrans = 1;

		return true;
	}
}
class BackgroundSizeOption extends Option
{
	var ies:Array<String> = ["Strumline Only","Fill screen"];
	var iesDesc:Array<String> = ["Only show underlay below strumline","Fill underlay to entire screen",];
	public function new(desc:String)
	{
		if (SESave.data.undlaSize >= ies.length) SESave.data.undlaSize = 0;
		super();
		description = desc;
		display = 'Underlay style';
		acceptValues = true;
	}

	override function getValue():String return iesDesc[SESave.data.undlaSize];

	override function right():Bool {
		SESave.data.undlaSize += 1;
		if (SESave.data.undlaSize >= ies.length) SESave.data.undlaSize = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		SESave.data.undlaSize -= 1;
		if (SESave.data.undlaSize < 0) SESave.data.undlaSize = ies.length - 1;
		display = updateDisplay();
		return true;
	}

}


class VolumeOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		display = '$opt Volume';
		description = desc;
		acceptValues = true;
	}


	override function right():Bool {
		Reflect.setField(SESave.data,opt+"Vol", Reflect.field(SESave.data,opt+"Vol") + (if(FlxG.keys.pressed.SHIFT) 0.01 else 0.1));

		if (Reflect.field(SESave.data,opt+"Vol") > 2)
			Reflect.setField(SESave.data,opt+"Vol", 2);
		// display = updateDisplay();
		return true;
	}

	override function getValue():String {

		switch(opt){
			case "master":{
				FlxG.sound.volume = SESave.data.masterVol;
			}
			case "inst":{
				FlxG.sound.music.volume = SESave.data.instVol;
			}
		}
		return opt + " Volume: " + (CoolUtil.truncateFloat(Reflect.field(SESave.data,opt+"Vol"),2) * 100) + "%"; // Multiplied by 100 to appear as 0-100 instead of 0-1

	}

	override function left():Bool {
		Reflect.setField(SESave.data,opt+"Vol", Reflect.field(SESave.data,opt+"Vol") - (if(FlxG.keys.pressed.SHIFT) 0.01 else 0.1));
		if (Reflect.field(SESave.data,opt+"Vol") < 0)
			Reflect.setField(SESave.data,opt+"Vol", 0);
		// display = updateDisplay();

		return true;
	}
}


class EraseOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
		display = "Reset Options to defaults";
	}

	public override function press():Bool
	{
		try{
			SEFlxSaveWrapper.saveTo();
			FlxG.save.erase();
			KadeEngineData.initSave();
			OptionsMenu.instance.showTempmessage('Reset options back to defaults and backed them up to SEOPTIONS-BACKUP.json',FlxColor.GREEN,10);
		}catch(e){
			OptionsMenu.instance.showTempmessage('Unable to export options! ${e.message}',FlxColor.RED,10);
		}
		
		return true;
	}
}
class ResetKeybindsOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
		display = "Reset Keybinds to defaults";
	}

	public override function press():Bool
	{
		SEFlxSaveWrapper.saveTo();
		KeyBinds.resetBinds();
		OptionsMenu.instance.showTempmessage('Reset keybinds back to defaults and backed up your options to SEOPTIONS-BACKUP.json',FlxColor.GREEN,10);
		
		return true;
	}
}

class LanguageOption extends Option{
	var name:String;

	public function new(name:String) {
		this.name = name;

		super();
		description = name;

	}
	override function getValue():String return "";
	override function right():Bool return false;
	override function left():Bool return false;
	override function press():Bool {
		se.translation.Lang.loadTranslations(SESave.data.lang = name);
		return true;
	}
	override function updateDisplay():String return name;
}
class QuickOption extends Option{
	var name:String;
	var setting:QOSetting;
	inline function setValue(name:String,value:Dynamic){
		setting.value = value;
	}
	public function new(name:String)
	{
		this.name = name;
		setting = QuickOptionsSubState.normalSettings[name];

		acceptValues = true;
		super();
		acceptValues = true;
		description = "Chart options. THESE ARE TEMPORARY AND RESET WHEN GAME IS CLOSED";

	}
	override function getValue():String {
		var val = setting.value;
		if (setting.lang != null && setting.lang[setting.value] != null) val = setting.lang[setting.value];
		return val;
	}
	function changeThing(?right:Bool = false){
		if (setting.type == 0) setValue(name,setting.value = !setting.value );
		if (setting.type == 1 || setting.type == 2) {
			var val = setting.value;
			var inc:Float = 1;
			if(setting.type == 2 && FlxG.keys.pressed.SHIFT) inc=0.1;
			val += if(right) inc else -inc;
			if (val > setting.max) val = setting.min; 
			if (val < setting.min) val = setting.max - 1; 
			setValue(name,val);
		}
		display = updateDisplay();

	}
			
	override function right():Bool {
		changeThing(true);
		return true;
	}
	override function left():Bool {
		changeThing();
		return true;
	}
	override function updateDisplay():String
	{
		var val = setting.value;
		if (setting.lang != null && setting.lang[setting.value] != null) val = setting.lang[setting.value];
		return '${name}: ${val}';
	}
}
/*
..	
BaseScaleMode	
The base class from which all other scale modes extend from. You can implement your own scale mode by extending this class and overriding the appropriate methods.

FillScaleMode	
FillScaleMode is a scaling mode which stretches and squashes the game to exactly fit the provided window. This may result in the graphics of your game being distorted if the user resizes their game window.

FixedScaleAdjustSizeScaleMode	
FixedScaleAdjustSizeScaleMode is a scaling mode which maintains the game's scene at a fixed size. This will clip off the edges of the scene for dimensions which are too small. However, unlike FixedScaleMode, this mode will extend the width of the current scene to match the window scale. The result is that objects that would be offscreen on smaller window sizes will be visible in larger ones.

FixedScaleMode	
FixedScaleMode is a scaling mode which maintains the game's scene at a fixed size. This will clip off the edges of the scene for dimensions which are too small, and leave black margins on the sides for dimensions which are too large.

PixelPerfectScaleMode	
PixelPerfectScaleMode is a scaling mode which maintains the game's aspect ratio. When you shrink or grow the window, the width and height of the game will adjust, either scaling the game or adding black bars as needed.

RatioScaleMode	
RatioScaleMode is a scaling mode which maintains the game's aspect ratio. When you shrink or grow the window, the width and height of the game will adjust, either scaling the game or adding black bars as needed.

RelativeScaleMode	
RelativeScaleMode is a scaling mode which stretches and squashes the game to exactly fit the provided window. It acts similar to the FillScaleMode, however there is one major difference. RelativeScaleMode takes two parameters, which represent the width scale and height scale.

StageSizeScaleMode	
StageSizeScaleMode is a scaling mode which maintains the game's scene at a fixed size. This will clip off the edges of the scene for dimensions which are too small. However, unlike FixedScaleMode, this mode will extend the width of the current scene to match the window scale. The result is that objects that would be offscreen on smaller window sizes will be visible in larger ones.

*/

class ScalingModeOption extends Option
{
	public static var scales = [
		new BaseScaleMode(),
		new FillScaleMode(),
		new FixedScaleAdjustSizeScaleMode(),
		new FixedScaleMode(),
		new PixelPerfectScaleMode(),
		new RatioScaleMode(),
		new StageSizeScaleMode(),
	];
	public static function setScale(){
		FlxG.scaleMode = scales[SESave.data.scalingMode];
	}
	var ies:Array<String> = ["Base","Fill","Adjust Size","Forced 720p","Pixel Perfect Scale","Closest Ratio","No Scaling"];
	var iesDesc:Array<String> = [
		"Default scaling",
		"Stretches/Squashes the screen from 720p to the window size",
		"Adjusts the game's cameras to use the window size",
		"Adds black bars to the sides of the screen and keeps the game at 720p",
		"Scales the game to a multiple of 720p",
		"Scales up to the closest size that can keep the same aspect ratio as 720p",
		"Applies no scaling",


		];
	public function new(desc:String)
	{
		if (SESave.data.scalingMode >= ies.length) SESave.data.scalingMode = 0;
		super();
		description = desc;
		acceptValues = true;
	}

	override function updateDisplay():String return 'Scaling mode:' + ies[SESave.data.scalingMode];
	override function getValue():String return iesDesc[SESave.data.scalingMode];

	override function right():Bool {
		SESave.data.scalingMode += 1;
		if (SESave.data.scalingMode >= ies.length) SESave.data.scalingMode = 0;
		setScale();
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		SESave.data.scalingMode -= 1;
		if (SESave.data.scalingMode < 0) SESave.data.scalingMode = ies.length - 1;
		setScale();
		display = updateDisplay();
		return true;
	}

}