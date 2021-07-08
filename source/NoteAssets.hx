package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;


class NoteAssets{
	public static var name:String;
	var path:String = "mods/noteassets"; // The slash not being here is just for ease of reading
	public static var image:FlxGraphic;
	public static var xml:String;
	public static var noteSplashAsset:SplashNoteAsset;
	public function new(?name_:String = 'default'):Void{
		try{
			name = name_;
			if (name == 'default'){
				noteSplashAsset = new SplashNoteAsset();
				image = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png'));
				xml = File.getContent("assets/shared/images/NOTE_assets.xml");
				return;
			}
		
			if (FileSystem.exists('${path}/${name}splash.png') && FileSystem.exists('${path}/${name}splash.xml')){
				noteSplashAsset = new SplashNoteAsset(name,'${path}');
			}else{noteSplashAsset = new SplashNoteAsset();}
			if (!FileSystem.exists('${path}/${name}.png') || !FileSystem.exists('${path}/${name}.xml')) MainMenuState.handleError('${name} isn\'t a valid note asset!');
			image = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}.png'));
			xml = File.getContent('${path}/${name}.xml');
			return;

		}catch(e){MainMenuState.handleError('Error occurred while loading notes ${e.message}');}
	}
}
class SplashNoteAsset{
	public static var name:String;
	var path:String = "mods/noteassets";
	public static var image:FlxGraphic;
	public static var xml:String;
	public function new(?name_:String = "noteSplashes",?path_:String = "assets/shared/images/"):Void{
		try{

		name = name_;
		path = path_;
		image = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}.png'));
		xml = File.getContent('${path}/${name}.xml');
		return;
		}catch(e) MainMenuState.handleError('Error occurred while loading splashes ${e.message}');
		
	}
}