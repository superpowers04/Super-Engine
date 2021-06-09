package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class CharSelection extends MusicBeatState
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
    for (char in TitleState.choosableCharacters)
    {
      songs.push(char);

      var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
      if (i != 0)
        controlLabel.alpha = 0.6;
			grpSongs.add(controlLabel);

      i++;
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
      FlxG.switchState(new OptionsMenu());
    }


    if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
    if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

    if (controls.ACCEPT && songs.length > 0)
    {
      if (Options.PlayerOption.playerEdit){
        FlxG.save.data.playerCharIndex = curSelected;
        FlxG.save.data.playerChar = songs[curSelected];
      }else{
        FlxG.save.data.opponentIndex = curSelected;
        FlxG.save.data.opponent = songs[curSelected];
      }

      FlxG.switchState(new OptionsMenu());
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
