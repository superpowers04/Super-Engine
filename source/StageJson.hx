package;


typedef StageJSON = {
	var layers:Array<StageLayer>;
	var tags:Array<String>;
	var bf_pos:Array<Float>;
	var dad_pos:Array<Float>;
	var gf_pos:Array<Float>;
	var camzoom:Float;
	var no_gf:Bool;
}
typedef StageLayer = {
	var name:String;
	var pos:Array<Float>;
	var scroll_factor:Array<Float>;
	var animated:Bool;
	var antialiasing:Bool;
	var scale:Float;
	var song:String;
	var alpha:Float;
	var animation_name:String;
	var centered:Bool;
	var fps:Int;
	var flip_x:Bool;
}



