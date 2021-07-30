package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class SickMenuState extends MusicBeatState
{
  var curSelected:Int = 0;

  var options:Array<String> = ["replace me dammit", "what are you doing, replace me"];
  var descriptions:Array<String> = ["Hello there, Please report this","Bruh"];

  var descriptionText:FlxText;
  var grpControls:FlxTypedGroup<Alphabet>;
  var bgImage:String = "menuDesat";
  var selected:Bool = false;
  var bg:FlxSprite;
  function goBack(){
    FlxG.switchState(new MainMenuState());
  }
  function generateList(){
    for (i in 0...options.length)
    {
      var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
      controlLabel.isMenuItem = true;
      controlLabel.targetY = i;
      if (i != 0)
        controlLabel.alpha = 0.6;
      grpControls.add(controlLabel);
    }
  }
  override function create()
  {
    if (ChartingState.charting) ChartingState.charting = false;
    if (!FlxG.sound.music.playing)
    {
      FlxG.sound.playMusic(Paths.music('freakyMenu'));
    } // TODO CUSTOM MAIN MENU SONGS

    bg = new FlxSprite().loadGraphic(Paths.image(bgImage));
    bg.color = 0xFFFF6E6E;
    bg.scrollFactor.set(0.01,0.01);
    add(bg);


    grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);
    generateList();

    descriptionText = new FlxText(5, FlxG.height - 18, 0, descriptions[0], 12);
		descriptionText.scrollFactor.set();
		descriptionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    var blackBorder:FlxSprite = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(descriptionText.width + 900)),Std.int(descriptionText.height + 600),FlxColor.BLACK);
    blackBorder.alpha = 0.5;

    add(blackBorder);

    add(descriptionText);

    FlxTween.tween(descriptionText,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
    FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

    FlxG.mouse.visible = false;
    FlxG.autoPause = true;


    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);
    if (selected) return;
    if (controls.BACK)
    {
      goBack();
    }
    if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
    if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

    if (controls.ACCEPT)
    {

      select(curSelected);
    }
  }
  function select(sel:Int){
    trace("Why wasn't this replaced?");
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
