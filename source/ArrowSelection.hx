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

class ArrowSelection extends SearchMenuState
{
  override function create()
  {try{
    { // Looks for all notes, This will probably be rarely accessed, so loading like this shouldn't be a problem
      searchList = ["default"];
      var dataDir:String = Sys.getCwd() + "mods/noteassets/";
      var customArrows:Array<String> = [];
      if (FileSystem.exists(dataDir))
      {
        for (file in FileSystem.readDirectory(dataDir))
        {
          if (file.endsWith(".png") && !file.endsWith("-bad.png") && !file.endsWith("splash.png")){
            var name = file.substr(0,-4);
            if (FileSystem.exists('${dataDir}${name}.xml'))
            {
              customArrows.push(name);

            }
          }
        }
      }else{MainMenuState.handleError('mods/noteassets is not a folder!');}
      // customCharacters.sort((a, b) -> );
      haxe.ds.ArraySort.sort(customArrows, function(a, b) {
             if(a < b) return -1;
             else if(b > a) return 1;
             else return 0;
          });
      for (char in customArrows){
        searchList.push(char);
      }
    }
    super.create();
  }catch(e) MainMenuState.handleError('Error with notesel "create" ${e.message}');}
  override function select(sel:Int = 0){
    FlxG.save.data.noteAsset = songs[curSelected];

  }
}