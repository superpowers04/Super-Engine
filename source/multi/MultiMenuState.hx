package multi;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import openfl.media.Sound;
import flixel.math.FlxMath;
import Song;
import sys.io.File;
import sys.FileSystem;
import tjson.Json;
import flixel.system.FlxSound;

import flixel.tweens.FlxTween;

using StringTools;

class MultiMenuState extends onlinemod.OfflineMenuState
{
	var modes:Map<Int,Array<String>> = [];
	static var CATEGORYNAME:String = "-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-CATEGORY";
	var diffText:FlxText;
	var scoreText:FlxText;
	var selMode:Int = 0;
	var blockedFiles:Array<String> = ['picospeaker.json','dialogue-end.json','dialogue.json','_meta.json','meta.json','SE-OVERRIDES.json','config.json'];
	static var lastSel:Int = 1;
	static var lastSearch:String = "";
	public static var lastSong:String = ""; 
	var beetHit:Bool = false;

	var songNames:Array<String> = [];
	var nameSpaces:Array<String> = [];
	var shouldDraw:Bool = true;
	var inTween:FlxTween;
	var score:Int = 0;
	var interpScore:Int = 0;
	override function draw(){
		if(shouldDraw){
			super.draw();
		}else{
			grpSongs.members[curSelected].draw();
		}
	}
	override function beatHit(){
		if (voices != null && voices.playing && (voices.time > FlxG.sound.music.time + 20 || voices.time < FlxG.sound.music.time - 20))
		{
			voices.time = FlxG.sound.music.time;
			voices.play();
		}
		super.beatHit();
	}
	override function findButton(){
		super.findButton();
		changeDiff();
	}
	override function switchTo(nextState:FlxState):Bool{
		FlxG.autoPause = true;
		if(voices != null){
			voices.destroy();
			voices = null;

		}
		return super.switchTo(nextState);
	}
	override function create()
	{
		try{

		retAfter = false;
		SearchMenuState.doReset = true;
		dataDir = "mods/charts/";
		PlayState.scripts = [];
		bgColor = 0x00661E;
		super.create();
		diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
		diffText.font = CoolUtil.font;
		diffText.borderSize = 2;
		add(diffText);
		scoreText = new FlxText(FlxG.width * 0.7, 35, 0, "N/A", 24);
		scoreText.font = CoolUtil.font;
		scoreText.borderSize = 2;
		scoreText.screenCenter(X);
		add(scoreText);

		searchField.text = lastSearch;
		if(lastSearch != "") reloadList(true,lastSearch);

		lastSearch = "";
		changeSelection(lastSel);
		lastSel = 1;
		changeDiff();
		updateInfoText('Use shift to scroll faster; Shift+F10 to erase the score of the current chart. Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while in this menu. Found ${songs.length} songs.');
		}catch(e){MainMenuState.handleError(e,'Something went wrong in create; ${e.message}\n${e.stack}');
		}

	}
	override function onFocus() {
		shouldDraw = true;
		super.onFocus();
		bg.alpha = 0;
		inTween = FlxTween.tween(bg,{alpha:1},0.7);
	}
	override function onFocusLost(){
		shouldDraw = false;
		super.onFocusLost();
		if(inTween != null){
			inTween.cancel();
			inTween.destroy();
		}
	}
	function addListing(name:String,i:Int){
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
	}
	function addCategory(name:String,i:Int){
		songs[i] = name;
		modes[i] = [CATEGORYNAME];
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false,true);
		controlLabel.adjustAlpha = false;
		controlLabel.screenCenter(X);
		var blackBorder = new FlxSprite(-500,-10).makeGraphic((Std.int(FlxG.width * 2)),Std.int(controlLabel.height) + 20,FlxColor.BLACK);
		blackBorder.alpha = 0.35;
		// blackBorder.screenCenter(X);
		controlLabel.insert(0,blackBorder);
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.alpha = 1;
		grpSongs.add(controlLabel);
	}
	inline function isValidFile(file) {return (!blockedFiles.contains(file.toLowerCase()) && (StringTools.endsWith(file, '.json') || StringTools.endsWith(file, '.sm')));}
	override function reloadList(?reload=false,?search = ""){
		curSelected = 0;
		var _goToSong = 0;
		if(reload){grpSongs.clear();}

		songs = ["No Songs!"];
		songNames = ["Nothing"];
		modes = [0 => ["None"]];
		var i:Int = 0;

		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		if (FileSystem.exists(dataDir))
		{
			var dirs = orderList(FileSystem.readDirectory(dataDir));
			addCategory("charts folder",i);
			i++;
			for (directory in dirs)
			{
				if (search == "" || query.match(directory.toLowerCase())) // Handles searching
				{
					if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
						modes[i] = [];
						for (file in FileSystem.readDirectory(dataDir + directory))
						{
								if (isValidFile(file)){
									modes[i].push(file);
								}
						}
						if (modes[i][0] == null){ // No charts to load!
							modes[i][0] = "No charts for this song!";
						}
						songs[i] = dataDir + directory;
						songNames[i] =directory;

						addListing(directory,i);
						if(_goToSong == 0)_goToSong = i;
						i++;

					}
				}
			}
		}
		var _packCount:Int = 0;
		if (FileSystem.exists("mods/weeks"))
		{
			for (name in FileSystem.readDirectory("mods/weeks"))
			{

				var dataDir = "mods/weeks/" + name + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				var catMatch = query.match(name.toLowerCase());
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				addCategory(name + "(Week)",i);
				i++;
				_packCount++;
				var containsSong = false;
				for (directory in dirs)
				{
					if ((search == "" || catMatch || query.match(directory.toLowerCase())) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (isValidFile(file)){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}
							songs[i] = dataDir + directory;
							songNames[i] = directory;

							
							addListing(directory,i);
							nameSpaces[i] = dataDir;
							if(_goToSong == 0)_goToSong = i;
							containsSong = true;
							i++;
						}
					}
				}
				if(!containsSong){
					grpSongs.members[i - 1].color = FlxColor.RED;
				}
			}
		}
		if (FileSystem.exists("mods/packs"))
		{
			for (name in FileSystem.readDirectory("mods/packs"))
			{
				// dataDir = "mods/packs/" + dataDir + "/charts/";
				var catMatch = query.match(name.toLowerCase());
				var dataDir = "mods/packs/" + name + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				
				addCategory(name,i);
				
				i++;
				var containsSong = false;
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				for (directory in dirs)
				{
					if ((search == "" || catMatch || query.match(directory.toLowerCase())) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (isValidFile(file)){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}

							songs[i] = dataDir + directory;
							songNames[i] =directory;

							
							addListing(directory,i);
							containsSong = true;
							if(_goToSong == 0)_goToSong = i;
							nameSpaces[i] = dataDir;
							i++;
						}
					}
				}
				if(!containsSong){
					grpSongs.members[i - 1].color = FlxColor.RED;
				}
			}
		}
		// if(_packCount == 0){
		// 	addCategory("No packs or weeks to show",i);
		// 	grpSongs.members[i - 1].color = FlxColor.RED;
		// }
		if(reload && lastSel == 1)changeSelection(_goToSong);
		updateInfoText('Use shift to scroll faster; Shift+F7 to erase the score of the current chart. Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs');
	}
	// function checkSong(dataDir:String,directory:String){

	// }

	// public static function grabSongInfo(songName:String):Array<String>{ // Returns empty array if song is not found or invalid
	// 	var ret:Array<Dynamic> = [];
	// 	var query = new EReg((~/[-_ ]/g).replace(songName.toLowerCase(),'[-_ ]'),'i');
	// 	var modes = [];
	// 	var dataDir = "mods/charts/";
	// 	// This is pretty messy, but I don't believe regex's are possible without a for loop
	// 	if (FileSystem.exists(dataDir))
	// 	{
	// 		var dirs = orderList(FileSystem.readDirectory(dataDir));
	// 		for (directory in dirs)
	// 			{
	// 				if (query.match(directory.toLowerCase())) // Handles searching
	// 				{
	// 					if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
	// 						modes = [];
	// 						for (file in FileSystem.readDirectory(dataDir + directory))
	// 						{
	// 								if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
	// 									modes.push(file);
	// 								}
	// 						}
	// 						if (modes[0] == null){return [];}
	// 						ret[0] = dataDir + directory;
	// 						ret[1] = directory;
	// 						ret[2] = modes;
	// 						break; // Who the hell in their right mind would continue to loop
	// 					}
	// 				}
	// 			}
	// 	}
	// 	return ret;
	// }

	public static function gotoSong(?selSong:String = "",?songJSON:String = "",?songName:String = "",?charting:Bool = false,?blankFile:Bool = false,?voicesFile:String="",?instFile:String=""){
			try{
				if(selSong == "" || songJSON == "" || songName == ""){
					throw("No song name provided!");
				}
				#if windows
				selSong = selSong.replace("\\","/"); // Who decided this was a good idea?
				#end
				onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.songDiff = songJSON;
				PlayState.storyDifficulty = switch(songJSON){case '${songName}-easy.json': 0; case '${songName}-hard.json': 2; default: 1;};
				PlayState.actualSongName = songJSON;
				onlinemod.OfflinePlayState.voicesFile = '';
				PlayState.hsBrTools = new HSBrTools('${selSong}');
				PlayState.scripts = [];


				if(instFile == "" ){
					if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
						onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
					}else{
						onlinemod.OfflinePlayState.instFile = '${selSong}/Inst.ogg';
					}
				} else onlinemod.OfflinePlayState.instFile = instFile;
				if(voicesFile == ""){
					if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
						onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
					}else if(FileSystem.exists('${selSong}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${selSong}/Voices.ogg';}
				}else{
					onlinemod.OfflinePlayState.voicesFile = voicesFile;
				}
				for (file in FileSystem.readDirectory(selSong)) {
					if((file.endsWith(".hscript") || file.endsWith(".hx")) && !FileSystem.isDirectory(file)){
						PlayState.scripts.push('${selSong}/$file');
					}
					
				}
				if(FlxG.save.data.packScripts && (selSong.contains("mods/packs") || selSong.contains("mods/weeks"))){
					var packDirL = selSong.split("/"); // Holy shit this is shit but using substr won't work for some reason :<
					if(packDirL[packDirL.length] == "")packDirL.pop(); // There might be an extra slash at the end, remove it
					packDirL.pop();
					if(packDirL.contains("packs")) packDirL.pop(); // Packs have a sub charts folder, weeks do not

					var packDir = packDirL.join("/");
					if(FileSystem.exists('${packDir}/scripts') && FileSystem.isDirectory('${packDir}/scripts')){

						for (file in FileSystem.readDirectory('${packDir}/scripts')) {
							if((file.endsWith(".hscript") || file.endsWith(".hx")) && !FileSystem.isDirectory('${packDir}/scripts/$file')){
								PlayState.scripts.push('${packDir}/scripts/$file');
							}
						}
					}
				}
				
				// if (FileSystem.exists('${selSong}/script.hscript')) {
				// 	trace("Song has script!");
				// 	MultiPlayState.scriptLoc = '${selSong}/script.hscript';
					
				// }else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				PlayState.nameSpace = selSong;
				PlayState.stateType = 4;
				FlxG.sound.music.fadeOut(0.4);
				LoadingState.loadAndSwitchState(new MultiPlayState(charting));
			}catch(e){MainMenuState.handleError(e,'Error while loading chart ${e.message}');
			}
	}

	function selSong(sel:Int = 0,charting:Bool = false){
		if (songs[sel] == "No Songs!" || modes[sel][selMode] == CATEGORYNAME){ // Actually check if the song is a song, if not then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		if(charting){
			var songLoc = songs[sel];
			var chart = modes[sel][selMode];
			var songName = songNames[sel];
			if(modes[curSelected][selMode] == "No charts for this song!"){
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${songName}.json';
				var song = cast Song.getEmptySong();
				song.song = songName;
				File.saveContent(onlinemod.OfflinePlayState.chartFile,Json.stringify({song:song}));
				
				reloadList(true,searchField.text);
				curSelected = sel;
				changeSelection();
				selSong(sel,true);
				// showTempmessage('Generated blank chart for $songName');
				return;


			}else{
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart}';
				PlayState.SONG = Song.parseJSONshit(File.getContent(onlinemod.OfflinePlayState.chartFile),true);
			}
			if (FileSystem.exists('${songLoc}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${songLoc}/Voices.ogg';}
			PlayState.hsBrTools = new HSBrTools('${songLoc}');
			if (FileSystem.exists('${songLoc}/script.hscript')) {
				trace("Song has script!");
				MultiPlayState.scriptLoc = '${songLoc}/script.hscript';
				
			}else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
			onlinemod.OfflinePlayState.instFile = '${songLoc}/Inst.ogg';
			if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
				onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
			}
			if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
				onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
			}
			PlayState.stateType = 4;
			PlayState.SONG.needsVoices =  onlinemod.OfflinePlayState.voicesFile != "";
			ChartingState.gotoCharter();
			// LoadingState.loadAndSwitchState(new charting.ForeverChartEditor());
			return;
		}
		if (modes[sel][selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		onlinemod.OfflinePlayState.nameSpace = "";
		if(nameSpaces[sel] != null){
			onlinemod.OfflinePlayState.nameSpace = nameSpaces[sel];
		}
		lastSel = sel;
		lastSearch = searchField.text;
		lastSong = songs[sel] + modes[sel][selMode] + songNames[sel];
		gotoSong(songs[sel],modes[sel][selMode],songNames[sel]);
	}

	override function select(sel:Int = 0){
			selSong(sel,false);

	}	

	var curPlaying = "";
	var voices:FlxSound;
	var playCount:Int = 0;
	var curVol:Float = 1;
	var SCORETXT:String = "";

	override function update(e){
		super.update(e);
		// if(interpScore != score){
		// 	if(score == 0){
		// 		scoreText.text = 'N/A';
		// 		scoreText.screenCenter(X);

		// 	}else{

		// 		if((score - interpScore) < 10){
		// 			interpScore = score;
		// 		}else{
		// 			interpScore = Std.int(FlxMath.lerp(interpScore,score,0.4));
		// 		}
		// 		scoreText.text = '${interpScore}${SCORETXT}';
		// 		scoreText.screenCenter(X);
		// 	}
		// }
		// Fucking flixel
		if(voices != null && curVol != FlxG.sound.volume){ // Don't change volume unless volume changes
			curVol = FlxG.sound.volume;
			voices.volume = FlxG.save.data.voicesVol * FlxG.sound.volume;
		}
	}
	override function handleInput(){
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
			{
				ret();
			}
			if(songs.length == 0) return;
			if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} 
			else if (controls.UP_P || (controls.UP && grpSongs.members[curSelected].y > FlxG.height * 0.46 && grpSongs.members[curSelected].y < FlxG.height * 0.50) ){changeSelection(-1);}
			if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} 
			else if (controls.DOWN_P || (controls.DOWN  && grpSongs.members[curSelected].y > FlxG.height * 0.50 && grpSongs.members[curSelected].y < FlxG.height * 0.56) ){changeSelection(1);}
			extraKeys();
			if (controls.ACCEPT && songs.length > 0)
			{
				select(curSelected);
			}
	}

	override function extraKeys(){
		if(controls.LEFT_P){changeDiff(-1);}
		if(controls.RIGHT_P){changeDiff(1);}
		if (FlxG.keys.justPressed.SEVEN && songs.length > 0 && FlxG.save.data.animDebug)
		{
			selSong(curSelected,true);
		}
		if(!FlxG.mouse.overlaps(blackBorder) && (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)){
			for (i in -2 ... 2) {
				if(grpSongs.members[curSelected + i] != null && FlxG.mouse.overlaps(grpSongs.members[curSelected + i])){
					selSong(curSelected + i,FlxG.mouse.justPressedRight);
				}
			}
		}
		if(FlxG.mouse.justPressedMiddle){
			changeDiff(1);
		}
		if(FlxG.mouse.wheel != 0){
			var move = -FlxG.mouse.wheel;
			changeSelection(Std.int(move));
		}
		if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F7){
			Highscore.setScore(curScoreName,0,['N/A']);
			changeDiff();
		}
		if(FlxG.keys.justPressed.CONTROL){
				FlxG.autoPause = false;
				playCount++;
				if(curPlaying != songs[curSelected]){
					curPlaying = songs[curSelected];
					if(voices != null){
						voices.stop();
					}
					voices = null;
					FlxG.sound.music.stop();
					FlxG.sound.playMusic(Sound.fromFile('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
					if (FlxG.sound.music.playing){
						if(modes[curSelected][selMode] != "No charts for this song!" && FileSystem.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
							try{

								var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
								if(e.bpm > 0){
									Conductor.changeBPM(e.bpm);
								}
							}catch(e){
								showTempmessage("Unable to get BPM from chart automatically. BPM will be out of sync",0xee0011);
							}
						}

					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				}
				if(curPlaying == songs[curSelected]){
					try{

						if(voices == null){
							voices = new FlxSound();
							voices.loadEmbedded(Sound.fromFile('${songs[curSelected]}/Voices.ogg'),true);
							voices.volume = FlxG.save.data.voicesVol;
							voices.play(FlxG.sound.music.time);
							FlxG.sound.list.add(voices);

						}else{
							if(!voices.playing){
								voices.play(FlxG.sound.music.time);
							}else
								voices.stop();
						}
					}catch(e){
						showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
					}
				}
				if(playCount > 2){
					playCount = 0;
					openfl.system.System.gc();
				}
			}
		super.extraKeys();
	}
	var twee:FlxTween;
	var curScoreName:String = "";
	function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
		if (songs.length == 0 || songs[curSelected] == null || songs[curSelected] == "") {
			diffText.text = 'No song selected';

			return;
		}
		if(twee != null)twee.cancel();
		diffText.scale.set(1.2,1.2);
		twee = FlxTween.tween(diffText.scale,{x:1,y:1},(30 / Conductor.bpm));
		lastSong = modes[curSelected][selMode] + songNames[curSelected];

		if (forcedInt == -100) selMode += change; else selMode = forcedInt;
		if (selMode >= modes[curSelected].length) selMode = 0;
		if (selMode < 0) selMode = modes[curSelected].length - 1;
		// var e:Dynamic = TitleState.getScore(4);
		// if(e != null && e != 0) diffText.text = '< ' + e + '%(' + Ratings.getLetterRankFromAcc(e) + ') - ' + modes[curSelected][selMode] + ' >';
		// else 
		diffText.text = (if(modes[curSelected][selMode - 1 ] != null ) '< ' else '|  ') + (if(modes[curSelected][selMode] == CATEGORYNAME) songs[curSelected] else modes[curSelected][selMode]) + (if(modes[curSelected][selMode + 1 ] != null) ' >' else '  |');
		// diffText.centerOffsets();
		diffText.screenCenter(X);
		var name = '${songs[curSelected]}-${modes[curSelected][selMode]}${(if(QuickOptionsSubState.getSetting("Inverted chart")) "-inverted" else "")}';
		curScoreName = "";
		if(modes[curSelected][selMode] == null || modes[curSelected][selMode] == CATEGORYNAME || !Highscore.songScores.exists(name)){
			// score = 0;
			scoreText.text = "N/A";
			SCORETXT = "N/A";
			scoreText.screenCenter(X);
		}else{
			// var _Arr:Array<Dynamic> = Highscore.songScores.getArr(name);
			// if(Std.isOfType(_Arr[0],Int)){
			// 	score = _Arr.shift();
			// }else{
			// 	score = -1;
			// }
			// SCORETXT = ', ${_Arr.join(", ")}';
			curScoreName = name;
			scoreText.text = (Highscore.songScores.getArr(curScoreName)).join(", ");
			scoreText.screenCenter(X);
			// score = Highscore.getScoreUnformatted();
		}
		// diffText.x = (FlxG.width) - 20 - diffText.width;

	}

	override function changeSelection(change:Int = 0)
	{
		var looped = 0;
		// while(modes[curSelected + change] != null && modes[curSelected + change][0] == CATEGORYNAME && looped < 200){ // If this loops more than 200 times, break to prevent crashes
		// 	if(change > 0) change+=1;
		// 	if(change < 0) change-=1;
		// 	if(curSelected + change > songs.length){
		// 		curSelected = 0;
		// 		change = 0;
		// 	}
		// 	looped++;
		// }
		// if(looped > 199){
		// 	grpSongs.clear();
		// 	change = 0;
		// 	curSelected = 0;
		// 	songs = ["No Songs!"];
		// 	songNames = ["Nothing"];
		// 	modes = [0 => ["None"]];
		// }

		super.changeSelection(change);
		if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);

	}	
	public static function fileDrop(file:String){
		try{
			var voices = "";
			var inst = "";
			var dir = file.substr(0,file.lastIndexOf("/"));
			var fileThing = file.substr(0,file.lastIndexOf("-")) + ".json"; // Difficulty detection
			trace(fileThing);
			if(FileSystem.exists(fileThing)){
				file = fileThing;
			}
			var json = file.substr(file.lastIndexOf("/"));
			var name = json.substr(0,json.lastIndexOf("."));
			if(file.contains("assets/")){
				var assets = file.substr(0,file.lastIndexOf("assets/"));
				trace('${assets}assets/songs/${name}/Inst.ogg');
				// Attempt 1 at finding the song files
				if(FileSystem.exists('${assets}assets/songs/${name}/Inst.ogg')){ 
					inst = '${assets}assets/songs/${name}/Inst.ogg';
				}
				if(inst == "" && FileSystem.exists('${assets}assets/music/${name}-Inst.ogg')){
					inst = '${assets}assets/music/${name}-Inst.ogg';
				}
				if(FileSystem.exists('${assets}assets/songs/${name}/Voices.ogg')){
					voices = '${assets}assets/songs/${name}/Voices.ogg';
				}
				if(voices == "" && FileSystem.exists('${assets}assets/music/${name}-Voices.ogg')){
					voices = '${assets}assets/music/${name}-Voices.ogg';
				}
				if(inst == ""){ // Check more places
					var name:Dynamic = cast Json.parse(file);
					var songName:String = "";
					if(name.song != null && Std.isOfType(name.song,String)){
						songName = cast name.song;
					}else if(name.song != null && name.song.song != null && Std.isOfType(name.song.song,String)){
						songName = cast name.song.song;
					}
					if(songName != null && songName != ""){ // Try using the chart name maybe?
						if(FileSystem.exists('${assets}assets/songs/${name}/Inst.ogg')){
							inst = '${assets}assets/songs/${name}/Inst.ogg';
						}
						if(inst == "" && FileSystem.exists('${assets}assets/music/${name}-Inst.ogg')){
							inst = '${assets}assets/songs/${name}-Inst.ogg';
						}
						if(voices == "" && FileSystem.exists('${assets}assets/songs/${name}/Voices.ogg')){
							voices = '${assets}assets/songs/${name}/Voices.ogg';
						}
						if(voices == "" && FileSystem.exists('${assets}assets/music/${name}-Voices.ogg')){
							voices = '${assets}assets/songs/${name}-Voices.ogg';
						}
					}
					if(inst == ""){ // Try without the extra - part, some songs only have a hard variant
						var name = fileThing.substr(fileThing.lastIndexOf("/"),fileThing.lastIndexOf("."));
						if(FileSystem.exists('${assets}assets/songs/${name}/Inst.ogg')){
							inst = '${assets}assets/songs/${name}/Inst.ogg';
						}
						if(inst == "" && FileSystem.exists('${assets}assets/music/${name}-Inst.ogg')){
							inst = '${assets}assets/music/${name}-Inst.ogg';
						}
						if(voices == "" && FileSystem.exists('${assets}assets/songs/${name}/Voices.ogg')){
							voices = '${assets}assets/songs/${name}/Voices.ogg';
						}
						if(voices == "" && FileSystem.exists('${assets}assets/music/${name}-Voices.ogg')){
							voices = '${assets}assets/music/${name}-Voices.ogg';
						}
					}

				}
			}
			if(inst == ""){
				MusicBeatState.instance.showTempmessage("Unable to load chart as there is no Inst!",FlxColor.RED);
				return;
			}
			gotoSong(dir,
					json,
					name,
					voices,
					inst
			);

		}catch(e){MainMenuState.handleError(e,'Unable to load dragdrop/argument song: ${e.message}');
		}
	}
	override function goOptions(){
			lastSel = curSelected;
			lastSearch = searchField.text;
			FlxG.mouse.visible = false;
			OptionsMenu.lastState = 4;
			FlxG.switchState(new OptionsMenu());
	}
}
typedef FuckingSong = {
	var song:Song;
}
