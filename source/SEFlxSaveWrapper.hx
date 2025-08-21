package;

import flixel.FlxG;

import sys.io.File;
import tjson.Json;
using StringTools;

class SEFlxSaveWrapper{
	public static function save(){

		SELoader.triggerSave('SESETTINGS.json',Json.stringify(SESave.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function saveTo(path:String = "SESETTINGS-BACK.json"){
		SELoader.saveContent(path,Json.stringify(SESave.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function load():Void{
		if(!SELoader.exists('SESETTINGS.json')) return;
		try{

			var json = SELoader.loadText('SESETTINGS.json').replace('"_hxcls": "se.SESave",','').replace('"" :','" :').replace('"":','":');

			var save = Json.parse(json);
			var newSave = SESave.data = new SESave();
			for(field in Reflect.fields(save)){
				try{
					if(Reflect.field(newSave,field) == null) throw('$field is FAKE and only present on the JSON but not the Save');
					var stuff:Dynamic = Reflect.field(save,field);
					if(stuff == null) throw('$field isn\'t on the JSON even though it\'s part of the json??');
					Reflect.setProperty(newSave,field,stuff);
				}catch(e){
					trace('Unable to load field "$field": $e');
				}
			}
		}catch(e){
			throw('Error while parsing SESettings.json:\n${e.message}');
		}
	};
}
