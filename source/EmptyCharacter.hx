package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.DynamicAccess;
import lime.utils.Assets;
import lime.graphics.Image;
import CharacterJson;

import flash.media.Sound;

import sys.io.File;
import flash.display.BitmapData;
import Xml;
// import lime.graphics.Image as LimeImage;

using StringTools;

class EmptyCharacter extends Character
{


	override public function new(x:Float, y:Float, ?character:String = "lonely", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
		animOffsets['all'] = [0, 0];
		character = "lonely";

		curCharacter = character;
		charType = char_type;
		this.isPlayer = isPlayer;
		this.visible = false;

		var tex:FlxAtlasFrames = null; // Dunno why this fixed crash with BF but it did
		tex = Paths.getSparrowAtlas('onlinemod/lonely');
		frames = tex;
	}


	override public function dance(?ignoreDebug:Bool = false)
	{
		return;
	}
	// Added for Animation debug
	override public function idleEnd(?ignoreDebug:Bool = false)
	{
		return;
	}
	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		return;
	}
	override public function cloneAnimation(name:String,anim:FlxAnimation):Void{
		return;
	}
	override public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom = false):Void
	{
		return;
	}
}
