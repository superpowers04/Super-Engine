package se.formats;


@:structInit @:publicFields class CharInfo{
	public var id:String = "";
	public var path(get,default):String = null;
	public function get_path(){
		return ((path == "" || path == null) ? "mods/characters/" : path);
	}
	public var folderName:String = "";
	public var description(get,default):String = null;
	public function get_description(){
		return description ??(
		 psychChar ? "Psych Engine character\nIf edited and saved, a copy of the character's Psych Engine json file will be created beside it with a -SE suffix and that will be loaded by Super Engine from now on.\nThe Psych Engine version of the character should still work in Psych engine"
		: null);
	}
	public var nameSpace:String = null;
	public var nameSpaceType:Int = 0; // 0: mods/characters, 1: mods/weeks, 2: mods/packs 
	public var internal:Bool = false;
	public var psychChar:Bool = false;
	public var internalAtlas:String = "";
	public var internalJSON:String = "";
	public var imageLocation(get,default):String = null;
	public function get_imageLocation(){
		if(imageLocation == "" || imageLocation == null) return path+"character";
		return imageLocation;
	}
	public var jsonLocation(get,default):String = null;
	public function get_jsonLocation(){
		if(jsonLocation == "" || jsonLocation == null) return path+"config.json";
		return jsonLocation;
	}
	public var iconLocation(get,default):String = null;
	public function get_iconLocation(){
		if(iconLocation == "" || iconLocation == null) return path+folderName+"/healthicon.png";
		return iconLocation;
	}
	public var type:Int = 0x0; // 0: PNG/XML based, 1: Script based
	public var hidden = false;

	public function toString(){
		return 'Character "$nameSpace/$id"';
		// return 'Character $nameSpace/$id, Raw folder name:$folderName, path:$path';
	}
	public function getNamespacedName(){
		return (nameSpace == null ? id : '$nameSpace|$id');
	}
}