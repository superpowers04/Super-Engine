package charting.data;

import flixel.addons.display.shapes.FlxShape;

class BaseButton extends FlxShape
{
	public var clickThing:Void->Void;
	public var size:String = "";
	public var child(default, set):String;
	public static var sizes:Map<String,Array<Int>> = [
		"large" => [342,45],
		"medium" => [297,47],
		"small" => [183,52],
	];

	public function new(x:Float, y:Float, size:String = "", ?clickThing:Void->Void)
	{
		var _size = [342,45];
		if(sizes[size.toLowerCase()] != null){
			_size = sizes[size.toLowerCase()];
		}
		super(x, y,_size[0],_size[1],{jointStyle:"bevel",thickness:2,color:0x543b61},0x543b61);
		this.clickThing = clickThing;
		this.size = size;

		// loadGraphic(Paths.image('chart editor/ui-buttons/charting_button-${size.toLowerCase()}'));
		antialiasing = true;
		scrollFactor.set();
	}

	public function set_child(value:String):String
	{
		child = value;
		return child;
	}

	public function onClick(?value:Dynamic):Void
	{
		if (clickThing != null)
			clickThing();
	}
}

class ChartingButton extends BaseButton
{
	public function new(x:Float, y:Float, size:String = "", ?onClickAction:Void->Void)
	{
		super(x, y, size, onClickAction);
	}

	override public function onClick(?value:Dynamic)
	{
		if (value != null)
			child = value;

		super.onClick();
	}
}
