package;

import flash.display.Sprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flash.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class LoadingScreen extends Sprite{
	public static var object:LoadingScreen;
	public static var isVisible = false;

	public static var loadingText(default,set):String = "";
	public static function set_loadingText(val:String):String{
		// Main.game.blockUpdate = Main.game.blockDraw = true;
		// lime.app.Application.current.draw();
		// Main.game.blockUpdate = Main.game.blockDraw = false;
		return loadingText = val;
	}
	// var _loadingText:String = "";
	var funni = false;
	var textField:TextField;
	// var loadingText:Alphabet;
	var loadingIcon:Sprite;
	var vel:Float = 0;

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
		if(FlxG.save.data.doCoolLoading){
			loadingIcon = new Sprite();
			loadingIcon.x = 640;
			loadingIcon.y = 300;
			addChild(loadingIcon);
			var note = new Note(0, 0, null,false,false);
			note.useFramePixels = true;
			note.draw();
			loadingIcon.graphics.beginBitmapFill(note.framePixels,false,true);
			// loadingIcon.graphics.moveTo();
			// 
			loadingIcon.graphics.drawRect(0,0, note.framePixels.width, note.framePixels.height);
			loadingIcon.graphics.endFill();
			loadingIcon.scaleX = loadingIcon.scaleY= 0.5;
			
		}

		var funniBitmap = new BitmapData(1290,730,false,0x100010);
		var x = 1200;
		var y = 600;
		var i = loadingText.members.length - 1;
		while (i >= 0) { // Writing backwards instead of forwards
			var v = loadingText.members[i];
			v.useFramePixels = true;
			v.drawFrame();
			x -= Std.int(v.width - 2);
			funniBitmap.copyPixels(v.framePixels,new flash.geom.Rectangle(0,0,v.width,v.height),new flash.geom.Point(x,y));
			v.destroy();
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
		// addChild(Main.fpsCounter);

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
		try{
			if(textField.htmlText != loadingText){
				updateText();
			}
			if(FlxG.save.data.doCoolLoading){
				if(loadingIcon != null){
					loadingIcon.rotation += e * vel;
					loadingIcon.rotation = loadingIcon.rotation % 360;
					vel = FlxMath.lerp(0.02,vel,e * 0.001); // This is shit but I don't care, it's funny
				}
				if(object.funni && alpha < 1){
					alpha += e * 0.003;
				}else if(!object.funni) {
					if(alpha > 0.003){
						alpha -= e * 0.003;
					}else{
						FlxG.stage.removeChild(this);
					}
				}
			}

			if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F1){
				MainMenuState.handleError("Manually triggered force exit");
			}
			if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F4){
				throw('Manually triggered crash');
			}
			super.__enterFrame(e);
		}
		catch(e){
			trace(e);

		}	
	} 
	function updateText(){
		textField.htmlText = loadingText;
		if(loadingIcon != null) vel += 0.15;
		// textField.x = (1280 * 0.5) - textField.width;
	}
	public static var tween:FlxTween;
	public static function show(){
		if(object == null){
			initScreen();
		}
		// object.alpha = 1;
		if(tween != null){tween.cancel();}
		isVisible = object.funni = true;
		object.elapsed = 0;
		object.scaleX = lime.app.Application.current.window.width / 1280;
		object.scaleY = lime.app.Application.current.window.height / 720;
		Main.funniSprite.addChildAt(object,1);
		loadingText = "";
		object.updateText();
		if(!FlxG.save.data.doCoolLoading)object.alpha = 1;

		// object.visible = true;
	}
	public static function forceHide(){
		if(object == null){
			return;
		}
		if(tween != null){tween.cancel();}
		isVisible = object.funni = false;
		object.alpha = 0;
		try{
			Main.funniSprite.removeChild(object);}catch(e){}
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
		if(!FlxG.save.data.doCoolLoading)
			try{
				tween = FlxTween.tween(object,{alpha:0},0.4,{onComplete:function(_){Main.funniSprite.removeChild(object);}});
			}catch(e){
				object.alpha = 0;
			}
		
	}

	@:keep inline static public function loadAndSwitchState(target:flixel.FlxState, stopMusic = false)
	{
		LoadingScreen.show();
		if (stopMusic && FlxG.sound.music != null){
			if(SickMenuState.chgTime){
				SickMenuState.curSongTime = FlxG.sound.music.time;
				SickMenuState.chgTime = false;
			}
			FlxG.sound.music.stop();

		}
		FlxG.switchState(target);
	}



}
