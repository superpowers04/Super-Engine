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
import tjson.Json;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import SickMenuState;
import flash.media.Sound;
import flixel.FlxCamera;

using StringTools;

typedef Scorekillme = {
	var scores:Array<Float>;
	var songs:Array<String>;
	var funniNumber:Float;
}

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxTypedGroup<FlxSprite>;
	var ngSpr:FlxSprite;
	public static var p2canplay = true;
	public static var choosableCharacters:Array<String> = [];
	public static var choosableStages:Array<String> = ["default","stage",'halloween',"philly","limo",'mall','mallevil','school','schoolevil'];
	public static var choosableStagesLower:Map<String,String> = [];
	public static var choosableCharactersLower:Map<String,String> = [];
	public static var weekChars:Map<String,Array<String>> = [];
	public static var characterDescriptions:Map<String,String> = [];
	public static var characterPaths:Map<String,String> = [];
	public static var invalidCharacters:Array<String> = [];
	// Var's I have because I'm to stupid to get them to properly transfer between certain functions
	public static var returnStateID:Int = 0;
	public static var supported:Bool = false;
	public static var outdated:Bool = false;
	public static var checkedUpdate:Bool = false;
	public static var updatedVer:String = "";
	public static var errorMessage:String = "";
	public static var osuBeatmapLoc:String = "";
	public static var songScores:Scorekillme;
	public static var pauseMenuMusic:Sound;



	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	public static function loadNoteAssets(?forced:Bool = false){
		if (NoteAssets == null || NoteAssets.name != FlxG.save.data.noteAsset || forced){
			if (!FileSystem.exists('mods/noteassets/${FlxG.save.data.noteAsset}.png') || !FileSystem.exists('mods/noteassets/${FlxG.save.data.noteAsset}.xml')){
				FlxG.save.data.noteAsset = "default";

			} // Hey, requiring an entire reset of the game's settings when noteasset goes missing is not a good idea
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
	public static function retCharPath(char:String):String{
		if (characterPaths[retChar(char)] != null){
			if(characterPaths[retChar(char)].substring(-1) == "/"){
				return characterPaths[retChar(char)].substring(0,-1);
			}
			return characterPaths[retChar(char)];
		}else{
			return "mods/characters";
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
		choosableCharacters = ["bf","gf"];
		choosableCharactersLower = ["bf" => "bf","gf" => "gf"];
		characterDescriptions = ["automatic" => "Automatically uses character from song json", "bf" => "Boyfriend, the main protagonist. Provided by the base game.","gf" => "Girlfriend, boyfriend's partner. Provided by the base game."];
		characterPaths = [];
		weekChars = [];
		invalidCharacters = [];
		#if sys
		// Loading like this is probably not a good idea
		var dataDir:String = "mods/characters/";
		var customCharacters:Array<String> = [];

		if (FileSystem.exists("assets/characters/"))
		{
			var dir = "assets/characters";
			trace('Checking ${dir} for characters');
			for (char in FileSystem.readDirectory(dir))
			{
				if (!FileSystem.isDirectory(dir+"/"+char)){continue;}
				if (FileSystem.exists(dir+"/"+char+"/config.json"))
				{
					customCharacters.push(char);
					var desc = 'Assets character';
					if (FileSystem.exists('${dir}/${char}/description.txt'))
						desc += ";" +File.getContent('${dir}/${char}/description.txt');
					characterDescriptions[char] = desc;
					choosableCharactersLower[char.toLowerCase()] = char;
					characterPaths[char] = dir;

				}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
					invalidCharacters.push(char);
					characterPaths[char] = dir;
					// customCharacters.push(directory);
				}
			}
		}

		if (FileSystem.exists(dataDir))
		{
		  for (directory in FileSystem.readDirectory(dataDir))
		  {
			if (!FileSystem.isDirectory(dataDir+"/"+directory)){continue;}
			if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/config.json"))
			{
				customCharacters.push(directory);
				if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/description.txt"))
					characterDescriptions[directory] = File.getContent('${dataDir}/${directory}/description.txt');
				choosableCharactersLower[directory.toLowerCase()] = directory;
			}else if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/character.png") && (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.xml") || FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.json"))){
				invalidCharacters.push(directory);
				// customCharacters.push(directory);
			}
		  }
		}

		

		for (_ => dataDir in ['mods/weeks/','mods/packs/']) {
			
			if (FileSystem.exists(dataDir))
			{
			  for (_dir in FileSystem.readDirectory(dataDir))
			  {
				if (!FileSystem.isDirectory(dataDir + _dir)){continue;}
				// trace(_dir);
				if (FileSystem.exists(dataDir + _dir + "/characters/"))
				{
					var dir = dataDir + _dir + "/characters/";
					trace('Checking ${dir} for characters');
					for (char in FileSystem.readDirectory(dir))
					{
						if (!FileSystem.isDirectory(dir+"/"+char)){continue;}
						if (FileSystem.exists(dir+"/"+char+"/config.json"))
						{
							var charPack = "";
							if(choosableCharactersLower[char.toLowerCase()] != null){
								var e = charPack;
								charPack = _dir+"|"+char;
								char = e;
							}
							customCharacters.push(char);
							var desc = 'Provided by ' + _dir;
							if (FileSystem.exists('${dir}/${char}/description.txt'))
								desc += ";" +File.getContent('${dir}/${char}/description.txt');
							characterDescriptions[char] = desc;
							if(choosableCharactersLower[char.toLowerCase()] != null){

								choosableCharactersLower[charPack.toLowerCase()] = char;
								if(weekChars[char] == null){
									weekChars[char] = [];
								}
								weekChars[char].push(charPack);
								characterPaths[charPack] = dir;
							}else{
								choosableCharactersLower[char.toLowerCase()] = char;
								characterPaths[char] = dir;
							}

						}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
							invalidCharacters.push(char);
							characterPaths[char] = dir;
							// customCharacters.push(directory);
						}
					}
				}		
			  }
			}
		}

		haxe.ds.ArraySort.sort(customCharacters, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		for (char in customCharacters){
			if(char.length > 0){
				choosableCharacters.push(char);
			}
			// choosableCharactersLower[char.toLowerCase()] = char;
		}
		// try{

		// 	var rawJson = File.getContent('assets/data/characterMetadata.json');
		// 	// trace('Char Json: \n${rawJson}');
		// 	TitleState.defCharJson = haxe.Json.parse(CoolUtil.cleanJSON(rawJson));
		// 	if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
		// 		characters:[],
		// 		aliases:[]
		// 	};trace("Character characterMetadata is null!");}
		// }catch(e){
		// 	MainMenuState.errorMessage = 'An error occurred when trying to parse Character Metadata:\n ${e.message}.\n You can reload this using Reload Char/Stage List';
		// 	if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
		// 		characters:[],
		// 		aliases:[]
		// 	};
		// 	}
		// }
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
	// static inline function GETSCOREPATH():String{
	// 	#if windows 
	// 		if (Sys.getEnv("LOCALAPPDATA") != null) return '${Sys.getEnv("LOCALAPPDATA")}/hahafunnisuperengine/'; // Windows path
	// 	#else
	// 		if (Sys.getEnv("HOME") != null ) return '${Sys.getEnv("HOME")}/.local/share/hahfunnysuperengine/'; // Unix path
	// 	#end
	// 	else return "./hahfunnysuperengine/"; // If this gets returned, fucking run
	// }
	// static function getfunninumber(?scores:Scorekillme = null){ // Really simple, but if you're gonna get past this one, then you'll probably just get past any smarter checksums I'd make
	// 	if(scores == null){
	// 		scores = songScores;
	// 	}
	// 	var funniNumber:Float = 0; // Would make this an int but I don't trust rounding
	// 	for (i => v in scores.scores) {
	// 		funniNumber += v;
	// 	}
	// 	// funniNumber += scores.scores.length * funniNumber; // If this doesn't return the same then cheat :<
	// 	return funniNumber;
	// }
	// public static function getScore(type:Int = -1):Float{
	// 	var stag = 0;
	// 	try{

	// 		if(type == -1) type = PlayState.stateType;
	// 		stag++;
	// 		var songName = "";
	// 		stag++;
	// 		switch(type){
	// 			case 4:songName = multi.MultiMenuState.lastSong;
	// 			default:return 0.0;
	// 		}
	// 		stag++;
	// 		return if(songName != null && songScores.songs.contains(songName)) songScores.scores[songScores.songs.indexOf(songName)] else 0.0;
	// 		stag++;
	// 	}catch(e){
	// 		trace("Fucking haxe:" + stag +" " + e.message);
	// 		return 0.0;
	// 	}
	// }
	// public static function saveScore(accuracy:Float,?type:Int = -1){
	// 	try{
	// 		var songName = "";
	// 		if(type == -1) type = PlayState.stateType;
	// 		switch(type){
	// 			case 4:songName = multi.MultiMenuState.lastSong;
	// 			default:return;
	// 		}
	// 		if(songScores.songs.contains(songName) && songScores.scores[songScores.songs.indexOf(songName)] > accuracy){return;} // Don't overwrite a better score!
	// 		if(!songScores.songs.contains(songName)) songScores.songs.push(songName);
	// 		songScores.scores[songScores.songs.indexOf(songName)] = accuracy;
	// 		songScores.funniNumber = getfunninumber();
	// 		File.saveContent(GETSCOREPATH() + "songs.json",Json.stringify(songScores));
	// 	}catch(e){
	// 		trace("Error saving:"  + e.message);
	// 		MusicBeatState.instance.showTempmessage('Unable to save score! ${e.message}');
	// 	}
	// }
	// static function handlError(err:String){
	// 	if(!MainMenuState.firstStart){
	// 		MainMenuState.handleError(err);
	// 	}else{
	// 		MusicBeatState.instance.showTempmessage(err);
	// 	}
	// }
	// static function loadScores(){
	// 	var path = GETSCOREPATH();
	// 	if (!FileSystem.exists(path)) {
	// 		FileSystem.createDirectory(path);
	// 	}
	// 	if (!FileSystem.exists(path + "songs.json")) {
	// 		songScores = {
	// 			scores : [0],
	// 			songs : ["bopeebo"],
	// 			funniNumber : 1
	// 		};
	// 		File.saveContent(path + "songs.json",Json.stringify(songScores));
	// 	}else{
	// 		try{
	// 			var e:Scorekillme = cast Json.parse(File.getContent(path+"songs.json"));
	// 			// File.saveContent(path + "_songs.json",Json.stringify(e));
	// 			// File.saveContent(path + "_songs.json",Json.stringify(e));
	// 			// songScores = cast e.scores;
	// 			if(e == null){throw("songs.json is invalid!");}
	// 			trace(e);
	// 			// trace("e");
	// 			if(getfunninumber(e) != e.funniNumber){
	// 				handlError("Something isn't adding up with your scores, you get bopeebo'd");
	// 				trace("bopeebo'd lmao");
	// 				songScores = {
	// 					scores : [0],
	// 					songs : ["bopeebo"],
	// 					funniNumber : 1
	// 				};
	// 			}
	// 			songScores = e;
	// 		}catch(err){
	// 			handlError("Something went wrong when loading song scores, RESETTING! " + err.message);
	// 			trace("Something went wrong when loading song scores, RESETTING! " + err.message);
	// 			try{File.saveContent(path + "songs.json-bak",File.getContent(path+"songs.json"));}catch(err){trace("rip scores, file is bein cring");}

	// 			songScores = {
	// 				scores : [0],
	// 				songs : ["bopeebo"],
	// 				funniNumber : 1
	// 			};
	// 			File.saveContent(path + "songs.json",Json.stringify(songScores));
	// 		}
	// 	}
	// 	if(songScores == null){
	// 		trace("What the fuck, why are you null?!?!!?");
	// 		songScores = {
	// 				scores : [0],
	// 				songs : ["bopeebo"],
	// 				funniNumber : 1
	// 			};

	// 	}
	// }
	override public function create():Void
	{
		Assets.loadLibrary("shared");
		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		PlayerSettings.init();


		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		
		if(CoolUtil.font != Paths.font("vcr.ttf")) flixel.system.FlxAssets.FONT_DEFAULT = CoolUtil.font;
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
		// loadScores();
		pauseMenuMusic = Sound.fromFile((if (FileSystem.exists('mods/pauseMenu.ogg')) 'mods/pauseMenu.ogg' else if (FileSystem.exists('assets/music/breakfast.ogg')) 'assets/music/breakfast.ogg' else "assets/shared/music/breakfast.ogg"));

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
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
			
			// FlxTween.tween(Main.fpsCounter,{alpha:1},0.2);


			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('StartItchBuild'), 0.1);
			FlxG.sound.music.pause();
			// LoadingState.loadingText = new FlxText(FlxG.width * 0.8,FlxG.height * 0.8,"Loading...");
			// LoadingState.loadingText.setFormat();
			findosuBeatmaps();
			MainMenuState.firstStart = true;
			Conductor.changeBPM(70);
			persistentUpdate = true;
			FlxG.fixedTimestep = false; // Makes the game not be based on FPS for things, thank you Forever Engine for doing this
			FlxG.mouse.useSystemCursor = true; // Uses system cursor, did not know this was a thing until Forever Engine
			CoolUtil.volKeys = [FlxG.sound.muteKeys,FlxG.sound.volumeUpKeys,FlxG.sound.volumeDownKeys];
			if(!FileSystem.exists("mods/menuTimes.json")){ // Causes crashes if done while game is running, unknown why
				File.saveContent("mods/menuTimes.json",Json.stringify(SickMenuState.musicList));
			}else{
				try{
					var musicList:Array<MusicTime> = Json.parse(File.getContent("mods/menuTimes.json"));
					SickMenuState.musicList = musicList;
				}catch(e){
					MusicBeatState.instance.showTempmessage("Unable to load Music Timing: " + e.message,FlxColor.RED);
				}
			}


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

		gfDance = new FlxSprite(FlxG.width, FlxG.height * 0.07);
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
		textGroup = new FlxTypedGroup<FlxSprite>();

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


		shiftSkip = new FlxText(0,0,0,"Hold shift to go to the options menu after title screen",16);
		shiftSkip.y = FlxG.height - shiftSkip.height - 12;
		shiftSkip.x = 6;
		add(shiftSkip);

		if (initialized)
			skipIntro();
		else{

			createCoolText(['Powered by',"haxeflixel"]);
			showHaxe();
			LoadingScreen.hide();
		}
			// initialized = true;
		// credGroup.add(credTextShit);
	}
	var shiftSkip:FlxText;
	var isShift = false;

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

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || skipBoth;

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
		if(shiftSkip != null && isShift != FlxG.keys.pressed.SHIFT){
			isShift = FlxG.keys.pressed.SHIFT;
			shiftSkip.color = (if(FlxG.keys.pressed.SHIFT) 0x00aa00 else 0xFFFFFF);
		}
		if (pressedEnter && !transitioning && skippedIntro)
		{



			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			// FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();
			if(MainMenuState.nightly != "") MainMenuState.ver += "-" + MainMenuState.nightly;
			lime.app.Application.current.window.onDropFile.add(AnimationDebug.fileDrop);
			if(Sys.args()[0] != null && FileSystem.exists(Sys.args()[0])){
				AnimationDebug.fileDrop(Sys.args()[0]);
			}
			#if !debug
			if (FlxG.keys.pressed.SHIFT || FileSystem.exists(Sys.getCwd() + "/noUpdates") || checkedUpdate || !FlxG.save.data.updateCheck)
				FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
			else
			{

				showTempmessage("Checking for updates..",FlxColor.WHITE);
				tempMessage.screenCenter(X);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					// Get current version of FNFBR, Uses kade's update checker 
	
					var http = new haxe.Http("https://raw.githubusercontent.com/superpowers04/Super-Engine/" + (if(MainMenuState.nightly == "") "master" else "nightly") + "/version.downloadMe"); // It's recommended to change this if forking
					var returnedData:Array<String> = [];
					
					http.onData = function (data:String)
					{
						checkedUpdate = true;
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						updatedVer = returnedData[0];
						OutdatedSubState.needVer = updatedVer;
						OutdatedSubState.currChanges = returnedData[1];
						if (!MainMenuState.ver.contains(updatedVer.trim()) || (MainMenuState.nightly != ""))
						{
							// trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.ver);
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

			// case 1:
			// 	// if (Main.watermarks)  You're not more important than fucking newgrounds
			// 	// 	createCoolText(['Kade Engine', 'by']);
			// 	// else
			// 	createCoolText(['Powered by',"haxeflixel"]);
			// 	showHaxe();
			case 0:
				deleteCoolText();
			// 	destHaxe();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 2:
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
			if(!FlxG.sound.music.playing){
				FlxG.sound.music.play();
				FlxG.sound.music.fadeIn(0.1,FlxG.save.data.instVol);
			}
			remove(ngSpr);
			destHaxe();
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
			var _x = logoBl.x;
			logoBl.x = -100;
			var _y = titleText.y;
			titleText.y = FlxG.height;
			FlxTween.tween(gfDance,{x: FlxG.width * 0.4},0.4);
			FlxTween.tween(logoBl,{x: _x},0.5);
			FlxTween.tween(titleText,{y: _y},0.5);
		}
	}

	// HaxeFlixel thing

	var _sprite:Sprite;
	var _gfx:Graphics;

	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _functions:Array<Void->Void>;
	var _curPart:Int = 0;
	var _cachedBgColor:FlxColor;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;
	var _timers:Array<FlxTimer>;
	var _sound:FlxSound;
	function showHaxe(){
		_times = [0.041, 0.184, 0.334, 0.495, 0.636,1];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb,0xFFFFFF,0xFFFFFF];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue,function(){return;}];
		_sprite = new Sprite();
		FlxG.stage.addChild(_sprite);
		_gfx = _sprite.graphics;


		_sprite.x = (FlxG.width / 2);
		_sprite.y = (FlxG.height * 0.60) - 20 * FlxG.game.scaleY;
		_sprite.scaleX = FlxG.game.scaleX;
		_sprite.scaleY = FlxG.game.scaleY;
		_sound = FlxG.sound.load(flixel.system.FlxAssets.getSound("flixel/sounds/flixel"),FlxG.save.data.instVol - 0.2); // Put the volume down by 0.2 for safety of eardrums
		_sound.play();
		for (time in _times)
		{
			new FlxTimer().start(time, _timerCallback);
		}
	}
	function destHaxe(){
		if(_sprite == null) return;
		if(_sound != null){
			_sound.pause();
			_sound.destroy();
		} 
		// remove(_sprite);
		flixel.util.FlxTimer.globalManager.clear();
		FlxG.stage.removeChild(_sprite);
		_sprite = null;
		_gfx = null;
		_times = null;
		_colors = null;
		_functions = null;
	}
	function _timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_curPart++;
		textGroup.members[1].color = _colors[_curPart];
		if (_curPart == 6)
		{
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: __onComplete});
			FlxTween.tween(textGroup.members[0], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
			FlxTween.tween(textGroup.members[1], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
		}
	}
	var skipBoth:Bool = false;
	function  __onComplete(tmr:FlxTween){
		if(_sound != null){
			_sound.pause();
			_sound.destroy();
		} 
		initialized = true;
		destHaxe();
		FlxG.sound.music.play();
		FlxG.sound.music.fadeIn(0.1,FlxG.save.data.instVol);
		if(isShift || FlxG.keys.pressed.ENTER || (Sys.args()[0] != null && FileSystem.exists(Sys.args()[0]))){
			skipBoth = true;
		}
	}
	function drawGreen():Void
	{
		_gfx.beginFill(0x00b922);
		_gfx.moveTo(0, -37);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(0, -37);
		_gfx.endFill();
	}

	function drawYellow():Void
	{
		_gfx.beginFill(0xffc132);
		_gfx.moveTo(-50, -50);
		_gfx.lineTo(-25, -50);
		_gfx.lineTo(0, -37);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(-50, -25);
		_gfx.lineTo(-50, -50);
		_gfx.endFill();
	}

	function drawRed():Void
	{
		_gfx.beginFill(0xf5274e);
		_gfx.moveTo(50, -50);
		_gfx.lineTo(25, -50);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(50, -25);
		_gfx.lineTo(50, -50);
		_gfx.endFill();
	}

	function drawBlue():Void
	{
		_gfx.beginFill(0x3641ff);
		_gfx.moveTo(-50, 50);
		_gfx.lineTo(-25, 50);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-50, 25);
		_gfx.lineTo(-50, 50);
		_gfx.endFill();
	}

	function drawLightBlue():Void
	{
		_gfx.beginFill(0x04cdfb);
		_gfx.moveTo(50, 50);
		_gfx.lineTo(25, 50);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(50, 25);
		_gfx.lineTo(50, 50);
		_gfx.endFill();
	}


}



class FuckinNoDestCam extends FlxCamera{
	public override function destroy(){
		return;
	}
}