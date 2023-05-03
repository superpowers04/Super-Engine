package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
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
import openfl.media.Sound;

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
	public var readyTimer:Float = 0;
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
	public function new(x:Float, y:Float,?won = true,?error:String = "",force:Bool = false)
	{
		instance = this;
		super();
		endingMusic = null;
		if (error != ""){
			isError = true;
			errorMsg = error;
			won = false;
			// PlayState.instance.paused = true;
		}
		if(force){
			FlxG.state.persistentUpdate = false;
			FlxG.sound.pause();
			PlayState.instance.generatedMusic = PlayState.instance.handleTimes = PlayState.instance.acceptInput = false;
			super();
			finishNew("FORCEDMOMENT.MP4efdhseuifghbehu");
			return;
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
		
		PlayState.instance.generatedMusic = PlayState.instance.handleTimes = PlayState.instance.acceptInput = false;
		
		var dad = PlayState.dad;
		var boyfriend = PlayState.boyfriend;
		var curAnim:String = PlayState.boyfriend.animName;

		// Conductor.changeBPM(70);
		FlxG.cameras.setDefaultDrawTarget(PlayState.instance.camGame,true);


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
		var bfAnims = [];
		if(!isError){
			if(win){
				bfAnims = ['win','hey','singUP'];
				if (dad.curCharacter == FlxG.save.data.gfChar) dad.playAnim('cheer',true); else {dad.playAnimAvailable(['lose'],true);}
				PlayState.gf.playAnim('cheer',true);
			}else{
				// boyfriend.playAnim('singDOWNmiss');
				// boyfriend.playAnim('lose');

				// dad.playAnim("hey",true);
				// dad.playAnim("win",true);
				bfAnims = ['lose'];
				dad.playAnimAvailable(['win','hey'],true);
				if (dad.curCharacter == FlxG.save.data.gfChar) dad.playAnim('sad',true); else dad.playAnim("hey",true);
				PlayState.gf.playAnim('sad',true);
			}
		}

		// if(fadeOut){
		// 	FlxTween.tween(PlayState.instance.camGame,{alpha:0},0.5);
		// 	// FlxTween.tween(FlxG.boyfriend,{x:FlxG.width - (boyfriend.width * 0.5),y:FlxG.height - (boyfriend.height * 0.5)},0.5);
		// 	PlayState.instance.camTOP.target = boyfriend;
		// 	boyfriend.cameras = [PlayState.instance.camTOP];
		// }
		if(autoEnd){

			// FlxG.camera.zoom = 1;
			// PlayState.instance.camHUD.zoom = 1;

			if(boyfriend.playAnimAvailable(bfAnims,true) && !isError) boyfriend.animation.finishCallback = this.finishNew; else finishNew();
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
	public var contText:FlxText;
	inline function canSaveScore(){
		return win && !PlayState.instance.hasDied && !ChartingState.charting && PlayState.instance.canSaveScore;
	}
	public function saveScore(forced:Bool = false):Bool{

		if(canSaveScore()){
			return (Highscore.setScore('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart) "-inverted" else "")}',PlayState.songScore,[PlayState.songScore,'${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%',Ratings.GenerateLetterRank(PlayState.accuracy)],forced));
		}
		// if(forced){
		// 	if(!win || PlayState.instance.hasDied){showTempmessage("",FlxColor.RED);}
		// }
		return false;
	}
	@:keep inline public function getScore(forced:Bool = false):Int{

			return (Highscore.getScoreUnformatted('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart) "-inverted" else "")}'));
	}
	public function finishNew(?name:String = ""){
			// FlxG.mouse.visible = true;
			// var timer = new FlxTimer().start(1,function(e:FlxTimer){FinishSubState.instance.ready=true;FlxTween.tween(FinishSubState.instance.contText,{alpha:1},0.5);});
			Conductor.changeBPM(70);
			if(name != "FORCEDMOMENT.MP4efdhseuifghbehu"){

				FlxG.camera.alpha = PlayState.instance.camHUD.alpha = 1;
				FlxG.camera.visible = PlayState.instance.camHUD.visible  = PlayState.instance.camTOP.visible = true;
				FlxG.camera.zoom = PlayState.instance.camTOP.zoom = PlayState.instance.camHUD.zoom = 1;
				// FlxG.camera.zoom = PlayState.instance.defaultCamZoom;
				PlayState.instance.generatedMusic = false;
				var camPos = PlayState.instance.getDefaultCamPos();
				// PlayState.instance.camFollow.setPosition(camPos[0],camPos[1]);
				PlayState.instance.moveCamera = false;
				PlayState.instance.camGame.scroll.x = camPos[0];
				PlayState.instance.camGame.scroll.y = camPos[1];
				FlxG.state.persistentUpdate = !isError && !pauseGame;
				if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dad.animation.finishCallback = null;
				updateBF = false;
			}
			cam = new FlxCamera();
			FlxG.cameras.add(cam);
			FlxG.cameras.setDefaultDrawTarget(cam,true);
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; 
				// ready = true;
			pauseGame = true;
			autoEnd = true;
			FlxG.sound.pause();

			// if(!win)FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
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
			if(isError){
				// ready = false;
				var finishedText:FlxText = new FlxText(20,-55,0, "Error caught!" );
				finishedText.size = 32;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.RED;
				finishedText.scrollFactor.set();
				finishedText.screenCenter(X);
				var errText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,150,0,'Error Message:\n${errorMsg}');
				errText.size = 20;
				errText.wordWrap = true;
				errText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				errText.color = FlxColor.WHITE;
				errText.scrollFactor.set();
				errText.fieldWidth = FlxG.width - errText.x;
				errText.screenCenter(X);
				var _errText_X = errText.x;
				errText.x = FlxG.width;
				contText = new FlxText(FlxG.width * 0.5,FlxG.height + 100,0,
				#if android
					'Tap the left of the screen to exit or the right of the screen to restart'
				#else
					'Press ENTER to exit, R to reload or O to open options.'
				#end );
				contText.size = 24;
				// contText.x -= contText.width * 0.5;
				contText.screenCenter(X);
				contText.alpha = 0.3;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				var reportText = new FlxText(0,FlxG.height - 180,0,'Please report this to the developer of the script/chart listed above');
				reportText.size = 24;
				// reportText.x -= contText.width * 0.5;
				reportText.screenCenter(X);
				var rep_x = reportText.x;
				reportText.x = FlxG.width;
				reportText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);

				// contText.alignment = CENTER;
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(errText, {x:_errText_X},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(reportText, {x:rep_x},0.5,{ease: FlxEase.expoInOut});
				add(bg);
				add(finishedText);
				add(errText);
				add(contText);
				add(reportText);
				optionsisyes = true;
				
			}else{

				var finishedText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-55,0, (if(PlayState.isStoryMode) "Week" else "Song") + " " + (if(win) "Won!" else "Failed...") );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.WHITE;
				finishedText.scrollFactor.set();
				var _oldScore = getScore();
				var savedScore = saveScore();
				if(savedScore){
					finishedText.text += " | New Personal Best!";
				}


				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,(if(PlayState.instance.botPlay) "Botplay " else "") + (!PlayState.isStoryMode ? 'Song/Chart' : "Week") + ':\n'
						+'\nSicks - ${PlayState.sicks}'
						+'\nGoods - ${PlayState.goods}'
						+'\nBads - ${PlayState.bads}'
						+'\nShits - ${PlayState.shits}'
						+'\nGhost Taps - ${PlayState.ghostTaps}'
						+'\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})'
						+'\nMisses${if(FlxG.save.data.ghost) "" else " + Ghost Taps"}${if(FlxG.save.data.shittyMiss) ' + Shits' else ''}${if(FlxG.save.data.badMiss) ' + Bads' else ''}${if(FlxG.save.data.goodMiss) ' + Goods' else ''}: ${PlayState.misses}'
						+'\n\nScore: ${if(savedScore) '${_oldScore} > ' else ""}${PlayState.songScore}' // ' shitty haxe syntax highlighting strikes again :skull:
						+'\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%'
						+'\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}\n');
				comboText.size = 28;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				var settingsText:FlxText = new FlxText(comboText.width * 1.10 + FlxG.save.data.guiGap,-30,0,
				(if(PlayState.isStoryMode) StoryMenuState.weekNames[StoryMenuState.curWeek] else if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
				
				+'\n\nSettings:'
				+'\n\n Able To Save Score: ${canSaveScore()}'
				// +'\n Downscroll: ${FlxG.save.data.downscroll}'
				+'\n Ghost Tapping: ${FlxG.save.data.ghost}'
				+'\n Practice: ${FlxG.save.data.practiceMode}${if(PlayState.instance.hasDied)' - Score not saved' else ''}'
				+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count:${PlayState.instance.interpCount}' : "")
				+'\n Safe Frames: ${FlxG.save.data.frames}' 
				+'\n HitWindows: ${Ratings.ratingMS("sick")},${Ratings.ratingMS("good")},${Ratings.ratingMS("bad")},${Ratings.ratingMS("shit")} MS'
				+'\n Input Engine: ${PlayState.inputEngineName}, V${MainMenuState.ver}'
				+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
				+'\n'
				);
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				contText = new FlxText(FlxG.width - FlxG.save.data.guiGap,FlxG.height + 100,0,
				#if android
					'Tap the left of the screen to exit or the right of the screen to restart'
				#else
				'Press ENTER to continue or R to restart.'
				#end );
				
				contText.size = 28;
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.x -= contText.width;
				contText.scrollFactor.set();
				contText.alpha = 0.3;
				// var chartInfoText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${songName}');
				// chartInfoText.size = 16;
				// chartInfoText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
				// chartInfoText.color = FlxColor.WHITE;
				// chartInfoText.scrollFactor.set();
				

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
							ver:MainMenuState.ver
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
						if(!SELoader.exists("songLogs/"))
							SELoader.createDirectory("songLogs/");
						var curDate = Date.now();
						var songName = if(PlayState.isStoryMode) StoryMenuState.weekNames[StoryMenuState.curWeek] else if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}';
						songName.replace(".json","");
						if(PlayState.invertedChart || QuickOptionsSubState.getSetting('Inverted Chart')) songName = songName + "-inverted";
						if(!SELoader.exists('songLogs/${songName}/'))
							SELoader.createDirectory('songLogs/${songName}/');
						SELoader.saveContent('songLogs/${songName}/${curDate.getDate()}-${curDate.getMonth()}-${curDate.getFullYear()}_AT_${curDate.getHours()}-${curDate.getMinutes()}-${curDate.getSeconds()}.log',events);
						SELoader.saveContent('songLogs/${songName}/${curDate.getTime()}.json',eventsjson);
					}catch(e){trace("Something went wrong when trying to output event log! " + e.message);}
				}
				// try{TitleState.saveScore(PlayState.accuracy);}catch(e){trace("e");}
			}



	}
	var shouldveLeft = false;
	function retMenu(){
		FlxTween.globalManager.clear();
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		if (shouldveLeft) {Main.game.forceStateSwitch(new MainMenuState());return;}
		while(MusicBeatState.lastClassList[MusicBeatState.lastClassList.length - 1] is PlayState ){
			MusicBeatState.lastClassList.pop();
		}
		var e = MusicBeatState.lastClassList.pop();
		if(e == null){
			e = MainMenuState;
		}
		FlxG.switchState(Type.createInstance(e,[]));
		// switch (PlayState.stateType)
		// {
		// 	case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
		// 	case 4:FlxG.switchState(new multi.MultiMenuState());
		// 	case 5:FlxG.switchState(new osu.OsuMenuState());
				

		// 	default:FlxG.switchState(new MainMenuState());
		// }
		shouldveLeft = true;
		// if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		// PlayState.actualSongName = ""; // Reset to prevent issues
		// PlayState.instance.persistentUpdate = true;
		// if (shouldveLeft){
		// 	Main.game.forceStateSwitch(new MainMenuState());

		// }else{
		// 	FlxTween.tween(FlxG.camera.scroll,{y:-100},0.2);
		// 	MusicBeatState.instance.goToLastClass();
		// 	// switch (PlayState.stateType)
		// 	// {
		// 	// 	case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
		// 	// 	case 4:FlxG.switchState(new multi.MultiMenuState());
		// 	// 	case 5:FlxG.switchState(new osu.OsuMenuState());
					

		// 	// 	default:FlxG.switchState(new FreeplayState());
		// 	// }
		// }
		// shouldveLeft = true;
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


			if (controls.ACCEPT){
				retMenu();
			}
			#if android
				if(FlxG.mouse.justPressed){
					trace(FlxG.mouse.screenX / FlxG.width);
					if((FlxG.mouse.screenX / FlxG.width) <= .5){
						retMenu();
					}else{
						if(win){FlxG.resetState();}else{restart();}
					}
				}
			#end

			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){saveScore(true);}
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
		}else{
			if(readyTimer > 2){
				ready=true;
				// FlxTween.tween(,{alpha:1},0.5);
			}
			readyTimer += elapsed;
			contText.alpha = readyTimer - 1;
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