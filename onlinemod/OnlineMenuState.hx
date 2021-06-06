package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OnlineMenuState extends MusicBeatState
{
  var curSelected:Int = 0;

  var options:Array<String> = ["play online", "play offline songs"];
  var descriptions:Array<String> = ["Play online with other people.",
  "Play songs that have been downloaded during online games."];

  var descriptionText:FlxText;
  var grpControls:FlxTypedGroup<Alphabet>;

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
    add(bg);


    grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
      if (i != 0)
        controlLabel.alpha = 0.6;
			grpControls.add(controlLabel);
		}


    descriptionText = new FlxText(5, FlxG.height - 18, 0, descriptions[0], 12);
		descriptionText.scrollFactor.set();
		descriptionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descriptionText);


    FlxG.mouse.visible = false;
    FlxG.autoPause = true;


    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (controls.BACK)
    {
      FlxG.switchState(new MainMenuState());
    }

    if (controls.UP_P)
      changeSelection(-1);
    if (controls.DOWN_P)
      changeSelection(1);

    if (controls.ACCEPT)
    {
      switch (curSelected)
      {
        case 0: // Play online
          FlxG.switchState(new OnlinePlayMenuState());
        /*case 1: // Host server
          FlxG.switchState(new OnlineHostMenu());*/
        case 1: // Play offline
          FlxG.switchState(new OfflineMenuState());
      }
    }
  }

  function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;


    descriptionText.text = descriptions[curSelected];


		var bullShit:Int = 0;

		for (item in grpControls.members)
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
