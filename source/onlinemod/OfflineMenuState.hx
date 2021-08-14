package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIText;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class OfflineMenuState extends SearchMenuState
{
  var sideButton:FlxUIButton;

  // var songs:Array<String> = [];
  var songFiles:Array<String> = [];
  var songDirs:Array<String> = [];
  var dataDir:String = "assets/onlinedata/data/";
  var optionsButton:FlxUIButton;
  var invertedChart:Bool = false;

  function goOptions(){
      FlxG.mouse.visible = false;
      OptionsMenu.lastState = 3;
      FlxG.switchState(new OptionsMenu());
  }
  override function create()
  {



    super.create();
    optionsButton = new FlxUIButton(1100, 40, "Options", goOptions);
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(150, 30);
    add(optionsButton);
    sideButton = new FlxUIButton(1050, 160, "Chart Options", () -> {
      openSubState(new QuickOptionsSubState(0,0));
    });
    sideButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    sideButton.resize(150, 60);
    add(sideButton);
  }
  override function reloadList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];
    songFiles = [];
    var i:Int = 0;

    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    if (FileSystem.exists(dataDir))
    {
      for (directory in FileSystem.readDirectory(dataDir))
      {
        for (file in FileSystem.readDirectory(dataDir + directory))
        {
          if ( StringTools.endsWith(file, '.json') && (search == "" || query.match(file.toLowerCase())) ) // Handles searching
          {
            songs.push(dataDir + directory + "/" + file);
            songFiles.push(file);
            songDirs.push(directory);

            var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, file.substr(0, file.length - 5), true, false);
            controlLabel.isMenuItem = true;
            controlLabel.targetY = i;
            if (i != 0)
              controlLabel.alpha = 0.6;
            grpSongs.add(controlLabel);

            i++;
          }
        }
      }
    }
  }

  override function ret(){
    FlxG.mouse.visible = false;
    FlxG.switchState(new MainMenuState());
  }
  override function select(sel:Int = 0){
      OfflinePlayState.chartFile = songs[curSelected];
      PlayState.isStoryMode = false;
      var songName = songFiles[curSelected];
      PlayState.songDir = songDirs[curSelected];
      // Set difficulty
      PlayState.storyDifficulty = 1;
      if (StringTools.endsWith(songs[curSelected], '-hard.json'))
      {
        songName = songName.substr(0,songName.indexOf('-hard.json'));
        PlayState.storyDifficulty = 2;
      }
      else if (StringTools.endsWith(songs[curSelected], '-easy.json'))
      {
        songName = songName.substr(0,songName.indexOf('-easy.json'));
        PlayState.storyDifficulty = 0;
      }
      PlayState.actualSongName = songName;

      LoadingState.loadAndSwitchState(new OfflinePlayState());
  }
}
