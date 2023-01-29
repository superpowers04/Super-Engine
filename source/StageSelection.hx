package;
// About 90% of code used from OfflineMenuState
import TitleState;
import flixel.FlxG;
import flixel.util.FlxColor;

using StringTools;

class StageSelection extends SearchMenuState
{
	var stageIDs:Array<String> = ['default'];
	override function reloadList(?reload = false,?search=""){try{
		curSelected = 0;
		if(reload){CoolUtil.clearFlxGroup(grpSongs);}
		songs = [];
		stageIDs = [];
		searchList = [];

		var i:Int = 0;
		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i');
		// for (i => char in chars){
		// 	if(search == "" || query.match(char[0].toLowerCase()) ){
		// 		_addToList(char,i);
		// 	}
		// }
		_addToList("default",0,"default");
		var i = TitleState.stages.length;
		var itemIndex = 1;
		var stage:StageInfo = null;
		while (i > 0){
			i--;
			stage = TitleState.stages[i];
			if(stage == null || (search != "" && !query.match(stage.folderName.toLowerCase())) ) continue;
			_addToList(stage.folderName,itemIndex,stage.getNamespacedName());
			itemIndex++;
			searchList.push(stage.folderName);
		}
	}catch(e) MainMenuState.handleError('Error with loading stage list ${e.message}');}

	function _addToList(char:String,i:Int = 0,id:String = ""){
		songs.push(char);
		stageIDs.push(id);
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		if(id == FlxG.save.data.selStage){
			controlLabel.color = FlxColor.GREEN;
		}
		grpSongs.add(controlLabel);
	}
	override function create()
	{try{
		searchList = ['default'];
		var i = TitleState.stages.length;
		var stage:StageInfo = null;
		// while (i > 0){
		// 	i--;
		// 	stage = TitleState.stages[i];
		// 	if(stage == null) continue;
		// 	stageIDs.push(stage.getNamespacedName());
			
		// }
		retAfter = true;
		super.create();
	}catch(e) MainMenuState.handleError('Error with stagesel "create" ${e.message}');}
	override function select(sel:Int = 0){
		FlxG.save.data.selStage = stageIDs[sel];
	}
}
