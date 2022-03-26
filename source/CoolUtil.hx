package;

import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class CoolUtil
{
	public static var fontName:String = "vcr.ttf";
	public static var font:String = if(FileSystem.exists('mods/font.ttf')) 'mods/font.ttf' else Paths.font(fontName);
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
			daList[i].replace("\\n","\n");
		}

		return daList;
	}
	public static function coolFormat(text:String){
		var daList:Array<String> = text.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
			daList[i] = daList[i].replace("\\n","\n");
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
	public static function orderList(list:Array<String>):Array<String>{
		haxe.ds.ArraySort.sort(list, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		return list;
	}
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
