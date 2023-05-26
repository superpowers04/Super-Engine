package se.objects;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxBasic;
import se.extensions.flixel.FlxSpriteLockScale;
import flixel.FlxG;


class SETooltip extends FlxBasic {
	public var textObject:FlxText;
	public var backgroundObject:FlxSpriteLockScale;
	public var text(get,set):String;

	public function get_text(){
		return textObject.text;
	}
	public function set_text(_text:String){
		if(textObject.text == _text) return _text;
		textObject.text = _text;
		backgroundObject.lockGraphicSize((Std.int(textObject.width) + 4),Std.int(textObject.height) + 4);
		return textObject.text;
	}

	public override function new(){
		super();
		textObject = new FlxText(0,-100,'Funny blank tooltip loma');
		textObject.setFormat(null, 16, 0xffffaaff, CENTER);
		// objectPosText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,);
		textObject.scrollFactor.set();
		
		backgroundObject = new FlxSpriteLockScale(-10,-100);
		backgroundObject.makeGraphic(1,1,0xFF000000);
		backgroundObject.lockGraphicSize(Std.int(textObject.width) + 4,Std.int(textObject.height) + 4);
		backgroundObject.alpha = 0.4;
		backgroundObject.scrollFactor.set();
	}
	public override function update(e){
		if(!visible) return;
		backgroundObject.update(e);
		textObject.update(e);
	}

	override function draw(){
		if(!visible) return;
		backgroundObject.x = (textObject.x = FlxG.mouse.screenX + 20) - 2;
		backgroundObject.y = (textObject.y = FlxG.mouse.screenY + 20) - 2;
		backgroundObject.draw();
		textObject.draw();
	}
}

