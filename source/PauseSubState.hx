package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	var ready = true;
	
	var offsetChanged:Bool = false;
	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var startTimer:FlxTimer;
	var quitHeld:Int = 0;
	var quitHeldBar:FlxBar;
	var quitHeldBG:FlxSprite;

	var songPath = '';
	var shouldveLeft = false;
	public function new(x:Float, y:Float)
	{
		super();
		// PlayState.canPause = false; // Prevents the game from glitching somehow and trying to pause when already paused
		PlayState.instance.callInterp("pauseCreate",[this]);

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(CoolUtil.font, 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		quitHeldBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar','shared'));
		quitHeldBG.screenCenter(X);
		quitHeldBG.scrollFactor.set();
		add(quitHeldBG);


		quitHeldBar = new FlxBar(quitHeldBG.x + 4, quitHeldBG.y + 4, LEFT_TO_RIGHT, Std.int(quitHeldBG.width - 8), Std.int(quitHeldBG.height - 8), this,'quitHeld', 0, 1000);
		quitHeldBar.numDivisions = 1000;
		quitHeldBar.scrollFactor.set();
		quitHeldBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		add(quitHeldBar);
		songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		PlayState.instance.callInterp("pause",[this]);
	}

	override function update(elapsed:Float)
	{if (ready){
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
		PlayState.instance.callInterp("pauseUpdate",[this]);

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;

		if (upP)
		{
			changeSelection(-1);
   
		}else if (downP)
		{
			changeSelection(1);
		}
		
		if (quitHeldBar.visible && quitHeld <= 0){
			quitHeldBar.visible = false;
			quitHeldBG.visible = false;
    		}
		if (FlxG.keys.pressed.ESCAPE)
		{
			quitHeld += 5;
			quitHeldBar.visible = true;
			quitHeldBG.visible = true;
			if (quitHeld > 1000) {quit();quitHeld = 0;} 
			}else if (quitHeld > 0){
			quitHeld -= 10;

		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					countdown();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					quit();
			}
		}

	}
}
	function quit(){
		if(PlayState.loadRep)
		{
			FlxG.save.data.botplay = false;
			FlxG.save.data.scrollSpeed = 1;
			FlxG.save.data.downscroll = false;
		}
		PlayState.loadRep = false;

		if (FlxG.save.data.fpsCap > 290) (cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		retMenu();

		return;
	}
	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		if (shouldveLeft) {Main.game.forceStateSwitch(new MainMenuState());return;}
		switch (PlayState.stateType)
		{
			case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
			case 4:FlxG.switchState(new multi.MultiMenuState());
			case 5:FlxG.switchState(new osu.OsuMenuState());
				

			default:FlxG.switchState(new MainMenuState());
		}
		shouldveLeft = true;
		return;
	}
	function countdown(){try{
		ready = false;
		var swagCounter:Int = 1;
		pauseMusic.stop();
		pauseMusic.destroy();
		grpMenuShit.destroy();
		levelDifficulty.destroy();
		levelInfo.destroy();
		perSongOffset.destroy();
		PlayState.instance.callInterp("pauseResume",[this]);



		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			switch (swagCounter)
			{
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

					PlayState.instance.callInterp("pauseExit",[]);
					close();
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}catch(e){MainMenuState.handleError('Something went wrong on countdown ${e.message}');}}
	
	override function destroy()
	{
		if (pauseMusic != null){pauseMusic.destroy();}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
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