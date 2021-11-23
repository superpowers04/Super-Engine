package;

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
class DirectoryListing extends SearchMenuState{
	var curDirReg:EReg = ~/(.+\/)(.*?\/)/g;
	var dataDir:String = "";
	override function findButton(){
		var nextDir:String = searchField.text;
		if (!FileSystem.exists(nextDir) || !FileSystem.isDirectory(nextDir)){
			// FlxG.sound.play(Paths.sound('cancelMenu'));
			reloadList(true,nextDir);
			searchField.hasFocus = false;
			changeSelection(0);
			return;
		}
		nextDir = (~/[\\]/g).replace(nextDir.toLowerCase(),'/'); // Converts from \ to /
		reloadList(true);
		searchField.hasFocus = false;
		changeSelection(0);
	}
	override function create()
	{
		useAlphabet = false;
		dataDir = Sys.getCwd();
		buttonText["Find"] = "Go to/Search";
		super.create();
		infotext.text = '${infotext.text}; Use LEFT to go back, RIGHT to go into a folder, and Enter to select it.';
		bg.color = 0x0000FF6E;
	}
  override function reloadList(?reload=false,?search = ""){
	try {
		curSelected = 0;
		if(reload){grpSongs.destroy();}
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		songs = [];
		var i:Int = 0;
		try{
			curDirReg.match(dataDir);
			addTitleText(curDirReg.matched(2));
		}catch(e){
			addTitleText(dataDir);
		}
			#if windows
			if (dataDir == "Root"){
				MainMenuState.handleError('Scanning for drives doesnt work yet, due to the developer lacking a Windows system(and 20 gigs) for testing.');
			}else{
			#end
				if (FileSystem.exists(dataDir))
				{
					addToList("../");
					var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i');
					for (directory in FileSystem.readDirectory(dataDir))
					{
						if(!FileSystem.isDirectory('${dataDir}${directory}') || (search != "" && !query.match(directory.toLowerCase())) ) continue;
						addToList(directory + "/");
					}
				}else{
				  MainMenuState.handleError('"${dataDir}" does not exist!');
				}
			#if windows
			}
			#end
		changeSelection(0);
		}catch(e){MainMenuState.handleError('Error while checking directory. ${e.message}');}
  }

  function upDir(){
  	if (curDirReg.match(dataDir)) {
  		dataDir = curDirReg.matched(1);
  		reloadList(true);
  	}else{
  		dataDir = #if windows "Root"; #else dataDir = "/"; #end
  		reloadList(true);
  	}
  }
  function changeDir(path:String){
  	if(path == "../"){upDir();return;}
  	if(dataDir == "Root") dataDir=path; else dataDir = '${dataDir}${path}';
  	reloadList(true);
  }
  function getDir(sel:String):String{
  	if(sel == "../") return dataDir;
  	return '${dataDir}${songs[curSelected]}';
  }
  function selDir(sel:String){
  	trace("REPLACEEEE MEEEE");
  }
  override function handleInput(){
      if (controls.BACK)
      {
        ret();
      }
      if(songs.length == 0) return;
      
      if(controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
      if(controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
      if(controls.LEFT_P){upDir();}
      if(controls.RIGHT_P){changeDir(songs[curSelected]);}
      if (controls.ACCEPT && songs.length > 0)
      {
        	selDir(getDir(songs[curSelected]));
      }
  }

}