package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUIText;
import flixel.math.FlxRandom;

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
  function chartOptions(){
      openSubState(new QuickOptionsSubState());
  }
  static var attempted:Bool = false;
  override function create()
  {

    optionsButton = new FlxUIButton(1120, 30, "Options", goOptions);
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(150, 30);
    sideButton = new FlxUIButton(1020, 65, "Chart Options", chartOptions);
    sideButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    sideButton.resize(250, 30);


    super.create();
    try{
    add(optionsButton);
    add(sideButton);
    }catch(e){
    	if(attempted){
    		MainMenuState.handleError(e,"Error while trying to create state, " + e.message);
    		attempted = false;
    		return;
    	}
    	attempted = true;
    	Main.game.forceStateSwitch(new OfflineMenuState()); // Try to load the state again
    	return;
    }
    attempted = false;
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
      var dirs = orderList(FileSystem.readDirectory(dataDir));
      for (directory in dirs)
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
  override function extraKeys(){
    if (FlxG.keys.justPressed.R){
      changeSelection(Math.floor(songs.length * Math.random()));
    }
    optionsButton.label.color = (if(FlxG.keys.pressed.SHIFT) 0xFF222222 else 0xFF000000);
    sideButton.label.color = (if(FlxG.keys.pressed.SHIFT) 0xFF222222 else 0xFF000000);

    if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.O){
      goOptions();
    }
    if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.C){
      chartOptions();
    }

  }
  override function select(sel:Int = 0){
      OfflinePlayState.chartFile = songs[curSelected];
      PlayState.songScript = "";
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
