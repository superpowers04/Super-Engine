package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.addons.ui.FlxUIState;
import lime.app.Application as LimeApp;

import openfl.Lib;

class FuckState extends FlxUIState
{

	// public static var needVer:String = "Unknown";
	// public static var currChanges:String = "Check for Updates needs to be enabled in Options > Misc!";
	public var err:String = "";
	public var info:String = "";

	public static function FUCK(e:haxe.Exception,?info:String = "unknown"){
		try{LoadingScreen.hide();}catch(e){}
		var exception = "Unable to grab exception!";
		if(e != null && e.message != null){

			try{
				exception = '${e.message}\n${e.stack}';
			}catch(e){exception = 'I tried to grab the exception but got another exception, ${e}';}
		}
		Main.game.forceStateSwitch(new FuckState(exception,info));
	}
	override function new(e:String,info:String){
		err = '${e}\nThis happened in ${info}';
		super();
	}
	override function create()
	{
		super.create();
		LoadingScreen.forceHide();
		// var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(if(Math.random() > 0.5) 'week54prototype' else "zzzzzzzz", 'shared'));
		// bg.scale.x *= 1.55;
		// bg.scale.y *= 1.55;
		// bg.screenCenter();
		// add(bg);
		
		// var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		// kadeLogo.scale.y = 0.3;
		// kadeLogo.scale.x = 0.3;
		// kadeLogo.x -= kadeLogo.frameHeight;
		// kadeLogo.y -= 180;
		// kadeLogo.alpha = 0.8;
		// add(kadeLogo);
		var outdatedLMAO:FlxText = new FlxText(0, FlxG.height * 0.05, 0,'Potentially fatal error caught' , 32);
		outdatedLMAO.setFormat(CoolUtil.font, 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		outdatedLMAO.scrollFactor.set();
		outdatedLMAO.screenCenter(flixel.util.FlxAxes.X);
		add(outdatedLMAO);
		trace("-------------------------\nERROR:\n\n"
			+ err + "\n\n-------------------------");
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"\n\nError/Stack:\n\n"
			+ err,
			16);
		
		txt.setFormat(CoolUtil.font, 16, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Please take a screenshot and report this, Press enter to attempt to soft-restart the game or press Escape to close the game",32);
		
		txt.setFormat(CoolUtil.font, 16, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter(X);
		txt.y = 680;
		add(txt);
		
	}

	override function update(elapsed:Float)
	{	
		try{

		if (FlxG.keys.justPressed.ENTER)
		{
			// var _main = Main.instance;
			LoadingScreen.show();
			// TitleState.initialized = false;
			MainMenuState.firstStart = true;
			FlxG.switchState(new TitleState());
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			Sys.exit(1);
		}
		}catch(e){}
		super.update(elapsed);
	}
}
