package;

// An FlxText that has the movement of an Alphabet object

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;


class MenuOption extends FlxText{
	public var targetY:Float = 0;
	public var alpha:Float = 0;

	override function update(elapsed:Float){
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
		x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		super.update(elapsed);
	}

}