package;

import flash.display.Sprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flash.display.BitmapData;

class LoadingScreen extends Sprite{
	public static var object:LoadingScreen;
	var funni = false;
	// var loadingText:Alphabet;
	@:access(flixel.FlxCamera)


	public override function new(?txt = "loading"){
		super();

		width = 1280;
		height = 720;

		scaleX = FlxG.game.scaleX;
		scaleY = FlxG.game.scaleY;
		// graphics.beginFill(0x110011);
		// graphics.drawRect(0,0, 1280, 720);
		// graphics.endFill();
		var loadingText = new Alphabet(0,0,txt,true);
		loadingText.isMenuItem = false;
		loadingText.visible = true;
		var funniBitmap = new BitmapData(1290,730,false,0x100010);
		var x = 850;
		var y = 600;
		for (i in 0...loadingText.members.length) {
			var v = loadingText.members[i];
			v.useFramePixels = true;
			v.draw();
			funniBitmap.copyPixels(v.framePixels,new flash.geom.Rectangle(0,0,v.width,v.height),new flash.geom.Point(x,y));
			// graphics.beginBitmapFill(v.framePixels,false,true);
			// graphics.moveTo(x,y);
			// graphics.drawRect(0,0, v.width, v.height);
			// graphics.endFill();
			x += Std.int(v.width + 2);
		}

		graphics.beginBitmapFill(funniBitmap,false,true);
		graphics.moveTo(x,y);
		graphics.drawRect(-5,-5, funniBitmap.width, funniBitmap.height);
		graphics.endFill();
		loadingText.destroy();

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

	public static function initScreen(?text:String = "Loading"){
		object = new LoadingScreen(text);
	}
	public static var tween:FlxTween;
	public static function show(){
		if(object == null){
			initScreen();
		}
		object.alpha = 1;
		if(tween != null){tween.cancel();}
		object.funni = true;
		object.scaleX = FlxG.game.scaleX;
		object.scaleY = FlxG.game.scaleY;
		FlxG.stage.addChild(object);
		// object.visible = true;
	}
	public static function hide(){
		if(object == null){
			return;
		}
		if(!object.funni){return;}
		if(tween != null){tween.cancel();}
		object.funni = false;
		object.alpha = 1;
		object.scaleX = FlxG.game.scaleX;
		object.scaleY = FlxG.game.scaleY;
		tween = FlxTween.tween(object,{alpha:0},0.4,{onComplete:function(_){FlxG.stage.removeChild(object);}});
		
	}
}
