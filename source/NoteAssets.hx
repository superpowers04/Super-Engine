package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import tjson.Json;


// typedef NoteSplashType = {
// 	var type:String;
// 	var blue:String;
// 	var purple:String;
// 	var red:String;
// 	var green:String;
// 	var blue2:String;
// 	var purple2:String;
// 	var red2:String;
// 	var green2:String;
// }
	// static var baseSplash:NoteSplashType = {
	// 	type:"se",
	// 	blue:"note splash blue 1",
	// 	green:"note splash green 1",
	// 	purple:"note splash purple 1",
	// 	red:"note splash red 1",
	// 	blue2:"note splash blue 2",
	// 	green2:"note splash green 2",
	// 	purple2:"note splash purple 2",
	// 	red2:"note splash red 2"
	// };

typedef NoteAssetJSON = {
	var notes:Array<NoteAssetConfig>;
}
typedef NoteAssetConfig = {
	var flipx:Bool;
	var flipy:Bool;
	var antialiasing:Bool;
	var scale:Array<Float>;


	var staticanimname:String;
	var confirmanimname:String;
	var pressedanimname:String;

	var animname:String;
	var holdanimname:String;
	var endanimname:String;
	var ?offset:Array<Float>;

}



// Todo, add automatic animation name detection

class NoteAssets{
	public static var name:String;
	static var path:String = "mods/noteassets"; // The slash not being here is just for ease of reading
	public static var image:FlxGraphic;
	public static var originalImage:FlxGraphic;
	public static var xml:String;
	public static var splashImage:FlxGraphic; // Is this getting cleared or something?
	public static var splashXml:String;
	public static var badImage:FlxGraphic;
	public static var badXml:String;
	public static var splashType:String = "se";
	public static var modified:Bool = false;
	public static var sprite:FlxSprite;
	public static var frames(get,set):FlxFramesCollection;
	public static var noteJSON:NoteAssetJSON;


	public static var defNoteJSON(default,never):NoteAssetJSON = {
		notes:[
			{ // Left
				flipx:false,
				flipy:false,
				antialiasing:true,
				scale:[1,1],


				staticanimname:"arrowLEFT",
				confirmanimname:"left confirm",
				pressedanimname:"left press",
				animname:"purple0",
				holdanimname:"purple hold piece",
				endanimname:"purple end hold",
			},
			{ // Down
				flipx:true, // Fixes the misaligned sustain
				flipy:false,
				antialiasing:true,
				scale:[1,1],

				staticanimname:"arrowDOWN",
				confirmanimname:"down confirm",
				pressedanimname:"down press",
				animname:"blue0",
				holdanimname:"blue hold piece",
				endanimname:"blue hold end",
			},
			{ // Up
				flipx:false,
				flipy:false,
				antialiasing:true,
				scale:[1,1],

				staticanimname:"arrowUP",
				confirmanimname:"up confirm",
				pressedanimname:"up press",
				animname:"green0",
				holdanimname:"green hold piece",
				endanimname:"green hold end",
			},
			{ // Right
				flipx:false,
				flipy:false,
				antialiasing:true,
				scale:[1,1],

				staticanimname:"arrowRIGHT",
				confirmanimname:"right confirm",
				pressedanimname:"right press",
				animname:"red0",
				holdanimname:"red hold piece",
				endanimname:"red hold end",
			}
		]
	};
	

	public static function get_frames():FlxFramesCollection{
		return sprite.frames;
	}
	public static function set_frames(vari:FlxFramesCollection):FlxFramesCollection{
		return sprite.frames = vari;
	}

	static var splTypes:Array<String> = [
		"se",
		"psych",
		"vanilla",
		"custom"
	];
	function perm(){
		for (i in [badImage,image,splashImage]){
			i.destroyOnNoUse = false;
			i.persist = true;
		}
	}
	public function new(?name_:String = 'default',?forced:Bool = false):Void{
		if(sprite == null) sprite = new FlxSprite();
		doThing(name_);
		frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
		perm(); // Prevents Flixel from being flixel and unloading things
	}
	static function doThing(name_:String,?forced:Bool = false){
		try{
			if(name == name_ && !forced){return;}
			splashType = "se";
			modified = false;
			if(image != null){
				for (i in [badImage,image,splashImage]){
					i.destroyOnNoUse = false;
					i.persist = false;
					i.destroy(); // These notes aren't needed anymore, dump em
				}
			}
			noteJSON = defNoteJSON;
			name = name_;
			if (name == 'default'){
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
				// genSplashes();
				image = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png'));
				xml = File.getContent("assets/shared/images/NOTE_assets.xml");
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/noteSplashes.png'));
				splashXml = File.getContent("assets/shared/images/noteSplashes.xml");
				return;
			} // Default arrows
		

			if (FileSystem.exists('${path}/${name}-splash.png') && FileSystem.exists('${path}/${name}-splash.xml')){ // Splashes
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}-splash.png'));
				splashXml = File.getContent('${path}/${name}-splash.xml');
				if(FileSystem.exists('${path}/${name}-splashType.json')){
					var _Type = File.getContent('${path}/${name}-splash.xml').toLowerCase();
					if(splTypes.contains(_Type)){
						splashType = _Type;
					}
				}
			}else{
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/noteSplashes.png'));
				splashXml = File.getContent("assets/shared/images/noteSplashes.xml");
			}
			if(FileSystem.exists('${path}/${name}.json')){
				try{
					noteJSON = cast Json.parse('${path}/${name}.json');
				}catch(e){
					noteJSON = defNoteJSON;
				}
			}

			if (FileSystem.exists('${path}/${name}-bad.png') && FileSystem.exists('${path}/${name}-bad.xml')){ // Hurt notes
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}-bad.png'));
				badXml = File.getContent('${path}/${name}-bad.xml');
			}else{
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
			}

				
			if (!FileSystem.exists('${path}/${name}.png') || !FileSystem.exists('${path}/${name}.xml')) MainMenuState.handleError('${name} isn\'t a valid note asset!');
			image = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}.png'));
			xml = File.getContent('${path}/${name}.xml');


			if (badImage == null) {
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
			}
			return;

		}catch(e){MainMenuState.handleError(e,'Error occurred while loading notes ${e.message}');}
	}

// class SplashNoteAsset{
// 	// public var name:String;
// 	var path:String = "mods/noteassets";
// 	// public var image:FlxGraphic;
// 	// public var xml:String;
	// public function genSplashes(?name_:String = "noteSplashes",?path_:String = "assets/shared/images/"):Void{
	// 	try{


	// 	NoteAssets.splashImage = '${path_}/${name_}.png';
	// 	NoteAssets.splashXml = File.getContent('${path_}/${name_}.xml');
	// 	return;
	// 	}catch(e) MainMenuState.handleError('Error occurred while loading splashes ${e.message}');
		
	// }
}