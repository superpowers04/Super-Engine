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
	var bpm:Float;
	var common_stage_offset:Array<Int>;
}
typedef CharJsonAnimation ={
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
}
typedef CharJsonAnimOffsets ={
	var anim:String;
	var player1:Array<Int>;
	var player2:Array<Int>;
}