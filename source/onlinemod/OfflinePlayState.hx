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
import sys.thread.Lock;
import sys.thread.Thread;


import Section.SwagSection;

using StringTools;

class OfflinePlayState extends PlayState
{
	public static var instanc:OfflinePlayState;
  // public var loadedVoices:FlxSound;
  public static var loadedVoices_:FlxSound;
  public var loadedVoices(get,set):FlxSound;
  public function get_loadedVoices(){
	return loadedVoices_;
  }
  public function set_loadedVoices(vari){
	return loadedVoices_ = vari;
  }
  public static var loadedInst_:Sound;
  // public var loadedInst:Sound;
  public var loadedInst(get,set):Sound;
  public function get_loadedInst(){
	return loadedInst_;
  }
  public function set_loadedInst(vari){
	return loadedInst_ = vari;
  }
  var loadingtext:FlxText;
  var shouldLoadJson:Bool = true;
  var stateType = 2;
  var shouldLoadSongs = true;
	public static var voicesFile = "";
  public static var instFile = "";
  public static var lastInstFile = "";
  public static var lastVoicesFile = "";
  public static var chartFile:String = "";
  public static var nameSpace:String = "";
  public static var stateNames:Array<String> = ["","-freep","-Offl","","-Multi","-OSU","-Story","","",""];
  var willChart:Bool = false;
  override public function new(?charting:Bool = false){
	willChart = charting;
	super();
  }

  function loadSongs(){
  		LoadingScreen.loadingText = "Loading music";
		if(lastVoicesFile != voicesFile && loadedVoices != null){
			loadedVoices.destroy();
		}
		#if(target.threaded)
		var lock = new Lock();
		sys.thread.Thread.create(() -> { // Offload to another thread for faster loading
		#end
			if(!(lastVoicesFile == voicesFile && loadedVoices != null)){
				if(voicesFile == ""){
					for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Voices.ogg']) {
						if (FileSystem.exists('${Sys.getCwd()}/$i')){
							voicesFile = i;
						}
					}
				}
				if(voicesFile != ""){loadedVoices = SELoader.loadFlxSound(voicesFile);}
				if(voicesFile == "" && PlayState.SONG != null){
					loadedVoices =  new FlxSound();
					PlayState.SONG.needsVoices = false;
				}
				if(loadedVoices.length < 1){
					trace('Voices.ogg didn\'t load properly. Try converting to MP3 and then into OGG Vorbis');
				}

			}
		#if(target.threaded)
			lock.release();
		});
		#end
			if(!(lastInstFile == instFile && loadedInst != null)){ // This doesn't need to be threaded
				if(instFile == ""){

					for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Inst.ogg']) {
						if (FileSystem.exists('${Sys.getCwd()}/$i')){
							instFile = i;
						}
					}
					if (instFile == ""){MainMenuState.handleError('${PlayState.actualSongName} is missing a inst file!');}

				}
				loadedInst = SELoader.loadSound(instFile);
			}
		#if(target.threaded)
		lock.wait();
		#end
		if(loadedVoices != null)loadedVoices.time = 0;

		lastInstFile = instFile;
		lastVoicesFile = voicesFile;
		loadedVoices.persist = true;
	trace('Loading $voicesFile, $instFile');
	
  }
  override function destroy(){
	if(loadedVoices != null){loadedVoices.pause();loadedVoices.time = 0;}
	super.destroy();
  }
  function loadJSON(){
	try{

		if (!ChartingState.charting) {
				if(chartFile.endsWith(".sm")){
					PlayState.SONG = smTools.SMFile.loadFile(chartFile).convertToFNF();
				}else{
					PlayState.SONG = Song.parseJSONshit(File.getContent(chartFile));

				}
				// if(nameSpace != ""){
				// 	if(TitleState.retChar(nameSpace + "|" + PlayState.player2) != null){
				// 		PlayState.player2 = nameSpace + "|" + PlayState.player2;
				// 	}
				// 	if(TitleState.retChar(nameSpace + "|" + PlayState.SONG.player1) != null){
				// 		PlayState.player1 = nameSpace + "|" + PlayState.player1;
				// 	}
				
				// }
		}
		// var e = chartFile.substr(0,chartFile.lastIndexOf('/') + "/SE-OVERRIDES.json";
		// if(FileSystem.exists(e)){
		// 	var overrides:SwagSong = 
		// }
	}catch(e) MainMenuState.handleError('Error loading chart \'${chartFile}\': ${e.message}');
  }
  override function create()
  {
	try{
		instanc = this;
		if (shouldLoadJson) loadJSON();
		// PlayState.player1 = FlxG.save.data.playerChar;
		// if ((FlxG.save.data.charAuto) && TitleState.retChar(PlayState.player2) != ""){ // Check is second player is a valid character
		// 	PlayState.player2 = TitleState.retChar(PlayState.player2);
		// }else{
		// 	PlayState.player2 = FlxG.save.data.opponent;
		// }
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

		var oldScripts:Bool = false;
		if(willChart){ // Loading scripts is redundant when we're just going to go into charting state
			oldScripts = QuickOptionsSubState.getSetting("Song hscripts");
			QuickOptionsSubState.setSetting("Song hscripts",false);
		}
		super.create();


		// Add XieneDev watermark
		var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.1 - 50, FlxG.width, "SuperEngine" + stateNames[stateType] + " " + MainMenuState.ver, 16);
			xieneDevWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			xieneDevWatermark.scrollFactor.set();
			add(xieneDevWatermark);
		xieneDevWatermark.cameras = [camHUD];


		FlxG.mouse.visible = false;
		FlxG.autoPause = true;
		if(willChart){
			QuickOptionsSubState.setSetting("Song hscripts",oldScripts);
			FlxG.switchState(new ChartingState());
		}
	  }catch(e){MainMenuState.handleError(e,'Caught "create" crash: ${e.message}');}
	}
override function startCountdown(){
	if(shouldLoadJson) FlxG.sound.playMusic(loadedInst, 1, false);
	super.startCountdown();
}
  override function generateSong(?dataPath:String = "")
  {
  //   // I have to code the entire code over so that I can remove the offset thing
  //   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		if (PlayState.SONG.needsVoices && loadedVoices.length > Math.max(4000,loadedInst.length - 20000) && loadedVoices.length < loadedInst.length + 10000)
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
	if(PlayState.isStoryMode){
		super.endSong();
	}else{

		canPause = false;
		FlxG.sound.music.onComplete = null;
		if (ChartingState.charting){FlxG.switchState(new ChartingState());return;}
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			super.openSubState(new FinishSubState(PlayState.boyfriend.getScreenPosition().x, PlayState.boyfriend.getScreenPosition().y,true));
	}
  }
}


