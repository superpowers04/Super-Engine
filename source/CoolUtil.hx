package;

import lime.app.Application;
import openfl.Lib;
import lime.utils.Assets;
import sys.FileSystem;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;

using StringTools;

class CoolUtil {
	public static var fontName:String = "vcr.ttf";
	public static var font:String = (SELoader.anyExists(['mods/font.ttf','mods/font.otf']) ?? Paths.font(fontName));
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var volKeysEnabled = true;
	public static var Framerate:Float = 0;
	public static var updateRate:Float = 120;
	public static var activeObject(default,set):Dynamic = null;
	public static function set_activeObject(vari){
		toggleVolKeys(FlxG.keys.enabled = (vari == null)); // Why the fuck do i need to do this, what
		return activeObject = vari;
	}
	public static function updateActiveObject(vari){
		try{
			activeObject.hasFocus = false;
		}catch(e){}
		return activeObject = vari;
	}
	public static function setFramerate(?fps:Float = 0,?update:Bool = false,?temp:Bool = false){
		if(!temp){
			if(fps != 0 && !update){
				updateRate = (Framerate = SESave.data.fpsCap = fps) * 2;
			}
			if(Framerate == 0 || update){
				Framerate = cast SESave.data.fpsCap;
			}
			if(Framerate < 30){
				var rf = Application.current.window.displayMode.refreshRate;
				var fr = Application.current.window.frameRate;
				Framerate = SESave.data.fpsCap = (rf > 30 ? rf : (fr > 30 ? fr : 30 ));
			}
			if(Framerate > 999){
				Framerate = SESave.data.fpsCap = 999;
			}
		}
		Main.instance.setFPSCap(Framerate);
		FlxG.updateFramerate = (FlxG.drawFramerate = Std.int(Framerate));
	}

	@:keep inline public static function clearFlxGroup(obj:FlxTypedGroup<Dynamic>):FlxTypedGroup<Dynamic>{ // Destroys all objects inside of a FlxGroup
		while (obj.members.length > 0){
			var e = obj.members.pop();
			if(e != null && e.destroy != null) e.destroy();
		}
		return obj;
	}
	@:keep inline public static function difficultyString():String {
		return if (PlayState.stateType == 4) PlayState.actualSongName else difficultyArray[PlayState.storyDifficulty];
	}
	public static function toggleVolKeys(?toggle:Bool = true){
		if (toggle){
			try{
				FlxG.sound.muteKeys = [FlxKey.fromStringMap[SESave.data.keys[0][9]]];
				FlxG.sound.volumeDownKeys = [FlxKey.fromStringMap[SESave.data.keys[0][10]]];
				FlxG.sound.volumeUpKeys = [FlxKey.fromStringMap[SESave.data.keys[0][11]]];
				return;
			}catch(e){
				trace('Unable to bind sound keys? ${e.details()}');
			}
		}
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
	}
	@:keep inline public static function coolTextFile(path:String):Array<String> {
		var daList:Array<String> = SELoader.getContent(path).trim().split('\n');

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim().replace("\\n","\n");
		}

		return daList;
	}
	@:keep inline public static function splitFilenameFromPath(str:String):Array<String>{
		return [str.substr(0,str.lastIndexOf("/")),str.substr(str.lastIndexOf("/") + 1)];
	}

	public inline static function getFilenameFromPath(str:String):String{
		return (str.lastIndexOf("/") == -1) ? str : str.substr(str.lastIndexOf("/") + 1);
	}
	public inline static function removeFileFromPath(str:String):String{
		return (str.lastIndexOf("/") == -1) ? str : str.substr(0,str.lastIndexOf("/"));
	}
	public static function coolFormat(text:String){
		var daList:Array<String> = text.trim().split('\n');

		for (i in 0...daList.length) daList[i] = daList[i].trim().replace("\\n","\n");

		return daList;
	}
	public static function formatChartName(str:String):String{

		if(!str.contains(' ')) str = (~/[-_ ]/g).replace(str,' '); // If the string contains spaces, probably already formatted to remove _ and -
		var e = str.split(' ');
		for (i=>item in e){
			e[i] = (item.substring(0,1).toUpperCase() + item.substring(1));
		}
		return e.join(' ').trim();
	}

	@:keep inline public static function orderList(list:Array<String>):Array<String>{
		haxe.ds.ArraySort.sort(list, (a, b) -> (a<b ? -1 : (a>b ? 1 : 0)) );

		return list;
	}
	public static function coolStringFile(path:String):Array<String> {
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length) daList[i] = daList[i].trim();

		return daList;
	}

	@:keep inline public static function numberArray(max:Int, ?min = 0):Array<Int> {
		return [for (i in min...max) i];
	}
	@:keep inline public static function multiInt(?int:Int = 0) return (int==1?'':'s');

	@:keep inline public static function cleanJSON(input:String):String{ // Haxe doesn't filter out comments?
		return (~/\/\*[\s\S]*?\*\/|\/\/.*/g).replace(input.trim(),'');
	}
	public static function applyAnonToObject(obj:Dynamic,anon:Dynamic,?logErrors:Bool = false):Bool{
		if(anon == null) return false;
		var type = Type.typeof(obj);
		var copied:Bool = false;
		for(field in Reflect.fields(anon)){
			// if(field.startsWith('set_')){
			// 	field = field.substring(4);
			// }
			try{
				if(Reflect.field(obj,field) == null) throw('$field is not present on $type');
				var stuff:Dynamic = Reflect.field(anon,field);
				if(stuff == null) throw('$field is not on the obj??');
				Reflect.setProperty(obj,field,stuff);
				if(!copied) copied = true;
			}catch(e){
				if(logErrors) trace('Unable to load field "$field": $e');
			}
		}
		return copied;
	}
}
