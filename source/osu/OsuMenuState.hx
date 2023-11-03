package osu;

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

class OsuMenuState extends onlinemod.OfflineMenuState
{
  var modes:Map<Int,Array<String>> = [];
  var diffText:FlxText;
  var selMode:Int = 0;
  public static var songPath:String = "";

  var songNames:Array<String> = [];
  override function findButton(){
	super.findButton();
	changeDiff();
  }
  override function chartOptions(){
	  openSubState(new OsuQuickOptionsSubState());
  }

  override function create()
  {
	dataDir = TitleState.osuBeatmapLoc;
	scriptSubDirectory = '/osumenu/';
	super.create();
	bg.color = 0x006E006E;
	diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
	diffText.font = CoolUtil.font;
	add(diffText);
	changeDiff();
  }
  override function reloadList(?reload=false,?search = ""){
	curSelected = 0;
	if(reload){grpSongs.destroy();}
	grpSongs = new FlxTypedGroup<Alphabet>();
	add(grpSongs);
	songs = [];
	songNames = [];
	modes = [];
	var i:Int = 0;

	var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
	if (FileSystem.exists(dataDir))
	{
	  var dirs = orderList(FileSystem.readDirectory(dataDir));
	  for (directory in dirs)
	  {
		if ((search == "" || query.match(directory.toLowerCase())) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
		{
		  var name = directory;
		  var nameff = false;
		  modes[i] = [];
		  for (file in FileSystem.readDirectory(dataDir + directory))
		  {
			  if (StringTools.endsWith(file, '.osu')){
				modes[i].push(file);
				if(!nameff){
				  var n = OsuBeatMap.getSettingBM("Title",File.getContent('${dataDir}${directory}/${file}'));
				  if (n != "") name=n;
				}
			  }
		  }
		  if (modes[i][0] == null){ // No charts to load!
			modes[i][0] = "No beatmaps for this song!";
		  }
			songs[i] = dataDir + directory;
			songNames[i] = directory;
			  
		  var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		  controlLabel.isMenuItem = true;
		  controlLabel.targetY = i;
		  if (i != 0)
			controlLabel.alpha = 0.6;
		  grpSongs.add(controlLabel);
		  i++;
		
		}
	  }
	  if (songs.length == 0) MainMenuState.handleError('Unable to find any songs, returned to main menu to prevent crash');
	}else{
	  MainMenuState.handleError('"${TitleState.osuBeatmapLoc}" does not exist!');
	}
  }
  override function select(sel:Int = 0){
	  if (songs[curSelected] == null) {return;}
	  if(modes[curSelected][selMode] == "No beatmaps for this song!"){ // Actually check if the song has no charts when loading, if so then error
		showTempmessage('${songs[curSelected]} has no beatmaps!');
		return;
	  }

	  var songJSON = modes[curSelected][selMode]; // Just for easy access
	  var songName = songNames[curSelected]; // Easy access to var
	  var selSong = songs[curSelected]; // Easy access to var
	  play(songJSON,'${selSong}/${songJSON}');

  }
  static public function play(name:String,path:String){
	try{
		songPath = path.substr(0,path.lastIndexOf("/"));
		PlayState.SONG = OsuBeatMap.loadFromText(sys.io.File.getContent(path));
		if(PlayState.SONG == null){
			return;
		} 
		PlayState.isStoryMode = false;
		PlayState.songDiff = name;
		PlayState.storyDifficulty = 1;

		PlayState.actualSongName = name;
		LoadingScreen.loadAndSwitchState(new OsuPlayState());
	}catch(e){MainMenuState.handleError(e,'Error while loading beatmap ${e.message}');}
  }

  override function extraKeys(){
	if(controls.LEFT_P){changeDiff(-1);}
	if(controls.RIGHT_P){changeDiff(1);}
  }
  function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
	if (songs[curSelected] == null || songs[curSelected] == "") {
	  diffText.text = 'No song selected';
	  return;
	}
	if (forcedInt == -100) selMode += change; else selMode = forcedInt;
	if (selMode >= modes[curSelected].length) selMode = 0;
	if (selMode < 0) selMode = modes[curSelected].length - 1;
	diffText.text = modes[curSelected][selMode];
	diffText.x = 10;
	diffText.scrollFactor.set();
	diffText.setFormat(CoolUtil.font, if (diffText.text.length > 72) 16 else 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

  
  }
	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		changeDiff(0,0);

	}

  override function goOptions(){
	  FlxG.mouse.visible = false;
	  OptionsMenu.lastState = 5;
	  FlxG.switchState(new OptionsMenu());
  }
	public static function fileDrop(file:String){
		try{
			if(file.toLowerCase().endsWith(".osu")){
				play(file.substr(file.lastIndexOf('/')),file);
				return;
			}

			if (!sys.FileSystem.exists(RepoState.unarExe)) {throw("Importing OSZ's require 7-Zip to be installed");return;}
			if (!sys.FileSystem.exists(TitleState.osuBeatmapLoc)) {throw("Importing OSZ's require a valid OSU Stable install");return;}
			RepoState.unzip(file,TitleState.osuBeatmapLoc + file.substring(file.lastIndexOf('/'),file.lastIndexOf('.')));
			FlxG.switchState(new OsuMenuState());
		}catch(e){MainMenuState.handleError(e,'Unable to ${if(file != null && file.toLowerCase().endsWith(".osz") ) "extract and load osz" else "import beatmap"}');}
	}
}


class OsuQuickOptionsSubState extends QuickOptionsSubState{
  override function saveSettings(){
	QuickOptionsSubState.osuSettings = settings;
  }
  override function loadSettings(){
	settings = QuickOptionsSubState.osuSettings;
  }
}