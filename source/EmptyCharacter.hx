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

import openfl.media.Sound;

import sys.io.File;
import flash.display.BitmapData;
import Xml;
// import lime.graphics.Image as LimeImage;

using StringTools;

class EmptyCharacter extends Character
{


	override public function new(x:Float, y:Float, ?character:String = "lonely", ?isPlayer:Bool = false,?char_type:Int = 0,?preview:Bool = false) // CharTypes: 0=BF 1=Dad 2=GF
	{
		this.lonely = true;
		animOffsets = new Map<String, Array<Float>>();
		animOffsets['all'] = [0.0, 0.0];

		curCharacter = character = "lonely";
		charType = char_type;
		this.isPlayer = isPlayer;
		this.visible = false;
		super(x, y,"lonely",false,0,false);
		curCharacter = character = "lonely";
		this.lonely = true;
		this.visible = false;

		var tex:FlxAtlasFrames = null; // Dunno why this fixed crash with BF but it did
		tex = FlxAtlasFrames.fromSparrow(FlxGraphic.fromRectangle(2,2,0x00000000,false,'lonelyspr'), '<?xml version="1.0" encoding="utf-8"?>
<TextureAtlas imagePath="lonely.png">
	<!-- Created with Adobe Animate version 20.0.0.17400 -->
	<!-- http://www.adobe.com/products/animate.html -->
	<SubTexture name="Idle0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="DanceRight0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="DanceLeft0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="SingUP0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="SingDOWN0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="SingLEFT0000" x="0" y="0" width="1" height="1"/>
	<SubTexture name="SingRIGHT0000" x="0" y="0" width="1" height="1"/>
</TextureAtlas>');
		frames = tex;
		animation.addByPrefix('idle', 'Idle', 24, false);
		animation.addByPrefix('Idle', 'Idle', 24, false);
		animation.play("idle",true,false,0);
	}

	override public function update(elapsed:Float)
	{
		return;
	}

	override public function dance(Forced:Bool = false,beatDouble:Bool = false,useDanced:Bool = true)
	{
		animation.play("idle",true,false,0);
		return;
	}
	// Added for Animation debug
	override public function idleEnd(?ignoreDebug:Bool = false)
	{
		return;
	}
	override public function playAnim(AnimName:String = "idle", Force:Bool = false, Reversed:Bool = false, Frame:Float = 0,?offsetX:Float = 0,?offsetY:Float = 0):Bool
	{
		animation.play("idle",true,false,0);
		return false;
	}
	override public function cloneAnimation(name:String,anim:FlxAnimation):Void{
		return;
	}
	override public function addOffset(name:String, x:Float = 0, y:Float = 0,?custom = false,?replace:Bool = false):Void
	{
		return;
	}
	override public function draw(){
		return;
	}
}
