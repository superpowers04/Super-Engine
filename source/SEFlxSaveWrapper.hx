package;

import flixel.FlxG;
import tjson.Json;
import sys.io.File;
// import flixel.util.FlxSave;
using StringTools;

class SEFlxSaveWrapper{
	public static function save(){
		var path = SELoader.absolutePath('SESETTINGS.json');
		File.saveContent(path,Json.stringify(FlxG.save.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function saveTo(path:String = "SESETTINGS-BACK.json"){
		var path = SELoader.absolutePath(path);
		File.saveContent(path,Json.stringify(FlxG.save.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function load(){
		if(!SELoader.exists('SESETTINGS.json')) return;
		var txt = SELoader.loadText('SESETTINGS.json');

		var anon = Json.parse(CoolUtil.cleanJSON(txt).replace('"" :','" :').replace('"":','":'));
		for(field in Reflect.fields(anon)){
			Reflect.setField(FlxG.save.data,field,Reflect.field(anon,field));
		}
	};
}
