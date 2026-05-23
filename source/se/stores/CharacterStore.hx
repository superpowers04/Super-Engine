package se.stores; 

import se.formats.CharInfo;
import SELoader;

using StringTools;
class CharacterStore{

	public static var characters:Array<CharInfo> = [];
	public static var defaultChar(get,null):CharInfo = null;
	public static function get_defaultChar():CharInfo{
		return defaultChar;
	}
	// This is a seperate array because the character doesn't need metadata beyond it being invalid
	public static var invalidCharacters:Array<CharInfo> = []; 



	public static function findInvalidChar(char:String):CharInfo{
		char = char.replace('INVALID|',"");
		var ID=Std.parseInt(char);
		if(ID != null && !Math.isNaN(ID)){
			if(invalidCharacters[ID] != null){
				return invalidCharacters[ID];
			}else{
				return null;
			}
		}
		char = char.replace(' ',"-").replace('_',"-").toLowerCase();
		for (i in invalidCharacters){
			if(i.id == char) return i;
		}
		
		return getCharacter(char);
	}

	public static function getCharacterUnknownNS(id:String):Null<CharInfo>{
		return id.contains('|') ? getCharacterSplitNamespace(id) : getCharacter(id);
	}
	public static function getCharacterSplitNamespace(id:String, ?nameSpace:String):Null<CharInfo>{
		if (nameSpace != null && nameSpace != "") return getCharacter(id,nameSpace);
		var split = id.indexOf('|');
		return getCharacter(id.substring(split+1),id.substring(0,split));
	}
	public static function getCharacterByIDSplitNamespace(id:String, ?nameSpace:String):Null<CharInfo>{
		if (nameSpace != null && nameSpace != "") return getCharacter(id,nameSpace);
		var split = id.indexOf('|');
		return getCharacterByID(id.substring(split+1),id.substring(0,split));
	}
	public static function getCharacterByIndex(charID:Int = -1):Null<CharInfo>{
		if(charID < 0 || Math.isNaN(charID)) return null;
		var char = characters[charID];
		if(char != null){
			trace('Found char with ID of $charID');
			return char;
		}
		trace('Invalid ID $charID, out of range 0-${characters.length}');
		return null;
		

	}
	public static function getCharacterByID(id:String, ?nameSpace:String=""):Null<CharInfo>{
		trace('Getting Character by id $nameSpace/$id');
		if(id == "" || id == "automatic"){
			trace('Tried to get a blank character!');
			return null;
		}
		id=id.replace(' ',"-").replace('_',"-").toLowerCase();
		nameSpace=nameSpace.toLowerCase();
		if(nameSpace == ""){
			for(char in characters){
				if(char.id == id) return char;
			}
		}else{
			for(char in characters){
				if(char.id == id && char.nameSpace == nameSpace) return char;
			}
		}
		return null;
	}
	public static function getCharacter(id:String, ?nameSpace:String=""):Null<CharInfo>{
		trace('Searching for $nameSpace/$id');
		{var indexChar:CharInfo = getCharacterByIndex(Std.parseInt(id));
			if (indexChar != null) return indexChar;
		}
		var oldId = id.replace(' ',"-").replace('_',"-");
		id=oldId.toLowerCase();
		nameSpace=nameSpace.toLowerCase();
		if(id == "" || id == "automatic"){
			trace('Tried to get a blank character!');
			return null;
		}
		for(char in characters){
			if(char.id == id && char.nameSpace == nameSpace) return char;
		}
		var possibleCharacter:CharInfo = null;
		var possiblility:Int = 0;
		while (id != ""){
			for(char in characters){
				var current_possibility:Int = 0;
				var char_id = char.id.toLowerCase();
				if(char_id == id) current_possibility = 3;
				else if(char_id.startsWith(id)) current_possibility = 2;
				else if(char_id.contains(id)) current_possibility = 1;

				if(current_possibility == 0) continue;

				if(char.nameSpace == nameSpace) current_possibility++;
				if(current_possibility == 4 ) return char;

				if (current_possibility > possiblility){
					possiblility=current_possibility;
					possibleCharacter=char;
					continue;
				}
			}

			id = id.substring(0,id.lastIndexOf('-'));
		}
		if (possibleCharacter == null){ // It's possible the character name from the chart uses something like bfGreen, try grabbing the character that way
			var id = (~/([^A-Z])([A-Z])/g).replace(oldId,"$1-$2").toLowerCase();
			trace('Searching for $id');
			while (id != ""){
				for(char in characters){
					var current_possibility:Int = 0;
					var char_id = char.id.toLowerCase();
					if(char_id == id) current_possibility = 3;
					else if(char_id.startsWith(id)) current_possibility = 2;
					else if(char_id.contains(id)) current_possibility = 1;

					if(current_possibility == 0) continue;

					if(char.nameSpace == nameSpace) current_possibility++;
					if(current_possibility == 4 ) return char;

					if (current_possibility > possiblility){
						possiblility=current_possibility;
						possibleCharacter=char;
						continue;
					}
				}

				id = id.substring(0,id.lastIndexOf('-'));
			}

		}
		return possibleCharacter;
	}
	public static function registerCharacters(){

		LoadingScreen.loadingText = 'Updating character list';
		characters = [
			{id:"bf",folderName:"bf",path:"assets/",nameSpace:"INTERNAL",internal:true,internalAtlas:"characters/BOYFRIEND",iconLocation:"assets/images/healthicons/bf.png",internalJSON:Character.BFJSON,description:"The funny rap guy"},
			{id:"gf",folderName:"gf",path:"assets/",nameSpace:"INTERNAL",internal:true,internalAtlas:"characters/GF_assets",iconLocation:"assets/images/healthicons/gf.png",internalJSON:Character.GFJSON,description:"The funny boombox girl"},
			{id:"lonely",folderName:"lonely",path:"assets/",nameSpace:"INTERNAL",internal:true,internalAtlas:"onlinemod/lonely",internalJSON:Character.BFJSON,description:"Not much is known about them besides their ability to mimic any voice, they're invisible and very shy"},
		];
		defaultChar = characters[0];
		invalidCharacters = [];
		#if sys
		
		final customCharacters:Array<String> = [];

		// TODO: MOVE TO SELOADER
		if (SELoader.exists("mods/characters/")){
			var path = new SEDirectory("mods/characters/");
			for (directory in path.readDirectory()) {
				if (!path.isDirectory(directory)){continue;}
				var charPath=path.newDirectory(directory);
				if (charPath.exists("config.json")) {
					var desc = null;
					if (charPath.exists("/description.txt"))
						desc = SELoader.getContent('${charPath}/description.txt');

					characters.push({
						id:directory.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:directory,
						nameSpace:"SECharactersFolder",
						description:desc
					});
				}else if (charPath.exists("script.hscript")) {
					var desc = charPath.exists("description.txt") ? charPath.getContent('${charPath}/description.txt') : null;

					characters.push({
						id:directory.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:directory,
						description:desc,
						nameSpace:"SECharactersFolder",
						type:1
					});
				}else if (charPath.exists("character.png") && (charPath.exists("character.xml") || charPath.exists("config.json"))){
					// invalidCharacters.push([directory,'mods/characters']);
					invalidCharacters.push({
						id:directory.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:directory,
						nameSpace:"SECharactersFolder",
						path:'mods/characters'
					});
				}
			}
		}

		
		// final ADDPE=SESave.data.PECharSeperate;
		final LOADPE=SESave.data.PECharLoading;
		for (ID => dataDir in ['mods/weeks/','mods/packs/']) {
			final dir = new SEDirectory(dataDir);
			if (dir.exists()) {
				for(pack in dir.readDirectory()){
					SELoader.registerCharactersInFolder(ID,dir.appendPath(pack),pack,LOADPE);
				}
			}
		}
		// if(easterEgg == 0x1){
		// 	characters[0] = defaultChar = findChar('bf-girlfriendmode');
		// 	trace('${characters[0]} lesbian mode hopefully?');
		// }
		trace('Found ${characters.length} characters');

		#end
	}

}
