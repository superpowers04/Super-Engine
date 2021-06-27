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

class FinishSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var music:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var win:Bool = true;

	public function new(x:Float, y:Float,?win = true)
	{
		if(win){PlayState.boyfriend.playAnim("hey");PlayState.dad.playAnim('singDOWNmiss');}else{PlayState.boyfriend.playAnim('singDOWNmiss');PlayState.dad.playAnim("hey");}
		super();
		music = new FlxSound().loadEmbedded(Paths.music(if(win) 'breakfast' else 'gameOver'), true, true);
		music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));

		FlxG.sound.list.add(music);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var finishedText:FlxText = new FlxText(20,-55,0,if(win) "Song Won!" else "Song failed" );
		finishedText.size = 34;
		finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
		finishedText.color = FlxColor.WHITE;
		finishedText.scrollFactor.set();
		add(finishedText);
		var comboText:FlxText = new FlxText(20,-75,0,'Judgements:\n\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\nShits - ${PlayState.shits}\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})\nMisses: ${PlayState.misses}\n\nScore: ${PlayState.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		var contText:FlxText = new FlxText(FlxG.width - 475,FlxG.height + 100,0,'Press ENTER to continue\nor R to restart.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		var settingsText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyString()}');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;


		if (accepted)
		{
			if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
			switch (PlayState.stateType)
			{
				case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
					

				default:FlxG.switchState(new FreeplayState());
			}
			return;
		}

		if (FlxG.keys.justPressed.R)
		{if(win){FlxG.resetState();}else{restart();}}
	}
	function restart()
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOverEnd'));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				FlxG.resetState();
			});
		});
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}