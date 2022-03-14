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
		new OptionCategory("Modifications", [
			new OpponentOption("Change the opponent character"),
			new PlayerOption("Change the player character"),
			new GFOption("Change the GF used"),
			new NoteSelOption("Change the note assets used, pulled from mods/noteassets"),
			new SelStageOption("Select the stage to use, Default will use song default"),
			new SelScriptOption("Enable/Disable scripts that run withsongs"),
			new CharAutoOption("Force the opponent you've selected or allow the song to choose the opponent if you have them installed"),
			new ReloadCharlist("Refreshes list of stages, characters and scripts"),
			new AllowServerScriptsOption("Allow servers to run scripts. THIS IS DANGEROUS, ONLY ENABLE IF YOU TRUST THE SERVERS"),
		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Change the layout of the strumline."),
			new MiddlescrollOption("Move the strumline to the middle of the screen"),

			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new OffsetMenu("Get a note offset based off of your inputs!"),
			new InputHandlerOption("Change the input engine used, only works locally. Kade is considered legacy and will not be improved")
		]),
		new OptionCategory("Modifiers", [
		    new PracticeModeOption("Disables the ability to get a gameover."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new AccurateNoteHoldOption("Adjust accuracy of note sustains"),
		]),

		new OptionCategory("Appearance", [
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamMovementOption("Toggle the camera moving"),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new AccuracyOption("Display accuracy information."),
			new SongPositionOption("Show the songs current position, name and length"),
			new CpuStrums("CPU's strumline lights up when a note hits it."),
			new SongInfoOption("Change how your performance is displayed"),
			new GUIGapOption("Change the distance between the end of the screen and text(Not used everywhere)"),
		]),
		new OptionCategory("Misc", [
			new CheckForUpdatesOption("Toggle check for updates when booting the game, useful if you're in the Discord with pings on"),
			new FPSOption("Toggle the FPS Counter"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new AnimDebugOption("Access animation debug in a offline session, 1=BF,2=Dad,3=GF. Also shows extra information"),
			new LogGameplayOption("Logs your game to a text file"),
			new EraseOption("Backs up your options to SEOPTIONS-BACKUP.json and then resets them"),
			new ImportOption("Import your options from SEOPTIONS.json"),
			new ExportOption("Export your options to SEOPTIONS.json to backup or to share with a bug report"),
		]),
		new OptionCategory("Performance", [
			new FPSCapOption("Cap your FPS"),
			new UseBadArrowsOption("Use custom arrow texture instead of coloring normal notes black"),
			new ShitQualityOption("Disables elements not essential to gameplay like the stage"),
			new NoteRatingOption("Toggles the rating that appears when you press a note"),
			// new UnloadSongOption("Unload the song when exiting the game"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		]),
		new OptionCategory("Visibility", [
            new FontOption("Force menus to use the built-in font or mods/font.ttf for easier reading"),new BackTransOption("Change underlay opacity"),new BackgroundSizeOption("Change underlay size"),
			new NoteSplashOption("Shows note splashes when you get a 'Sick' rating"),
			new OpponentStrumlineOption("Whether to show the opponent's notes or not"),
			new ShowP2Option("Show Opponent"),
			new ShowGFOption("Show Girlfriend"),
			new ShowP1Option("Show Player 1"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		]),
		new OptionCategory("Auditory", [
			new VolumeOption("Adjust the volume of the entire game","master"),
			new VolumeOption("Adjust the volume of the background music","inst"),
			new VolumeOption("Adjust the volume of the vocals","voices"),
			new VolumeOption("Adjust the volume of the hit sounds","hit"),    
			new VolumeOption("Adjust the volume of miss sounds","miss"),       
			new VolumeOption("Adjust the volume of other sounds and the default script sound volume","other"),  
			new MissSoundsOption("Play a sound when you miss"),
			new HitSoundOption("Play a click when you hit a note. Uses osu!'s sounds or your mods/hitsound.ogg"),
			new PlayVoicesOption("Plays the voices a character has when you press a note."),
		]),
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	private var grpControls_:FlxTypedGroup<Alphabet>;
	private var catControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;
	var timer:FlxTimer;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	var titleText:FlxText;
	function addTitleText(str:String = "Options"){
		if (titleText != null) titleText.destroy();
		titleText = new FlxText(FlxG.width * 0.5 - (str.length * 10), 20, 0, str, 12);
		titleText.scrollFactor.set();
		titleText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titleText);
	}
	override function create()
	{

		instance = this;
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
		updateCat();
	}

	var isCat:Bool = false;
	public static var lastClass:Class<Dynamic>;
	function goBack(){
		if (lastState != 0){
			var ls = lastState;
			lastState = 0;
			SearchMenuState.doReset = true;
			switch(ls){
				case 3:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
				case 12:FlxG.switchState(new onlinemod.OfflinePlayState());
				case 14:FlxG.switchState(new multi.MultiPlayState());
				case 15:FlxG.switchState(new osu.OsuPlayState());
				default:FlxG.switchState((if(ls > 10) new PlayState() else new MainMenuState()));
			}
		}else
			FlxG.switchState(new MainMenuState());
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isCat){

				saveChanges(); // Save when exiting, not every fucking frame
				goBack();
			}
				
			else if (controls.BACK)
			{
				isCat = false;
				if (catControls != null){
					catControls.clear();
					grpControls.forEach(function(item){
						catControls.add(item);
						item.xOffset = FlxG.width * 0.60;
						item.alpha = 0.3;
						item.color = 0xdddddd;
					});
				}
				grpControls.clear();
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
				changeSelection(0,false);
				addTitleText();
				updateOffsetText();
			}
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
			
			if (isCat)
			{
				
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
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

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						ctrl.isMenuItem = true;
						// grpControls.add(ctrl);
						grpControls.replace(grpControls.members[curSelected],ctrl);
					}
				}
				else
				{
					selCat = curSelected;
					currentSelectedCat = options[curSelected];
					isCat = true;
					var start = 0;
					var iy = FlxG.height * 0.50;
					if ( grpControls_ == null) {grpControls_ = new FlxTypedGroup<Alphabet>();add(grpControls_);}
					grpControls_.clear();
					grpControls.forEach(function(item){
						item.xOffset = -1500;
						grpControls_.add(item);
					});
					grpControls.clear();
					if (timer != null)timer.cancel();
					timer=new FlxTimer().start(0.4, function(tmr:FlxTimer){grpControls_.clear();},1);
					

					if (catControls != null){
						start = 4;
						iy=FlxG.height;
						catControls.forEach(function(item){
							grpControls.add(item);
							item.xOffset = 70;
							item.alpha = 1;
							item.color = 0xFFFFFFFF;
						});
						catControls.clear();
						curSelected = 0;
						changeSelection(0);
					}
					// for (i in start...currentSelectedCat.getOptions().length)
					// 	{
					// 		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
					// 		controlLabel.isMenuItem = true;
					// 		controlLabel.targetY = i;
					// 		controlLabel.x = FlxG.width * 0.60;
					// 		controlLabel.y = iy;
					// 		grpControls.add(controlLabel);
					// 		// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					// 	}
					
					curSelected = 0;
					addTitleText(options[selCat].getName());
					updateOffsetText();
				}

				updateCat();
			}
		}
		
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

	function updateCat(){
		if (catControls != null){catControls.clear();} else{catControls = new FlxTypedGroup<Alphabet>();add(catControls);}
		
		if (isCat) return;
		// catControls = new FlxTypedGroup<Alphabet>();
		// add(catControls);
		var ia = 0;
		if (options[curSelected].modded) ia = 1;
		for (i in 0...options[curSelected].getOptions().length)
		{
			// if(i >= 4) break; // No reason to add more than 4 // Actually, probably not a good idea, slower machines don't load the rest for some reason
			
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[curSelected].getOptions()[i].getDisplay(), true, false, false,FlxG.width * 0.60);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i + ia;
			controlLabel.alpha = 0.3;
			controlLabel.color = 0xdddddd;
			controlLabel.x = 80;
			controlLabel.y = FlxG.height * 0.50;
			// if(options[curSelected].getOptions()[i].getDisplay().length > 24) controlLabel.scale.set(0.6);
			catControls.add(controlLabel);
		}
	}

	function changeSelection(change:Int = 0,?upCat = true)
	{

		if (change != 0 )FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		if(transitioning) return;

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		updateOffsetText();
		if (upCat) updateCat();
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
		try{FileSystem.createDirectory('mods/scriptOptions/');}catch(e){trace('Unable to create dir! ${e}');}
		for (si in 0 ... FlxG.save.data.scripts.length) {
			var script = FlxG.save.data.scripts[si];
			if(!FileSystem.exists('mods/scripts/$script/options.json')) {
				trace('$script has no options');
				continue;
			}
			trace('$script has valid options file');
			try{
				var sOptions:OptionsFileDef = Json.parse(CoolUtil.cleanJSON(File.getContent('mods/scripts/$script/options.json')));
				// var curOptions:Map<String,Dynamic> = new Map<String,Dynamic>();
				modOptions[script] = new Map<String,Dynamic>();
				if(FileSystem.exists('mods/scriptOptions/$script.json')){
					var scriptJson:Map<String,Dynamic> = loadScriptOptions('mods/scriptOptions/$script.json');
					trace('scriptJson: $scriptJson'); 
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
				trace('$script: Setting up user settings');
				for (v in sOptions.options) {
					var i = v.name;
					trace('$script,$i: Registering. Info: ${v.type},${v.description},${v.def}');
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
				trace('$script registered successfully');
			}catch(e){
				trace('Error for $script options: ${e.message}');
				MainMenuState.errorMessage += '\nError for $script options: ${e.message}';
				modOptions[script] = null;
				ScriptOptions[script] = null;
			}
		}
	}
	static function saveScriptOptions(path:String,obj:Map<String,Dynamic>){
		var _obj:Array<OptionF> = [];
		for (i => v in obj) {
			_obj.push({name:i,value:v});
		}
		File.saveContent(path,Json.stringify(_obj));
	}
	public static function loadScriptOptions(path:String):Null<Map<String,Dynamic>>{ // Holy shit this is terrible but whatever
		
		var ret:Map<String,Dynamic> = new Map<String,Dynamic>();
		var obj:Array<OptionF> = Json.parse(CoolUtil.cleanJSON(File.getContent(path)));
		if(obj == null) return null;
		for (i in obj) {
			ret[i.name] = i.value;
		}
		return ret;
	}

	function saveChanges(){
		FlxG.save.flush();
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
