package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flash.media.Sound;
import sys.FileSystem;
import flixel.util.FlxColor;

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
  public static var menuMusic:Sound;
  public static var musicTime:Int = 8;
  public static var fading:Bool = false;
  var isMainMenu:Bool = false;


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
  function musicHandle(){

      
      var time:Int = Date.now().getHours();
      var curMusicTime = (if (time > 22 || time < 6) 1 else if (time > 5 && time < 10) 2 else if (time > 18 && time < 22) 3 else 0); // 0=day,1=night,2=morning,3=evening

      var musicTime = SickMenuState.musicTime;
      if (SickMenuState.menuMusic == null || musicTime != curMusicTime){
        if(FlxG.sound.music.playing){if(!SickMenuState.fading){SickMenuState.fading = true;
          var switchToColor = switch (curMusicTime) {// default=day,1=night,2=morning,3=evening
                      case 1:0x1133aa;
                      case 2,3:0xffaa11;
                      default:0xECD77F;
                    }
          new FlxTimer().start(0.1, function(tmr:FlxTimer)
          {
              FlxG.sound.music.volume -= 0.1;
              if(isMainMenu){
                bg.color = FlxColor.interpolate(bg.color,switchToColor,0.2);
              }              
              if(tmr.elapsedLoops > 9){
                FlxG.sound.music.stop();
                
                musicHandle();
              }
          },10);
          }
          return;}
        SickMenuState.fading = false;
        SickMenuState.menuMusic = switch (curMusicTime) {
          case 1:Sound.fromFile(if(FileSystem.exists("mods/title-night.ogg")) "mods/title-night.ogg" else Paths.music("freshChillMix"));
          case 2:Sound.fromFile(if(FileSystem.exists("mods/title-morning.ogg")) "mods/title-morning.ogg" else Paths.music("breakfast"));
          case 3:Sound.fromFile(if(FileSystem.exists("mods/title-evening.ogg")) "mods/title-evening.ogg" else Paths.music("GiveaLilBitBack"));
          default:Sound.fromFile(if(FileSystem.exists("mods/title-day.ogg")) "mods/title-day.ogg" else Paths.music('freakyMenu'));
        };
        SickMenuState.musicTime = curMusicTime;
      FlxG.sound.playMusic(SickMenuState.menuMusic);
    }else if (!FlxG.sound.music.playing) FlxG.sound.playMusic(SickMenuState.menuMusic);

  }

  override function create()
  {
    if (ChartingState.charting) ChartingState.charting = false;
    musicHandle();

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
