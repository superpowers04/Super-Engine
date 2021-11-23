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
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end



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
		// // : )
		// SE Specific
		interp.variables.set("Character", Character);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("Note", Note);
		interp.variables.set("EmptyCharacter", EmptyCharacter);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("Overlay", Overlay);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("TitleState", TitleState);
		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		interp.variables.set("SEVersion",MainMenuState.ver);
		interp.variables.set("FinishSubState",FinishSubState);


		// SE clones of other libaries
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("BRcolor", HscriptColor);
		interp.variables.set("SESettings",SESettings);
		interp.variables.set("FlxMath", SEMath);

		// Flixel Libaries

		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
		interp.variables.set("FlxAnimation", flixel.animation.FlxAnimation);
		interp.variables.set("FlxBaseAnimation", flixel.animation.FlxBaseAnimation);
		interp.variables.set("FlxBackdrop", flixel.addons.display.FlxBackdrop);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxTrailArea", FlxTrailArea);
		interp.variables.set("FlxPoint", FlxPoint);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxTimer", BRTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("FlxCamera",FlxCamera);
		interp.variables.set("FlxText",FlxText);
		interp.variables.set("FlxSort",FlxSort);

		// Normal Haxe
		interp.variables.set("Math", Math);
		interp.variables.set("Json", haxe.Json);
		interp.variables.set("Global",HSBrTools.shared);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("Reflect", Reflect);


		
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end
		
		
		return interp;
	}
}
class BRTimer extends FlxTimer{ // Make sure errors are caught whenever a timer is used
	override public function start(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var __onComplete:Null<FlxTimer->Void> = null;
		if(OnComplete != null){
			
			__onComplete = function(timer:FlxTimer):Void{
				try{
					OnComplete(timer);
				}catch(e){MainMenuState.handleError('An error occurred in a Timer: ${e.message}');}
			}
		}
		return super.start(Time,__onComplete,Loops);
	}
}

class SESettings{
	public static function get(id:String):Dynamic{
		return Reflect.field(FlxG.save.data,id);
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

	public static var sound(get,never):SoundFrontEnd;
	public static function init() {
	}
	static function get_sound(){
		return FlxG.sound;
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



// Litterally just FlxMath but without inline
class SEMath
{
	#if (flash || js || ios || blackberry)
	/**
	 * Minimum value of a floating point number.
	 */
	public static var MIN_VALUE_FLOAT:Float = 0.0000000000000001;
	#else

	/**
	 * Minimum value of a floating point number.
	 */
	public static var MIN_VALUE_FLOAT:Float = 5e-324;
	#end

	/**
	 * Maximum value of a floating point number.
	 */
	public static var MAX_VALUE_FLOAT:Float = 1.79e+308;

	/**
	 * Minimum value of an integer.
	 */
	public static var MIN_VALUE_INT:Int = -MAX_VALUE_INT;

	/**
	 * Maximum value of an integer.
	 */
	public static var MAX_VALUE_INT:Int = 0x7FFFFFFF;

	/**
	 * Approximation of `Math.sqrt(2)`.
	 */
	public static var SQUARE_ROOT_OF_TWO:Float = 1.41421356237;

	/**
	 * Used to account for floating-point inaccuracies.
	 */
	public static var EPSILON:Float = 0.0000001;

	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 *
	 * ```haxe
	 * roundDecimal(1.2485, 2) = 1.25
	 * ```
	 *
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimals the result should have.
	 * @return	The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float
	{
		var mult:Float = 1;
		for (i in 0...Precision)
		{
			mult *= 10;
		}
		return Math.fround(Value * mult) / mult;
	}

	/**
	 * Bound a number by a minimum and maximum. Ensures that this number is
	 * no smaller than the minimum, and no larger than the maximum.
	 * Leaving a bound `null` means that side is unbounded.
	 *
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	public static function bound(Value:Float, ?Min:Float, ?Max:Float):Float
	{
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}

	/**
	 * Returns the linear interpolation of two numbers if `ratio`
	 * is between 0 and 1, and the linear extrapolation otherwise.
	 *
	 * Examples:
	 *
	 * ```haxe
	 * lerp(a, b, 0) = a
	 * lerp(a, b, 1) = b
	 * lerp(5, 15, 0.5) = 10
	 * lerp(5, 15, -1) = -5
	 * ```
	 */
	public static function lerp(a:Float, b:Float, ratio:Float):Float
	{
		return a + ratio * (b - a);
	}

	/**
	 * Checks if number is in defined range. A null bound means that side is unbounded.
	 *
	 * @param Value		Number to check.
	 * @param Min		Lower bound of range.
	 * @param Max 		Higher bound of range.
	 * @return Returns true if Value is in range.
	 */
	public static function inBounds(Value:Float, Min:Null<Float>, Max:Null<Float>):Bool
	{
		return (Min == null || Value >= Min) && (Max == null || Value <= Max);
	}

	/**
	 * Returns `true` if the given number is odd.
	 */
	public static function isOdd(n:Float):Bool
	{
		return (Std.int(n) & 1) != 0;
	}

	/**
	 * Returns `true` if the given number is even.
	 */
	public static function isEven(n:Float):Bool
	{
		return (Std.int(n) & 1) == 0;
	}

	/**
	 * Returns `-1` if `a` is smaller, `1` if `b` is bigger and `0` if both numbers are equal.
	 */
	public static function numericComparison(a:Float, b:Float):Int
	{
		if (b > a)
		{
			return -1;
		}
		else if (a > b)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Returns true if the given x/y coordinate is within the given rectangular block
	 *
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rectX		The X value of the region to test within
	 * @param	rectY		The Y value of the region to test within
	 * @param	rectWidth	The width of the region to test within
	 * @param	rectHeight	The height of the region to test within
	 *
	 * @return	true if pointX/pointY is within the region, otherwise false
	 */
	public static function pointInCoordinates(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float):Bool
	{
		if (pointX >= rectX && pointX <= (rectX + rectWidth))
		{
			if (pointY >= rectY && pointY <= (rectY + rectHeight))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Returns true if the given x/y coordinate is within the given rectangular block
	 *
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rect		The FlxRect to test within
	 * @return	true if pointX/pointY is within the FlxRect, otherwise false
	 */
	public static function pointInFlxRect(pointX:Float, pointY:Float, rect:FlxRect):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
	}

	#if FLX_MOUSE
	/**
	 * Returns true if the mouse world x/y coordinate are within the given rectangular block
	 *
	 * @param	useWorldCoords	If true the world x/y coordinates of the mouse will be used, otherwise screen x/y
	 * @param	rect			The FlxRect to test within. If this is null for any reason this function always returns true.
	 *
	 * @return	true if mouse is within the FlxRect, otherwise false
	 */
	public static function mouseInFlxRect(useWorldCoords:Bool, rect:FlxRect):Bool
	{
		if (rect == null)
		{
			return true;
		}

		if (useWorldCoords)
		{
			return pointInFlxRect(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), rect);
		}
		else
		{
			return pointInFlxRect(FlxG.mouse.screenX, FlxG.mouse.screenY, rect);
		}
	}
	#end

	/**
	 * Returns true if the given x/y coordinate is within the Rectangle
	 *
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rect		The Rectangle to test within
	 * @return	true if pointX/pointY is within the Rectangle, otherwise false
	 */
	public static function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
	}

	/**
	 * Adds the given amount to the value, but never lets the value
	 * go over the specified maximum or under the specified minimum.
	 *
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @param 	min 	The minimum the value is allowed to be
	 * @return The new value
	 */
	public static function maxAdd(value:Int, amount:Int, max:Int, min:Int = 0):Int
	{
		value += amount;

		if (value > max)
		{
			value = max;
		}
		else if (value <= min)
		{
			value = min;
		}

		return value;
	}

	/**
	 * Makes sure that value always stays between 0 and max,
	 * by wrapping the value around.
	 *
	 * @param 	value 	The value to wrap around
	 * @param 	min		The minimum the value is allowed to be
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrap(value:Int, min:Int, max:Int):Int
	{
		var range:Int = max - min + 1;

		if (value < min)
			value += range * Std.int((min - value) / range + 1);

		return min + (value - min) % range;
	}

	/**
	 * Remaps a number from one range to another.
	 *
	 * @param 	value	The incoming value to be converted
	 * @param 	start1 	Lower bound of the value's current range
	 * @param 	stop1 	Upper bound of the value's current range
	 * @param 	start2  Lower bound of the value's target range
	 * @param 	stop2 	Upper bound of the value's target range
	 * @return The remapped value
	 */
	public static function remapToRange(value:Float, start1:Float, stop1:Float, start2:Float, stop2:Float):Float
	{
		return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
	}

	/**
	 * Finds the dot product value of two vectors
	 *
	 * @param	ax		Vector X
	 * @param	ay		Vector Y
	 * @param	bx		Vector X
	 * @param	by		Vector Y
	 *
	 * @return	Result of the dot product
	 */
	public static function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}

	/**
	 * Returns the length of the given vector.
	 */
	public static function vectorLength(dx:Float, dy:Float):Float
	{
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * Find the distance (in pixels, rounded) between two FlxSprites, taking their origin into account
	 *
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @return	Distance between the sprites in pixels
	 */
	public static function distanceBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Int
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		return Std.int(SEMath.vectorLength(dx, dy));
	}

	/**
	 * Check if the distance between two FlxSprites is within a specified number.
	 * A faster algorithm than distanceBetween because the Math.sqrt() is avoided.
	 *
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calculated distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance
	 */
	public static function isDistanceWithin(SpriteA:FlxSprite, SpriteB:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}

	/**
	 * Find the distance (in pixels, rounded) from an FlxSprite
	 * to the given FlxPoint, taking the source origin into account.
	 *
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @return	Distance in pixels
	 */
	public static function distanceToPoint(Sprite:FlxSprite, Target:FlxPoint):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Target.x;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Target.y;
		Target.putWeak();
		return Std.int(SEMath.vectorLength(dx, dy));
	}

	/**
	 * Check if the distance from an FlxSprite to the given
	 * FlxPoint is within a specified number.
	 * A faster algorithm than distanceToPoint because the Math.sqrt() is avoided.
	 *
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calculated distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance
	 */
	public static function isDistanceToPointWithin(Sprite:FlxSprite, Target:FlxPoint, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - (Target.x);
		var dy:Float = (Sprite.y + Sprite.origin.y) - (Target.y);

		Target.putWeak();

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}

	#if FLX_MOUSE
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the mouse x/y
	 *
	 * @param	Sprite	The FlxSprite to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	public static function distanceToMouse(Sprite:FlxSprite):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		return Std.int(SEMath.vectorLength(dx, dy));
	}

	/**
	 * Check if the distance from the object x/y and the mouse x/y is within a specified number.
	 * A faster algorithm than distanceToMouse because the Math.sqrt() is avoided.
	 *
	 * @param	Sprite		The FlxSprite to test against
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calculated distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance
	 */
	public static function isDistanceToMouseWithin(Sprite:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end

	#if FLX_TOUCH
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the FlxPoint screen x/y
	 *
	 * @param	Sprite	The FlxSprite to test against
	 * @param	Touch	The FlxTouch to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	public static function distanceToTouch(Sprite:FlxSprite, Touch:FlxTouch):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		return Std.int(SEMath.vectorLength(dx, dy));
	}

	/**
	 * Check if the distance from the object x/y and the FlxPoint screen x/y is within a specified number.
	 * A faster algorithm than distanceToTouch because the Math.sqrt() is avoided.
	 *
	 * @param	Sprite	The FlxSprite to test against
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calculated distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance
	 */
	public static function isDistanceToTouchWithin(Sprite:FlxSprite, Touch:FlxTouch, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end

	/**
	 * Returns the amount of decimals a `Float` has.
	 */
	public static function getDecimals(n:Float):Int
	{
		var helperArray:Array<String> = Std.string(n).split(".");
		var decimals:Int = 0;

		if (helperArray.length > 1)
		{
			decimals = helperArray[1].length;
		}

		return decimals;
	}

	public static function equal(aValueA:Float, aValueB:Float, aDiff:Float = 0.0000001):Bool
	{
		return (Math.abs(aValueA - aValueB) <= aDiff);
	}

	/**
	 * Returns `-1` if the number is smaller than `0` and `1` otherwise
	 */
	public static function signOf(n:Float):Int
	{
		return (n < 0) ? -1 : 1;
	}

	/**
	 * Checks if two numbers have the same sign (using `FlxMath.signOf()`).
	 */
	public static function sameSign(a:Float, b:Float):Bool
	{
		return signOf(a) == signOf(b);
	}

	/**
	 * A faster but slightly less accurate version of `Math.sin()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param	n	The angle in radians.
	 * @return	An approximated sine of `n`.
	 */
	public static function fastSin(n:Float):Float
	{
		n *= 0.3183098862; // divide by pi to normalize

		// bound between -1 and 1
		if (n > 1)
		{
			n -= (Math.ceil(n) >> 1) << 1;
		}
		else if (n < -1)
		{
			n += (Math.ceil(-n) >> 1) << 1;
		}

		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (n > 0)
		{
			return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)));
		}
		else
		{
			return n * (3.1 - n * (0.5 + n * (7.2 + n * 3.6)));
		}
	}

	/**
	 * A faster, but less accurate version of `Math.cos()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param	n	The angle in radians.
	 * @return	An approximated cosine of `n`.
	 */
	public static function fastCos(n:Float):Float
	{
		return fastSin(n + 1.570796327); // sin and cos are the same, offset by pi/2
	}

	/**
	 * Hyperbolic sine.
	 */
	public static function sinh(n:Float):Float
	{
		return (Math.exp(n) - Math.exp(-n)) / 2;
	}

	/**
	 * Returns the bigger argument.
	 */
	public static function maxInt(a:Int, b:Int):Int
	{
		return (a > b) ? a : b;
	}

	/**
	 * Returns the smaller argument.
	 */
	public static function minInt(a:Int, b:Int):Int
	{
		return (a > b) ? b : a;
	}

	/**
	 * Returns the absolute integer value.
	 */
	public static function absInt(n:Int):Int
	{
		return (n > 0) ? n : -n;
	}
}