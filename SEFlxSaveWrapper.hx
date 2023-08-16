package;

import flixel.FlxG;
import tjson.Json;
import sys.io.File;
// import flixel.util.FlxSave;

class SEFlxSaveWrapper{
	public static function save(){
		var path = SELoader.absolutePath('SESETTINGS.json');
		File.saveContent(path,Json.stringify(FlxG.save.data));

	}
	public static function load(){
		try{

			if(!SELoader.exists('SESETTINGS.json')) return;
			var txt = SELoader.loadText('SESETTINGS.json');

			var anon = Json.parse(CoolUtil.cleanJSON(txt));
			for(field in Reflect.fields(anon)){
				Reflect.setField(FlxG.save.data,field,Reflect.field(anon,field));
			}
		}catch(e){
			SELoader.copy('SESETTINGS.json','SESETTINGS-BACKUP.json');
			MainMenuState.errorMessage += 'Something went wrong when trying to load your settings file. ${e.message}\nYour settings have been backed up and reset to prevent further issues';
		}
	};
}
