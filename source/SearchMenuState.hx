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

class SearchMenuState extends MusicBeatState
{
  var curSelected:Int = 0;

  var songs:Array<String> = []; // Is the character list, just too lazy to rename
  var grpSongs:FlxTypedGroup<Alphabet>;
  var posX:Int = Std.int(FlxG.width * 0.7);
  var posY:Int = 0;
  var searchField:FlxInputText;
  var searchButton:FlxUIButton;
  var muteKeys = FlxG.sound.muteKeys;
  var volumeUpKeys = FlxG.sound.volumeUpKeys;
  var volumeDownKeys = FlxG.sound.volumeDownKeys;
  var searchList:Array<String> = ["this should be replaced"];

  function findButton(){
      reloadList(true,searchField.text);
      searchField.hasFocus = false;
  }
  override function create()
  {try{
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
    add(bg);
    reloadList();
    //Searching
    searchField = new FlxInputText(10, 100, 1152, 20);
    searchField.maxLength = 81;
    add(searchField);

    searchButton = new FlxUIButton(10 + 1152 + 9, 100, "Find", findButton);
    searchButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    searchButton.resize(100, searchField.height);
    add(searchButton);

    var infotexttxt:String = "Hold shift to scroll faster";
    var infotext = new FlxText(5, FlxG.height - 40, 0, infotexttxt, 12);
    infotext.scrollFactor.set();
    infotext.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    var blackBorder = new FlxSprite(-30,FlxG.height - 40).makeGraphic((Std.int(infotext.width + 900)),Std.int(infotext.height + 600),FlxColor.BLACK);
    blackBorder.alpha = 0.5;

    add(blackBorder);
    add(infotext);
    FlxG.mouse.visible = true;
    FlxG.autoPause = true;

    super.create();
  }catch(e) MainMenuState.handleError('Error with searchmenu "create" ${e.message}');}


  function reloadList(?reload = false,?search=""){try{
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];

    var i:Int = 0;
    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    for (char in searchList){
      if(search == "" || query.match(char.toLowerCase()) ){
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
  }catch(e) MainMenuState.handleError('Error with loading stage list ${e.message}');}
  override function update(elapsed:Float)
  {try{
    super.update(elapsed);
    if (searchField.hasFocus){SetVolumeControls(false);if (FlxG.keys.pressed.ENTER) findButton();}else{
      SetVolumeControls(true);
      if (controls.BACK)
      {
        ret();
      }
      if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
      if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

      if (controls.ACCEPT && songs.length > 0)
      {
        select(curSelected);
        ret();
      }
    }
  }catch(e) MainMenuState.handleError('Error with searchmenu "update" ${e.message}');}
  function select(sel:Int = 0){
    trace("You forgot to replace the select function!");
  }
  function ret(){
    FlxG.mouse.visible = false;
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
	}catch(e) MainMenuState.handleError('Error with searchmenu "chgsel" ${e.message}');}
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