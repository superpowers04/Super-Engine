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
  var defText:String = "Use shift to scroll faster";
  override function create()
  {try{
    searchList = TitleState.choosableCharacters;
    if (Options.PlayerOption.playerEdit == 0){
      if(!searchList.contains("automatic")) searchList.insert(0,"automatic");
    } else if (searchList.contains("automatic")) searchList.remove("automatic");
    super.create();
    var title = "";
    switch (Options.PlayerOption.playerEdit){
      case 0: title="Change BF";
      case 1: title="Change Opponent";
      case 2: title="Change GF";
      default: title= "You found a secret, You should exit this menu";
    }
    if (title != "") addTitleText(title);
    if (onlinemod.OnlinePlayMenuState.socket == null) defText =  "Use shift to scroll faster, Animation Debug keys: 1=bf,2=dad,3=gf";
    changeSelection();
  }catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}
  override function extraKeys(){
    if (songs[curSelected] != "automatic" && onlinemod.OnlinePlayMenuState.socket == null){
        if (FlxG.keys.justPressed.ONE){FlxG.switchState(new AnimationDebug(songs[curSelected],true,0,true));}
        if (FlxG.keys.justPressed.TWO){FlxG.switchState(new AnimationDebug(songs[curSelected],false,1,true));}
        if (FlxG.keys.justPressed.THREE){FlxG.switchState(new AnimationDebug(songs[curSelected],false,2,true));}
      }
  }
  override function changeSelection(change:Int = 0){
    super.changeSelection(change);

    if (songs[curSelected] != "" && TitleState.characterDescriptions[songs[curSelected]] != null && TitleState.characterDescriptions[songs[curSelected]] != "" ){
      updateInfoText('${defText}; ' + TitleState.characterDescriptions[songs[curSelected]]);
    }else{
      updateInfoText('${defText}; No description for this character.');
    }
  }
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