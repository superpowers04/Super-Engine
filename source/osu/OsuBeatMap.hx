package osu;

import flixel.FlxG;
import flixel.system.FlxSound;
import flash.media.Sound;
import sys.FileSystem;
import Section;
import Song;

using StringTools;

class OsuBeatMap{
	static var beatmap:String = "";
	static function getSetting(str:String):String{	
		var e:EReg = new EReg('${str}:([^\n]*)','ig');
		e.match(beatmap);
		return e.matched(1).trim();
	}
	public static function getSettingBM(str:String,map:String):String{
		var e:EReg = new EReg('${str}:([^\n]*)','ig');
		e.match(map);
		return e.matched(1).trim();
	}
	public static function loadFromText(bm:String):SwagSong{
			var started = Sys.time();
			beatmap = bm;
			var mp3:String = getSetting("AudioFilename");
			var song:SwagSong = {
				song: getSetting("Title"),
				notes: [],
				bpm: 120,
				needsVoices: true,
				player1: 'bf',
				player2: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 2.0,
				validScore: false
			};

			{ // 242,292,2002,5,0,0:0:0:0:
				var hitobjs:Array<SwagSection> = [];
				var regHitObj:EReg = (~/(^[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*,[0-9]*)/gm);
				var hitobjval:EReg = (~/(^[0-9]*),([0-9]*),([0-9]*),([0-9]*),([0-9]*),([0-9]*|)/gm);
				var i = 0;
				var curSection = 0;
				var noteCount = 0;
				var input =bm;
				while (hitobjval.match(input)) {
					input = hitobjval.matchedRight();
					// var curObj:String = regHitObj.matched(1);
					if (Std.parseInt(hitobjval.matched(4)) == 3 ) continue;
					if (hitobjs[curSection] == null) {
						hitobjs[curSection] = {
							typeOfSection : 0,
							lengthInSteps : 16,
							mustHitSection : true,
							altAnim : false,
							sectionNotes : [],
							changeBPM : false,
							bpm : 120
						};
					}
					var time = Std.parseInt(hitobjval.matched(3));
					var hold = if (Std.parseInt(hitobjval.matched(4)) == 7) Std.parseInt(hitobjval.matched(6)) - time else 0;
					var nid = Math.round(Std.parseInt(hitobjval.matched(1)) * 4 / 512);
					hitobjs[curSection].sectionNotes.push([time,nid,hold]); 
					i++;
					noteCount++;
					if (i > 15) {i = 0; curSection++;}
					

				}
				trace('Converted ${noteCount} circles to notes with ${hitobjs.length} sections in ${Sys.time() - started} seconds');
				song.notes = hitobjs;
			}
			var ogg = '${mp3.substr(0,-4)}.ogg';
 			if (!FileSystem.exists('${OsuMenuState.songPath}/${ogg}')) {MainMenuState.handleError('Sadly Lime/OpenFL does not support mp3\'s, you will have to convert ${OsuMenuState.songPath}/${mp3} to an ogg');}
			OsuPlayState.instFile = '${OsuMenuState.songPath}/${ogg}';
			beatmap = "";
			sys.io.File.saveContent("test.json",haxe.Json.stringify(song,' '));
			return song;
		
	}

}