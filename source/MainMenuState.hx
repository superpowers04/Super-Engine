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
	public static var ver:String = "0.1.0";
	
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.2" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var errorMessage:String = "";
	public static function handleError(error:String):Void{
		MainMenuState.errorMessage = error;
		try{if (onlinemod.OnlinePlayMenuState.socket != null){onlinemod.OnlinePlayMenuState.socket.close();}}catch(e){trace('You just got an exception in yo exception ${e.message}');}
		
		FlxG.switchState(new MainMenuState());
	}
	// var danceLeft:Bool=false;
	// var gfDance:FlxSprite;

	override function create()
	{
		options = ['online', 'downloaded songs','modded songs','get characters','story mode', 'freeplay', 'options'];
		descriptions = ["Play online with other people.","Play songs that have been downloaded during online games.","Play Funkin Multi format songs locally","Download characters to play as ingame",'Play through the story mode', 'Play any song from the game',  'Customise your experience to fit you'];
		trace(errorMessage);

		persistentUpdate = persistentDraw = true;
		bgImage = 'menuBG';
		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		super.create();

		var versionShit:FlxText = new FlxText(5, FlxG.height - 36, 0, 'FNF ${gameVer}/Kade ${kadeEngineVer}/FNFBR ${ver}', 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();
		add(versionShit);

		if (TitleState.outdated){
			var outdatedLMAO:FlxText = new FlxText(0, FlxG.height * 0.05, 0,'FNFBR is outdated, Latest: ${TitleState.updatedVer}', 32);
			outdatedLMAO.setFormat("VCR OSD Mono", 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

			var errorText =  new FlxText(2, 48, 0, MainMenuState.errorMessage, 12);
		    errorText.scrollFactor.set();
		    errorText.wordWrap = true;
		    errorText.fieldWidth = 1200;
		    errorText.setFormat("VCR OSD Mono", 32, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    add(errorText);
		    MainMenuState.errorMessage="";
		}

		// if(!FlxG.save.data.preformance && FileSystem.exists(Sys.getCwd() + "mods/characters/"+FlxG.save.data.gfChar+"/character.png")){ // Gf on main menu because yes
		// 	try{
		// 		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		// 		var curCharacter:String = FlxG.save.data.gfChar;
		// 		gfDance.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$curCharacter/character.png')), File.getContent('mods/characters/$curCharacter/character.xml'));
		// 		var charPropJson:String = File.getContent('mods/characters/$curCharacter/config.json');
		// 		var charProperties:CharacterJson = haxe.Json.parse(charPropJson);
		// 		gfDance.antialiasing = !charProperties.no_antialiasing;
		// 		gfDance.setGraphicSize(Std.int(gfDance.width * charProperties.scale));
		// 		gfDance.updateHitbox();

		// 		for (anima in charProperties.animations){
		// 			if (anima.indices.length > 0) { // Add using indices if specified
		// 				gfDance.animation.addByIndices(anima.anim, anima.name,anima.indices,"", anima.fps, anima.loop);
		// 			}else{gfDance.animation.addByPrefix(anima.anim, anima.name, anima.fps, anima.loop);}
		// 		}
		// 		add(gfDance);

		// 	}
		// }
		// changeItem();

		
	}
	// override function beatHit()
	// {
	// 	super.beatHit();
	// 	if (gfDance != null){
	// 		danceLeft = !danceLeft;
	
	// 		if (danceLeft)
	// 			gfDance.animation.play('danceRight');
	// 		else
	// 			gfDance.animation.play('danceLeft');
	// 	}
	// }

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
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");
			case 'online':
				FlxG.switchState(new onlinemod.OnlinePlayMenuState());
			case 'modded songs':
				FlxG.switchState(new multi.MultiMenuState());
			case 'downloaded songs':
				FlxG.switchState(new onlinemod.OfflineMenuState());
			case 'get characters':
				FlxG.switchState(new RepoState());

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}
}
