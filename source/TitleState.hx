package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import sys.io.File;
import sys.FileSystem;
import flixel.math.FlxMath;


using StringTools;


class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	public static var p2canplay = true;
	public static var choosableCharacters:Array<String> = [];
	public static var choosableStages:Array<String> = ["default","stage",'halloween',"philly","limo",'mall','mallevil','school','schoolevil'];
	public static var choosableStagesLower:Map<String,String> = [];
	public static var choosableCharactersLower:Map<String,String> = [];
	public static var characterDescriptions:Map<String,String> = [];
	public static var invalidCharacters:Array<String> = [];
	public static var defCharJson:CharacterMetadataJSON = {characters:[], aliases:[]};
	// Var's I have because I'm to stupid to get them to properly transfer between certain functions
	public static var returnStateID:Int = 0;
	public static var supported:Bool = false;
	public static var outdated:Bool = false;
	public static var checkedUpdate:Bool = false;
	public static var updatedVer:String = "";
	public static var errorMessage:String = "";
	public static var osuBeatmapLoc:String = "";

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	public static function loadNoteAssets(?forced:Bool = false){
		if (NoteAssets == null || NoteAssets.name != FlxG.save.data.noteAsset || forced){
			new NoteAssets(FlxG.save.data.noteAsset);
		}
	}
	public static function retChar(char:String):String{
		if (choosableCharactersLower[char.toLowerCase()] != null){
			return choosableCharactersLower[char.toLowerCase()];
		}else{
			return "";
		}
	}
	public static function retStage(char:String):String{
		if (choosableStagesLower[char.toLowerCase()] != null){
			return choosableStagesLower[char.toLowerCase()];
		}else{
			return "";
		}
	}
	public static function checkCharacters(){

		choosableCharacters = ["bf","bf-pixel","bf-christmas","gf",'gf-pixel',"dad","spooky","pico","mom",'parents-christmas',"senpai","senpai-angry","spirit","monster"];
		choosableCharactersLower = ["bf" => "bf","bf-pixel" => "bf-pixel","bf-christmas" => "bf-christmas","gf" => "gf","gf-pixel" => "gf-pixel","dad" => "dad","spooky" => "spooky","pico" => "pico","mom" => "mom","parents-christmas" => "parents-christmas","senpai" => "senpai","senpai-angry" => "senpai-angry","spirit" => "spirit","monster" => "monster"];
		characterDescriptions = ["automatic" => "Automatically uses character from song json"];
		invalidCharacters = [];
		#if sys
		// Loading like this is probably not a good idea
		var dataDir:String = "mods/characters/";
		var customCharacters:Array<String> = [];
		if (FileSystem.exists(dataDir))
		{
		  for (directory in FileSystem.readDirectory(dataDir))
		  {
			if (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/config.json"))
			{
				customCharacters.push(directory);
				if (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/description.txt"))
					characterDescriptions[directory] = File.getContent('mods/characters/${directory}/description.txt');
			}else if (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.png") && (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.xml") || FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.json"))){
				invalidCharacters.push(directory);
				// customCharacters.push(directory);
			}
		  }
		}
		// customCharacters.sort((a, b) -> );
		haxe.ds.ArraySort.sort(customCharacters, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		for (char in customCharacters){
			choosableCharacters.push(char);
			choosableCharactersLower[char.toLowerCase()] = char;
		}
		// var rawJson = Assets.getText('assets/data/characterMetadata.json');
		try{

			var rawJson = File.getContent('assets/data/characterMetadata.json');
			// trace('Char Json: \n${rawJson}');
			TitleState.defCharJson = haxe.Json.parse(CoolUtil.cleanJSON(rawJson));
			if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
				characters:[],
				aliases:[]
			};trace("Character characterMetadata is null!");}
		}catch(e){
			MainMenuState.errorMessage = 'An error occurred when trying to parse Character Metadata:\n ${e.message}.\n You can reload this using Reload Char/Stage List';
			if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
				characters:[],
				aliases:[]
			};
			}
		}
		#end
		checkStages();
		if(FlxG.save.data.scripts != null){
			trace('Currently enabled scripts: ${FlxG.save.data.scripts}');
			for (i in 0 ... FlxG.save.data.scripts.length) {
				var v = FlxG.save.data.scripts[i];
				if(!FileSystem.exists('mods/scripts/${v}/')){
					FlxG.save.data.scripts.remove(v);
					trace('Script $v doesn\'t exist! Disabling');
				}
			}
		}
	}
	public static function checkStages(){
		choosableStages = ["default","stage",'halloween',"philly","limo",'mall','mallevil','school','schoolevil'];
		choosableStagesLower = ["default" => "default","stage" => "stage",'halloween' => 'halloween',"philly" => "philly","limo" => "limo",'mall' => 'mall','mallevil' => 'mallevil','school' => 'school','schoolevil' => 'schoolevil'];
		#if sys
		// Loading like this is probably not a good idea
		var dataDir:String = "mods/stages/";
		var customStages:Array<String> = [];
		if (FileSystem.exists(dataDir))
		{
		  for (directory in FileSystem.readDirectory(dataDir))
		  {
			if (FileSystem.exists(Sys.getCwd() + "mods/stages/"+directory+"/config.json") || FileSystem.exists(Sys.getCwd() + "mods/stages/"+directory+"/script.hscript"))
			{
				customStages.push(directory);

			}
		  }
		}
		haxe.ds.ArraySort.sort(customStages, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		for (char in customStages){
			choosableStages.push(char);
			choosableStagesLower[char.toLowerCase()] = char;
		}
		#end
	}
	public static function findosuBeatmaps(){
		var loc = "";
		#if windows
			if (Sys.getEnv("LOCALAPPDATA") != null && FileSystem.exists('${Sys.getEnv("LOCALAPPDATA")}/osu!/Songs/')) loc = '${Sys.getEnv("LOCALAPPDATA")}/osu!/Songs/';
			if (Sys.getEnv("LOCALAPPDATA") != null && FileSystem.exists('${Sys.getEnv("LOCALAPPDATA")}/osu-stable/Songs/')) loc = '${Sys.getEnv("LOCALAPPDATA")}/osu-stable/Songs/';
		#else
			if (Sys.getEnv("HOME") != null && FileSystem.exists('${Sys.getEnv("HOME")}/.local/share/osu-stable/Songs/')) loc = '${Sys.getEnv("HOME")}/.local/share/osu-stable/Songs/';
			if (loc == "") trace('${Sys.getEnv("HOME")}/.local/share/osu-stable/songs/ doesnt exist!');
		#end

		osuBeatmapLoc = loc;
	}
	override public function create():Void
	{
		
		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end
		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		PlayerSettings.init();


		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();


		FlxG.save.bind('funkin', 'ninjamuffin99');

		KadeEngineData.initSave();

		Highscore.load();
		checkCharacters();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	override function tranOut(){return;}
	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(-1, 0), {asset: diamond, width: 32, height: 32},
				new FlxRect(-FlxG.width * 0.5, -FlxG.height * 0.5, FlxG.width * 2, FlxG.height * 2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(1, 0),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-FlxG.width * 0.5, -FlxG.height * 0.5, FlxG.width * 2, FlxG.height * 2));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;


			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('StartItchBuild'), 0.1);

			FlxG.sound.music.fadeIn(4, 0, 1);
			findosuBeatmaps();
			MainMenuState.firstStart = true;
			Conductor.changeBPM(70);
			persistentUpdate = true;
			FlxG.fixedTimestep = false; // Makes the game not be based on FPS for things, thank you Forever Engine for doing this
			FlxG.mouse.useSystemCursor = true; // Uses system cursor, did not know this was a thing until Forever Engine
		}


		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.3);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{



			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			// FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			
			#if !debug
			if (FlxG.keys.pressed.SHIFT || FileSystem.exists(Sys.getCwd() + "/noUpdates") || checkedUpdate || !FlxG.save.data.updateCheck)
				FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
			else
			{
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					// Get current version of FNFBR, Uses kade's update checker 
	
					var http = new haxe.Http("https://raw.githubusercontent.com/superpowers04/Super-Engine/master/version.downloadMe"); // It's recommended to change this if forking
					var returnedData:Array<String> = [];
					
					http.onData = function (data:String)
					{
						checkedUpdate = true;
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						updatedVer = returnedData[0];
						OutdatedSubState.needVer = updatedVer;
						OutdatedSubState.currChanges = returnedData[1];
						if (!MainMenuState.ver.contains(updatedVer.trim()))
						{
							trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.ver);
							outdated = true;
							
						}
						FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
					}
					http.onError = function (error) {
					  trace('error: $error');
					  FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState()); // fail but we go anyway
					}
					
					http.request();
				});
			}
			#else
				FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
			#end
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null) logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				// if (Main.watermarks)  You're not more important than fucking newgrounds
				// 	createCoolText(['Kade Engine', 'by']);
				// else
					createCoolText(['In Partnership', 'with']);
			case 7:
				// if (Main.watermarks)
				// 	addMoreText('KadeDeveloper');
				// else
				// {
					addMoreText('Newgrounds');
					ngSpr.visible = true;
				// }
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
			FlxTween.tween(gfDance,{y:FlxG.height * 0.07},1);
		}
	}
}
