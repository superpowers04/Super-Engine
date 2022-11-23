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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import sys.io.File;
import sys.FileSystem;
import TitleState;

using StringTools;

class CharSelection extends SearchMenuState
{
	var defText:String = "Use shift to scroll faster";
	var uiIcon:HealthIcon;
	var curChar = "";
	var curCharID = 0;
	// Type
	// -1 = automatic
	// 0 = valid
	// 1 = invalid
	var chars:Array<Array<Dynamic>> = []; // [NAME,TYPE,ID,DESCRIPTION,OBJ]
	var charIDList:Array<Int> = [];

	override function reloadList(?reload = false,?search=""){try{
		curSelected = 0;
		if(reload){CoolUtil.clearFlxGroup(grpSongs);}
		songs = [];
		charIDList = [];
		searchList = songs;

		var i:Int = 0;
		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i');
		for (i => char in chars){
			if(search == "" || query.match(char[0].toLowerCase()) ){
				_addToList(char,i);
			}
		}
	}catch(e) MainMenuState.handleError('Error with loading stage list ${e.message}');}
	function _addToList(char:Array<Dynamic>,i:Int = 0){
		songs.push(char[0]);
		charIDList.push(i);
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char[0], true, false);
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		if(char[0] == curChar){
			curCharID = i;
			controlLabel.color = FlxColor.GREEN;
		}
		if(char[1] == 1){
			controlLabel.color = FlxColor.RED;
		}
		grpSongs.add(controlLabel);
	}

	override function create()
	{try{
		switch (Options.PlayerOption.playerEdit){
			case 0:
				curChar = FlxG.save.data.playerChar;
			case 1:
				curChar = FlxG.save.data.opponent;
			case 2:
				curChar = FlxG.save.data.gfChar;
		}
		chars = [];
		if (Options.PlayerOption.playerEdit == 0){chars.push(['automatic',-1,'Automatically choose whatever BF is suitable for the chart']);}
		searchList = [];
		if(TitleState.invalidCharacters.length > 0 && onlinemod.OnlinePlayMenuState.socket == null){
			for (i => v in TitleState.invalidCharacters) {
				chars.push([v.id,1,i,null,v]);
			}
		}
		for (i => v in TitleState.characters) {
			chars.push([v.id,0,i,v.description,v]);
		}

		
		super.create();
		var title = "";
		switch (Options.PlayerOption.playerEdit){
			case 0: title="Change BF";bg.color = 0x007799;
			case 1: title="Change Opponent";bg.color = 0x600060;
			case 2: title="Change GF";bg.color = 0x771521;
			default: title= "You found a 'secret', You should exit this menu to prevent further 'secret's";bg.color = 0xff0000;
		}



		if (title != "") addTitleText(title);
		if (onlinemod.OnlinePlayMenuState.socket == null) defText = "Use shift to scroll faster, Animation Debug keys: 1=bf,2=dad,3=gf";
		uiIcon = new HealthIcon("bf",Options.PlayerOption.playerEdit == 0);
		uiIcon.x = FlxG.width * 0.8;
		uiIcon.y = FlxG.height * 0.2;
		add(uiIcon);
		FlxTween.angle(uiIcon, -40, 40, 1.12, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(uiIcon, {"scale.x": 1.25,"scale.y": 1.25}, 1.50, {ease: FlxEase.quadInOut, type: PINGPONG});  
		changeSelection(curCharID); 

	}catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}
	override function extraKeys(){
		var curSelected =getChar();
		if (chars[curSelected] != null && chars[curSelected][1] != -1 && onlinemod.OnlinePlayMenuState.socket == null){
			var _char = formatChar(chars[curSelected]);
			if (FlxG.keys.justPressed.ONE)  {LoadingState.loadAndSwitchState(new AnimationDebug(_char,true ,0,true));}
			if (FlxG.keys.justPressed.TWO)  {LoadingState.loadAndSwitchState(new AnimationDebug(_char,false,1,true));}
			if (FlxG.keys.justPressed.THREE){LoadingState.loadAndSwitchState(new AnimationDebug(_char,false,2,true));}
		}
	}
	inline function formatChar(char:Array<Dynamic>):String{
		return ((if(char[1] == 1)"INVALID|" else if(char[4] != null && char[4].nameSpace != null) '${char[4].namespace}|' else "") +'${char[0]}');
	}
	inline function getChar(){
		return charIDList[curSelected];
	}
	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		retAfter = true;
		var curSelected =getChar();

		// if (songs[curSelected] != "" && TitleState.invalidCharacters.contains(songs[curSelected])){
		// 	grpSongs.members[curSelected].color = FlxColor.RED;
		// 	updateInfoText();
		// }else 
		if (chars[curSelected] != null && chars[curSelected][3] != null ){
			updateInfoText('${defText}; ' + chars[curSelected][3]);
		}else if (chars[curSelected] != null &&chars[curSelected][1] == 1 ){
			updateInfoText('${defText}; This character is invalid, you need to set them up in Animation Debug. To set them up now, press 1 for BF, 2 for dad, 3 for GF. If you need help please ask on my Discord, you can access it from the changelog screen');
		}else{
			updateInfoText('${defText}; No description for this character.');
		}
		uiIcon.changeSprite(formatChar(chars[curSelected]),'face',false,(if(chars[curSelected][4] != null) chars[curSelected][4].path else null) );
	}

	override function select(sel:Int = 0){
		var curSelected =getChar();
		if(chars[curSelected][1] == 1){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(grpSongs.members[curSelected], {x: grpSongs.members[curSelected].x + 100}, 0.4, {ease: FlxEase.bounceInOut,onComplete: function(twn:FlxTween){return;}});
			FlxTween.tween(infotext, {alpha:0}, 0.2, {ease: FlxEase.quadInOut,onComplete: function(twn:FlxTween){FlxTween.tween(infotext, {alpha:1}, 0.2, {ease: FlxEase.quadInOut,onComplete: function(twn:FlxTween){return;}});}});
			if(grpSongs.members[curSelected].x > 500){
				updateInfoText('This character\'s invalid dammit! To set them up now, press 1 for BF, 2 for dad, 3 for GF. If you need help please ask on my Discord, you can access it from the changelog screen');
			}
			retAfter = false;
			return;
		}
		var _char =formatChar(chars[curSelected]);

		switch (Options.PlayerOption.playerEdit){
		case 0:
			FlxG.save.data.playerChar = _char;
		case 1:
			FlxG.save.data.opponent = _char;
		case 2:
			FlxG.save.data.gfChar = _char;
		}
	}
}