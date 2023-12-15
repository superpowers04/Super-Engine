package se;

import flash.display.Sprite;
import flash.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFormat;
import lime.app.Application;

class ErrorSprite extends Sprite{
	
	var textField:TextField;
	public override function new(?txt = "loading"){
		super();

		width = 1280;
		height = 720;

		var funniBitmap = new BitmapData(1290,730,false,0x100010);
		graphics.beginBitmapFill(funniBitmap,false,true);
		graphics.endFill();

		addChild(textField = new TextField());
		textField.width = 1280;
		textField.text = "";
		textField.y = 720 * 0.7;


		// textField.x = (1280 * 0.5);
		var tf = new TextFormat(null, 32, 0xFFFFFF);
		textField.embedFonts = true;
		tf.align = "center";
		textField.defaultTextFormat = tf;



		// new FlxTimer().start(0.1,function(_){
		// 	FlxG.cameras.remove(cam);
		// 	graphics.beginBitmapFill(cam.buffer);
		// 	graphics.drawRect(0,0, 1280, 720);
		// 	graphics.endFill();
		// 	loadingText.destroy();
		// 	cam.destroy();
		// 	cam = null;
		// 	loadingText = null;
		// },1);
		// loadingText.update(0);
		// loadingText.draw();
		
		
		// super.addChild(loadingText);
	}

}