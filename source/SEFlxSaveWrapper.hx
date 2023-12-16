package;

import flixel.FlxG;
import tjson.Json;
import sys.io.File;
// import flixel.util.FlxSave;
using StringTools;

class SEFlxSaveWrapper{
	public static function save(){
		File.saveContent(SELoader.absolutePath('SESETTINGS.json'),Json.stringify(SESave.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function saveTo(path:String = "SESETTINGS-BACK.json"){
		File.saveContent(SELoader.absolutePath(path),Json.stringify(SESave.data).replace('"" :','" :').replace('"":','":'));
	}
	public static function load():Void{
		if(!SELoader.exists('SESETTINGS.json')) return;
		var json = CoolUtil.cleanJSON(SELoader.loadText('SESETTINGS.json')).replace('"" :','" :').replace('"":','":');
		var anon = Json.parse(json);
		if(anon is SESave){
			SESave.data = anon;
			return;
		} 

		for(field in Type.getInstanceFields(SESave)){
			if(field.startsWith('set_')){
				field = field.substring(4);
			}
			if(!Reflect.hasField(anon,field)){
				trace('Save field "$field" was not found in the save file');
				continue;
			}
			// try{
			Reflect.setProperty(SESave.data,field,Reflect.field(anon,field));
			// }catch(e){
			// 	trace('Invalid save field "$field" ignored');
			// }
		}
			
		
		
		// for(field in Reflect.fields(anon)){
		// 	if(!Reflect.hasField(SESave.data,field)){
		// 		trace('Invalid save field "$field" ignored');
		// 		continue;
		// 	}
		// 	// try{
		// 	Reflect.setProperty(SESave.data,field,Reflect.field(anon,field));
		// 	// }catch(e){
		// 	// 	trace('Invalid save field "$field" ignored');
		// 	// }
		// }
	};
}
