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
import Discord.DiscordClient;

import flixel.tweens.FlxTween;

using StringTools;

class MultiMenuState extends onlinemod.OfflineMenuState
{
	var modes:Map<Int,Array<String>> = [];
	static inline var CATEGORYNAME:String = "-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-CATEGORY";
	var diffText:FlxText;
	var scoreText:FlxText;
	var selMode:Int = 0;
	var blockedFiles:Array<String> = ['events.json','picospeaker.json','dialogue-end.json','dialogue.json','_meta.json','meta.json','se-overrides.json','config.json'];
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
	var shouldVoicesPlay:Bool = false;
	override function draw(){
		if(shouldDraw){
			super.draw();
		}else{
			grpSongs.members[curSelected].draw();
		}
	}
	override function beatHit(){
		if (voices != null && shouldVoicesPlay && (!voices.playing || (voices.time > FlxG.sound.music.time + 20 || voices.time < FlxG.sound.music.time - 20)))
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
		scriptSubDirectory = "/multilist/";
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
		updateInfoText('Use shift to scroll faster; Shift+F10 to erase the score of the current chart. Press CTRL/Control to listen to inst/voices of song. Press again to toggle the voices. *Disables autopause while in this menu. Found ${songs.length} songs.');
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
	function addListing(name:String,i:Int):Alphabet{
		callInterp('addListing',[name,i]);
		if(cancelCurrentFunction) return null;
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		controlLabel.yOffset = 20;
		controlLabel.cutOff = 25;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0) controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
		callInterp('addListingAfter',[controlLabel,name,i]);
		return controlLabel;
	}
	function addCategory(name:String,i:Int):Alphabet{
		callInterp('addCategory',[name,i]);
		if(cancelCurrentFunction) return null;
		songs[i] = name;
		modes[i] = [CATEGORYNAME];
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false,true);
		controlLabel.adjustAlpha = false;
		controlLabel.screenCenter(X);
		// blackBorder.alpha = 0.35;
		// blackBorder.screenCenter(X);
		controlLabel.border.alpha = 0.35;
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.alpha = 1;
		// controlLabel.screenCentX = true;
		grpSongs.add(controlLabel);
		callInterp('addCategoryAfter',[controlLabel,name,i]);
		return controlLabel;
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
		callInterp('reloadList',[reload,search,query]);
		if(!cancelCurrentFunction){
			if (SELoader.exists(dataDir))
			{
				var dirs = orderList(SELoader.readDirectory(dataDir));
				addCategory("charts folder",i);
				i++;

				LoadingScreen.loadingText = 'Scanning mods/charts';
				for (directory in dirs)
				{
					if (search == "" || query.match(directory.toLowerCase())) // Handles searching
					{
						if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in orderList(SELoader.readDirectory(dataDir + directory)))
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
			if (SELoader.exists("mods/weeks"))
			{
				for (name in orderList(SELoader.readDirectory("mods/weeks")))
				{

					var dataDir = "mods/weeks/" + name + "/charts/";
					if(!SELoader.exists(dataDir)){continue;}
					var catMatch = query.match(name.toLowerCase());
					var dirs = orderList(SELoader.readDirectory(dataDir));
					addCategory(name + "(Week)",i);
					i++;
					_packCount++;
					var containsSong = false;
					LoadingScreen.loadingText = 'Scanning mods/weeks/$name';
					for (directory in dirs)
					{
						if ((search == "" || catMatch || query.match(directory.toLowerCase())) && SELoader.isDirectory('${dataDir}${directory}')) // Handles searching
						{
							if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
								modes[i] = [];
								for (file in orderList(SELoader.readDirectory(dataDir + directory)))
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
			var emptyCats:Array<String> = [];
			if (SELoader.exists("mods/packs"))
			{
				for (name in orderList(SELoader.readDirectory("mods/packs")))
				{
					// dataDir = "mods/packs/" + dataDir + "/charts/";
					var catMatch = query.match(name.toLowerCase());
					var dataDir = "mods/packs/" + name + "/charts/";
					if(!SELoader.exists(dataDir)){continue;}
					var containsSong = false;
					var dirs = orderList(SELoader.readDirectory(dataDir));
					LoadingScreen.loadingText = 'Scanning mods/packs/$name/charts/';
					for (directory in dirs)
					{
						if ((search == "" || catMatch || query.match(directory.toLowerCase())) && SELoader.isDirectory('${dataDir}${directory}')) // Handles searching
						{
							if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
								if(!containsSong){
									containsSong = true;
									addCategory(name,i);
									i++;
								}
								modes[i] = [];
								for (file in orderList(SELoader.readDirectory(dataDir + directory)))
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
								nameSpaces[i] = dataDir;
								i++;
							}
						}
					}
					if(!containsSong){
						// grpSongs.members[i - 1].color = FlxColor.RED;
						emptyCats.push(name);
					}
				}
			}
			while(emptyCats.length > 0){
				var e = emptyCats.shift();
				addCategory(e,i).color = FlxColor.RED;
				i++;
			}
		}
		// if(_packCount == 0){
		// 	addCategory("No packs or weeks to show",i);
		// 	grpSongs.members[i - 1].color = FlxColor.RED;
		// }
		if(reload && lastSel == 1) changeSelection(_goToSong);
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
				LoadingScreen.loadingText = "Setting up variables";
				onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.songDiff = songJSON;
				PlayState.storyDifficulty = (if(songJSON == '${songName}-easy.json') 0 else if(songJSON == '${songName}-easy.json') 2 else 1);
				PlayState.actualSongName = songJSON;
				onlinemod.OfflinePlayState.voicesFile = '';
				PlayState.hsBrToolsPath = selSong;
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
				LoadingScreen.loadingText = "Finding scripts";
				if(FlxG.save.data.packScripts && (selSong.contains("mods/packs") || selSong.contains("mods/weeks"))){
					var packDirL = selSong.split("/"); // Holy shit this is shit but using substr won't work for some reason :<
					if(packDirL[packDirL.length] == "")packDirL.pop(); // There might be an extra slash at the end, remove it
					packDirL.pop();
					if(packDirL.contains("packs")) packDirL.pop(); // Packs have a sub charts folder, weeks do not

					var packDir = packDirL.join("/");
					if(SELoader.exists('${packDir}/scripts') && SELoader.isDirectory('${packDir}/scripts')){

						for (file in SELoader.readDirectory('${packDir}/scripts')) {
							if((file.endsWith(".hscript") || file.endsWith(".hx")) && !SELoader.isDirectory('${packDir}/scripts/$file')){
								PlayState.scripts.push('${packDir}/scripts/$file');
							}
						}
					}
				}
				// if (FileSystem.exists('${selSong}/script.hscript')) {
				// 	trace("Song has script!");
				// 	MultiPlayState.scriptLoc = '${selSong}/script.hscript';
					
				// }else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				LoadingScreen.loadingText = "Creating PlayState";

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
				SELoader.saveContent(onlinemod.OfflinePlayState.chartFile,Json.stringify({song:song}));
				
				reloadList(true,searchField.text);
				curSelected = sel;
				changeSelection();
				selSong(sel,true);
				// showTempmessage('Generated blank chart for $songName');
				return;


			}else{
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart}';
				PlayState.SONG = Song.parseJSONshit(SELoader.loadText(onlinemod.OfflinePlayState.chartFile),true);
			}
			if (SELoader.exists('${songLoc}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${songLoc}/Voices.ogg';}
			PlayState.hsBrTools = new HSBrTools('${songLoc}');
			onlinemod.OfflinePlayState.instFile = '${songLoc}/Inst.ogg';
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
				onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
			}
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
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
			trace('Using namespace ${onlinemod.OfflinePlayState.nameSpace}');
		}
		lastSel = sel;
		lastSearch = searchField.text;
		lastSong = songs[sel] + modes[sel][selMode] + songNames[sel];
		{
			var diffList:Array<String> = [];
			for(i => v in modes[sel]){
				diffList.push(songs[curSelected] + "/" + v);
			}
			PlayState.songDifficulties = diffList;
		}
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
			FlxG.sound.music.volume = FlxG.save.data.instVol * FlxG.sound.volume;
			voices.volume = FlxG.save.data.voicesVol * FlxG.sound.volume;
		}
	}
	override function handleInput(){
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
			{
				ret();
			}
			if(songs.length == 0 || !allowInput) return;
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
	var listeningTime:Float = 0;
	override function extraKeys(){
		if(controls.LEFT_P){changeDiff(-1);}
		if(controls.RIGHT_P){changeDiff(1);}
		if (FlxG.keys.justPressed.SEVEN && songs.length > 0 && FlxG.save.data.animDebug)
		{
			selSong(curSelected,true);
		}
		if((FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)){
			if(FlxG.mouse.screenY < 35 && FlxG.mouse.screenX < 1115){
				changeDiff(if(FlxG.mouse.screenX > 640) 1 else -1);
			}
			else if(!FlxG.mouse.overlaps(blackBorder)){
				var curSel = grpSongs.members[curSelected];
				for (i in -2 ... 2) {
					var member = grpSongs.members[curSelected + i];
					if(member != null && FlxG.mouse.overlaps(member)){
						if(curSel == member){
							selSong(curSelected,FlxG.mouse.justPressedRight);
						}else{
							changeSelection(i);
						}
					}
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
			allowInput = false;
			#if (target.threaded)
			sys.thread.Thread.create(() -> {
			#end
				if(curPlaying != songs[curSelected]){
					FlxG.sound.music.fadeOut(0.4);
					curPlaying = songs[curSelected];
					if(voices != null){
						voices.stop();
						voices.destroy();
					}
					voices = null;
					try{
						FlxG.sound.playMusic(SELoader.loadSound('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
					}
					catch(e){

						showTempmessage('Unable to play instrumental! ${e.message}',FlxColor.RED);
					}
					if (FlxG.sound.music.playing){
						if(modes[curSelected][selMode] != "No charts for this song!" && SELoader.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
							try{

								var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
								if(e.bpm > 0){
									Conductor.changeBPM(e.bpm);
								}
							}catch(e){
								showTempmessage("Unable to get BPM from chart automatically. BPM will be out of sync",0xee0011);
							}
							FlxG.sound.music.pause();
						}

						#if discord_rpc
							if(listeningTime == 0)listeningTime = Date.now().getTime();
							DiscordClient.changePresence('Listening to a song in menus',songNames[curSelected],listeningTime);
						#end
					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				}
				if(curPlaying == songs[curSelected]){
					try{

						if(voices == null){
							if(SELoader.exists('${songs[curSelected]}/Voices.ogg')){
								voices = new FlxSound();
								voices.loadEmbedded(SELoader.loadSound('${songs[curSelected]}/Voices.ogg'),true);
								voices.volume = FlxG.save.data.voicesVol;
								voices.looped = true;
								voices.play(FlxG.sound.music.time);
								FlxG.sound.list.add(voices);
							}
						}else{
							if(!voices.playing){
								voices.play(FlxG.sound.music.time);
								voices.volume = FlxG.save.data.voicesVol;
								voices.looped = true;
							}else
								voices.stop();
						}
						shouldVoicesPlay = (voices != null && voices.playing);
					}catch(e){
						showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
					}
					if(FlxG.sound.music.fadeTween != null)FlxG.sound.music.fadeTween.destroy(); // Prevents the song from muting itself
					FlxG.sound.music.volume = FlxG.save.data.instVol;
					FlxG.sound.music.play();
				}
				if(playCount > 2){
					playCount = 0;
					openfl.system.System.gc();
				}
				allowInput = true;
			#if (target.threaded)
			});
			#end
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
	@:keep inline public static function findFileFromAssets(path:String,name:String,file:String):String{
		if(FileSystem.exists('${path}/songs/${name}/$file')){
			return '${path}/songs/${name}/$file';
		}
		if(FileSystem.exists('${path}/music/${name}-${file}')){
			return '${path}/music/${name}-${file}';
		}
		if(FileSystem.exists('${path}/${name}/${file}')){
			return '${path}/${name}/${file}';
		}
		if(FileSystem.exists('${path}/${name}-${file}')){
			return '${path}/${name}-${file}';
		}
		if(FileSystem.exists('${path}/${file}')){
			return '${path}/${file}';
		}
		return '';
	}
	inline static function upToString(str:String,ending:String){
		return str.substr(0,str.lastIndexOf(ending) + ending.length);
	}
	@:keep inline public static function getAssetsPathFromChart(path:String,attempt:Int = 0):String{
		if(path.contains('data/') && attempt < 1){
			return path.substr(0,path.lastIndexOf('data/'));
		}
		if(path.contains('assets/')  && attempt < 2){
			return upToString(path,'assets/');
		}
		if(path.contains('mods/')  && attempt < 3){
			return upToString(path,'mods/');
		}
		return "";
	}
	public static function fileDrop(file:String){
		try{
			trace('Attempting to load "$file"');
			try{

				var json:FuckingSong = cast Json.parse(File.getContent(file));
				var name = json.song.song;

			}catch(e){
				MainMenuState.handleError('This chart isn\'t a FNF format chart!(Unable to parse and grab the song name from JSON.song.song)');
			}
			var voices = "";
			var inst = "";
			var dir = file.substr(0,file.lastIndexOf("/"));
			var json = file.substr(file.lastIndexOf("/") + 1);
			var name = json.substr(0,json.lastIndexOf("."));

			var attempts = 0;
			if(FileSystem.exists('${dir}/Inst.ogg')){ 
				inst = '${dir}/Inst.ogg';
				if(FileSystem.exists('${dir}/Voices.ogg')){
					voices = '${dir}/Voices.ogg';
				}
			}
			while(inst == "" && attempts < 99){ // If this reaches 99 attempts, fucking run
				attempts++;
				var assets = getAssetsPathFromChart(file,attempts);
				if(assets == "") break; // Nothing else to search!

				inst = findFileFromAssets(assets,name,'Inst.ogg');
				voices = findFileFromAssets(assets,name,'Voices.ogg');

				if(inst == "" && name.lastIndexOf("-") != -1){ // Try without the extra - part, some songs only have a hard variant
					var name = name.substr(0,name.lastIndexOf("-"));
					inst = findFileFromAssets(assets,name,'Inst.ogg');
					voices = findFileFromAssets(assets,name,'Voices.ogg');
				}
				if(inst == ""){ // Check more places
					var content = File.getContent(file);
					if(content != null && content != ""){
						var name:Dynamic = cast Json.parse(File.getContent(file));
						var songName:String = "";
						if(name.song != null && Std.isOfType(name.song,String)){
							songName = cast name.song;
						}else if(name.song != null && name.song.song != null && Std.isOfType(name.song.song,String)){
							songName = cast name.song.song;
						}
						if(songName != null && songName != ""){ // Try using the chart name maybe?
							trace(songName);
							inst = findFileFromAssets(assets,name,'Inst.ogg');
							voices = findFileFromAssets(assets,name,'Voices.ogg');
						}
					}

				}
				
			}
			if(inst == ""){
				MusicBeatState.instance.showTempmessage('Unable to find Inst.ogg for "$json"',FlxColor.RED);
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
	var song:FSong;
}
typedef FSong = {
	var song:String;
}
