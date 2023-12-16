package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:Dynamic;
	public var flashingEl:Float = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0,weekName:String = "")
	{
		super(x, y);
		var size = Std.int(48 - (weekName.length * 0.4));
		week = new FlxText(0,0,0,weekName,size);
		// week.font = CoolUtil.font;
		week.setFormat(CoolUtil.font,size);
		// week.wordWrap = true;
		week.y += week.height * 0.50;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
		week.color = 0xFF33ffff;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol

	// what you're literally using elapsed to get the framerate

	// var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48),10 * elapsed);
		if (SESave.data.flashing){

			if (isFlashing)
				flashingEl += elapsed;

			if (flashingEl > 0.5 ){
				week.color = 0xFF33ffff;
			}
			else if(flashingEl > 1){
				flashingEl = 0;
				week.color = FlxColor.WHITE;
			}
		}
	}
}
