package;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flash.media.Sound;
import sys.io.File;
import flash.display.BitmapData;
import Xml;
import sys.FileSystem;

// Made specifically for Super Engine


using StringTools;

class HSBrTools {
	var path:String;
	public var spriteArray:Map<String,FlxGraphic> = [];
	public var bitmapArray:Map<String,BitmapData> = [];
	public var xmlArray:Map<String,String> = [];
	public var textArray:Map<String,String> = [];
	public var soundArray:Map<String,Sound> = [];
	// public var dumpGraphics:Bool = false; // If true, All FlxGraphics will be dumped upon creation, trades off bitmap editability for less memory usage
 
	

	var optionsMap:Map<String,Dynamic> = new Map<String,Dynamic>();
	public static var shared:Map<String,Dynamic> = new Map<String,Dynamic>();
	public var global(get,never):Map<String,Dynamic>;
	var id = "Unspecified script";
	public function new(_path:String,?id:String = ""){
		path = _path;
		if (!path.endsWith('/')) path = path + "/";
		if(id != "" && sys.FileSystem.exists('mods/scriptOptions/$id.json')){
			trace('$id has user settings');
			var scriptJson:Map<String,Dynamic> = OptionsMenu.loadScriptOptions('mods/scriptOptions/$id.json');
			if(scriptJson != null) optionsMap = scriptJson;
			this.id = id;
		}
		trace('HSBrTools initialised in ${path}');
	}

	public function getSetting(setting:String,?defValue:Dynamic = false):Dynamic{
		if (optionsMap[setting] != null){
			return optionsMap[setting];
		}
		return defValue;
	}
	function get_global(){
		return shared;
	}

	inline function handleError(e:String){
		PlayState.instance.handleError(e);
	}


	public function getPath(?str:String = ""){
		return path + str;
	}
	public function loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite{
		if(!FileSystem.exists('${path}${pngPath}')){
			handleError('${id}: Image "${path}${pngPath}" doesn\'t exist!');
			return new FlxSprite(x, y); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}${pngPath}'));
		return new FlxSprite(x, y).loadGraphic(spriteArray[pngPath]);
	}
	public function loadGraphic(pngPath:String):FlxGraphic{
		if(!FileSystem.exists('${path}${pngPath}')){
			handleError('${id}: "${path}${pngPath}" doesn\'t exist!');
			return FlxGraphic.fromRectangle(0,0,0); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}${pngPath}'));
		return spriteArray[pngPath];
	}

	public function loadSparrowFrames(pngPath:String):FlxAtlasFrames{
		if(!FileSystem.exists('${path}${pngPath}.png')){
			handleError('${id}: SparrowFrame PNG "${path}${pngPath}.png" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(!FileSystem.exists('${path}${pngPath}.xml')){
			handleError('${id}: SparrowFrame XML "${path}${pngPath}.xml" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath + ".png"] == null){ 
			cacheGraphic('${pngPath}.png');
		}
		if(xmlArray[pngPath + ".xml"] == null) xmlArray[pngPath + ".xml"] = File.getContent('${path}${pngPath}.xml');

		return FlxAtlasFrames.fromSparrow(spriteArray[pngPath + ".png"],xmlArray[pngPath + ".xml"]);
	}
	public function loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite{

		if(!FileSystem.exists('${path}${pngPath}.png')){
			handleError('${id}: SparrowSprite PNG "${path}${pngPath}.png" doesn\'t exist!');
			return new FlxSprite(x, y); // Prevents the script from throwing a null error or something
		}
		if(!FileSystem.exists('${path}${pngPath}.xml')){
			handleError('${id}: SparrowSprite XML "${path}${pngPath}.xml" doesn\'t exist!');
			return new FlxSprite(x, y); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath + ".png"] == null){ 
			cacheGraphic('${pngPath}.png');
		}
		var spr = new FlxSprite(x, y);
		if(xmlArray[pngPath + ".xml"] == null) xmlArray[pngPath + ".xml"] = File.getContent('${path}${pngPath}.xml');

		spr.frames= FlxAtlasFrames.fromSparrow(spriteArray[pngPath + ".png"],xmlArray[pngPath + ".xml"]);
		if (anim != ""){
			spr.animation.addByPrefix(anim,anim,fps,loop);
			spr.animation.play(anim);
		}

		return spr;
	}
	public function reset(){
		spriteArray = new Map<String,FlxGraphic>();
	}

	public function loadText(textPath:String):String{
		if(textArray[textPath] == null) textArray[textPath] = File.getContent('${path}${textPath}');
		return textArray[textPath];
	}
	// public function saveText(textPath:String,text:String):Bool{
	// 	File.saveContent('${path}${textPath}',text);
	// 	return true;
	// }



	public function loadSound(soundPath:String):Sound{
		if(soundArray[soundPath] == null) soundArray[soundPath] = Sound.fromFile('${path}${soundPath}');
		return soundArray[soundPath];
	}

	public function playSound(soundPath:String,?volume:Float = 0.662121):FlxSound{
		if(volume == 0.662121) volume = FlxG.save.data.otherVol;
		if(soundArray[soundPath] == null) soundArray[soundPath] = Sound.fromFile('${path}${soundPath}');
		return FlxG.sound.play(soundArray[soundPath],volume);
	}

	public function unloadSound(soundPath:String){
		soundArray[soundPath] = null;
	}
	public function unloadText(pngPath:String){
		textArray[pngPath] = null;
	}
	public function unloadXml(pngPath:String){
		xmlArray[pngPath] = null;
	}
	public function unloadSprite(pngPath:String){
		spriteArray[pngPath] = null;
	}

	public function cacheSound(soundPath:String){
		if(soundArray[soundPath] == null) {
			if(!FileSystem.exists('${path}${soundPath}')){
				trace('${id} : CacheSound: "${path}${soundPath}" doesn\'t exist!');
				return;
			}
			soundArray[soundPath] = Sound.fromFile('${path}${soundPath}');
		}
	}
	public function cacheGraphic(pngPath:String,?dumpGraphic:Bool = false){ // DOES NOT CHECK IF FILE IS VALID!
		
		if(bitmapArray[pngPath] == null){
			bitmapArray[pngPath] = BitmapData.fromFile('${path}${pngPath}');
		}
		if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(bitmapArray[pngPath]);
		if(spriteArray[pngPath] == null) handleError('${id} : cacheGraphic: Unable to load $pngPath into a FlxGraphic!');
		// if(dumpGraphic || dumpGraphics) spriteArray[pngPath].dump();

	}
	public function cacheSprite(pngPath:String,?dump:Bool = false){

		if(spriteArray[pngPath] == null) {
			if(!FileSystem.exists('${path}${pngPath}.png')){
				handleError('${id} : CacheSprite: "${path}${pngPath}.png" doesn\'t exist!');
				return;
			}
			cacheGraphic('${pngPath}.png',dump);
		}
	}
}



