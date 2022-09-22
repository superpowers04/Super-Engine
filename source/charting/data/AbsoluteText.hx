package charting.data;

import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * A simple text class that will only follows it's parent's positions.
 * Will copy it's parent's opacity aswell (optional, copies by default).
 */
class AbsoluteText extends FlxText
{
	public var parent:FlxSprite;
	public var offsetX:Null<Float> = null;
	public var offsetY:Null<Float> = null;
	public var trackAlpha:Bool = true;

	public function new(text:String, size:Int, ?parent:FlxSprite, ?offsetX:Float, ?offsetY:Float)
	{
		super(0, 0, 400, text, size);

		setFormat(Paths.font('vcr.ttf'), size);

		this.parent = parent;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (parent != null)
		{
			setPosition(parent.x + offsetX, parent.y + offsetY);

			if (trackAlpha)
				alpha = parent.alpha;
		}
	}
}

class EventText extends FlxText
{
	public var tracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (tracker != null)
		{
			setPosition(tracker.x + xAdd, tracker.y + yAdd);
			angle = tracker.angle;
			alpha = tracker.alpha;
		}
	}
}
