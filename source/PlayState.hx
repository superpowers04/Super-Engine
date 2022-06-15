package;

import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib; 
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect; 
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import tjson.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.media.Sound;

import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;


import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
import hscript.ParserEx;

import CharacterJson;
import StageJson;




using StringTools;

typedef OutNote = {
	var time:Float;
	var strumTime:Float;
	var direction:Int;
	var rating:String;
	var isSustain:Bool;
}


class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var actualSongName:String = ''; // The actual song name, instead of the shit from the JSON
	public static var songDir:String = ''; // The song's directory
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Dynamic = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var songDiff:String = "";
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var stateType=0;
	public static var invertedChart:Bool = false;

	public static var songPosBG(get,set):FlxSprite; // WHY IS THIS STATIC?
	public static function get_songPosBG(){return PlayState.instance.songPosBG_;}
	public static function set_songPosBG(vari){return PlayState.instance.songPosBG_ = vari;}
	public static var songPosBar(get,set):FlxBar; // WHY IS THIS STATIC?
	public static function get_songPosBar(){return PlayState.instance.songPosBar_;}
	public static function set_songPosBar(vari){return PlayState.instance.songPosBar_ = vari;}
	
	public var songPosBG_:FlxSprite;
	public var songPosBar_:FlxBar;
	public static var underlay:FlxSprite;

	public static var loadRep:Bool = false;
	public static inline var daPixelZoom:Int = 6;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	public static var p2canplay = false;//TitleState.p2canplay

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	public var kadeEngineWatermark:FlxText;
	

	public var vocals:FlxSound;

	public var gfChar:String = "gf";
	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;

	public static var girlfriend(get,set):Character;
	public static function get_girlfriend(){return gf;};
	public static function set_girlfriend(vari){return gf = vari;};
	public static var bf(get,set):Character;
	public static function get_bf(){return boyfriend;};
	public static function set_bf(vari){return boyfriend = vari;};
	public static var opponent(get,set):Character;
	public static function get_opponent(){return dad;};
	public static function set_opponent(vari){return dad = vari;};
	public static var player1:String = "bf";
	public static var player2:String = "bf";
	public static var player3:String = "gf";

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumArrow> = null;
	public var playerStrums:FlxTypedGroup<StrumArrow> = null;
	public var cpuStrums:FlxTypedGroup<StrumArrow> = null;
	public static var dadShow = true;
	var canPause:Bool = true;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	public var healthPercent(get,set):Int; //making public because sethealth doesnt work without it
	public function get_healthPercent(){
		return Std.int(health * 50);
	}
	public function set_healthPercent(vari:Int){
		health = vari * 50; return get_healthPercent();
	}
	public static var combo:Int = 0;
	public static var maxCombo:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 0.00;
	public static var accuracyDefault:Float = 0.00;
	var rating:FlxSprite;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var practiceText:FlxText;
	private var songPositionBar:Float = 0;
	public var handleTimes:Bool = true;
	
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	public var camTOP:FlxCamera;
	public var camGame:FlxCamera;
	public var hasDied:Bool = false;

	public static var offsetTesting:Bool = false;
	var updateTime:Bool = false;


	// Note Splash group
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var notesHitArray:Array<Float> = [];
	var currentFrames:Int = 0;

	public static var dialogue:Array<String> = [];
	public static var endDialogue:Array<String> = [];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	public var songName:FlxText;
	public var songTimeTxt:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	public static var songScore:Int = 0;
	var songScoreDef:Int = 0;
	public var scoreTxt:FlxText;
	var scoreTxtX:Float;
	var replayTxt:FlxText;
	public var downscroll:Bool;
	public var middlescroll:Bool;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;


	// public static var theFunne:Bool = true;
	var inCutscene:Bool = false;
	// public static var repPresses:Int = 0;
	// public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	public static var jumpTo:Float = 0;
	public var moveCamera:Bool = true;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var bruhmode:Bool = false;
	public static var stageTags:Array<String> = [];
	public static var beatAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var stepAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var canUseAlts:Bool = false;
	public static var hitSoundEff:Sound;
	public static var hurtSoundEff:Sound;
	static var vanillaHurtSounds:Array<Sound> = [];
	public var inputMode:Int = 0;
	public static var inputEngineName:String = "Unspecified";
	public static var songScript:String = "";
	public static var hsBrTools:HSBrTools;
	public static var nameSpace:String = "";
	public var gfShow:Bool = true;
	public var eventLog:Array<OutNote> = [];
	public var camBeat:Bool = true;
	public var forceChartChars:Bool = false;
	public var loadChars:Bool = true;
	var updateOverlay = true;
	var practiceMode = false;
	var errorMsg:String = "";

	var hitSound:Bool = false;
	var flippy:Bool = false;
	public static var scripts:Array<String> = [];
	public static var stageObjects:Array<Dynamic<FlxObject>> = [];


	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	public static function resetScore(){
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;
		maxCombo = 0;
		combo = 0;
		accuracy = 0.00;
		// totalNotesHit = 0;
		// noteCount = 0;

		// repPresses = 0;
		// repReleases = 0;
		songScore = 0;
		if(isStoryMode){// Reset current preformance to last song
			sicks = StoryMenuState.weekSicks;
			bads = StoryMenuState.weekBads;
			shits = StoryMenuState.weekShits;
			goods = StoryMenuState.weekGoods;
			misses = StoryMenuState.weekMisses;
			maxCombo = StoryMenuState.weekMaxCombo;
			songScore = StoryMenuState.weekScore;
			accuracy = StoryMenuState.weekAccuracy;
		}


	}
	public static var logGameplay:Bool = false;


	public var interps:Map<String,Interp> = new Map();
	public static var customDiff = "";

	public function handleError(?error:String = "Unknown error!",?forced:Bool = false){
		try{

			resetInterps();
			trace('Error! ${error}');
			if(!songStarted && !forced && playCountdown){
				errorMsg = error;
				trace("Suppressing error to prevent issues as it was thrown before countdown");
				return;
			}
			// generatedMusic = false;
			generatedMusic = false;
			persistentUpdate = false;
			openSubState(new FinishSubState(0,0,error));
		}catch(e){MainMenuState.handleError(e,error);
		}
	}
	public function revealToInterp(value:Dynamic,name:String,id:String){
		if ((interps[id] == null )) {return;}
		interps[id].variables.set(name,value); 

	}
	public function getFromInterp(name:String,id:String,?remove:Bool = false,?defVal:Dynamic = null):Dynamic{
		if ((interps[id] == null )) {return defVal;}
		var e = interps[id].variables.get(name); 
		if(remove) interps[id].variables.set(name,null);
		return e;
	}

	public function callSingleInterp(func_name:String, args:Array<Dynamic>,id:String){
		try{
			if (interps[id] == null) {trace('No Interp ${id}!');return;}
			if (!interps[id].variables.exists(func_name)) {return;}
			// trace('$func_name:$id $args');
			
			var method = interps[id].variables.get(func_name);
			Reflect.callMethod(interps[id],method,args);
		}catch(e:hscript.Expr.Error){handleError('${func_name} for ${id}:\n ${e.toString()}');}
	}

	public function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
			try{
				if(func_name == "noteHitDad"){
					charCall("noteHitSelf",[args[1]],1);
					charCall("noteHitOpponent",[args[1]],0);
				}
				if(func_name == "noteHit"){
					charCall("noteHitSelf",[args[1]],0);
					charCall("noteHitOpponent",[args[1]],1);
				}
				// if(func_name != "update") trace('Called $func_name for ${(if(id != "")id else "Global")}');
				args.insert(0,this);
				if (id == "") {

					for (name in interps.keys()) {
						// var ag:Array<Dynamic> = [];
						// for (i => v in args) { // Recreates the array
						// 	ag[i] = v;
						// }
						callSingleInterp(func_name,args,name);
					}
				}else callSingleInterp(func_name,args,id);
			}catch(e:hscript.Expr.Error){handleError('${func_name} for "${id}":\n ${e.toString()}');}

		}
	public function resetInterps() {interps = new Map();interpCount=0;HSBrTools.shared.clear();}
	public function unloadInterp(?id:String){
		interpCount--;interps.remove(id);
	}
	
	public function parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song"){
		// Scripts are forced with weeks, otherwise, don't load any scripts if scripts are disabled or during online play
		if (!QuickOptionsSubState.getSetting("Song hscripts") && !isStoryMode) {resetInterps();return;}
		var songScript = songScript;
		// var hsBrTools = hsBrTools;
		if (script != "") songScript = script;
		if (brTools == null && hsBrTools != null) brTools = hsBrTools;
		if (songScript == "") {return;}
		var interp = HscriptUtils.createSimpleInterp();
		var parser = new hscript.Parser();
		try{
			parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;

			var program;
			// parser.parseModule(songScript);
			program = parser.parseString(songScript);

			if (brTools != null) {
				trace('Using hsBrTools');
				interp.variables.set("BRtools",brTools); 
				brTools.reset();
			}else {
				trace('Using assets folder');
				interp.variables.set("BRtools",new HSBrTools("assets/"));
			}
			interp.variables.set("charGet",charGet); 
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
			interp.variables.set("scriptName",id);
			interp.variables.set("close",function(id:String){PlayState.instance.unloadInterp(id);}); // Closes a script
			interp.execute(program);
			interps[id] = interp;
			if(brTools != null)brTools.reset();
			callInterp("initScript",[],id);
			interpCount++;
		}catch(e){
			handleError('Error parsing ${id} hscript, Line:${parser.line};\n Error:${e.message}');
			// interp = null;
		}
		trace('Loaded ${id} script!');
	}
	static function charGet(charId:Int,field:String):Dynamic{
		return Reflect.field(switch(charId){
			case 1: dad; 
			case 2: gf;
			default: boyfriend;
		},field);
	}
	static public function charSet(charId:Int,field:String,value:Dynamic){
		Reflect.setField(switch(charId){case 1: dad; case 2: gf; default: boyfriend;},field,value);
	}
	static public function charAnim(charId:Dynamic = 0,animation:String = "",?forced:Bool = false){
		if(charId.playAnim == null){
			try{
				charId = Std.string(charId);
			}catch(e){
				return boyfriend.playAnim(animation,forced);
			}
			charId = switch(charId){case "1" | "dad" | "opponent" | "p2": dad; case "2" | "gf" | "girlfriend" | "p3": gf; default: boyfriend;};
		}
		charId.playAnim(animation,forced);
	}
	public function clearVariables(){
		stepAnimEvents = [];
		beatAnimEvents = [];
		if(unspawnNotes != null){
			for (i in unspawnNotes) {
				i.destroy();
			}
		}
		notesHitArray = [];
		unspawnNotes = [];
		strumLineNotes = null;
		playerStrums = null;
		cpuStrums = null;
		practiceMode = (FlxG.save.data.practiceMode || ChartingState.charting);
		introAudio = [
			Paths.sound('intro3'),
			Paths.sound('intro2'),
			Paths.sound('intro1'),
			Paths.sound('introGo'),
		];
		introGraphics = [
			"",
			"",
			Paths.image('ready'),
			Paths.image("set"),
			Paths.image("go"),
		];
	}
	public static var hasStarted = false;
	public static var ignoreScripts:Array<String> = [
		"state",
		"options"
	];
	public function requireScript(v:String,?important:Bool = false,?nameSpace:String = "requirement",?script:String = ""):Bool{
		if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket == null){return false;}
		if(interps['${nameSpace}-${v}'] != null || interps['global-${v}'] != null) return true; // Don't load the same script twice
		trace('Checking for ${v}');
		if (FileSystem.exists('mods/scripts/${v}/script.hscript')){
			parseHScript(File.getContent('mods/scripts/${v}/script.hscript'),new HSBrTools('mods/scripts/${v}',v),'${nameSpace}-${v}');
		// }else if (FileSystem.exists('mods/dependancies/${v}/script.hscript')){
		// 	parseHScript(File.getContent('mods/dependancies/${v}/script.hscript'),new HSBrTools('mods/dependancies/${v}',v),'${nameSpace}-${v}');
		}else{showTempmessage('Script \'${v}\'' + (if(script == "") "" else ' required by \'${script}\'') + ' doesn\'t exist!');}
		if(important && interps['${nameSpace}-${v}'] == null){handleError('$script is missing a script: $v!');}
		return ((interps['${nameSpace}-${v}'] == null));
	}
	public function loadSingleScript(v:String){

		for (i in ignoreScripts) {
			if(v.contains(i)) return;
		}
		var e = v.substr(0,v.lastIndexOf("/"));
		e = e.substr(0,e.lastIndexOf("/"));
		parseHScript(File.getContent('${v}'),new HSBrTools(v.substr(0,v.lastIndexOf("/"))),'${e}-${v.substr(v.lastIndexOf("/"))}');
	}
	public function loadScript(v:String){
		if (FileSystem.exists('mods/scripts/${v}')){
			for (i in ignoreScripts) {
				if(v.contains(i)) return;
			}
			var brtool = new HSBrTools('mods/scripts/${v}',v);
			for (i in CoolUtil.orderList(FileSystem.readDirectory('mods/scripts/${v}/'))) {
				if(i.endsWith(".hscript")){
					parseHScript(File.getContent('mods/scripts/${v}/$i'),brtool,'global-${v}-${i}');
				}
			}
			// parseHScript(File.getContent('mods/scripts/${v}/script.hscript'),new HSBrTools('mods/scripts/${v}',v),'global-${v}');
		}else{showTempmessage('Global script \'${v}\' doesn\'t exist!');}
	}
	override public function new(){
		super();
		PlayState.player1 = "";
		PlayState.player2 = "";
		PlayState.player3 = "";
	}
	override public function create()
	{
		#if !debug
		try{
		#end
		if (instance != null) instance.destroy();
		downscroll = FlxG.save.data.downscroll;
		middlescroll = FlxG.save.data.middleScroll;
		setInputHandlers(); // Sets all of the handlers for input
		instance = this;
		clearVariables();
		hasStarted = true;
		logGameplay = FlxG.save.data.logGameplay;


		if (PlayState.songScript == "" && SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()] != null) songScript = SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()];
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		resetScore();

		if(ChartingState.charting){
			if (TitleState.retChar(PlayState.SONG.player1) != "") player1 = TitleState.retChar(PlayState.SONG.player1);
			else if(FlxG.save.data.playerChar == "automatic") player1 = "bf";
			else player1 = FlxG.save.data.playerChar;
		}else{
			if (FlxG.save.data.playerChar == "automatic"){
				if (TitleState.retChar(PlayState.SONG.player1) != "") player1 = TitleState.retChar(PlayState.SONG.player1);
				else player1 = "bf";
			}else player1 = FlxG.save.data.playerChar;
		}
		TitleState.loadNoteAssets(); // Make sure note assets are actually loaded
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camTOP = new FlxCamera();
		camTOP.bgColor.alpha = 0;


		// Note splashes
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(FlxG.height * 0.85, FlxG.width * 0.9, 0);
		noteSplash0.cameras = [camHUD];

		grpNoteSplashes.add(noteSplash0);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camTOP);

		FlxCamera.defaultCameras = [camGame];



		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale);
	
		
		//dialogue shit
		loadDialog();
		// Stage management
		var bfPos:Array<Float> = [0,0]; 
		var gfPos:Array<Float> = [0,0]; 
		var dadPos:Array<Float> = [0,0]; 
		 // Oh my god this code hurts my soul, but I really don't want to recreate it
		if (FlxG.save.data.preformance){
			defaultCamZoom = 0.9;
			curStage = 'stage';
			stageTags = ["inside","stage"];
			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = false;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);
		}else{
			if (FlxG.save.data.selStage != "default"){SONG.stage = FlxG.save.data.selStage;}
			switch(SONG.stage.toLowerCase()){
					case 'halloween': 
					{
						curStage = 'spooky';
						halloweenLevel = true;
						stageTags = ["spooky","inside"];
						var hallowTex = Paths.getSparrowAtlas('halloween_bg','week2');
		
						halloweenBG = new FlxSprite(-200, -100);
						halloweenBG.frames = hallowTex;
						halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
						halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
						halloweenBG.animation.play('idle');
						halloweenBG.antialiasing = true;
						add(halloweenBG);
		
						isHalloween = true;
					}
					case 'philly': 
							{
							curStage = 'philly';
							stageTags = ["outside"];
							var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
							bg.scrollFactor.set(0.1, 0.1);
							add(bg);
		
							var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
							city.scrollFactor.set(0.3, 0.3);
							city.setGraphicSize(Std.int(city.width * 0.85));
							city.updateHitbox();
							add(city);
		
							phillyCityLights = new FlxTypedGroup<FlxSprite>();
							if(FlxG.save.data.distractions){
								add(phillyCityLights);
							}
		
							for (i in 0...5)
							{
									var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
									light.scrollFactor.set(0.3, 0.3);
									light.visible = false;
									light.setGraphicSize(Std.int(light.width * 0.85));
									light.updateHitbox();
									light.antialiasing = true;
									phillyCityLights.add(light);
							}
		
							var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
							add(streetBehind);
		
							phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
							if(FlxG.save.data.distractions){
								add(phillyTrain);
							}
		
							trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
							FlxG.sound.list.add(trainSound);
		
							// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
		
							var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
							add(street);
					}
					case 'limo':
					{
							curStage = 'limo';
							defaultCamZoom = 0.90;
							stageTags = ["outside","windy"];

		
							var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
							skyBG.scrollFactor.set(0.1, 0.1);
							add(skyBG);
		
							var bgLimo:FlxSprite = new FlxSprite(-200, 480);
							bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo','week4');
							bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
							bgLimo.animation.play('drive');
							bgLimo.scrollFactor.set(0.4, 0.4);
							add(bgLimo);
							if(FlxG.save.data.distractions){
								grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
								add(grpLimoDancers);
			
								for (i in 0...5)
								{
										var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
										dancer.scrollFactor.set(0.4, 0.4);
										grpLimoDancers.add(dancer);
								}
							}
		
							var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay','week4'));
							overlayShit.alpha = 0.5;
							// add(overlayShit);
		
							// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
		
							// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
		
							// overlayShit.shader = shaderBullshit;
		
							var limoTex = Paths.getSparrowAtlas('limo/limoDrive','week4');
		
							limo = new FlxSprite(-120, 550);
							limo.frames = limoTex;
							limo.animation.addByPrefix('drive', "Limo stage", 24);
							limo.animation.play('drive');
							limo.antialiasing = true;
		
							fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol','week4'));
							// add(limo);
					}
					case 'mall':
					{
							curStage = 'mall';
							stageTags = ["inside","christmas"];
							defaultCamZoom = 0.80;
		
							var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);
		
							upperBoppers = new FlxSprite(-240, -90);
							upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
							upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
							upperBoppers.antialiasing = true;
							upperBoppers.scrollFactor.set(0.33, 0.33);
							upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
							upperBoppers.updateHitbox();
							if(FlxG.save.data.distractions){
								add(upperBoppers);
							}
		
		
							var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
							bgEscalator.antialiasing = true;
							bgEscalator.scrollFactor.set(0.3, 0.3);
							bgEscalator.active = false;
							bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
							bgEscalator.updateHitbox();
							add(bgEscalator);
		
							var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
							tree.antialiasing = true;
							tree.scrollFactor.set(0.40, 0.40);
							add(tree);
		
							bottomBoppers = new FlxSprite(-300, 140);
							bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
							bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
							bottomBoppers.antialiasing = true;
							bottomBoppers.scrollFactor.set(0.9, 0.9);
							bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
							bottomBoppers.updateHitbox();
							if(FlxG.save.data.distractions){
								add(bottomBoppers);
							}
		
		
							var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
							fgSnow.active = false;
							fgSnow.antialiasing = true;
							add(fgSnow);
		
							santa = new FlxSprite(-840, 150);
							santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
							santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
							santa.antialiasing = true;
							if(FlxG.save.data.distractions){
								add(santa);
							}
					}
					case 'mallevil':
					{
							curStage = 'mallEvil';
							stageTags = ["inside","christmas","spooky"];
							var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);
		
							var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
							evilTree.antialiasing = true;
							evilTree.scrollFactor.set(0.2, 0.2);
							add(evilTree);
		
							var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
								evilSnow.antialiasing = true;
							add(evilSnow);
							}
					case 'school':
					{
							curStage = 'school';
							stageTags = ["outside","pixel"];
		
							// defaultCamZoom = 0.9;
		
							var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
							bgSky.scrollFactor.set(0.1, 0.1);
							add(bgSky);
		
							var repositionShit = -200;
							var y = 0;
							gfPos = [0,5];
		
							var bgSchool:FlxSprite = new FlxSprite(repositionShit, y).loadGraphic(Paths.image('weeb/weebSchool','week6'));
							bgSchool.scrollFactor.set(0.6, 0.90);
							add(bgSchool);
		
							var bgStreet:FlxSprite = new FlxSprite(repositionShit, y).loadGraphic(Paths.image('weeb/weebStreet','week6'));
							bgStreet.scrollFactor.set(0.95, 0.95);
							add(bgStreet);
		
							var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, y + 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
							fgTrees.scrollFactor.set(0.9, 0.9);
							add(fgTrees);
		
							var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, y + -800);
							var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
							bgTrees.frames = treetex;
							bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
							bgTrees.animation.play('treeLoop');
							bgTrees.scrollFactor.set(0.85, 0.85);
							add(bgTrees);
		
							var treeLeaves:FlxSprite = new FlxSprite(repositionShit, y + -40);
							treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
							treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
							treeLeaves.animation.play('leaves');
							treeLeaves.scrollFactor.set(0.85, 0.85);
							add(treeLeaves);
		
							var widShit = Std.int(bgSky.width * 6);
		
							bgSky.setGraphicSize(widShit);
							bgSchool.setGraphicSize(widShit);
							bgStreet.setGraphicSize(widShit);
							bgTrees.setGraphicSize(Std.int(widShit * 1.4));
							fgTrees.setGraphicSize(Std.int(widShit * 0.8));
							treeLeaves.setGraphicSize(widShit);
		
							fgTrees.updateHitbox();
							bgSky.updateHitbox();
							bgSchool.updateHitbox();
							bgStreet.updateHitbox();
							bgTrees.updateHitbox();
							treeLeaves.updateHitbox();
		
							bgGirls = new BackgroundGirls(-100, y + 190);
							bgGirls.scrollFactor.set(0.9, 0.9);
		
							if (SONG.song.toLowerCase() == 'roses')
								{
									if(FlxG.save.data.distractions){
										bgGirls.getScared();
									}
								}
		
							bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
							bgGirls.updateHitbox();
							if(FlxG.save.data.distractions){
								add(bgGirls);
						}
					}
					case 'schoolevil':
					{
							curStage = 'schoolEvil';
							stageTags = ["outside","pixel"];
							var y = 200;
		
							var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
							var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
		
							var posX = 400;
							var posY = 200;
		
							var bg:FlxSprite = new FlxSprite(posX, posY);
							bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
							bg.animation.addByPrefix('idle', 'background 2', 24);
							bg.animation.play('idle');
							bg.scrollFactor.set(0.8, 0.9);
							bg.scale.set(6, 6);
							add(bg);
					}
					case 'stage','default':
					{
								defaultCamZoom = 0.9;
								curStage = 'stage';
								stageTags = ["inside","stage"];
								var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
								bg.antialiasing = true;
								bg.scrollFactor.set(0.9, 0.9);
								bg.active = false;
								add(bg);
			
								var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
								stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(0.9, 0.9);
								stageFront.active = false;
								add(stageFront);
			
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;
			
								add(stageCurtains);
					}
					default:
					{	
						var stage:String = TitleState.retStage(SONG.stage);
						if(stage == "nothing"){
							stageTags = ["empty"];
							defaultCamZoom = 0.9;
							curStage = 'nothing';
						}else if(stage == "" || !FileSystem.exists('mods/stages/$stage')){
								trace('"${SONG.stage}" not found, using "Stage"!');
								stageTags = ["inside"];
								defaultCamZoom = 0.9;
								curStage = 'stage';
								var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
								bg.antialiasing = true;
								bg.scrollFactor.set(0.9, 0.9);
								bg.active = false;
								add(bg);
			
								var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
								stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(0.9, 0.9);
								stageFront.active = false;
								add(stageFront);
			
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;
			
								add(stageCurtains);
						}else{
							curStage = SONG.stage;
							stageTags = [];
							var stagePath:String = 'mods/stages/$stage';
							if (FileSystem.exists('$stagePath/config.json')){
								// var stagePropJson:String = File.getContent('$stagePath/config.json');
								// var stageProperties:StageJSON = haxe.Json.parse(CoolUtil.cleanJSON(stagePropJson));
								// if (stageProperties == null || stageProperties.layers == null || stageProperties.layers[0] == null){MainMenuState.handleError('$stage\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
								// defaultCamZoom = stageProperties.camzoom;
								// for (layer in stageProperties.layers) {
								// 	if(layer.song != null && layer.song != "" && layer.song.toLowerCase() != SONG.song.toLowerCase()){continue;}
								// 	var curLayer:FlxSprite = new FlxSprite(0,0);
								// 	if(layer.animated){
								// 		var xml:String = File.getContent('$stagePath/${layer.name}.xml');
								// 		if (xml == null || xml == "")MainMenuState.handleError('$stage\'s XML is invalid!');
								// 		curLayer.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('$stagePath/${layer.name}.png')), xml);
								// 		curLayer.animation.addByPrefix(layer.animation_name,layer.animation_name,layer.fps,false);
								// 		curLayer.animation.play(layer.animation_name);
								// 	}else{
								// 		var png:BitmapData = BitmapData.fromFile('$stagePath/${layer.name}.png');
								// 		if (png == null) MainMenuState.handleError('$stage\'s PNG is invalid!');
								// 		curLayer.loadGraphic(png);
								// 	}

								// 	if (layer.centered) curLayer.screenCenter();
								// 	if (layer.flip_x) curLayer.flipX = true;
								// 	curLayer.setGraphicSize(Std.int(curLayer.width * layer.scale));
								// 	curLayer.updateHitbox();
								// 	curLayer.x += layer.pos[0];
								// 	curLayer.y += layer.pos[1];
								// 	curLayer.antialiasing = layer.antialiasing;
								// 	curLayer.alpha = layer.alpha;
								// 	curLayer.active = false;
								// 	curLayer.scrollFactor.set(layer.scroll_factor[0],layer.scroll_factor[1]);
								// 	add(curLayer);
								// }
								var stageProperties = StageEditor.loadStage(this,'$stagePath/config.json');
								
								 // This doesn't have to be provided, doing it this way
								bfPos = stageProperties.bfPos;
								dadPos = stageProperties.dadPos;
								gfPos = stageProperties.gfPos;
								stageTags = stageProperties.tags;
								if(gfShow) gfShow = stageProperties.showGF;
							}
							var brTool = new HSBrTools(stagePath);
							for (i in CoolUtil.orderList(FileSystem.readDirectory(stagePath))) {
								if(i.endsWith(".hscript")){
									parseHScript(File.getContent('$stagePath/$i'),brTool,"STAGE-" + i);
								}
							}
							
						}
					}
				}
		}
		parseHScript(songScript,null,"song");
		if(QuickOptionsSubState.getSetting("Song hscripts") && FlxG.save.data.scripts != null){
			for (i in 0 ... FlxG.save.data.scripts.length) {
				
				var v = FlxG.save.data.scripts[i];
				trace('Checking for ${v}');
				loadScript(v);
			}
		}
		if(QuickOptionsSubState.getSetting("Song hscripts")){
			for (i in 0 ... scripts.length) {
				
				var v = scripts[i];
				trace('Loading ${v}');
				loadSingleScript(v);
			}
		}
		if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket != null){
			for (i in 0 ... onlinemod.OnlinePlayMenuState.scripts.length) {
				
				var v = onlinemod.OnlinePlayMenuState.scripts[i];
				trace('Checking for ${v}');
				loadScript(v);
			}
		}

		if(onlinemod.OnlinePlayMenuState.socket != null){

			for (i in 0 ... onlinemod.OnlinePlayMenuState.rawScripts.length) {
				parseHScript(onlinemod.OnlinePlayMenuState.rawScripts[i][1],hsBrTools,onlinemod.OnlinePlayMenuState.rawScripts[i][0]);
			}
		}
		if(PlayState.player2 == "")PlayState.player2 = SONG.player2;
		if(PlayState.player3 == "")PlayState.player3 = SONG.gfVersion;
		callInterp("afterStage",[]);


		if ((FlxG.save.data.charAuto || PlayState.isStoryMode || ChartingState.charting) && TitleState.retChar(PlayState.player2) != ""){ // Check is second player is a valid character
			PlayState.player2 = TitleState.retChar(PlayState.player2);
		}else{
			PlayState.player2 = FlxG.save.data.opponent;
    	}
		// if (invertedChart){ // Invert players if chart is inverted, Does not swap sides, just changes character names
		// 	var pl:Array<String> = [player1,player2];
		// 	player1 = pl[1];
		// 	player2 = pl[0];
		// }
		if(loadChars){
			switch (SONG.gfVersion)
			{
				case 'gf-car':
					player3 = 'gf-car';
				case 'gf-christmas':
					player3 = 'gf-christmas';
				case 'gf-pixel':
					player3 = 'gf-pixel';
				default:
					player3 = 'gf';
			}
			if (FlxG.save.data.gfChar != "gf"){player3=FlxG.save.data.gfChar;}
			gfChar = player3;
			 gf = (if (FlxG.save.data.gfShow && loadChars && gfShow) new Character(400, 100, player3,false,2) else new EmptyCharacter(400, 100));
			gf.scrollFactor.set(0.95, 0.95);
			if (!ChartingState.charting && SONG.player1.startsWith("gf") && FlxG.save.data.charAuto) player1 = FlxG.save.data.gfChar;
			if (!ChartingState.charting && SONG.player2.startsWith("gf") && FlxG.save.data.charAuto) player2 = FlxG.save.data.gfChar;
			 dad = (if (dadShow && FlxG.save.data.dadShow && loadChars && !(player3 == player2 && player1 != player2)) new Character(100, 100, player2,false,1) else new EmptyCharacter(100, 100));
			 boyfriend = (if (FlxG.save.data.bfShow && loadChars) new Character(770, 100, player1,true,0) else new EmptyCharacter(770,100));
		}else{
			dad = new EmptyCharacter(100, 100);
			boyfriend = new EmptyCharacter(400,100);
			gf = new EmptyCharacter(400, 100);
		}
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);

		camPos.set(camPos.x + gf.camX, camPos.y + gf.camY);
		

		// REPOSITIONING PER STAGE
		switch (curStage.toLowerCase())
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions){
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
		}
		for (i => v in [bfPos,dadPos,gfPos]) {
			if (v[0] != 0 || v[1] != 0){
				switch(i){
					case 0:boyfriend.x+=v[0];boyfriend.y+=v[1];
					case 1:dad.x+=v[0];dad.y+=v[1];
					case 2:gf.x+=v[0];gf.y+=v[1];
				}
			}
		}
		if (player3 == player2 && player1 != player2){// Don't hide GF if player 1 is GF
				// dad.setPosition(gf.x, gf.y);
				dad.destroy();
				dad = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}

		if (player3 == player1){
			if (player1 != player2){	// Don't hide GF if player 1 is GF
				boyfriend.destroy();
				boyfriend = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
		}
		// if (dad.spiritTrail && FlxG.save.data.distractions){
		// 	var dadTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		// 	add(dadTrail);
		// }
		// if (boyfriend.spiritTrail && FlxG.save.data.distractions){
		// 	var bfTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
		// 	add(bfTrail);
		// }


		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);


		

		charCall("addGF",[],-1);
		callInterp("addGF",[]);
		add(dad);
		charCall("addDad",[],-1);
		callInterp("addDad",[]);
		add(boyfriend);
		callInterp("addChars",[]);
		charCall("addChars",[],-1);


		// if (loadRep)
		// {
		// 	FlxG.watch.addQuick('rep rpesses',repPresses);
		// 	FlxG.watch.addQuick('rep releases',repReleases);
			
		// 	FlxG.save.data.botplay = true;
		// 	FlxG.save.data.scrollSpeed = rep.replay.noteSpeed;
		// 	downscroll = rep.replay.isDownscroll;
		// 	// FlxG.watch.addQuick('Queued',inputsQueued);
		// }
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		if((dialogue != null && dialogue[0] != null)){

			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdownFirst;
		}

		Conductor.songPosition = -5000;
		if(FlxG.save.data.undlaTrans > 0){
			underlay = new FlxSprite(-100,-100).makeGraphic((if(FlxG.save.data.undlaSize == 0)Std.int(Note.swagWidth * 4 + 4) else 1920),1080,0xFF000010);
			underlay.alpha = FlxG.save.data.undlaTrans;
			underlay.cameras = [camHUD];
			add(underlay);
			
		}
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<StrumArrow>();
		add(strumLineNotes);

		add(grpNoteSplashes);
		if (SONG.difficultyString != null && SONG.difficultyString != "") songDiff = SONG.difficultyString;
		else songDiff = if(customDiff != "") customDiff else if(stateType == 4) "mods/charts" else if (stateType == 5) "osu! beatmap" else (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		playerStrums = new FlxTypedGroup<StrumArrow>();
		cpuStrums = new FlxTypedGroup<StrumArrow>();

		// startCountdown();



		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		followChar(0,true);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		// FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG_ = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
				if (downscroll)
					songPosBG_.y = FlxG.height * 0.9 + 45 - FlxG.save.data.guiGap; 
				songPosBG_.screenCenter(X);
				songPosBG_.scrollFactor.set();
				// add(songPosBG_);
				
				songPosBar_ = new FlxBar(songPosBG_.x + 4, songPosBG_.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG_.width - 8), Std.int(songPosBG_.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar_.scrollFactor.set();
				songPosBar_.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				// add(songPosBar_);
	
				songName = new FlxText(songPosBG_.x + (songPosBG_.width / 2) - 20,songPosBG_.y,0,SONG.song, 16);
				if (downscroll)
					songName.y -= 3;
				songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				// add(songName);
				songName.cameras = [camHUD];
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9 - FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
		if (downscroll)
			healthBarBG.y = 50 + FlxG.save.data.guiGap;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,'health', 0, 2);
		
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.definingColor, boyfriend.definingColor);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		

		if(actualSongName == ""){
			actualSongName = (if(ChartingState.charting) "Charting" else curSong + " " + songDiff);
		}
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50 - FlxG.save.data.guiGap,0,actualSongName + " - " + inputEngineName, 16);
		kadeEngineWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		if(QuickOptionsSubState.getSetting("Flippy mode")){
			practiceMode = true;
			flippy = true;
			kadeEngineWatermark.text = actualSongName + " - fucking flippy mode lmao";
		}
		add(kadeEngineWatermark);

		if (downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap;

		// scoreTxtX = FlxG.width * ;
		
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 3) {
			scoreTxt = new FlxText(50, healthBarBG.y + 30 - FlxG.save.data.guiGap, 0, (FlxG.save.data.npsDisplay ? "NPS: 0000 (Max 0000)" : "") +                // NPS Toggle
				" | Score:00000000"+                               // Score
				" | Combo:00000"+
				" | Combo Breaks:00000" + PlayState.misses + 																				// Misses/Combo Breaks
				"\n | Accuracy:000.000%" +  				// Accuracy
				" | F", 20);
			scoreTxt.autoSize = false;
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "center";
		}else {
			scoreTxt = new FlxText(10 + FlxG.save.data.guiGap, FlxG.height * 0.46 , 600, "NPS: 000000\nScore:00000000\nCombo:00000 (Max 00000)\nCombo Breaks:00000\nAccuracy:0000 %\n Unknown", 20); // Long ass text to make sure it's sized correctly
			// scoreTxt.autoSize = true;
			// scoreTxt.width += 300;
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "center";
			scoreTxt.screenCenter(X);
		}

		
		// if (!FlxG.save.data.accuracyDisplay)
		// 	scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		// Literally copy-paste of the above, fu

		

		iconP1 = new HealthIcon(player1, true,boyfriend.clonedChar,boyfriend.charLoc);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(player2, false,dad.clonedChar,dad.charLoc);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		// iconP2.offset.set(0,iconP2.width);

		add(iconP2);

		callInterp("addUI",[]);
		charCall("addUI",[],-1);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		if(practiceMode){
			// if(practiceMode ){
			practiceText = new FlxText(0,healthBar.y - 64,(if(flippy)"Flippy Mode" else if(ChartingState.charting) "Testing Chart" else "Practice mode"),16);
			practiceText.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			practiceText.cameras = [camHUD];
			practiceText.screenCenter(X);
			insert(members.indexOf(healthBar),practiceText);
			FlxTween.tween(practiceText,{alpha:0},1,{type:PINGPONG});
			// }
			healthBar.visible = healthBarBG.visible = false;
			var iconOffset = 26;
			if(middlescroll){
				iconP2.x = FlxG.width * 0.05;
				iconP1.x = FlxG.width * 0.95 - iconP1.width;
			}else{
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01) - iconOffset);

			}
			var y = (downscroll ? FlxG.height * 0.9 : FlxG.height * 0.1);
			iconP2.y = iconP1.y = y - (iconP1.height * 0.5);
		}
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if(doof != null) doof.cameras = [camHUD];
		iconP1.y = healthBarBG.y - (iconP1.height / 2);
		iconP2.y = healthBarBG.y - (iconP2.height / 2);
		// if (FlxG.save.data.songPosition)
		// {
		// 	songPosBG_.cameras = [camHUD];
		// 	songPosBar_.cameras = [camHUD];
		// }
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		hitSound = FlxG.save.data.hitSound;
		if(FlxG.save.data.hitSound && hitSoundEff == null) hitSoundEff = Sound.fromFile(( if (FileSystem.exists('mods/hitSound.ogg')) 'mods/hitSound.ogg' else Paths.sound('Normal_Hit')));

		if(hurtSoundEff == null) hurtSoundEff = Sound.fromFile(( if (FileSystem.exists('mods/hurtSound.ogg')) 'mods/hurtSound.ogg' else Paths.sound('ANGRY')));
		if(vanillaHurtSounds[0] == null && FlxG.save.data.playMisses) vanillaHurtSounds = [Sound.fromFile('assets/shared/sounds/missnote1.ogg'),Sound.fromFile('assets/shared/sounds/missnote2.ogg'),Sound.fromFile('assets/shared/sounds/missnote3.ogg')];

		startingSong = true;
		
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdownFirst();
								}
							});
						});
					});
				case 'senpai','thorns':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				default:
					if(dialogue[0] != null){
						schoolIntro(doof);

					}else{
						startCountdownFirst();
					}
					// startCountdownFirst();
			}
		}
		else
		{
			startCountdownFirst();
		}

		// if (!loadRep)
		// 	rep = new Replay("na");
		
		add(scoreTxt);
		// FlxG.sound.cache("missnote1");
		// FlxG.sound.cache("missnote2");
		// FlxG.sound.cache("missnote3");

		super.create();



		openfl.system.System.gc();
	#if !debug 
	}catch(e){MainMenuState.handleError(e,'Caught "create" crash: ${e.message}\n ${e.stack}');}
	#end
	}
	function loadDialog(){		
		// dialogue = [];
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = CoolUtil.coolFormat("dad:Hey you're pretty cute.
				dad:Use the arrow keys to keep up\\nwith me singing.");
			case 'bopeebo':
				dialogue = CoolUtil.coolFormat(
					'dad:HEY!\n' +
					'bf:Beep?\n' +
					"dad:You think you can just sing\\nwith my daughter like that?\n" +
					"dad:If you want to date her...\\n" +
					"dad:You're going to have to go \\nthrough ME first!\n" +
					'bf:Beep bop!'
				);
			case 'fresh':
				dialogue = CoolUtil.coolFormat("dad:Not too shabby boy.\ndad:But I'd like to see you\\n keep up with this!");
			case 'dad battle':
				dialogue = CoolUtil.coolFormat(
					"dad:Gah, you think you're hot stuff?\n"+
					"dad:If you can beat me here...\n"+
					"dad:Only then I will even CONSIDER letting you\\ndate my daughter!"
				);
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}
	}



	// public static function regAnimEvent(charType:Int,ifState:IfStatement,animName:String){
	// 	PlayState.animEvents[charType][animName] = ifState;
	// }


	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		if(SONG.song.toLowerCase() == 'thorns'){
			senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
			senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
			senpaiEvil.scrollFactor.set();
			senpaiEvil.updateHitbox();
			senpaiEvil.screenCenter();
		}

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}
		
		// FlxTween.tween(black,0.3)
		playCountdown = false;
		// startCountdownFirst();
		FlxTween.tween(black, {alpha: 0}, 1, {
			onComplete: function(twn:FlxTween){
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdownFirst();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdownFirst(){ // Skip the 
		callInterp("startCountdownFirst",[]);
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		// camFollow.setPosition(720, 500);

		canPause = true;
		updateCharacterCamPos();
		if (!generatedArrows){
			generatedArrows = true;
			generateStaticArrows(0);
			generateStaticArrows(1);

		}
		if (!playCountdown){
			playerStrums.visible = cpuStrums.visible = false;
			playCountdown = true;
			return;
		}

		startCountdown();
	}

	var playCountdown = true;
	var generatedArrows = false;
	public var swappedChars = false;
	public function swapChars(?what:Bool = false){
		// if(settings && !) return;
		var bf:Character = boyfriend;
		var opp:Character = dad;
		boyfriend = opp;
		dad = bf;
		boyfriend.isPlayer = true;
		dad.isPlayer = false;
		swappedChars = !swappedChars;
		healthBar.fillDirection = (swappedChars ? LEFT_TO_RIGHT : RIGHT_TO_LEFT);
		// if(swappedChars){
		// 	healthBar.createFilledBar(boyfriend.definingColor, dad.definingColor);
		// }else{
		healthBar.createFilledBar(dad.definingColor, boyfriend.definingColor);
		// }
		if(!middlescroll){ // This is dumb but whatever
			var plStrumX = [];
			var oppStrumX = [];
			for (i in playerStrums.members) {
				plStrumX[i.ID] = i.x;
			}
			for (i in cpuStrums.members) {
				oppStrumX[i.ID] = i.x;
			}
			for (i in [0,1,2,3]) {
				playerStrums.members[i].x = oppStrumX[i];
			}
			for (i in [0,1,2,3]) {
				cpuStrums.members[i].x = plStrumX[i];
			}
		}
		if(underlay != null && FlxG.save.data.undlaSize == 0){
			underlay.x = playerStrums.members[0].x -2;
		}
		updateCharacterCamPos();
	}
	public static var introAudio:Array<flixel.system.FlxAssets.FlxSoundAsset> = [
	];
	public static var introGraphics:Array<flixel.system.FlxAssets.FlxGraphicAsset> = [
	];
	public function startCountdown():Void
	{
		dialogue = [];

		inCutscene = false;

		if(!songStarted){

			if (!generatedArrows){
				generatedArrows = true;
				generateStaticArrows(0);
				generateStaticArrows(1);
				
			}
			if(invertedChart || (onlinemod.OnlinePlayMenuState.socket == null && QuickOptionsSubState.getSetting("Swap characters")))
				swapChars();
			playerStrums.visible = cpuStrums.visible = true;
			FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			// camFollow.setPosition(720, 500);


			
			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;
			if(jumpTo != 0){
				Conductor.songPosition = FlxG.sound.music.time = vocals.time = jumpTo;
				jumpTo = 0;
			}
			trace(introAudio.length);
			Conductor.songPosition -= (introAudio.length + 1) * 500;
			trace(Conductor.songPosition);
			// loadPositions();


			if(errorMsg != "") {handleError(errorMsg,true);return;}
		}
		var swagCounter:Int = 0;
		
		callInterp("startCountdown",[]);
		


		startTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			dad.dance();
			if(gf != boyfriend && gf != dad) gf.dance();
			boyfriend.dance();
			trace('Countdown ${swagCounter}');


			// for (value in introAssets.keys())
			// {
			// 	if (value == curStage)
			// 	{
			// 		introAlts = introAssets.get(value);
			// 	}
			// }
			callInterp("startTimerStep",[swagCounter]);
			if(playCountdown){

				switch (swagCounter)
				{
					case 0:
						if (errorMsg != ""){
							handleError(errorMsg);
							startTimer.cancel();
							return;
						}
					case 1:
					case 2:
					case 3:
					case 4:
						
				}
				if(introGraphics[swagCounter] != null && introGraphics[swagCounter] != ""){
					var go:FlxSprite = new FlxSprite().loadGraphic(introGraphics[swagCounter]);
					go.scrollFactor.set();


					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
				}
				if(introAudio[swagCounter] != null && introAudio[swagCounter] != "")FlxG.sound.play(introAudio[swagCounter],FlxG.save.data.otherVol);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, introAudio.length + 1);
	}

	function charCall(func:String,args:Array<Dynamic>,?char:Int = -1){
		switch(char){
			case 0: boyfriend.callInterp(func,args);
			case 1: dad.callInterp(func,args);
			case 2: gf.callInterp(func,args);
			case -1:
				boyfriend.callInterp(func,args);
				dad.callInterp(func,args);
				gf.callInterp(func,args);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	public var songStarted(default, null):Bool = false;
	function loadPositions(){
		var map:Map<String,KadeEngineData.ObjectInfo> = cast FlxG.save.data.playStateObjectLocations;
		for (i => v in map) {
			var obj = Reflect.field(this,i);
			if(obj != null){
				if(!Std.isOfType(obj,FlxTypedGroup)){
					FlxTween.tween(obj,{x:v.x,y:v.y},0.4);
				}
				if(GameplayCustomizeState.objs[i] != null){
					for (subIndex => subValue in GameplayCustomizeState.objs[i]) {
						var subObj = Reflect.field(this,subIndex);
						if(subObj != null){
							FlxTween.tween(subObj,{x:v.x + subValue.x,y:v.y + subValue.y},0.4);
						}
					}

				}

				// obj.x = v.x;
				// obj.y = v.y;
			}
		}
	}
	function startSong(?alrLoaded:Bool = false):Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!alrLoaded)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), FlxG.save.data.instVol, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
		if (FlxG.save.data.songPosition)
		{
			addSongBar();
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		if(errorMsg != "") {handleError(errorMsg,true);return;}
		charCall("startSong",[]);
		callInterp("startSong",[]);


		updateTime = FlxG.save.data.songPosition;
		

	}

	function addSongBar(?minimal:Bool = false){

			if(songPosBG_ != null) remove(songPosBG_);
			if(songPosBar_ != null) remove(songPosBar_);
			if(songName != null) remove(songName);
			if(songTimeTxt != null) remove(songTimeTxt);
			songPosBG_ = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
			// songPosBG_.scale.set(1,2);
			// songPosBG_.updateHitbox();
			if (downscroll)
				songPosBG_.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap; 
			songPosBG_.screenCenter(X);
			songPosBG_.scrollFactor.set();

			songPosBar_ = new FlxBar(songPosBG_.x + 4, songPosBG_.y + 4 + FlxG.save.data.guiGap, LEFT_TO_RIGHT, Std.int(songPosBG_.width - 8), Std.int(songPosBG_.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar_.numDivisions = 1000;
			songPosBar_.scrollFactor.set();
			songPosBar_.createFilledBar(FlxColor.GRAY, FlxColor.LIME);

			songName = new FlxText(songPosBG_.x + (songPosBG_.width * 0.2) - 20,songPosBG_.y + 1,0,SONG.song, 16);
			songName.x -= songName.text.length;
			songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			songTimeTxt = new FlxText(songPosBG_.x + (songPosBG_.width * 0.7) - 20,songPosBG_.y + 1,0,"00:00 | 0:00", 16);
			if (downscroll)
				songName.y -= 3;
			songTimeTxt.text = "00:00 | " + songLengthTxt;
			songTimeTxt.x -= songTimeTxt.text.length;
			songTimeTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songTimeTxt.scrollFactor.set();

			songPosBG_.cameras = [camHUD];
			songPosBar_.cameras = [camHUD];
			songName.cameras = [camHUD];
			songTimeTxt.cameras = [camHUD];
			add(songPosBG_);
			add(songPosBar_);
			add(songName);
			add(songTimeTxt);





		

	}

	var debugNum:Int = 0;

	public function generateSong(?dataPath:String = ""):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		if (vocals == null ){
			if (SONG.needsVoices)
				try{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				}catch(e){
					SONG.needsVoices = false;
					showTempmessage("Song needs voices but none found! Automatically disabled");
					vocals = new FlxSound();

				}
			else
				SONG.needsVoices = false;
				vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		if (notes == null) 
			notes = new FlxTypedGroup<Note>();
		notes.clear();
		// add(notes);
		add(notes);
		Note.lastNoteID = -1;

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;


		callInterp("generateSongBefore",[]);
		// Per song offset check
		
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;

				if (daStrumTime < 0)
					daStrumTime = 0;


				var daNoteData:Int = songNotes[1];


				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				if(jumpTo != 0 && daStrumTime < jumpTo){continue;} // Don't load notes if they aren't from this timezone
				// if(songNotes[3] != null) trace('Note type: ${songNotes[3]}');
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,songNotes[3],songNotes,gottaHitNote);
				if(swagNote.killNote){swagNote.destroy();continue;}
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var lastSusNote = false; // If the last note is a sus note
				var _susNote = -1;
				if(susLength > 0.1){

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,songNotes[3],songNotes,gottaHitNote);
						if(sustainNote.killNote){sustainNote.destroy();continue;}
						sustainNote.scrollFactor.set();
						sustainNote.sustainLength = susLength;
						unspawnNotes.push(sustainNote);
						lastSusNote = true;


						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						_susNote = susNote;
					}
					if(Math.floor(susLength) - susLength > 0.1){ // Allow for float note lengths, hopefully
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * _susNote) + (Conductor.stepCrochet * Math.floor(susLength) - susLength), daNoteData, oldNote, true,null,songNotes[3],songNotes,gottaHitNote);
						sustainNote.scrollFactor.set();
						sustainNote.sustainLength = susLength;
						unspawnNotes.push(sustainNote);
						lastSusNote = true;


						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}

					}

					if (onlinemod.OnlinePlayMenuState.socket == null && lastSusNote){ // Moves last sustain note so it looks right, hopefully
						unspawnNotes[Std.int(unspawnNotes.length - 1)].strumTime -= (Conductor.stepCrochet * 0.4);
						// if(susLength < 2){
						// 	// swagNote.stamp(unspawnNotes[Std.int(unspawnNotes.length - 1)],Std.int(swagNote.width * 0.5),Std.int(swagNote.height * 0.6));
						// 	swagNote.scale.set(swagNote.scale.x,swagNote.scale.y * 1.25);
						// }
					}
				}

				// swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}

			daBeats += 1;
		}
		// try{

		// if(SONG.eventObjects != null && SONG.eventObjects[0] != null){
		// 	for (i in SONG.eventObjects)
		// 	{
		// 		var swagNote:Note = new Note(i.position, -1, null,null,null,i.type,[i.position,-1,i.type],false);
		// 		swagNote.eventNote = true;
		// 		unspawnNotes.push(swagNote);

		// 	}

		// }
		// }catch(e){trace('Unable to load Kade event: ${e.message}');}
		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
		callInterp("generateSong",[]);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{

		// var strumSeperation = 3;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumArrow = new StrumArrow(i,0, strumLine.y);

			// switch (SONG.noteStyle)
			// {
			// 	case 'normal':
			charCall("strumNoteLoad",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteLoad",[babyArrow,player == 1]);
			// babyArrow.x += Note.swagWidth * i + i;
			babyArrow.init();
			// babyArrow.frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
			// babyArrow.animation.addByPrefix('green', 'arrowUP');
			// babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			// babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			// babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			// babyArrow.antialiasing = true;
			// babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			// switch (Math.abs(i))
			// {
			// 	case 0:
			// 		// babyArrow.x += Note.swagWidth * 0;
			// 		babyArrow.animation.addByPrefix('static', 'arrowLEFT');
			// 		babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
			// 		babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
			// 	case 1:
			// 		// babyArrow.x += Note.swagWidth * 1 ;
			// 		babyArrow.animation.addByPrefix('static', 'arrowDOWN');
			// 		babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
			// 		babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
			// 	case 2:
			// 		// babyArrow.x += Note.swagWidth * 2;
			// 		babyArrow.animation.addByPrefix('static', 'arrowUP');
			// 		babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
			// 		babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
			// 	case 3:
			// 		// babyArrow.x += Note.swagWidth * 3 + 4;
			// 		babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
			// 		babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
			// 		babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			// }

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			// if (!isStoryMode)
			// {
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			// }

			babyArrow.ID = i;

			switch (player)
			{
				case 0: 
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static'); 
			// Todo, clean this shitty code up
			if(middlescroll){
				switch(player){
					case 1:{
						babyArrow.screenCenter(X);
						babyArrow.x += (Note.swagWidth * i + i) - ((Note.swagWidth * 1 ) + Note.swagWidth * 0.5);
					}
					case 0:
						// babyArrow.screenCenter(X);
						babyArrow.x = FlxG.width * 0.25;
						if(babyArrow.ID > 1){
							babyArrow.x = FlxG.width * 0.75;
						}	
						babyArrow.x += (Note.swagWidth * i + i) - (Note.swagWidth * 2 + 2);
				}

			}
			else{
				// babyArrow.x += if (middlescroll) 50 else 145;

				// babyArrow.x += if (middlescroll) ((FlxG.width / 4) * player) else ((FlxG.width / 2) * player);
			// if (middlescroll && player == 0 && i > 1) babyArrow.x += Note.swagWidth * 6;
				switch(player){
					case 1:{
						babyArrow.x = FlxG.width * 0.625;
						// babyArrow.x -= Note.swagWidth * 0.5;
					}
					case 0:
						// babyArrow.screenCenter(X);
						babyArrow.x = FlxG.width * 0.15;
						// babyArrow.x += (Note.swagWidth * i + i) - (Note.swagWidth * 2 + 2);
				}
				babyArrow.x += (Note.swagWidth * i + i) - (Note.swagWidth * 1 );
			}
			babyArrow.visible = (player == 1 || FlxG.save.data.oppStrumLine);

			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
			babyArrow.ID = i;
			// if(underlay != null && FlxG.save.data.undlaSize == 0 && i == 0 && player == 1){
			// 	if(middlescroll){
			// 		underlay.screenCenter(X);
			// 	}else{

			// 		underlay.x = babyArrow.x;
			// 	}
			// }
			charCall("strumNoteAdd",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteAdd",[babyArrow,player == 1]);
		}

		if(underlay != null && FlxG.save.data.undlaSize == 0 && player == 1){
			underlay.x = playerStrums.members[0].x -2;
		}

	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			canPause = false;

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			canPause = true;
			paused = false;

		}

		super.closeSubState();
	}
	
	var resyncCount:Int = 0;
	function resyncVocals():Void
	{

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		// vocals.pause();
		if(SONG.needsVoices && (!vocals.playing || vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)){
			vocals.time = FlxG.sound.music.time;
			vocals.play();
		}
		resyncCount++;

	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;
	var finished = false;

	function finishSong(?win=true):Void{
		
		updateTime = false;
		FlxG.camera.zoom = defaultCamZoom;
		camHUD.zoom = 1;
		if (finished) return;
		finished = true;
		PlayState.dadShow = true; // Reenable this to prevent issues later
		canPause = false;
		this.paused = true;
		FlxG.sound.music.pause();
		this.vocals.pause();
		FlxG.sound.music.volume = 0;
		this.vocals.volume = 0;

		openSubState(new FinishSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,win));
		
	}

	var songLengthTxt = "N/A";

	public var interpCount:Int = 0;
	public var lastFrameTime:Float = 0;
	override public function update(elapsed:Float)
	{
		#if !debug
		try{
		perfectMode = false;
		#end


		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		if(FlxG.save.data.npsDisplay){
			var leg = notesHitArray.length-1;
			var curTime = Date.now().getTime();
			while (leg >= 0)
			{
				var funni:Null<Float> = notesHitArray[leg];
				if (funni != null && funni + 1000 < curTime)
					notesHitArray.pop();
				else
					leg = 0;
				leg--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}
		if (combo > maxCombo)
			maxCombo = combo;
		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		PlayState.canUseAlts = (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim);

		super.update(elapsed);
		callInterp("update",[elapsed]);

		
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;
		else
			scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);

		// if(FlxG.save.data.songInfo == 0) scoreTxt.x = scoreTxtX - scoreTxt.text.length;
		if (updateTime) songTimeTxt.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if(!practiceMode){
			var iconOffset:Int = 26;
			if(healthBar.fillDirection == LEFT_TO_RIGHT){
				iconP1.x = (healthBar.x + healthBar.width - iconOffset) - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01));
				iconP2.x = (healthBar.x + healthBar.width - (iconP2.width - iconOffset)) - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01));

			}else{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - (iconOffset));
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - (iconP2.width - iconOffset));


			}
		}
		// else{
		// 	iconP1.y = playerStrums.members[0].y - (iconP1.height / 2);
		// 	iconP2.y = playerStrums.members[0].y - (iconP2.height / 2);
		// }

		if (health > 2)
			health = 2;
		if(swappedChars){

			iconP2.updateAnim(healthBar.percent);
			iconP1.updateAnim(100 - healthBar.percent);
		}else{

			iconP1.updateAnim(healthBar.percent);
			iconP2.updateAnim(100 - healthBar.percent);
		}		
		// if (healthBar.percent < 20)
		// 	iconP1.animation.curAnim.curFrame = 1;
		// else
		// 	iconP1.animation.curAnim.curFrame = 0;

		// if (healthBar.percent > 80)
		// 	iconP2.animation.curAnim.curFrame = 1;
		// else
		// 	iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */
		testanimdebug();


		if (startingSong && handleTimes)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (handleTimes)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.sound.music.time = Conductor.songPosition
			if(FlxG.sound.music != null){
					if(FlxG.sound.music.time == lastFrameTime){
						Conductor.songPosition += elapsed * 1000;
					}else{
						Conductor.songPosition = FlxG.sound.music.time;
					}
					lastFrameTime = FlxG.sound.music.time;

			}

			if (subState == null )
			{
				songPositionBar = Conductor.songPosition;
				songTime = FlxG.sound.music.time;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				// if (Conductor.lastSongPos != Conductor.songPosition)
				// {
				// 	songTime = (songTime + Conductor.songPosition) / 2;
				// 	Conductor.lastSongPos = Conductor.songPosition;
				// 	// Conductor.songPosition += FlxG.elapsed * 1000;
				// 	// trace('MISSED FRAME');
				// }
			}
			// vocals.time = Conductor.songPosition;

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			curSection = Std.int(curStep / 16);
			if(moveCamera){

				var locked = (!FlxG.save.data.camMovement || camLocked || PlayState.SONG.notes[curSection].sectionNotes[0] == null);
				if (PlayState.SONG.notes[curSection] != null) followChar((PlayState.SONG.notes[curSection].mustHitSection ? 0 : 1),locked);
			}
		}
		if(FlxG.save.data.animDebug && updateOverlay){
			Overlay.debugVar += '\nResync count:${resyncCount}'
				+'\nCond/Music time:${Std.int(Conductor.songPosition)}/${Std.int(FlxG.sound.music.time)}'
				+'\nAssumed Section:${curSection}'
				+'\nHealth:${health}'
				+'\nCamFocus:${if(!FlxG.save.data.camMovement || camLocked || PlayState.SONG.notes[curSection].sectionNotes[0] == null) " Locked" else (PlayState.SONG.notes[curSection].mustHitSection ? " BF" : " Dad") }'
				+'\nScript Count:${interpCount}';
		}
		if ((FlxG.save.data.camMovement || !camLocked ) && camBeat){
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			
		}else if (camBeat){
			FlxG.camera.zoom = defaultCamZoom;
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			// FlxG.camera.zoom = 0.95;
			// camHUD.zoom = 1;
		}
		switch(curSong){
			case 'Fresh':
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
					case 163:
						// FlxG.sound.music.stop();
						// FlxG.switchState(new TitleState());
				}
			case 'Bopeebo':
				switch (curBeat)
				{
					case 128, 129, 130:
						vocals.volume = 0;
						// FlxG.sound.music.stop();
						// FlxG.switchState(new PlayState());
				}
		}

		if (health <= 0 && !hasDied && !ChartingState.charting){

			if(practiceMode) {
					hasDied = true;practiceText.text = "Practice Mode; Score won't be saved";practiceText.screenCenter(X);FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
				} else finishSong(false);
		}
 		if (FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				finishSong(false);
		}

		if (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
		{
			var dunceNote:Note = unspawnNotes.shift();
			notes.add(dunceNote);
		}
			// if(dunceNote.childNotes.length > 0){
			// 	while (dunceNote.childNotes.length > 0) {
			// 		var sussy = dunceNote.childNotes.shift();
			// 		notes.add(sussy);
			// 		unspawnNotes.remove(sussy);
			// 	}
			// }

		// if (addNotes && FlxG.random.int(0,1000) > 700){
		// 	var note:Array<Dynamic> = [Conductor.songPosition + FlxG.random.int(400,1000),FlxG.random.int(0,3),0];
		// 	var swagNote:Note = new Note(note[0], note[1], null,null,null,0,note,true);
		// 	swagNote.scrollFactor.set(0, 0);				

		// 	unspawnNotes.push(swagNote);
		// 	notes.add(swagNote);


		// 	swagNote.mustPress = true;

		// 	if (swagNote.mustPress)
		// 	{
		// 		swagNote.x += FlxG.width / 2; // general offset
		// 	}
		// }


		
		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}
		if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) PlayState.canUseAlts = true;
		callInterp("updateAfter",[elapsed]);
		notes.forEachAlive(function(daNote:Note){
					if (daNote.skipNote) return;
					if (dadShow && !daNote.mustPress && daNote.wasGoodHit )
					{
					} else if (!daNote.mustPress && daNote.wasGoodHit && !dadShow && SONG.needsVoices){
						daNote.active = false;
						vocals.volume = 0;
						daNote.kill();
						notes.remove(daNote, true);
					}
	
					// if (daNote.mustPress && daNote.tooLate)
					// {
					// 	if (!daNote.shouldntBeHit)
					// 	{
					// 		health += SONG.noteMetadata.tooLateHealth;
					// 		vocals.volume = 0;
					// 		noteMiss(daNote.noteData, daNote);
					// 	}
	
					// 	daNote.visible = false;
					// 	daNote.kill();
					// 	notes.remove(daNote, true);
					// }
		});


		if (!inCutscene)
			keyShit();
	#if !debug
	}catch(e){MainMenuState.handleError(e,'Caught "update" crash: ${e.message}\n ${e.stack}');}
	#end
}

	override function draw(){
		try{noteShit();}catch(e){handleError('Error during noteShit: ${e.message}\n ${e.stack}}');}
		callInterp("draw",[]);
		if(!FlxG.save.data.preformance){
			if(downscroll){
				notes.sort(FlxSort.byY,FlxSort.DESCENDING);
			}else{
				notes.sort(FlxSort.byY,FlxSort.ASCENDING);

			}
		}
		super.draw();
	}
	public function followChar(?char:Int = 0,?locked:Bool = true){
		// if(swappedChars) char = (char == 1 ? 0 : 1);
		focusedCharacter = char;
		if(locked || cameraPositions[char] == null){
			camIsLocked = true;
			camFollow.x = lockedCamPos[0] + additionCamPos[0];
			camFollow.y = lockedCamPos[1] + additionCamPos[1];
			return; 
		}
		camFollow.x = cameraPositions[char][0] + additionCamPos[0];
		camFollow.y = cameraPositions[char][1] + additionCamPos[1];


	}
	public function getDefaultCamPos():Array<Float>{
		if(camIsLocked){
			return lockedCamPos; 
		}
		return cameraPositions[focusedCharacter];
	}
	public var cameraPositions:Array<Array<Float>> = [];
	public var camLocked:Bool = false;
	public var camIsLocked:Bool = false;
	public var defLockedCamPos:Array<Float> = [720, 500];
	public var lockedCamPos:Array<Float> = [720, 500];
	public var additionCamPos:Array<Float> = [0,0];
	public var focusedCharacter:Int = 0;
	public function updateCharacterCamPos(){ // Resets all camera positions
		var offsetX = boyfriend.getMidpoint().x - 100 + boyfriend.camX;
		var offsetY = boyfriend.getMidpoint().y - 100 + boyfriend.camY;


		switch (curStage)
		{
			case 'limo':
				offsetX -= 300;
			case 'mall':
				offsetY -= 200;
		}
		cameraPositions = [[offsetX,offsetY]];
		var offsetX = dad.getMidpoint().x + 150 + dad.camX;
		var offsetY = dad.getMidpoint().y - 100 + dad.camY;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter)
		{
			case 'mom':
				offsetY = dad.getMidpoint().y;
			case 'senpai':
				offsetY = dad.getMidpoint().y - 430;
				offsetX = dad.getMidpoint().x - 100;
			case 'senpai-angry':
				offsetY = dad.getMidpoint().y - 430;
				offsetX = dad.getMidpoint().x - 100;
		}
		cameraPositions.push([offsetX,offsetY]);
		// if(swappedChars) cameraPositions = [cameraPositions[0],cameraPositions[1]];
		cameraPositions.push([gf.getMidpoint().x + gf.camX,gf.getMidpoint().y - 100 + gf.camY]);
		lockedCamPos = defLockedCamPos;
	}

	var shouldEndSong:Bool = true;
	function endSong():Void
	{
		// if (!loadRep)
		// 	rep.SaveReplay(saveNotes);
		// else
		// {
		// 	FlxG.save.data.botplay = false;
		// 	FlxG.save.data.scrollSpeed = 1;
		// 	downscroll = false;
		// }
		inCutscene = true;
		paused = true;
		if(endDialogue[0] != null){
			canPause = false;
			var doof:DialogueBox = new DialogueBox(false, endDialogue);
			vocals.stop();
			vocals.volume = 0;
			endDialogue = [];
			doof.scrollFactor.set();
			doof.finishThing = endSong;
			camHUD.alpha = 1;
			doof.cameras = [camHUD];

			// inCutscene = true;
			add(doof);
			return;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		// #if !switch
		// if (SONG.validScore && stateType != 2 && stateType != 4)
		// {
			

		// }
		// #end
		charCall("endSong",[]);
		callInterp("endSong",[]);
		if(!shouldEndSong){shouldEndSong = true;return;}
		// if(!ChartingState.charting ){
		// 	Highscore.saveScore('${nameSpace}-${actualSongName}', Math.round(songScore), storyDifficulty);
		// }
		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);
				StoryMenuState.weekSicks = sicks;
				StoryMenuState.weekBads = bads;
				StoryMenuState.weekShits = shits;
				StoryMenuState.weekGoods = goods;
				StoryMenuState.weekMisses = misses;
				StoryMenuState.weekMaxCombo = maxCombo;
				StoryMenuState.weekScore = songScore;
				StoryMenuState.weekAccuracy = accuracy;
				if (storyPlaylist.length <= 0)
				{
					// FlxG.sound.playMusic(Paths.music('freakyMenu'));
					trace("Song finis");

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					// FlxG.switchState(new StoryMenuState());


					// if ()

					// if (SONG.validScore)
					// {
						Highscore.saveWeekScore(storyWeek, songScore, storyDifficulty);
					// }
					FlxG.save.flush();
					finishSong(true);
				}
				else if(!StoryMenuState.isVanillaWeek){
					trace('Swapping songs');
					resetInterps();
					FlxG.sound.music.stop();
					prevCamFollow = camFollow;
					StoryMenuState.curSong++;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					StoryMenuState.swapSongs();

					// LoadingState.loadAndSwitchState(new PlayState());

				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					// difficulty = if (songDiff != "normal") '-${songDiff}';
					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'),FlxG.save.data.otherVol);
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				// trace('WENT BACK TO FREEPLAY??');
				// Switches to the win state
				// openSubState(new FinishSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,true));
				finishSong(true);
			}
		}
	}
	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;
	var lastNoteSplash:NoteSplash;
	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			vocals.volume = FlxG.save.data.voicesVol;
			
			var placement:String = Std.string(combo);
			
			// var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			// coolText.screenCenter();
			// coolText.x = FlxG.width * 0.55;
			// coolText.y -= 350;
			// coolText.cameras = [camHUD];
			//
	
			
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					// combo = 0;
					// misses++; A shit should not equal a miss
					health -= 0.2;
					ss = false;
					shits++;
					if(FlxG.save.data.shittyMiss){misses++;combo = 0;}
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if(FlxG.save.data.badMiss){misses++;combo = 0;}
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if(FlxG.save.data.goodMiss){misses++;combo = 0;}
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
					if (FlxG.save.data.noteSplash){
						var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
						a.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						lastNoteSplash = a;
						grpNoteSplashes.add(a);
					}
			}
			if(flippy && daRating != "sick"){
				practiceMode = false;
				health = 0;
			}
			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));
			var rating:FlxSprite = new FlxSprite();
			// if (daRating != 'shit' || daRating != 'bad')
			// {
	
			
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
			if(!FlxG.save.data.noterating) return;
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			if(FlxG.save.data.noterating){
				rating.loadGraphic(Paths.image(daRating));
				rating.screenCenter();
				rating.y -= 50;
				rating.x = -125;
			
				var funni:Map<String,KadeEngineData.ObjectInfo> = cast FlxG.save.data.playStateObjectLocations;
				if (funni["rating"] != null)
				{

					rating.x = funni["rating"].x;
					rating.y = funni["rating"].y;
				}
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
			}
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3); 

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (offsetTesting && msTiming >= 0.03)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);
			var comboSpr:FlxSprite = null;
			if(FlxG.save.data.noterating){
				comboSpr = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
				comboSpr.screenCenter();
				comboSpr.x = rating.x;
				comboSpr.y = rating.y + 100;
				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;

				currentTimingShown.screenCenter();
				currentTimingShown.x = comboSpr.x + 100;
				currentTimingShown.y = rating.y + 100;
				currentTimingShown.acceleration.y = 600;
				currentTimingShown.velocity.y -= 150;
		
				comboSpr.velocity.x += FlxG.random.int(1, 10);
				currentTimingShown.velocity.x += comboSpr.velocity.x;
				add(rating);
		

				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
		
				currentTimingShown.updateHitbox();
				comboSpr.updateHitbox();
				rating.updateHitbox();
		
				currentTimingShown.cameras = [camHUD];
				comboSpr.cameras = [camHUD];
				rating.cameras = [camHUD];
			}
			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			if(FlxG.save.data.noterating){
				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001,
					onUpdate: function(tween:FlxTween)
					{
						if (currentTimingShown != null)
							currentTimingShown.alpha -= 0.02;
						timeShown++;
					}
				});

				FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						comboSpr.destroy();
						if (currentTimingShown != null && timeShown >= 20)
						{
							remove(currentTimingShown);
							currentTimingShown = null;
						}
						rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001
				});

			}

		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	
		private function fromBool(input:Bool):Int{
			if (input) return 1;
			return 0; 
		}
		private function fromInt(?input:Int = 0):Bool{
			return (input == 1);
		}


	// Custom input handling

	function setInputHandlers(){
		inputMode = FlxG.save.data.inputHandler;
		var inputEngines = ["KE" + MainMenuState.kadeEngineVer,"SE" + (if (FlxG.save.data.accurateNoteSustain) "-ACNS" else "")];
		// if (onlinemod.OnlinePlayMenuState.socket != null && inputMode != 0) {inputMode = 0;trace("Loading with non-kade in online. Forcing kade!");} // This is to prevent input differences between clients
		trace('Using ${inputMode}');
		// noteShit handles moving notes around and opponent hitting them
		// keyShit handles player input and hitting notes
		// These can both be replaced by scripts :>

		switch(inputMode){
			case 0:
				noteShit = kadeNoteShit;
				doKeyShit = kadeKeyShit;
				goodNoteHit = kadeGoodNote;
			case 1:
				noteShit = SENoteShit;
				doKeyShit = kadeBRKeyShit;
				goodNoteHit = kadeBRGoodNote;
			default:
				MainMenuState.handleError('${inputMode} is not a valid input! Please change your input mode!');

		}
		inputEngineName = if(inputEngines[inputMode] != null) inputEngines[inputMode] else "Unspecified";


	}
	dynamic function noteShit(){MainMenuState.handleError("I can't handle input for some reason, Please report this!");}
	public function DadStrumPlayAnim(id:Int) {
		var spr:FlxSprite= strumLineNotes.members[id];
		if(spr != null) {
			spr.animation.play('confirm', true);
			spr.centerOffsets();
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		}
	}
	public function BFStrumPlayAnim(id:Int,anim:String = 'confirm') {
		var spr:FlxSprite= playerStrums.members[id];
		if(spr != null) {
			spr.animation.play(anim, true);
			spr.centerOffsets();
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		}
	}


	private function keyShit():Void
		{try{doKeyShit();}catch(e){handleError('Error during keyshit: ${e.message}\n ${e.stack}');}}
	private dynamic function doKeyShit():Void
		{MainMenuState.handleError("I can't handle key inputs? Please report this!");}



	inline function badNoteHit():Void {
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		for (i in 0...controlArray.length) {
			if(controlArray[i]) noteMiss(i,null);
		}
	}


// Vanilla Kade

	public var acceptInput = true;
	function kadeNoteShit(){
		if (generatedMusic)
			{
				var _scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2); // Probably better to calculate this beforehand
				var strumNote:StrumArrow;
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
						daNote.destroy();
						notes.remove(daNote, true);
					}
					else
					{
						daNote.active = true;
					}
					// if (!daNote.modifiedByLua) Modcharts don't work, this check is useless
					// 	{
					strumNote = (if (daNote.mustPress) playerStrums.members[Math.floor(Math.abs(daNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))]);
					if(daNote.updateY){
							if (downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (strumNote.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height * 0.5;
	
									// Only clip sustain notes when properly hit
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (strumNote.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height * 0.5;
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
							}
						}
		
					if (daNote.skipNote) return;

					// if ((daNote.mustPress || !daNote.wasGoodHit) && daNote.lockToStrum){
					// 	daNote.visible = strumNote.visible;
					// 	if(daNote.updateX) daNote.x = strumNote.x + strumNote.width;
					// 	if(!daNote.isSustainNote && daNote.updateAngle) daNote.angle = strumNote.angle;
					// 	if(daNote.updateAlpha) daNote.alpha = strumNote.alpha;
					// }

					if (daNote.mustPress)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						if(!daNote.skipXAdjust){
							daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
							// if (daNote.isSustainNote)
							// 	daNote.x += daNote.width / 2 + 17;
						}
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						if(!daNote.skipXAdjust){
							daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
							// if (daNote.isSustainNote)
							// 	daNote.x += daNote.width / 2 + 17;
						}
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					


					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if (daNote.mustPress && daNote.tooLate )
					{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else if (!daNote.shouldntBeHit)
							{
								health += SONG.noteMetadata.tooLateHealth;
								vocals.volume = 0;
								noteMiss(daNote.noteData, daNote);
							}
		
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
					}
				});
			}
	}
	private function kadeKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
		 		callInterp("keyShit",[pressArray,holdArray]);
		 		charCall("keyShit",[pressArray,holdArray]);
		 		if (!acceptInput) {holdArray = pressArray = releaseArray = [false,false,false,false];}
				// HOLDS, check for sustain notes
				if (generatedMusic && holdArray.contains(true))
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 		var hitArray = [false,false,false,false];
				// PRESSES, check for note hits
				if (generatedMusic && pressArray.contains(true) /* && !boyfriend.stunned && */ )
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.skipNote) return;
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;
					var curTime = Date.now().getTime();
					for (i in 0...pressArray.length)
					{	
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								hitArray[coolNote.noteData] = true;
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost)
					{
						if (mashViolations > 8)
						{
							trace('mash violations ' + mashViolations);
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}

				}
		 		callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
		 		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
				

				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true)))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
									

			}

	function kadeGoodNote(note:Note, ?resetMashViolation = true):Void
					{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if(note.shouldntBeHit){noteMiss(note.noteData,note,true);return;}
				// if(note.shouldntBeHit){if(note.rating != "miss" && note.rating != "shit" && note.rating != "bad") {noteMiss(note.noteData,note,true);} return;}

				// if (note.canMiss){ Disabled for now, It seemed to add to the lag and isn't even properly implemented
					
				// 	if (note.rating == "shit") return;// Lets not be a shit and count shit hits for hurt notes
				// 	noteMiss(note.noteData, note,1);
				// }


				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (FlxG.save.data.npsDisplay && !note.isSustainNote)
					notesHitArray.unshift(Date.now().getTime());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;


				if (mashViolations < 0)
					mashViolations = 0;

				if(logGameplay) eventLog.push({
					rating:note.rating,
					direction:note.noteData,
					strumTime:note.strumTime,
					isSustain:note.isSustainNote,
					time:Conductor.songPosition
				});

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
					

					if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,FlxG.save.data.hitVol);






					// if(!loadRep && note.mustPress)
					// 	saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					
					note.hit(0,note);
					callInterp("noteHit",[boyfriend,note]);
					onlineNoteHit(note.noteID,0);
					
					note.wasGoodHit = true;
					if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = FlxG.save.data.voicesVol;
		

					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		
	inline function onlineNoteHit(noteID:Int = -1,miss:Int = 0){
		if(p2canplay){
			onlinemod.Sender.SendPacket(onlinemod.Packets.KEYPRESS, [noteID,miss], onlinemod.OnlinePlayMenuState.socket);
		}
	}



// "improved" kade

	function SENoteShit(){
		if (generatedMusic)
			{
				var _scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2); // Probably better to calculate this beforehand
				var strumNote:StrumArrow;
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					strumNote = (if (daNote.mustPress) playerStrums.members[Math.floor(Math.abs(daNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))]);
					if(daNote.updateY){

						switch (downscroll){

							case true:{
								daNote.y = (strumNote.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height * 0.5;
	
									// Only clip sustain notes when properly hit
									if((daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || dadShow) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
										if(daNote.mustPress || !(!daNote.mustPress && !p2canplay)){

											daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
											callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
										}
									}
								}
						
							}
							case false:{
								daNote.y = (strumNote.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
									// (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) &&
									if((daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || dadShow) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumNote.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
										if(daNote.mustPress || !(!daNote.mustPress && !p2canplay)){
											daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
											callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
										}
									}
								}
							}
						}
					}
					if (daNote.skipNote) return;
		
	
					if ((daNote.mustPress || !daNote.wasGoodHit) && daNote.lockToStrum){
						daNote.visible = strumNote.visible;
						if(daNote.updateX) daNote.x = strumNote.x + (strumNote.width * 0.5);
						if(!daNote.isSustainNote && daNote.updateAngle) daNote.angle = strumNote.angle;
						if(daNote.updateAlpha) daNote.alpha = strumNote.alpha;

					}
					if(daNote.mustPress && daNote.tooLate){
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else if (!daNote.shouldntBeHit)
						{
							health += SONG.noteMetadata.tooLateHealth;
							vocals.volume = 0;
							noteMiss(daNote.noteData, daNote);
						}
	
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}


					// if (daNote.mustPress)
					// {
					// 	daNote.visible = playerStrums.members[Std.int(daNote.noteData)].visible;
					// 	if(!daNote.skipXAdjust){
					// 		daNote.x = playerStrums.members[Std.int(daNote.noteData)].x;
					// 		if (daNote.isSustainNote)
					// 			daNote.x += daNote.width / 2 + 17;
					// 	}
					// 	if (!daNote.isSustainNote)
					// 		daNote.angle = playerStrums.members[Std.int(daNote.noteData)].angle;
					// 	daNote.alpha = playerStrums.members[Std.int(daNote.noteData)].alpha;



					// }
					// else if (!daNote.wasGoodHit)
					// {
					// 	daNote.visible = strumLineNotes.members[Std.int(daNote.noteData)].visible;
					// 	if(!daNote.skipXAdjust){
					// 		daNote.x = strumLineNotes.members[Std.int(daNote.noteData)].x;
					// 		if (daNote.isSustainNote)
					// 			daNote.x += daNote.width / 2 + 17;
					// 	}
						
					// 	if (!daNote.isSustainNote)
					// 		daNote.angle = strumLineNotes.members[Std.int(daNote.noteData)].angle;
					// 	daNote.alpha = strumLineNotes.members[Std.int(daNote.noteData)].alpha;
					// }



					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

					
				});
			}
	}
 	private function kadeBRKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
				var hitArray:Array<Bool> = [false,false,false,false];
		 		callInterp("keyShit",[pressArray,holdArray]);
		 		charCall("keyShit",[pressArray,holdArray]);
		 


		 		if (!acceptInput) {holdArray = pressArray = releaseArray = [false,false,false,false];}
				// HOLDS, check for sustain notes
				if (generatedMusic && (holdArray.contains(true) || releaseArray.contains(true)))
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.mustPress && daNote.isSustainNote && daNote.canBeHit && holdArray[daNote.noteData]){ // Clip note to strumline
							if(daNote.strumTime <= Conductor.songPosition || daNote.sustainLength < 2 || !FlxG.save.data.accurateNoteSustain) // Only destroy the note when properly hit
								{goodNoteHit(daNote);return;}
							// if(Std.isOfType(daNote,HoldNote)){
							// 	var e:HoldNote = cast daNote;
							// 	daNote.clip = true;
							// }else{
								daNote.isPressed = true;
							// }
							
							daNote.susHit(0,daNote);
							callInterp("susHit",[daNote]);
						}
					});
				}
		 
				// PRESSES, check for note hits
				
				if (generatedMusic && pressArray.contains(true) /*!boyfriend.stunned && */ )
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Bool> = [false,false,false,false]; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 			var onScreenNote:Bool = false;
		 			var i = 0;
		 			var daNote:Note;
		 			while (i < notes.members.length)
					{
						daNote = notes.members[i];
						i++;
						if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;

						if (!onScreenNote) onScreenNote = true;
						if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit && pressArray[daNote.noteData])
						{
							if (directionList[daNote.noteData])
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData){

										if (Math.abs(daNote.strumTime - coolNote.strumTime) < 5)
										{ // if it's the same note twice at < 5ms distance, just delete it
											// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
											// weell now I'm using a while instead of a forEachAlive, so fuck you

											daNote.kill();
											notes.remove(daNote, true);
											daNote.destroy();
											i--;
											break;
										}
										if (daNote.strumTime < coolNote.strumTime)
										{ // if daNote is earlier than existing note (coolNote), replace
											// This shouldn't happen due to all of the notes being arranged by strumtime, if it does, run
											possibleNotes.remove(coolNote);
											trace('${daNote.strumTime} < ${coolNote.strumTime} 💀');
											possibleNotes.push(daNote);
											break;
										}
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList[daNote.noteData] = true;
							}
						}
						
					};
					// for (note in dumbNotes)
					// {
					// }
		 			if(onScreenNote){

						for (i in 0...possibleNotes.length) {
							hitArray[possibleNotes[i].noteData] = true;
							goodNoteHit(possibleNotes[i]);
						}
						if(!FlxG.save.data.ghost && onScreenNote){

							for (i in 0 ... pressArray.length) {
								if(pressArray[i] && !directionList[i]){
									noteMiss(i, null);
								}
							}
						}

		 			}

				}
		 		callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
		 		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 && (!holdArray.contains(true)))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}

		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 			

					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});

			}

	function kadeBRGoodNote(note:Note, ?resetMashViolation = true):Void
				{

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);


				if(note.shouldntBeHit){noteMiss(note.noteData,note,true);return;}

				if (FlxG.save.data.npsDisplay && !note.isSustainNote)
					notesHitArray.unshift(Date.now().getTime());



				if(logGameplay) eventLog.push({
					rating:note.rating,
					direction:note.noteData,
					strumTime:note.strumTime,
					isSustain:note.isSustainNote,
					time:Conductor.songPosition
				});
				// if (!note.wasGoodHit)
				// {
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
					

					if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * (0.25 * note.noteData + 1));
					note.hit(0,note);
					callInterp("noteHit",[boyfriend,note]);
					onlineNoteHit(note.noteID,0);
					
					note.wasGoodHit = true;
					if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = FlxG.save.data.voicesVol;
					note.skipNote = true;
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				// }
			}
		








	public function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		noteMissdyn(direction,daNote,forced);
	}
	dynamic function noteMissdyn(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		if(daNote != null && daNote.shouldntBeHit && !forced) return;
		
		if(daNote != null && forced && daNote.shouldntBeHit){ // Only true on hurt arrows
			FlxG.sound.play(hurtSoundEff, FlxG.save.data.missVol);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();

		}
		if(FlxG.save.data.playMisses) if (boyfriend.useMisses){FlxG.sound.play(boyfriend.missSounds[direction], FlxG.save.data.missVol);}else{FlxG.sound.play(vanillaHurtSounds[Math.round(Math.random() * 2)], FlxG.save.data.missVol);}
		// FlxG.sound.play(hurtSoundEff, 1);
		health += SONG.noteMetadata.missHealth;
		// switch (direction)
		// {
		// 	case 0:
		// 		boyfriend.playAnim('singLEFTmiss', true);
		// 	case 1:
		// 		boyfriend.playAnim('singDOWNmiss', true);
		// 	case 2:
		// 		boyfriend.playAnim('singUPmiss', true);
		// 	case 3:
		// 		boyfriend.playAnim('singRIGHTmiss', true);
		// }
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;
		misses++;
		if(flippy){
			practiceMode = false;
			health = 0;
		}
		if(daNote != null) daNote.miss(0,daNote); else charAnim(0,"singDOWNmiss");
		if(logGameplay) {eventLog.push ({
				rating:if(daNote == null) "Missed without note" else "Missed a note",
				direction:direction,
				strumTime:(if(daNote != null) daNote.strumTime else 0 ),
				isSustain:if(daNote != null) daNote.isSustainNote else false,
				time:Conductor.songPosition
			});
		}


		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit -= 1;

		songScore -= 10;
		if (daNote != null && daNote.shouldntBeHit) {songScore += SONG.noteMetadata.badnoteScore; health += SONG.noteMetadata.badnoteHealth;} // Having it insta kill, not a good idea 
		if(daNote == null) callInterp("miss",[boyfriend,direction]); else callInterp("noteMiss",[boyfriend,daNote]);
		onlineNoteHit(if(daNote == null) -1 else daNote.noteID,direction + 1);



		updateAccuracy();
	}













	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;



	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff);
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));

			}
		}


	dynamic function goodNoteHit(note:Note, ?resetMashViolation = true):Void
		{MainMenuState.handleError('I cant register any note hits!');}




	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}


	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	// public static function registerEvent(func:String,step:Int){
	// 	stepAnimEvents[]
	// } 

	// var lastStep =0;
	override function stepHit()
	{
		if(lastStep == curStep)return;
		super.stepHit();
		// lastStep = curStep;
		if (handleTimes && (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) && generatedMusic)
		{
			resyncVocals();
		}
		try{
			callInterp("stepHit",[]);
			charCall("stepHit",[curStep]);
		}catch(e){handleError('An uncaught error from a stephit call: ${e.message}\n ${e.stack}');}
		try{
			for (i => v in stepAnimEvents) {
				for (anim => ifState in v) {
					var variable:Dynamic = Reflect.field(this,ifState.variable);
					var play:Bool = false;
					if (ifState.type == "contains"){
						if (ifState.value.contains(variable)){play = true;}
					}else if(ifState.type == "function"){
						callInterp(ifState.value,[]);
					}else{
						var ret:Int = Reflect.compare(variable,ifState.value);
						if (ifState.type == "equals" && ret == 0) play = true; else if (ifState.type == "more" && ret == 1) play = true; else if (ifState.type == "less" && ret == 0) play = true;
					}
					if (play){
						trace("Custom animation, Playing anim");
						switch(i){
							case 0: boyfriend.playAnim(anim);
							case 1: dad.playAnim(anim);
							case 2: gf.playAnim(anim);
						}
					}
				}
			}
			
		}catch(e){handleError('A animation event caused an error: ${e.message}\n ${e.stack}');}

	}
	
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		callInterp("beatHit",[]);
		charCall("beatHit",[curBeat]);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 3) {
			scoreTxt.screenCenter(X);
		}


		if (dad.dance_idle) {
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}else{
			dad.dance();
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
			if (SONG.notes[Math.floor(curStep / 16)].scrollSpeed != null)
			{
				SONG.speed = SONG.notes[Math.floor(curStep / 16)].scrollSpeed;
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[curSection].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (FlxG.save.data.camMovement && camBeat){
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// if (curBeat % gfSpeed == 0)
		// {
		// 	gf.dance();
		// }
		try{
			for (i => v in beatAnimEvents) {
				for (anim => ifState in v) {
					var variable:Dynamic = Reflect.field(this,ifState.variable);
					var play:Bool = false;
					if (ifState.type == "contains"){
						if (ifState.value.contains(variable)){play = true;}
					}else{
						var ret:Int = Reflect.compare(variable,ifState.value);
						if (ifState.type == "equals" && ret == 0) play = true; else if (ifState.type == "more" && ret == 1) play = true; else if (ifState.type == "less" && ret == 0) play = true;
					}
					if (play){
						trace("Custom animation, Playing anim");
						switch(i){
							case 0: boyfriend.playAnim(anim);
							case 1: dad.playAnim(anim);
							case 2: gf.playAnim(anim);
						}
					}
				}
			}
		}catch(e){handleError('A animation event caused an error ${e.message}\n ${e.stack}');}

		// if (gf.animation.curAnim.name.startsWith("dance") || gf.animation.curAnim.finished){
		// 	if (curBeat % 2 == 1){gf.playAnim('danceLeft');}
		// 	if (curBeat % 2 == 0){gf.playAnim('danceRight');}
		// } // Honestly surprised this fixed it

		// if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.dance_idle)
		// {
		// 	boyfriend.playAnim('idle');
		// }
		// if (boyfriend.dance_idle && (boyfriend.animation.curAnim.name.startsWith("dance") || boyfriend.animation.curAnim.finished)){
		// 	if (curBeat % 2 == 1){boyfriend.playAnim('danceLeft');}
		// 	if (curBeat % 2 == 0){boyfriend.playAnim('danceRight');}
		// }
		for (i => v in [boyfriend,gf,dad]) {
			if (v.dance_idle && (v.animation.curAnim.name.startsWith("dance") || v.animation.curAnim.finished)){
				if (curBeat % 2 == 1){v.playAnim('danceLeft');}
				if (curBeat % 2 == 0){v.playAnim('danceRight');}
			}else if (!v.dance_idle && !v.animation.curAnim.name.startsWith("sing"))
			{
			 v.playAnim('idle');
			}
		}




		stageShit();

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if(FlxG.save.data.distractions){
				lightningStrikeShit();
			}
		}
	}

	inline function stageShit(){
		switch (curStage)
		{
			case 'school':
				if(FlxG.save.data.distractions){
					bgGirls.dance();
				}

			case 'mall':
				if(FlxG.save.data.distractions){
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if(FlxG.save.data.distractions){
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});
		
						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
				}
			case "philly":
				if(FlxG.save.data.distractions){
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
				}

				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if(FlxG.save.data.distractions){
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}
	}

	public function testanimdebug(){
		if (FlxG.save.data.animDebug && onlinemod.OnlinePlayMenuState.socket == null) {
			if (FlxG.keys.justPressed.ONE && boyfriend != null)
			{
				FlxG.switchState(new AnimationDebug(boyfriend.curCharacter,true,0));
			}
			if (FlxG.keys.justPressed.TWO && dad != null)
			{
				FlxG.switchState(new AnimationDebug(dad.curCharacter,false,1));
			}

			if (FlxG.keys.justPressed.THREE && gf != null)
			{
				FlxG.switchState(new AnimationDebug(gfChar,false,2));
			}
			if (FlxG.keys.justPressed.SEVEN )
			{
				FlxG.switchState(new ChartingState());
			}
		}
	}

	override function switchTo(nextState:FlxState):Bool{
		if(!paused)resetInterps();
		return super.switchTo(nextState);
	}
	// public override function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME,?time = 5,?cent = false){
	// 	super.showTempmessage(str,color,time,cent);
		
		
	// }

	var curLight:Int = 0;
}