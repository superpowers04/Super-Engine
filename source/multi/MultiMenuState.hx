package multi;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import openfl.media.Sound;
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
	var diffText:FlxText;
	var selMode:Int = 0;
	var blockedFiles:Array<String> = ['picospeaker.json','dialogue-end.json','dialogue.json','_meta.json','meta.json','config.json'];
	static var lastSel:Int = 0;
	static var lastSearch:String = "";
	var beetHit:Bool = false;

	var songNames:Array<String> = [];
	var nameSpaces:Array<String> = [];
	var shouldDraw:Bool = true;
	var inTween:FlxTween;
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
		retAfter = false;
		dataDir = "mods/charts/";
		bgColor = 0x00661E;
		super.create();
		diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
		diffText.font = CoolUtil.font;
		diffText.x = (FlxG.width) - 20;
		// diffText.autoSize = false;
		// diffText.width = 200;
		diffText.alignment = RIGHT;
		add(diffText);

		searchField.text = lastSearch;
		if(lastSearch != "") reloadList(true,lastSearch);

		lastSearch = "";
		changeSelection(lastSel);
		lastSel = 0;
		changeDiff();
		updateInfoText('Use shift to scroll faster; Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs');

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
	override function reloadList(?reload=false,?search = ""){
		curSelected = 0;
		if(reload){grpSongs.clear();}

		songs = ["No Songs!"];
		songNames = ["Nothing"];
		modes = [0 => ["None"]];
		var i:Int = 0;

		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		if (FileSystem.exists(dataDir))
		{
			var dirs = orderList(FileSystem.readDirectory(dataDir));
			for (directory in dirs)
			{
				if (search == "" || query.match(directory.toLowerCase())) // Handles searching
				{
					if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
						modes[i] = [];
						for (file in FileSystem.readDirectory(dataDir + directory))
						{
								if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
									modes[i].push(file);
								}
						}
						if (modes[i][0] == null){ // No charts to load!
							modes[i][0] = "No charts for this song!";
						}
						songs[i] = dataDir + directory;
						songNames[i] =directory;

						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, directory, true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						if (i != 0)
							controlLabel.alpha = 0.6;
						grpSongs.add(controlLabel);
						i++;
					}
				}
			}
		}
		if (FileSystem.exists("mods/weeks"))
		{
			for (dataDir in FileSystem.readDirectory("mods/weeks"))
			{
				dataDir = "mods/weeks/" + dataDir + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				for (directory in dirs)
				{
					if (search == "" || query.match(directory.toLowerCase()) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}
							songs[i] = dataDir + directory;
							songNames[i] = directory;

							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, directory, true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							if (i != 0)
								controlLabel.alpha = 0.6;
							grpSongs.add(controlLabel);
							nameSpaces[i] = dataDir;
							i++;
						}
					}
				}
			}
		}
		if (FileSystem.exists("mods/packs"))
		{
			for (dataDir in FileSystem.readDirectory("mods/packs"))
			{
				dataDir = "mods/packs/" + dataDir + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				for (directory in dirs)
				{
					if (search == "" || query.match(directory.toLowerCase()) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}
							songs[i] = dataDir + directory;
							songNames[i] =directory;

							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, directory, true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							if (i != 0)
								controlLabel.alpha = 0.6;
							grpSongs.add(controlLabel);
							nameSpaces[i] = dataDir;
							i++;
						}
					}
				}
			}
		}
		updateInfoText('Use shift to scroll faster; Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs');
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

	public static function gotoSong(?selSong:String = "",?songJSON:String = "",?songName:String = ""){
			try{
				if(selSong == "" || songJSON == "" || songName == ""){
					throw("No song name provided!");
				}
				onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.songDiff = songJSON;
				PlayState.storyDifficulty = switch(songJSON){case '${songName}-easy.json': 0; case '${songName}-hard.json': 2; default: 1;};
				PlayState.actualSongName = songJSON;
				onlinemod.OfflinePlayState.voicesFile = '';

				if (FileSystem.exists('${selSong}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${selSong}/Voices.ogg';}
				PlayState.hsBrTools = new HSBrTools('${selSong}');
				if (FileSystem.exists('${selSong}/script.hscript')) {
					trace("Song has script!");
					MultiPlayState.scriptLoc = '${selSong}/script.hscript';
					
				}else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				onlinemod.OfflinePlayState.instFile = '${selSong}/Inst.ogg';
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
					onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
				}
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
					onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
				}
				PlayState.stateType = 4;
				FlxG.sound.music.fadeOut(0.4);				LoadingState.loadAndSwitchState(new MultiPlayState());
			}catch(e){
				MainMenuState.handleError('Error while loading chart ${e.message}');
			}
	}

	override function select(sel:Int = 0){
			if (songs[curSelected] == "No Songs!" || modes[curSelected][selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
				FlxG.sound.play(Paths.sound("cancelMenu"));
				return;
			}
			
			lastSel = curSelected;
			lastSearch = searchField.text;

			// var songJSON = modes[curSelected][selMode]; // Just for easy access
			// var songName = songNames[curSelected]; // Easy access to var
			// var selSong = songs[curSelected]; // Easy access to var
			gotoSong(songs[curSelected],modes[curSelected][selMode],songNames[curSelected]);

			// PlayState.SONG = Song.parseJSONshit(File.getContent('${selSong}/${songJSON}'));

	}	

	var curPlaying = "";
	var voices:FlxSound;
	var playCount:Int = 0;
	var curVol:Float = 1;
	override function update(e){
		super.update(e);
		// Fucking flixel
		if(voices != null && curVol != FlxG.sound.volume){ // Don't change volume unless volume changes
			curVol = FlxG.sound.volume;
			voices.volume = FlxG.save.data.voicesVol * FlxG.sound.volume;
		}
	}
	override function handleInput(){
			if (controls.BACK)
			{
				ret();
			}
			if(songs.length == 0) return;
			super.handleInput();
			// if(controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
			// if(controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
			// if(controls.LEFT_P){changeDiff(-1);}
			// if(controls.RIGHT_P){changeDiff(1);}
			
			// extraKeys();
			// if (controls.ACCEPT && songs.length > 0)
			// {
			// 		select();
			// }
	}
	override function extraKeys(){
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
	function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
		if (songs.length == 0 || songs[curSelected] == null || songs[curSelected] == "") {
			diffText.text = 'No song selected';
			return;
		}
		if (forcedInt == -100) selMode += change; else selMode = forcedInt;
		if (selMode >= modes[curSelected].length) selMode = 0;
		if (selMode < 0) selMode = modes[curSelected].length - 1;
		diffText.text = modes[curSelected][selMode];
		// diffText.centerOffsets();
		diffText.x = (FlxG.width) - 20 - diffText.width;

	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);

	}

	override function goOptions(){
			lastSel = curSelected;
			lastSearch = searchField.text;
			FlxG.mouse.visible = false;
			OptionsMenu.lastState = 4;
			FlxG.switchState(new OptionsMenu());
	}
}
