package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class OfflineMenuState extends MusicBeatState
{
  var curSelected:Int = 0;

  var songs:Array<String> = [];
  var grpSongs:FlxTypedGroup<Alphabet>;

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
    add(bg);


    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);

    var i:Int = 0;
    var dataDir:String = "assets/onlinedata/data/";
    if (FileSystem.exists(dataDir))
    {
      for (directory in FileSystem.readDirectory(dataDir))
      {
        for (file in FileSystem.readDirectory(dataDir + directory))
        {
          if (StringTools.endsWith(file, '.json'))
          {
            songs.push(dataDir + directory + "/" + file);

            var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, file.substr(0, file.length - 5), true, false);
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


    FlxG.mouse.visible = false;
    FlxG.autoPause = true;


    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (controls.BACK)
    {
      FlxG.switchState(new OnlineMenuState());
    }

    if (controls.UP_P)
      changeSelection(-1);
    if (controls.DOWN_P)
      changeSelection(1);

    if (controls.ACCEPT && songs.length > 0)
    {
      PlayState.SONG = Song.parseJSONshit(File.getContent(songs[curSelected]));
      PlayState.isStoryMode = false;

      // Set difficulty
      PlayState.storyDifficulty = 1;
      if (StringTools.endsWith(songs[curSelected], '-hard.json'))
      {
        PlayState.storyDifficulty = 2;
      }
      else if (StringTools.endsWith(songs[curSelected], '-easy.json'))
      {
        PlayState.storyDifficulty = 0;
      }

      LoadingState.loadAndSwitchState(new OfflinePlayState());
    }
  }

  function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		if (curSelected >= grpSongs.length)
			curSelected = 0;


		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
