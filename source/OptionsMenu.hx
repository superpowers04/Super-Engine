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

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;
	public static var lastState:Int = 0;

	var selector:FlxText;
	var curSelected:Int = 0;
	var selCat:Int = 0;
	var transitioning:Bool = false;

	var options:Array<OptionCategory> = [
		new OptionCategory("Customization", [
			new OpponentOption("Change the opponent character"),
			new PlayerOption("Change the player character"),
			new GFOption("Change the GF used"),
			new NoteSelOption("Change the note assets used, pulled from mods/noteassets"),
			new CharAutoOption("Allow the song to choose the opponent if you have them"),
			new ReloadCharlist("Refreshes the character list, used for if you added characters"),
			new SelStageOption("Select the stage to use, Default will use song default"),
		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
		    new PracticeModeOption("Disables the ability to get a gameover."),
			new DownscrollOption("Change the layout of the strumline."),
			new MiddlescrollOption("Move the strumline to the middle of the screen"),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),

			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new OffsetMenu("Get a note offset based off of your inputs!"),
			// new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference"), This didn't work before and it doesn't work again...
			new HitSoundOption("Play a click when you hit a note. Uses osu!'s sounds or your mods/hitsound.ogg"),
			new InputHandlerOption("Change the input engine used, only works locally, Disables Kade options unless supported by engine")
		]),
		new OptionCategory("Appearance", [
			new GUIGapOption("Change the distance between the end of the screen and text"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamMovementOption("Toggle the camera moving"),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new AccuracyOption("Display accuracy information."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			new CpuStrums("CPU's strumline lights up when a note hits it."),
		]),
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new FPSCapOption("Cap your FPS"),
			new MissSoundsOption("Play a sound when you miss"),
			new ResetButtonOption("Toggle pressing R to gameover."),

			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new AnimDebugOption("Access animation debug in a offline session, 1=BF,2=Dad,3=GF"),
			new PlayVoicesOption("Plays your character's voices when you press a note.")
		]),
		new OptionCategory("Preformance", [
			new CheckForUpdatesOption("Toggle check for updates when booting the game, useful if you're in the Discord with pings on"),
			new UseBadArrowsOption("Use custom arrow texture instead of coloring normal notes black"),
			new NoteSplashOption("Shows note splashes when you get a 'Sick' rating"),
			new ShitQualityOption("Disables elements not essential to gameplay like the stage"),
			new NoteRatingOption("Toggles the rating that appears when you press a note"),
			new UnloadSongOption("Unload the song when exiting the game, can cause issues but should help with memory"),
			new OpponentStrumlineOption("Whether to show the opponent's notes or not"),
			new ShowP2Option("Show Opponent"),
			new ShowGFOption("Show Girlfriend"),
			new ShowP1Option("Show Player 1"),
		])
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
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
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
	
	function goBack(){
		if (lastState != 0){
			var ls = lastState;
			lastState = 0;
			switch(ls){
				case 3:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
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
				// var id = TitleState.returnStateID;
				// TitleState.returnStateID = 0; // Reset
				// switch(id){
				// 	case 0:
				// 		FlxG.switchState(new MainMenuState());

				// 	case 1:
				// 		FlxG.switchState(new onlinemod.OfflineMenuState());
				// }}
				FlxG.save.flush(); // Save when exiting, not every fucking frame
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
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						ctrl.isMenuItem = true;
						grpControls.add(ctrl);
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
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
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

		for (i in 0...options[curSelected].getOptions().length)
		{
			// if(i >= 4) break; // No reason to add more than 4 // Actually, probably not a good idea, slower machines don't load the rest for some reason
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[curSelected].getOptions()[i].getDisplay(), true, false, true,FlxG.width * 0.60);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			controlLabel.alpha = 0.3;
			controlLabel.color = 0xdddddd;
			controlLabel.x = 80;
			controlLabel.y = FlxG.height * 0.50;
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
}
