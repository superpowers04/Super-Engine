package;

// Class used for loading sprites and caching them, hopefully will be more efficient than Flixels built-in caching
// This will work reguardless of if they're in assets/ or not


import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileInput;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import lime.media.AudioBuffer;
import haxe.io.Bytes;
import se.formats.SongInfo;
import se.formats.Song.SwagSong;
import se.formats.VSliceSongMeta;
// import vlc.VLCSound;
using StringTools;

// This uses rawmode all of the time because this uses absolute pathing. 
// I plan to support more storage locations so we HAVE to use SELoader
@:publicFields class SEDirectory { 
	var path:String;
	function new(_path:String = ""){
		path=SELoader.getPath(_path);
		if(path.substring(-1) != "/") path+="/";
	}
	@:keep inline function appendPath(?part:String){
		return part == null ? path : path + part;
	}
	@:keep inline function cd(part:String):SEDirectory{
		path+='/$part';
		return this;
	}
	function exists(?path:String):Bool{
		SELoader.rawMode=true;
		return SELoader.exists(appendPath(path));
	}
	function newDirectory(?path:String):SEDirectory{
		SELoader.rawMode=true;
		return new SEDirectory(appendPath(path));
	}
	function isDirectory(?path:String):Bool{
		SELoader.rawMode=true;
		return SELoader.isDirectory(appendPath(path));
	}
	function readDirectory(?path:String){
		SELoader.rawMode=true;
		return SELoader.readDirectory(appendPath(path));
	}
	function getContent(?path:String):String{
		SELoader.rawMode=true;
		return SELoader.getContent(appendPath(path));
	}
	@:keep inline function toString(){
		return path;
	}
}
class SELoader {
	static final normalFolders:Map<String,Bool> = [
		'assets'=>true,
		'characters'=>true,
		'custom_events'=>true,
		'custom_notetypes'=>true,
		'data'=>true,
		'dialogue'=>true,
		'fonts'=>true,
		'images'=>true,
		'music'=>true,
		'scripts'=>true,
		'shaders'=>true,
		'songs'=>true,
		'sounds'=>true,
		'stages'=>true,
		'videos'=>true,
		'weeks'=>true,
	];

	static public var cache:InternalCache = new InternalCache();
	public static var AssetPathCache:Map<String,String>=[];
	public static var AssetPathListingCache:Map<String,Array<String>>=[];
	public static var aliases:Map<String,String>=[];
	
	public static var PATH(default,set):String = '';
	public static function set_PATH(?_path:String = "./"):String{
		_path = _path.replace('\\',"/"); // Unix styled paths, Windows \\ paths are weird and fucky and i hate it
		if(!_path.endsWith('/')) _path = _path + "/"; // SELoader expects the main path to have a / at the end
		
		return PATH = _path.replace('//','/'); // Fixes paths having //'s in them 
	}
	public static var rawMode = false;
	public static var defaultRawMode = false;
	public static var ignoreMods = false;
	public static var id = "SELoader";
	public static var namespace = "";
	inline public static function handleError(e:String){
		e = '${id}: $e';
		trace(e);
		throw(e);
		// if((cast (FlxG.state)).handleError != null) (cast (FlxG.state)).handleError(e); else MainMenuState.handleError(e);
	}
	// Basically clenses paths and returns the base path with the requested one. Used heavily for the Android port
	@:keep inline public static function getPath(path:String="",allowModded:Bool = true):String{
		if(path == "") return PATH;
		// Absolute paths should just return themselves without anything changed
		if( rawMode ||
			#if windows
				path.charAt(1) == ':' || 
			#end
				path.charAt(0) == "/" || path.substring(0,2) == "./"){
			rawMode = defaultRawMode;
			return path.replace('//','/');
		}
		if(aliases[path] != null) return getRawPath(aliases[path]);
		// Allow custom assets
		if(path.substring(0,7) == "assets:" || (!ignoreMods && allowModded && path.substring(0,7) == "assets/")){
			return getAssetPath(path);
		}
		// Remove library from path
		if(path.indexOf(":") > 3) path = path.substring(path.indexOf(":") + 1);
		// if( && FileSystem.exists('${PATH}mods${path}')) path = 'mods/' + path; // Return modded assets before vanilla assets

		return (PATH + path).replace('//','/'); // Fixes paths having //'s in them
	}
	// The above but skips the getAssetPath check
	@:keep inline public static function getRawPath(path:String,allowModded:Bool = true):String{
		
		// Absolute paths should just return themselves without anything changed
		if(rawMode || 
			#if windows
				path.charAt(1) == ':' || 
			#end
				path.charAt(0) == "/" || path.substring(0,2) == "./"){
			rawMode = defaultRawMode;
			return path.replace('//','/');
		}
		// Remove library from path
		if(path.indexOf(":") > 3) path = path.substring(path.indexOf(":") + 1);

		return (PATH + path).replace('//','/'); // Fixes paths having //'s in them
	}
	public static function getAssetPath(path:String,?namespace:String = ""):String{
		if(#if windows path.charAt(1) == ':' || #end path.charAt(0) == "/" || rawMode){
			rawMode=false;
			return path.replace('//','/');
		}
		// Remove library
		if(path.indexOf(':') > 2) path = path.substring(path.indexOf(":") + 1);
		if(path.startsWith('assets/')) path = path.substring(7);
		final modsFolder = new SEDirectory(getRawPath('mods/'));
		final packsFolder = modsFolder.newDirectory('packs/');
		if(namespace=="") namespace=SELoader.namespace;
		if(namespace!=""){ // We always want to check the namespace first, It has top priority
			final packFolder = (namespace == "INTERNAL" || namespace == "assets") ? getPath() : packsFolder+namespace;
			SELoader.ignoreMods = true;
			final the = SELoader.anyExists([
				packFolder+'/'+path,
				packFolder+'/shared/'+path,
				packFolder+'/assets/'+path,
				packFolder+'/assets/shared/'+path,
				packFolder+'/assets/preload/'+path
			]);
			SELoader.ignoreMods = false;
			if(the!=null) return the;
		}
		{ // If the path has already been found before, just use that. No need to re-scan
			final PATH = AssetPathCache[path];
			if(PATH!=null) return PATH == "" ? SELoader.getRawPath("assets/"+path,false) :PATH; 
		}
		{ // Mods folder
			final the = SELoader.anyExists([
				'mods/'+path,
				'mods/shared/'+path,
				'mods/assets/'+path,
				'mods/assets/shared/'+path,
				'mods/assets/preload/'+path
			]);
			if(the!=null) return AssetPathCache[path]=the;
		}
		final p = SELoader.getRawPath("assets/"+path);
		// Cache as an empty string, literally no fucking reason to store the same string twice in memory
		AssetPathCache[path]="";

		if(!exists(p)){ // I am honestly too lazy at the moment to add a proper mods menu
			AssetPathCache[path]=null;
			{
				final rawAssets = getRawPath('assets/');
				rawMode=defaultRawMode=true;
				final the = SELoader.anyExists([
					rawAssets+'/'+path,
					rawAssets+'/shared/'+path,
				]);
				rawMode=defaultRawMode=false;
				if(the!=null) return AssetPathCache[path]=the;
			}
			if(!SESave.data.HDDMode){
				if(SELoader.exists(modsFolder + path)) return AssetPathCache[path]=modsFolder+path;
				for (directory in orderList(SELoader.readDirectory(packsFolder.toString()))){
					final packFolder = packsFolder+directory;
					final the = SELoader.anyExists([
						packFolder+'/'+path,
						packFolder+'/shared/'+path,
						packFolder+'/assets/'+path,
						packFolder+'/assets/shared/'+path,
						packFolder+'/assets/preload/'+path
					]);
					if(the!=null) return AssetPathCache[path]=the;
				}
			}
			trace('Unable to find "${path}"!');
		}
		return p;
	}

	public static function loadText(textPath:String,?useCache:Bool = false):String{
		textPath = getPath(textPath);
		if(cache.textArray[textPath] != null || useCache){
			return cache.loadText(textPath);
		}
		if(!exists(textPath)){
			handleError(' Text "${textPath}" doesn\'t exist!');
			return "";
		}
		return File.getContent(textPath);
	}
	public static function loadXML(textPath:String,?useCache:Bool = false):String{ // Automatically fixes UTF-16 encoded files
		if(textPath.substring(textPath.length-4) != ".xml") textPath+='.xml';
		return cleanXML(loadText(textPath,useCache));
	}
	public static function cleanXML(text:String):String{ // Automatically fixes UTF-16 encoded files
		
		final text = text.replace("UTF-16","utf-8");
		// final nul = String.fromCharCode(0);
		if(text.substr(2).contains("U\x00T\x00F\x00-\x001\x006")){ // Flash CS6 outputs a UTF-16 xml even though no UTF-16 characters are usually used. This reformats the file to be UTF-8 *hopefully*
			return '<?' + text.substr(2).replace(String.fromCharCode(0),'').replace('UTF-16','utf-8');
		}
		return text;
	}

	public static function loadFlxSprite(x:Float = 0,y:Float = 0,pngPath:String,?useCache:Bool = false):FlxSprite{
		if(!SELoader.exists('${pngPath}')){
			handleError(' Image "${pngPath}" doesn\'t exist!');
			return new FlxSprite(x, y); // Prevents the script from throwing a null error or something
		}
		return new FlxSprite(x, y).loadGraphic(loadGraphic(pngPath,useCache));
	}
	public static function loadGraphic(pngPath:String,?useCache:Bool = false):FlxGraphic{
		if(useCache) return cache.loadGraphic(pngPath);
		return FlxGraphic.fromBitmapData(loadBitmap(pngPath));
	}

	@:access(openfl.display.BitmapData)
	public static function cacheOnGPU(bitmap:BitmapData):BitmapData{ // I didn't steal this from Psych Engine, naaaahhhh
		if (!SESave.data.gpuCaching || bitmap?.image == null) return bitmap;
		bitmap.lock();
		if (bitmap.__texture == null) {
			bitmap.image.premultiplied = true;
			bitmap.getTexture(FlxG.stage.context3D);
		}
		bitmap.getSurface();
		bitmap.disposeImage();
		bitmap.image.data = null;
		bitmap.image = null;
		bitmap.readable = true;
		return bitmap;
		
	}
	public static function loadBitmap(pngPath:String,?useCache:Bool = false):BitmapData{
		if(pngPath.substr(-4) != ".png") pngPath += '.png';
		final pngPath = getPath(pngPath);
		if(cache.bitmapArray[pngPath] != null || useCache){
			return cache.loadBitmap(pngPath);
		}
		if(!exists('${pngPath}')){
			handleError(' "${pngPath}" doesn\'t exist!');
			return new BitmapData(0,0,false,0xFF000000); // Prevents the script from throwing a null error or something
		}
		return BitmapData.fromFile(pngPath);
	}


	public static function loadStichedSparrowFrames(pngPath:String,?cache:Bool=false):FlxAtlasFrames{
		pngPath = getPath(pngPath);
		if(!exists('${pngPath}.png')){
			handleError(' SparrowFrame PNG "${pngPath}.png" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(!exists('${pngPath}.xml')){
			handleError(' SparrowFrame XML "${pngPath}.xml" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		final atlas = FlxAtlasFrames.fromSparrow(loadGraphic('$pngPath.png',cache),loadXML('${pngPath}',cache));
		var i = 1;
		while(exists('${pngPath}-$i.png') && exists('${pngPath}-$i.xml')){
			final pngPath ='${pngPath}-$i' ;
			trace(pngPath);
			i++;
			final nextAtlas = FlxAtlasFrames.fromSparrow(loadGraphic('$pngPath.png',cache),loadXML('${pngPath}',cache));
			@:privateAccess{
				if(!atlas.usedGraphics.contains(atlas.parent)){
					atlas.usedGraphics.push(atlas.parent);
				}
			}
			atlas.addAtlas(nextAtlas);
		}
		return atlas;
	}
	public static function loadSparrowFrames(pngPath:String,?cache:Bool=false,?xml:String = ""):FlxAtlasFrames{
		pngPath = getPath(pngPath);
		if(!exists('${pngPath}.png')){
			handleError(' SparrowFrame PNG "${pngPath}.png" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		if(!exists('${pngPath}.xml')){
			handleError(' SparrowFrame XML "${pngPath}.xml" doesn\'t exist!');
			return new FlxAtlasFrames(FlxGraphic.fromRectangle(0,0,0)); // Prevents the script from throwing a null error or something
		}
		return FlxAtlasFrames.fromSparrow(loadGraphic('$pngPath.png',cache),xml == "" ? loadXML('${pngPath}',cache) : xml);
	}
	public static function loadSparrowSprite(x:Float,y:Float,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24,?useCache:Bool = false):FlxSprite{
		pngPath = getPath(pngPath);
		final spr = new FlxSprite(x, y);
		final _f = spr.frames;
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
		AssetPathListingCache = [];
		AssetPathCache=[];
		gc();
	}
	@:keep inline public static function getContent(textPath:String):String{return loadText(textPath,false);}
	public static function getChart(textPath:String,?difficulty:String="normal"):SwagSong{
		// return Song.parseJSONshit(loadText(textPath,false));

		final colonIndex = textPath.lastIndexOf(':');
		final oldPath = textPath;
		if(colonIndex > 4) {
			difficulty = textPath.substring(colonIndex+1);
			textPath = textPath.substring(0,colonIndex);
		}
		if(!(textPath.lastIndexOf('-metadata') != -1 || textPath.lastIndexOf('-chart') != -1)){
			final s:SwagSong = Song.parseJSONshit(loadText(oldPath,false));
			try{

				if(SESave.data.loadPsychEvents){
					final events = oldPath.substring(0,oldPath.lastIndexOf('/'))+'/events.json';
					if(exists(events)){
						Song.loadEvents(s,loadText(events,false));
					}
				}
			}catch(e){
				trace('Unable to load events: $e');
			}
			return s;
		}

		textPath = textPath.replace('-metadata','_FILE_').replace('-chart','_FILE_');
		final rawJson = loadText(textPath.replace('_FILE_','-chart'),false);
		final metaJson = loadText(textPath.replace('_FILE_','-metadata'),false);
		return Song.fromVSlice('{"meta":$metaJson,'+rawJson.substring(rawJson.indexOf('{')+1,rawJson.lastIndexOf('}'))+'}',difficulty);


		// if(textPath.lastIndexOf('-metadata.json') != -1){
		// 	if(colonIndex != -1){
		// 	}
		// 	var meta = loadText(textPath,false);
		// 	var chartPath = (textPath.substring(0,textPath.lastIndexOf('-'))+'-chart.json');

		// 	return Song.fromVSlice(rawJson,difficulty);
		// }

		// if(colonIndex == -1 && difficulty == "") return Song.parseJSONshit(loadText(textPath,false));
		
		// if(colonIndex != -1){
		// 	textPath = textPath.substring(0,colonIndex);
		// 	difficulty = textPath.substring(colonIndex+1);
		// }
		
		// var rawJson = loadText(textPath,false);
		// rawJson = rawJson.substring(rawJson.indexOf('{'),rawJson.lastIndexOf('}'));
		// var metaPath = (textPath.substring(0,textPath.lastIndexOf('-'))+'-metadata.json');
		// trace('$metaPath');
		// if(exists(metaPath)){
		// 	var meta = loadText(metaPath,false);
		// 	rawJson = '{"meta":'+meta+','+rawJson.substring(1);
		// }
	}

	/* TODO ADD SUPPORT FOR JUST FINDING CHARACTER PNGS */
	public static function registerCharactersInFolder(ID:Int=0,path:String,?nameSpace:String="UNKNOWN",?recurse:Bool = true){
		final ADDPE:Bool=SESave.data.PECharSeperate;
		final LOADPE:Bool=SESave.data.PECharLoading;
		final _dir = new SEDirectory(path);
		if(!_dir.exists('characters/')) {
			if(!recurse || !LOADPE || ID==0) return;
			var foundCharacterFolder:Bool = false;
			if(_dir.exists('assets/shared/characters')){
				registerCharactersInFolder(ID,_dir.appendPath('assets/shared/'),nameSpace,false);
				foundCharacterFolder=true;
			}
			if(_dir.exists('assets/characters')){
				registerCharactersInFolder(ID,_dir.appendPath('assets/'),nameSpace,false);
				foundCharacterFolder=true;
			}
			final modsFolder = _dir.newDirectory('mods/');
			if(modsFolder.exists()){
				if(modsFolder.exists('characters')){
					registerCharactersInFolder(ID,modsFolder.toString(),nameSpace,false);
					foundCharacterFolder=true;
				}else{
					for(mod in modsFolder.readDirectory()){
						registerCharactersInFolder(ID,modsFolder.appendPath(mod),nameSpace);
					}
				}
			}
			// if(!foundCharacterFolder){
			// 	if(_dir.exists('assets/shared/characters')){
			// 		registerCharactersInFolder(ID,_dir.appendPath('assets/shared/'),nameSpace,false);
			// 		foundCharacterFolder=true;
			// 	}

			// }

			return;
		}
		_dir.cd('characters/');
		// trace('Checking ${dir} for characters');
		for (char in _dir.readDirectory()) {
			if (LOADPE && !_dir.isDirectory(char)){
				if (char.substring(char.length-5) == ".json"){ // Psych characters
					TitleState.characters.push({
						id:char.substring(0,char.length-5).replace(' ',"-").replace('_',"-").toLowerCase()+(ADDPE?"-pe":""),
						folderName:char,
						jsonLocation:'$_dir/$char',
						psychChar:true,
						path:'$_dir',
						nameSpaceType:ID,
						nameSpace:nameSpace
					});
				}
				continue;
			}
			final charPath = _dir.newDirectory(char);
			if (charPath.exists("config.json")) {
				TitleState.characters.push({
					id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
					folderName:char,
					description:(charPath.exists('description.txt') ? ';${SELoader.getContent('${charPath}/description.txt')}' : null),
					path:'${_dir}',
					nameSpaceType:ID,
					nameSpace:nameSpace
				});
				continue;

			}
			if (charPath.exists("script.hscript")) {
				TitleState.characters.push({
					id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
					folderName:char,
					description:(charPath.exists('description.txt') ? ';${SELoader.getContent('${charPath}/description.txt')}' : null),
					path:'${_dir}',
					nameSpaceType:ID,
					type:1,
					nameSpace:nameSpace
				});
				continue;
			}
			if (charPath.exists("character.png") && (charPath.exists("character.xml") || charPath.exists("config.json"))){
				TitleState.invalidCharacters.push({
					id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
					folderName:char,
					path:'${_dir}',
					nameSpaceType:ID,
					nameSpace:nameSpace
				});
				continue;
			}
		}
		  
		
	}

	@:keep inline public static function triggerSave(textPath:String,content:String):Dynamic{
		se.objects.SaveIcon.show();
		return saveText(textPath,content,false);
	}
	@:keep inline public static function saveContent(textPath:String,content:String):Dynamic{return saveText(textPath,content,false);}
	@:keep inline public static function getBytes(textPath:String):Bytes{return loadBytes(textPath,false);}
	@:keep inline public static function gc(){
		FlxG.bitmap.clearUnused();
		openfl.system.System.gc();
	}

	public static function loadBytes(textPath:String,?useCache:Bool = false):Bytes{
		// No cache support atm

		// if(cache.textArray[textPath] != null || useCache){
		// 	return cache.loadText(textPath);
		// }
		textPath = getPath(textPath);
		if(!exists(textPath)){
			handleError(' Text "${textPath}" doesn\'t exist!');
			return null;
		}
		return File.getBytes(getPath(textPath));
	}
	public static function saveBytes(textPath:String,contents:Bytes){ // If there's an error, it'll return the error, else it'll return null
		try{
			File.saveBytes(getPath(textPath),contents);
		}catch(e){ return e; }
		return null;
	}
	public static function saveText(textPath:String,contents:String = "",?useCache:Bool = false):Dynamic{ // If there's an error, it'll return the error, else it'll return null
		textPath = getPath(textPath);
		try{
			File.saveContent(textPath,contents);
		}catch(e){ return e; }
		if(cache.textArray[textPath] != null || useCache){
			cache.textArray[textPath] = contents;
		}
		return null;
	}
	public static function loadSound(soundPath:String,?useCache:Bool = false):Null<Sound>{
		if(soundPath.lastIndexOf('.') == -1){
			soundPath+='.ogg';
		}
		final rawPath = getPath(soundPath);
		if(cache.soundArray[rawPath] != null || useCache){
			return cache.loadSound(rawPath);
		}
		if(!exists(soundPath)){
			handleError(' Sound "$soundPath" > "$rawPath" doesn\'t exist!');
			// return null;
		}
		return Sound.fromFile(getPath(rawPath));
	}
	@:keep inline public static function loadFlxSound(soundPath:String,?useCache:Bool=false):FlxSound{
		return new FlxSound().loadEmbedded(loadSound(soundPath,useCache));
	}


	static public function playSound(soundPath:String = "",?volume:Dynamic = null,?cache:Bool = false):FlxSound{
		if(soundPath == ""){
			try{
				throw('Tried to play an empty sound!');
			}catch(e){
				trace('UNABLE TO PLAY SOUND: ${e.details()}');
			}
			return null;
		}
		var _vol = SESave.data.otherVol;
		if(volume != null){

			if(volume is String){
				switch(volume.toLowerCase()){
					case "inst": _vol = SESave.data.instVol;
					case "voices": _vol = SESave.data.voicesVol;
					case "master": _vol = SESave.data.masterVol;
					case "hit": _vol = SESave.data.hitVol;
					case "misses": _vol = SESave.data.missVol;
					default: _vol = SESave.data.otherVol;
				}
			}else if(volume is Int || volume is Float){
				_vol = volume;
			}
		}
		// if(volume == 0.662121) volume = SESave.data.otherVol;
		return FlxG.sound.play(loadSound(soundPath,cache),_vol);
	}


	// Clones of FileSystem and File functions. Eventually, zip support might be added. This'll also allow custom formats to be used

	public static function absolutePath(path:String):String{
		return FileSystem.absolutePath(getPath(path));
	}
	public static function absoluteRawPath(path:String):String{
		return FileSystem.absolutePath(getRawPath(path));
	}
	public static function fullPath(path:String):String{
		return FileSystem.fullPath(getPath(path));
	}

	public static function anyExists(paths:Array<String>,?returnOriginal:Bool = false,?defaultValue:String = null):String{
		for(i in paths) {
			final path = getPath(i);
			if(exists(path)) return returnOriginal ? i : path;
		}
		return defaultValue;
	}
	#if windows 
		@:keep inline public static function anyExistsInsensitive(paths:Array<String>,?returnOriginal:Bool = false,?defaultValue:String = null):String{ return anyExists(paths,returnOriginal,defaultValue); }
	#else

	public static function anyExistsInsensitive(paths:Array<String>,?returnOriginal:Bool = false,?defaultValue:String = null):String{
		for(i in paths) {
			var path = getPath(i);
			if(exists(path)) return returnOriginal ? i : path;
		}
		for(i in paths) {
			var path = getPath(i);
			var folder = path.substring(0,path.lastIndexOf('/'));
			var file = path.substring(path.lastIndexOf('/')+1).toLowerCase();

			for(FILE in readDirectory(folder)){
				if(FILE.toLowerCase() != file) continue;
				return folder+"/"+FILE;
				
			}
			
		}
		return defaultValue;
	}
	#end
	public static function exists(path:String):Bool{
		try{
			return FileSystem.exists(getPath(path));
		}catch(e){trace('$path is an invalid path!');return false;}
	}
	@:keep inline public static function readDirectoryOrdered(path:String):Array<String>{
		return inline CoolUtil.orderList(readDirectory(path));
	}
	public static function readDirectory(path:String):Array<String>{
		if(SESave.data.HDDMode || (!path.startsWith('assets/') && !path.startsWith('assets:'))) return FileSystem.readDirectory(getPath(path));
		
		path = path.substring(7);
		if(AssetPathListingCache[path] != null){
			return AssetPathListingCache[path].copy();
		}
		final modsFolder = new SEDirectory(getRawPath('mods/'));
		final packsFolder = modsFolder.newDirectory('packs/');
		final listing:Map<String,Bool> = [];
		for (pack in orderList(SELoader.readDirectory(packsFolder.toString()))){
			if(exists('$packsFolder/$pack/assets/$path')){
				for(p in readDirectory('$packsFolder/$pack/assets/$path')){
					listing[p]=true;
				}
			}
			if(exists('$packsFolder/$pack/assets/shared/$path')){
				for(p in readDirectory('$packsFolder/$pack/assets/shared/$path')){
					listing[p]=true;
				}
			}
		}
		return (AssetPathListingCache[path] = [for(key in listing.keys()) key]).copy();
		
	}
	public static function readDirectories(paths:Array<String>):Array<String>{
		final ret = [];
		for(path in paths){
			final _path = getPath(path,false);
			if(exists(_path) && isDirectory(_path)){
				for(item in readDirectory(_path)){
					ret.push('$path/$item');
				}
			}
		}
		return ret;
	}
	@:keep inline public static function getAsDirectory(path:String):SEDirectory{
		return new SEDirectory(path);
	}
	@:keep inline public static function upDirectory(path:String):String{
		return path.substring(0,path.lastIndexOf('/',path.length-2)+1);
	}
	@:keep inline public static function upDirs(path:String,count:Int = 2):String{
		var i = path.length-2;
		while (count >= 0){ count--; i = path.lastIndexOf('/',i); }
		return path.substring(0,i+1);
	}
	public static function readDirectoriesAsPaths(paths:Array<String>):Array<SEDirectory>{
		final ret = [];
		for(path in paths){
			final _path = new SEDirectory(path);
			if(_path.exists() && _path.isDirectory()){
				for(item in _path.readDirectory()){
					ret.push(_path.newDirectory(item));
				}
			}
		}
		return ret;
	}
	public static function isDirectory(path:String):Bool{
		return FileSystem.isDirectory(getPath(path));
	}
	public static function write(path:String,binary:Bool=true):FileOutput{
		return File.write(getPath(path));
	}
	public static function read(path:String,binary:Bool=true):FileInput{
		return File.read(getPath(path));
	}
	public static function cleanPath(path:String):String{
		return path.replace('..\\','').replace('../','');
	}
	public static function append(path:String,binary:Bool=true):FileOutput{
		return File.append(getPath(path));
	}
	public static function createDirectory(path:String){
		return FileSystem.createDirectory(getPath(path));
	}
	public static function createDirUnlessExists(path:String){
		var p = getPath(path);
		if(FileSystem.exists(p)) return;
		return FileSystem.createDirectory(p);
	}
	public static function copy(from:String,to:String){
		return File.copy(getPath(from),getPath(to));
	}
	public static function importFile(from:String,to:String){
		final path = getPath(to);
		FileSystem.createDirectory(upDirectory(path));
		return File.copy(from,path);
	}
	public static function exportFile(from:String,to:String){
		return File.copy(getPath(from),to);
	}

	static function orderList(list:Array<String>):Array<String>{
		haxe.ds.ArraySort.sort(list, function(a, b) {
			a=a.toLowerCase();
			b=b.toLowerCase();
			return (a<b) ? -1 : ((a>b) ? 1 : 0);
		});
		return list;
	}
	public static function getSongsFromFolder(path:String,?query:String = ""):Array<SongInfo>{
		final path=new SEDirectory(path);
		final returnArray:Array<SongInfo> = [];
		if(!path.isDirectory()) return returnArray;
		final blockedFiles = multi.MultiMenuState.blockedFiles;
		if(path.isDirectory('assets/')){ // subfolder
			for(i in getSongsFromFolder(path.appendPath('assets/'),query)) returnArray.push(i);
		}
		if(path.isDirectory('mods/')){ // subfolder
			final modsFolder:SEDirectory = path.newDirectory('mods/');
			// if(modsFolder.isDirectory('images')){ // Treat as a seperate assets folder
			// }
			for(i in getSongsFromFolder(modsFolder.toString(),query)) returnArray.push(i);
			for(i in modsFolder.readDirectory()){ // Treat as a folder of mods
				if(normalFolders.get(i) == true) continue;
				for(i in getSongsFromFolder(modsFolder.appendPath(i),query)) returnArray.push(i);
			}
		}

		if(path.isDirectory('charts/')){ // SE
			for (folder in path.readDirectory('charts/')){
				final path = path.newDirectory('charts/$folder');
				if((!path.exists('Inst.ogg') && !path.exists('ignoreMissingInst'))) continue;
				final song:SongInfo = {
					name:folder,
					charts:[],
					namespace:null,
					path:path.toString()
				};
				for (file in orderList(path.readDirectory())){
					if(file.substring(file.length-5) != ".json" || blockedFiles.contains(file.toLowerCase())) 
						continue;
					song.charts.push(file);
				}
				returnArray.push(song);
			}
		}
		if(path.isDirectory('data/')){ // Normal FNF
			final songsFolder = path.newDirectory('songs/');
			final data = path.newDirectory('data/');
			if(data.exists('songData')){ // Legacy psych
				data.cd('songData');
			}
			if(data.exists('songs')){ // VSlice
				final data = data.newDirectory('songs');
				for (folder in data.readDirectory()){
					final path = data.newDirectory('$folder');
					if(!path.isDirectory() || !songsFolder.exists('$folder/Inst.ogg')) continue;
					for (file in orderList(path.readDirectory())){
						if((query != "" && file.lastIndexOf(query) == -1) || file.lastIndexOf('-metadata') == -1) continue;
						final e:VSliceSongMeta = Json.parse(SELoader.getContent(path.appendPath(file)));
						final folder = songsFolder.newDirectory(folder);
						final name = file.substr(0,file.lastIndexOf('-metadata'));
						final song:SongInfo = {
							name:file.substr(0,file.lastIndexOf('.')).replace('-metadata',''),
							charts:[],
							namespace:null,

							path:path.toString()
						};
						var ie = e.playData.characters.instrumental?? "";
						if(ie != "") ie='-$ie';

						final t = ie != "" ? ie : name.indexOf('-') == -1 ? "" : name.substring(name.indexOf('-'));
						var pe = e.playData.characters.player;
						var p = pe;
						song.voices = folder.appendPath('Voices-$p$t.ogg');
						while(!exists(song.voices)){
							final index = p.lastIndexOf('-');
							if(index == -1){
								song.voices=folder.appendPath('Voices-$p.ogg');
								break;
							}
							p = p.substring(0,index);
							song.voices=folder.appendPath('Voices-$p$t.ogg');
						}
						if(!exists(song.voices)) song.voices=folder.appendPath('Voices.ogg');

						var oe = e.playData.characters.opponent;
						var opponentVoices = folder.appendPath('Voices-$oe$t.ogg');
						while(!exists(opponentVoices)){
							final index = oe.lastIndexOf('-');
							if(index == -1){
								opponentVoices=folder.appendPath('Voices-$oe.ogg');
								break;
							}
							oe = oe.substring(0,index);
							opponentVoices=folder.appendPath('Voices-$oe$t.ogg');
						}
						if(exists(opponentVoices)) song.extraVoices.push(opponentVoices);


						song.inst = folder.appendPath('Inst$t.ogg');
						if(!exists(song.inst)) song.inst = folder.appendPath('Inst.ogg');
						for (diff in e.playData.difficulties){
							song.charts.push(file.replace('-metadata','-chart')+':'+diff);
						}
						returnArray.push(song);
						
					}
					// song.inst = songsFolder.appendPath('$folder/Inst.ogg');
					// song.voices = songsFolder.appendPath('$folder/Voices.ogg');
					// for (file in orderList(path.readDirectory())){
					// 	if(file.substring(file.length-5) != ".json" || blockedFiles.contains(file.toLowerCase())) 
					// 		continue;
					// 	song.charts.push(file);
					// }
					
				}
			}
			final list = data.readDirectory();
			// for (chart in list){
			// 	if(chart.contains(''))
			// }
			for (folder in list){
				final path = data.newDirectory('$folder');
				if(!path.isDirectory() || !songsFolder.exists('$folder/Inst.ogg')) continue;
				final  song:SongInfo = {
					name:folder,
					charts:[],
					namespace:null,

					path:path.toString()
				};
				song.inst = songsFolder.appendPath('$folder/Inst.ogg');
				song.voices = songsFolder.appendPath('$folder/Voices.ogg');
				for (file in orderList(path.readDirectory())){
					if(file.substring(file.length-5) != ".json" || blockedFiles.contains(file.toLowerCase())) 
						continue;
					song.charts.push(file);
				}
				returnArray.push(song);
			}
		}
		if(path.isDirectory('songs/')){ // Codename :sob:
			var path = path.newDirectory('songs/');
			for (folder in path.readDirectory()){
				if(!path.isDirectory('$folder/charts')) continue;
				var path = path.newDirectory('$folder');
				var song:SongInfo = {
					name:folder,
					charts:[],
					namespace:null,

					path:path.toString()
				};
				song.inst = path.appendPath('song/Inst.ogg');
				song.voices = path.appendPath('song/Voices.ogg');
				for (file in orderList(path.readDirectory('charts'))){
					if(file.substring(file.length-5) != ".json" || blockedFiles.contains(file.toLowerCase())) 
						continue;
					song.charts.push('charts/$file');
				}
				returnArray.push(song);
			}
		}
		if(returnArray.length < 0){
			for (file in orderList(path.readDirectory())){
				if(!path.isDirectory(file)) continue;
				var songs = getSongsFromFolder(path.appendPath());
				if(songs.length > 0){
					for (song in songs) returnArray.push(song);
				}
			}
		}
		return returnArray;

	}

}
class InternalCache{
	public var spriteArray:Map<String,FlxGraphic> = [];
	public var bitmapArray:Map<String,BitmapData> = [];
	public var xmlArray:Map<String,String> = [];
	public var textArray:Map<String,String> = [];
	public var soundArray:Map<String,Sound> = [];
	public var audioBufferArray:Map<String,AudioBuffer> = [];
	// public var dumpGraphics:Bool = false; // If true, All FlxGraphics will be dumped upon creation, trades off bitmap editability for less memory usage
 
	@:keep inline static function getPath(path):String{return SELoader.getPath(path);}

	

	var id = "Internal Cache";
	public function new(?id:String = "Internal Cache"){
		this.id = id;
		trace('New cache $id');
	}
	public function clear(){
		for (id=>v in spriteArray){spriteArray[id]=null;}
		for (id=>v in bitmapArray){bitmapArray[id]=null;}
		for (id=>v in textArray){textArray[id]=null;}
		for (id=>v in xmlArray){xmlArray[id]=null;}
		for (id=>v in soundArray){soundArray[id]=null;}
		for (id=>v in audioBufferArray){audioBufferArray[id]=null;}
		openfl.system.System.gc();
	}
	// clear USED to destroy objects. now it just removes them- what the fuck was I smoking :sob:
	public function clearAndDestroy(){
		for (id=>v in spriteArray){if(v?.destroy != null) v.destroy();spriteArray[id]=null;}
		for (id=>v in bitmapArray){if(v?.dispose != null) v.dispose();bitmapArray[id]=null;}
		for (id=>v in textArray){textArray[id]=null;}
		for (id=>v in xmlArray){xmlArray[id]=null;}
		for (id=>v in soundArray){if(v?.close != null) v.close();soundArray[id]=null;}
		for (id=>v in audioBufferArray){audioBufferArray[id]=null;}
		openfl.system.System.gc();
	}
	inline public function handleError(e:String){
		e = '${id}: '+e;
		trace(e);
		throw(e);
		// if((cast (FlxG.state)).handleError != null) (cast (FlxG.state)).handleError(e); else MainMenuState.handleError(e);
	}


	// public function getPath(?str:String = ""){
	// 	return Sys.getCwd() + str;
	// }
	public function loadFlxSprite(x:Float,y:Float,pngPath:String):FlxSprite{
		return new FlxSprite(x, y).loadGraphic(loadGraphic(pngPath));
	}
	public function loadGraphic(pngPath:String):FlxGraphic{
		if(!exists('${pngPath}')){
			handleError(' "${pngPath}" doesn\'t exist!');
			return FlxGraphic.fromRectangle(0,0,0); // Prevents the script from throwing a null error or something
		}
		if(spriteArray[pngPath] == null) cacheGraphic(pngPath);
		return spriteArray[pngPath];
	}
	public function loadBitmap(pngPath:String):BitmapData{
		if(!exists('${pngPath}')){
			handleError(' "${pngPath}" doesn\'t exist!');
			return new BitmapData(0,0,false,0xFF000000); // Prevents the script from throwing a null error or something
		}
		if(bitmapArray[pngPath] == null) cacheBitmap(pngPath);
		return SELoader.cacheOnGPU(bitmapArray[pngPath]);
	}

	public function loadSparrowFrames(pngPath:String):FlxAtlasFrames{
		// if(!exists('${pngPath}.png')){
		// 	handleError(' SparrowFrame PNG "${pngPath}.png" doesn\'t exist!');
		// 	return FlxAtlasFrames.fromSparrow(FlxGraphic.fromRectangle(1,1,0),""); // Prevents the script from throwing a null error or something
		// }
		final xmlPath = '${pngPath}.xml';
		if(!exists(xmlPath)){
			handleError(' SparrowFrame XML "${pngPath}.xml" doesn\'t exist!');
			return FlxAtlasFrames.fromSparrow(FlxGraphic.fromRectangle(1,1,0),""); // Prevents the script from throwing a null error or something
		}
		// else{
		// }

		return FlxAtlasFrames.fromSparrow(loadGraphic(pngPath + ".png"),loadXML(xmlPath));
	}
	public function loadSparrowSprite(x:Float,y:Float,pngPath:String,?anim:String = "",?loop:Bool = false,?fps:Int = 24):FlxSprite{
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
	public function loadXML(textPath:String):String{
		cacheXML(textPath);
		return xmlArray[textPath];
	}
	// public function saveText(textPath:String,text:String):Bool{
	// 	File.saveContent('${textPath}',text);
	// 	return true;
	// }



	public function loadSound(soundPath:String):Sound{
		cacheSound(soundPath);
		return soundArray[soundPath];
	}
	@:keep inline public function loadFlxSound(soundPath:String):FlxSound{
		return new FlxSound().loadEmbedded(loadSound(soundPath));
	}
	public function playSound(soundPath:String,?volume:Dynamic = null):FlxSound{
		var _vol = SESave.data.otherVol;
		if(volume != null){
			if(volume is String){
				switch(volume.toLowerCase()){
					case "inst": _vol = SESave.data.instVol;
					case "voices": _vol = SESave.data.voicesVol;
					case "master": _vol = SESave.data.masterVol;
					case "hit": _vol = SESave.data.hitVol;
					case "misses": _vol = SESave.data.missVol;
					default: _vol = SESave.data.otherVol;
				}
			}else if(volume is Int || volume is Float){
				_vol = volume;
			}
		}
		// if(volume == 0.662121) volume = SESave.data.otherVol;
		return FlxG.sound.play(loadSound(soundPath),_vol);
	}

	public function unloadSound(soundPath:String){
		if(soundArray[soundPath] == null) return;
		trace('Unloading $soundPath');
		soundArray[soundPath].close();
		soundArray[soundPath] = null;
	}
	public function unloadText(pngPath:String){
		textArray[pngPath] = null;
		trace('Unloading $pngPath');
	}
	public function unloadShader(pngPath:String){
		textArray[pngPath + ".vert"] = null;
		textArray[pngPath + ".frag"] = null;
	}
	public function unloadSprite(pngPath:String){
		if(spriteArray[pngPath] == null) return;
		trace('Unloading $pngPath');
		spriteArray[pngPath].destroy();
		spriteArray[pngPath] = null;
	}

	public function cacheXML(textPath:String){
		if(xmlArray[textPath] == null){
			if(!exists('${textPath}')){
				trace('${id} : CacheText: "${textPath}" doesn\'t exist!');
				return;
			}
			xmlArray[textPath] = SELoader.cleanXML(SELoader.getContent(textPath));
		}
	}

	public function cacheText(textPath:String){
		if(textArray[textPath] == null){
			if(!exists('${textPath}')){
				trace('${id} : CacheText: "${textPath}" doesn\'t exist!');
				return;
			}
			textArray[textPath] = SELoader.getContent(textPath);
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
		if(bitmapArray[pngPath] == null) bitmapArray[pngPath] = BitmapData.fromFile(getPath(pngPath));
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
	public function toString(){
		var sprites = 0;
			for(e in spriteArray) sprites++;
		var sounds = 0;
			for(e in soundArray) sounds++;
		var bitmaps = 0;
			for(e in bitmapArray) bitmaps++;
		var xmls = 0;
			for(e in xmlArray) xmls++;
		var texts = 0;
			for(e in textArray) texts++;
		return '$id Cache. Currently loaded:'
		+' Sprites: ${sprites}'
		+' Audio: ${sounds}'
		+' Bitmaps: ${bitmaps}'
		+' XMLS: ${xmls}'
		+' TEXT: ${texts}';
	}
	public function list(){
		return '$id Cache. Currently loaded:'
		+'\n Sprites: ${spriteArray}'
		+'\n Audio: ${soundArray}'
		+'\n Bitmaps: ${bitmapArray}'
		+'\n XMLS: ${xmlArray}'
		+'\n TEXT: ${textArray}';
	}
	@:keep inline public static function absolutePath(path:String):String{ return SELoader.absolutePath(getPath(path)); }
	@:keep inline public static function fullPath(path:String):String{ return SELoader.fullPath(getPath(path)); }
	@:keep inline public static function exists(path:String):Bool{ return SELoader.exists(getPath(path)); }
	@:keep inline public static function readDirectory(path:String):Array<String>{ return SELoader.readDirectory(getPath(path)); }
	@:keep inline public static function isDirectory(path:String):Bool{ return SELoader.isDirectory(getPath(path)); }
	@:keep inline public static function createDirectory(path:String){ return SELoader.createDirectory(getPath(path)); }
}