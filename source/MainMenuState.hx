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

// For Title Screen GF
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxBaseAnimation;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.util.FlxAxes;


using StringTools;

class MainMenuState extends SickMenuState
{
	public static var ver:String = "0.11.0";
	
	public static var firstStart:Bool = true;

	public static var nightly:String = "N8";

	public static var kadeEngineVer:String = "1.5.2";
	public static var gameVer:String = "0.2.7.1";
	public static var errorMessage:String = "";
	public static var bgcolor:Int = 0;
	var char:Character = null;
	static var hasWarnedInvalid:Bool = false;
	static var hasWarnedNightly:Bool = (nightly == "");
	
	public static function handleError(?error:String = "An error occurred",?details:String="",?forced:Bool = true):Void{
		// if (MainMenuState.errorMessage != "") return; // Prevents it from trying to switch states multiple times
		if(MainMenuState.errorMessage.contains(error)) return; // Prevents the same error from showing twice
		MainMenuState.errorMessage += "\n" + error;
		if(details != "") trace(details);
		if (onlinemod.OnlinePlayMenuState.socket != null){
			try{
				onlinemod.OnlinePlayMenuState.socket.close();
				onlinemod.OnlinePlayMenuState.socket=null;
			}catch(e){trace('You just got an exception in yo exception ${e.message}');}
		}

		if(forced)
			Main.game.forceStateSwitch(new MainMenuState());
		else
			FlxG.switchState(new MainMenuState());
		
	}

	override function create()
	{
		if (Main.errorMessage != ""){
			errorMessage = Main.errorMessage;
			Main.errorMessage = "";
		}
		mmSwitch(false);
		trace(errorMessage);

		persistentUpdate = persistentDraw = true;
		bgImage = 'menuDesat';
		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);
		isMainMenu = true;
		super.create();

		bg.scrollFactor.set(0.1,0.1);
		bg.color = MainMenuState.bgcolor;


		if (TitleState.outdated){

			var outdatedLMAO:FlxText = new FlxText(0, FlxG.height * 0.05, 0,(if(nightly == "") 'SE is outdated, Latest: ${TitleState.updatedVer}, Check Changelog for more info' else 'Latest nightly: ${TitleState.updatedVer}. You are on ${ver}'), 32);
			outdatedLMAO.setFormat(CoolUtil.font, 32, if(nightly == "") FlxColor.RED else FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			outdatedLMAO.scrollFactor.set();
 			outdatedLMAO.screenCenter(FlxAxes.X);
			add(outdatedLMAO);
		}
		//  Whole bunch of checks to prevent crashing
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.playerChar) && FlxG.save.data.playerChar != "automatic"){
			errorMessage += '\n${FlxG.save.data.playerChar} is an invalid player! Reset back to BF!';
			FlxG.save.data.playerChar = "bf";
		}
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.opponent)){
			errorMessage += '\n${FlxG.save.data.opponent} is an invalid opponent! Reset back to BF!';
			FlxG.save.data.opponent = "bf";
		}
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.gfChar)){
			errorMessage += '\n${FlxG.save.data.gfChar} is an invalid GF! Reset back to GF!';
			FlxG.save.data.gfChar = "gf";
		}
		// if(FlxG.save.data.mainMenuChar && MainMenuState.errorMessage == "" && !FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.SHIFT){
		// 	try{
		// 		char = new Character(FlxG.width * 0.55,FlxG.height * 0.10,FlxG.save.data.playerChar,true,0,true);
		// 		if(char != null) add(char);
		// 	}catch(e){trace(e);char = null;}
		// }
		if(firstStart){
			// FlxG.sound.volumeHandler = function(volume:Float){
			// 	FlxG.save.data.masterVol = volume;
			// 	FlxG.save.data.flush();
			// };
			firstStart = false;
		}


		if (MainMenuState.errorMessage == "" && TitleState.invalidCharacters.length > 0 && !hasWarnedInvalid) {
			errorMessage = "You have some characters missing config.json files.";
			hasWarnedInvalid = true;
		} 
		if (!hasWarnedNightly) {
			errorMessage = "This is a nightly build for " + ver.substring(0,ver.length - nightly.length) +", expect bugs and things changing without warning!\nBasing a fork off of this is not advised!";
			// ver+=nightly;
			hasWarnedNightly = true;
		} 


		var versionShit:FlxText = new FlxText(5, FlxG.height - 50, 0, 'FNF ${gameVer}/Kade ${kadeEngineVer}/Super-Engine ${ver}', 12);
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
		
	}

	override function goBack(){
		if (otherMenu) {mmSwitch(true);FlxG.sound.play(Paths.sound('cancelMenu'));return;}
		// FlxG.switchState(new TitleState());
		// do nothing
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		super.update(elapsed);
	}
	override function beatHit(){
		super.beatHit();
		// if(char != null && char.animation.curAnim.finished) char.dance(true);
	}
	override function changeSelection(change:Int = 0){
		if(char != null && change != 0) char.playAnim(Note.noteAnims[FlxG.random.int(0,3)],true);
		
		super.changeSelection(change);
	}

	var otherMenu:Bool = false;

	function otherSwitch(){
		options = ["story mode","freeplay","Convert Charts from other mods","download charts","download characters"];
		descriptions = ['Play through the story mode', 'Play any song from the game', 'Convert charts from other mods to work here. Will put them in Multi Songs, will not be converted to work with FNF Multiplayer though.',"Download charts made for or ported to Super Engine","Download characters made for or ported to Super Engine"];
		if (TitleState.osuBeatmapLoc != '') {options.push("osu beatmaps"); descriptions.push("Play osu beatmaps converted over to FNF");}
		options.push("back"); descriptions.push("Go back to the main menu");
		generateList();
		curSelected = 0;
		otherMenu = true;
		selected = false;
		changeSelection();
	}
	function mmSwitch(regen:Bool = false){
		options = ['modded songs','online', 'online songs','other',"changelog", 'options'];
		descriptions = ["Play songs from your mods/charts folder","Play online with other people.","Play songs that have been downloaded during online games.",'Story mode, Freeplay, Osu beatmaps, and download characters or songs',"Check the latest update and it's changes",'Customise your experience to fit you'];
		if(regen)generateList();
		curSelected = 0;
		if(regen)changeSelection();
		selected = false;
		otherMenu = false;

	}

  override function select(sel:Int){
		MainMenuState.errorMessage="";
		if (selected){return;}
		// if(char != null) {char.playAnim("hey",true);char.playAnim("win",true);}
		selected = true;
		var daChoice:String = options[sel];
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		switch (daChoice)
		{
			case 'other':
				// FlxG.switchState(new OtherMenuState());
				otherSwitch();
			case 'online':
				FlxG.switchState(new onlinemod.OnlinePlayMenuState());
			case 'modded songs':
				FlxG.switchState(new multi.MultiMenuState());
			case 'online songs':
				FlxG.switchState(new onlinemod.OfflineMenuState());
			case 'changelog':
				FlxG.switchState(new OutdatedSubState());
			case 'options':
				FlxG.switchState(new OptionsMenu());
			// case "Setup characters":
			// 	FlxG.switchState(new SetupCharactersList());

			case "download charts":
				FlxG.switchState(new ChartRepoState());
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'osu beatmaps':
				FlxG.switchState(new osu.OsuMenuState());
			case "Convert Charts from other mods":
				FlxG.switchState(new ImportMod());
			case 'download characters':
				FlxG.switchState(new RepoState());
			
			case "back":
				mmSwitch(true);
		}
	}
}
