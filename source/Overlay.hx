package;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.system.System;
import openfl.text.TextFormat;

// Recreation of openfl.display.fps, with memory being listed
class Overlay extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	public static var debugVar:String = "";

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;
		width = 1280;
		height = 720;
		// alpha = 0;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			__enterFrame(e);
		});
		#end
	}
	var memPeak:Float = 0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += flixel.FlxG.elapsed;
		times.push(currentTime);

		while (times[0] < currentTime - 1)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) * 0.5) ;
		var mem:Float = Math.round((System.totalMemory / 1024) / 1000);
		if (mem > memPeak)
			memPeak = mem;

		// if (currentCount != cacheCount /*&& visible*/)
		// {
			// text = "FPS: " + currentFPS;
			text = "" + currentFPS + " FPS/" + deltaTime + " MS\nMemory/Peak: " + mem + "MB/" + memPeak + "MB" +  debugVar;
		// }

		cacheCount = currentCount;
	}
}