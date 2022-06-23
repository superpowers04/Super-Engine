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
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import sys.FileSystem;
import sys.io.File;
import PlayState.OutNote;
import flash.media.Sound;

using StringTools;


typedef ActionsFile = {
	var info:String;
	var notes:Array<OutNote>;
	var bf:String;
	var gf:String;
	var opp:String;
	var ver:String;

}


class FinishSubState extends MusicBeatSubstate
{
	public var curSelected:Int = 0;
	public var music:FlxSound;
	public var perSongOffset:FlxText;
	public var offsetChanged:Bool = false;
	public var win:Bool = true;
	public var ready = false;
	public var errorMsg:String = "";
	public var isError:Bool = false; 
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var iconP1:HealthIcon; 
	public var iconP2:HealthIcon;
	public static var pauseGame:Bool = true;
	public static var autoEnd:Bool = true;
	public static var forceBFAnim:Bool = false;
	public static var instance:FinishSubState;
	public static var fadeOut:Bool = true;
	public var updateBF = true;
	public function new(x:Float, y:Float,?won = true,?error:String = "")
	{
		instance = this;
		endingMusic = null;
		if (error != ""){
			isError = true;
			errorMsg = error;
			won = false;
			// PlayState.instance.paused = true;
		}
		PlayState.instance.camHUD.alpha = PlayState.instance.camTOP.alpha = 1;
		PlayState.instance.followChar(if(won) 0 else 1);
		var camPos = PlayState.instance.getDefaultCamPos();
		PlayState.instance.camFollow.setPosition(camPos[0],camPos[1]);

		if(!isError){
			var inName = if(won)"winSong" else "loseSong";
			PlayState.instance.callInterp(inName,[]);
			PlayState.dad.callInterp(inName,[]);
			PlayState.boyfriend.callInterp(inName,[]);
		}

		FlxG.state.persistentUpdate = false;
		win = won;
		FlxG.sound.pause();
		if(!isError) PlayState.instance.generatedMusic = PlayState.instance.handleTimes = PlayState.instance.acceptInput = false;
		var dad = PlayState.dad;
		var boyfriend = PlayState.boyfriend;
		Conductor.changeBPM(70);
		FlxG.cameras.setDefaultDrawTarget(PlayState.instance.camTOP,true);


		// For healthbar shit
		healthBar = PlayState.instance.healthBar;
		healthBarBG = PlayState.instance.healthBarBG;
		iconP1 = PlayState.instance.iconP1;
		iconP2 = PlayState.instance.iconP2;


		if(win){
			for (g in [PlayState.instance.cpuStrums,PlayState.instance.playerStrums]) {
				g.forEach(function(i){
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				});
			}
			if (FlxG.save.data.songPosition)
			{
				for (i in [PlayState.songPosBar,PlayState.songPosBG,PlayState.instance.songName,PlayState.instance.songTimeTxt]) {
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				}
			}

			FlxTween.tween(healthBar, {y:Std.int(FlxG.height * 0.10)},1,{ease: FlxEase.expoIn});
			FlxTween.tween(healthBarBG, {y:Std.int(FlxG.height * 0.10 - 4)},1,{ease: FlxEase.expoIn});
			FlxTween.tween(iconP1, {y:Std.int(FlxG.height * 0.10 - (iconP1.height * 0.5))},1,{ease: FlxEase.expoIn});
			FlxTween.tween(iconP2, {y:Std.int(FlxG.height * 0.10 - (iconP2.height * 0.5))},1,{ease: FlxEase.expoIn});




			FlxTween.tween(PlayState.instance.kadeEngineWatermark, {y:FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.scoreTxt, {y:if(FlxG.save.data.downscroll) -200 else FlxG.height + 200},1,{ease: FlxEase.expoIn});
		}
		if(!isError){
			if(win){
				boyfriend.playAnimAvailable(['win','hey','singUP'],true);
				if (dad.curCharacter == FlxG.save.data.gfChar) dad.playAnim('cheer',true); else {dad.playAnimAvailable(['lose','singDOWNmiss'],true);}
				PlayState.gf.playAnim('cheer',true);
			}else{
				// boyfriend.playAnim('singDOWNmiss');
				// boyfriend.playAnim('lose');

				// dad.playAnim("hey",true);
				// dad.playAnim("win",true);
				boyfriend.playAnimAvailable(['lose'],true);
				dad.playAnimAvailable(['win','hey'],true);
				if (dad.curCharacter == FlxG.save.data.gfChar) dad.playAnim('sad',true); else dad.playAnim("hey",true);
				PlayState.gf.playAnim('sad',true);
			}
		}

		super();
		// if(fadeOut){
		// 	FlxTween.tween(PlayState.instance.camGame,{alpha:0},0.5);
		// 	// FlxTween.tween(FlxG.boyfriend,{x:FlxG.width - (boyfriend.width * 0.5),y:FlxG.height - (boyfriend.height * 0.5)},0.5);
		// 	PlayState.instance.camTOP.target = boyfriend;
		// 	boyfriend.cameras = [PlayState.instance.camTOP];
		// }
		if(autoEnd){

			// FlxG.camera.zoom = 1;
			// PlayState.instance.camHUD.zoom = 1;

			if((["win","lose","singup"]).contains(boyfriend.animation.curAnim.name.toLowerCase())) boyfriend.animation.finishCallback = this.finishNew; else finishNew();
			// if (FlxG.save.data.camMovement){
			PlayState.instance.followChar(0);
			// }
			forceBFAnim = false;
		}

	}

	public static var endingMusic:Sound;
	public var cam:FlxCamera;
	var optionsisyes:Bool = false;
	var shownResults:Bool = false;
	public function finishNew(?name:String){
			ready =true;
			Conductor.changeBPM(70);
			FlxG.camera.alpha = PlayState.instance.camHUD.alpha = 1;
			// FlxG.camera.zoom = PlayState.instance.defaultCamZoom;
			PlayState.instance.generatedMusic = false;
			PlayState.instance.followChar(if(win) 0 else 1);
			var camPos = PlayState.instance.getDefaultCamPos();
			PlayState.instance.camFollow.setPosition(camPos[0],camPos[1]);
			PlayState.instance.camGame.setPosition(camPos[0],camPos[1]);
			cam = new FlxCamera();
			updateBF = false;
			FlxG.cameras.add(cam);
			FlxCamera.defaultCameras = [cam];
			if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dad.animation.finishCallback = null;
			// ready = true;
			FlxG.state.persistentUpdate = !isError && !pauseGame;
			pauseGame = true;
			autoEnd = true;
			FlxG.sound.pause();

			music = new FlxSound().loadEmbedded(if(endingMusic != null) endingMusic else Paths.music( if(win) 'StartItchBuild' else 'gameOver'), true, true);
			music.play(false);

			if(win && endingMusic == null){
				music.looped = false;
				music.onComplete = function(){music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);music.play(false);} 

			}
			endingMusic = null;
			shownResults = true;
			// FlxG.camera.zoom = PlayState.instance.camHUD.zoom = 1;

			FlxG.sound.list.add(music);
			// PlayState.songScore
			

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			new FlxTimer().start(0.6,function(e:FlxTimer){FinishSubState.instance.ready=true;});
			if(isError){
				// ready = false;
				var finishedText:FlxText = new FlxText(20,-55,0, "Error caught!" );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.RED;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,'Error Message:\n${errorMsg}\n\nIf you\'re not the creator of the character or chart,\nit is recommended that you report this to the chart/character\'s developer');
				comboText.size = 28;
				comboText.wordWrap = true;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				comboText.fieldWidth = FlxG.width - comboText.x;
				var contText:FlxText = new FlxText(FlxG.width * 0.5,FlxG.height + 100,0,'Press ENTER to exit, R to reload or O to open options.');
				contText.size = 28;
				contText.x -= contText.width * 0.5;

				// contText.alignment = CENTER;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
				optionsisyes = true;
				
			}else{

				var finishedText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-55,0, (if(PlayState.isStoryMode) "Week" else "Song") + " " + (if(win) "Won!" else "Failed...") );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.WHITE;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,(!PlayState.isStoryMode ? 'Song/Chart' : "Week") + ':\n'
						+'\nSicks - ${PlayState.sicks}'
						+'\nGoods - ${PlayState.goods}'
						+'\nBads - ${PlayState.bads}'
						+'\nShits - ${PlayState.shits}'
						+'\nGhost Taps - ${PlayState.ghostTaps}'
						+'\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})'
						+'\nMisses${if(FlxG.save.data.ghost) "" else " + Ghost Taps"}${if(FlxG.save.data.shittyMiss) ' + Shits' else ''}${if(FlxG.save.data.badMiss) ' + Bads' else ''}${if(FlxG.save.data.goodMiss) ' + Goods' else ''}: ${PlayState.misses}'
						+'\n\nScore: ${PlayState.songScore}'
						+'\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%'
						+'\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}\n');
				comboText.size = 28;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
// Std.int(FlxG.width * 0.45)
				var settingsText:FlxText = new FlxText(comboText.width * 1.10 + FlxG.save.data.guiGap,-30,0,
				(if(PlayState.isStoryMode) StoryMenuState.weekNames[StoryMenuState.curWeek] else if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
				
				+'\n\nSettings:'
				+'\n\n Downscroll: ${FlxG.save.data.downscroll}'
				+'\n Ghost Tapping: ${FlxG.save.data.ghost}'
				+'\n Practice: ${FlxG.save.data.practiceMode}'
				+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count:${PlayState.instance.interpCount}' : "")
				+(if(FlxG.save.data.inputHandler == 1) '\n Safe Frames: ${FlxG.save.data.frames}' else 
				 '\n HitWindows: ${Ratings.ratingMS("sick")},${Ratings.ratingMS("good")},${Ratings.ratingMS("bad")},${Ratings.ratingMS("shit")} MS')
				+'\n Input Engine: ${PlayState.inputEngineName}, V${MainMenuState.ver}'
				+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
				+'\n'
				);
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				var contText:FlxText = new FlxText(FlxG.width - FlxG.save.data.guiGap,FlxG.height + 100,0,'Press ENTER to continue or R to restart.');
				
				contText.size = 28;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.x -= contText.width;
				contText.scrollFactor.set();
				// var chartInfoText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${songName}');
				// chartInfoText.size = 16;
				// chartInfoText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
				// chartInfoText.color = FlxColor.WHITE;
				// chartInfoText.scrollFactor.set();
				

				if(win && !PlayState.instance.hasDied && !ChartingState.charting){Highscore.setScore('${PlayState.nameSpace}-${PlayState.actualSongName}',PlayState.songScore,[PlayState.songScore,'${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%',Ratings.GenerateLetterRank(PlayState.accuracy)]);}
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
				add(settingsText);
				// add(chartInfoText);
				healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = [cam];

				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				// FlxTween.tween(chartInfoText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(settingsText, {y:145},0.5,{ease: FlxEase.expoInOut});
				if(PlayState.logGameplay){

					try{
						var info = '--- Game Info:\n${comboText.text}\n\n${settingsText.text}\n\nCharacters(Dad,GF,BF): ${PlayState.dad.curCharacter},${PlayState.gf.curCharacter},${PlayState.boyfriend.curCharacter}\n\nScripts:';
						for (i => v in PlayState.instance.interps) {
							info += '\n- $i';
						}
						var eventLog:ActionsFile = {
							info:info,
							notes:PlayState.instance.eventLog,
							bf:PlayState.boyfriend.curCharacter,
							opp:PlayState.dad.curCharacter,
							gf:PlayState.gf.curCharacter,
							ver:${MainMenuState.ver}
						};
						var events:String = info + '\n\n--- Hits and Misses:\n
/ Example Note
|- TIME
|- DIRECTION
|- RATING
|- IS SUSTAIN
|- NOTE STRUM TIME
\\


';
						var noteCount = 0;
						for (_ => v in PlayState.instance.eventLog ) {
							events += '
/
|- ${v.time}
|- ${Note.noteDirections[v.direction]}
|- ${v.rating}
|- ${v.isSustain}
|- ${v.strumTime}
\\';
							if(!v.isSustain && v.rating != "Missed without note")noteCount++;
						}
						var eventsjson:String = haxe.Json.stringify(eventLog);
						events += '\n---\nLog generated at ${Date.now()}, Assumed Note Count: ${noteCount}. USE THE JSON FOR AUTOMATION';
						if(!FileSystem.exists("songLogs/"))
							FileSystem.createDirectory("songLogs/");
						var curDate = Date.now();
						var songName = if(PlayState.isStoryMode) StoryMenuState.weekNames[StoryMenuState.curWeek] else if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}';
						songName.replace(".json","");
						if(PlayState.invertedChart) songName = songName + "-inverted";
						if(!FileSystem.exists('songLogs/${songName}/'))
							FileSystem.createDirectory('songLogs/${songName}/');
						File.saveContent('songLogs/${songName}/${curDate.getDate()}-${curDate.getMonth()}-${curDate.getFullYear()}_AT_${curDate.getHours()}-${curDate.getMinutes()}-${curDate.getSeconds()}.log',events);
						File.saveContent('songLogs/${songName}/${curDate.getTime()}.json',eventsjson);
					}catch(e){trace("Something went wrong when trying to output event log! " + e.message);}
				}
				// try{TitleState.saveScore(PlayState.accuracy);}catch(e){trace("e");}
			}

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; 
	}
	var shouldveLeft = false;
	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		PlayState.instance.persistentUpdate = true;
		if (shouldveLeft){
			Main.game.forceStateSwitch(new MainMenuState());

		}else{
			switch (PlayState.stateType)
			{
				case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
					

				default:FlxG.switchState(new FreeplayState());
			}
		}
		shouldveLeft = true;
		return;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.keys.pressed.ESCAPE){
			retMenu();
		}
		if(updateBF && PlayState.boyfriend != null){
			PlayState.boyfriend.update(elapsed);
		}
		if (ready){


			if (controls.ACCEPT)
			{
				retMenu();
			}

			if (FlxG.keys.justPressed.R){if(win){FlxG.resetState();}else{restart();}}
			if (FlxG.keys.justPressed.O && optionsisyes){
				SearchMenuState.doReset = false;
				OptionsMenu.lastState = PlayState.stateType + 10;
				FlxG.switchState(new OptionsMenu());
			}
		}else if (!shownResults){
			if(FlxG.keys.justPressed.ANY){
				PlayState.boyfriend.animation.finishCallback = null;
				finishNew();
			}
		}

	}
	override function draw(){

		if(updateBF && PlayState.boyfriend != null){
			PlayState.boyfriend.draw();
		}
		super.draw();

	}
	function restart()
	{
		ready = false;
		// FlxG.sound.music.stop();
		// FlxG.sound.play(Paths.music('gameOverEnd'));
		if(isError){
			FlxG.resetState();
			if (shouldveLeft){ // Error if the state hasn't changed and the user pressed r already
				MainMenuState.handleError("Caught softlock!");
			}
			shouldveLeft = true;
			return;
		}
		// Holyshit this is probably a bad idea but whatever
		// PlayState.instance.resetInterps();
		// Conductor.songPosition = 0;
		// Conductor.songPosition -= Conductor.crochet * 5;
		
		// PlayState.instance.persistentUpdate = true;
		// PlayState.instance.resetScore();
		// PlayState.songStarted = false;

		// PlayState.strumLineNotes = null;
		// PlayState.instance.generateSong();
		// PlayState.instance.startCountdown();
		// close();
		FlxG.resetState();
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}