package;

import flash.display.Sprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flash.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.text.FlxText;

class LoadingScreen extends Sprite{
	public static var object:LoadingScreen;
	public static var loadingText(default,set):String = "";
	public static function set_loadingText(val:String):String{
		loadingText = val;
		// Main.game.blockUpdate = Main.game.blockDraw = true;
		// lime.app.Application.current.draw();
		// Main.game.blockUpdate = Main.game.blockDraw = false;
		return loadingText;
	}
	// var _loadingText:String = "";
	var funni = false;
	var textField:TextField;
	// var loadingText:Alphabet;
	

	public override function new(?txt = "loading"){
		super();

		width = 1280;
		height = 720;

			// scaleX = lime.app.Application.current.window.width / 1280;
			// scaleY = lime.app.Application.current.window.height / 720;
		// graphics.beginFill(0x110011);
		// graphics.drawRect(0,0, 1280, 720);
		// graphics.endFill();
		var loadingText = new Alphabet(0,0,txt,true);
		loadingText.isMenuItem = false;
		loadingText.visible = true;
		var funniBitmap = new BitmapData(1290,730,false,0x100010);
		var x = 1200;
		var y = 600;
		var i = loadingText.members.length - 1;
		while (i >= 0) { // Writing backwards instead of forwards
			var v = loadingText.members[i];
			v.useFramePixels = true;
			v.draw();
			x -= Std.int(v.width - 2);
			funniBitmap.copyPixels(v.framePixels,new flash.geom.Rectangle(0,0,v.width,v.height),new flash.geom.Point(x,y));
			// graphics.beginBitmapFill(v.framePixels,false,true);
			// graphics.moveTo(x,y);
			// graphics.drawRect(0,0, v.width, v.height);
			// graphics.endFill();
			i--;
		}

		graphics.beginBitmapFill(funniBitmap,false,true);
		graphics.moveTo(x,y);
		graphics.drawRect(-5,-5, funniBitmap.width, funniBitmap.height);
		graphics.endFill();
		loadingText.destroy();


		var errText:FlxText = new FlxText(0,0,0,'');
		errText.size = 20;
		errText.setFormat(CoolUtil.font, 32, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		errText.setBorderStyle(FlxTextBorderStyle.OUTLINE,0xFF000000,4,1);
		errText.scrollFactor.set();
		var oldTF = errText.textField;
		errText.destroy();
		textField = new TextField();
		textField.width = 1280;
		textField.text = "";
		textField.y = 720 * 0.7;
		addChild(textField);


		// textField.x = (1280 * 0.5);
		var tf = new TextFormat(oldTF.defaultTextFormat.font, 32, 0xFFFFFF);
		textField.embedFonts = oldTF.embedFonts;
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

	public static function initScreen(?text:String = "Loading"){
		object = new LoadingScreen(text);

	}
	var elapsed = 0;
	override function __enterFrame(e:Int){
		if(textField.htmlText != loadingText){
			updateText();
		}
		super.__enterFrame(e);
	} 
	function updateText(){
		textField.htmlText = loadingText;
		// textField.x = (1280 * 0.5) - textField.width;
	}
	public static var tween:FlxTween;
	public static function show(){
		if(object == null){
			initScreen();
		}
		object.alpha = 1;
		if(tween != null){tween.cancel();}
		object.funni = true;
		object.elapsed = 0;
		object.scaleX = lime.app.Application.current.window.width / 1280;
		object.scaleY = lime.app.Application.current.window.height / 720;
		FlxG.stage.addChild(object);
		loadingText = "";
		object.updateText();
		// object.visible = true;
	}
	public static function forceHide(){
		if(object == null){
			return;
		}
		if(tween != null){tween.cancel();}
		object.funni = false;
		object.alpha = 0;
		
	}
	public static function hide(){
		Main.game.blockUpdate = Main.game.blockDraw = false;
		if(object == null){
			return;
		}
		if(!object.funni){return;}
		if(tween != null){tween.cancel();}
		object.funni = false;
		object.alpha = 1;
		tween = FlxTween.tween(object,{alpha:0},0.4,{onComplete:function(_){FlxG.stage.removeChild(object);}});
		
	}





}
