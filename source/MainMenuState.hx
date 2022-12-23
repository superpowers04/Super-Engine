package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import sys.io.File;
import ScriptableState;

// For Title Screen GF
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxBaseAnimation;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.util.FlxAxes;
import haxe.CallStack;


using StringTools;

class MainMenuState extends SickMenuState
{
	
	public static var firstStart:Bool = true;

	public static var nightly(default,never):String = "U30";
	public static var ver(default,never):String = "1.0.0" + (if(nightly != "") "-" + nightly else "");

	public static var compileType(default,never):String =
	#if ghaction
		"Github action build"
	#elseif debug
		"Manual debug build"
	#else
		"Manual build"
	#end;
	public static var buildType:String = Sys.systemName();
	public static var errorMessage:String = "";
	public static var bgcolor:Int = 0;
	public static var char:Character = null;
	static var hasWarnedInvalid:Bool = false;
	static var hasWarnedNightly:Bool = (nightly == "");
	public static var triedChar:Bool = false;
	
	public static function handleError(?exception:haxe.Exception = null,?error:String = "An error occurred",?details:String="",?forced:Bool = true):Void{
		// if (MainMenuState.errorMessage != "") return; // Prevents it from trying to switch states multiple times
		ScriptableStateManager.lastState = "";
		ScriptableStateManager.goToLastState = false;
		if(MainMenuState.errorMessage.contains(error)) return; // Prevents the same error from showing twice
		MainMenuState.errorMessage += "\n" + error;
		if(details != "") trace(details);
		if (onlinemod.OnlinePlayMenuState.socket != null){
			try{
				onlinemod.OnlinePlayMenuState.socket.close();
				onlinemod.OnlinePlayMenuState.socket=null;
				QuickOptionsSubState.setSetting("Song hscripts",true);
			}catch(e){trace('You just got an exception in yo exception ${e.message}');}
		}
		try{
			LoadingScreen.hide();
		}catch(e){
			trace("Unable to hide loading screen, forcing it hidden");
		}
		if(exception != null){
			try{
				trace('${exception.message}\n${exception.stack}');
			}catch(e){}
		}

		try{
			LoadingScreen.object.alpha = 0;
			
		}catch(e){
			trace("bruhh");
		}
		if(forced)
			Main.game.forceStateSwitch(new MainMenuState());
		else
			FlxG.switchState(new MainMenuState());
		
	}
	// macro function getTime():String{
	// 	var time = Date.now();
	// 	return '${time.getDay()}/${time.getMonth}/${time.getYear() - 2000} ${time.getHours()}:${time.getMinutes()}';
	// }
	override function create()
	{
		// forceQuit = true;
		if (Main.errorMessage != ""){
			errorMessage = Main.errorMessage;
			Main.errorMessage = "";
			trace(errorMessage);
		}
		mmSwitch(false);

		persistentUpdate = persistentDraw = true;
		bgImage = 'menuDesat';
		controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		loading = false;
		isMainMenu = true;
		super.create();
		if(MainMenuState.errorMessage == "" && ScriptableStateManager.goToLastState && ScriptableStateManager.lastState != ""){
			SelectScriptableState.selectState(ScriptableStateManager.lastState);
		}
		bg.scrollFactor.set(0.1,0.1);
		bg.color = MainMenuState.bgcolor;
		if (onlinemod.OnlinePlayMenuState.socket != null){
			try{
				QuickOptionsSubState.setSetting("Song hscripts",true);
				onlinemod.OnlinePlayMenuState.socket.close();
				onlinemod.OnlinePlayMenuState.socket=null;
			}catch(e){trace('Error closing socket? ${e.message}');}
		}

		if (TitleState.outdated){

			var outdatedLMAO:FlxText = new FlxText(0, FlxG.height * 0.05, 0,(if(nightly == "") 'SE is outdated, Latest: ${TitleState.updatedVer}, Check Changelog for more info' else 'Latest nightly: ${TitleState.updatedVer}. You are on ${ver}'), 32);
			outdatedLMAO.setFormat(CoolUtil.font, 32, if(nightly == "") FlxColor.RED else FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			outdatedLMAO.scrollFactor.set();
 			outdatedLMAO.screenCenter(FlxAxes.X);
			add(outdatedLMAO);
		}
		//  Whole bunch of checks to prevent crashing
		if (TitleState.retChar(FlxG.save.data.playerChar) == "" && FlxG.save.data.playerChar != "automatic"){
			errorMessage += '\n${FlxG.save.data.playerChar} is an invalid player! Reset back to BF!';
			FlxG.save.data.playerChar = "bf";
		}
		if (TitleState.retChar(FlxG.save.data.opponent) == null){
			errorMessage += '\n${FlxG.save.data.opponent} is an invalid opponent! Reset back to BF!';
			FlxG.save.data.opponent = "bf";
		}
		if (TitleState.retChar(FlxG.save.data.gfChar) == null){
			errorMessage += '\n${FlxG.save.data.gfChar} is an invalid GF! Reset back to GF!';
			FlxG.save.data.gfChar = "gf";
		}
		// if(MainMenuState.errorMessage == "" && !triedChar && FlxG.save.data.mainMenuChar && !FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.SHIFT){
		// 	triedChar = true;
		// 	try{
		// 		char = new Character(FlxG.width * 0.55,FlxG.height * 0.10,FlxG.save.data.playerChar,true,0,true);
		// 		if(char != null) add(char);
		// 	}catch(e){MainMenuState.lastStack = e.stack;trace(e);char = null;}
		// }
		if(firstStart){
			// FlxG.sound.volumeHandler = function(volume:Float){
			// 	FlxG.save.data.masterVol = volume;
			// 	FlxG.save.data.flush();
			// };
			FlxG.camera.scroll.y -= 100;
			FlxTween.tween(FlxG.camera.scroll,{y:0},1,{ease:FlxEase.cubeOut});
			firstStart = false;
		}


		if (MainMenuState.errorMessage == "" && TitleState.invalidCharacters.length > 0 && !hasWarnedInvalid) {
			errorMessage += "You have some characters missing config.json files.";
			hasWarnedInvalid = true;
		} 
		if (!hasWarnedNightly) {
			errorMessage += "This is a nightly build for " + ver.substring(0,ver.length - (1 + nightly.length) ) +", expect bugs and things changing without warning!\nBasing a fork off of this is not advised!";
			// ver+=nightly;
			hasWarnedNightly = true;
		} 

		var versionShit:FlxText = new FlxText(5, FlxG.height - 50, 0, 'FNF 0.2.7.1/Kade 1.5.2/Super-Engine ${ver} ${buildType} ${compileType}', 12);
		versionShit.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 2;
		versionShit.scrollFactor.set();
		add(versionShit);
		if (MainMenuState.errorMessage != ""){

			FlxG.sound.play(Paths.sound('cancelMenu'));

			var errorText =  new FlxText(2, 64, 0, MainMenuState.errorMessage, 12);
		    errorText.scrollFactor.set();
		    errorText.wordWrap = true;
		    errorText.fieldWidth = 1200;
		    errorText.setFormat(CoolUtil.font, 32, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    add(errorText);
		}
		FlxG.bitmap.clearCache();
		eventColors(Date.now());
	}

	public function eventColors(date:Date){
		if(date.getMonth() == 11){

			var _d = date.getDate();
			if(_d > 19 && _d < 26){
				bg.color = 0xaa3333;
				FlxTween.cancelTweensOf(bg);
				FlxTween.color(bg,10,FlxColor.fromString("#aa3333"),FlxColor.fromString("#33aa33"),{type:FlxTweenType.PINGPONG});
			}
			return;
		}
	}

	override function goBack(){
		if (otherMenu) {mmSwitch(true);FlxG.sound.play(Paths.sound('cancelMenu'));return;} else{selected = false;}
		// FlxG.switchState(new TitleState());
		// do nothing
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		// if(char != null){
		// 	if(controls.LEFT){
		// 		char.playAnim("singLEFT",true);
		// 	}else if(controls.RIGHT){
		// 		char.playAnim("singRIGHT",true);
		// 	}
		// }
		super.update(elapsed);
	}
	override function beatHit()
	{
		super.beatHit();
		// if(char != null && char.animation.curAnim.finished) char.dance(true);
	}
	override function changeSelection(change:Int = 0){
		// if(char != null && change != 0) char.playAnim(Note.noteAnims[if(change > 0)1 else 2],true);
		if(MainMenuState.errorMessage != "")MainMenuState.errorMessage = "";
		super.changeSelection(change);
	}

	var otherMenu:Bool = false;

	function otherSwitch(){
		options = ["freeplay","download charts","download characters"];
		descriptions = ['Play any song from the main game or your assets folder',"Download charts made for or ported to Super Engine","Download characters made for or ported to Super Engine"];
		
		if (TitleState.osuBeatmapLoc != '') {options.push("osu beatmaps"); descriptions.push("Play osu beatmaps converted over to FNF");}
		options.push("back"); descriptions.push("Go back to the main menu");
		generateList();
		curSelected = 0;
		otherMenu = true;
		selected = false;
		changeSelection();
	}
	function mmSwitch(regen:Bool = false){
		options = ['modded songs','join BR compatible server',
		#if !ghaction
			'host br server',
		#end
			'online songs',"story mode",'other',"import charts from mods", "scripted states","changelog", 'options'];
		descriptions = ["Play songs from your mods/charts folder, packs or weeks","Join and play online with other people on a Battle Royale compatible server.",
		#if !ghaction
		'Host a server so people can join locally, via ngrok or from your IP using portforwarding',
		#end
		"Play songs that have been downloaded during online games.","Play a vanilla or custom week",'Freeplay, Osu beatmaps, and download characters or songs','Convert charts from other mods to work here. Will put them in Modded Songs',"Run a script in a completely scriptable blank state","Check the latest update and it's changes",'Customise your experience to fit you'];
		if(regen)generateList();
		curSelected = 0;
		if(regen)changeSelection();
		selected = false;
		otherMenu = false;

	}

  override function select(sel:Int){
		MainMenuState.errorMessage="";
		if (selected){return;}
		// if(char != null) {char.playAnimAvailable(["win","singUP"],true);}
		selected = true;
		var daChoice:String = options[sel];
		FlxG.sound.play(Paths.sound('confirmMenu'));
		triedChar = false;
		if(daChoice != "other" && daChoice != 'back'){
			FlxTween.tween(grpControls.members[sel],{x:500},0.4,{ease:FlxEase.quadIn});
		}
		
		switch (daChoice)
		{
			case 'other':
				// FlxG.switchState(new OtherMenuState());
				otherSwitch();
			case 'join BR compatible server':
				FlxG.switchState(new onlinemod.OnlinePlayMenuState());
			#if !ghaction
			// Unstable,this'll be removed when I actually make it work
			case 'host br server':
				FlxG.switchState(new onlinemod.OnlineHostMenu());
			#end
			case 'modded songs':
				loading = true;
				FlxG.switchState(new multi.MultiMenuState());
			case 'online songs':
				loading = true;
				FlxG.switchState(new onlinemod.OfflineMenuState());
			case 'changelog':
				FlxG.switchState(new OutdatedSubState());
			case 'options':
				FlxG.switchState(new OptionsMenu());
			// case "Setup characters":
			// 	FlxG.switchState(new SetupCharactersList());
			
			case "scripted states":
				FlxG.switchState(new SelectScriptableState());
			case "download charts":
				FlxG.switchState(new ChartRepoState());
			case 'story mode':
				loading = true;
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				loading = true;
				FlxG.switchState(new FreeplayState());
			case 'osu beatmaps':
				loading = true;
				FlxG.switchState(new osu.OsuMenuState());
			case "import charts from mods":
				FlxG.switchState(new ImportMod());
			case 'download characters':
				FlxG.switchState(new RepoState());
			
			case "back":
				mmSwitch(true);
		}
	}
}
