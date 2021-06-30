package;

typedef CharacterJson =
{
	var spirit_trail:Bool;
	var flip_x:Bool;
	var clone:String;
	var animations:Array<CharJsonAnimation>;
	var animations_offsets:Array<CharJsonAnimOffsets>;
	var sing_duration:Int;
	var scale:Float;
	var no_antialiasing:Bool;
	var dance_idle:Bool;
	var alt_anims:Bool;
	var bpm:Float;
	var common_stage_offset:Array<Int>;
	var cam_pos:Array<Int>;
	var char_pos:Array<Int>;
	var custom_misses:Int;

}
typedef IfStatement = {
	var	variable:String;
	var	type:String;
	var	value:Dynamic;
	var check:Int; // 0 = beat, 1 = step
} 
typedef CharJsonAnimation ={
	var ifstate:IfStatement;
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var stage:String; // Set on specific stage
	var song:String; // Set on specific songname
	var char_side:Dynamic; // Set song specific side, 0 for BF, 1 for Dad, 2 for GF, 3 for disabled
	var oneshot:Bool; // Should animation overlap everything?
}
typedef CharJsonAnimOffsets ={
	var anim:String;
	var player1:Array<Int>;
	var player2:Array<Int>;
}