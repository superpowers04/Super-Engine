package onlinemod;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;

import Section.SwagSection;

class OfflinePlayState extends PlayState
{
  var loadedVoices:FlxSound;
  var loadedInst:Sound;

  override function create()
  {
    PlayState.SONG.player1 = 'bf';
    PlayState.SONG.player2 = 'dad';


    loadedVoices = new FlxSound().loadEmbedded(Sound.fromFile('assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Voices.ogg'));
    loadedInst = Sound.fromFile('assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Inst.ogg');


    super.create();


    // Add XieneDev watermark
    var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.9 + 50, FlxG.width, "XieneDev Battle Royale", 16);
		xieneDevWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		xieneDevWatermark.scrollFactor.set();
		add(xieneDevWatermark);
    xieneDevWatermark.cameras = [camHUD];


    FlxG.mouse.visible = false;
    FlxG.autoPause = true;
  }

  override function startSong()
  {
    FlxG.sound.playMusic(loadedInst, 1, false);

    paused = true; // Setting 'paused' to true makes it so 'super.startSong()' doesn't try to load the Inst track
    super.startSong();
    paused = false;
  }

  override function generateSong(dataPath:String)
  {
    // I have to code the entire code over so that I can remove the offset thing
    var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (PlayState.SONG.needsVoices)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
  }

  override function endSong()
  {
    canPause = false;
    FlxG.sound.music.onComplete = null;
    FlxG.sound.music.pause();
		vocals.volume = 0;

    FlxG.switchState(new OfflineMenuState());
  }

  override function openSubState(SubState:FlxSubState)
  {
    if (Type.getClass(SubState) == GameOverSubstate)
    {
      // super.openSubState(new OfflineGameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
      return;
    }
    else if (Type.getClass(SubState) == PauseSubState)
    {
      super.openSubState(new OnlinePauseSubState(true));
      return;
    }

    super.openSubState(SubState);
  }
}
