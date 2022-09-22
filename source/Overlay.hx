package;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.system.System;
import openfl.text.TextFormat;
import flixel.FlxG;

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


		scaleX = lime.app.Application.current.window.width / 1280;
		scaleY = lime.app.Application.current.window.height / 720;
		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) * 0.5) ;

			var mem:Float = Math.round((
			#if cpp
			cpp.NativeGc.memInfo(0)
			#else
			System.totalMemory
			#end
			/ 1024) / 1000);
			if (mem > memPeak)
				memPeak = mem;
			text = "" + currentFPS + " FPS/" + deltaTime + " MS\nMemory/Peak: " + mem + "MB/" + memPeak + "MB" +  debugVar;
		// }

		cacheCount = currentCount;
	}
}
// Clone of Overlay but to show a console sort of thing instead
class Console extends TextField
{
	public static var instance:Console = new Console();
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	public static var debugVar:String = "";

	public function new(x:Float = 20, y:Float = 20, color:Int = 0xFFFFFFFF)
	{
		super();
		instance = this;
		haxe.Log.trace = function(v, ?infos) {
			var str = haxe.Log.formatOutput(v,infos);
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(str);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(str));
			#elseif sys
			Sys.println(str);
			#end
			if(Console.instance != null)Console.instance.log(str);
		}


		this.x = x;
		this.y = y;
		width = 1240;
		height = 680;
		background = true;
		backgroundColor = 0xaa000000;
		// alpha = 0;

		selectable = false;
		mouseEnabled = mouseWheelEnabled = true;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "Start of log";
		alpha = 0;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			__enterFrame(e);
		});
		#end
	}
	var lineCount:Int = 0;
	var lines:Array<String> = [];
	public function log(str:String){
		if(FlxG.save.data != null && !FlxG.save.data.animDebug){return;}
		// text += "\n-" + lineCount + ": " + str;
		lineCount++;
		lines.push('$lineCount ~ $str');
		while(lines.length > 100){
			lines.shift();
		}
		requestUpdate = true;

	}
	var requestUpdate = false;
	var showConsole = false;
	var wasMouseDisabled = false;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if(FlxG.keys == null || FlxG.save.data == null || !FlxG.save.data.animDebug) return;
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F10){
			lines = [];
			trace("Cleared log");
		}else if(FlxG.keys != null && FlxG.keys.justPressed.F10 && FlxG.save.data != null){
			showConsole = !showConsole;
			alpha = (if(showConsole) 1 else 0);
			if(showConsole){
				wasMouseDisabled = FlxG.mouse.visible;
				FlxG.mouse.visible = true;
				requestUpdate = true;
				scaleX = lime.app.Application.current.window.width / 1280;
				scaleY = lime.app.Application.current.window.height / 720;
			}else{
				text = ""; // No need to have text if the console isn't showing
				FlxG.mouse.visible = wasMouseDisabled;
			}
		}
		if(showConsole && requestUpdate){
			text = lines.join("\n");
			scrollV = bottomScrollV;
			requestUpdate = false;
		}
		

	}
}