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
import openfl.media.Sound;

import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import openfl.events.KeyboardEvent;
import Overlay.Console;


import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
#if discord_rpc
	import Discord.DiscordClient;
#end

#if linc_luajit
import se.handlers.SELua;
#end

import CharacterJson;
import StageJson;
import TitleState;




using StringTools;

typedef OutNote = {
	var time:Float;
	var strumTime:Float;
	var direction:Int;
	var rating:String;
	var isSustain:Bool;
}


class PlayState extends ScriptMusicBeatState
{
	public static var instance:PlayState = null;

	/* Song Shite */
		public static var curStage:String = '';
		public static var SONG:SwagSong;
		public static var actualSongName:String = ''; // The actual song name, instead of the shit from the JSON
		public static var songDir:String = ''; // The song's directory
		public static var isStoryMode:Bool = false;
		public static var playlistMode:Bool = false;
		public static var songDiff:String = "";
		public static var invertedChart:Bool = false;
		var songLength:Float = 0;
		public var curSection:Int = 0;
		public var curSong:String = "";
		public var speed:Float = 1;
		public static var songDifficulties:Array<String> = [];

	/* Story */
		public static var storyPlaylist:Array<String> = [];
		public static var storyDifficulty:Int = 1;
		public static var storyWeek:Dynamic = 0;
		public static var weekSong:Int = 0;

	/* Scoring */
		public static var shits(default,set):Int = 0;
		public static var bads(default,set):Int = 0;
		public static var goods(default,set):Int = 0;
		public static var sicks(default,set):Int = 0;
		public static var misses(default,set):Int = 0;
		public static function set_shits(vari:Int):Int{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return shits = vari;} // Prevent cheating that easily lmao
		public static function set_bads(vari:Int):Int{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return bads = vari;}
		public static function set_goods(vari:Int):Int{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return goods = vari;}
		public static function set_sicks(vari:Int):Int{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return sicks = vari;}
		public static function set_misses(vari:Int):Int{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return misses = vari;}
		public static function set_accuracy(vari:Float):Float{ if(Overlay.Console.showConsole && instance != null){instance.canSaveScore = false;} return accuracy = vari;}
		public static var accuracy(default,set):Float = 0.00;
		public static var ghostTaps:Int = 0;
		public static var combo:Int = 0;
		public static var maxCombo:Int = 0;
		public static var accuracyDefault:Float = 0.00;
		
		public var totalNotesHit:Float = 0;
		public var totalNotesHitDefault:Float = 0;
		public var totalPlayed:Int = 0;
		public var ss:Bool = false;
		public var fc:Bool = true;
		public static var songScore:Int = 0;
		public var songScoreDef:Int = 0;
		public static var campaignScore:Int = 0;
		public var practiceMode = false;
		public var flippy:Bool = false;

	/* Gameplay Vari's */
		public static var restartTimes:Int = -1;
		public static var offsetTesting:Bool = false;
		public static var timeCurrently:Float = 0;
		public static var timeCurrentlyR:Float = 0;
		public static var jumpTo:Float = 0;
		public var health:Float = 1;
		public var healthPercent(get,set):Int;
		public function get_healthPercent() return Std.int(health * 50);
		public function set_healthPercent(vari:Int){ health = vari / 50; return get_healthPercent();}
		public var handleHealth:Bool = true;
		public var checkHealth:Bool = true;
		public var downscroll:Bool = false;
		public var middlescroll:Bool = false;
		public var generatedMusic:Bool = false;
		public var startingSong:Bool = false;
		public var hasDied:Bool = false;
		public var canSaveScore(default,set):Bool = true; // Controls the ability for the game to save your score. Can be disabled but not re-enabled to prevent cheating
		public function set_canSaveScore(val){ // Prevents being able to enable this if it's already been disabled.
			if(!val){
				canSaveScore = false;
			}
			return canSaveScore;
		}
		public var botPlay(default,set):Bool = false;
		public function set_botPlay(val){ // Prevents botplay from being disabled to cheat
			if(val) canSaveScore = false;
			
			return botPlay = val;
		}
		var inCutscene:Bool = false;
		public var canPause:Bool = true;
		public var camZooming:Bool = false;
		public var timeSinceOnscreenNote:Float = 0;

	/* Notes & Strumline */
		public static var noteBools:Array<Bool> = [false, false, false, false];
		public static var p2canplay = false;
		public static var logGameplay:Bool = false;
		public var notes:FlxTypedGroup<Note>;
		public var eventNotes:FlxTypedGroup<Note>; // The above but doesn't need to update anything beyond the strumtime
		public var unspawnNotes:Array<Note> = [];
		public var strumLine:FlxSprite;
		public var strumLineNotes:FlxTypedGroup<StrumArrow> = null;
		public var playerStrums:FlxTypedGroup<StrumArrow> = null;
		public var cpuStrums:FlxTypedGroup<StrumArrow> = null;
		public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
		public var eventLog:Array<OutNote> = [];
		var notesHitArray:Array<Float> = [];


	/* Audio */
		public static var hitSoundEff:Sound;
		public static var hurtSoundEff:Sound;
		static var vanillaHurtSounds:Array<Sound> = [];
		public var vocals:FlxSound;
		var trainSound:FlxSound;
		var hitSound:Bool = false;

	/* Script Shite*/
		public static var stateType=0;
		public static var dialogue:Array<String> = [];
		public static var endDialogue:Array<String> = [];
		public static var hsBrTools:HSBrTools;
		public static var hsBrToolsPath:String = 'assets/';
		public static var nameSpace:String = "";
		public static var nsType:String = "";
		public static var stageTags:Array<String> = [];
		public static var beatAnimEvents:Map<Int,Map<String,IfStatement>>;
		public static var stepAnimEvents:Map<Int,Map<String,IfStatement>>;
		public static var inputEngineName:String = "Unspecified";
		public static var scripts:Array<String> = [];
		public static var stageObjects:Array<Dynamic<FlxObject>> = [];
		// public static var stages:Array<FlxSpriteGroup> = [];
		public static var customDiff = "";

		public var handleTimes:Bool = true;
		public var defaultCamZoom:Float = 1.05;
		public var realtimeCharCam:Bool = !FlxG.save.data.performance;
		public var inputMode:Int = 0;
		public var camBeat:Bool = true;
		public var cachedChars:Array<Map<String,Character>> = [[],[],[]];
		public var controlCamera:Bool = true;
		public var moveCamera(default,set):Bool = true;
		public function set_moveCamera(v):Bool{
			if(v){
				FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
			}else{
				FlxG.camera.follow(null);
			}
			return moveCamera = v;
		}

		var updateOverlay = true;
		var errorMsg:String = "";
		var songPositionBar:Float = 0;
		var updateTime:Bool = false;

	/* Objects */

		/*Cam whores*/
			public var camHUD:FlxCamera;
			public var camTOP:FlxCamera;
			public var camGame:FlxCamera;
			public var camFollow:FlxObject;
			private static var prevCamFollow:FlxObject;

		/* UI */

			public static var songPosBG(get,set):FlxSprite; // WHY IS THIS STATIC?
			public static function get_songPosBG(){return PlayState.instance.songPosBG_;}
			public static function set_songPosBG(vari){return PlayState.instance.songPosBG_ = vari;}
			public static var songPosBar(get,set):FlxBar; // WHY IS THIS STATIC?
			public static function get_songPosBar(){return PlayState.instance.songPosBar_;}
			public static function set_songPosBar(vari){return PlayState.instance.songPosBar_ = vari;}

			public static var underlay:FlxSprite;
			public var songPosBG_:FlxSprite;
			public var songPosBar_:FlxBar;
			public var kadeEngineWatermark:FlxText;
			public var healthBarBG:FlxSprite;
			public var healthBar:FlxBar;
			public var practiceText:FlxText;
			public var iconP1:HealthIcon;
			public var iconP2:HealthIcon;
			public var songName:FlxText;
			public var songTimeTxt:FlxText;
			public var scoreTxt:FlxText;
			var scoreTxtX:Float;
			var rating:FlxSprite;
			#if android
			public var noteButtons:Array<FlxSprite>;
			#end

		/* Stage Shite */

			public static var stage:String = "nothing";
			public static var stageInfo:StageInfo = null;
			/* Varis, too lazy to move somewhere else*/
			// Will fire once to prevent debug spam messages and broken animations
			private var triggeredAlready:Bool = false;
			// Will decide if she's even allowed to headbang at all depending on the song
			private var allowedToHeadbang:Bool = false;

	/* Character shite */
		public var gfChar:String = "gf";
		public static var dad:Character;
		public static var gf:Character;
		public static var boyfriend:Character;
		public static var girlfriend(get,set):Character;
		@:keep inline public static function get_girlfriend(){return gf;};
		@:keep inline public static function set_girlfriend(vari){return gf = vari;};
		public static var bf(get,set):Character;
		@:keep inline public static function get_bf(){return boyfriend;};
		@:keep inline public static function set_bf(vari){return boyfriend = vari;};
		public static var opponent(get,set):Character;
		@:keep inline public static function get_opponent(){return dad;};
		@:keep inline public static function set_opponent(vari){return dad = vari;};
		public static var player1:String = "bf";
		public static var player2:String = "bf";
		public static var player3:String = "gf";
		public static var dadShow = true;
		public var _dadShow = dadShow && FlxG.save.data.dadShow;
		public var gfShow:Bool = true;
		private var gfSpeed:Int = 1;
		public var forceChartChars:Bool = false;
		public var loadChars:Bool = true;
		public static var canUseAlts:Bool = false;

	/* Misc */
		public static var songOffset:Float = 0;


	/* Input */


	public var holdArray:Array<Bool> = [];
	public var pressArray:Array<Bool> = [];
	public var releaseArray:Array<Bool> = [];
	public var lastPressArray:Array<Bool> = [];



	// API stuff

		public function addEvent(id:Int,name:String,check:Int,value:Int,func:Dynamic->Void,?variable:String = "def",?type:String="equals"):IfStatement{
			var _events:Map<Int,Map<String,IfStatement>> = (switch(check){
				case 0:
					beatAnimEvents;
				default:
					stepAnimEvents;
			});
			if(_events[id] == null){
				_events[id] = new Map<String,IfStatement>();
			}
			return _events[id][name] = cast {
				isFunc:true,
				value:value,
				check:type,
				variable:(if(variable == "def") (if(check == 0) "curBeat" else "curStep") else variable),
				func:func,
				type:type
			};
		}


	/*Interpeter shit*/
		public override function addVariablesToHScript(interp:Interp){
			interp.variables.set("state",cast (this)); 
			interp.variables.set("game",cast (this));
			interp.variables.set("require",require);
			interp.variables.set("charGet",charGet); 
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
		}
		#if linc_luajit
		public override function addVariablesToLua(interp:SELua){
			interp.variables.set("state",cast (this)); 
			interp.variables.set("game",cast (this));
			interp.variables.set("charGet",charGet); 
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
			interp.variables.set("require",require);
		}
		#end


		public override function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
				try{
					if(func_name == "noteHitDad"){
						charCall("noteHitSelf",[args[1]],1);
						charCall("noteHitOpponent",[args[1]],0);
					}else if(func_name == "noteHit"){
						charCall("noteHitSelf",[args[1]],0);
						charCall("noteHitOpponent",[args[1]],1);
					}else if(func_name == "susHitDad"){
						charCall("susHitSelf",[args[1]],1);
						charCall("susHitOpponent",[args[1]],0);
					}else if(func_name == "susHit"){
						charCall("susHitSelf",[args[1]],0);
						charCall("susHitOpponent",[args[1]],1);
					}
					args.insert(0,this);
					if (id == "") {
						for (name in interps.keys()) {
							callSingleInterp(func_name,args,name);
						}
						if(Console.instance != null && Console.instance.commandBox != null){
							if(Console.instance.commandBox.interp != null) callSingleInterp(func_name,args,'console-hx',Console.instance.commandBox.interp);
							#if linc_luajit
								if(Console.instance.commandBox.selua != null) callSingleInterp(func_name,args,'console-lua',Console.instance.commandBox.selua);
							#end
						}
					}else callSingleInterp(func_name,args,id);
				}catch(e:hscript.Expr.Error){handleError('${func_name} for "${id}":\n ${e.toString()}');}

			}

	public override function errorHandle(?error:String = "",?forced:Bool = false) handleError(error,forced);
	public function handleError(?error:String = "",?forced:Bool = false){
		try{
			if(currentInterp.args[0] == this) currentInterp.args.shift();
			if(error == "") error = 'No error passed!\nInterp info: ${currentInterp}';
			if(error == "Null Object Reference") error = 'Null Object Reference;\nInterp info: ${currentInterp}';
			resetInterps();
			trace('Error!\n ${error}');
			parseMoreInterps = false;
			if(!songStarted && !forced && playCountdown){
				if(errorMsg == "") errorMsg = error; 
				// else trace(error);
				startedCountdown = true;
				// updateTime = true;
				// new FlxTimer().start(0.5,function(_){
				// 	handleError(error,true);
				// });
				LoadingScreen.loadingText = 'ERROR!';
				return;
			}
			errorMsg = "";
			FlxTimer.globalManager.clear();
			FlxTween.globalManager.clear();
			// updateTime = false;

			var _forced = (!songStarted && !forced && playCountdown);
			generatedMusic = false;
			persistentUpdate = false;
			persistentDraw = true;
			if(FinishSubState.instance != null){
				showTempmessage('Error! ${error}',FlxColor.RED);
			}

			Main.game.blockUpdate = Main.game.blockDraw = false;
			openSubState(new FinishSubState(0,0,error,_forced));
		}catch(e){trace('${e.message}\n${e.stack}');MainMenuState.handleError(error);
		}
	}

	static function charGet(charId:Dynamic,field:String):Dynamic{
		return Reflect.field(getCharFromID(charId),field);
	}
	static public function charSet(charId:Dynamic,field:String,value:Dynamic){
		Reflect.setField(getCharFromID(charId),field,value);
	}
	public static function getCharVariName(charID:Dynamic):String{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": "dad"; case "2" | "gf" | "girlfriend" | "p3": "gf"; default: "boyfriend";};
	}
	public static function getCharFromID(charID:Dynamic):Character{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": dad; case "2" | "gf" | "girlfriend" | "p3": gf; default: boyfriend;};
	}
	public static function getCharID(charID:Dynamic):Int{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": 1; case "2" | "gf" | "girlfriend" | "p3": 2; default: 0;};
	}
	static public function charAnim(charId:Dynamic = 0,animation:String = "",?forced:Bool = false){
		try{
			getCharFromID(charId).playAnim(animation,forced);
		}catch(e){MusicBeatState.instance.showTempmessage('Unable to play $animation: ${e.message}');}
	}


	@:keep inline public static function resetScore(){
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;
		maxCombo = 0;
		combo = 0;
		ghostTaps = 0;
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
			ghostTaps = StoryMenuState.weekGT;
			misses = StoryMenuState.weekMisses;
			maxCombo = StoryMenuState.weekMaxCombo;
			songScore = StoryMenuState.weekScore;
			accuracy = StoryMenuState.weekAccuracy;
		}

	}
	@:keep inline public function clearVariables(){

		resetInterps();
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
		botPlay = QuickOptionsSubState.getSetting("BotPlay");
		practiceMode = (FlxG.save.data.practiceMode || ChartingState.charting || onlinemod.OnlinePlayMenuState.socket != null || botPlay);
		introAudio = [
			Paths.sound('intro3'),
			Paths.sound('intro2'),
			Paths.sound('intro1'),
			Paths.sound('introGo'),
		];
		introGraphics = [
			"",
			Paths.image('ready'),
			Paths.image("set"),
			Paths.image("go"),
		];
		songStarted = false;
	}

	override public function softReloadState(?showWarning:Bool = true){
		if(!parseMoreInterps){
			showTempmessage('You are currently unable to reload interpeters!',FlxColor.RED);
			return;
		}
		callInterp('reload',[false]);
		callInterp('unload',[]);
		FlxTimer.globalManager.clear();
		FlxTween.globalManager.clear();
		resetInterps();
		loadScripts();
		generateSong();
		addNotes();
		var oldBf:Character = bf;
		bf = new Character(oldBf.x, oldBf.y,oldBf.isPlayer,oldBf.charType, oldBf.charInfo);
		this.replace(oldBf,bf);
		oldBf.destroy();
		oldBf = dad;
		dad = new Character(oldBf.x, oldBf.y,oldBf.isPlayer,oldBf.charType, oldBf.charInfo);
		this.replace(oldBf,dad);
		oldBf.destroy();


		callInterp('reloadDone',[]);
		if(showWarning) showTempmessage('Soft reloaded state. This is unconventional, Hold shift and press F5 for a proper state reload');
	}
	override public function loadScripts(?enableScripts:Bool = false,?enableCallbacks:Bool = false,?force:Bool = false){
		if((!enableScripts && !parseMoreInterps) || (!FlxG.save.data.menuScripts && !force)) return;
		super.loadScripts(enableScripts,enableCallbacks,force);
		for (i in 0 ... scripts.length) {
			var v = scripts[i];
			LoadingScreen.loadingText = 'Loading scripts: $v';
			loadSingleScript(v);
		}
	}
	public static var hasStarted = false;
	override public function new(){
		LoadingScreen.loadingText = "Starting Playstate";
		parseMoreInterps = (!QuickOptionsSubState.getSetting("Song hscripts") && !isStoryMode);
		useNormalCallbacks = false;
		// this.restartTimes = restartTimes;
		restartTimes++;
		super();
		checkInputFocus = false;
		PlayState.player1 = "";
		PlayState.player2 = "";
		PlayState.player3 = "";
	}

	
	override public function create(){
		#if !debug
		try{
		#end
		LoadingScreen.loadingText = 'Loading playstate variables';
		parseMoreInterps = (QuickOptionsSubState.getSetting("Song hscripts") || isStoryMode);
		if (instance != null) instance.destroy();
		downscroll = FlxG.save.data.downscroll;
		middlescroll = FlxG.save.data.middleScroll;
		setInputHandlers(); // Sets all of the handlers for input
		instance = this;
		clearVariables();
		hasStarted = true;
		logGameplay = FlxG.save.data.logGameplay;


		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		resetScore();

		TitleState.loadNoteAssets(); // Make sure note assets are actually loaded
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camTOP = new FlxCamera();
		camGame.bgColor = 0xFF000000;
		camHUD.bgColor = 0x00000000;
		camTOP.bgColor = 0x00000000;



		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camTOP);
		FlxG.cameras.setDefaultDrawTarget(camGame,true);
		// FlxCamera.defaultCameras = [camGame];



		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.parseJSONshit(SELoader.loadText('assets/data/tutorial/tutorial-hard.json'));

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		if(hsBrToolsPath == "" || !SELoader.exists(hsBrToolsPath)){
			hsBrToolsPath = 'assets/';
		}
		hsBrTools = getBRTools(hsBrToolsPath,'SONG');
		if(QuickOptionsSubState.getSetting("Song hscripts")){
			if(SELoader.exists(hsBrTools.path)){
				LoadingScreen.loadingText = 'Loading song scripts';
				loadScript(hsBrTools.path,'','SONG',hsBrTools);
			}
		}
		
		//dialogue shit
		loadDialog();
		LoadingScreen.loadingText = "Loading stage";
		// Stage management
		var bfPos:Array<Float> = [0,0]; 
		var gfPos:Array<Float> = [0,0]; 
		var dadPos:Array<Float> = [0,0]; 
		stageInfo = (if(PlayState.isStoryMode || ChartingState.charting || SONG.forceCharacters || isStoryMode || FlxG.save.data.selStage == "default") TitleState.findStageByNamespace(SONG.stage,onlinemod.OfflinePlayState.nameSpace) else TitleState.findStageByNamespace(FlxG.save.data.selStage,onlinemod.OfflinePlayState.nameSpace));
		stage = stageInfo.folderName;
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
			switch(stage.toLowerCase()){
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
						stage = TitleState.retStage(stage);
						if(stage == "nothing"){
							stageTags = ["empty"];
							defaultCamZoom = 0.9;
							curStage = 'nothing';
						}else if(stage == "" || !SELoader.exists('${stageInfo.path}/${stageInfo.folderName}')){
							trace('"${stage}" not found, using "Stage"!');
							stageTags = ["inside"];
							defaultCamZoom = 0.9;
							stage = curStage = 'stage';
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
							curStage = stage;
							stageTags = [];
							var stagePath:String = '${stageInfo.path}/${stageInfo.folderName}';
							if (SELoader.exists('$stagePath/config.json')){
								var stageProperties = StageEditor.loadStage(this,'$stagePath/config.json');
								
								 // This doesn't have to be provided, doing it this way
								bfPos = stageProperties.bfPos;
								dadPos = stageProperties.dadPos;
								gfPos = stageProperties.gfPos;
								stageTags = stageProperties.tags;
								if(gfShow) gfShow = stageProperties.showGF;
							}
							var brTool = getBRTools(stagePath);
							for (i in CoolUtil.orderList(SELoader.readDirectory(stagePath))) {
								if(i.endsWith(".hscript")){
									parseHScript(SELoader.getContent('$stagePath/$i'),brTool,"STAGE/" + i,'$stagePath/$i');
								}
							}
						}
					}
				}
		}
		LoadingScreen.loadingText = "Loading scripts";
		
		if(QuickOptionsSubState.getSetting("Song hscripts")){
			if(FlxG.save.data.scripts != null){
				loadScripts(null,null);
			}

		}
		if(onlinemod.OnlinePlayMenuState.socket != null){
			for (i in 0 ... onlinemod.OnlinePlayMenuState.scripts.length) {
				var v = onlinemod.OnlinePlayMenuState.scripts[i];
				LoadingScreen.loadingText = 'loading script: $v';
				var _v = v.substr(v.lastIndexOf('/') - 1);
				if(v.lastIndexOf('/') > v.length - 2){
					_v = v.substr(0,v.lastIndexOf('/') - 1).substr(v.lastIndexOf('/'));
				}
				loadScript(v,null,'ONLINE/' + _v);
			}
			for (i in 0 ... onlinemod.OnlinePlayMenuState.rawScripts.length) {
				parseHScript(onlinemod.OnlinePlayMenuState.rawScripts[i][1],hsBrTools,onlinemod.OnlinePlayMenuState.rawScripts[i][0],'onlineScript:$i');
			}
		}
		var bfShow = FlxG.save.data.bfShow;
		if(PlayState.player1 == "")PlayState.player1 = SONG.player1;
		if(PlayState.player2 == "")PlayState.player2 = SONG.player2;
		if(PlayState.player3 == "")PlayState.player3 = SONG.gfVersion;
		if(PlayState.player1 == "" || PlayState.player1.toLowerCase() == "lonely" || PlayState.player1.toLowerCase() == "hidden" || PlayState.player1.toLowerCase() == "nothing") bfShow = false;
		if(PlayState.player2 == "" || PlayState.player2.toLowerCase() == "lonely" || PlayState.player2.toLowerCase() == "hidden" || PlayState.player2.toLowerCase() == "nothing") _dadShow = false;
		if(PlayState.player3 == "" || PlayState.player3.toLowerCase() == "lonely" || PlayState.player3.toLowerCase() == "hidden" || PlayState.player3.toLowerCase() == "nothing") gfShow = false;
		var player1CharInfo = null;
		var player2CharInfo = null;
		callInterp("afterStage",[]);

		if(!(SONG.forceCharacters || PlayState.isStoryMode || ChartingState.charting || isStoryMode)){

			if (PlayState.player2 == "bf" || !FlxG.save.data.charAuto){
				PlayState.player2 = FlxG.save.data.opponent;
	    	}
	    	
			if((PlayState.player1 == "bf" && FlxG.save.data.playerChar != "automatic") || !FlxG.save.data.charAutoBF ){
				PlayState.player1 = FlxG.save.data.playerChar;
			}
		}
		{
			var p1List:Array<String> = [FlxG.save.data.playerChar];
			var p2List:Array<String> = [FlxG.save.data.opponent];
			for(id in PlayState.player1.split('/')) p1List.push(id);
			for(id in PlayState.player2.split('/')) p2List.push(id);

			player1CharInfo = TitleState.getCharFromList(p1List,onlinemod.OfflinePlayState.nameSpace);
			player2CharInfo = TitleState.getCharFromList(p2List,onlinemod.OfflinePlayState.nameSpace);
			PlayState.player1 = player1CharInfo.getNamespacedName();
			PlayState.player2 = player2CharInfo.getNamespacedName();
		}
		// if (invertedChart){ // Invert players if chart is inverted, Does not swap sides, just changes character names
		// 	var pl:Array<String> = [player1,player2];
		// 	player1 = pl[1];
		// 	player2 = pl[0];
		// }
		if(loadChars){

			LoadingScreen.loadingText = "Loading GF";
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
			if(gf== null || !FlxG.save.data.persistGF || (!FlxG.save.data.gfShow && !Std.isOfType(gf,EmptyCharacter)) || gf.getNamespacedName() != player2){
				if (FlxG.save.data.gfShow && gfShow)
					gf = new Character(400, 100, player3,false,2);
				else gf =  new EmptyCharacter(400, 100);
			}else{
				try{
					gf.x = 400;
					gf.y = 100;
					gf.playAnim('songStart');
				}catch(e){
					handleError((if(FlxG.save.data.persistGF) 'Crashed while setting up GF, maybe try disabling persistant GF in your options? ' else 'Crash while trying to setup GF:') + '${e.message}\n${e.stack}');
					gf = new EmptyCharacter(770,100);
				}
			}
			gf.scrollFactor.set(0.95, 0.95);
			
			LoadingScreen.loadingText = "Loading opponent";
			if (!ChartingState.charting && SONG.player1.startsWith("gf") && FlxG.save.data.charAuto) player1 = FlxG.save.data.gfChar;
			if (!ChartingState.charting && SONG.player2.startsWith("gf") && FlxG.save.data.charAuto) player2 = FlxG.save.data.gfChar;

			// if(dad == null || !FlxG.save.data.persistOpp || (!(dadShow || FlxG.save.data.dadShow) && !Std.isOfType(dad,EmptyCharacter)) || dad.getNamespacedName() != player2){
			if (_dadShow && !(player3 == player2 && player1 != player2))
				dad = {x:100, y:100, charInfo:player2CharInfo,isPlayer:false,charType:1};
			else dad = new EmptyCharacter(100, 100);
			// }else{
				// dad.x = 100;
				// dad.y = 100;
			// }

			LoadingScreen.loadingText = "Loading BF";
			if(boyfriend == null || !FlxG.save.data.persistBF || (!FlxG.save.data.bfShow && !Std.isOfType(boyfriend,EmptyCharacter)) || boyfriend.getNamespacedName() != player1){
				if (bfShow)
					boyfriend = {x:770, y:100, charInfo:player1CharInfo,isPlayer:true,charType:0} ;
				else boyfriend =  new EmptyCharacter(770,100);
			}else{
				try{

					boyfriend.x = 770;
					boyfriend.y = 100;
					boyfriend.playAnim('songStart');
				}catch(e){
					handleError((if(FlxG.save.data.persistBF) 'Crashed while setting up BF, maybe try disabling persistantBF in your options? ' else 'Crash while trying to setup BF:') + '${e.message}\n${e.stack}');
					boyfriend = new EmptyCharacter(770,100);
				}
			}
		}else{
			dad = new EmptyCharacter(100, 100);
			boyfriend = new EmptyCharacter(400,100);
			gf = new EmptyCharacter(400, 100);
		}
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);

		camPos.set(camPos.x + gf.camX, camPos.y + gf.camY);
		cachedChars[0][bf.curCharacter] = bf;
		cachedChars[1][dad.curCharacter] = dad;
		cachedChars[2][gf.curCharacter] = gf;
		cachedChars[0]['default'] = bf;
		cachedChars[1]['default'] = dad;
		cachedChars[2]['default'] = gf;
		cachedChars[0]['_song'] = bf;
		cachedChars[1]['_song'] = dad;
		cachedChars[2]['_song'] = gf;
		
		LoadingScreen.loadingText = "Adding characters";

		// REPOSITIONING PER STAGE
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
			dad.destroy();
			dad = gf;
			if (isStoryMode){
				camPos.x += 600;
				tweenCamIn();
			}
		}

		if (player3 == player1 && player1 != player2){ // Don't hide GF if player 1 is GF
			boyfriend.destroy();
			boyfriend = gf;
			if (isStoryMode){
				camPos.x += 600;
				tweenCamIn();
			}
			
		}
		// if (dad.spiritTrail && FlxG.save.data.distractions){
		// 	var dadTrail = new FlxSprTrail(dad,0.2,0,2);
		// 	add(dadTrail);
		// }
		// if (boyfriend.spiritTrail && FlxG.save.data.distractions){
		// 	var bfTrail = new FlxSprTrail(boyfriend,0.2,0,2);
		// 	add(bfTrail);
		// }


		add(gf);

		charCall("addGF",[],-1);
		callInterp("addGF",[]);
		add(dad);
		charCall("addDad",[],-1);
		callInterp("addDad",[]);
		add(boyfriend);
		callInterp("addChars",[]);
		charCall("addChars",[],-1);


		var doof:DialogueBox = new DialogueBox(false, dialogue);
		if((dialogue != null && dialogue[0] != null)){
			doof.scrollFactor.set();
			doof.finishThing = startCountdownFirst;
			doof.cameras = [camTOP];
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
		// Note splashes
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>(10);
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(boyfriend, 0);
		// noteSplash0.cameras = [camHUD];

		if (SONG.difficultyString != null && SONG.difficultyString != "") songDiff = SONG.difficultyString;
		else songDiff = if(customDiff != "") customDiff else if(stateType == 4) "mods/charts" else if (stateType == 5) "osu! beatmap" else (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		playerStrums = new FlxTypedGroup<StrumArrow>();
		cpuStrums = new FlxTypedGroup<StrumArrow>();

		// startCountdown();



		LoadingScreen.loadingText = "Loading chart";
		generateSong(SONG.song);

		LoadingScreen.loadingText = "Loading UI";
		// add(strumLine);


		if (prevCamFollow == null){
			camFollow = new FlxObject(0, 0, 1, 1);
			camFollow.setPosition(camPos.x, camPos.y);
		}else{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		followChar(0,true);
		add(camFollow);



		moveCamera = moveCamera;
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		// FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition){ // This is just to prevent null object references. These variables are properly setup later
			songPosBG_ = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
			songPosBar_ = new FlxBar(0,0, LEFT_TO_RIGHT, Std.int(songPosBG_.width - 8), Std.int(songPosBG_.height - 8), this, 'songPositionBar', 0, 1);
			songName = new FlxText(0,0,0,SONG.song, 16);
			songTimeTxt = new FlxText(0,0,0,"00:00/00:00", 16);
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
				" | Combo:00000000"+
				" | Combo Breaks:0000000" + PlayState.misses + 																				// Misses/Combo Breaks
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

		

		iconP1 = new HealthIcon(bf.getNamespacedName(), true,boyfriend.clonedChar,boyfriend.charLoc);
		iconP1.antialiasing = bf.antialiasing;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.trackedSprite = healthBar;
		add(iconP1);

		iconP2 = new HealthIcon(dad.getNamespacedName(), false,dad.clonedChar,dad.charLoc);
		iconP2.antialiasing = dad.antialiasing;
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.trackedSprite = healthBar;
		// iconP2.offset.set(0,iconP2.width);

		add(iconP2);

		callInterp("addUI",[]);
		charCall("addUI",[],-1);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.isTracked = iconP2.isTracked = !practiceMode;
		if(practiceMode){
			// if(practiceMode ){
			practiceText = new FlxText(0,healthBar.y - 64,(if(botPlay) "Botplay" else if(flippy)"Flippy Mode" else if(ChartingState.charting) "Testing Chart" else "Practice mode"),16);
			practiceText.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			practiceText.cameras = [camHUD];
			practiceText.screenCenter(X);
			if(downscroll){
				practiceText.y += 20;
			}
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
		scoreTxt.alpha = 0;
		iconP1.y = healthBarBG.y - (iconP1.height / 2);
		iconP2.y = healthBarBG.y - (iconP2.height / 2);
		kadeEngineWatermark.cameras = [camHUD];

		hitSound = FlxG.save.data.hitSound;
		if(FlxG.save.data.hitSound && hitSoundEff == null) hitSoundEff = SELoader.loadSound(( if (SELoader.exists('mods/hitSound.ogg')) 'mods/hitSound.ogg' else Paths.sound('Normal_Hit')));

		if(hurtSoundEff == null) hurtSoundEff = SELoader.loadSound(( if (SELoader.exists('mods/hurtSound.ogg')) 'mods/hurtSound.ogg' else Paths.sound('ANGRY')));
		if(vanillaHurtSounds[0] == null && FlxG.save.data.playMisses) vanillaHurtSounds = [SELoader.loadSound('assets/shared/sounds/missnote1.ogg',true),SELoader.loadSound('assets/shared/sounds/missnote2.ogg',true),SELoader.loadSound('assets/shared/sounds/missnote3.ogg',true)];

		startingSong = true;
		

		
		add(scoreTxt);
		

		LoadingScreen.loadingText = "Finishing up";
		super.create();
		openfl.system.System.gc();
		LoadingScreen.loadingText = "Starting countdown/dialog";
		if (isStoryMode)
		{
			if(dialogue[0] != null){
				callInterp('openDialogue',[doof]);
				schoolIntro(doof);
			}else{
				startCountdownFirst();
			}
		}else{
			startCountdownFirst();
		}

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
					'bf:Beep' +
					"dad:If you want to date her...\\n" +
					"dad:You're going to have to go \\nthrough ME first!\n" +
					'bf:Beep bop!'
				);
			case 'fresh':
				dialogue = CoolUtil.coolFormat("dad:Not too shabby $BF.\ndad:But I'd like to see you\\n keep up with this!");
			case 'dad battle':
				dialogue = CoolUtil.coolFormat(
					"dad:Gah, you think you're hot stuff?\n"+
					"dad:If you can beat me here...\n"+
					"dad:Only then I will even CONSIDER letting you\\ndate my daughter!"+
					'bf:Beep!'
				);
		}
	}



	inline function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		
		// FlxTween.tween(black,0.3)
		// playCountdown = false;
		// startCountdownFirst();
		
		FlxTween.tween(black, {alpha: 0}, 1, {
			onComplete: function(twn:FlxTween){
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdownFirst();
				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

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
	public static var introAudio:Array<flixel.system.FlxAssets.FlxSoundAsset> = [];
	public static var introGraphics:Array<flixel.system.FlxAssets.FlxGraphicAsset> = [];
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


			
			startedCountdown = true;
			Conductor.songPosition = (introAudio.length + 1) * -500;


			if(errorMsg != "") {
				Conductor.songPosition = -500;
				return;
			}
			
			FlxG.sound.music.pause();
			vocals.pause();
			FlxG.sound.music.onComplete = endSong;
			// vocals.play();

			// Song duration in a float, useful for the time left feature
			songLength = FlxG.sound.music.length;
			songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
			if (FlxG.save.data.songPosition) addSongBar();
		}
		var swagCounter:Int = 0;
		
		trace('Starting Countdown');
		callInterp("startCountdown",[]);
		


		startTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer){
			dad.dance();
			if(gf != boyfriend && gf != dad) gf.dance();
			boyfriend.dance();

			callInterp("startTimerStep",[swagCounter]);
			if(playCountdown){

				switch (swagCounter){
					case 0:
						if (errorMsg != ""){
							handleError(errorMsg);
							startTimer.cancel();
							return;
						}
				}
				if(introGraphics[swagCounter] != null && introGraphics[swagCounter] != ""){
					var go:FlxSprite = new FlxSprite().loadGraphic(introGraphics[swagCounter]);
					go.scrollFactor.set();


					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 500, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween){go.destroy();}
					});
				}
				if(introAudio[swagCounter] != null && introAudio[swagCounter] != "") FlxG.sound.play(introAudio[swagCounter],FlxG.save.data.otherVol);
			}
			callInterp("startTimerStepAfter",[swagCounter]);

			swagCounter += 1;
			// generateSong('fresh');
		}, introAudio.length + 1);
	}

	@:keep inline function charCall(func:String,args:Array<Dynamic>,?char:Int = -1){
		currentInterp.isActive = true;
		currentInterp.name = 'char: ${char}';
		currentInterp.currentFunction = func;
		currentInterp.args = args;
		switch(char){
			case 0: boyfriend.callInterp(func,args);
			case 1: dad.callInterp(func,args);
			case 2: gf.callInterp(func,args);
			case -1:
				currentInterp.name = 'char: 0';
				boyfriend.callInterp(func,args);
				currentInterp.name = 'char: 1';
				dad.callInterp(func,args);
				currentInterp.name = 'char: 2';
				gf.callInterp(func,args);
		}
		currentInterp.reset();
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;


	public var songStarted:Bool = false;
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
	function startSong(?alrLoaded:Bool = false):Void{
		FlxG.sound.music.play();
		vocals.play();
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		FlxTween.tween(scoreTxt,{alpha:1},0.5);


		#if discord_rpc
			DiscordClient.updateSong();
		#end
		// Song check real quick

		if(errorMsg != "") {handleError(errorMsg,true);return;}
		charCall("startSong",[]);
		callInterp("startSong",[]);
		updateTime = FlxG.save.data.songPosition;


		if(!FlxG.save.data.skipToFirst || onlinemod.OnlinePlayMenuState.socket != null) return;

		var _validNote:Bool = false;
		var _validUnspawn:Float = 0;
		var isJumpTo:Bool = false;
		if(jumpTo != 0){
			// Conductor.songPosition = FlxG.sound.music.time = vocals.time = jumpTo;
			_validUnspawn = jumpTo;
			isJumpTo = true;
			jumpTo = 0;
		}else{
			for (_ => n in notes.members) {
				if(!n.eventNote){
					if(n.strumTime >= 10000){
						_validUnspawn = n.strumTime;
						_validNote = false;
						break;
					}
					_validNote = true;

					break;
				}
			}
			if(!_validNote){
				for (_ => n in unspawnNotes) {
					if(!n.eventNote){
						if(n.strumTime >= 10000){
							_validUnspawn = n.strumTime;
							_validNote = false;
							break;
						}
						_validNote = true;

						break;
					}
				}
			}
		}
		if(!_validNote){
			skipPos = _validUnspawn - 5000; // -5000 is to make sure all of the notes actually appear and don't blindside the player
			jumpToText = new FlxText(0,0,1000,"Press a note button to skip to " + Math.floor(skipPos * 0.001) + " seconds");
			jumpToText.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			jumpToText.cameras = [camHUD];
			jumpToText.screenCenter(XY);
			jumpToText.y -= 20;
			add(jumpToText);
			FlxTween.tween(jumpToText,{alpha:1},0.4);
			jumpToTimer = FlxTween.tween(jumpToText,{y:jumpToText.y + 40},10,{onUpdate:function(_){
				if(subState != null || !acceptInput || !(controls.RIGHT_P || controls.LEFT_P || controls.UP_P || controls.DOWN_P)) return;
				if(isJumpTo){
					var arrowList:Array<Note> = [];
					for (n in unspawnNotes) {
						if(!n.eventNote){
							if(n.strumTime < _validUnspawn){
								arrowList.push(n);
							}else{
								break;
							}
						}
					}
					for (n in arrowList) {
						unspawnNotes.remove(n);
					}

				}
				FlxG.sound.music.time = Conductor.songPosition = skipPos;
				if(vocals != null) vocals.time = FlxG.sound.music.time;
				FlxTween.tween(PlayState.jumpToText,{alpha:0},0.2,{onComplete:function(_){jumpToTimer.cancelChain();PlayState.jumpToText.destroy();}});
			}});
			jumpToTimer.then(FlxTween.tween(PlayState.jumpToText,{alpha:0,y:jumpToText.y + 5},0.4,{onComplete:function(_){PlayState.jumpToText.destroy();}}));
		}
		

	}
	public var skipPos:Float = 0;
	public static var jumpToText:FlxText;
	var jumpToTimer:FlxTween;

	@:keep inline function addSongBar(?minimal:Bool = false){

		if(songPosBG_ == null) songPosBG_ = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
		// songPosBG_.scale.set(1,2);
		// songPosBG_.updateHitbox();
		if (downscroll) songPosBG_.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap; 
		songPosBG_.screenCenter(X);
		songPosBG_.scrollFactor.set();

		if(songPosBar_ == null) songPosBar_ = new FlxBar(0,0, LEFT_TO_RIGHT, Std.int(songPosBG_.width - 8), Std.int(songPosBG_.height - 8), this,
			'songPositionBar', 0, 100);
		songPosBar_.x = songPosBG_.x + 4;
		songPosBar_.y = songPosBG_.y + 4 + FlxG.save.data.guiGap;
		songPosBar_.numDivisions = 1000;
		songPosBar_.setRange(0,songLength - 1000);
		songPosBar_.scrollFactor.set();
		songPosBar_.createFilledBar(FlxColor.GRAY, FlxColor.LIME);

		if(songName == null) songName = new FlxText(0,0,SONG.song, 14);
		songName.text = SONG.song;
		songName.x = (songPosBG_.x + 20);
		songName.y = songPosBG_.y + 1;
		songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		songName.scrollFactor.set();
		if (songTimeTxt == null) songTimeTxt = new FlxText(0,0,0,"00:00/0:00", 16);
		songTimeTxt.x = songPosBG_.x + songPosBG_.width - (20 + songTimeTxt.width);
		songTimeTxt.y = songPosBG_.y + 1;
		if (downscroll) songName.y -= 3;
		songTimeTxt.text = "00:00/" + songLengthTxt;
		songTimeTxt.x -= songTimeTxt.width;
		songTimeTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		songTimeTxt.scrollFactor.set();


		songPosBG_.cameras = [camHUD];
		songPosBar_.cameras = [camHUD];
		songName.cameras = [camHUD];
		songTimeTxt.cameras = [camHUD];

		songPosBG_.alpha = songPosBar_.alpha = songName.alpha = songTimeTxt.alpha = 0;

		FlxTween.tween(songPosBG_,{alpha:1},0.5);
		FlxTween.tween(songPosBar_,{alpha:1},0.5);
		FlxTween.tween(songName,{alpha:1},0.5);
		FlxTween.tween(songTimeTxt,{alpha:1},0.5);

		add(songPosBG_);
		add(songPosBar_);
		add(songName);
		add(songTimeTxt);
		

	}

	var debugNum:Int = 0;
	@:keep inline public function generateNotes(){
		callInterp("generateNotes",[]);
		var songData = SONG;
		if (notes == null) notes = new FlxTypedGroup<Note>();
		if (eventNotes == null) eventNotes = new FlxTypedGroup<Note>();
		CoolUtil.clearFlxGroup(notes);
		CoolUtil.clearFlxGroup(eventNotes);
		add(notes);
		Note.lastNoteID = -1;

		var noteData:Array<SwagSection> = songData.notes;

		// Per song offset check
		
		var daBeats:Int = 0; // Current section ID, ig
		var section:SwagSection = null;
		while (daBeats < noteData.length)
		{
			section = noteData[daBeats];
			if(section == null || section.sectionNotes == null || section.sectionNotes[0] == null) {
				daBeats += 1;
				continue;
			}
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			var daStrumTime:Float = 0;
			for (songNotes in section.sectionNotes)
			{
				daStrumTime = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0) daStrumTime = 0;
				if(daStrumTime < Conductor.songPosition) continue;

				var daNoteData:Int = songNotes[1];


				var gottaHitNote:Bool = (if (daNoteData % 8 > 3) !section.mustHitSection else section.mustHitSection);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// if(songNotes[3] != null) trace('Note type: ${songNotes[3]}');
				//                       new(strumTime,  _noteData, prevNote, sustainNote,_inCharter,_type,_rawNote,playerNote)
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,false,false,songNotes[3],songNotes,gottaHitNote);
				if(swagNote.killNote){swagNote.destroy();continue;}
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				unspawnNotes.push(swagNote);
				if(swagNote.eventNote) continue;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				var lastSusNote = false; // If the last note is a sus note
				var _susNote:Float = 0;
				if(susLength > 0.1){

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,false,songNotes[3],songNotes,gottaHitNote);
						if(sustainNote.killNote){sustainNote.destroy();continue;}
						sustainNote.scrollFactor.set();
						sustainNote.sustainLength = susLength;
						unspawnNotes.push(sustainNote);
						lastSusNote = true;
						_susNote = susNote;
					}
					if(susLength % 1 > 0.1){ // Allow for float note lengths, hopefully
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susLength), daNoteData, oldNote, true,false,songNotes[3],songNotes,gottaHitNote);
						sustainNote.scrollFactor.set();
						sustainNote.sustainLength = susLength;
						unspawnNotes.push(sustainNote);
						lastSusNote = true;

					}
				}
			}

			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
		callInterp("generateNotesAfter",[unspawnNotes]);

	}
	public function generateSong(?dataPath:String = ""){

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		if (vocals == null ){
			if (SONG.needsVoices){
				SONG.needsVoices = false;
				showTempmessage("Song needs voices but none found! Automatically disabled");
			}
			vocals = new FlxSound();
		}
		vocals.looped = false;
		FlxG.sound.list.add(vocals);

		callInterp("generateSongBefore",[]);
		generateNotes();
		callInterp("generateSong",[unspawnNotes]);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}
	public var useNoteCameras:Bool = true; // Legacy support because fuck you
	public var playerNoteCamera:FlxCamera;
	public var opponentNoteCamera:FlxCamera; 
	inline function readdCam(camera:FlxCamera){
		FlxG.cameras.remove(camera,false);
		FlxG.cameras.add(camera,false);
	}
	function generateStaticArrows(player:Int):Void
	{
		if(useNoteCameras){
			var camWhore = FlxG.cameras.list;
			if(player == 1){
				if(playerNoteCamera != null)playerNoteCamera.destroy();
				playerNoteCamera = new FlxCamera(0,0,
												1280,720
												);
				if(FlxG.save.data.undlaSize == 0 && underlay != null){
					underlay.cameras = [playerNoteCamera];
					// playerNoteCamera.fill(FlxColor.BLACK,true,FlxG.save.data.undlaTrans);
				}
				// playerNoteCamera.x = ;
				// playerNoteCamera.width = ;
				// readdCam(camHUD);
				FlxG.cameras.add(playerNoteCamera,false);
				playerNoteCamera.bgColor = 0x00000000;

				readdCam(camHUD);
				readdCam(camTOP);
			}else{
				if(opponentNoteCamera != null)opponentNoteCamera.destroy();
				opponentNoteCamera = new FlxCamera(0,0,
												1280,(if(middlescroll) 1080 else 720));
				opponentNoteCamera.bgColor = 0x00000000;
				opponentNoteCamera.color = 0xAAFFFFFF;

				if(middlescroll){
					opponentNoteCamera.setScale(0.5,0.5);
				}
				// readdCam(camHUD,false);
				FlxG.cameras.add(opponentNoteCamera,false);
				readdCam(camHUD);
				readdCam(camTOP);
				

			}
		}
		for (i in 0...4){
			var babyArrow:StrumArrow = new StrumArrow(i,0, strumLine.y);

			charCall("strumNoteLoad",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteLoad",[babyArrow,player == 1]);
			babyArrow.init();


			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			// if (!isStoryMode)
			// {
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			if(player == 1) babyArrow.color = 0xdddddd;
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
			if(useNoteCameras){

				babyArrow.screenCenter(X);
				babyArrow.x += ((Note.swagWidth #if(android) * if(FlxG.save.data.useStrumsAsButtons) 1.5 else 1 #end ) * i) + i - 
				(Note.swagWidth + (Note.swagWidth * ( #if(android) if(FlxG.save.data.useStrumsAsButtons) 1 else #end 0.5) ));
				#if android
				if(FlxG.save.data.useStrumsAsButtons){
					// babyArrow.setGraphicSize(1);
					babyArrow.scale.set(1,1);
					babyArrow.updateHitbox();
				}
				#end
				// babyArrow.x += 2 + (Note.swagWidth * i + 1);
				babyArrow.cameras = [switch(player){
					case 1:
						playerNoteCamera;
					default:
						opponentNoteCamera;
				}];
			}else{

				if(middlescroll){
					switch(player){
						case 1:{
							babyArrow.screenCenter(X);
							babyArrow.x += (Note.swagWidth * i) + i - (Note.swagWidth + (Note.swagWidth * 0.5));
						}
						case 0:
							// babyArrow.screenCenter(X);
							babyArrow.x = (FlxG.width * (if(babyArrow.ID > 1)0.75 else 0.25)) + (Note.swagWidth * i + i) - (Note.swagWidth * 2 + 2);
					}

				}else{
					babyArrow.x = (FlxG.width * (if(player == 1) 0.625 else 0.15)) + (Note.swagWidth * i) + i - Note.swagWidth;
				}
			}
			babyArrow.visible = (player == 1 || FlxG.save.data.oppStrumLine);

			
			cpuStrums.forEach(function(spr:FlxSprite){					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
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
		if(useNoteCameras){
			if(player == 1){
				if(underlay != null && FlxG.save.data.undlaSize == 0 && player == 1){
					underlay.screenCenter(X);
				}
				playerNoteCamera.x = Std.int(FlxG.width * (if(middlescroll) 0 else 0.25));
			}else{
				opponentNoteCamera.x = Std.int(FlxG.width * -0.25);
				if(middlescroll){
					opponentNoteCamera.x -= 100;
					// if(downScroll)opponentNoteCamera.y = 360;
				}
				

			}
		}
		if(player == 1){add(grpNoteSplashes);}
		#if android
		if(FlxG.save.data.useTouch && !FlxG.save.data.useStrumsAsButtons && player == 0){
			var _width = Std.int((FlxG.width / 4) - 1);
			var _height = Std.int(FlxG.height + 100);
			noteButtons = [
				// 
				new FlxSprite(0,50).loadGraphic(FlxGraphic.fromRectangle(_width,_height,0xffc24b99)),
				// 0x00ffff
				new FlxSprite(_width * 1,50).loadGraphic(FlxGraphic.fromRectangle(_width,_height,0xff00ffff)),
				// 0x12fa05
				new FlxSprite(_width * 2,50).loadGraphic(FlxGraphic.fromRectangle(_width,_height,0xff12fa05)),
				// 0xf9393f
				new FlxSprite(_width * 3,50).loadGraphic(FlxGraphic.fromRectangle(_width,_height,0xfff9393f)),
			];
			for(spr in noteButtons){
				FlxTween.tween(spr,{alpha:0.2},1);
				spr.cameras = [camHUD];
				spr.scrollFactor.set();
				add(spr);
			}
		}
		#end

	}

	@:keep inline function tweenCamIn():Void{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused){
			
			if (FlxG.sound.music != null && !startingSong){
				vocals.pause();
				vocals.time = Conductor.songPosition = FlxG.sound.music.time;
			}
			canPause = false;
		}

		return super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused){
			if (FlxG.sound.music != null && !startingSong){
				vocals.time = Conductor.songPosition = FlxG.sound.music.time;
			}

			if (!startTimer.finished) startTimer.active = true;
			canPause = true;
			paused = false;
			vocals.looped = FlxG.sound.music.looped = false;

		}

		return super.closeSubState();
	}
	
	var resyncCount:Int = 0;
	function resyncVocals():Void{

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if(SONG.needsVoices && (!vocals.playing || vocals.time > Conductor.songPosition + 5 || vocals.time < Conductor.songPosition - 5)){
			vocals.time = FlxG.sound.music.time;
			vocals.play();
		}
		resyncCount++;

	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var nps:Int = 0;
	var maxNPS:Int = 0;

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
		FlxG.sound.music.volume = this.vocals.volume = 0;

		openSubState(new FinishSubState(0, 0,win));
		
	}

	public var songLengthTxt = "N/A";

	public var lastFrameTime:Float = 0;
	var currentSpeed:Float = 1;
	override public function update(elapsed:Float)
	{
		#if !debug
		try{
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
		if (combo > maxCombo) maxCombo = combo;


		super.update(elapsed);
		callInterp("update",[elapsed]);

		
		if (!FlxG.save.data.accuracyDisplay) scoreTxt.text = "Score: " + songScore;
		else scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);

		// if(FlxG.save.data.songInfo == 0) scoreTxt.x = scoreTxtX - scoreTxt.text.length;
		if (updateTime) songTimeTxt.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt;
		
		if ((FlxG.keys.justPressed.ENTER 
		     #if(android) || FlxG.mouse.justReleased && FlxG.mouse.screenY < 50 || FlxG.swipes[0] != null && FlxG.swipes[0].duration < 1 && FlxG.swipes[0].startPosition.y - FlxG.swipes[0].endPosition.y < -200 #end )
		     // #if(android) || FlxG.swipes[0] #end ) 
			&& startedCountdown && canPause)
		{
			pause();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		// iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		// iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		// iconP1.updateHitbox();
		// iconP2.updateHitbox();
		if(iconP1.isTracked){
			iconP1.trackingOffset = -26;
			iconP1.updateTracking(if(healthBar.fillDirection == LEFT_TO_RIGHT) health * 0.5 else 1 - (health * 0.5));
		}
		if(iconP2.isTracked){
			iconP2.trackingOffset = -(iconP2.width - 26);
			iconP2.updateTracking(if(healthBar.fillDirection == LEFT_TO_RIGHT) health * 0.5 else 1 - (health * 0.5));
		}

		// else{
		// 	iconP1.y = playerStrums.members[0].y - (iconP1.height / 2);
		// 	iconP2.y = playerStrums.members[0].y - (iconP2.height / 2);
		// }

		if (health > 2 && handleHealth) health = 2;
		if(swappedChars){
			iconP2.updateAnim(healthBar.percent);
			iconP1.updateAnim(100 - healthBar.percent);
		}else{

			iconP1.updateAnim(healthBar.percent);
			iconP2.updateAnim(100 - healthBar.percent);
		}
		testanimdebug();


		if (startingSong && handleTimes)
		{
			if (startedCountdown){
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0) startSong();
			}
		}else if (handleTimes){
			if(FlxG.sound.music != null){
				if(currentSpeed != speed){
					currentSpeed = speed;
					@:privateAccess
					{
						// The __backend.handle attribute is only available on native.
						try{
							// We need to make CERTAIN vocals exist and are non-empty
							// before we try to play them. Otherwise the game crashes.
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
							if (vocals != null && vocals.length > 0) lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
						}catch (e) {}
					}
				}
				if(FlxG.sound.music.time == lastFrameTime){
					Conductor.songPosition += elapsed * 1000 * speed;
				}else{
					Conductor.songPosition = FlxG.sound.music.time;
				}
				if(vocals != null && vocals.playing && Conductor.songPosition > vocals.length){
					vocals.pause();
				}
				lastFrameTime = FlxG.sound.music.time;
			}

			if (subState == null ){
				songPositionBar = Conductor.songPosition;
				songTime = FlxG.sound.music.time;
				previousFrameTime = FlxG.game.ticks;
			}
		}

		if(FlxG.save.data.animDebug && updateOverlay){
			var vt = 0;
			if(vocals != null) vt = Std.int(vocals.time);
			var e = getDefaultCamPos();
			Overlay.debugVar += '\nResync count:${resyncCount}'
				+'\nCond/Music/Vocals time:${Std.int(Conductor.songPosition)}/${Std.int(FlxG.sound.music.time)}/${vt}'
				+'\nHealth:${health}'
				+'\nCamFocus: ${Std.int(camFollow.x * 10) * 0.1},${Std.int(camFollow.y * 10) * 0.1}/${Std.int(e[0] * 10) * 0.1},${Std.int(e[1] * 10) * 0.1}   | ${if(!moveCamera) "Locked by script" else if(!FlxG.save.data.camMovement || camLocked) "Locked" else '${focusedCharacter}' } ' //' // extra ' to prevent bad syntaxes interpeting the entire file as a string
				+'\nScript Count:${interpCount}'
				+'\nChartType: ${SONG.chartType}';
		}
		if(controlCamera){
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		}
		if (camBeat){
			if (FlxG.save.data.camMovement || !camLocked){} else FlxG.camera.zoom = defaultCamZoom;
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			// FlxG.camera.zoom = 0.95;
			// camHUD.zoom = 1;
		}

		if (health <= 0 && !hasDied && checkHealth && !ChartingState.charting && onlinemod.OnlinePlayMenuState.socket == null){

			if(practiceMode) {
					hasDied = true;practiceText.text = "Practice Mode; Score won't be saved";practiceText.screenCenter(X);
					// FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
				} else finishSong(false);
		}
 		if (FlxG.save.data.resetButton && onlinemod.OnlinePlayMenuState.socket == null && controls.RESET)
			finishSong(false);
		try{
			addNotes();
		}catch(e){trace('Error adding notes to pool? ${e.message}');}

		if(realtimeCharCam){
			var f = getDefaultCamPos();

			camFollow.x = f[0] + additionCamPos[0];
			camFollow.y = f[1] + additionCamPos[1];
		}

		
		if (FlxG.save.data.cpuStrums){

 			var i = cpuStrums.members.length - 1;
 			var spr:StrumArrow;
 			while (i >= 0){
				spr = cpuStrums.members[i];
				i--;
				if (spr.animation.finished) spr.playStatic();
			}
		}
		
		callInterp("updateAfter",[elapsed]);
		if(!_dadShow && SONG.needsVoices){
			notes.forEachAlive(function(daNote:Note){
				if (daNote.skipNote || daNote.mustPress || !daNote.wasGoodHit) return;
				daNote.active = false;
				vocals.volume = 0;
				daNote.kill();
				notes.remove(daNote, true);
			});
		}
		if(eventNotes.members.length > 0){
			var i = 0;
			var note:Note;
			while (i < eventNotes.members.length){
				note = eventNotes.members[i];
				i++;
				if(note == null || note.strumTime > Conductor.songPosition) continue;
				note.hit(note);
				eventNotes.remove(note);
				note.destroy();
			}
		}

		if (!inCutscene){
			if(timeSinceOnscreenNote > 0) timeSinceOnscreenNote -= elapsed;
			keyShit();
		}
	#if !debug
	}catch(e){
		MainMenuState.handleError(e,'Caught "update" crash: ${e.message}\n ${e.stack}');
	}
	#end
}
	public function pause(){
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		openSubState(new PauseSubState(boyfriend.x, boyfriend.y));
		camFollow.x = defLockedCamPos[0];
		camFollow.y = defLockedCamPos[1];
		// followChar(0);
		camGame.zoom = 1;
	}
	@:keep inline function addNotes(){
		if(unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 3500){
			while(unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes.shift();
				callInterp('noteSpawn',[dunceNote]);
				if(!dunceNote.eventNote && dunceNote.strumTime - Conductor.songPosition < -100){ // Fucking don't load notes that are 100 ms before the current time
					dunceNote.destroy();
				}else if(dunceNote.eventNote){ // eventNote
					eventNotes.add(dunceNote);
				}else{ // we add note lmao
					notes.add(dunceNote);
				}
			}
		}
	}
	override function draw(){
		try{noteShit();}catch(e){handleError('Error during noteShit: ${e.message}\n ${e.stack}}');}
		callInterp("draw",[]);
		try{

			if(!FlxG.save.data.preformance){
				if(downscroll){
					notes.sort(FlxSort.byY,FlxSort.DESCENDING);
				}else{
					notes.sort(FlxSort.byY,FlxSort.ASCENDING);
				}
			}
		}catch(e){}
		super.draw();
		callInterp("drawAfter",[]);
	}
	public function followChar(?char:Int = 0,?locked:Bool = true){
		// if(swappedChars) char = (char == 1 ? 0 : 1);
		focusedCharacter = char;

		camIsLocked = (locked || cameraPositions[char] == null);
		var f = getDefaultCamPos();

		camFollow.x = f[0] + additionCamPos[0];
		camFollow.y = f[1] + additionCamPos[1];


	}
	public function getDefaultCamPos():Array<Float>{
		if(!moveCamera) return [camFollow.x,camFollow.y];
		if(camIsLocked) return lockedCamPos; 
		if(realtimeCharCam){
			var char:Character = switch(focusedCharacter){case 1: dad;case 2:gf;default: boyfriend;};
			if(char.lonely || char.curCharacter == "" || char.curCharacter == "lonely"){
				cameraPositions[focusedCharacter] = lockedCamPos.copy();
				camIsLocked = true;
				return lockedCamPos;
			}else{
				var x:Float = switch(focusedCharacter){case 2: 0;case 1: 150;default:-100;};
				cameraPositions[focusedCharacter] = [char.getMidpoint().x + x + char.camX,char.getMidpoint().y - 100 + char.camY];
			}
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
		cameraPositions = [
			[boyfriend.getMidpoint().x - 100 + boyfriend.camX,boyfriend.getMidpoint().y - 100 + boyfriend.camY],
			[dad.getMidpoint().x + 150 + dad.camX,dad.getMidpoint().y - 100 + dad.camY],
			[gf.getMidpoint().x + gf.camX,gf.getMidpoint().y - 100 + gf.camY]
		];
		if(boyfriend.lonely || boyfriend.curCharacter == "" || boyfriend.curCharacter == "lonely"){
			cameraPositions[0] = defLockedCamPos.copy();
		}
		if(dad.lonely || dad.curCharacter == "" || dad.curCharacter == "lonely"){
			cameraPositions[1] = defLockedCamPos.copy();

		}
		if(gf.lonely || gf.curCharacter == "" || gf.curCharacter == "lonely"){
			cameraPositions[2] = defLockedCamPos.copy();
		}
		lockedCamPos = defLockedCamPos.copy();
	}

	var shouldEndSong:Bool = true;
	function endSong():Void
	{
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

		charCall("endSong",[]);
		callInterp("endSong",[]);
		if(!shouldEndSong){shouldEndSong = true;return;}

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (offsetTesting){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}else{
			if (isStoryMode){
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
				if (storyPlaylist.length <= 0){
					// FlxG.sound.playMusic(Paths.music('freakyMenu'));
					trace("Song finis");

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					Highscore.saveWeekScore(storyWeek, songScore, storyDifficulty);
					FlxG.save.flush();
					finishSong(true);
				}else if(!StoryMenuState.isVanillaWeek){
					trace('Swapping songs');
					resetInterps();
					FlxG.sound.music.stop();
					prevCamFollow = camFollow;
					StoryMenuState.curSong++;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					StoryMenuState.swapSongs();

					// LoadingState.loadAndSwitchState(new PlayState());

				}else{
					var difficulty:String = (if(storyDifficulty == 0)"-easy" else if(storyDifficulty == 2)'-hard' else '');

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.parseJSONshit(SELoader.loadText('assets/data/${PlayState.storyPlaylist[0]}/${PlayState.storyPlaylist[0]}$difficulty.json'));
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}else{
				finishSong(!hasDied);
			}
		}
	}
	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;
	var lastNoteSplash:NoteSplash;
	private function popUpScore(daNote:Note){
			var daRating = daNote.rating;
			if(daRating == "miss") return noteMiss(daNote.noteData,null,null,true);
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			vocals.volume = FlxG.save.data.voicesVol;
			
			var placement:String = Std.string(combo);
			var camHUD = camHUD;
			if(useNoteCameras) camHUD = playerNoteCamera;
			
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1) totalNotesHit += EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			else if (FlxG.save.data.accuracyMod == 2) totalNotesHit += daNote.hitDistance;

			switch(daRating.toLowerCase())
			{

				case 'shit':
					score = -300;
					// combo = 0;
					// misses++; A shit should not equal a miss
					ss = false;
					shits++;
					if(handleHealth) health -= 0.2;
					if(FlxG.save.data.shittyMiss){noteMiss(daNote.noteData,null,null,true);}
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.25;
				case 'bad':
					score = 0;
					ss = false;
					bads++;
					if(handleHealth) health -= 0.06;
					if(FlxG.save.data.badMiss) noteMiss(daNote.noteData,null,null,true);
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.50;
				case 'good':
					score = 200;
					ss = false;
					goods++;
					if (handleHealth && health < 2) health += 0.04;
					if(FlxG.save.data.goodMiss) noteMiss(daNote.noteData,null,null,true);
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.75;
				case 'sick':
					sicks++;
					if (FlxG.save.data.noteSplash){
						var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
						a.setupNoteSplash(daNote, daNote.noteData);
						lastNoteSplash = a;
						grpNoteSplashes.add(a);
						callInterp('spawnNoteSplash',[a]);
					}
					if (handleHealth && health < 2) health += 0.1;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 1;
			}
			if(flippy && daRating != "sick"){
				practiceMode = false;
				health = 0;
			}
			var rating:FlxSprite = new FlxSprite();
	
			
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			if(!FlxG.save.data.noterating && !FlxG.save.data.showTimings && !FlxG.save.data.showCombo) return;
	
			if(FlxG.save.data.noterating){

				rating.loadGraphic(Paths.image(daRating)); // TODO: Add mod folder support and precaching
				rating.x = playerStrums.members[0].x - (playerStrums.members[0].width);
				rating.y = playerStrums.members[0].y + (playerStrums.members[0].height * 0.5);
				rating.acceleration.y = 550;
				rating.velocity.y = (FlxG.random.int(140, 175) * -(daNote.hitDistance - 0.5) * 2);
				rating.velocity.x = -FlxG.random.int(-10, 10);
				rating.angularVelocity = rating.velocity.x * 1.5;

				rating.setGraphicSize(Std.int(rating.width * 0.3));
				rating.antialiasing = true;
				rating.updateHitbox();
			}
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3); 


			var currentTimingShown = new FlxText(0,0,0,"0ms");
			if(FlxG.save.data.showTimings){
				timeShown = 0;
				switch(daRating){
					case 'shit':
						currentTimingShown.color = FlxColor.RED;
					case 'bad':
						currentTimingShown.color = FlxColor.ORANGE;
					case 'good':
						currentTimingShown.color = FlxColor.GREEN;
					case 'sick':
						currentTimingShown.color = FlxColor.CYAN;
				}
				currentTimingShown.borderStyle = OUTLINE;
				currentTimingShown.borderSize = 1;
				currentTimingShown.borderColor = FlxColor.BLACK;
				var _dist = (Conductor.songPosition - daNote.strumTime);
				// This if statement is shit but it should work
				currentTimingShown.text = msTiming + "ms " + (if(_dist == 0) "=" else if(downscroll && _dist < 0 || !downscroll && _dist > 0) "^" else "v");
				currentTimingShown.size = 20;
				currentTimingShown.screenCenter();
				currentTimingShown.updateHitbox();
				currentTimingShown.x = (playerStrums.members[daNote.noteData].x + (playerStrums.members[daNote.noteData].width * 0.5)) - (currentTimingShown.width * 0.5);
				currentTimingShown.y = daNote.y + (daNote.height * 0.5);
				currentTimingShown.cameras = [camHUD]; 


				add(currentTimingShown);
			}
			if(FlxG.save.data.noterating){
				rating.cameras = [camHUD];
				add(rating);
			}
	

			
			var scoreObjs = [];
			if(FlxG.save.data.showCombo){

				var seperatedScore:Array<Int> = [];
		
				var comboSplit:Array<String> = (combo + "").split('');



				var comboSize = 1.20 - (seperatedScore.length * 0.1);
				for (i in 0...comboSplit.length)
				{
					var num:Int = Std.parseInt(comboSplit[i]);
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + num));
					// numScore.screenCenter();
					numScore.x = playerStrums.members[playerStrums.members.length - 1].x + (playerStrums.members[playerStrums.members.length - 1].width) + ((43 * comboSize) * i);

					numScore.y = rating.y;
					numScore.cameras = rating.cameras;

					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * comboSize) * 0.5));

					numScore.updateHitbox();
		
					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);
					numScore.angularVelocity = numScore.velocity.x;
					add(numScore);
					scoreObjs.push(numScore);
					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							numScore.destroy();
						},
						startDelay: Conductor.crochet * 0.002
					});
		
				}
			}

			if(FlxG.save.data.noterating){
				FlxTween.tween(rating, {alpha: 0}, 0.3, {
					startDelay: Conductor.crochet * 0.001,
					onComplete: function(tween:FlxTween)
					{
						rating.destroy();
					}
				});
			}
			if(FlxG.save.data.showTimings){
				FlxTween.tween(currentTimingShown, {alpha: 0,y:currentTimingShown.y - 60}, 0.8, {
					onComplete: function(tween:FlxTween)
					{
						currentTimingShown.destroy();
					},
					startDelay: Conductor.crochet * 0.001,
				});
			}
			callInterp('popUpScore',[rating,scoreObjs,currentTimingShown]);



		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;

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
		inputMode = FlxG.save.data.inputEngine;
		var inputEngines = ["SE" + (if (FlxG.save.data.accurateNoteSustain) "-ACNS" else "") 
		#if(!mobile), 'SE-EV'+ (if (FlxG.save.data.accurateNoteSustain) "-ACNS" else "")#end
		];
		// if (onlinemod.OnlinePlayMenuState.socket != null && inputMode != 0) {inputMode = 0;trace("Loading with non-kade in online. Forcing kade!");} // This is to prevent input differences between clients
		trace('Using ${inputMode}');
		// noteShit handles moving notes around and opponent hitting them
		// keyShit handles player input and hitting notes
		// These can both be replaced by scripts :>

		switch(inputMode){
			case 0:
				noteShit = SENoteShit;

				doKeyShit = kadeBRKeyShit;
				goodNoteHit = kadeBRGoodNote;
			#if(!mobile)
			case 1:
				noteShit = SENoteShit;
				doKeyShit = SEKeyShit;
				goodNoteHit = kadeBRGoodNote;
				SEIUpdateKeys();
				FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
				FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);

			#end
			default:
				MainMenuState.handleError('${inputMode} is not a valid input! Please change your input mode!');

		}
		inputEngineName = if(inputEngines[inputMode] != null) inputEngines[inputMode] else "Unspecified";


	}
	dynamic function noteShit(){MainMenuState.handleError("I can't handle input for some reason, Please report this!");}
	public function DadStrumPlayAnim(id:Int,?anim:String = "confirm") {
		var spr:StrumArrow= cpuStrums.members[id];
		if(spr != null) {
			switch(anim.toLowerCase()){
				case "confirm":
					spr.confirm(true);
				case "static":
					spr.playStatic(true);
				case "press":
					spr.press(true);
			}
		}
	}
	public function BFStrumPlayAnim(id:Int,anim:String = 'confirm') {
		var spr:StrumArrow= playerStrums.members[id];
		if(spr != null) {
			switch(anim.toLowerCase()){
				case "confirm":
					spr.confirm(true);
				case "static":
					spr.playStatic(true);
				case "press":
					spr.press(true);
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



	inline function onlineNoteHit(noteID:Int = -1,miss:Int = 0){
		if(p2canplay){
			onlinemod.Sender.SendPacket(onlinemod.Packets.KEYPRESS, [noteID,miss], onlinemod.OnlinePlayMenuState.socket);
		}
	}



// Super Engine input and handling

	function SENoteShit(){
		if (!generatedMusic) return;
		var _scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2); // Probably better to calculate this beforehand
		var strumNote:FlxSprite;
		var i = notes.members.length - 1;
		var daNote:Note;
		while (i > -1){
			daNote = notes.members[i];
			i--;
			if(daNote == null || !daNote.alive) continue;
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
			strumNote = (if (daNote.parentSprite != null) daNote.parentSprite else if (daNote.mustPress) playerStrums.members[Math.floor(Math.abs(daNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))] );
			daNote.distanceToSprite = 0.45 * (Conductor.songPosition - daNote.strumTime) * _scrollSpeed;
			if(daNote.updateY){
				switch (downscroll){

					case true:{
						daNote.y = strumNote.y + daNote.distanceToSprite;
						if(daNote.isSustainNote)
						{
							// daNote.isSustainNoteEnd && 
							// if(daNote.isSustainNoteEnd && daNote.prevNote != null)
							// 	daNote.y = daNote.prevNote.y - (daNote.frameHeight * daNote.scale.y);
							// else
							daNote.y += daNote.height * 0.5;

							// Only clip sustain notes when properly hit
							if(daNote.clipSustain && (daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || _dadShow && daNote.aiShouldPress) && FlxG.overlap(daNote,strumNote))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (strumNote.y + (Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;


								daNote.clipRect = swagRect;
								daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
								callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
							}
						}
				
					}
					case false:{
						daNote.y = strumNote.y - daNote.distanceToSprite;
						if(daNote.isSustainNote)
						{
							if(daNote.isSustainNoteEnd && daNote.parentNote != null){
								daNote.y = daNote.prevNote.y + (daNote.frameHeight * daNote.scale.y);
							}else
								daNote.y -= daNote.height * 0.5;
							// (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) &&
							if(daNote.clipSustain && (daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || _dadShow && daNote.aiShouldPress) && FlxG.overlap(daNote,strumNote))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumNote.y + (Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								if(daNote.mustPress && swagRect.height < 0 ) {goodNoteHit(daNote);continue;}

								daNote.clipRect = swagRect;
								daNote.susHit(if(daNote.mustPress) 0 else 1,daNote);
								callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
							}
						}
					}
				}
			}
			if (daNote.skipNote) continue;

			if ((daNote.mustPress || !daNote.wasGoodHit) && daNote.lockToStrum){
				daNote.visible = strumNote.visible;
				if(daNote.updateX) daNote.x = strumNote.x + (strumNote.width * 0.5);
				if(!daNote.isSustainNote && daNote.updateAngle) daNote.angle = strumNote.angle;
				if(daNote.updateAlpha) daNote.alpha = strumNote.alpha;
				if(daNote.updateScrollFactor) daNote.scrollFactor.set(strumNote.scrollFactor.x,strumNote.scrollFactor.y);
				if(daNote.updateCam) daNote.cameras = [strumNote.cameras[0]];
			}
			if(daNote.mustPress && daNote.tooLate){
				if (!daNote.shouldntBeHit)
				{
					if(handleHealth) health += SONG.noteMetadata.tooLateHealth;
					vocals.volume = 0;
					noteMiss(daNote.noteData, daNote);
				}

				daNote.visible = false;
				daNote.kill();
				notes.remove(daNote, true);
			}


			
		}
	}
	private function SEKeyShit():Void{ // Only used for holds, not pressing
		if (!generatedMusic) return;
		boyfriend.isPressingNote = false;
		callInterp("holdShit",[holdArray]);
		charCall("holdShit",[holdArray]);


		if (generatedMusic && acceptInput && !boyfriend.isStunned && holdArray.contains(true)) {

 			var daNote:Note;
 			var i:Int = 0;
			
 			boyfriend.holdTimer = 0;
			boyfriend.isPressingNote = true;
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
				if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
					{goodNoteHit(daNote);continue;}
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
		}
 
		// Debugging
		
		// pressArray = [
		// 	controls.LEFT_P,
		// 	controls.DOWN_P,
		// 	controls.UP_P,
		// 	controls.RIGHT_P
		// ];
		// if (generatedMusic && pressArray.contains(true))
		// {
		// 	boyfriend.holdTimer = 0;
 
		// 	var possibleNotes:Array<Note> = [null,null,null,null]; // notes that can be hit
 		// 	var onScreenNote:Bool = false;
 		// 	var i = notes.members.length;
 		// 	var daNote:Note;
 		// 	while (i >= 0) {
		// 		daNote = notes.members[i];
		// 		i--;
		// 		if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;

		// 		if (!pressArray[daNote.noteData] || !daNote.canBeHit || daNote.tooLate || daNote.wasGoodHit) continue;
		// 		var coolNote = possibleNotes[daNote.noteData];
		// 		if (coolNote != null)
		// 		{
		// 			if((Math.abs(daNote.strumTime - coolNote.strumTime) < 7)){notes.remove(daNote);daNote.destroy();continue;}
		// 			if((daNote.strumTime > coolNote.strumTime)) continue;
		// 		}
		// 		possibleNotes[daNote.noteData] = daNote;
		// 	}
 		// 	i = pressArray.length;
 		// 	daNote = null;
		// 	while(i > 0) {
		// 		i--;
		// 		daNote = possibleNotes[i];
		// 		if(daNote == null && pressArray[i] && timeSinceOnscreenNote > 0){ continue;}
		// 		if(daNote == null) continue;
		// 		daNote.color = FlxColor.GREEN;
		// 	}
		// }
 		callInterp("holdShitAfter",[holdArray]);
 		charCall("holdShitAfter",[holdArray]);
		if (boyfriend.currentAnimationPriority == 10 && (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 || boyfriend.isDonePlayingAnim()) && !boyfriend.isPressingNote) {
			boyfriend.dance(true,curBeat % 2 == 1);
		}

	}
	var SEIKeyMap:Map<Int,Int> = [];
	var SEIHeld:Array<Bool> = [false,false,false,false];
	var SEIBlockInput:Bool = false;
	function SEIUpdateKeys(){
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.leftBind]] =		0;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltleftBind]] =	0;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.downBind]] =		1;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltdownBind]] =	1;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.upBind]] =		2;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltupBind]] =		2;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.rightBind]] =		3;
		SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltrightBind]] =	3;
	}
	function SEIKeyPress(event:KeyboardEvent){
		if(this != FlxG.state){
			Main.instance.removeEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
			Main.instance.removeEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);
			return;
		}
		pressArray = [false,false,false,false];
		holdArray = [false,false,false,false];
		releaseArray = [false,false,false,false];
		// var keyCode:FlxKey = event.keyCode;
		// var data:Null<Int> = SEIKeyMap[keyCode];
		// if(data == null) data = -1;
		SEIBlockInput = false;
		callInterp('keyPress',[event.keyCode]);
		// || SEIHeld[data]
		if (SEIBlockInput || !acceptInput || boyfriend.isStunned || !generatedMusic || subState != null || paused ) return;
		
		for(key => data in SEIKeyMap){
			if(FlxG.keys.checkStatus(key, JUST_PRESSED)){
				pressArray[data] = true;
				holdArray[data] = true;
				var strum = playerStrums.members[data];
				if(strum != null) strum.press();
			}else if(FlxG.keys.checkStatus(key, PRESSED)){
				holdArray[data] = true;
			}
		}
		callInterp('keyShit',[pressArray,holdArray]);
		charCall("keyShit",[pressArray,holdArray]);
		if(!pressArray.contains(true) || SEIBlockInput || !acceptInput) return;

		boyfriend.holdTimer = 0;
		var hitArray = [false,false,false,false];
		if(holdArray.contains(true)){
			
			boyfriend.isPressingNote = true;
			var daNote = null;
			var i = notes.members.length;
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
				if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
					{goodNoteHit(daNote);continue;}
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				hitArray[daNote.noteData] = true;
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
		}
		var possibleNotes:Array<Note> = [null,null,null,null]; // notes that can be hit
		var onScreenNote:Bool = false;
		var i = notes.members.length;
		var daNote:Note;
		while (i >= 0) {
			daNote = notes.members[i];
			i--;
			if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;
			
			if (!onScreenNote) onScreenNote = true;
			if (!pressArray[daNote.noteData] || !daNote.canBeHit || daNote.tooLate || daNote.wasGoodHit) continue;
			var coolNote = possibleNotes[daNote.noteData];
			if (coolNote != null){
				if((Math.abs(daNote.strumTime - coolNote.strumTime) < 7)){notes.remove(daNote);daNote.destroy();continue;}
				if((daNote.strumTime > coolNote.strumTime)) continue;
			}
			possibleNotes[daNote.noteData] = daNote;

		}

		if(onScreenNote) timeSinceOnscreenNote = 0.5;
		i = pressArray.length;
		daNote = null;
		var ghostTapping = FlxG.save.data.ghost;
		while(i > 0) {
			i--;
			daNote = possibleNotes[i];
			if(daNote == null && pressArray[i] && timeSinceOnscreenNote > 0){
				ghostTaps += 1;
				if(ghostTapping){
					noteMiss(i, null);
				}
				continue;
			}
			if(daNote == null) continue;
			hitArray[daNote.noteData] = true;
			goodNoteHit(daNote);
		}
		callInterp('keyShitAfter',[pressArray,holdArray,hitArray]);
		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);

	}
	function SEIKeyRelease(event:KeyboardEvent){
		if(this != FlxG.state){
			Main.instance.removeEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
			Main.instance.removeEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);
			return;
		}
		callInterp('keyRelease',[event.keyCode]);
		holdArray = [false,false,false,false];

		for(key => data in SEIKeyMap){
			if(FlxG.keys.checkStatus(key, PRESSED)){
				holdArray[data] = true;
			}
		}
		for(id => bool in holdArray){
			if(!bool){
				var strum = playerStrums.members[id];
				if(strum == null) return;
				strum.playStatic();
			}
		}

	}

	private function kadeBRKeyShit():Void{
		if (!generatedMusic) return;

		if(botPlay){
			holdArray = [false,false,false,false];
			pressArray = [false,false,false,false];
			releaseArray = [false,false,false,false];
			var i = 0;
			var daNote:Note = null;
			callInterp('botKeyShit',[]);
			if(cancelCurrentFunction) return;
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !daNote.mustPress || !daNote.canBeHit) continue;
				if(daNote.strumTime <= Conductor.songPosition){pressArray[daNote.noteData] = true;goodNoteHit(daNote);continue;}
				if(!daNote.isSustainNote) continue;
				// hitArray[daNote.noteData] = true;
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				holdArray[daNote.noteData] = true;
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
 
			var i = playerStrums.members.length - 1;
			var spr:StrumArrow;
			while (i >= 0){
				spr = playerStrums.members[i];
				i--;
				if(spr == null) continue;
				if(!holdArray[spr.ID] && spr.animation.finished) spr.playStatic();
			}
			return;
		}


		// control arrays, order L D R U
		lastPressArray = [for (i in pressArray) i];
		holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		pressArray = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P
		];
		releaseArray = [
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R
		];
		var hitArray:Array<Bool> = [false,false,false,false];
		#if android
			if(FlxG.save.data.useTouch){
				if(FlxG.save.data.useStrumsAsButtons){
					for(touch in FlxG.touches.list){
						for(i in 0...playerStrums.members.length){
							if(touch.overlaps(playerStrums.members[i])){
							// var obj = playerStrums.members[i];
							// if(	touch.screenX > obj.x && touch.screenX < obj.x + obj.width &&
							// 	touch.screenX > obj.y && touch.screenX < obj.y + obj.height){
								pressArray[i] = touch.justPressed;
								holdArray[i] = touch.pressed;

							}
						}
					}

				}else{

					for(spr in noteButtons){
						spr.alpha = 0.1;
					}
					for(touch in FlxG.touches.list){
						if(touch.screenX < FlxG.width && touch.screenY > 30){
							var pos = Std.int((touch.screenX / FlxG.width) * 4);
							pressArray[pos] = touch.justPressed;
							holdArray[pos] = touch.pressed;
							if(noteButtons[pos] != null){
								noteButtons[pos].alpha = (if(touch.justPressed) 0.25 else 0.2);
							}
						}
					}
				}
			}
		#end
		callInterp("keyShit",[pressArray,holdArray]);
		charCall("keyShit",[pressArray,holdArray]);

		if (!acceptInput || boyfriend.isStunned) {lastPressArray = holdArray = pressArray = releaseArray = [false,false,false,false];}

		if(FlxG.save.data.debounce && lastPressArray.contains(true)){
			pressArray = [for (i => v in lastPressArray) if(v) false else pressArray[i] ];
		}
		// HOLDS, check for sustain notes
		if (generatedMusic && (holdArray.contains(true) || releaseArray.contains(true))) {

 			var daNote:Note;
 			var i:Int = 0;
			
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
				if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
					{goodNoteHit(daNote);continue;}
				hitArray[daNote.noteData] = true;
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
		}
 
		// PRESSES, check for note hits
		
		if (generatedMusic && pressArray.contains(true))
		{
			boyfriend.holdTimer = 0;
 
			var possibleNotes:Array<Note> = [null,null,null,null]; // notes that can be hit
 			var onScreenNote:Bool = false;
 			var i = notes.members.length;
 			var daNote:Note;
 			while (i >= 0) {
				daNote = notes.members[i];
				i--;
				if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;

				if (!onScreenNote) onScreenNote = true;
				if (!pressArray[daNote.noteData] || !daNote.canBeHit || daNote.tooLate || daNote.wasGoodHit) continue;
				var coolNote = possibleNotes[daNote.noteData];
				if (coolNote != null)
				{
					if((Math.abs(daNote.strumTime - coolNote.strumTime) < 7)){notes.remove(daNote);daNote.destroy();continue;}
					if((daNote.strumTime > coolNote.strumTime)) continue;
				}
				possibleNotes[daNote.noteData] = daNote;
			}
			if(onScreenNote) timeSinceOnscreenNote = 0.5;
 			i = pressArray.length;
 			daNote = null;
			while(i > 0) {
				i--;
				daNote = possibleNotes[i];
				if(daNote == null && pressArray[i] && timeSinceOnscreenNote > 0){
					ghostTaps += 1;
					if(!FlxG.save.data.ghost){
						noteMiss(i, null);
					}
					continue;
				}
				if(daNote == null) continue;
				hitArray[daNote.noteData] = true;
				goodNoteHit(daNote);
			}
		}
 		callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
 		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
		boyfriend.isPressingNote = holdArray.contains(true);
		if (boyfriend.currentAnimationPriority == 10 && (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 || boyfriend.isDonePlayingAnim()) && !boyfriend.isPressingNote) {
			boyfriend.dance(true,curBeat % 2 == 1);
		}

 
		var i = playerStrums.members.length - 1;
		var spr:StrumArrow;
		while (i >= 0){
			spr = playerStrums.members[i];
			i--;
			if(spr == null) continue;
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm') spr.press(); 
			else if (!holdArray[spr.ID]) spr.playStatic();
		}

	}

	function kadeBRGoodNote(note:Note, ?resetMashViolation = true):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		note.hitDistance = Ratings.getDistanceFloat(noteDiff);
		note.rating = Ratings.ratingFromDistance(note.hitDistance);

		if(note.shouldntBeHit){
			noteMiss(note.noteData,note,true);
			return;
		}

		callInterp("beforeNoteHit",[boyfriend,note]);


		if (FlxG.save.data.npsDisplay && !note.isSustainNote) notesHitArray.unshift(Date.now().getTime());

		if(logGameplay) eventLog.push({
				rating:note.rating,
				direction:note.noteData,
				strumTime:note.strumTime,
				isSustain:note.isSustainNote,
				time:Conductor.songPosition
			});

		if (!note.isSustainNote){
			popUpScore(note);
			combo += 1;
		}else totalNotesHit += 1;
		

		if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * (0.25 * note.noteData + 1));
		note.wasGoodHit = true;
		note.hit(0,note);
		callInterp("noteHit",[boyfriend,note]);
		onlineNoteHit(note.noteID,0);
		
		if (boyfriend.useVoices){
			boyfriend.voiceSounds[note.noteData].play(1);
			boyfriend.voiceSounds[note.noteData].time = 0;
			vocals.volume = 0;
		}else vocals.volume = FlxG.save.data.voicesVol;
		notes.remove(note, true);
		note.kill();
		note.destroy();
		updateAccuracy();
	}
		










	public function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false,?calcStats:Bool = true):Void
	{
		noteMissdyn(direction,daNote,forced,calcStats);
	}
	public function playMissSound(char,direction){
		if(FlxG.save.data.playMisses) 
			if (char.useMisses){
				FlxG.sound.play(char.missSounds[direction], FlxG.save.data.missVol);
			}else{
				FlxG.sound.play(vanillaHurtSounds[Math.round(Math.random() * 2)], FlxG.save.data.missVol);
			}
	}
	dynamic function noteMissdyn(direction:Int = 1, daNote:Note,?forced:Bool = false,?calcStats:Bool = true):Void
	{
		if(daNote != null && daNote.shouldntBeHit && !forced) return;
		
		if(daNote != null && forced && daNote.shouldntBeHit){ // Only true on hurt arrows
			FlxG.sound.play(hurtSoundEff, FlxG.save.data.missVol);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();

		}
		playMissSound(boyfriend,direction);
		// FlxG.sound.play(hurtSoundEff, 1);
		if(calcStats && handleHealth) health += SONG.noteMetadata.missHealth;
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		if(calcStats){
			combo = 0;
			misses += 1;
		}
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


		if (FlxG.save.data.accuracyMod == 1 && calcStats)
			totalNotesHit -= 1;

		if(calcStats) songScore -= 10;
		if (daNote != null && daNote.shouldntBeHit) {songScore += SONG.noteMetadata.badnoteScore; if(handleHealth) health += SONG.noteMetadata.badnoteHealth;} // Having it insta kill, not a good idea 
		if(daNote == null){
			callInterp("miss",[boyfriend,direction,calcStats]);
			boyfriend.callInterp('miss',[direction,calcStats]);
		}else {
			callInterp("noteMiss",[boyfriend,daNote,direction,calcStats]);
			boyfriend.callInterp('noteMiss',[daNote,direction,calcStats]);
		}
		onlineNoteHit(if(daNote == null) -1 else daNote.noteID,direction + 1);



		updateAccuracy();
	}



	function updateAccuracy(){
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}

	
	var mashing:Int = 0;
	var mashViolations:Int = 0;



	dynamic function goodNoteHit(note:Note, ?resetMashViolation = true):Void {MainMenuState.handleError('I cant register any note hits!');}


	override function stepHit(){
		if(lastStep == curStep) return;
		super.stepHit();
		// lastStep = curStep;
		if (handleTimes && (FlxG.sound.music.time > Conductor.songPosition + 5 || FlxG.sound.music.time < Conductor.songPosition - 5) && generatedMusic)
			resyncVocals();
		

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
						play = (ifState.type == "equals" && ret == 0) || (ifState.type == "more" && ret == 1) || (ifState.type == "less" && ret == 0);

					}
					if (play){
						trace("Custom animation, Playing anim");
						
						if(ifState.isFunc){
							ifState.func(this);
						}else{

							switch(i){
								case 0: boyfriend.playAnim(anim);
								case 1: dad.playAnim(anim);
								case 2: gf.playAnim(anim);
							}
						}
					}
				}
			}
			
		}catch(e){handleError('A animation event caused an error: ${e.message}\n ${e.stack}');}

		callInterp("stepHitAfter",[]);
		charCall("stepHitAfter",[curStep]);
	}
	

	override function beatHit()
	{
		super.beatHit();
		callInterp("beatHit",[]);
		charCall("beatHit",[curBeat]);

		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 3) {
			scoreTxt.screenCenter(X);
		}


		if (generatedMusic && SONG.notes[Math.floor(curStep / 16)] != null)
		{
			curSection = Std.int(curStep / 16);
			var sect = SONG.notes[curSection];
			if (sect.changeBPM && !Math.isNaN(sect.bpm))
			{
				Conductor.changeBPM(sect.bpm);
			}
			if (sect.scrollSpeed != null && !Math.isNaN(sect.scrollSpeed))
			{
				SONG.speed = sect.scrollSpeed;
			}

			PlayState.canUseAlts = sect.altAnim;
			if(controlCamera){
				var locked = (!FlxG.save.data.camMovement || camLocked || (notes.members[0] == null && unspawnNotes[0] == null || (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition > 4000)) );
				followChar((sect.mustHitSection ? 0 : 1),locked);
			}
		}

		// Zoooooooom
		if (FlxG.save.data.camMovement && camBeat && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0){
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		
		iconP1.bounce(Conductor.crochetSecs);
		iconP2.bounce(Conductor.crochetSecs);
		// iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		// iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		// iconP1.updateHitbox();
		// iconP2.updateHitbox();

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
						if(ifState.isFunc){
							ifState.func(this);
						}else{

							switch(i){
								case 0: boyfriend.playAnim(anim);
								case 1: dad.playAnim(anim);
								case 2: gf.playAnim(anim);
							}
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
			if(v != null && v.currentAnimationPriority != 10){
				v.dance(true,curBeat % 2 == 0,true);
			}
		}
		// 	if(v.currentAnimationPriority != 10){

		// 		if (v.dance_idle && (v.animation.curAnim.name.startsWith("dance") || v.animation.curAnim.finished)){
		// 			if (curBeat % 2 == 1){v.playAnim('danceLeft');}
		// 			if (curBeat % 2 == 0){v.playAnim('danceRight');}
		// 		}else if (!v.dance_idle)
		// 		{
		// 		 v.playAnim('idle');
		// 		}
		// 	}
		// }
		callInterp("beatHitAfter",[]);
		charCall("beatHitAfter",[curBeat]);



	}



	public var acceptInput = true;

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
			if (FlxG.keys.justPressed.FIVE)
			{
				downscroll = !downscroll;
				for (i in playerStrums.members){
					FlxTween.tween(i,{y:(if(downscroll)FlxG.height - 165 else 50)},0.3);
				}
				for (i in cpuStrums.members){
					FlxTween.tween(i,{y:(if(downscroll)FlxG.height - 165 else 50)},0.3);
				}
			}
			if (FlxG.keys.justPressed.SEVEN )
			{
				// FlxG.switchState(new ChartingState());
				ChartingState.gotoCharter();
			}
			if (FlxG.keys.pressed.SHIFT && (FlxG.keys.justPressed.LBRACKET || FlxG.keys.justPressed.RBRACKET) )
			{
				FlxG.save.data.scrollSpeed += (if(FlxG.keys.justPressed.LBRACKET) -0.05 else 0.05);
				showTempmessage('Changed scrollspeed to ${FlxG.save.data.scrollSpeed}');
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
	override function destroy(){
		callInterp("destroy",[]);
		try{
			hsBrTools.reset();
			instance = null;
		}catch(e){}
		super.destroy();
	}

}