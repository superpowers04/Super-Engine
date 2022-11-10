package;

import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import lime.app.Application as LimeApp;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
// import crashdumper.CrashDumper;
// import crashdumper.SessionData;
import Overlay;

import haxe.CallStack;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
	public static var errorMessage = "";
	public static var instance:Main;
	public static var funniSprite:Sprite;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets 

	public static var watermarks = true; // Whether to put Kade Engine liteartly anywhere

	public static var game:FlxGameEnhanced;

	public static var fpsCounter:Overlay;
	public static var console:Console;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{

		// quick checks 

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		instance = this;
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		// var crashDumper = new CrashDumper(SessionData.generateID("FNFBR-"));
		#if !debug
			initialState = TitleState;
		#end

		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		
		addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		funniSprite = new Sprite();

		game = new FlxGameEnhanced(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(funniSprite);
		funniSprite.addChild(game);
		LoadingScreen.show();
		fpsCounter = new Overlay(0, 0);
		addChild(fpsCounter);
		console = new Console();
		#if !mobile
		addChild(console);

		// fpsCounter.visible = false;
		// fpsOverlay = new Overlay(0, 0);
		// addChild(fpsCounter);

		// fpsCounter = new FPS(10, 3, 0xFFFFFF);
		// addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);

		#end
	}
	function uncaughtErrorHandler(event:UncaughtErrorEvent):Void { // Yes this is copied from the wiki, fuck you
		var message:String;
		if (Std.isOfType(event.error, openfl.errors.Error)) {
			var err = cast(event.error, openfl.errors.Error);
			message = err.getStackTrace();
			if(message == null){
				message = err.message;
			}
		} else if (Std.isOfType(event.error, openfl.events.ErrorEvent)) {
			message = cast(event.error, openfl.events.ErrorEvent).text;
		} else {
			message = Std.string(event.error);
		}
		FuckState.FUCK(null,message);
	}
	// var fpsOverlay:Overlay;

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
	public function onCrash(e:UncaughtErrorEvent){

		game = null;
		// overlay.destroy();

		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", ".");

		var path:String = "./crash/" + "FNFBR_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");
		LimeApp.current.window.alert(errMsg, "Restarting game due to error!");
		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + path);
		// errorMessage = 'Uncaught error forced game to reboot, Crash dump saved in "${Path.normalize(path)}"';
		setupGame();
	}
}


class FlxGameEnhanced extends FlxGame{
	public var blockUpdate:Bool = false;
	public var blockDraw:Bool = false;
	public var blockEnterFrame:Bool = false;
	public function forceStateSwitch(state:FlxState){ // Might be a bad idea but allows an error to force a state change to Mainmenu instead of softlocking
		_requestedState = state;
		switchState();
	}
	override function onEnterFrame(_){
		try{
			if(!blockEnterFrame) super.onEnterFrame(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.onEnterFrame");
		}
	}
	function _update(){
		super.update();
	}
	public var funniLoad:Bool = false;
	override function update(){
		try{
			#if(target.threaded && false) // This is broken at the moment
			if(_state != _requestedState){
				// blockUpdate = blockEnterFrame = blockDraw = true;
				Main.funniSprite.removeChild(this);
				// funniLoad = true;
				sys.thread.Thread.create(() -> { 
					// _update();
					switchState();
					Main.funniSprite.addChild(this);
					// funniLoad = false;
				});
				return;
			}
			#end
			if(!blockUpdate) super.update();
		}catch(e){
			FuckState.FUCK(e,"FlxGame.Update");
		}
	}
	override function draw(){
		try{
			if(!blockDraw) super.draw();
		}catch(e){
			FuckState.FUCK(e,"FlxGame.Draw");
		}
	}
	override function onFocus(_){
		try{
			super.onFocus(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.onFocus");
		}
	}
	override function onFocusLost(_){
		try{
			super.onFocusLost(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.onFocusLost");
		}
	}
}