package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class CharSelection extends MusicBeatState
{
  var curSelected:Int = 0;

  var songs:Array<String> = [];
  var grpSongs:FlxTypedGroup<Alphabet>;
  var char:Character;
  var posX:Int = Std.int(FlxG.width * 0.7);
  var posY:Int = 0;
  var searchField:FlxInputText;
  var searchButton:FlxUIButton;
  var muteKeys = FlxG.sound.muteKeys;
  var volumeUpKeys = FlxG.sound.volumeUpKeys;
  var volumeDownKeys = FlxG.sound.volumeDownKeys;


  override function create()
  {try{
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
    add(bg);
    reloadCharList();
    //Searching
    searchField = new FlxInputText(10, 100, 1152, 20);
    searchField.maxLength = 81;
    add(searchField);

    searchButton = new FlxUIButton(10 + 1152 + 9, 100, "Find", () -> {
      reloadCharList(true,searchField.text);
      searchField.hasFocus = false;
    });
    searchButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    searchButton.resize(100, searchField.height);
    add(searchButton);

    var infotexttxt:String = "Hold shift to scroll faster";
    if(FlxG.save.data.charSelShow){infotexttxt+=", press Right to update the charater preview";}
    var infotext = new FlxText(5, FlxG.height - 40, 0, infotexttxt, 12);
    infotext.scrollFactor.set();
    infotext.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    var blackBorder = new FlxSprite(-30,FlxG.height - 40).makeGraphic((Std.int(infotext.width + 900)),Std.int(infotext.height + 600),FlxColor.BLACK);
    blackBorder.alpha = 0.5;

    add(blackBorder);
    add(infotext);
    if(FlxG.save.data.charSelShow){addChar();}
    FlxG.mouse.visible = true;
    FlxG.autoPause = true;

    super.create();
  }catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}

  public function addChar(?spr = 'bf'){try{
    char = new Character(posX,posY,spr,Options.PlayerOption.playerEdit == 0,Options.PlayerOption.playerEdit,true);
    char.debugMode = true;
    // char.screenCenter();
    add(char);
    if(char.dance_idle){char.playAnim('danceRight');}else{char.playAnim('idle');}
  }catch(e) MainMenuState.handleError('Error with previewing char, ${e.message}');}

  function reloadCharList(?reload = false,?search=""){try{
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];

    var i:Int = 0;

    for (char in TitleState.choosableCharacters){
      if(search == "" || FlxStringUtil.contains(char.toLowerCase(),search.toLowerCase())){
          songs.push(char);
    
          var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
          controlLabel.isMenuItem = true;
          controlLabel.targetY = i;
          if (i != 0)
            controlLabel.alpha = 0.6;
          grpSongs.add(controlLabel);
    
          i++;
      }
    }
  }catch(e) MainMenuState.handleError('Error with loading char list ${e.message}');}
  override function update(elapsed:Float)
  {try{
    super.update(elapsed);
    if (searchField.hasFocus){SetVolumeControls(false);}else{
      SetVolumeControls(true);
      if (controls.BACK)
      {
        ret();
      }

      if (controls.RIGHT_P && FlxG.save.data.charSelShow){
        char.destroy();
        addChar(songs[curSelected]);
        
      }
      if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
      if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
      if (FlxG.keys.pressed.ONE && songs.length > 0){FlxG.switchState(new AnimationDebug(songs[curSelected],true,0));}
      if (FlxG.keys.pressed.TWO && songs.length > 0){FlxG.switchState(new AnimationDebug(songs[curSelected],false,1));}
      if (FlxG.keys.pressed.THREE && songs.length > 0){FlxG.switchState(new AnimationDebug(songs[curSelected],false,2));}

      if (controls.ACCEPT && songs.length > 0)
      {
        switch (Options.PlayerOption.playerEdit){
          case 0:
            FlxG.save.data.playerChar = songs[curSelected];
          case 1:
            FlxG.save.data.opponent = songs[curSelected];
          case 2:
            FlxG.save.data.gfChar = songs[curSelected];
        }
        ret();
      }
    }
  }catch(e) MainMenuState.handleError('Error with charsel "update" ${e.message}');}
  function ret(){
    if (onlinemod.OnlinePlayMenuState.socket != null){FlxG.switchState(new onlinemod.OnlineOptionsMenu());}else{FlxG.switchState(new OptionsMenu());}
  }
  function changeSelection(change:Int = 0)
	{try{
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
	}catch(e) MainMenuState.handleError('Error with charsel "chgsel" ${e.message}');}
  function SetVolumeControls(enabled:Bool)
  {
    if (enabled)
    {
      FlxG.sound.muteKeys = muteKeys;
      FlxG.sound.volumeUpKeys = volumeUpKeys;
      FlxG.sound.volumeDownKeys = volumeDownKeys;
    }
    else
    {
      FlxG.sound.muteKeys = null;
      FlxG.sound.volumeUpKeys = null;
      FlxG.sound.volumeDownKeys = null;
    }
  }
}
