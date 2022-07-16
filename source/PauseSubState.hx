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
// import flixel.tweens.FlxTweenManager;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Options Menu",'Exit to menu'];
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
	var finishCallback:()->Void;
	var time:Float = 0;
	var volume:Float = 0;
	public function new(x:Float, y:Float)
	{
		openfl.system.System.gc();
		super();
		// PlayState.canPause = false; // Prevents the game from glitching somehow and trying to pause when already paused
		PlayState.instance.callInterp("pauseCreate",[this]);

		// pauseMusic = ;
		// pauseMusic.volume = 0;
		// FlxG.sound.playMusic(SickMenuState.menuMusic,FlxG.save.data.instVol);
		// FlxG.sound.music.play(false, FlxG.save.data.instVol * 0.8);
		// FlxG.sound.music.time = Conductor.songPosition;

		finishCallback = FlxG.sound.music.onComplete;

		time = FlxG.sound.music.time;
		FlxG.sound.music.onComplete = null;
		FlxG.sound.music.looped = true;
		// FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(CoolUtil.font, 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text = CoolUtil.difficultyString();
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
		// perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		// perSongOffset.scrollFactor.set();
		// perSongOffset.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		// #if cpp
		// 	add(perSongOffset);
		// #end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false,true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			songText.screenCenter(X);
			var sX = songText.x;
			songText.x = 100 - songText.width * 0.5;
			FlxTween.tween(songText,{x : sX},0.9,{ease:FlxEase.bounceOut});
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
		volume = FlxG.sound.music.volume;
		FlxTween.tween(FlxG.sound.music,{volume:0.2},0.5);
		FlxG.sound.music.looped = true;
	}

	override function update(elapsed:Float)
	{if (ready){
		// if (FlxG.sound.music.volume < 0.5)
		// 	FlxG.sound.music.volume += 0.01 * elapsed;
		// if (FlxG.sound.music.volume > 0.25)
		// 	FlxG.sound.music.volume -= 0.1 * elapsed;
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
					disappearMenu();
					new FlxTimer().start(0.3,function(tmr:FlxTimer){
						FlxG.resetState();
					},1);
				case "Options Menu":
					disappearMenu();
					new FlxTimer().start(0.3,function(tmr:FlxTimer){
						SearchMenuState.doReset = false;
						OptionsMenu.lastState = PlayState.stateType + 10;
						FlxG.switchState(new OptionsMenu());
					},1);

				case "Exit to menu":
					disappearMenu();
					new FlxTimer().start(0.3,function(tmr:FlxTimer){
						FlxTween.globalManager.clear();
						quit();
					},1);
			}
		}

	}else{
		if (controls.ACCEPT && menuItems[curSelected] == "Exit to menu")
		{
			quit();
		}
	}}
	function disappearMenu(?time:Float = 0.3){
		for (_ => v in grpMenuShit.members)
		{
			ready = false;
			FlxTween.tween(v,{x : -(100 + v.width),alpha : 0},time,{ease:FlxEase.cubeIn});
		}
	}
	function quit(){
		PlayState.loadRep = false;

		if (FlxG.save.data.fpsCap > 290) (cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		FlxG.sound.music.stop();
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
	var _tween:FlxTween;
	function countdown(){try{
		ready = false;
		var swagCounter:Int = 1;
		try{
			_tween = FlxTween.tween(FlxG.sound.music,{volume:0},0.5);
		}catch(e){}
		for (i in [levelDifficulty,levelInfo,perSongOffset]) {
			if(i != null){
				i.destroy();
			}
		}
		disappearMenu(0.4);
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
					FlxTimer.globalManager.forEach(function(tmr:FlxTimer){
						tmr.active = false;
					});
					FlxTween.globalManager.forEach(function(t){
						t.active = false;
					});
					if(_tween != null)_tween.cancel();
					FlxG.sound.music.time = time;
					FlxG.sound.music.volume = volume;
					FlxTween.tween(FlxG.sound.music,{volume:volume},0.01);
					FlxG.sound.music.onComplete = finishCallback;
					FlxG.sound.music.pause();
					close();

			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}catch(e){MainMenuState.handleError(e,'Something went wrong on countdown ${e.message}');}}
	
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