package;

// import flixel.FlxG;
// import flixel.graphics.FlxGraphic;
// import flixel.FlxSprite;
// import flixel.animation.FlxBaseAnimation;
// import flixel.animation.FlxAnimation;
// import flixel.graphics.frames.FlxAtlasFrames;
// import haxe.Json;
// import haxe.format.JsonParser;
// import haxe.DynamicAccess;
// import lime.utils.Assets;
// import lime.graphics.Image;
// import CharacterJson;
// import flixel.group.FlxGroup.FlxTypedGroup;

// import flash.media.Sound;

// import sys.io.File;
// import flash.display.BitmapData;
// import Xml;
// // import lime.graphics.Image as LimeImage;

// using StringTools;


// class BoneCharacter extends Character
// {
// 	public var childSprites:FlxTypedGroup = new FlxTypedGroup();
// 	public var animationPosition:Float = 0;
// 	public var Animations:Map<String,BCAnim>

// 	override public function new(x:Float, y:Float, ?character:String = "lonely", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF
// 	{
// 		if(!amPreview){
// 			curCharacter = TitleState.retChar(curCharacter); // Make sure you're grabbing the right character
// 		}
// 		trace('Loading a custom character "$curCharacter"! ');				
// 		if(charLoc == "mods/characters"){
// 			if(TitleState.weekChars[curCharacter] != null && TitleState.weekChars[curCharacter].contains(onlinemod.OfflinePlayState.nameSpace) && TitleState.characterPaths[onlinemod.OfflinePlayState.nameSpace + "|" + curCharacter] != null){
// 				charLoc = TitleState.characterPaths[onlinemod.OfflinePlayState.nameSpace + "|" + curCharacter];
// 				trace('$curCharacter is loading from $charLoc');
// 			}else if(TitleState.characterPaths[curCharacter] != null){
// 				charLoc = TitleState.characterPaths[curCharacter];
// 				trace('$curCharacter is loading from $charLoc');
// 			}
// 		}
// 		this.lonely = true;
// 		super(x, y);
// 		animOffsets = new Map<String, Array<Float>>();
// 		animOffsets['all'] = [0.0, 0.0];
// 		// character = "lonely";

// 		// curCharacter = character;
// 		charType = char_type;
// 		this.isPlayer = isPlayer;
// 		this.visible = false;

// 		var tex:FlxAtlasFrames = null; // Dunno why this fixed crash with BF but it did
// 		tex = Paths.getSparrowAtlas('onlinemod/lonely');
// 		frames = tex;
// 		animation.addByPrefix('idle', 'Idle', 24, false);
// 		animation.addByPrefix('Idle', 'Idle', 24, false);
// 		animation.play("idle",true,false,0);
// 	}

// 	override public function update(elapsed:Float)
// 	{

// 		return;
// 	}

// 	override public function dance(?ignoreDebug:Bool = false)
// 	{
// 		animation.play("idle",true,false,0);
// 		return;
// 	}
// 	// Added for Animation debug
// 	override public function idleEnd(?ignoreDebug:Bool = false)
// 	{
// 		return;
// 	}
// 	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0,?offsetX:Float = 0,?offsetY:Float = 0):Void
// 	{
// 		if(animation.curAnim.name == AnimName){return;}
// 		animation.play(AnimName,true,false,0);
// 		return;
// 	}

// 	override public function cloneAnimation(name:String,anim:FlxAnimation):Void{
// 		return;
// 	}
// 	public function createNewAnimation(name:String,animation:BCAnimJSON){
// 		animation.addByPrefix(name, 'Idle', 0, true);

// 	}
// 	override public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom = false,?replace:Bool = false):Void
// 	{
// 		return;
// 	}
// }

// class BCAnim {
// 	var keyframes:Map<String,Array<BCAnimKeyFrame>> = [];
// 	var keyframes:Map<String,Array<BCAnimKeyFrame>>;
// }