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
import sys.thread.Thread;

using StringTools;

typedef Scorekillme = {
	var scores:Array<Float>;
	var songs:Array<String>;
	var funniNumber:Float;
}
@:structInit class CharInfo{
	public var id:String = "";
	public var path:String = 'mods/characters/';
	public var folderName:String = "";
	public var description:String = null;
	public var nameSpace:String = null;
	public var nameSpaceType:Int = 0; // 0: mods/characters, 1: mods/weeks, 2: mods/packs 
	public var internal:Bool = false;
	public var internalAtlas:String = "";
	public var internalJSON:String = "";

	public function toString(){
		return 'Character $nameSpace/$id, Raw folder name:$folderName, path:$path';
	}
	public function getNamespacedName(){
		return (if (nameSpace != null) '$nameSpace|$id' else id);
	}
}



class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxTypedGroup<FlxSprite>;
	var ngSpr:FlxSprite;
	public static var p2canplay = true;
	public static var choosableStages:Array<String> = ["default","stage","nothing"];
	public static var choosableStagesLower:Map<String,String> = [];

	// TODO, FIX CHARACTERS LOADING FROM WRONG FOLDER WHNE SELECTED
	public static var characters:Array<CharInfo> = [];

	// public static var choosableCharacters:Array<String> = [];
	// public static var choosableCharactersLower:Map<String,String> = [];
	// public static var weekChars:Map<String,Array<String>> = [];
	// public static var characterDescriptions:Map<String,String> = [];
	// public static var characterPaths:Map<String,String> = [];
	public static var invalidCharacters:Array<CharInfo> = []; // This is a seperate array because the character doesn't need metadata beyond it being invalid


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



	public static var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	public static function loadNoteAssets(?forced:Bool = false,?forced2:Bool = false){
		if (NoteAssets == null || NoteAssets.name != FlxG.save.data.noteAsset || forced){
			if (!FileSystem.exists('mods/noteassets/${FlxG.save.data.noteAsset}.png') || !FileSystem.exists('mods/noteassets/${FlxG.save.data.noteAsset}.xml')){
				FlxG.save.data.noteAsset = "default";
			} // Hey, requiring an entire reset of the game's settings when noteasset goes missing is not a good idea
			new NoteAssets(FlxG.save.data.noteAsset,forced2);
		}
	}
	public static function findChar(char:String,?retBF:Bool = true,?ignoreNSCheck:Bool = false):Null<CharInfo>{
		if(char == ""){
			trace('Empty character search, returning BF');
			if(retBF) return characters[0];
			return null;
		}
		if(char.contains('|') && !ignoreNSCheck){
			return findCharByNamespace(char,retBF);
		}
		if(char == ""){
			trace('Tried to get a blank character!');
			if(retBF) return characters[0];
			return null;
		}
		if(Std.parseInt(char) != null && !Math.isNaN(Std.parseInt(char))){
			var e = Std.parseInt(char);
			if(characters[e] != null){

				// trace('Found char with ID of $e');
				return characters[e];
			}else{
				trace('Invalid ID $e, out of range 0-${characters.length}');
				if(retBF) return characters[0];
				return null;
			}
		}
		char = char.replace(' ',"-").replace('_',"-").toLowerCase();
		for (i in characters){
			if(i.id == char.toLowerCase()){
				return i;
			}
		}
		trace('Unable to find $char!');
		if(retBF) return characters[0];
		return null;
	}
	public static function findInvalidChar(char:String):CharInfo{
		char = char.replace('INVALID|',"");
		if(Std.parseInt(char) != null && !Math.isNaN(Std.parseInt(char))){
			var e = Std.parseInt(char);
			if(invalidCharacters[e] != null){
				return invalidCharacters[e];
			}else{
				return null;
			}
		}
		char = char.replace(' ',"-").replace('_',"-").toLowerCase();
		for (i in invalidCharacters){
			if(i.id == char){
				return i;
			}
		}
		
		return findChar(char);
	}
	// This prioritises characters from a specific namespace, if it finds one outside of the namespace, then they'll be used instead
	public static function findCharByNamespace(char:String = "",?namespace:String = "",?nameSpaceType:Int = -1,?retBF:Bool = true):Null<CharInfo>{ 
		if(char == ""){
			trace('Empty character search, returning BF');
			if(retBF) return characters[0];
			return null;
		}
		if(char.contains('|')){
			var _e = char.split('|');
			namespace = _e[0];
			char = _e[1];
		}
		if(namespace == "") return findChar(char,retBF,true);
		if(namespace == "INVALID"){
			return findInvalidChar(char);
		}
		if(char == ""){
			trace('Tried to get a blank character!');
			if(retBF) return characters[0];
			return null;
		}
		var currentChar:CharInfo = null;
		char = char.replace(' ',"-").replace('_',"-");
		for (i in characters){
			if(i.id == char.toLowerCase()){
				if(i.nameSpace == namespace && (nameSpaceType == -1 || i.nameSpaceType == nameSpaceType)){
					return i;
				}
				currentChar = i;
			}
		}
		if(currentChar == null){
			trace('Unable to find $char!');
			if(retBF) return characters[0];
			return null;
		}
		return currentChar;

	}
	public static function retChar(char:String):String{
		var char = findChar(char,false);
		return (if(char != null) char.id else "");
	}
	public static function getCharFromList(list:Array<String>,nameSpace:String = ""):CharInfo{
		trace(list);
		while (list.length > 0){
			var char = list.pop();
			if(char == "" ){continue;}
			var charInfo = findCharByNamespace(char,nameSpace,false);
			if(charInfo != null){
				return charInfo;
			}
		}
		return characters[0];
	}
	public static function retCharPath(char:String):String{
		var path = findChar(char,false);
		return (if(path == null || path.path == null) "" else path.path);
	}
	public static function retStage(char:String):String{
		if (choosableStagesLower[char.toLowerCase()] != null){
			return choosableStagesLower[char.toLowerCase()];
		}else{
			return "";
		}
	}
	public static function checkCharacters(){
		characters = [
			{id:"bf",folderName:"bf",path:"assets/",internal:true,internalAtlas:"characters/BOYFRIEND",internalJSON:Character.BFJSON,description:"Base Character; Boyfriend, the funny rap guy"},
			{id:"gf",folderName:"gf",path:"assets/",internal:true,internalAtlas:"characters/GF_assets",internalJSON:Character.GFJSON,description:"Base Character; Girlfriend, the funny boombox girl"}
		];
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
					characters.push({
						id:char.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:char,
						path:"assets/characters/",
						description:desc
					});

				}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
					// invalidCharacters.push([char,dir]);
					invalidCharacters.push({
						id:char.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:char,
						path:dir
					});
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
				var desc = null;
				if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/description.txt"))
					desc = File.getContent('${dataDir}/${directory}/description.txt');

				characters.push({
					id:directory.replace(' ','-').replace('_','-').toLowerCase(),
					folderName:directory,
					description:desc
				});
			}else if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/character.png") && (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.xml") || FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.json"))){
				// invalidCharacters.push([directory,'mods/characters']);
					invalidCharacters.push({
						id:directory.replace(' ','-').replace('_','-').toLowerCase(),
						folderName:directory,
						path:'mods/characters'
					});
			}
		  }
		}

		

		for (ID => dataDir in ['mods/weeks/','mods/packs/']) {
			
			if (FileSystem.exists(dataDir))
			{
			  for (_dir in FileSystem.readDirectory(dataDir))
			  {
				if (!FileSystem.isDirectory(dataDir + _dir)){continue;}
				// trace(_dir);
				if (FileSystem.exists(dataDir + _dir + "/characters/"))
				{
					var dir = dataDir + _dir + "/characters/";
					// trace('Checking ${dir} for characters');
					for (char in FileSystem.readDirectory(dir))
					{
						if (!FileSystem.isDirectory(dir+"/"+char)){continue;}
						if (FileSystem.exists(dir+"/"+char+"/config.json"))
						{
							var desc = 'Provided by ' + _dir;
							if (FileSystem.exists('${dir}/${char}/description.txt'))
								desc += ";" +File.getContent('${dir}/${char}/description.txt');
							characters.push({
								id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
								folderName:char,
								description:desc,
								path:dir,
								nameSpaceType:ID,
								nameSpace:_dir
							});

						}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
							invalidCharacters.push({
								id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
								folderName:char,
								path:dir,
								nameSpaceType:ID,
								nameSpace:_dir
							});
						}
					}
				}		
			  }
			}
		}

		trace('Found ${characters.length} characters');
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
		choosableStages = ["default","stage","nothing"];
		choosableStagesLower = ["default" => "default","stage" => "stage",'nothing' => 'nothing'];
		#if sys
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

		forceQuit = false; // You can't force quit to something that hasn't been loaded
		Assets.loadLibrary("shared");
		@:privateAccess
		{
			trace("Loaded " + (openfl.Assets.list().length) + " assets");
		}
		
		PlayerSettings.init();


		curWacky = getIntroTextShit();
		
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
		// pauseMenuMusic = Sound.fromFile((if (FileSystem.exists('mods/pauseMenu.ogg')) 'mods/pauseMenu.ogg' else if (FileSystem.exists('assets/music/breakfast.ogg')) 'assets/music/breakfast.ogg' else "assets/shared/music/breakfast.ogg"));

		#if discord_rpc
			DiscordClient.initialize();
		
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			 });
		#end

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:Alphabet;
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
			Conductor.changeBPM(140);
			persistentUpdate = true;
			FlxG.mouse.enabled = true;
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
		logoBl.loadGraphic(Paths.image('logoBumpin'));
		logoBl.antialiasing = true;

		// logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		// logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		// logoBl.animation.play('bump');
		// logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		gfDance.scrollFactor.set(0.8,0.8);
		add(gfDance);
		add(logoBl);
		titleText = new Alphabet(0, 0,"PRESS ENTER TO BEGIN",true,false);
		titleText.x = 100;
		titleText.y = FlxG.height * 0.8;
		titleText.screenCenter(X);
		// titleText.frames = Paths.getSparrowAtlas('titleEnter');
		// titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		// titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		// titleText.antialiasing = true;
		// titleText.animation.play('idle');
		// titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		// var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		// logo.screenCenter();
		// logo.antialiasing = true;
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


		shiftSkip = new FlxText(0,0,0,"DRP not init - Hold shift to go to the options menu after title screen",16);
		shiftSkip.y = FlxG.height - shiftSkip.height - 12;
		shiftSkip.x = 6;
		shiftSkip.scrollFactor.set();
		add(shiftSkip);
		CoolUtil.setFramerate(true);
		FlxG.sound.volume = FlxG.save.data.masterVol;
		if(initialized)
			skipIntro();
		else{
			Assets.loadLibrary("shared").onComplete(function (_) {
				
				showHaxe();
				LoadingScreen.hide();
			});

		}
			// initialized = true;
		// credGroup.add(credTextShit);
	}
	var shiftSkip:FlxText;
	var isShift = false;

	public static var hardcodedDays(default,never):Map<Int,Map<Int,Array<Array<String>>>> = [
		6 => [
			1 => [["Technoblade","never dies"]],
			30 => [["Technoblade","never dies"]]
		],
		7 => [
			1 => [["Technoblade","never dies"]]
		],
		10 => [
			28 => [["Technoblade","never dies"]]
		],
	];
	var forcedText:Bool = false;
	function getIntroTextShit():Array<String>
	{
		var now = Date.now();
		// FlxG.save.data.seenText = true;
		if(hardcodedDays[now.getMonth()] != null && hardcodedDays[now.getMonth()][now.getDate()] != null){
			// FlxG.save.data.seenText = false;
			forcedText = true;
			return FlxG.random.getObject(hardcodedDays[now.getMonth()][now.getDate()]);
		}
		if(FlxG.save.data.seenForcedText) FlxG.save.data.seenForcedText = false;
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');

		return FlxG.random.getObject(firstArray).split('--');
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

		#if (!FLX_NO_GAMEPAD)

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
		#end
		if(shiftSkip != null && isShift != FlxG.keys.pressed.SHIFT){
			isShift = FlxG.keys.pressed.SHIFT;
			shiftSkip.color = (if(FlxG.keys.pressed.SHIFT) 0x00aa00 else 0xFFFFFF);
		}
		if (pressedEnter && !transitioning && skippedIntro)
		{



			if (FlxG.save.data.flashing){
				FlxTween.tween(titleText,{alpha:0},0.1,{type:PINGPONG,ease:FlxEase.cubeInOut});
			}

			// FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();
			// if(MainMenuState.nightly != "")MainMenuState.ver += "-" + MainMenuState.nightly;
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
				#if (target.threaded)
				Thread.create(function()
				{
				#end
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
				#if (target.threaded)
				});
				#end
			}
			#else
				FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
			#end
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized && (!forcedText || FlxG.save.data.seenForcedText))
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>,yOffset:Int = 200)
	{
		for (i in 0...textArray.length)
		{
			addMoreText(textArray[i],yOffset);
			// var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			// money.screenCenter(X);
			// money.y += (i * 70) + 100;
			// money.scale.x = money.scale.y = 1.1;
			// FlxTween.tween(money.scale,{x:1,y:1},0.2,{ease:FlxEase.expoOut});
			// credGroup.add(money);
			// textGroup.add(money);
		}
	}

	function addMoreText(text:String,yOffset:Int = 200):Alphabet
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (70 * textGroup.length) + yOffset;
		coolText.bounce();
		credGroup.add(coolText);
		textGroup.add(coolText);
		return coolText;
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
	var tweeny:FlxTween;
	var ttBounce:FlxTween;
	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null){
			
			if(tweeny != null)tweeny.cancel();
			logoBl.scale.set(1,1);
			// FlxTween.tween(logoBl.scale,{x:1,y:1},0.1);
			tweeny = FlxTween.tween(logoBl.scale,{x:0.9,y:0.9},(60 / Conductor.bpm),{ease:FlxEase.expoOut});
			if(ttBounce != null)ttBounce.cancel();
			titleText.scale.x = titleText.scale.y = 1.1;
			ttBounce = FlxTween.tween(titleText.scale,{x:1,y:1},(60 / Conductor.bpm),{ease:FlxEase.expoOut});
		} 
		// logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		switch (curBeat)
		{
			case 0:
				if(DiscordClient.canSend) shiftSkip.text = "DRP initiated - Hold shift to go to the options menu after title screen";
				deleteCoolText();
			// 	destHaxe();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'], 0);

				// addMoreText('ninjamuffin99').startTyping(0.015,Conductor.crochetSecs);
				// addMoreText('phantomArcade').startTyping(0.015,Conductor.crochetSecs);
				// addMoreText('kawaisprite').startTyping(0.02,Conductor.crochetSecs);
				// addMoreText('evilsk8er').startTyping(0.022,Conductor.crochetSecs);
				credTextShit.x -= 130;
			case 2:
				addMoreText('present');
			case 7:
				deleteCoolText();
			case 10:
				// if (Main.watermarks)  You're not more important than fucking newgrounds
				// 	createCoolText(['Kade Engine', 'by']);
				// else
					// createCoolText(['In Partnership']);
				
				deleteCoolText();
				addMoreText('In Partnership with').startTyping(0,Conductor.crochetSecs * 2);
			case 11:
				// if (Main.watermarks)  You're not more important than fucking newgrounds
				// 	createCoolText(['Kade Engine', 'by']);
				// else
			case 12:
				addMoreText('Newgrounds');
				ngSpr.scale.x = ngSpr.scale.y = 1.1;
				FlxTween.tween(ngSpr.scale,{x:1,y:1},0.2);
				ngSpr.visible = true;
			case 16:
				deleteCoolText();
				credTextShit.y += 130;
				ngSpr.visible = false;



			case 18:
			// 	// createCoolText([curWacky[0]]);
				if(curWacky.length % 2 == 1){curWacky.push('');}// Hacky but fuck you
				var max = Std.int(Math.floor(curWacky.length * 0.5));
				createCoolText(curWacky.slice(0,max));
			case 20:
				var max = Std.int(Math.floor(curWacky.length * 0.5));
				createCoolText(curWacky.slice(max));
			case 24:
				deleteCoolText();
				if(forcedText) FlxG.save.data.seenForcedText = true;
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 26:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 28:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 30:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 32:
				skipIntro();
			default:
				// if(curBeat > 17 && curBeat < (20 + (curWacky.length * 2))){
				// 	var _beat:Float = (curBeat - 17) * 0.5;
				// 	if(_beat % 1 == 0){
				// 		addMoreText(curWacky[_beat]);
				// 	}
				// }
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
			FlxG.camera.flash(FlxColor.WHITE, 2);
			remove(credGroup);
			skippedIntro = true;
			FlxG.camera.scroll.x += 100;
			FlxG.camera.scroll.y += 100;

			FlxTween.tween(FlxG.camera.scroll,{x: 0,y:0},1,{ease:FlxEase.cubeOut});
			// var _x = logoBl.x;
			// logoBl.x = -100;
			// var _y = titleText.y;
			// titleText.y = FlxG.height;
			// FlxTween.tween(gfDance,{x: },0.4);
			// FlxTween.tween(logoBl,{x: _x},0.5);
			// FlxTween.tween(titleText,{y: _y},0.5);
		}
	}

	// HaxeFlixel thing
	// Holy shit I've spent way too much time on this
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
		_sprite.filters = [new flash.filters.GlowFilter(0xFFFFFF,1,6,6,1,1)];


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
		
		if(textGroup.members[1] == null) textGroup.members[0].color = _colors[_curPart]; else {textGroup.members[1].color = _colors[_curPart];textGroup.members[0].color = 0xFFFFFF;}
		
		cast(_sprite.filters[0],flash.filters.GlowFilter).color = _colors[_curPart];
		if (_curPart == 6)
		{
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			FlxTween.tween(_sprite.filters[0],{blurX:0,blurY:0,strength:1},1.5,{ease:FlxEase.quadOut});
			FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: __onComplete});
			FlxTween.tween(textGroup.members[0], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
			FlxTween.tween(textGroup.members[1], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
		}
	}
	function bounceText(?beatLength:Float = 0.3){
		var i = textGroup.members.length - 1;
		while (i > -1){
			textGroup.members[i].scale.x = textGroup.members[i].scale.y = 1.2;
			FlxTween.cancelTweensOf(textGroup.members[i]);
			FlxTween.tween(textGroup.members[i].scale, {x: 1,y: 1}, beatLength, {ease: FlxEase.cubeOut});
			i--;
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
		createCoolText(['']);

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
		createCoolText(['Powered by']);
		bounceText();

		// textGroup.members[1].color = 0x00b922;
		
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
		deleteCoolText();
		createCoolText(['Powered by','HaxeFlixel']);

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
		FlxTween.tween(_sprite.filters[0],{blurX:50,blurY:50,strength:2},0.2,{ease:FlxEase.quadOut});
		bounceText();

		// addMoreText('HaxeFlixel');
	}


}



class FuckinNoDestCam extends FlxCamera{
	public override function destroy(){
		return;
	}
}