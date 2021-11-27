package onlinemod;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;

import Section.SwagSection;

class OfflinePlayState extends PlayState
{
  var loadedVoices:FlxSound;
  var loadedInst:Sound;
  var loadingtext:FlxText;
  var shouldLoadJson:Bool = true;
  var stateType = 2;
  var shouldLoadSongs = true;
  public static var chartFile:String = "";
  function loadSongs(){

  	var voicesFile = "";
    var instFile = "";
    for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Inst.ogg']) {
    	if (FileSystem.exists('${Sys.getCwd()}/$i')){
    		instFile = i;
    	}
    }
    if (instFile == ""){MainMenuState.handleError('${PlayState.actualSongName} is missing a inst file!');}
    for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Voices.ogg']) {
    	if (FileSystem.exists('${Sys.getCwd()}/$i')){
    		voicesFile = i;
    	}
    }
    if (voicesFile != ""){loadedVoices = new FlxSound().loadEmbedded(Sound.fromFile(voicesFile));}
    trace('Loading $voicesFile, $instFile');
    
    loadedInst = Sound.fromFile(instFile);
  }
  function loadJSON(){
  	try{

  		if (!ChartingState.charting) PlayState.SONG = Song.parseJSONshit(File.getContent(chartFile));
  	}catch(e) MainMenuState.handleError('Error loading chart \'${chartFile}\': ${e.message}');
  }
  override function create()
  {
  	try{
	  	if (shouldLoadJson) loadJSON();
	    PlayState.SONG.player1 = FlxG.save.data.playerChar;
	    if (FlxG.save.data.charAuto && TitleState.retChar(PlayState.SONG.player2) != ""){ // Check is second player is a valid character
	    	PlayState.SONG.player2 = TitleState.retChar(PlayState.SONG.player2);
	    }else{
	    	PlayState.SONG.player2 = FlxG.save.data.opponent;
	    }
	    PlayState.stateType=stateType;
	    // var voicesFile = 'assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg'
	    // if (!FileSystem.exists('${FileSystem.exists(Sys.getCwd()}/assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg')){
	    // 	voicesFile = '${FileSystem.exists(Sys.getCwd()}/assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg';
	    // }
	    // var instFile = 'assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg'
	    // if (!FileSystem.exists('${FileSystem.exists(Sys.getCwd()}/assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg')){
	    // 	voicesFile = '${FileSystem.exists(Sys.getCwd()}/assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg';
	    // }
	    if (shouldLoadSongs) loadSongs();


	    super.create();


	    // Add XieneDev watermark
	    var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.1 - 50, FlxG.width, "XieneDev Battle Royale", 16);
			xieneDevWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			xieneDevWatermark.scrollFactor.set();
			add(xieneDevWatermark);
	    xieneDevWatermark.cameras = [camHUD];


	    FlxG.mouse.visible = false;
	    FlxG.autoPause = true;
	  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}
	}

  override function startSong(?alrLoaded:Bool = false)
  {
    if (shouldLoadJson) FlxG.sound.playMusic(loadedInst, 1, false);

    // We be good and actually just use an argument to not load the song instead of "pausing" the game
    super.startSong(true);
  }
  override function generateSong(?dataPath:String = "")
  {
  //   // I have to code the entire code over so that I can remove the offset thing
  //   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		if (PlayState.SONG.needsVoices)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();
    super.generateSong(dataPath);

  }
  // override function generateSong(dataPath:String)
  // {try{
  //   // I have to code the entire code over so that I can remove the offset thing
  //   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		// if (PlayState.SONG.needsVoices)
		// 	vocals = loadedVoices;
		// else
		// 	vocals = new FlxSound();

		// FlxG.sound.list.add(vocals);

		// notes = new FlxTypedGroup<Note>();
		// add(notes);

		// var noteData:Array<SwagSection>;

		// // NEW SHIT
		// noteData = songData.notes;

		// var playerCounter:Int = 0;

		// // Per song offset check
		// var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		// for (section in noteData)
		// {
		// 	var coolSection:Int = Std.int(section.lengthInSteps / 4);

		// 	for (songNotes in section.sectionNotes)
		// 	{

		// 		if(songNotes[1] == -1) continue;
		// 		var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
		// 		if (daStrumTime < 0)
		// 			daStrumTime = 0;
		// 		var daNoteData:Int = songNotes[1];

		// 		var gottaHitNote:Bool = section.mustHitSection;

		// 		if (songNotes[1] > 3)
		// 		{
		// 			gottaHitNote = !section.mustHitSection;
		// 		}

		// 		var oldNote:Note;
		// 		if (unspawnNotes.length > 0)
		// 			oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
		// 		else
		// 			oldNote = null;

		// 		var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,songNotes[3] == 1,songNotes,gottaHitNote);
		// 		swagNote.sustainLength = songNotes[2];
		// 		swagNote.scrollFactor.set(0, 0);

		// 		var susLength:Float = swagNote.sustainLength;

		// 		susLength = susLength / Conductor.stepCrochet;
		// 		unspawnNotes.push(swagNote);

		// 		for (susNote in 0...Math.floor(susLength))
		// 		{
		// 			oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

		// 			var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,songNotes[3] == 1,gottaHitNote);
		// 			sustainNote.scrollFactor.set();
		// 			unspawnNotes.push(sustainNote);

		// 			sustainNote.mustPress = gottaHitNote;

		// 			if (sustainNote.mustPress)
		// 			{
		// 				sustainNote.x += FlxG.width / 2; // general offset
		// 			}
		// 		}

		// 		swagNote.mustPress = gottaHitNote;

		// 		if (swagNote.mustPress)
		// 		{
		// 			swagNote.x += FlxG.width / 2; // general offset
		// 		}
		// 	}
		// 	daBeats += 1;
		// }

		// // trace(unspawnNotes.length);
		// // playerCounter += 1;

		// unspawnNotes.sort(sortByShit);

		// generatedMusic = true;
  //  }catch(e){MainMenuState.handleError('Caught "gensong" crash: ${e.message}');}}

  override function endSong()
  {
    canPause = false;
    FlxG.sound.music.onComplete = null;
  	if (ChartingState.charting){
  	    	FlxG.switchState(new ChartingState());return;}
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

    	super.openSubState(new FinishSubState(PlayState.boyfriend.getScreenPosition().x, PlayState.boyfriend.getScreenPosition().y,true));
  }
}


