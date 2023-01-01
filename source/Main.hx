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

		game = new FlxGameEnhanced(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
		addChild(funniSprite);
		funniSprite.addChild(game);
		LoadingScreen.show();
		fpsCounter = new Overlay(0, 0);
		game.addChild(fpsCounter);
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
		FuckState.FUCK(e);
	}
}

// Made specifically for Super Engine. Adds some extensions to FlxGame to allow it to handle errors
// If you use this at all, Please credit me
class FlxGameEnhanced extends FlxGame{
	static var blankState:FlxState = new FlxState();
	public function forceStateSwitch(state:FlxState){ // Might be a bad idea but allows an error to force a state change to Mainmenu instead of softlocking
		_requestedState = state;
		switchState();
	}
	public var blockUpdate:Bool = false;
	public var blockDraw:Bool = false;
	public var blockEnterFrame:Bool = false;
	var requestAdd = false;
	override function create(_){

		try{
			super.create(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.Create");
		}
	}
	override function onEnterFrame(_){
		try{
			if(requestAdd){
				requestAdd = false;
				Main.funniSprite.addChild(this);
				blockUpdate = blockEnterFrame = blockDraw = false;
				FlxG.autoPause = _oldAutoPause;
				_oldAutoPause = false;

				if(_lostFocusWhileLoading != null){
					onFocusLost(_lostFocusWhileLoading);_lostFocusWhileLoading = null;
				}

			}

			if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F1){
				MainMenuState.handleError("Manually triggered force exit");
			}
			if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F4){
				throw('Manually triggered crash');
			}
			if(blockEnterFrame) {
				ticks = getTicks();
				_elapsedMS = ticks - _total;
				_total = ticks;
			}else{
				super.onEnterFrame(_);
			}

		}catch(e){
			FuckState.FUCK(e,"FlxGame.onEnterFrame");
		}
	}
	public var funniLoad:Bool = false;
	function _update(){
		if (!_state.active || !_state.exists)
			return;


		#if FLX_DEBUG
		if (FlxG.debugger.visible)
			ticks = getTicks();
		#end

		updateElapsed();

		FlxG.signals.preUpdate.dispatch();

		#if FLX_POST_PROCESS
		if (postProcesses[0] != null)
			postProcesses[0].update(FlxG.elapsed);
		#end

		#if FLX_SOUND_SYSTEM
		FlxG.sound.update(FlxG.elapsed);
		#end
		FlxG.plugins.update(FlxG.elapsed);

		FlxG.signals.postUpdate.dispatch();

		#if FLX_DEBUG
		debugger.stats.flixelUpdate(getTicks() - ticks);
		#end

		filters = filtersEnabled ? _filters : null;
	}
	var _oldAutoPause:Bool = false;

	override function update(){
		
		try{
			#if(target.threaded)
				if(_state != _requestedState && FlxG.save.data.doCoolLoading){
					blockUpdate = blockEnterFrame = blockDraw = true;
					Main.funniSprite.removeChild(this);
					_oldAutoPause = FlxG.autoPause;
					FlxG.autoPause = false;
					visible = false;
					sys.thread.Thread.create(() -> { 
						switchState();
						
						requestAdd = true;
						visible = true;
					});
					return;
				}
			#end
			if(blockUpdate) _update(); else {
				super.update();

				if (FlxG.keys.justPressed.F11)
				{
					FlxG.save.data.fullscreen = (FlxG.fullscreen = !FlxG.fullscreen);
				}
			}
		}catch(e){
			FuckState.FUCK(e,"FlxGame.Update");
		}
	}
	override function draw(){
		try{
			if(blockDraw)
				return;
			else{
				super.draw();
			}
		}catch(e){
			FuckState.FUCK(e,"FlxGame.Draw");
		}
	}
	var _lostFocusWhileLoading:flash.events.Event = null;
	override function onFocus(_){
		try{
			if(blockEnterFrame)
				_lostFocusWhileLoading = null;
			else
				super.onFocus(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.onFocus");
		}
	}
	override function onFocusLost(_){
		try{
			if(blockEnterFrame && _oldAutoPause) _lostFocusWhileLoading = _; 
			else if(!blockEnterFrame && onlinemod.OnlinePlayMenuState.socket == null) 
				super.onFocusLost(_);
		}catch(e){
			FuckState.FUCK(e,"FlxGame.onFocusLost");
		}
	}
}