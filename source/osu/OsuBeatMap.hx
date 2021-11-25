package osu;

import flixel.FlxG;
import flixel.system.FlxSound;
import flash.media.Sound;
import sys.FileSystem;
import Section;
import Song;

using StringTools;

typedef OsuTimingPoint = {
	var ms:Int;
	var bpm:Float;
	var sliderMult:Float;
	// var meter:Int;
	// var uninher:Bool;
}

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
			var song:SwagSong = {
				song: "OsuBeatMap_Not_loaded",
				notes: [],
				bpm: 120,
				needsVoices: false,
				player1: 'bf',
				player2: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 2.0,
				validScore: false,
				difficultyString: "Unknown",
				mania: 0
			};
			try{

				inline function normalizeInt(int:Int){if (int < 0) return -int; else return int;}
				var started = Sys.time();
				beatmap = bm;
				var mp3:String = getSetting("AudioFilename");
				song = {
					song: getSetting("Title"),
					notes: [],
					bpm: 120,
					needsVoices: false,
					player1: 'bf',
					player2: 'gf',
					gfVersion: 'gf',
					noteStyle: 'normal',
					stage: 'stage',
					speed: if(QuickOptionsSubState.osuSettings['Scroll speed'].value > 0) QuickOptionsSubState.osuSettings['Scroll speed'].value else 2.0,
					validScore: false,
					noteMetadata:Song.defNoteMetadata,
					difficultyString: '[${getSetting("Version")}]',
					mania:0
				};
				var hitobjsre:EReg = (~/\[HitObjects\]/gi);
				hitobjsre.match(bm);
				var timingPoints:Array<OsuTimingPoint> = [];
				{ // Timing points   0,0.0,0,0,0,0,0,0 |  -28,461.538461538462,4,1,0,100,1,0

					var regTP:EReg = (~/(^[-0-9]*),([-0-9.]*),([-0-9.]*),([-0-9]*),([-0-9.]*),([-0-9.]*),([01]),/gm);
					var input:String = bm;
					while (regTP.match(input)) {
						input=regTP.matchedRight();
						var inher:Bool = (regTP.matched(7) == "0");
						if (inher) {trace('${regTP.matched(0)} is inherited, Unsupported at the moment');continue;} // Unsupported atm
						var bpm:Float = 1 / Std.parseFloat(regTP.matched(1)) * 1000 * 60; // Did not google this, dunno what you mean. *I'm not bad at math, I swear*
						if (bpm < 0) bpm = -bpm;
						timingPoints.push({
							ms : Std.parseInt(regTP.matched(1)),
							bpm : bpm,
							// uninher : uninher,
							sliderMult : 0

						});

					}
					if(timingPoints.length == 0) MainMenuState.handleError("Unable to load timingPoints!");
					trace('Loaded ${timingPoints.length} timingPoints');
				}

				var isTimedReg:EReg = (~/([a-z]|)/gi);
				{ // hitobjs
					var hitobjs:Array<SwagSection> = [];
					var hitobjval:EReg = (~/(^[-0-9]*),([-0-9]*),([-0-9]*),([-0-9]*),([-0-9]*),([-0-9A-z|:]*)/gm);
					var sliderReg:EReg = (~/([A-z]\|[|0-9.]*),([-0-9]*),([-0-9]*),.*/gm);
					var maniaHoldReg:EReg = (~/([|0-9.]*):/gm);

					var i = 0;
					var curSection = 0;
					var noteCount = 0;
					var input =bm;
					while (hitobjval.match(input)) {
						input = hitobjval.matchedRight();
						// var curObj:String = regHitObj.matched(1);
						var hold = 0;
						var time = Std.parseInt(hitobjval.matched(3));
						var int = Std.parseInt; // Just for easier access

						if (sliderReg.match(hitobjval.matched(6))) {
							continue;
						}else if (maniaHoldReg.match(hitobjval.matched(6))) {
							hold = int(maniaHoldReg.matched(1)) - time;
						}
						// else if (int(hitobjval.matched(4)) >> 3 == 1){
							// hold = int(hitobjval.matched(6)) - time;
						// }

						

						if (timingPoints[curSection + 1] != null && timingPoints[curSection + 1].ms <= time) curSection++;
						if (i >= 72) {curSection++;timingPoints.insert(curSection,timingPoints[curSection - 1]);}
						if (hitobjs[curSection] == null) {
							i=0;
							hitobjs[curSection] = {
								typeOfSection : 0,
								lengthInSteps : 16,
								mustHitSection : true,
								altAnim : false,
								sectionNotes : [],
								changeBPM : true,
								bpm : timingPoints[curSection].bpm
							};
							trace('New section: ${curSection}');
						}
						// var hold = normalizeInt(Math.round(Std.parseInt(hitobjval.matched(6)) - time * 0.01));
						var nid = Math.floor(int(hitobjval.matched(1)) * 4 / 512);
						hitobjs[curSection].sectionNotes.push([time,nid,hold,0]); 
						i++;
						noteCount++;
						

					}
					trace('Converted ${noteCount} circles to notes with ${hitobjs.length} sections in ${Sys.time() - started} seconds');
					song.notes = hitobjs;
				}

				var ogg = '${mp3.substr(0,-4)}.ogg';
	 			var oggPath = '${OsuMenuState.songPath}/${ogg}';
				var oggExist = FileSystem.exists(oggPath);
	 			var mp3Path = '${OsuMenuState.songPath}/${mp3}';
	 			var ffmpegLoc = 'ffmpeg'#if windows + '.exe' #end;
	 			if (FileSystem.exists(Sys.getCwd() + '/${ffmpegLoc}')) ffmpegLoc = Sys.getCwd() + '/${ffmpegLoc}' else if (FileSystem.exists(Sys.getCwd() + '/ffmpeg/${ffmpegLoc}')) ffmpegLoc = Sys.getCwd() + '/${ffmpegLoc}';
	 			if (!oggExist && Sys.command(ffmpegLoc) < 2){ // Check for FFMpeg, returns an exit code of 1 if present
	 				trace('Trying to convert ${mp3Path} to ${oggPath}');
	 				Sys.command(ffmpegLoc,["-i",mp3Path,"-vn",oggPath]);
					oggExist = FileSystem.exists(oggPath);
	 			}
	 			if (!oggExist) {MainMenuState.handleError('Sadly Lime/OpenFL does not support mp3\'s, you will have to convert ${mp3} to an ogg, or install ffmpeg');}
				OsuPlayState.instFile = oggPath;
				beatmap = "";
				sys.io.File.saveContent("test.json",haxe.Json.stringify(song,' '));
			}catch(e){MainMenuState.handleError('Error loading beatmap ${e.message}');}
			return song;
		
	}

}