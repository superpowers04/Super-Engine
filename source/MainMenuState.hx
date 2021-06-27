package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;


using StringTools;

class MainMenuState extends SickMenuState
{
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.2" + nightly;
	public static var gameVer:String = "0.2.7.1/0.2.8";
	public static var errorMessage:String = "";

	override function create()
	{
		options = ['online', 'downloaded songs','story mode', 'freeplay', 'options'];
		descriptions = ["Play online with other people.","Play songs that have been downloaded during online games.",'Play through the story mode', 'Play any song from the game',  'Customise your experience to fit you'];



		persistentUpdate = persistentDraw = true;
		bgImage = 'menuBG';

		var versionShit:FlxText = new FlxText(5, FlxG.height - 32, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		if (TitleState.outdated){
			var outdatedLMAO:FlxText = new FlxText(5, FlxG.height - 48, 0, 	'Kade is outdated: ${TitleState.updatedVer}', 12);
			outdatedLMAO.scrollFactor.set();
			outdatedLMAO.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(outdatedLMAO);
		}
		//  Whole bunch of checks to prevent crashing
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.playerChar)){
			errorMessage += '\n${FlxG.save.data.playerChar} is an invalid player! Reset back to BF!';
			FlxG.save.data.playerChar = "bf";
		}
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.opponent)){
			errorMessage += '\n${FlxG.save.data.opponent} is an invalid opponent! Reset back to Dad!';
			FlxG.save.data.opponent = "dad";
		}
		if (!TitleState.choosableCharacters.contains(FlxG.save.data.gfChar)){
			errorMessage += '\n${FlxG.save.data.gfChar} is an invalid opponent! Reset back to GF!';
			FlxG.save.data.gfChar = "gf";
		}
		if (errorMessage != ""){
			var errorText = new FlxText(0, FlxG.height - 18, FlxG.width, errorMessage);
		    errorText.scrollFactor.set();
		    errorText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER);
		    add(errorText);
		    errorMessage="";
		}

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		// changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

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
			case 'downloaded songs':
				FlxG.switchState(new onlinemod.OfflineMenuState());

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}
}
