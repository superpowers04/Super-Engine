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

class CharSelection extends SearchMenuState
{

  override function create()
  {try{
    searchList = TitleState.choosableCharacters;
    super.create();
  }catch(e) MainMenuState.handleError('Error with stagesel "create" ${e.message}');}
  override function select(sel:Int = 0){
    switch (Options.PlayerOption.playerEdit){
      case 0:
        FlxG.save.data.playerChar = songs[curSelected];
      case 1:
        FlxG.save.data.opponent = songs[curSelected];
      case 2:
        FlxG.save.data.gfChar = songs[curSelected];
    }
  }
}