package se.objects;
#if hxCodec

import sys.FileSystem;
import hxcodec.flixel.FlxVideoSprite;
import flixel.FlxG;

class SEFlixelVideoSprite extends FlxVideoSprite{
	public var autoPause:Bool = true;
	private var wasPlaying:Bool = false;

	override public function play(location:String, shouldLoop:Bool = false):Int {
		if (!FlxG.signals.focusGained.has(signalResume))
			FlxG.signals.focusGained.add(signalResume);
		if (!FlxG.signals.focusLost.has(signalPause))
			FlxG.signals.focusLost.add(signalPause);

		if (bitmap != null)
		{
			if (FileSystem.exists(Sys.getCwd() + location))
				return bitmap.play(Sys.getCwd() + location, shouldLoop);
			else
				return bitmap.play(location, shouldLoop);
		}
		else
			return -1;
	}

	private function signalResume():Void {
		if(bitmap == null || !autoPause || !FlxG.autoPause) return;
		if(wasPlaying){
			wasPlaying = false;
			resume();
		}
	}
	private function signalPause():Void {
		if(bitmap == null || !autoPause || !FlxG.autoPause) return;
		if(bitmap.isPlaying){
			wasPlaying = true;
			pause();
		}
	}
}


#end