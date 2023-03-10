package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxTimer;

import tjson.Json;
import sys.FileSystem;
import sys.io.File;
import OptionsFileDef;
import Reflect;
using StringTools;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;
	public static var lastState:Int = 0;

	var selector:FlxText;
	var curSelected:Int = 0;
	var selCat:Int = 0;
	var transitioning:Bool = false;

	public static var modOptions:Map<String,Map<String,Dynamic>> = new Map<String,Map<String,Dynamic>>();
	public static var ScriptOptions:Map<String,OptionsFileDef> = new Map<String,OptionsFileDef>();

	var options:Array<OptionCategory> = [
		new OptionCategory("Session/Temp Options", [
			for (name => setting in QuickOptionsSubState.normalSettings)
			{
				new QuickOption(name);
			}
		],"Chart options. THESE ARE TEMPORARY AND RESET WHEN GAME IS CLOSED"),
		new OptionCategory("Modifications", [
			new OpponentOption("Change the opponent character"),
			new PlayerOption("Change the player character"),
			new GFOption("Change the GF used"),
			new NoteSelOption("Change the note assets used, pulled from mods/noteassets"),
			new SelStageOption("Select the stage to use, Default will use song default"),
			new SelScriptOption("Enable/Disable scripts that run withsongs"),
			new CharAutoOption("Force the opponent you've selected or allow the song to choose the opponent if you have them installed"),
			new CharAutoBFOption("Force the player you've selected or allow the song to choose the player if you have them installed"),
			new HCBoolOption("Toggle the ability for packs to provide scripts","Pack scripts","packScripts"),
			new HCBoolOption("Toggle the ability for scripts to run in menus","Menu Scripts","menuScripts"),
			// new HCBoolOption("Show your player character on the main menu, MAY CAUSE CRASHES!","Show player on main menu","mainMenuChar"),
			
			new AnimDebugOption("Enables the Character/chart editor, F10 console, displays some extra info in the FPS Counter, and some other debug stuff"),
			new ReloadCharlist("Refreshes list of stages, characters and scripts"),
		],"Settings relating to Characters, scripts, etc"),
		new OptionCategory("Online", [
			// new HCBoolOption("Saves charts to disk whenever you recieve one","Save charts from servers","onlineSaveChart"),
			new AllowServerScriptsOption("Allow servers to run scripts. THIS IS DANGEROUS, ONLY ENABLE IF YOU TRUST THE SERVERS"),
		],"Settings relating to Characters, scripts, etc"),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			#if android

			new HCBoolOption("Toggle the built-in taps for hitting notes","Native tapping support","useTouch"),
			new HCBoolOption("Whether to split the screen into 4 buttons or use strums as buttons(Requires native Touch)","Strum Buttons","useStrumsAsButtons"),
			#end
			new DownscrollOption("Change the layout of the strumline."),
			new MiddlescrollOption("Move the strumline to the middle of the screen"),

			new AccuracyDOption("Change how accuracy is calculated. ( Simple = Rating based, SE = Distance from note to time, Complex = Etterna(?) )"),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new InputHandlerOption("Change the input engine used, only works locally. Kade is considered legacy and will not be improved")
		],"Edit things like Keybinds, scroll direction, etc"),
		new OptionCategory("Judgements", [
			new AccuracyDOption("Change how accuracy is calculated. ( Simple = Rating based, SE = Distance from note to time, Complex = Etterna(?) )"),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new SEJudgement("Sick"),
			new SEJudgement("Good"),
			new SEJudgement("Bad"),
			new SEJudgement("Shit")
		],"Edit things like Keybinds, scroll direction, etc"),
		new OptionCategory("Modifiers", [
		    new PracticeModeOption("Disables the ability to get a gameover. Also disables saving scores."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new HCBoolOption("Show skip beginning prompt","Jump to first note prompt","skipToFirst"),
			new HCBoolOption("Enables some simple debounce detection. Forces presses to be missed from one frame to another. ","Debounce detection","debounce"),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new ScrollSpeedOSUOption("Change your scroll speed on OSU charts"),

			new AccurateNoteHoldOption("Whether note sustains/holds are more accurate. If off then they act like early kade"),
			new HCBoolOption("Whether you'll get a miss from getting a shit","Shitty Misses","shittyMiss"),
			new HCBoolOption("Whether you'll get a miss from getting a bad","Bad Misses","badMiss"),
			new HCBoolOption("Whether you'll get a miss from getting a good","Good Misses","goodMiss"),
		],"Toggle Practice mode, Ghost Tapping, etc"),

		new OptionCategory("Appearance", [
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamMovementOption("Toggle the camera moving"),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new AccuracyOption("Display accuracy information."),
			new SongPositionOption("Show the songs current position, name and length"),
			new CpuStrums("CPU's strumline lights up when a note hits it."),
			new SongInfoOption("Change how your performance is displayed"),
			new GUIGapOption("Change the distance between the end of the screen and text(Not used everywhere)"),
		],"Toggle flashing lights, camera movement, song info, etc "),
		new OptionCategory("Misc", [
			#if !mobile
			new CheckForUpdatesOption("Toggle check for updates when booting the game, useful if you're in the Discord with pings on"),
			#end
			#if discord_rpc
			new HCBoolOption("Toggle Discord Rich Presence(Requires restart)","Discord Rich Presence","discordDRP"),
			#end
			new FullscreenOption("Toggle fullscreen mode. Press F11 to toggle fullscreen ingame"),
			new ResetButtonOption("Toggle pressing R to gameover."),			// new HCBoolOption("Allows you to use the legacy chart editor","Lecacy chart editor","legacyCharter"),
			new LogGameplayOption("Logs your game to a text file"),
			new EraseOption("Backs up your options to SEOPTIONS-BACKUP.json and then resets them"),
			// new ImportOption("Import your options from SEOPTIONS.json"),
			// new ExportOption("Export your options to SEOPTIONS.json to backup or to share with a bug report"),
		],"Misc things"),
		new OptionCategory("Performance", [
			new FPSCapOption("Cap your FPS"),
			new UseBadArrowsOption("Use custom arrow texture instead of coloring normal notes black"),
			new ShitQualityOption("Disables elements not essential to gameplay like the stage"),
			new NoteRatingOption("Toggles the rating that appears when you press a note"),
			new HCBoolOption("Doesn't destroy the Player when you exit a song. Makes loading quicker but uses more ram and might cause issues","Persistant BF","persistBF"),
			new HCBoolOption("Doesn't destroy GF when you exit a song. Makes loading quicker but uses more ram and might cause issues","Persistant GF","persistGF"),
			// new HCBoolOption("Doesn't destroy the opponent when you exit a song. Makes loading quicker but uses more ram and might cause issues","Persistant Opponent","persistOpp"),
			// new UnloadSongOption("Unload the song when exiting the game"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		],"Disable some features for better performance"),
		new OptionCategory("Visibility", [
            new FontOption("Force menus to use the built-in font or mods/font.ttf for easier reading"),
            new BackTransOption("Change underlay opacity"),new BackgroundSizeOption("Change underlay size"),
			new FPSOption("Toggle the FPS Counter"),
			new BeatBouncingOption("Toggle certain animations like text beating on the main menu. Useful if text is hard to read"),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new NoteSplashOption("Shows note splashes when you get a 'Sick' rating"),
			new OpponentStrumlineOption("Whether to show the opponent's notes or not"),
			new ShowP2Option("Show Opponent"),
			new ShowGFOption("Show Girlfriend"),
			new ShowP1Option("Show Player 1"),
			new HCBoolOption("Makes the loading screen use threads and show loading progress but is buggy","Threaded loading screen","doCoolLoading"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		],"Toggle visibility of certain gameplay aspects"),
		new OptionCategory("Auditory", [
			#if hxCodec
			new HCBoolOption("Whether to use Flixel or VLC for audio. VLC supports more formats but may cause issues","VLC Audio Handling","vlcSound"),
			#end
			new VolumeOption("Adjust the volume of the entire game","master"),
			new VolumeOption("Adjust the volume of the background music","inst"),
			new VolumeOption("Adjust the volume of the vocals","voices"),
			new VolumeOption("Adjust the volume of the hit sounds","hit"),    
			new VolumeOption("Adjust the volume of miss sounds","miss"),       
			new VolumeOption("Adjust the volume of other sounds and the default script sound volume","other"),  
			new MissSoundsOption("Play a sound when you miss"),
			new HitSoundOption("Play a click when you hit a note. Uses osu!'s sounds or your mods/hitsound.ogg"),
			new PlayVoicesOption("Plays the voices a character has when you press a note."),
		],"Toggle some sounds and change the volume of things"),
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;
	var timer:FlxTimer;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	var titleText:FlxText;
	function addTitleText(str:String = 
							#if android
							"Options - Tap here to go back"
							#else
							"< Options"
							#end
	                      ){
		if (titleText != null) titleText.destroy();
		titleText = new FlxText(FlxG.width * 0.5 - (str.length * 10), 20, 0, str, 12);
		titleText.scrollFactor.set();
		titleText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titleText);
	}
	override function create()
	{
		loading = false;
		FlxG.mouse.visible = true;
		instance = this;
		FlxG.save.data.masterVol = FlxG.sound.volume;
		if(onlinemod.OnlinePlayMenuState.socket == null){
			initOptions();
		}

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0x793397;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);
		addTitleText();
		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

		super.create();
		changeSelection(0);
	}

	var isCat:Bool = false;
	public static var lastClass:Class<Dynamic>;
	function goBack(){
		if (lastState != 0){
			var ls = lastState;
			lastState = 0;
			SearchMenuState.doReset = true;
			LoadingScreen.show();
			switch(ls){
				case 3:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
				// case 6:FlxG.switchState(new PlayListState());
				case 12:FlxG.switchState(new onlinemod.OfflinePlayState());
				case 14:FlxG.switchState(new multi.MultiPlayState());
				case 15:FlxG.switchState(new osu.OsuPlayState());
				default:FlxG.switchState((if(ls > 10) new PlayState() else new MainMenuState()));
			}
		}else
			FlxG.switchState(new MainMenuState());
	}
	function isHovering(obj1:Dynamic,obj2:Dynamic):Bool{
		if(obj1 == null || obj2 == null) return false;
		var width:Float = obj2.width;
		var height:Float = obj2.height;
		var x:Float = obj2.x;
		var y:Float = obj2.y;
			
			
			
			

		return (obj1.x > x && obj1.x < x + width) && (obj1.y > y && obj1.y < y + height);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{	
			var _back = controls.BACK;
			var _up = controls.UP_P;
			var _down = controls.DOWN_P;
			var _left = controls.LEFT_P;
			var _right = controls.RIGHT_P;
			var _accept = controls.ACCEPT;

			if(FlxG.mouse.justReleased){
				if(isHovering(FlxG.mouse,titleText)){
					_back = true;
				}
				if(FlxG.mouse.overlaps(grpControls.members[curSelected])){
					_accept = true;
				}
				if(grpControls.members[curSelected + 1] != null && FlxG.mouse.overlaps(grpControls.members[curSelected + 1])){
					_down = true;
				}
				if(grpControls.members[curSelected - 1] != null && FlxG.mouse.overlaps(grpControls.members[curSelected - 1])){
					_up = true;
				}

				if(FlxG.swipes[0] != null){
					var swipe = FlxG.swipes[0];
					var distance = (swipe.startPosition.x - swipe.endPosition.x);
					
					if(swipe.duration < 0.5 && (distance > 100 || distance < -100)){
						_left = (distance < -100);
						_right = (distance > 100);
					}
				}
				// TODO Add left and right arrows onscreen for changing options
			}
			if (_back){
				if(isCat){

					isCat = false;

					CoolUtil.clearFlxGroup(grpControls);
					for (i in 0...options.length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							controlLabel.x = -2000;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = selCat;
					changeSelection(0);
					addTitleText();
					updateOffsetText();
				}else{
					saveChanges(); // Save when exiting, not every fucking frame
					goBack();
				}
			}
			if (_up) changeSelection(-1);
			if (_down) changeSelection(1);
			if(FlxG.mouse.wheel != 0){
				var move = -FlxG.mouse.wheel;
				changeSelection(Std.int(move));
			}
			
			if (isCat)
			{
				
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{

					if (FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.RIGHT || _right ){
						if(currentSelectedCat.getOptions()[curSelected].right()) updateAlphabet(grpControls.members[curSelected],currentSelectedCat.getOptions()[curSelected].getDisplay());

					}
					if (FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.LEFT || _left ){
						if(currentSelectedCat.getOptions()[curSelected].left()) updateAlphabet(grpControls.members[curSelected],currentSelectedCat.getOptions()[curSelected].getDisplay());
					}

				}
				updateOffsetText();
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT) FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT) FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT) FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT) FlxG.save.data.offset -= 0.1;
				updateOffsetText();
			}
		

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (_accept)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						// var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						// ctrl.isMenuItem = true;
						// grpControls.add(ctrl);
						// grpControls.replace(
						updateAlphabet(grpControls.members[curSelected],currentSelectedCat.getOptions()[curSelected].getDisplay());
						                    // ,ctrl);
					}
				}
				else
				{
					selCat = curSelected;
					currentSelectedCat = options[curSelected];
					isCat = true;
					var start = 0;
					var iy = FlxG.height * 0.50;
					CoolUtil.clearFlxGroup(grpControls);
					for (i in start...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							// controlLabel.y = iy;
							updateAlphabet(controlLabel);
							controlLabel.y+=360;
							controlLabel.x=1280;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					
					curSelected = 0;
					addTitleText('Options > ' + options[selCat].getName());
					updateOffsetText();
				}
			}
		}
		
	}
	function updateAlphabet(obj:Alphabet,str:String = ""){

		if(str != "") obj.text = str;
		var txt = obj.text.toLowerCase();
		if(txt.endsWith(" true") || txt.endsWith(" on")){
			obj.color = 0x55FF55;
		}else if(txt.endsWith(" false") || txt.endsWith(" off")){
			obj.color = 0xFF5555;
		}
		obj.bounce();
	}

	var isSettingControl:Bool = false;

	function updateOffsetText(){
		// versionShit.color = FlxColor.WHITE;
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				// if(currentDescription.substr(0,2) == "**" ){
				// 	versionShit.color = FlxColor.RED;

				// }
				versionShit.text = "Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
	}

	function changeSelection(change:Int = 0)
	{

		if (change != 0 )FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.members.length - 1;
		if (curSelected >= grpControls.members.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		// else if (currentSelectedCat.description != null)
		// 	currentDescription = currentSelectedCat.description;
		else
			currentDescription = "Select a category";

		updateOffsetText();
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	function initOptions(){
		trace('Initializing script options');
		if(FlxG.save.data.scripts.length < 1) return;
		try{SELoader.createDirectory('mods/scriptOptions/');}catch(e){trace('Unable to create dir! ${e}');}
		for (si in 0 ... FlxG.save.data.scripts.length) {
			var script = FlxG.save.data.scripts[si];
			if(!SELoader.exists('mods/scripts/$script/options.json')) {
				continue;
			}
			try{
				var sOptions:OptionsFileDef = Json.parse(CoolUtil.cleanJSON(SELoader.getContent('mods/scripts/$script/options.json')));
				// var curOptions:Map<String,Dynamic> = new Map<String,Dynamic>();
				modOptions[script] = new Map<String,Dynamic>();
				if(SELoader.exists('mods/scriptOptions/$script.json')){
					var scriptJson:Map<String,Dynamic> = loadScriptOptions('mods/scriptOptions/$script.json');
					if(scriptJson != null) {
						// modOptions[script] = scriptJson;
						modOptions[script] = scriptJson;
						// trace('Loaded "mods/scriptOptions/$script.json"');
					}else{
						trace('$script has an empty settings file, skipping!');
					}
				}

				if(sOptions.options == null){'$script has no options defined in it\'s options.json!';continue;}
				var saveOptions:Bool = false;
				var category:Array<Option> = [];
				for (v in sOptions.options) {
					var i = v.name;
					// trace('$script,$i: Registering. Info: ${v.type},${v.description},${v.def}');
					try{

						if(modOptions[script][i] == null) {
							// trace('$script,$i: Reseting to default value');
							if(v.def == null){
								 
								switch(v.type){
									case 0,1: modOptions[script][i] = 0;
									case 2: modOptions[script][i] = false;
								}
							}else{
								modOptions[script][i] = v.def;
							
							}
							saveOptions=true;
						}
						// trace('$script,$i: Adding to list');
						switch (v.type) {
							case 0:category.push(new FloatOption(v.description,i,Std.int(v.min),Std.int(v.max),script));
							case 1:category.push(new IntOption(v.description,i,Std.int(v.min),Std.int(v.max),script));
							case 2:category.push(new BoolOption(v.description,i,script));
							// case 3:category.push(new KeyOption(v.description,i,script));
						}
					}catch(e){
						trace('Error for $script,$i: ${e.message}');
						MainMenuState.errorMessage += '\nError for $script,$i: ${e.message}';
						modOptions[script][i] = null;
					}
				}
				if(category.length < 1){
					throw("No options loaded!");
				}
				// trace('$script: Pushing to options list');
				options.push(new OptionCategory('*${script}',category,true));
				// trace('$script: Globalising options');
				// modOptions[script] = curOptions;
				// trace('$script: Globalising option definitions');
				ScriptOptions[script] = sOptions;
				// trace('$script: Saving options');
				if (saveOptions) saveScriptOptions('mods/scriptOptions/$script.json',modOptions[script]);
			}catch(e){
				trace('Error for $script options: ${e.message}');
				MainMenuState.errorMessage += '\nError for $script options: ${e.message}';
				modOptions[script] = null;
				ScriptOptions[script] = null;
			}
		}
	}
	static function saveScriptOptions(path:String,obj:Map<String,Dynamic>){// TJSON gets fucky with maps, this'll save them using a typedef instead
		var _obj:Array<OptionF> = [];
		for (i => v in obj) {
			_obj.push({name:i,value:v});
		}
		File.saveContent(path,Json.stringify(_obj));
	}
	public static function loadScriptOptions(path:String):Null<Map<String,Dynamic>>{ // TJSON gets fucky with maps, this'll load them using a typedef instead
		
		var ret:Map<String,Dynamic> = new Map<String,Dynamic>();
		var obj:Array<OptionF> = Json.parse(CoolUtil.cleanJSON(SELoader.getContent(path)));
		if(obj == null) return null;
		for (i in obj) {
			ret[i.name] = i.value;
		}
		return ret;
	}

	function saveChanges(){
		try{
			// FlxG.save.flush();
			SEFlxSaveWrapper.save();
		}catch(e){MainMenuState.errorMessage += '\nUnable to save options! ${e.message}';}
		// File.saveContent('SEOPTIONS.json',Json.stringify(FlxG.save.data));
		for (i => v in modOptions) {
			try{
				// File.saveContent('mods/scriptOptions/$i.json',Json.stringify({options:v}));
				saveScriptOptions('mods/scriptOptions/$i.json',v);
				// trace('Saved mods/scriptOptions/$i.json');
			}catch(e){
				trace('Error saving $i, ${e.message}');
				MainMenuState.errorMessage += '\nError saving $i, ${e.message}';
			}
		}
		modOptions = new Map<String,Map<String,Dynamic>>();
	}


	// public function parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song",option:ScriptableOption){
	// 	if ((!QuickOptionsSubState.getSetting("Song hscripts") || onlinemod.OnlinePlayMenuState.socket != null) && !isStoryMode) {resetInterps();return;}
	// 	var songScript = songScript;
	// 	// var hsBrTools = hsBrTools;
	// 	if (script != "") songScript = script;
	// 	if (brTools == null && hsBrTools != null) brTools = hsBrTools;
	// 	if (songScript == "") {return;}
	// 	var interp = HscriptUtils.createSimpleInterp();
	// 	var parser = new hscript.Parser();
	// 	try{
	// 		parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;

	// 		var program;
	// 		// parser.parseModule(songScript);
	// 		program = parser.parseString(songScript);

	// 		if (brTools != null) {
	// 			trace('Using hsBrTools');
	// 			interp.variables.set("BRtools",brTools); 
	// 			brTools.reset();
	// 		}else {
	// 			trace('Using assets folder');
	// 			interp.variables.set("BRtools",new HSBrTools("assets/"));
	// 		}
	// 		interp.variables.set("charGet",charGet); 
	// 		interp.execute(program);
	// 		interps[id] = interp;
	// 		if(brTools != null)brTools.reset();
	// 		callInterp("initScript",[],id);
	// 		interpCount++;
	// 	}catch(e){
	// 		handleError('Error parsing ${id} hscript, Line:${parser.line};\n Error:${e.message}');
	// 		// interp = null;
	// 	}
	// 	trace('Loaded ${id} script!');
	// }



}
