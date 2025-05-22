package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.UncaughtErrorEvent;
import openfl.events.KeyboardEvent;

import openfl.Lib;
using StringTools;

class FuckState extends FlxUIState {

	public var err:String = "";
	public var info:String = "";
	public static var currentStateName:String = "";
	public static var FATAL:Bool = false;
	public static var forced:Bool = false;
	public static var showingError:Bool = false;
	public static var useOpenFL:Bool = false;
	public static var lastERROR = "";
	public static var allowLogWrite:Bool = true;
	public static var errorCount = 0;
	public static var quip = "";
	public static var lastState:Class<FlxState>;
	public static function generateReport(error:String = "UNKNOWN ERROR?",type:String = "CRASH"):Bool{
		var callstack = CallStack.exceptionStack(true) ?? CallStack.callStack() ?? [];
		var dateNow:String = "";
		var err = "";
		errorCount++;

		try{Overlay.debugVar="";}catch(e){}
		try{
			if(!(FlxG.state is FuckState)) lastState = Type.getClass(FlxG.state);
		}catch(e){lastState = null;}

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
					"Oh lawd it crashing",
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
					'sex pt 3: gone wrong',
					'sex pt 4: on the run',
					'sex pt 5: in hell',
					'sex pt 6: im seeing blue',
					'the stalemate button was boobytrapped',
					'mf shoulda just stayed with psych engine :sob:',
					'super engine moment',
					'Another one bites the dust',
					"https://www.youtube.com/watch?v=dQw4w9WgXcQt",
					"Dude, she's a lesbian",
					"snrk",
					"This message was brought to you by CRASH REPORT",
					"Unable to cast Dragon to Note",
					"Unable to cast Mouse to Sound",
					"Unable to cast Human to Integer",
					"Unable to cast Character to FlxColor",
					"Unable to cast File to PlayState",
					"Unable to cast Note to Character",
					"It's fine, everything is good. What do you mean this is a crash report?",
					"What're you looking at? It wasn't me",
					"Unable to cast Integer '4' to String",
					"guh",
					'BALD BALD BALD- MY EYEEEEEEESSSS'
				];
				funnyQuip = jokes[Std.int(Math.random() * jokes.length - 1) ]; // I know, this isn't FlxG.random but fuck you the game just crashed
			}catch(e){}
			err = '# Super Engine Crash Report: \n# $funnyQuip\n$error';
			if(!SELoader.exists('crashReports/')){
				SELoader.createDirectory('crashReports/');
			}
			quip = funnyQuip;

			dateNow = StringTools.replace(StringTools.replace(_date.toString(), " ", "_"), ":", ".");
			try{
				currentStateName = haxe.rtti.Rtti.getRtti(cast FlxG.state).path;
			}catch(e){}
			try{
				err +="\n\n # ---------- SYSTEM INFORMATION --------"
					+'\n Operating System: ${Sys.systemName()}'
					+'\n Working Path: ${SELoader.absolutePath('')}'
					+'\n Current Working Directory: ${Sys.getCwd()}'
					+'\n Executable path: ${Sys.programPath()}'
					+'\n Arguments: ${Sys.args()}'
					+"\n # ---------- GAME INFORMATION ----------"
					+'\n Fatal, forced, Shown thru OpenFL, errorCount: ${FATAL}, ${forced}, ${useOpenFL}, ${errorCount}'
					+'\n Callstack: ${CallStack.toString(callstack)}'
					+'\n Version: ${MainMenuState.ver}'
					+'\n Buildtype: ${MainMenuState.compileType}'
					+'\n Debug: ${SESave.data.animDebug}'
					+'\n Registered character count: ${TitleState.characters.length}'
					+'\n Scripts: ${SESave.data.scripts}'
					+'\n State: ${currentStateName}'
					+'\n # --------------------------------------';
				
			}catch(e){
				trace('Unable to get system information! ${e.message}');
			}
			try{
				SELoader.saveContent('crashReports/SUPERENGINE_${type}-${dateNow}.log',err);
			}catch(e){
				sys.io.File.saveContent('crashReports/SUPERENGINE_${type}-${dateNow}.log',err);

			}
			
			
			trace('Wrote a crash report to ./crashReports/SUPERENGINE_${type}-${dateNow}.log!');
			trace('Crash Report:\n$err');
			return true;
		}catch(e){
			trace('Unable to write a crash report!');
			if(err != null && err.indexOf('SYSTEM INFORMATION') != -1){
				trace('Here is generated crash report:\n$err');

			}
		}
		return false;
	}
	// This function has a lot of try statements.
	// The game just crashed, we need as many failsafes as possible to prevent the game from closing or crash looping
	@:keep inline public static function FUCK(e:Dynamic,?info:String = "unknown",_forced:Bool = false,_FATAL:Bool = false,_rawError:Bool=false){
		if(e is FakeException) return;
		LoadingScreen.forceHide();
		LoadingScreen.loadingText = 'ERROR!';
		if(forced && !_forced && !_FATAL) return;
		if(_forced) forced = _forced;
		if(_FATAL){
			forced = true;
			FATAL=true;
		}
		var _stack:String = "";
		try{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);

			var errMsg:String = "";
			if(callStack.length > 0){
				_stack+='\nhaxe Stack:\n${CallStack.toString(callStack)}';
			}
		}catch(e){}
		var exception = "Unable to grab exception!";
		if(e != null && e.message != null){
			try{
				exception = 'Message:${e.message}\nStack:${e.stack}\nDetails: ${e.details()}';
			}catch(_e){
				try{
					exception = '${e.details()}';
				}catch(_e){
					try{
						exception = '${e.message}\n${e.stack}';
					}catch(_e){
						try{
							exception = '${e}';
						}catch(e){
							exception = 'I tried to grab the exception but got another exception, ${e}';
						}
					}
				}
			}
		}else{
			try{
				exception = '${e}';
			}catch(e){}
		}
		var saved = false;
		var err = "";
		exception += _stack;

		// Crash log 
		if(lastERROR != exception && allowLogWrite){
			lastERROR = exception;

			saved = generateReport('${exception}\nThis happened in ${info}','CRASH');

		}

		exception='# $quip\n\n$exception';
		Main.renderLock.release();
		if(Main.game == null || _rawError || !TitleState.initialized || useOpenFL){
			// trace(Main.game == null);
			// trace(_rawError);
			// trace(!TitleState.initialized);
			// trace(useOpenFL);
			try{Main.instance.removeChild(Main.funniSprite);}catch(e){};
			try{Main.funniSprite.removeChild(Main.game);}catch(e){};
			if(Main.game != null){
				Main.game.blockUpdate = Main.game.blockDraw = true;
			}
			Main.game = null;
			// Main.instance
			// trace('OpenFL error screen');

			try{
				if(!showingError){

					var addChild=Main.instance.addChild;
					showingError = true;
					var textField = new TextField();
					addChild(textField);
					textField.width = 1280;
					textField.text = '${exception}\nThis happened in ${info}';
					textField.y = 720 * 0.3;
					var textFieldTop = new TextField();
					addChild(textFieldTop);
					textFieldTop.width = 1280;
					textFieldTop.text = "An unrecoverable fatal error occurred!";
					textFieldTop.textColor = 0xFFFF0000;
					textFieldTop.y = 30;
					var textFieldBot = new TextField();
					addChild(textFieldBot);
					textFieldBot.width = 1280;
					textFieldBot.text = "Please take a screenshot and report this.\nPress enter or escape to close";
					textFieldBot.y = 720 * 0.8;
					if(saved){
						var dateNow:String = StringTools.replace(StringTools.replace(Date.now().toString(), " ", "_"), ":", ".");
						textFieldBot.text = 'Saved crashreport to "crashReports/SUPERENGINE_CRASH-${dateNow}.log".\nPlease send this file when reporting this crash.';
					}

					// textField.x = (1280 * 0.5);
					var tf = new TextFormat(CoolUtil.font, 24, 0xFFFFFF);
					tf.align = "center";
					textFieldBot.embedFonts = textFieldTop.embedFonts = textField.embedFonts = true;
					textFieldBot.defaultTextFormat =textFieldTop.defaultTextFormat =textField.defaultTextFormat = tf;
					allowLogWrite = false;

					FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, OPENFLKEYPRESS);
				}

				// Main.instance.addChild(new se.ErrorSprite('${exception}\nThis happened in ${info}',saved));
			}catch(e){trace('FUCK $e');}
			return;
		}

		

		// try{LoadingScreen.hide();}catch(e){}
		Main.game.forceStateSwitch(new FuckState(exception,info,saved));
	}
	public static function FUCK_OPENFL(E:UncaughtErrorEvent){
		FUCK(E);
	}
	public static function OPENFLKEYPRESS(E:KeyboardEvent){
		if(E.keyCode == 13 || E.keyCode==27) Sys.exit(-1);
	}
	public static function hook(){
		// trace('Enabling standard uncaught error handler...');
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, FUCK_OPENFL);

		#if cpp
		// trace('Enabling C++ critical error handler...');
		untyped __global__.__hxcpp_set_critical_error_handler(FUCK);
		#end
	}
	var saved:Bool = false;
	override function new(e:String,info:String,saved:Bool = false){
		err = '${e}\nThis happened in ${info}';
		this.saved = saved;
		// LoadingScreen.hide();
		LoadingScreen.canShow = false;
		LoadingScreen.forceHide();
		try{
			LoadingScreen.object.alpha=0;
		}catch(e){}
		super();
	}
	override function create() {
		super.create();
		LoadingScreen.forceHide();
		try{

		final bg:FlxSprite = SELoader.loadFlxSprite(0,0,"./assets/images/crash.png");
		bg.screenCenter();
		add(bg);
		}catch(e){}
		
		final header:FlxText = new FlxText(0, FlxG.height * 0.05, 0,((FATAL) ? 'Fatal' : 'Potentially recoverable') + ' error caught' , 32);

		header.screenCenter(flixel.util.FlxAxes.X);
		add(header);
		trace("-------------------------\nERROR:\n\n" + err + "\n\n-------------------------");
		var txt:FlxText = new FlxText(40, 125, FlxG.width - 60,
			"# Error/Stack:\n\n"
			+ err,
			18);
		
		txt.setFormat(CoolUtil.font, 18, 0xFFFFFFee, LEFT, NONE);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 2;
		txt.borderStyle = NONE;
		// txt.screenCenter();
		add(txt);

		txt = new FlxText(50, 640, 1000,
			"Please take a screenshot and report this\n" +((FATAL) ? "" : (lastState != null ? " Press R to reload the last state\n P" : " P") + "ress ENTER to attempt to return to the main menu\n")+ " Press ESCAPE to close the game",32);

		txt.setFormat(CoolUtil.font, 16, 0xFFFFaaaa, LEFT, NONE);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 2;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		// txt.screenCenter(X);
		add(txt);
		if(saved) {
			txt.y -= 30;
			var dateNow:String = Date.now().toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", ".");
			txt.text = 'Crash report saved to "crashReports/SUPERENGINE_CRASH-${dateNow}.log".\nPlease send this file when reporting this crash.\n' + txt.text.substring(41);
		}
		useOpenFL = true;
		try{
			SELoader.cache.clear();
		}catch(e){}
	}

	override function update(elapsed:Float) { try{
			if(!FATAL){
				if (FlxG.keys.justPressed.R && lastState != null) {
					forced = false;
					LoadingScreen.canShow = true;
					LoadingScreen.show();
					// TitleState.initialized = false;
					// MainMenuState.firstStart = true;
					useOpenFL = false;
					errorCount=0;
					FlxG.switchState(Type.createInstance(lastState, []));
					return;
				}
				if (FlxG.keys.justPressed.ENTER) {
					// var _main = Main.instance;
					forced = false;
					LoadingScreen.canShow = true;
					LoadingScreen.show();
					// TitleState.initialized = false;
					MainMenuState.firstStart = true;
					FlxG.switchState(new MainMenuState());
					useOpenFL = false;
					errorCount=0;
					return;
				}
			}
			if (FlxG.keys.justPressed.ESCAPE){
				trace('Exit requested!');
				Sys.exit(1);
				useOpenFL = false;
			}

			if (LoadingScreen.isVisible){
				LoadingScreen.forceHide(); // Hide you fucking piece of shit
				LoadingScreen.object.alpha = 0;
				LoadingScreen.isVisible = false;
				LoadingScreen.canShow = false;
			} 
		}catch(e){}
		super.update(elapsed);
	}
}
