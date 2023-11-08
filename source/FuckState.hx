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
import haxe.CallStack;

import openfl.Lib;

class FuckState extends Sprite
{

	// public static var needVer:String = "Unknown";
	// public static var currChanges:String = "Check for Updates needs to be enabled in Options > Misc!";
	public var err:String = "";
	public var info:String = "";
	public static var currentStateName:String = "";
	public static var FATAL:Bool = false;

	var _stage:Stage;
	// This function has a lot of try statements.
	// The game just crashed, we need as many failsafes as possible to prevent the game from closing or crash looping
	@:keep inline public static function FUCK(e:Dynamic,?info:String = "unknown"){
		LoadingScreen.hide();
		LoadingScreen.forceHide();
		var _stack:String = "";
		try{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);

			var errMsg:String = "";
			if(callStack.length > 0){
				_stack+='\nhaxe Stack:\n';
				for (stackItem in callStack)
				{
					switch (stackItem)
					{
						case FilePos(s, file, line, column):
							_stack += '\n$file:${line}:${column}';
						default:
							_stack += '$stackItem';
					}
				}
			}
		}catch(e){}
		var exception = "Unable to grab exception!";
		if(e != null && e.message != null){
			try{

				exception = 'Message:${e.message}\nStack:${e.stack}\nDetails: ${e.details()}';
			}catch(e){

				try{
					exception = '${e.details()}';
				}catch(e){
					try{
						exception = '${e.message}\n${e.stack}';
					}catch(e){
						exception = 'I tried to grab the exception but got another exception, ${e}';
					}
				}
			}
		}else{
			try{
				exception = '${e}';
			}catch(e){}
		}
		var saved = false;
		var dateNow:String = "";
		var err = "";
		exception += _stack;
		// Crash log 

		try{
			var funnyQuip = "insert funny line here";
			var _date = Date.now();
			try{
				var jokes = [
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
					"Now with more crashes",
					"I'm out of ideas.",
					"me when null object reference",
					'you looked at me funny :(',
					'Hey VSauce, Michael here. What is an error?',
					'AAAHHHHHHHHHHHHHH! Don\'t mind me, I\'m practicing my screaming',
					'crash% speedrun less goooo!',
					'hey look, the consequences of my actions are coming to haunt me',
					'time to go to stack overflow for a solution',
					'you\'re mother',
					'sex pt 2: electric boobaloo',
					'sex pt 3: gone wrong'
					
				];
				funnyQuip = jokes[Std.int(Math.random() * jokes.length - 1) ]; // I know, this isn't FlxG.random but fuck you the game just crashed
			}catch(e){}
			err = '# Super Engine Crash Report: \n# $funnyQuip\n${exception}\nThis happened in ${info}';
			if(!SELoader.exists('crashReports/')){
				SELoader.createDirectory('crashReports/');
			}

			dateNow = _date.toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", ".");
			try{
				currentStateName = haxe.rtti.Rtti.getRtti(cast FlxG.state).path;
			}catch(e){}
			try{
				err +="\n\n # ---------- SYSTEM INFORMATION --------";
				
				err +='\n Operating System: ${Sys.systemName()}';
				err +='\n Working Path: ${SELoader.absolutePath('')}';
				err +='\n Current Working Directory: ${Sys.getCwd()}';
				err +='\n Executable path: ${Sys.programPath()}';
				err +='\n Arguments: ${Sys.args()}';
				err +="\n # ---------- GAME INFORMATION ----------";
				err +='\n Version: ${MainMenuState.ver}';
				err +='\n Buildtype: ${MainMenuState.compileType}';
				err +='\n Debug: ${FlxG.save.data.animDebug}';
				err +='\n Registered character count: ${TitleState.characters.length}';
				err +='\n Scripts: ${FlxG.save.data.scripts}';
				err +='\n State: ${currentStateName}';
				err +='\n Save: ${FlxG.save.data}';
				err +='\n # --------------------------------------';
				
			}catch(e){
				trace('Unable to get system information! ${e.message}');
			}
			sys.io.File.saveContent('crashReports/SUPERENGINE_CRASH-${dateNow}.log',err);
			
			saved = true;
			trace('Wrote a crash report to ./crashReports/SUPERENGINE_CRASH-${dateNow}.log!');
			trace('Crash Report:\n$err');
		}catch(e){
			trace('Unable to write a crash report!');
			if(err != null && err.indexOf('SYSTEM INFORMATION') != -1){
				trace('Here is generated crash report:\n$err');

			}
		}
		try{LoadingScreen.hide();}catch(e){}
		Main.game.forceStateSwitch(new FuckState(exception,info,saved));
	}
	var saved:Bool = false;
	override function new(e:String,info:String,saved:Bool = false){
		err = '${e}\nThis happened in ${info}';
		this.saved = saved;
		this._stage = openfl.Lib.application.window.stage;
		LoadingScreen.hide();
		LoadingScreen.forceHide();
		super();
		LoadingScreen.forceHide();
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyActions);
		
		final textFormat = new TextFormat(font, 24, 0xFFFFFF);
		final centerX = 640;
		final centerY = 360;

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
		var outdatedLMAO:TextField = new TextField()
		outdatedLMAO.y = 36;
		outdatedLMAO.text = (if(FATAL) 'F' else 'Potentially f') + 'atal error caught');
		outdatedLMAO.x = centerX - (outdatedLMAO.width * 0.5);
		
		// outdatedLMAO.setFormat(CoolUtil.font, 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// outdatedLMAO.scrollFactor.set();
		// outdatedLMAO.screenCenter(flixel.util.FlxAxes.X);
		addChild(outdatedLMAO);
		trace("-------------------------\nERROR:\n\n"
			+ err + "\n\n-------------------------");
		var txt:TextField = new TextField();
		txt.text = "\n\nError/Stack:\n\n"+ err;
		txt.y = 
		// txt.setFormat(CoolUtil.font, 16, FlxColor.fromRGB(200, 200, 200), CENTER);
		// txt.borderColor = FlxColor.BLACK;
		// txt.borderSize = 3;
		// txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		// txt.screenCenter();
		addChild(txt);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Please take a screenshot and report this, " +(if(FATAL)"P" else "Press enter to attempt to return to the main menu or p")+ "ress Escape to close the game",32);
		
		// txt.setFormat(CoolUtil.font, 16, FlxColor.fromRGB(200, 200, 200), CENTER);
		// txt.borderColor = FlxColor.BLACK;
		// txt.borderSize = 3;
		// txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		// txt.screenCenter(X);
		txt.x = 
		txt.y = 680;
		addChild(txt);
		scaleX=_stage.stageWidth / 1280;
		scaleY=_stage.stageHeight / 720;
		if(saved){
			txt.y -= 30;
			var dateNow:String = Date.now().toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", ".");
			txt.text = 'Crash report saved to "crashReports/SUPERENGINE_CRASH-${dateNow}.log".\n Please send this file when reporting this crash. Press enter to attempt to soft-restart the game or press Escape to close the game';
		}
	}

	override function __enterFrame(elapsed:Float){	
		try{

			// if (FlxG.keys.justPressed.ENTER && !FATAL)
			// {
			// 	// var _main = Main.instance;
			// 	LoadingScreen.show();
			// 	// TitleState.initialized = false;
			// 	MainMenuState.firstStart = true;
			// 	FlxG.switchState(new MainMenuState());
			// }
			// if (FlxG.keys.justPressed.ESCAPE) Sys.exit(1);

			if (LoadingScreen.isVisible){
				LoadingScreen.forceHide(); // Hide you fucking piece of shit
				LoadingScreen.object.alpha = 0;
				LoadingScreen.isVisible = false;
			} 
		}catch(e){}
		super.__enterFrame(elapsed);
	}

	public function keyActions(e:KeyboardEvent):Void {
		switch e.keyCode {
			case Keyboard.ENTER:
				if(FATAL) return;
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyActions);
				// now that the crash handler should be no longer active, remove it from the game container.
				if (Main.instance != null && Main.instance.contains(this)) Main.instance.removeChild(this);
			case Keyboard.ESCAPE:
				sys.exit(1);
		}
	}
}
/* Kinda funny situation, 
	this was made by crowplexus, and it was originally inspired by the original fuck state from super engine. now I am stealing it back >:) 

class CrashHandler extends Sprite {
	final font:String = CoolUtil.font;

	var errorTitle:RotatableTextField;
	var loggedError:TextField;
	var _modReset:Bool = false;

	private static var _active:Bool = false;

	var _stage:Stage;
	var random = new flixel.math.FlxRandom();

	final imagineBeingFunny:Array<String> = [
		// crowplexus
		"Fatal Error!",
		"!rorrE lataF",
		"Enough of your puns SANS.",
		"Forever riddled with bugs.",
		"Welcome to game development!",
		"Anything wrong with your script buddy?",
		"Take a break and listen to something nice -> watch?v=Zqa2mgjbOIM",
		// Keoiki
		"I wish i was funny so i could come up with a funny",
		"Let me guess, Null Object Reference?",
		// Totally Wizard
		"Gay gay gay gay gay gay gay gay gay gay gay",
		// Ne_Eo
		"U fucking messed up, i can't believe you",
		"What are you??? A idiot program -Godot RAMsey",
		'I told you, ${DiscordWrapper.username ?? "the human"} was gonna crash the engine',
		// SrtHero278
		"GET IN THE CAR I FUCKED UP",
		"...Oh dear. Your brain       is... a                  underwhelming. ",
		// Zyfix
		"IT WAS A MISS INPUT, MISS INPUT CALM DOWN, YOU CALM THE FUCK DOWN",
		// RapperGF
		"Thats not very forever engine fnf of you.",
	];

	public function new(stack:String):Void {
		super();

		this._stage = openfl.Lib.application.window.stage;

		if (!_active)
			_active = true;

		final _matrix = new flixel.math.FlxMatrix().rotateByPositive90();

		// draw a background
		// [0.8, 0.6]
		// 0xFFA95454
		graphics.beginGradientFill(LINEAR, [0xFF000000, 0xFFA84444], [0.5, 1], [75, 255], _matrix);
		graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
		graphics.endFill();

		// -- TEXT CREATING PHASE -- //

		final tf = new TextFormat(font, 24, 0xFFFFFF);
		final tf2 = new TextFormat(font, 48, 0xDADADA);

		errorTitle = new RotatableTextField();
		loggedError = new TextField();

		// create the error title!
		errorTitle.defaultTextFormat = tf2;

		random.shuffle(imagineBeingFunny);
		// imagineBeingFunny = ["IT WAS A MISS INPUT, MISS INPUT CALM DOWN, YOU CALM THE FUCK DOWN"]; // testing long
		var quote:String = random.getObject(imagineBeingFunny);
		errorTitle.text = '${quote}\n';

		for (i in 0...quote.length)
			errorTitle.appendText('-');

		errorTitle.width = _stage.stageWidth * 0.5;
		errorTitle.x = centerX(errorTitle.width);
		errorTitle.y = _stage.stageHeight * 0.1;

		errorTitle.autoSize = CENTER;
		errorTitle.multiline = true;

		// create the error text
		loggedError.defaultTextFormat = tf;
		loggedError.text = '\n\n${stack}\n'
			+ "\nPress R to Unload your mods if needed, Press ESCAPE to Reset"
			+ "\nIf you feel like this error shouldn't have happened,"
			+ "\nPlease report it to our GitHub Page by pressing SPACE";

		// and position it properly
		loggedError.autoSize = errorTitle.autoSize;
		// loggedError.width = _stage.stageWidth;
		loggedError.y = errorTitle.y + (errorTitle.height) + 50;
		loggedError.autoSize = CENTER;

		addChild(errorTitle);
		addChild(loggedError);

		// Autosizing
		if (loggedError.width > _stage.stageWidth) {
			loggedError.scaleX = loggedError.scaleY = _stage.stageWidth / (loggedError.width + 100);
		}
		loggedError.x = centerX(loggedError.width);

		if (errorTitle.width > _stage.stageWidth) {
			errorTitle.scaleX = errorTitle.scaleY = _stage.stageWidth / (errorTitle.width + 100);
		}
		errorTitle.x = centerX(errorTitle.width);

		// Sound from codename
		final sound:Sound = AssetHelper.getAsset('audio/sfx/errorReceived', SOUND);
		final volume:Float = Tools.toFloatPercent(Settings.masterVolume);

		sound.play(new SoundTransform(volume)).addEventListener(Event.SOUND_COMPLETE, (_) -> {
			sound.close();
		});

		_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyActions);
		addEventListener(Event.ENTER_FRAME, (e) -> {
			var time = openfl.Lib.getTimer() / 1000;
			if (time - lastTime > 1 / 5) {
				if (!setupOrigin) {
					errorTitle.originX = errorTitle.width * 0.5;
					errorTitle.originY = errorTitle.height * 0.5;
					setupOrigin = true;
				}
				errorTitle.rotation = random.float(-1, 1);
				lastTime = time;
			}
		});
	}

	var lastTime = 0.0;
	var setupOrigin = false;


	inline function centerX(w:Float):Float {
		return (0.5 * (_stage.stageWidth - w));
	}
}

*/