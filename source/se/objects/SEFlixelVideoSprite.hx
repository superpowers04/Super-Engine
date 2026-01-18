package se.objects;
#if hxCodec

import hxcodec.flixel.FlxVideoSprite;
import flixel.FlxG;


class SEFlixelVideoSprite extends FlxVideoSprite{
	public var checkAutoPause:Bool = false;
	// Methods
	override public function play(location:String, shouldLoop:Bool = false):Int
	{
		if(checkAutoPause) return super.play(location,shouldLoop);
		var autoPause = FlxG.autoPause;
		FlxG.autoPause = false;
		
		var ret:Int = super.play(location,shouldLoop);
		FlxG.autoPause = autoPause;
		
		return ret;
	}
}


#end