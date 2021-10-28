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
import haxe.Json;
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

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var actualSongName:String = ''; // The actual song name, instead of the shit from the JSON
	public static var songDir:String = ''; // The song's directory
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
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

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static inline var daPixelZoom:Int = 6;

	public static var noteBools:Array<Bool> = [false, false, false, false];
	public static var p2presses:Array<Bool> = [false,false,false,false,false,false,false,false]; // 0 = not pressed, 1 = pressed, 2 = hold, 3 = miss
	public static var p1presses:Array<Bool> = [false, false, false, false];
	public static var p2canplay = false;//TitleState.p2canplay

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	public var kadeEngineWatermark:FlxText;
	

	public var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public var gfChar:String = "gf";
	public static var boyfriend:Character;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	public static var dadShow = true;
	var canPause:Bool = true;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	public static var combo:Int = 0;
	public static var maxCombo:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	public var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;
	var updateTime:Bool = false;


	// Note Splash group
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = [];

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

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;


	// public static var theFunne:Bool = true;
	var inCutscene:Bool = false;
	// public static var repPresses:Int = 0;
	// public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;
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
	var errorMsg:String = "";

	var hitSound:Bool = false;


	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	public function resetScore(){
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;
		combo = 0;
		maxCombo = 0;
		// noteCount = 0;

		// repPresses = 0;
		// repReleases = 0;
		songScore = 0;

	}

	var interps:Map<String,Interp> = new Map();

	public function handleError(?error:String = "Unknown error!",?forced:Bool = false){
		try{

			resetInterps();
			if(!songStarted && !forced){
				errorMsg = error;
				return;
			}
			// generatedMusic = false;
			generatedMusic = false;
			persistentUpdate = false;
			openSubState(new FinishSubState(0,0,error));
		}catch(e){

			MainMenuState.handleError(error);
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
			var method = interps[id].variables.get(func_name);
			args.insert(0,this);
			Reflect.callMethod(interps[id],method,args);
		}catch(e:hscript.Expr.Error){handleError('${func_name}:${e.line} for ${id}:\n ${e.toString()}');}
	}

	public function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
			if(func_name == "noteHitDad"){
				charCall("noteHitSelf",[args[1]],1);
				charCall("noteHitOpponent",[args[1]],0);
			}
			if(func_name == "noteHit"){
				charCall("noteHitSelf",[args[1]],0);
				charCall("noteHitOpponent",[args[1]],1);
			}
			if (id == "") {
				for (name in interps.keys()) {
					callSingleInterp(func_name,args,name);
				}
			}else callSingleInterp(func_name,args,id);

		}
	inline function resetInterps() interps = new Map();
	
	public function parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song"){
		if (!QuickOptionsSubState.getSetting("Song hscripts")) {resetInterps();return;}
		var songScript = songScript;
		var hsBrTools = hsBrTools;
		if (script != "") songScript = script;
		if (brTools != null) hsBrTools = brTools;
		if (songScript == "") {return;}
		var interp = HscriptUtils.createSimpleInterp();
		var parser = new hscript.Parser();
		try{
			parser.allowTypes = parser.allowJSON = true;

			var program:Expr;
			program = parser.parseString(songScript);

			if (hsBrTools != null) {
				trace('Using hsBrTools');
				interp.variables.set("BRtools",hsBrTools); }
			else {
				trace('Using assets folder');
				interp.variables.set("BRtools",new HSBrTools("assets/"));}
			interp.variables.set("charGet",charGet); 
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim); 
			interp.execute(program);
			interps[id] = interp;
			callSingleInterp("initScript",[],id);
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
	static function charSet(charId:Int,field:String,value:Dynamic){
		Reflect.setField(switch(charId){case 1: dad; case 2: gf; default: boyfriend;},field,value);
	}
	static function charAnim(charId:Int,animation:String){
		var e = switch(charId){case 1: dad; case 2: gf; default: boyfriend;};
		e.playAnim(animation);
	}
	public function clearVariables(){
		stepAnimEvents = [];
		beatAnimEvents = [];
		unspawnNotes = [];
		strumLineNotes = null;
		playerStrums = null;
		cpuStrums = null;
	}
	public static var hasStarted = false;
	override public function create()
	{try{
		if (instance != null) instance.destroy();
		setInputHandlers(); // Sets all of the handlers for input
		instance = this;
		clearVariables();
		hasStarted = true;

		if (PlayState.songScript == "" && SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()] != null) songScript = SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()];
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		resetScore();

		if (FlxG.save.data.playerChar == "automatic"){
			if (TitleState.retChar(PlayState.SONG.player1) != "") SONG.player1 = TitleState.retChar(PlayState.SONG.player1);
			else SONG.player1 = "bf";
		}else SONG.player1 = FlxG.save.data.playerChar;
		TitleState.loadNoteAssets(); // Make sure note assets are actually loaded
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		// Note splashes

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash0);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
	
		
		//dialogue shit
		loadDialog();
		// Stage management
		var bfPos:Array<Float> = [0,0]; 
		var gfPos:Array<Float> = [0,0]; 
		var dadPos:Array<Float> = [0,0]; 
		var noGf:Bool = false;
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
						if(stage == ""){
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
								var stagePropJson:String = File.getContent('$stagePath/config.json');
								var stageProperties:StageJSON = haxe.Json.parse(CoolUtil.cleanJSON(stagePropJson));
								if (stageProperties == null || stageProperties.layers == null || stageProperties.layers[0] == null){MainMenuState.handleError('$stage\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
								defaultCamZoom = stageProperties.camzoom;
								for (layer in stageProperties.layers) {
									if(layer.song != null && layer.song != "" && layer.song.toLowerCase() != SONG.song.toLowerCase()){continue;}
									var curLayer:FlxSprite = new FlxSprite(0,0);
									if(layer.animated){
										var xml:String = File.getContent('$stagePath/${layer.name}.xml');
										if (xml == null || xml == "")MainMenuState.handleError('$stage\'s XML is invalid!');
										curLayer.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('$stagePath/${layer.name}.png')), xml);
										curLayer.animation.addByPrefix(layer.animation_name,layer.animation_name,layer.fps,false);
										curLayer.animation.play(layer.animation_name);
									}else{
										var png:BitmapData = BitmapData.fromFile('$stagePath/${layer.name}.png');
										if (png == null) MainMenuState.handleError('$stage\'s PNG is invalid!');
										curLayer.loadGraphic(png);
									}

									if (layer.centered) curLayer.screenCenter();
									if (layer.flip_x) curLayer.flipX = true;
									curLayer.setGraphicSize(Std.int(curLayer.width * layer.scale));
									curLayer.updateHitbox();
									curLayer.x += layer.pos[0];
									curLayer.y += layer.pos[1];
									curLayer.antialiasing = layer.antialiasing;
									curLayer.alpha = layer.alpha;
									curLayer.active = false;
									curLayer.scrollFactor.set(layer.scroll_factor[0],layer.scroll_factor[1]);
									add(curLayer);
								}
								if (stageProperties.no_gf) noGf = true; // This doesn't have to be provided, doing it this way
								bfPos = stageProperties.bf_pos;
								dadPos = stageProperties.dad_pos;
								gfPos = stageProperties.gf_pos;
								stageTags = stageProperties.tags;
							}
							if (FileSystem.exists('$stagePath/script.hscript')){
								parseHScript(File.getContent('$stagePath/script.hscript'),new HSBrTools(stagePath),"stage");
							}
						}
					}
				}
		}


		callInterp("afterStage",[]);

		if (stateType == 0 || stateType == 1){
		    PlayState.SONG.player1 = FlxG.save.data.playerChar;
		    if (FlxG.save.data.charAuto && TitleState.retChar(PlayState.SONG.player2) != ""){ // Check is second player is a valid character
		    	PlayState.SONG.player2 = TitleState.retChar(PlayState.SONG.player2);
		    }else{
		    	PlayState.SONG.player2 = FlxG.save.data.opponent;
	    	}
		}
		if (invertedChart){ // Invert players if chart is inverted, Does not swap sides, just changes character names
			var pl:Array<String> = [SONG.player1,SONG.player2];
			SONG.player1 = pl[1];
			SONG.player2 = pl[0];
		}
		var gfVersion:String = 'gf';

		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			default:
				gfVersion = 'gf';
		}
		if (FlxG.save.data.gfChar != "gf"){gfVersion=FlxG.save.data.gfChar;}
		gfChar = gfVersion;
		if (FlxG.save.data.gfShow) gf = new Character(400, 100, gfVersion,false,2); else gf = new EmptyCharacter(400, 100);
		gf.scrollFactor.set(0.95, 0.95);
		if (noGf) gf.visible = false;
		if (SONG.defplayer1 != null && SONG.defplayer1.startsWith("gf") && FlxG.save.data.charAuto) SONG.player1 = FlxG.save.data.gfChar;
		if (SONG.defplayer2 != null && SONG.defplayer2.startsWith("gf") && FlxG.save.data.charAuto) SONG.player2 = FlxG.save.data.gfChar;
		if (dadShow && FlxG.save.data.dadShow) dad = new Character(100, 100, SONG.player2,false,1); else dad = new EmptyCharacter(100, 100);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		camPos.set(camPos.x + dad.camX, camPos.y + dad.camY);
		if (FlxG.save.data.bfShow) boyfriend = new Character(770, 100, SONG.player1,true,0); else boyfriend = new EmptyCharacter(400,100);
		

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
		if (gfVersion == SONG.player2){
			if (SONG.player1 != SONG.player2){	// Don't hide GF if player 1 is GF
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
		}

		if (gfVersion == SONG.player1){
			if (SONG.player1 != SONG.player2){	// Don't hide GF if player 1 is GF
				boyfriend.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
		}
		if (dad.spiritTrail && FlxG.save.data.distractions){
			var dadTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(dadTrail);
		}
		if (boyfriend.spiritTrail && FlxG.save.data.distractions){
			var bfTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(bfTrail);
		}
		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);


		parseHScript(null,null,"song");

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
		// 	FlxG.save.data.downscroll = rep.replay.isDownscroll;
		// 	// FlxG.watch.addQuick('Queued',inputsQueued);
		// }

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);
		if (SONG.difficultyString != null && SONG.difficultyString != "") songDiff = SONG.difficultyString;
		else songDiff = if(stateType == 4) "mods/charts" else if (stateType == 5) "osu! beatmap" else (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

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

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		// FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
				if (FlxG.save.data.downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45 - FlxG.save.data.guiGap; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				// add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				// add(songPosBar);
	
				songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (FlxG.save.data.downscroll)
					songName.y -= 3;
				songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				// add(songName);
				songName.cameras = [camHUD];
			}
		
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9 - FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
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
		if (stateType != 4 && stateType != 5 ) actualSongName = curSong + " " + songDiff;

		
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50 - FlxG.save.data.guiGap,0,actualSongName + " - " + inputEngineName, 16);
		kadeEngineWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap;

		scoreTxtX = FlxG.width / 2 - 350;
		scoreTxt = new FlxText(scoreTxtX, healthBarBG.y + 30 - FlxG.save.data.guiGap, 0, "", 20);
		// if (!FlxG.save.data.accuracyDisplay)
		// 	scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;
		if(FlxG.save.data.botplay) scoreTxt.x = FlxG.width / 2 - 250;													  
		
		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		
		if(FlxG.save.data.botplay && !loadRep){add(botPlayState);bruhmode = FlxG.save.data.botplay;};

		iconP1 = new HealthIcon(SONG.player1, true,boyfriend.clonedChar);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false,dad.clonedChar);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		callInterp("addUI",[]);
		charCall("addUI",[],-1);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		// if (FlxG.save.data.songPosition)
		// {
		// 	songPosBG.cameras = [camHUD];
		// 	songPosBar.cameras = [camHUD];
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
									startCountdown();
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
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}

		if (!loadRep)
			rep = new Replay("na");
		
		add(scoreTxt);
		// FlxG.sound.cache("missnote1");
		// FlxG.sound.cache("missnote2");
		// FlxG.sound.cache("missnote3");
		super.create();

		openfl.system.System.gc();
	#if !debug 
	}catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}
	#end
	}
	function loadDialog(){		
		dialogue = [];
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
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
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
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
		camFollow.setPosition(720, 500);
		if (!playCountdown){
			playCountdown = true;
			return;
		}
		startCountdown();
	}

	var playCountdown = true;
	var generatedArrows = false;
	public function startCountdown():Void
	{



		inCutscene = false;
		if (!generatedArrows){
			generatedArrows = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		camFollow.setPosition(720, 500);


		
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;


		if(errorMsg != "") {handleError(errorMsg,true);return;}
		var swagCounter:Int = 0;
		
		callInterp("startCountdown",[]);


		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			// for (value in introAssets.keys())
			// {
			// 	if (value == curStage)
			// 	{
			// 		introAlts = introAssets.get(value);
			// 	}
			// }
			callInterp("startTimerStep",[swagCounter]);

			switch (swagCounter)
			{
				case 0:
					if (errorMsg != ""){
						handleError(errorMsg);
						startTimer.cancel();
						return;
					}
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
			
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();


					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();



					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
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
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
					
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
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

	function startSong(?alrLoaded:Bool = false):Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!alrLoaded)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
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

			if(songPosBG != null) remove(songPosBG);
			if(songPosBar != null) remove(songPosBar);
			if(songName != null) remove(songName);
			if(songTimeTxt != null) remove(songTimeTxt);
			songPosBG = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4 + FlxG.save.data.guiGap, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);

			songName = new FlxText(songPosBG.x + (songPosBG.width * 0.2) - 20,songPosBG.y + 1,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.x -= songName.text.length;
			songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			songTimeTxt = new FlxText(songPosBG.x + (songPosBG.width * 0.7) - 20,songPosBG.y + 1,0,"00:00 | 0:00", 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songTimeTxt.text = "00:00 | " + songLengthTxt;
			songTimeTxt.x -= songTimeTxt.text.length;
			songTimeTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songTimeTxt.scrollFactor.set();

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
			songTimeTxt.cameras = [camHUD];
			add(songPosBG);
			add(songPosBar);
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
		if (vocals == null){
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		if (notes == null) 
			notes = new FlxTypedGroup<Note>();
		
		notes.clear();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;


		// Per song offset check
		
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] == -1) continue;
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
				// if(songNotes[3] != null) trace('Note type: ${songNotes[3]}');
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,songNotes[3],songNotes,gottaHitNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,songNotes[3],songNotes);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}

			daBeats += 1;
		}

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

		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// switch (SONG.noteStyle)
			// {
			// 	case 'normal':
			charCall("strumNoteLoad",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteLoad",[babyArrow,player == 1]);
			babyArrow.frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.x += Note.swagWidth * i + i;

			switch (Math.abs(i))
			{
				case 0:
					// babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					// babyArrow.x += Note.swagWidth * 1 ;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					// babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					// babyArrow.x += Note.swagWidth * 3 + 4;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

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
			 babyArrow.x += if (!(FlxG.save.data.middleScroll && player == 1)) 50 else 100;

			babyArrow.x += if (FlxG.save.data.middleScroll) ((FlxG.width / 4) * player) else ((FlxG.width / 2) * player);
			if (FlxG.save.data.middleScroll && player == 0 && i > 1) babyArrow.x += Note.swagWidth * 6;
			babyArrow.visible = (player == 1 || FlxG.save.data.oppStrumLine);

			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
			charCall("strumNoteAdd",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteAdd",[babyArrow,player == 1]);
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
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

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

		openSubState(new FinishSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,win,camFollow));
		
	}

	var songLengthTxt = "N/A";

	override public function update(elapsed:Float)
	{
		#if !debug
		try{
		perfectMode = false;
		#end


		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
			if (combo > maxCombo)
				maxCombo = combo;
		}
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

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;
		scoreTxt.x = scoreTxtX - scoreTxt.text.length;
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

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		testanimdebug();

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		if(FlxG.save.data.animDebug){
			Overlay.debugVar += '\nHealth:${health}\nVocalVol:${vocals.volume}';
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			// if(allowedToHeadbang)
			// {
			// 	// Don't animate GF if something else is already animating her (eg. train passing)
			// 	if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
			// 	{
			// 		// Per song treatment since some songs will only have the 'Hey' at certain times
			// 		switch(curSong)
			// 		{
			// 			case 'Philly':
			// 			{
			// 				// General duration of the song

			// 			}
			// 			case 'Bopeebo':
			// 			{
			// 				// Where it starts || where it ends
			// 				if(curBeat > 5 && curBeat < 130)
			// 				{
			// 					if(curBeat % 8 == 7)
			// 					{
			// 						if(!triggeredAlready)
			// 						{
			// 							gf.playAnim('cheer');
			// 							triggeredAlready = true;
			// 						}
			// 					}else triggeredAlready = false;
			// 				}
			// 			}
			// 			case 'Blammed':
			// 			{
			// 				if(curBeat > 30 && curBeat < 190)
			// 				{
			// 					if(curBeat < 90 || curBeat > 128)
			// 					{
			// 						if(curBeat % 4 == 2)
			// 						{
			// 							if(!triggeredAlready)
			// 							{
			// 								gf.playAnim('cheer');
			// 								triggeredAlready = true;
			// 							}
			// 						}else triggeredAlready = false;
			// 					}
			// 				}
			// 			}
			// 			case 'Cocoa':
			// 			{
			// 				if(curBeat < 170)
			// 				{
			// 					if(curBeat < 65 || curBeat > 130 && curBeat < 145)
			// 					{
			// 						if(curBeat % 16 == 15)
			// 						{
			// 							if(!triggeredAlready)
			// 							{
			// 								gf.playAnim('cheer');
			// 								triggeredAlready = true;
			// 							}
			// 						}else triggeredAlready = false;
			// 					}
			// 				}
			// 			}
			// 			case 'Eggnog':
			// 			{
			// 				if(curBeat > 10 && curBeat != 111 && curBeat < 220)
			// 				{
			// 					if(curBeat % 8 == 7)
			// 					{
			// 						if(!triggeredAlready)
			// 						{
			// 							gf.playAnim('cheer');
			// 							triggeredAlready = true;
			// 						}
			// 					}else triggeredAlready = false;
			// 				}
			// 			}
			// 		}
			// 	}
			// }
			

			
			if (FlxG.save.data.camMovement){
				if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{followChar(1);}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{followChar();}
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
				
			}else{
				FlxG.camera.zoom = defaultCamZoom;
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
				// FlxG.camera.zoom = 0.95;
				// camHUD.zoom = 1;
			}
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

		if (health <= 0 && !FlxG.save.data.practiceMode)
			finishSong(false);
 		if (FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				finishSong(false);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		handleInput();
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

		if (!inCutscene)
			keyShit();
	#if !debug
	}catch(e){MainMenuState.handleError('Caught "update" crash: ${e.message}');}
	#end
}

	public function followChar(?char:Int = 0){
		switch (char) {
			case 1:{
				var offsetX = 0;
				var offsetY = 0;
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX+ dad.camX, dad.getMidpoint().y - 100 + offsetY + dad.camY);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;}
			default:
				{
					var offsetX = 0;
					var offsetY = 0;

					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX+ boyfriend.camX, boyfriend.getMidpoint().y - 100 + offsetY+ boyfriend.camY);


					switch (curStage)
					{
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
					}
				}

		}
	}


	function endSong():Void
	{
		// if (!loadRep)
		// 	rep.SaveReplay(saveNotes);
		// else
		// {
		// 	FlxG.save.data.botplay = false;
		// 	FlxG.save.data.scrollSpeed = 1;
		// 	FlxG.save.data.downscroll = false;
		// }

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		#if !switch
		if (SONG.validScore && stateType != 2 && stateType != 4)
		{
			
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		}
		#end

		charCall("endSong",[]);
		callInterp("endSong",[]);
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

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());


					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
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

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
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
	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			vocals.volume = 1;
			
			var placement:String = Std.string(combo);
			
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
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
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
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
						grpNoteSplashes.add(a);
					}
			}
			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
			
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if(FlxG.save.data.noterating){
				rating.loadGraphic(Paths.image(daRating));
				rating.screenCenter();
				rating.y -= 50;
				rating.x = coolText.x - 125;
			
				if (FlxG.save.data.changedHit)
				{
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
				}
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
			}
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(FlxG.save.data.botplay) msTiming = 0;							   

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

			if (msTiming >= 0.03 && offsetTesting)
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

			if(!FlxG.save.data.botplay) add(currentTimingShown);
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
				if(!FlxG.save.data.botplay) add(rating);
		

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
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
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
						coolText.destroy();
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
			curSection += 1;
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
		var inputEngines = ["KE " + MainMenuState.kadeEngineVer,"KE1.5.2-SE"];
		if (onlinemod.OnlinePlayMenuState.socket != null && inputMode != 0) {inputMode = 0;trace("Loading with non-kade in online. Forcing kade!");} // This is to prevent input differences between clients
		trace('Using ${inputMode}');
		switch(inputMode){
			case 0:
				handleInput = kadeInput; // I believe this is for Dad
				doKeyShit = kadeKeyShit; // I believe this is for Boyfriend
				goodNoteHit = kadeGoodNote;
			case 1:
				handleInput = kadeBRInput; // I believe this is for Dad
				doKeyShit = kadeBRKeyShit; // I believe this is for Boyfriend
				goodNoteHit = kadeBRGoodNote;
			default:
				MainMenuState.handleError('${inputMode} is not a valid input! Please change your input mode!');

		}
		inputEngineName = if(inputEngines[inputMode] != null) inputEngines[inputMode] else "Unspecified";
		// }
		// handleInput = kadeInput;
		// doKeyShit = kadeKeyShit; // Todo, add multiple input options

	}
	dynamic function handleInput(){MainMenuState.handleError("I can't handle input for some reason, Please report this!");}
	function DadStrumPlayAnim(id:Int) {
		var spr:FlxSprite= strumLineNotes.members[id];
		if(spr != null) {
			spr.animation.play('confirm', true);
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		}
	}
	function BFStrumPlayAnim(id:Int) {
		var spr:FlxSprite= playerStrums.members[id];
		if(spr != null) {
			spr.animation.play('confirm', true);
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		}
	}


	private function keyShit():Void
		{doKeyShit();}
	private dynamic function doKeyShit():Void
		{MainMenuState.handleError("I can't handle key inputs? Please report this!");}



	function badNoteHit():Void {
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		for (i in 0...controlArray.length) {
			if(controlArray[i]) noteMiss(i,null);
		}
	}

// Vanilla Kade
	public var acceptInput = true;
	function kadeInput(){
		if (generatedMusic)
			{
				var _scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2); // Probably better to calculate this beforehand
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
						daNote.active = true;
					}
					// if (!daNote.modifiedByLua) Modcharts don't work, this check is useless
					// 	{
							if (FlxG.save.data.downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
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
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height * 0.5;
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
							}
						// }
		
					if (daNote.skipNote) return;
					if (dadShow && !daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
						if (!p2canplay){
							if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) PlayState.canUseAlts = true;
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									dad.playAnim('singUP', true);
								case 3:
									dad.playAnim('singRIGHT', true);
								case 1:
									dad.playAnim('singDOWN', true);
								case 0:
									dad.playAnim('singLEFT', true);
							}
							
							if (FlxG.save.data.cpuStrums)
							{
								DadStrumPlayAnim(daNote.noteData);
							}
							callInterp("noteHitDad",[dad,daNote]);
						}

						dad.holdTimer = 0;
						if (dad.useVoices){dad.voiceSounds[daNote.noteData].play(1);dad.voiceSounds[daNote.noteData].time = 0;vocals.volume = 0;}else if (SONG.needsVoices) vocals.volume = 1;

	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					} else if (!daNote.mustPress && daNote.wasGoodHit && !dadShow && SONG.needsVoices){
						daNote.active = false;
						vocals.volume = 0;
						daNote.kill();
						notes.remove(daNote, true);
					}

					if (daNote.mustPress)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

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
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 		var hitArray = [false,false,false,false];
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
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
									
				if (p2canplay){ // The above but for P2
					p1presses = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
					var p2holds:Array<Bool> = [p2presses[4],p2presses[5],p2presses[6],p2presses[7]];
					if (p2presses[0] || p2holds[0]) dad.playAnim('singLEFT', true);
					else if (p2presses[1] || p2holds[1]) dad.playAnim('singDOWN', true);
					else if (p2presses[2] || p2holds[2]) dad.playAnim('singUP', true);
					else if (p2presses[3] || p2holds[3]) dad.playAnim('singRIGHT', true);
					else if (dad.animation.curAnim.name != "Idle" && dad.animation.curAnim.finished) dad.playAnim('Idle',true);
					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (p2presses[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
							spr.animation.play('pressed');

						if (!p2holds[spr.ID])
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
			}

	function kadeGoodNote(note:Note, ?resetMashViolation = true):Void
					{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if(note.shouldntBeHit){if(note.rating != "miss" && note.rating != "shit" && note.rating != "bad") {noteMiss(note.noteData,note,true);} return;}

				// if (note.canMiss){ Disabled for now, It seemed to add to the lag and isn't even properly implemented
					
				// 	if (note.rating == "shit") return;// Lets not be a shit and count shit hits for hurt notes
				// 	noteMiss(note.noteData, note,1);
				// }


				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;


				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
					

					if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,0.75);


					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}



					if(!loadRep && note.mustPress)
						saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					BFStrumPlayAnim(note.noteData);
					callInterp("noteHit",[boyfriend,note]);
					
					note.wasGoodHit = true;
					if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		




// "improved" kade

	function kadeBRInput(){
		if (generatedMusic)
			{
				var _scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2); // Probably better to calculate this beforehand

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
							if (FlxG.save.data.downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
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
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
						
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
							}
						// }
					if (daNote.skipNote) return;
		
	

					if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) PlayState.canUseAlts = true;
					if (dadShow && !daNote.mustPress && daNote.wasGoodHit )
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
						if (!p2canplay){
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									dad.playAnim('singUP', true);
								case 3:
									dad.playAnim('singRIGHT', true);
								case 1:
									dad.playAnim('singDOWN', true);
								case 0:
									dad.playAnim('singLEFT', true);
							}
							
							if (FlxG.save.data.cpuStrums)
							{
								DadStrumPlayAnim(daNote.noteData);
							}
							callInterp("noteHitDad",[dad,daNote]);
						}

						dad.holdTimer = 0;
	
						if (dad.useVoices){dad.voiceSounds[daNote.noteData].play(1);dad.voiceSounds[daNote.noteData].time = 0;vocals.volume = 0;}else if (SONG.needsVoices) vocals.volume = 1;

	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					} else if (!daNote.mustPress && daNote.wasGoodHit && !dadShow && SONG.needsVoices){
						daNote.active = false;
						vocals.volume = 0;
						daNote.kill();
						notes.remove(daNote, true);
					}

					if (daNote.mustPress)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if (daNote.mustPress && daNote.tooLate)
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
 	private function kadeBRKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				p1presses = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
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
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				// PRESSES, check for note hits
				
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Bool> = [false,false,false,false]; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 			var onScreenNote:Bool = false;
		 			var looped = 0;

					notes.forEachAlive(function(daNote:Note)
					{
						looped++;
						if (daNote.skipNote || !daNote.mustPress) return;

						if (!onScreenNote) onScreenNote = true;
						if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList[daNote.noteData])
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData){

										if (Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
										{ // if it's the same note twice at < 10ms distance, just delete it
											// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
											dumbNotes.push(daNote);
											break;
										}
										if (daNote.strumTime < coolNote.strumTime)
										{ // if daNote is earlier than existing note (coolNote), replace
											possibleNotes.remove(coolNote);
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
					});
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					// possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));  Should already be sorted
					var dontCheck = false;

					for (i in 0...3)
					{
						if (pressArray[i] && !directionList[i])
							dontCheck = true;
					}
					
					if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList[shit])
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								hitArray[coolNote.noteData] = true;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost && onScreenNote)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
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


				if(note.shouldntBeHit){if(note.rating != "miss" && note.rating != "shit" && note.rating != "bad") {noteMiss(note.noteData,note,true);} return;}

				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());




				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
					

					if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,0.75).x = (FlxG.camera.x) + (FlxG.width * (0.25 * note.noteData + 1));

					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}
					callInterp("noteHit",[boyfriend,note]);


					// if(!loadRep && note.mustPress)
					// 	saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					BFStrumPlayAnim(note.noteData);
					
					note.wasGoodHit = true;
					if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = 1;
					note.skipNote = true;
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		








	function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		if(daNote != null && daNote.shouldntBeHit && !forced) return;
		
		if(daNote != null && forced && daNote.shouldntBeHit){ // Only true on hurt arrows
			FlxG.sound.play(hurtSoundEff, 1);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();

		}
		if (!boyfriend.stunned)
		{
			if(FlxG.save.data.playMisses) if (boyfriend.useMisses){FlxG.sound.play(boyfriend.missSounds[direction], 1);}else{FlxG.sound.play(vanillaHurtSounds[Math.round(Math.random() * 2)], FlxG.random.float(0.1, 0.2));}
			// FlxG.sound.play(hurtSoundEff, 1);
			health += SONG.noteMetadata.missHealth;
			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;


			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;
			if (daNote != null && daNote.shouldntBeHit) {songScore += SONG.noteMetadata.badnoteScore; health += SONG.noteMetadata.badnoteHealth;} // Having it insta kill, not a good idea 
			callInterp("noteMiss",[boyfriend,daNote]);




			updateAccuracy();
		}
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




	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20 && generatedMusic)
		{
			resyncVocals();
		}
		try{
			callInterp("stepHit",[]);
			for (i => v in stepAnimEvents) {
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
			
		}catch(e){MainMenuState.handleError('A animation event caused an error ${e.message}');}

	}
	
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		callInterp("beatHit",[]);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}



		if (dad.dance_idle) {
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
			// if (SONG.notes[Math.floor(curStep / 16)].scrollSpeed != null)
			// {
			// 	curScrollSpeed = SONG.notes[Math.floor(curStep / 16)].scrollSpeed;
			// }
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (FlxG.save.data.camMovement){
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
		}catch(e){MainMenuState.handleError('A animation event caused an error ${e.message}');}

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
	var curLight:Int = 0;
}