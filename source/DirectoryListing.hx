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

	override public function onTextInputFocus(object:Dynamic){}
	override public function onTextInputUnfocus(object:Dynamic){}
	override function findButton(){
		final nextDir:String = searchField.text;
		if (!FileSystem.exists(nextDir) || !FileSystem.isDirectory(nextDir)){
			// SELoader.playSound('assets:sounds/cancelMenu.ogg');
			reloadList(true,nextDir);
			searchField.hasFocus = false;
			changeSelection(0);
			return;
		}
		// nextDir = (~/[\\]/g).replace(nextDir.toLowerCase(),'/'); // Converts from \ to /
		reloadList(true);
		searchField.hasFocus = false;
		changeSelection(0);
	}
	override function create() {
		checkInputFocus = false;
		useAlphabet = false;
		dataDir = SELoader.getPath();
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
		try{
			curDirReg.match(dataDir);
			addTitleText(curDirReg.matched(2));
		}catch(e){
			addTitleText(dataDir);
		}
		#if windows
		if (dataDir == "Root"){
			MainMenuState.handleError('Scanning for drives doesnt work yet, due to the developer lacking a Windows system(and 20 gigs) for testing.');
			return;
		}
		#end
		if (FileSystem.exists(dataDir)) {
			addToList("../");
			final query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i');
			for (directory in FileSystem.readDirectory(dataDir))
			{
				if(!FileSystem.isDirectory('${dataDir}${directory}') || (search != "" && !query.match(directory.toLowerCase())) ) continue;
				addToList(directory + "/");
			}
		}else{
		  MainMenuState.handleError('"${dataDir}" does not exist!');
		}
		changeSelection(0);
		}catch(e){MainMenuState.handleError(e,'Error while checking directory. ${e.message}');}
	}

	@:keep inline function upDir(){
		dataDir = curDirReg.match(dataDir) ? curDirReg.matched(1) : #if windows "Root"; #else dataDir = "/"; #end
		reloadList(true);
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
		if (controls.BACK) ret();
		if (songs.length == 0) return;
		
		if (controls.UP_P) changeSelection(FlxG.keys.pressed.SHIFT ? -5 :-1);
		if (controls.DOWN_P) changeSelection(FlxG.keys.pressed.SHIFT ? 5 :1);
		if (controls.LEFT_P) upDir();
		if (controls.RIGHT_P) changeDir(songs[curSelected]);
		if (controls.ACCEPT && songs.length > 0) selDir(getDir(songs[curSelected]));
	}

}