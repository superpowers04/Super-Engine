package;

typedef CharacterJson =
{
	var flip_x:Bool;
	var flip:Dynamic; // Controls if the character should be flipped when on the player's side
	var offset_flip:Dynamic; // Flips the offsets on the left, 0/not specififed = off completely, 1 = use player2, 2 = flip left, 3 = flip right  
	var asset_files:Array<CharacterAssetFiles>;
	var clone:String;
	var like:String; // Clone but without stealing the offsets
	var voices:String;
	var animations:Array<CharJsonAnimation>;
	var animations_offsets:Array<CharJsonAnimOffsets>;
	var sing_duration:Float;
	var scale:Float;
	var no_antialiasing:Bool;
	// var dance_idle:Bool;
	var common_stage_offset:Array<Float>;
	var cam_pos:Array<Float>;
	var char_pos:Array<Float>;
	var cam_pos1:Array<Float>;
	var char_pos1:Array<Float>;
	var cam_pos2:Array<Float>;
	var char_pos2:Array<Float>;
	var cam_pos3:Array<Float>;
	var char_pos3:Array<Float>;
	var custom_misses:Int;
	var ?flip_notes:Bool; // Tells the game if it should flip left and right notes on the right
	var ?editableSprite:Bool; // If false, marks the sprite to not allow it's frames/bitmaps to be editable for performance after done creating
	var color:Dynamic;
	var sprites:Array<String>;

	var embedded:Bool; // For embedded JSON chars, will not effect custom chars. Tells the game whether to use Lime assets or load them like a custom character
	var path:String; // For embedded JSON chars, will not effect custom chars. Tells the game the asset to use or the path to load from
	var genBy:String; // This should not be provided manually
	var ?boneChar:BoneChar;
	var ?customProperties:Array<CCProp>; // Allows the json file to edit any value about the character
}
typedef CCProp = {
	var path:String;
	var value:Dynamic;
}
typedef IfStatement = {
	var ?func:Dynamic->Void;
	var ?isFunc:Bool;
	var	variable:String;
	var	type:String;
	var	value:Dynamic;
	var check:Int; // 0 = beat, 1 = step
} 
typedef CharJsonAnimation ={
	var ?ifstate:Null<IfStatement>;
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var ?flipx:Null<Bool>;
	var indices:Array<Int>;
	var ?loopStart:Null<Int>; // Tells the game where to restart the animation if looped
	var ?playAfter:Null<String>; // Tells the game to swap animations, useful for a start animation and then a loop animation
	var ?stage:Null<String>; // Set on specific stage
	var ?song:Null<String>; // Set on specific songname
	var ?char_side:Null<Int>; // Set song specific side, 0 for BF, 1 for Dad, 2 for GF, 3 for disabled
	var ?oneshot:Null<Bool>; // Should animation overlap everything?
	var ?priority:Null<Int>; // Animation priority, 0 is idle, 10 is sing, 5 is hey, and the rest is up to you. The engine will handle the rest
}

typedef CharacterAssetFiles ={
	var xml:String;
	var png:String;
	var stage:String; // Set on specific stage
	var song:String; // Set on specific songname
	var char_side:Dynamic; // Set song specific side, 0 for BF, 1 for Dad, 2 for GF, 3 for disabled
	var tags:Array<String>;
	var animations:Array<CharJsonAnimation>;
	var animations_offsets:Array<CharJsonAnimOffsets>;
}
typedef CharJsonAnimOffsets ={
	var anim:String;
	var player1:Array<Float>;
	var player2:Array<Float>;
	var player3:Array<Float>;
}
typedef BoneChar = {
	var anims:Array<BCAnim>;

}

typedef BCAnim = {
	var keyframes:Array<BCAnimKeyFrame>;
	var name:String;
	var length:Float;
	var looped:Bool;
	var priority:Int;
	var blend:Float;
}
typedef BCAnimKeyFrame = {
	var time:Float; // Time in seconds
	var length:Float; // Time in seconds
	var bone:String;
	var type:Int; // 1 = position, 2 = angle, 3 = frame
	var position:Array<Float>;
	var angle:Float;
	var frame:Int;
	var tweenType:String; // Defaults to linear, allows using a Flx
}