package;

import Controls.KeyboardScheme;
import flixel.FlxG;
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
	public static var ver:String = "0.5.2";
	
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.2";
	public static var gameVer:String = "0.2.7.1";
	public static var errorMessage:String = "";
	public static var bgcolor:Int = 0;
	public static function handleError(?error:String = "An error occurred",?details:String=""):Void{
		if (errorMessage != "") return; // Prevents it from trying to switch states multiple times
		MainMenuState.errorMessage = error;
		if(details != "") trace(details);
		if (onlinemod.OnlinePlayMenuState.socket != null){
			try{
				onlinemod.OnlinePlayMenuState.socket.close();
				onlinemod.OnlinePlayMenuState.socket=null;
			}catch(e){trace('You just got an exception in yo exception ${e.message}');}
		}
		FlxG.switchState(new MainMenuState());
		
	}

	override function create()
	{
		if (Main.errorMessage != ""){
			errorMessage = Main.errorMessage;
			Main.errorMessage = "";
		}
		options = ['online', 'downloaded songs','modded songs','other',"changelog",'get characters', 'options'];
		descriptions = ["Play online with other people.","Play songs that have been downloaded during online games.","Play Funkin Multi format songs locally",'Other playing modes',"Check the latest update and it's changes","Download characters to play as ingame",'Customise your experience to fit you'];
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
		var versionShit:FlxText = new FlxText(5, FlxG.height - 36, 0, 'FNF ${gameVer}/Kade ${kadeEngineVer}/Super-BR ${ver}', 12);
		versionShit.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();
		add(versionShit);

		if (TitleState.outdated){
			var outdatedLMAO:FlxText = new FlxText(0, FlxG.height * 0.05, 0,'FNFBR is outdated, Latest: ${TitleState.updatedVer}, Check Changelog for more info', 32);
			outdatedLMAO.setFormat(CoolUtil.font, 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
			errorMessage += '\n${FlxG.save.data.opponent} is an invalid opponent! Reset back to Dad!';
			FlxG.save.data.opponent = "dad";
		}
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.gfChar)){
			errorMessage += '\n${FlxG.save.data.gfChar} is an invalid GF! Reset back to GF!';
			FlxG.save.data.gfChar = "gf";
		}
		if (MainMenuState.errorMessage != ""){

			FlxG.sound.play(Paths.sound('cancelMenu'));

			var errorText =  new FlxText(2, 64, 0, MainMenuState.errorMessage, 12);
		    errorText.scrollFactor.set();
		    errorText.wordWrap = true;
		    errorText.fieldWidth = 1200;
		    errorText.setFormat(CoolUtil.font, 32, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    add(errorText);
		    MainMenuState.errorMessage="";
		}

		
	}

	override function goBack(){
		FlxG.switchState(new TitleState());
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		super.update(elapsed);
	}
	
  override function select(sel:Int){
  	    if (selected){return;}
    	selected = true;
		var daChoice:String = options[sel];
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		switch (daChoice)
		{
			case 'other':
				FlxG.switchState(new OtherMenuState());
			case 'online':
				FlxG.switchState(new onlinemod.OnlinePlayMenuState());
			case 'modded songs':
				FlxG.switchState(new multi.MultiMenuState());
			case 'downloaded songs':
				FlxG.switchState(new onlinemod.OfflineMenuState());
			case 'get characters':
				FlxG.switchState(new RepoState());
			case 'changelog':
				FlxG.switchState(new OutdatedSubState());
			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}
}
