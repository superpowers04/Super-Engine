package onlinemod;

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

class OfflineMenuState extends MusicBeatState
{
  var curSelected:Int = 0;
  var searchField:FlxInputText;
  var searchButton:FlxUIButton;

  var songs:Array<String> = [];
  var songFiles:Array<String> = [];
  var songDirs:Array<String> = [];
  var grpSongs:FlxTypedGroup<Alphabet>;
  var dataDir:String = "assets/onlinedata/data/";
  public static var optionsButton:FlxUIButton;
  var muteKeys = FlxG.sound.muteKeys;
  var volumeUpKeys = FlxG.sound.volumeUpKeys;
  var volumeDownKeys = FlxG.sound.volumeDownKeys;
  var bg:FlxSprite;
  function findButton(){
      refreshList(true,searchField.text);
      searchField.hasFocus = false;
  }
  override function create()
  {
    bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
    
    add(bg);
    searchField = new FlxInputText(10, 100, 1152, 20);
    searchField.maxLength = 81;
    add(searchField);

    searchButton = new FlxUIButton(10 + 1152 + 9, 100, "Find", findButton);
    searchButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    searchButton.resize(100, searchField.height);
    add(searchButton);



    

    refreshList();

    FlxG.mouse.visible = true;
    FlxG.autoPause = true;


    super.create();

    optionsButton = new FlxUIButton(1100, 40, "Options", () -> {
      FlxG.mouse.visible = false;
      FlxG.switchState(new OfflineOptionsMenu());
    });
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(150, 30);
    add(optionsButton);
  }
  function refreshList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];
    songFiles = [];
    var i:Int = 0;
    if (FileSystem.exists(dataDir))
    {
      for (directory in FileSystem.readDirectory(dataDir))
      {
        for (file in FileSystem.readDirectory(dataDir + directory))
        {
          if (StringTools.endsWith(file, '.json') && (search == "" || FlxStringUtil.contains(file.toLowerCase(),search.toLowerCase()))) // Handles searching
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
  override function update(elapsed:Float)
  {
    super.update(elapsed);
    if (searchField.hasFocus){SetVolumeControls(false);}else{
      SetVolumeControls(true);
      handleInput();
    }
  }
  function handleInput(){
      if (controls.BACK)
      {
        FlxG.switchState(new MainMenuState());
      }

        if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
        if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

      if (controls.ACCEPT && songs.length > 0)
      {
          gotoSong();
      }
  }
  function gotoSong(){
      PlayState.SONG = Song.parseJSONshit(File.getContent(songs[curSelected]));
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

  function changeSelection(change:Int = 0)
	{
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
	}
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

class OfflineOptionsMenu extends OptionsMenu{
  override function goBack(){
    FlxG.switchState(new OfflineMenuState());
  }
}