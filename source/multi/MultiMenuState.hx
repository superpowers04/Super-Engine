package multi;

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

class MultiMenuState extends onlinemod.OfflineMenuState
{
  var modes:Map<Int,Array<String>> = [];
  var diffText:FlxText;
  var selMode:Int = 0;
  var blockedFiles:Array<String> = [];

  var songNames:Array<String> = ['picospeaker.json','meta.json','config.json'];
  override function findButton(){
    super.findButton();
    changeDiff();
  }
  override function create()
  {
    dataDir = "mods/charts/";
    super.create();
    bg.color = 0x0000FF6E;
    diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
    diffText.font = Paths.font("vcr.ttf");
    add(diffText);
    changeDiff();
  }
  override function refreshList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];
    modes = [];
    var i:Int = 0;

    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    if (FileSystem.exists(dataDir))
    {
      for (directory in FileSystem.readDirectory(dataDir))
      {
        if (search == "" || query.match(directory.toLowerCase())) // Handles searching
        {
        if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){

          songs.push(dataDir + directory);
          songNames.push(directory);
              
          var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, directory, true, false);
          controlLabel.isMenuItem = true;
          controlLabel.targetY = i;
          modes[i] = [];
          if (i != 0)
            controlLabel.alpha = 0.6;
          grpSongs.add(controlLabel);
          for (file in FileSystem.readDirectory(dataDir + directory))
          {
              if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
                modes[i].push(file);
              }
          }
          i++;
        }
      }
    }}else{
      MainMenuState.handleError('"/mods/charts" does not exist!');
    }
  }
  override function gotoSong(){
      try{

      var songJSON = modes[curSelected][selMode]; // Just for easy access
      var songName = songNames[curSelected]; // Easy access to var
      var selSong = songs[curSelected]; // Easy access to var
      onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
      // PlayState.SONG = Song.parseJSONshit(File.getContent('${selSong}/${songJSON}'));
      PlayState.isStoryMode = false;
      // Set difficulty
      PlayState.songDiff = songJSON;
      PlayState.storyDifficulty = switch(songJSON){case '${songName}-easy.json': 0; case '${songName}-hard.json': 2; default: 1;};
      // if (StringTools.endsWith(songs[curSelected], '-hard.json'))
      // {
      //   songName = songName.substr(0,songName.indexOf('-hard.json'));
      //   PlayState.storyDifficulty = 2;
      // }
      // else if (StringTools.endsWith(songs[curSelected], '-easy.json'))
      // {
      //   songName = songName.substr(0,songName.indexOf('-easy.json'));
      //   PlayState.storyDifficulty = 0;
      // }
      PlayState.actualSongName = songName;
      MultiPlayState.voicesFile = '${selSong}/Voices.ogg';
      MultiPlayState.instFile = '${selSong}/Inst.ogg';
      LoadingState.loadAndSwitchState(new MultiPlayState());
      }catch(e){
        MainMenuState.handleError('Error while loading chart ${e.message}');
      }
  }
  override function handleInput(){
      if (controls.BACK)
      {
        FlxG.switchState(new MainMenuState());
      }

      if(controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
      if(controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
      if(controls.LEFT_P){changeDiff(-1);}
      if(controls.RIGHT_P){changeDiff(1);}
      if (controls.ACCEPT && songs.length > 0)
      {
          gotoSong();
      }
  }
  function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
    if (forcedInt == -100) selMode += change; else selMode = forcedInt;
    if (selMode >= modes[curSelected].length) selMode = 0;
    if (selMode < 0) selMode = modes[curSelected].length - 1;
    diffText.text = modes[curSelected][selMode];

  }
  override function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		if (curSelected >= grpSongs.length)
			curSelected = 0;

    if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);


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
}

class OfflineOptionsMenu extends OptionsMenu{
  override function goBack(){
    FlxG.switchState(new MultiMenuState());
  }
}