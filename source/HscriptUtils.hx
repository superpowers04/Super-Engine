package;

//More Modding Plus stuff

import openfl.display.DisplayObject;
import openfl.display.Stage;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.addons.effects.FlxTrail;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxGame;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import hscript.InterpEx;
import hscript.Interp;
import flixel.FlxG;
import flash.media.Sound;
import flixel.graphics.FlxGraphic;


class HscriptUtils {
   public static var interp = new InterpEx();
    public static var hscriptClasses:Array<String> = [];
	@:access(hscript.InterpEx)
    public static function init() {
        // var filelist = hscriptClasses = CoolUtil.coolTextFile("assets/scripts/plugin_classes/classes.txt");
		interp = addVarsToInterp(interp);
        HscriptGlobals.init();
        trace(InterpEx._scriptClassDescriptors);
    }
    /**
     * Create a simple interp, that already added all the needed shit
     * This is what has all the default things for hscript.
     * @see https://github.com/TheDrawingCoder-Gamer/Funkin/wiki/HScript-Commands
     * @return Interp
     */
    public static function createSimpleInterp():Interp {
        var reterp = new Interp();
        reterp = addVarsToInterp(reterp);
        return reterp;
    }
     public static function addVarsToInterp<T:Interp>(interp:T):T {
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
        interp.variables.set("FlxMath", flixel.math.FlxMath);
        interp.variables.set("FlxAnimation", flixel.animation.FlxAnimation);
		interp.variables.set("FlxBaseAnimation", flixel.animation.FlxBaseAnimation);
		interp.variables.set("TitleState", TitleState);
		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		// // : )
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxTrail", FlxTrail);
        interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("BRcolor", HscriptColor);
		interp.variables.set("Reflect", Reflect);
        interp.variables.set("Character", Character);
        interp.variables.set("PlayState", PlayState);
        interp.variables.set("Note", Note);
        interp.variables.set("EmptyCharacter", EmptyCharacter);
        interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("Alphabet", Alphabet);
		
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end
        return interp;
    }
}
class HscriptColor{
    public static var TRANSPARENT:FlxColor = 0x00000000;
    public static var WHITE:FlxColor = 0xFFFFFFFF;
    public static var GRAY:FlxColor = 0xFF808080;
    public static var BLACK:FlxColor = 0xFF000000;

    public static var GREEN:FlxColor = 0xFF008000;
    public static var LIME:FlxColor = 0xFF00FF00;
    public static var YELLOW:FlxColor = 0xFFFFFF00;
    public static var ORANGE:FlxColor = 0xFFFFA500;
    public static var RED:FlxColor = 0xFFFF0000;
    public static var PURPLE:FlxColor = 0xFF800080;
    public static var BLUE:FlxColor = 0xFF0000FF;
    public static var BROWN:FlxColor = 0xFF8B4513;
    public static var PINK:FlxColor = 0xFFFFC0CB;
    public static var MAGENTA:FlxColor = 0xFFFF00FF;
    public static var CYAN:FlxColor = 0xFF00FFFF;
    public static function fromInt(Value:Int):FlxColor
    {
        return new FlxColor(Value);
    }
}



class HscriptGlobals {
    public static var VERSION = FlxG.VERSION;
    public static var autoPause(get, set):Bool;
    public static var bitmap(get, never):BitmapFrontEnd;
    // no bitmapLog
    public static var camera(get ,set):FlxCamera;
    public static var cameras(get, never):CameraFrontEnd;
    // no console frontend
    // no debugger frontend
    public static var drawFramerate(get, set):Int;
    public static var elapsed(get, never):Float;
    public static var fixedTimestep(get, set):Bool;
    public static var fullscreen(get, set):Bool;
    public static var game(get, never):FlxGame;
    public static var gamepads(get, never):FlxGamepadManager;
    public static var height(get, never):Int;
    public static var initialHeight(get, never):Int;
    public static var initialWidth(get, never):Int;
    public static var initialZoom(get, never):Float;
    public static var keys(get, never):FlxKeyboard;
    // no log
    public static var maxElapsed(get, set):Float;
    public static var mouse = FlxG.mouse;
    // no plugins
    public static var random= FlxG.random;
    public static var renderBlit(get, never):Bool;
    public static var renderMethod(get, never):FlxRenderMethod;
    public static var renderTile(get, never):Bool;
    public static var stage(get, never):Stage;
    public static var state(get, never):FlxState;
    // no swipes because no mobile : )
    public static var timeScale(get, set):Float;
    // no touch because no mobile : )
    public static var updateFramerate(get,set):Int;
    // no vcr : )
    // no watch : )
    public static var width(get, never):Int;
    public static var worldBounds(get, never):FlxRect;
    public static var worldDivisions(get, set):Int;
    public static function init() {
    }
    static function get_bitmap() {
        return FlxG.bitmap;
    }
    static function get_cameras() {
        return FlxG.cameras;
    }
    static function get_autoPause():Bool {
        return FlxG.autoPause;
    }
    static function set_autoPause(b:Bool):Bool {
        return FlxG.autoPause = b;
    }
	static function get_drawFramerate():Int
	{
		return FlxG.drawFramerate;
	}

	static function set_drawFramerate(b:Int):Int
	{
		return FlxG.drawFramerate = b;
	}
    static function get_elapsed():Float {
        return FlxG.elapsed;
    }
	static function get_fixedTimestep():Bool
	{
		return FlxG.fixedTimestep;
	}

	static function set_fixedTimestep(b:Bool):Bool
	{
		return FlxG.fixedTimestep = b;
	}
	static function get_fullscreen():Bool
	{
		return FlxG.fullscreen;
	}

	static function set_fullscreen(b:Bool):Bool
	{
		return FlxG.fullscreen = b;
	}
    static function get_height():Int {
        return FlxG.height;
    }
    static function get_initialHeight():Int {
        return FlxG.initialHeight;
    }
    static function get_camera():FlxCamera {
        return FlxG.camera;
    }
    static function set_camera(c:FlxCamera):FlxCamera {
        return FlxG.camera = c;
    }
    static function get_game():FlxGame {
        return FlxG.game;
    }
    static function get_gamepads():FlxGamepadManager {
        return FlxG.gamepads;
    }
    static function get_initialWidth():Int {
        return FlxG.initialWidth;
    }
    static function get_initialZoom():Float {
        return FlxG.initialZoom;
    }
    static function get_inputs() {
        return FlxG.inputs;
    }
    static function get_keys() {
        return FlxG.keys;
    }
    static function set_maxElapsed(s) {
        return FlxG.maxElapsed = s;
    }
    static function get_maxElapsed() {
        return FlxG.maxElapsed;
    }
    static function get_renderBlit() {
        return FlxG.renderBlit;
    }
    static function get_renderMethod() {
        return FlxG.renderMethod;
    }
    static function get_renderTile() {
        return FlxG.renderTile;
    }
    static function get_stage() {
        return FlxG.stage;
    }
    static function get_state() {
        return FlxG.state;
    }
    static function set_timeScale(s) {
        return FlxG.timeScale = s;
    }
    static function get_timeScale() {
        return FlxG.timeScale;
    }
    static function set_updateFramerate(s) {
        return FlxG.updateFramerate = s;
    }
    static function get_updateFramerate() {
        return FlxG.updateFramerate;
    }
    static function get_width() {
        return FlxG.width;
    }
    static function get_worldBounds() {
        return FlxG.worldBounds;
    }
    static function get_worldDivisions() {
        return FlxG.worldDivisions;
    }
	static function set_worldDivisions(s)
	{
		return FlxG.worldDivisions = s;
	}

    public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
        return FlxG.addChildBelowMouse(Child, IndexModifier);
    }
    public static function collide(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback) {
        return FlxG.collide(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback);
    }
    // no open url because i don't trust you guys

	public static function overlap(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback, ?ProcessCallback)
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
	}
    public static function pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance = 255, ?Camera) {
        return FlxG.pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance, Camera);
    }
    public static function removeChild<T:DisplayObject>(Child:T):T {
        return FlxG.removeChild(Child);
    }
}
