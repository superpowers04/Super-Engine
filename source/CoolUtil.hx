package;

import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class CoolUtil
{
	public static var fontName = "vcr.ttf";
	public static var font = if(FileSystem.exists('mods/font.ttf')) 'mods/font.ttf' else Paths.font(fontName);
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{

		return if (PlayState.stateType == 4) PlayState.actualSongName else difficultyArray[PlayState.storyDifficulty];
	}
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	// static var songNames:Map<String,String> = [
	// 	'dad-battle'=> "Dad Battle",
	// 	'dadbattle'=> "Dad Battle",
	// 	'phillynice' =>"philly",
	// 	'philly-nice' =>"philly",
	// 	'philly nice' =>"philly",
	// 	'winter-horrorland' =>"winterhorrorland",
	// 	'winterhorrorland' =>"Winter Horrorland",
	// 	'satin-panties' => "satinpanties"
	// ];
	// public static function getNativeSongname(?song:String = "",?convLower:Bool = false):String{

	// 	if (songNames[song.toLowerCase()] != null) return if (convLower) songNames[song.toLowerCase()].toLowerCase() else songNames[song.toLowerCase()];
	// 	return if (convLower) song.toLowerCase() else song;
	// }
	
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function multiInt(?int:Int = 0){
		if (int == 1) return ''; else return 's';
	}
	public static function cleanJSON(input:String):String{ // Haxe doesn't filter out comments?
		input = input.trim();
		input = (~/\/\*[\s\S]*?\*\/|\/\/.*/g).replace(input,'');
		return input;
	}
}
