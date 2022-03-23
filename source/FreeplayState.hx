package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import tjson.Json;
import multi.MultiPlayState;




using StringTools;

typedef JustThePlayer = {
	var player1:String;
	var player2:String;
}


class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;


	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		try{


		// var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		super.create();
		
		if (FileSystem.exists("assets/data"))
		{
			for (dir in FileSystem.readDirectory("assets/data"))
			{
				if(FileSystem.exists('assets/data/${dir}/${dir}.json') && FileSystem.exists('assets/songs/${dir}/Inst.ogg')){
					try{

						var song:JustThePlayer = cast Json.parse(File.getContent('assets/data/${dir}/${dir}.json')).song;
						songs.push(new SongMetadata(dir, 0, song.player2));
						song = null;
					}catch(e){trace('Failed to load ${dir}: ${e.message}');}
				}
			}
		}
		if(songs.length < 1){
			MainMenuState.handleError("No songs found!");
		}
		haxe.ds.ArraySort.sort(songs, function(a, b) {
		   if(a.songName < b.songName) return -1;
		   else if(b.songName > a.songName) return 1;
		   else return 0;
		});
		// for (i in 0...initSonglist.length)
		// {
		// 	var data:Array<String> = initSonglist[i].split(':');
		// 	songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		// }



		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

	}catch(e){MainMenuState.handleError('Something went wrong when creating freeplaystate: ${e.message}');}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			try{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

				trace(poop);

				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				// PlayState.storyWeek = songs[curSelected].week;
				// PlayState.stateType = 0;
				trace('CUR WEEK' + PlayState.storyWeek);
			// LoadingState.loadAndSwitchState(new MultiPlayState());
				// onlinemod.OfflinePlayState.chartFile = '';
				onlinemod.OfflinePlayState.chartFile = 'assets/data/${songs[curSelected].songName}/${poop}.json';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.actualSongName = ${songs[curSelected].songName};
				onlinemod.OfflinePlayState.voicesFile = '';

				if (FileSystem.exists('assets/songs/${songs[curSelected].songName}/Voices.ogg')) onlinemod.OfflinePlayState.voicesFile = 'assets/songs/${songs[curSelected].songName}/Voices.ogg';
				PlayState.hsBrTools = new HSBrTools('assets/data/${songs[curSelected].songName}/');
				if (FileSystem.exists('assets/data/${songs[curSelected].songName}/script.hscript')) {
					trace("Song has script!");
					MultiPlayState.scriptLoc = 'assets/data/${songs[curSelected].songName}/script.hscript';
					
				}else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				onlinemod.OfflinePlayState.instFile = 'assets/songs/${songs[curSelected].songName}/Inst.ogg';
				PlayState.stateType = 0;
				FlxG.sound.music.fadeOut(0.4);
				LoadingState.loadAndSwitchState(new MultiPlayState());
			}catch(e){
				MainMenuState.handleError('Error while loading chart ${e.message}');
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		// #if PRELOAD_ALL
		// FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		// #end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.songCharacter = songCharacter;
	}
}
