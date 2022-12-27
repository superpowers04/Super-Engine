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
	public var currentStateName:String = "";
	public static var jokes:Array<String> = [
		"Hey look, mom! I'm on a crash report!",
		"This wasn't supposed to go down like this...",
		"Don't look at me that way.. I tried",
		"Ow, that really hurt :(",
		"missingno",
		"Did I ask for your opinion?",
		"Oh lawd he crashing",
		"get stickbugged lmao",
		"Mom? Come pick me up. I'm scared...",
		"It's just standing there... Menacingly.",
		"Are you having fun? I'm having fun.",
		"That crash though",
		"I'm out of ideas.",
		"Where do we go from here?",
		"Coded in Haxe.",
		"Oh what the hell?",
		"I just wanted to have fun.. :(",
		"Oh no, not this again",
		"null object reference is real and haunts us",
		'What is a error exactly?',
		"I just got ratioed :(",
		"L + Ratio + Skill Issue",
		"I'm out of ideas.",
	];

	public static function FUCK(e:Dynamic,?info:String = "unknown"){
		try{LoadingScreen.hide();}catch(e){}
		var exception = "Unable to grab exception!";
		if(e != null && e.message != null){
			try{
				exception = '${e.message}\n${e.stack}';
			}catch(e){exception = 'I tried to grab the exception but got another exception, ${e}';}
		}else{
			try{

				exception = '${e}';
			}catch(e){}
		}
		var saved = false;
		// Crash log 
		try{
			var funnyQuip = "insert funny line here";
			var _date = Date.now();
			try{
				funnyQuip = jokes[Std.int(Math.random() * jokes.length - 1) ]; // I know, this isn't random but fuck you the game just crashed
			}
			var err = '# Super Engine Crash Report: \n# $funnyQuip\n${exception}\nThis happened in ${info}';
			if(!sys.FileSystem.exists('crashReports/')){
				sys.FileSystem.createDirectory('crashReports/');
			}

			var dateNow:String = _date.toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", ".");
			try{
				err += "\n\n# ---------- SYSTEM INFORMATION ----------";
				err += ''
				+'\n Operating System: ${Sys.systemName()}'
				+'\n Working Path: ${sys.FileSystem.absolutePath('./')}'
				+'\n Current Working Directory: ${Sys.getCwd()}'
				+'\n Executable path: ${Sys.programPath()}'
				+'\n Arguments: ${Sys.args()}'
				+'\n Environment: ${Sys.environment()}'
				+"\n # ---------- GAME INFORMATION ----------"
				+'\n Version: ${MainMenuState.ver}'
				+'\n Buildtype: ${MainMenuState.compileType}'
				+'\n Debug: ${FlxG.save.data.animDebug}'
				+'\n Registered character count: ${TitleState.characters.length}'
				// +'\n Registered stage count: ${TitleState.stages.length}'
				+'\n Scripts: ${FlxG.save.data.scripts}'
				+'\n State: ${TitleState.characters.length}'
				+'\n Save: ${FlxG.save.data}'
				+'\n# -------------------';
			}catch(e){}
			sys.io.File.saveContent('crashReports/SUPERENGINE_CRASH-${dateNow}.log',err);
			saved = true;
		}catch(e){} 
		Main.game.forceStateSwitch(new FuckState(exception,info,saved));
	}
	var saved:Bool = false;
	override function new(e:String,info:String,saved:Bool = false){
		err = '${e}\nThis happened in ${info}';
		this.saved = saved;
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
		if(saved){
			txt.y -= 30;
			var dateNow:String = Date.now().toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", ".");
			txt.text = 'Crash report saved to "crashReports/SUPERENGINE_CRASH-${dateNow}.log".\n Please send this file when reporting this crash. Press enter to attempt to soft-restart the game or press Escape to close the game';
		}
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
