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

class StageSelection extends SearchMenuState
{

  override function create()
  {try{
    searchList = TitleState.choosableStages;
    super.create();
  }catch(e) MainMenuState.handleError('Error with stagesel "create" ${e.message}');}
  override function select(sel:Int = 0){
    FlxG.save.data.selStage = songs[sel];
  }
}
