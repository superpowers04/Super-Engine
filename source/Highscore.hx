package;

import flixel.FlxG;
import sys.io.File;
import sys.FileSystem;
import tjson.Json;
class SongScores {

	var songNames:Array<String> = [];
	var scores:Array<Array<Dynamic>> = [];
	var path:String = "";
	public function new(?path:String = ""){
		if(path == ""){
			path = Highscore.GETSCOREPATH();
		}
		trace('Loading saves from $path');
		this.path = path;
		var json:ScoreJson = {
			songNames:["Bopeebo"],
			scores:[[1]]
		}
		if(FileSystem.exists(path)){
			json = cast try{Json.parse(File.getContent(path));}catch(e){ {songNames:["Bopeebo"],scores:[1]}; };
		}
		songNames = json.songNames;
		scores = json.scores;
	}
	public function save(){
		try{
			if(!FileSystem.exists(path)){
				FileSystem.createDirectory(path.substr(0,path.lastIndexOf("/")));
			}
			File.saveContent(path,Json.stringify({songNames:songNames,scores:scores}));
		}catch(e){
			MusicBeatState.instance.showTempmessage('Unable to save scores! ${e.message}',0xFF0000);
		}
		trace("This is a save momentum");
	}
	public function exists(song:String):Bool{
		return songNames.indexOf(song) != -1;
	}
	public static var NORESULT:Array<Dynamic> = [0,"No score to display!"];
	public function getArr(song:String):Array<Dynamic>{
		var index = songNames.indexOf(song);
		if(index < 0){
			return [0,"No score to display!"];
		}
		return scores[index].copy();
	}
	public function get(song:String):Int{
		var index = songNames.indexOf(song);
		if(index < 0){
			return 0;
		}
		return scores[index][0];
	}
	public function set(song:String,?score:Int = 0,?arr:Array<Dynamic>){
		var index = songNames.indexOf(song);
		if(index < 0){
			index = songNames.length;
		}
		songNames[index] = song;
		if(arr == null){
			scores[index] = [score];
		}else{
			scores[index] = arr;
		}
		save();
		trace('Funni set $song = $score');
	}
	public function wipe(){
		songNames = [];
		scores = [];
		save();
		trace("");
	}
}
typedef ScoreJson = {
	var songNames:Array<String>;
	var scores:Array<Array<Dynamic>>;
}
class Highscore
{
	// #if (haxe >= "4.0.0")
	// public static var songScores:Map<String, Int> = new Map();
	// #else
	// public static var songScores:Map<String, Int> = new Map<String, Int>();
	// #end
	public static var songScores:SongScores;

	public static inline function GETSCOREPATH():String{
		#if windows 
			if (Sys.getEnv("LOCALAPPDATA") != null) return '${Sys.getEnv("LOCALAPPDATA")}/superpowers04/FNF Super Engine/scores.json'; // Windows path
		#else
			if (Sys.getEnv("HOME") != null ) return '${Sys.getEnv("HOME")}/.local/share/superpowers04/FNF Super Engine/scores.json'; // Unix path
		#end
		else 
			return "./superpowers04/FNF Super Engine/scores.json"; // If this gets returned, fucking run
	}

	public static var scorePath:String = GETSCOREPATH();


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);



		// if(!FlxG.save.data.botplay)
		// {
			// if (songScores.exists(daSong))
			// {
				// if (songScores.get(daSong) < score)
		setScore(daSong, score);
			// }
			// else
			// 	setScore(daSong, score);
		// }else trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveWeekScore(week:Dynamic = 1, score:Int = 0, ?diff:Int = 0):Void
	{



		if(!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong('week$week', diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	public static function setScore(song:String, score:Int,?Arr:Array<Dynamic>):Void
	{
		// // Reminder that I don't need to format this song, it should come formatted!
		if(songScores.get(song) < score)
			songScores.set(song, score,Arr);
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function getScoreUnformatted(song:String):Int
	{
		try{
			return cast songScores.get(song);
		}catch(e){return 0;}
	}
	public static function getScore(song:String, diff:Int):Array<Dynamic>
	{
		var songy = formatSong(song, diff);
		return songScores.getArr(songy);
	}

	public static function getWeekScore(week:Dynamic, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week-' + week, diff)))
			setScore(formatSong('week-' + week, diff), 0);

		return songScores.get(formatSong('week-' + week, diff));
	}
	public static function save():Void { // This is usually not needed as scores are automatically saved
		songScores.save();
	}

	public static function load():Void {
		// if (FileSystem.exists())
		// {
		songScores = new SongScores();
		// }
	}
}