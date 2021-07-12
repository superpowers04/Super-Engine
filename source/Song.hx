package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var ?defplayer1:String;
	var ?defplayer2:String;
	var ?defgf:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		swagShit.defplayer1 = swagShit.player1;
		swagShit.defplayer2 = swagShit.player2;
		if (PlayState.invertedChart){
			var invertedNotes:Array<Int> = [4,5,6,7,0,1,2,3];
			for (sid => section in swagShit.notes) {
				// for (nid => note in section.sectionNotes){
				// 	note[1] = invertedNotes[note[1]];
				// 	swagShit.notes[sid].sectionNotes[nid] = note;
				// }
				section.mustHitSection = !section.mustHitSection;
				swagShit.notes[sid] = section;
			}
			swagShit.defplayer1 = swagShit.player2;
			swagShit.defplayer2 = swagShit.player1;
		}
		swagShit.defgf = swagShit.gfVersion;
		return swagShit;
	}
}
