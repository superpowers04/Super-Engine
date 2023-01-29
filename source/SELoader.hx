package;

// Class used for loading sprites and caching them, hopefully will be more efficient than Flixels built-in caching
// This will work reguardless of if they're in assets/ or not


import sys.io.File;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import flash.media.Sound;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import lime.media.AudioBuffer;
// import vlc.VLCSound;
using StringTools;

class SELoader {

 	static public var cache:InternalCache = new InternalCache();
 	public static var PATH:String = '';
	// if(Sys.getCwd() != "/" && Sys.getCwd() != "C:/") Sys.getCwd() else lime.system.System.applicationDirectory

	public static var id = "Internal";

	inline static function handleError(e:String){
		trace(e);
		if(PlayState.instance != null) PlayState.instance.handleError(e); else MainMenuState.handleError(e);
	}
	// Basically clenses paths and returns the base path with the requested one. Used heavily for the Android port
	@:keep inline public static function getPath(path:String):String{
			// Remove library from path
			if(path.indexOf(":") > 3) path = path.substring(path.indexOf(":") + 1);
			// Absolute paths should just return themselves without anything changed
			if(
				#if windows
					path.substring(1,2) == ':') || 
				#end
					path.substring(0,1) == "/"){

				return path.replace('//','/');
			}else{
				return (PATH + path).replace('//','/'); // Fixes paths having //'s in them
			}
	}


	public static function loadFlxSprite(x:Int,y:Int,pngPath:String,?useCache:Bool = false):FlxSprite{
		if(!FileSystem.exists('${pngPath}')){
			handleError('${id}: Image "${pngPath}" doesn\'t exist!');
			return new FlxSprite(x, y); // Prevents the script from throwing a null error or something
		}
		return new FlxSprite(x, y).loadGraphic(loadGraphic(pngPath,useCache));
	}
	public static function loadGraphic(pngPath:String,?useCache:Bool = false):FlxGraphic{
		if(cache.spriteArray[pngPath] != null || useCache){
			return cache.loadGraphic(pngPath);
		}
		// if(!FileSystem.exists('${pngPath}')){
		// 	handleError('${id}: "${pngPath}" doesn\'t exist!');
		// 	return FlxGraphic.fromRectangle(0,0,0); // Prevents the script from throwing a null error or something
		// }
		return FlxGraphic.fromBitmapData(loadBitmap(pngPath));
	}
	public static function loadBitmap(pngPath:String,?useCache:Bool = false):BitmapData{
		if(cache.bitmapArray[pngPath] != null || useCache){
			return cache.loadBitmap(pngPath);
		}
		if(!exists('${pngPath}')){
			handleError('${id}: "${pngPath}" doesn\'t exist!');
			return new BitmapData(0,0,false,0xFF000000); // Prevents the script from throwing a null error or something
		}
		return BitmapData.fromFile(getPath(pngPath));
	}

	public static function loadSparrowFrames(pngPath:String):FlxAtlasFrames{
		if(!exists('${getPath(pngPath)}.png')){
			handleError('${id}: SparrowFrame PNG "${pngPath}.png" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(!exists('${getPath(pngPath)}.xml')){
			handleError('${id}: SparrowFrame XML "${pngPath}.xml" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		return FlxAtlasFrames.fromSparrow(loadGraphic(pngPath),loadText('${pngPath}.xml'));
	}
	public static function loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24,?useCache:Bool = false):FlxSprite{
		
		var spr = new FlxSprite(x, y);
		var _f = spr.frames;
		try{
			spr.frames=loadSparrowFrames(pngPath);
		}catch(e){
			spr.frames = _f;
			return spr;
		}
		if (anim != ""){
			spr.animation.addByPrefix(anim,anim,fps,loop);
			spr.animation.play(anim);
		}
		return spr;
	}
	public static function reset(){
		cache.clear();
		cache = new InternalCache();
	}

	public static function loadText(textPath:String,?useCache:Bool = false):String{
		if(cache.textArray[textPath] != null || useCache){
			return cache.loadText(textPath);
		}
		if(!exists(textPath)){
			handleError('${id}: Text "${textPath}" doesn\'t exist!');
			return "";
		}
		return File.getContent(getPath(textPath));
	}
	@:keep inline public static function getContent(textPath:String):String{return loadText(textPath,false);}
	@:keep inline public static function saveContent(textPath:String,content:String):String{return saveText(textPath,content,false);}
	@:keep inline public static function getBytes(textPath:String):haxe.io.Bytes{return loadBytes(textPath,false);}

	public static function loadBytes(textPath:String,?useCache:Bool = false):haxe.io.Bytes{
		// No cache support atm

		// if(cache.textArray[textPath] != null || useCache){
		// 	return cache.loadText(textPath);
		// }
		if(!exists(textPath)){
			handleError('${id}: Text "${textPath}" doesn\'t exist!');
			return null;
		}
		return File.getBytes(getPath(textPath));
	}

	public static function saveText(textPath:String,contents:String = "",?useCache:Bool = false):Dynamic{ // If there's an error, it'll return the error, else it'll return null

		try{
			File.saveContent(getPath(textPath),contents);
		}catch(e){
			return e;
		}
		if(cache.textArray[textPath] != null || useCache){
			cache.textArray[textPath] = contents;
		}
		return null;
	}
	// public function saveText(textPath:String,text:String):Bool{
	// 	File.saveContent('${textPath}',text);
	// 	return true;
	// }

	// public static function createVLCUrl(FileName:String):String
	// {
	// 	FileName = haxe.io.Path.normalize(FileSystem.absolutePath(FileName));
	// 	#if android
	// 	return Uri.fromFile(FileName);
	// 	#elseif linux
	// 	return 'file://' + FileName;
	// 	#elseif (windows || mac)
	// 	return 'file:///' + FileName;
	// 	#end
	// }

	public static function loadSound(soundPath:String,?useCache:Bool = false):Sound{
		if(cache.soundArray[soundPath] != null || useCache){
			return cache.loadSound(soundPath);
		}
		if(!exists(soundPath)){
			handleError('${id}: Sound "${getPath(soundPath)}" doesn\'t exist!');
		}
		return Sound.fromFile(getPath(soundPath));
		

	}
	@:keep inline public static function loadFlxSound(soundPath:String):FlxSound{
		return new FlxSound().loadEmbedded(loadSound(soundPath));
	}

	public static function playSound(soundPath:String,?volume:Float = -1):FlxSound{
		if(volume == -1) volume = FlxG.save.data.otherVol;
		return FlxG.sound.play(loadSound(soundPath),volume);
	}


	// Clones of FileSystem and File functions. Eventually, zip support might be added. This'll also allow custom formats to be used

	public static function absolutePath(path:String):String{
		return FileSystem.absolutePath(getPath(path));
	}
	public static function fullPath(path:String):String{
		return FileSystem.fullPath(getPath(path));
	}
	public static function exists(path:String):Bool{
		return FileSystem.exists(getPath(path));
	}
	public static function readDirectory(path:String):Array<String>{
		return FileSystem.readDirectory(getPath(path));
	}
	public static function isDirectory(path:String):Bool{
		return FileSystem.isDirectory(getPath(path));
	}
	public static function createDirectory(path:String){
		return FileSystem.createDirectory(getPath(path));
	}



	// public static function cleanUp(){ // This will be used for when a song ends, 
	// 	if(FlxG.save.data.cacheall){
	// 		cleanUpList.clear();
	// 		return;
	// 	}
	// 	for (i => v in cleanUpList) {
	// 		switch (v) {
	// 			case 0: {
	// 				SpriteList[i].destroy();
	// 				SpriteList[i] = null;
	// 			}
	// 			case 1: SoundList[i] = null;
	// 			case 2: TextList[i] = null;
	// 			case 3: FLXSoundList[i] = null;
	// 			// case 3:
	// 			// 	SpriteList[i + ".png"] = null;
	// 			// 	TextList[i + ".xml"] = null;
	// 		}
	// 	}
	// 	// cleanUpList = new Map<String,Int>();
	// 	cleanUpList.clear();
	// }

	// public static function clearMemory(){
	// 	if(FlxG.save.data.cacheall) return; // imagine needing to clear the memory lmoa
	// 	for(i => v in SpriteList){
	// 		v.destroy();
	// 	}
	// 	SpriteList = [];
	// 	SoundList = [];
	// 	TextList = [];
	// }   
	// public static function loadFlxSound(path:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID):Null<FlxSound>{
	// 	if(cacheID != "" && cacheIDList["FLXSOUND:" + cacheID] == path){
	// 		if(FLXSoundList[cacheID] == null){
	// 			cacheIDList["FLXSOUND:" + cacheID] = "";
	// 		}
	// 		else{
	// 			return FLXSoundList["FLXSOUND:" + cacheID];
	// 		}
	// 	}
	// 	if(FLXSoundList[path] != null) return SoundList[path];
	// 	if(!FileSystem.exists(path)) return null;
	// 	if(!FlxG.save.data.cacheall && (!cache || !FlxG.save.data.cache)) return SoundList[path];
	// 	if(cacheID != "" && cacheIDList["FLXSOUND:" + cacheID] == path){
	// 		cacheIDList["FLXSOUND:" + cacheID] = path;
	// 		FLXSoundList[cacheID] = new FlxSound().loadEmbedded(Sound.fromFile(path));
	// 		path = cacheID;
	// 	}else{
	// 		FLXSoundList[path] = new FlxSound().loadEmbedded(Sound.fromFile(path));
	// 	}
	// 	if(cacheTemp) cleanUpList[path] = 3;

		
	// 	return FLXSoundList[path];
	// } 
	// public static function loadSound(path:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID):Null<Sound>{
	// 	if(cacheID != "" && cacheIDList["SOUND:" + cacheID] == path){
	// 		if(SoundList[cacheID] == null){
	// 			cacheIDList["SOUND:" + cacheID] = "";
	// 		}
	// 		else{
	// 			return SoundList["SOUND:" + cacheID];
	// 		}
	// 	}
	// 	if(SoundList[path] != null) return SoundList[path];
	// 	if(!FileSystem.exists(path)) return null;
	// 	if(!FlxG.save.data.cacheall && (!cache || !FlxG.save.data.cache)) return SoundList[path];
	// 	if(cacheID != "" && cacheIDList["SOUND:" + cacheID] == path){
	// 		cacheIDList["SOUND:" + cacheID] = path;
	// 		SoundList[cacheID] = Sound.fromFile(path);
	// 		path = cacheID;
	// 	}else{
	// 		SoundList[path] = Sound.fromFile(path);
	// 	}
	// 	if(cacheTemp) cleanUpList[path] = 1;

		
	// 	return SoundList[path];
	// } 
	// public static function getSprite(path:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID:String = ""):Null<FlxGraphic>{
	// 	if(cacheID != "" && cacheIDList["SPRITE:" + cacheID] == path){
	// 		if(SpriteList[cacheID] == null){
	// 			cacheIDList["SPRITE:" + cacheID] = "";
	// 		}
	// 		else{
	// 			return SpriteList["SPRITE:" + cacheID];
	// 		}
	// 	}
	// 	if(SpriteList[path] == null){

	// 	// if(!FileSystem.exists(path)) return null;

	// 		if(!FlxG.save.data.cacheall && (!cache || !FlxG.save.data.cache)) return FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
	// 		if(cacheID != "" && cacheIDList["SPRITE:" + cacheID] == path){
	// 			cacheIDList["SPRITE:" + cacheID] = path;
	// 			SpriteList[cacheID] = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
	// 			path = cacheID;
	// 		}else{
	// 			SpriteList[path] = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
	// 		}
	// 		if(cacheTemp) cleanUpList[path] = 0;
	// 		SpriteList[path].destroyOnNoUse = false;
	// 		SpriteList[path].persist = true;
	// 	}
	// 	return SpriteList[path];
	// }

	// public static function loadGraphic(path:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID:String = ""):Null<FlxGraphic>{
	// 	// var spr = getSprite(path,cache,cacheTemp);
	// 	// if (spr == null) return null;
	// 	return FlxGraphic.fromBitmapData(getSprite(path,cache,cacheTemp,cacheID));
	// }

	// public static function loadText(textPath:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID:String = ""):String{
		
	// 	if(cacheID != "" && cacheIDList["TEXT:" + cacheID] == textPath){
	// 		if(TextList[cacheID] == null){
	// 			cacheIDList["TEXT:" + cacheID] = "";
	// 		}else{
	// 			return TextList[cacheID];
	// 		}
	// 	}
	// 	if(!FileSystem.exists(textPath)) return "";
 //      	if(!FlxG.save.data.cacheall && (!cache || !FlxG.save.data.cache)) return File.getContent('${textPath}');
 //      	if(cacheID == "") cacheID = textPath;
 //        if(TextList[cacheID] == null) TextList[cacheID] = File.getContent('${textPath}');
 //        if (cacheTemp) cleanUpList[textPath] = 2;
 //        return TextList[cacheID];
 //    }
	// public static function cacheText(textPath:String,?cacheTemp:Bool = false,?cacheID:String = ""):String{

	// 	if(cacheID != "" && cacheIDList["TEXT:" + cacheID] == textPath){
	// 		if(TextList[cacheID] == null){
	// 			cacheIDList["TEXT:" + cacheID] = "";
	// 		}else{
	// 			return TextList[cacheID];
	// 		}
	// 	}
	// 	if(!FileSystem.exists(textPath)) return null;
	// 	if(cacheTemp) cleanUpList[textPath] = 2;
	// 	if(cacheID == "") cacheID = textPath;
 //        if(TextList[cacheID] == null) TextList[cacheID] = File.getContent('${textPath}');
 //        return TextList[cacheID];
 //    }
	
	// public static function cacheSound(soundPath:String,?cacheTemp:Bool = false){
	// 	if(cacheTemp) cleanUpList[soundPath] = 1;
 //        if(SoundList[soundPath] == null) SoundList[soundPath] = Sound.fromFile('${soundPath}');
 //    }
    
 //    public static function cacheSprite(path:String,?cacheTemp:Bool = false,?cacheID:String = ""){

	// 	if(cacheID != "" && cacheIDList["SPRITE:" + cacheID] == path){
	// 		if(SpriteList[cacheID] == null){
	// 			cacheIDList["SPRITE:" + cacheID] = "";
	// 		}
	// 		else{
	// 			return;
	// 		}
	// 	}
	// 	if(SpriteList[path] == null){
	// 		if(cacheTemp) cleanUpList[path] = 0;
	// 		if(cacheID != "" && cacheIDList["SPRITE:" + cacheID] == path){
	// 			cacheIDList["SPRITE:" + cacheID] = path;
	// 			SpriteList[cacheID] = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
	// 			path = cacheID;
	// 		}else{
	// 			SpriteList[path] = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
	// 		}
	// 		SpriteList[path].destroyOnNoUse = false;
	// 		SpriteList[path].persist = true;
	// 	}
 //    }
 //    public static function loadSFramesSep(pngPath:String,xmlPath:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID:String = ""):Null<FlxAtlasFrames>{
 //    	if(!FileSystem.exists(pngPath)){
 //    		handleError("Invalid path " + pngPath);
 //    		return null;
 //    	}
 //    	if(!FileSystem.exists(xmlPath)){
 //    		handleError("Invalid path " + xmlPath);
 //    		return null;
 //    	}
	// 	// if(cacheTemp) cleanUpList[path] = 3;
 //        // if(spriteArray[pngPath + ".png"] == null) spriteArray[pngPath + ".png"] = BitmapData.fromFile('${pngPath}.png'));
 //        // if(xmlArray[pngPath + ".xml"] == null) xmlArray[pngPath + ".xml"] = File.getContent('${pngPath}.xml');

 //        return FlxAtlasFrames.fromSparrow(getSprite(pngPath,cache,cacheTemp,cacheID),loadText(xmlPath,cache,cacheTemp,cacheID));
 //    }
 //    public static function loadSparrowFrames(pngPath:String,?useCache:Bool = false,?cacheTemp:Bool = false,?cacheID:String = ""):Null<FlxAtlasFrames>{
 //    	if(!FileSystem.exists(pngPath + ".png") || !FileSystem.exists(pngPath + ".xml")){
 //    		handleError("Invalid path " + pngPath);
 //    		return null;
 //    	}
	// 	// if(cacheTemp) cleanUpList[path] = 3;
 //        // if(spriteArray[pngPath + ".png"] == null) spriteArray[pngPath + ".png"] = BitmapData.fromFile('${pngPath}.png'));
 //        // if(xmlArray[pngPath + ".xml"] == null) xmlArray[pngPath + ".xml"] = File.getContent('${pngPath}.xml');

 //        return FlxAtlasFrames.fromSparrow(getSprite(pngPath + ".png",cache,cacheTemp,cacheID),loadText(pngPath + ".xml",cache,cacheTemp,cacheID));
 //    }


 //    public static function unloadSound(soundPath:String){
 //        SoundList[soundPath] = null;
 //    }
 //    public static function unloadText(pngPath:String){
 //        TextList[pngPath] = null;
 //    }
 //    public static function unloadSprite(pngPath:String){
 //        SpriteList[pngPath].destroy();
 //        SpriteList[pngPath] = null;
 //    }
}

class InternalCache{
	public var spriteArray:Map<String,FlxGraphic> = [];
	public var bitmapArray:Map<String,BitmapData> = [];
	public var xmlArray:Map<String,String> = [];
	public var textArray:Map<String,String> = [];
	public var soundArray:Map<String,Sound> = [];
	// public var dumpGraphics:Bool = false; // If true, All FlxGraphics will be dumped upon creation, trades off bitmap editability for less memory usage
 
	@:keep inline static function getPath(path):String{return SELoader.getPath(path);}
	

	var id = "Internal Cache";
	public function new(){
		trace('Internal cache initialised');
	}
	public function clear(){
		for (i => v in spriteArray){
			if(v != null && v.destroy != null){
				v.destroy();
			}
		}

		openfl.system.System.gc();
	}
	inline function handleError(e:String){
		trace(e);
		if(MusicBeatState.instance != null) MusicBeatState.instance.showTempmessage(e); else MainMenuState.handleError(e);
	}


	// public function getPath(?str:String = ""){
	// 	return Sys.getCwd() + str;
	// }
	public function loadFlxSprite(x:Int,y:Int,pngPath:String):FlxSprite{
		return new FlxSprite(x, y).loadGraphic(loadGraphic(pngPath));
	}
	public function loadGraphic(pngPath:String):FlxGraphic{
		if(!exists('${pngPath}')){
			handleError('${id}: "${pngPath}" doesn\'t exist!');
			return FlxGraphic.fromRectangle(0,0,0); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath] == null) cacheGraphic(pngPath);
		return spriteArray[pngPath];
	}
	public function loadBitmap(pngPath:String):BitmapData{
		if(!exists('${pngPath}')){
			handleError('${id}: "${pngPath}" doesn\'t exist!');
			return new BitmapData(0,0,false,0xFF000000); // Prevents the script from throwing a null error or something
		}
		if(bitmapArray[pngPath] == null) cacheBitmap(pngPath);
		return bitmapArray[pngPath];
	}

	public function loadSparrowFrames(pngPath:String):FlxAtlasFrames{
		if(!exists('${pngPath}.png')){
			handleError('${id}: SparrowFrame PNG "${pngPath}.png" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(!exists('${pngPath}.xml')){
			handleError('${id}: SparrowFrame XML "${pngPath}.xml" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}

		return FlxAtlasFrames.fromSparrow(loadGraphic(pngPath + ".png"),loadText(pngPath + ".xml"));
	}
	public function loadSparrowSprite(x:Int,y:Int,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite{

		var spr = new FlxSprite(x, y);
		spr.frames= loadSparrowFrames(pngPath);
		if (anim != ""){
			spr.animation.addByPrefix(anim,anim,fps,loop);
			spr.animation.play(anim);
		}

		return spr;
	}

	public function loadText(textPath:String):String{
		cacheText(textPath);
		return textArray[textPath];
	}
	// public function saveText(textPath:String,text:String):Bool{
	// 	File.saveContent('${textPath}',text);
	// 	return true;
	// }



	public function loadSound(soundPath:String):Sound{
		cacheSound(soundPath);
		return soundArray[soundPath];
	}

	public function playSound(soundPath:String,?volume:Float = 0.662121):FlxSound{
		if(volume == 0.662121) volume = FlxG.save.data.otherVol;
		return FlxG.sound.play(loadSound(soundPath),volume);
	}

	public function unloadSound(soundPath:String){
		if(soundArray[soundPath] == null) return;
		soundArray[soundPath].close();
		soundArray[soundPath] = null;
	}
	public function unloadText(pngPath:String){
		textArray[pngPath] = null;
	}
	public function unloadShader(pngPath:String){
		textArray[pngPath + ".vert"] = null;
		textArray[pngPath + ".frag"] = null;
	}
	public function unloadSprite(pngPath:String){
		if(spriteArray[pngPath] == null) return;
		spriteArray[pngPath].destroy();
		spriteArray[pngPath] = null;
	}

	public function cacheText(textPath:String){
		if(textArray[textPath] != null){
			if(!exists('${textPath}')){
				trace('${id} : CacheText: "${textPath}" doesn\'t exist!');
				return;
			}
			textArray[textPath] = File.getContent('${textPath}');
		}
	}
	public function cacheSound(soundPath:String){
		if(soundArray[soundPath] == null) {
			if(!exists('${soundPath}')){
				trace('${id} : CacheSound: "${soundPath}" doesn\'t exist!');
				return;
			}
			soundArray[soundPath] = Sound.fromFile(getPath(soundPath));
		}
	}
	public function cacheBitmap(pngPath:String){ // DOES NOT CHECK IF FILE IS VALID!
		if(bitmapArray[pngPath] == null) bitmapArray[pngPath] = BitmapData.fromFile(getPath('${pngPath}'));
	}
	public function cacheGraphic(pngPath:String){ // DOES NOT CHECK IF FILE IS VALID!
		
		cacheBitmap('${pngPath}');
		if(spriteArray[pngPath] == null) spriteArray[pngPath] = FlxGraphic.fromBitmapData(bitmapArray[pngPath]);
		if(spriteArray[pngPath] == null) handleError('${id} : cacheGraphic: Unable to load $pngPath into a FlxGraphic!');
		spriteArray[pngPath].persist = true;
		spriteArray[pngPath].destroyOnNoUse = false;
		// if(dumpGraphic || dumpGraphics) spriteArray[pngPath].dump();

	}
	public function cacheSprite(pngPath:String){

		if(spriteArray[pngPath] == null) {
			if(!SELoader.exists('${pngPath}.png')){
				handleError('${id} : CacheSprite: "${pngPath}.png" doesn\'t exist!');
				return;
			}
			cacheGraphic('${pngPath}.png');
		}
	}
	@:keep inline public static function absolutePath(path:String):String{
		return SELoader.absolutePath(getPath(path));
	}
	@:keep inline public static function fullPath(path:String):String{
		return SELoader.fullPath(getPath(path));
	}
	@:keep inline public static function exists(path:String):Bool{
		return SELoader.exists(getPath(path));
	}
	@:keep inline public static function readDirectory(path:String):Array<String>{
		return SELoader.readDirectory(getPath(path));
	}
	@:keep inline public static function isDirectory(path:String):Bool{
		return SELoader.isDirectory(getPath(path));
	}
	@:keep inline public static function createDirectory(path:String){
		return SELoader.createDirectory(getPath(path));
	}
}