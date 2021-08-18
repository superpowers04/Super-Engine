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
	public static var badImage:FlxGraphic;
	public static var badXml:String;
	public static var noteSplashAsset:SplashNoteAsset;
	public function new(?name_:String = 'default'):Void{
		try{
			name = name_;
			if (name == 'default'){
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
				noteSplashAsset = new SplashNoteAsset();
				image = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png'));
				xml = File.getContent("assets/shared/images/NOTE_assets.xml");
				return;
			}
		
			if (FileSystem.exists('${path}/${name}splash.png') && FileSystem.exists('${path}/${name}splash.xml')){
				noteSplashAsset = new SplashNoteAsset(name,'${path}');
			}else{noteSplashAsset = new SplashNoteAsset();}
			if (FileSystem.exists('${path}/${name}-bad.png') && FileSystem.exists('${path}/${name}-bad.xml')){
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}-bad.png'));
				badXml = File.getContent('${path}/${name}-bad.xml');
			}else{noteSplashAsset = new SplashNoteAsset();}
			if (!FileSystem.exists('${path}/${name}.png') || !FileSystem.exists('${path}/${name}.xml')) MainMenuState.handleError('${name} isn\'t a valid note asset!');
			image = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name}.png'));
			xml = File.getContent('${path}/${name}.xml');


			if (badImage == null) {
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
			}
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