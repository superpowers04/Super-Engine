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
	var descriptions:Map<String,String> = [];
	var chars:Map<String,CharInfo> = [];
	var invalid:Array<String> = [];
	override function addToList(char:String,i:Int = 0){
		songs.push(char);
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		if(invalid.contains(char)){
			controlLabel.color = FlxColor.RED;
		}
		if(char == curChar){
			controlLabel.color = FlxColor.GREEN;
		}
		grpSongs.add(controlLabel);
	}
	override function create()
	{try{
	// searchList = TitleState.choosableCharacters;
	switch (Options.PlayerOption.playerEdit){
		case 0:
			curChar = FlxG.save.data.playerChar;
		case 1:
			curChar = FlxG.save.data.opponent;
		case 2:
			curChar = FlxG.save.data.gfChar;
	}
	searchList = [];
	descriptions = [];
	if(TitleState.invalidCharacters.length > 0){
		for (i in 0 ... TitleState.invalidCharacters.length) {
			invalid.push(TitleState.invalidCharacters[i][0]);
			searchList.push(TitleState.invalidCharacters[i][0]);
			descriptions[TitleState.invalidCharacters[i][0]] = 'This character is invalid, you need to set them up in Animation Debug. To set them up now, press 1 for BF, 2 for dad, 3 for GF. If you need help please ask on my Discord, you can access it from the changelog screen';
		}
	}
	for (i => v in TitleState.characters) {
		searchList[invalid.length + i - 1] = v.id;
		chars[ v.id] = v;
		descriptions[v.id] = v.description;
	}

	if (Options.PlayerOption.playerEdit == 0){
		if(!searchList.contains("automatic")){searchList.insert(0,"automatic");descriptions['automatic'] = 'Automatically choose whatever BF is suitable for the chart';}
	} else if (searchList.contains("automatic")) searchList.remove("automatic");
	super.create();
	var title = "";
	switch (Options.PlayerOption.playerEdit){
		case 0: title="Change BF";bg.color = 0x007799;
		case 1: title="Change Opponent";bg.color = 0x600060;
		case 2: title="Change GF";bg.color = 0x771521;
		default: title= "You found a 'secret', You should exit this menu to prevent further 'secret's";bg.color = 0xff0000;
	}



	if (title != "") addTitleText(title);
	if (onlinemod.OnlinePlayMenuState.socket == null) defText =  "Use shift to scroll faster, Animation Debug keys: 1=bf,2=dad,3=gf";
	uiIcon = new HealthIcon("bf",Options.PlayerOption.playerEdit == 0);
	uiIcon.x = FlxG.width * 0.8;
	uiIcon.y = FlxG.height * 0.2;
	add(uiIcon);
	FlxTween.angle(uiIcon, -40, 40, 1.12, {ease: FlxEase.quadInOut, type: PINGPONG});
	FlxTween.tween(uiIcon, {"scale.x": 1.25,"scale.y": 1.25}, 1.50, {ease: FlxEase.quadInOut, type: PINGPONG});  
	// changeSelection();
	{
		var charID = searchList.indexOf(curChar);
		changeSelection(if (charID >= 0) charID else 0); 
	}

	}catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}
	override function extraKeys(){
	if (songs[curSelected] != "automatic" && songs[curSelected] != "" && onlinemod.OnlinePlayMenuState.socket == null){
		if (FlxG.keys.justPressed.ONE){LoadingState.loadAndSwitchState(new AnimationDebug(songs[curSelected],true,0,true));}
		if (FlxG.keys.justPressed.TWO){LoadingState.loadAndSwitchState(new AnimationDebug(songs[curSelected],false,1,true));}
		if (FlxG.keys.justPressed.THREE){LoadingState.loadAndSwitchState(new AnimationDebug(songs[curSelected],false,2,true));}
		}
	}
	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		retAfter = true;

		// if (songs[curSelected] != "" && TitleState.invalidCharacters.contains(songs[curSelected])){
		// 	grpSongs.members[curSelected].color = FlxColor.RED;
		// 	updateInfoText();
		// }else 
		if (songs[curSelected] != "" && descriptions[songs[curSelected]] != null ){
			updateInfoText('${defText}; ' + descriptions[songs[curSelected]]);
		}else{
			updateInfoText('${defText}; No description for this character.');
		}
		uiIcon.changeSprite(songs[curSelected],'face',false,(if(chars[songs[curSelected]] != null) chars[songs[curSelected]].path else null) );
	}

	override function select(sel:Int = 0){
	if(curSelected < TitleState.invalidCharacters.length + 1 && invalid.contains(songs[curSelected])){
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxTween.tween(grpSongs.members[curSelected], {x: grpSongs.members[curSelected].x + 100}, 0.4, {ease: FlxEase.bounceInOut,onComplete: function(twn:FlxTween){return;}});
		FlxTween.tween(infotext, {alpha:0}, 0.2, {ease: FlxEase.quadInOut,onComplete: function(twn:FlxTween){FlxTween.tween(infotext, {alpha:1}, 0.2, {ease: FlxEase.quadInOut,onComplete: function(twn:FlxTween){return;}});}});
		if(grpSongs.members[curSelected].x > 500){
			updateInfoText('What did that text ever do to you to deserve this much shaking?');
		}
		retAfter = false;
		return;
	}

		switch (Options.PlayerOption.playerEdit){
		case 0:
			FlxG.save.data.playerChar = songs[curSelected];
		case 1:
			FlxG.save.data.opponent = songs[curSelected];
		case 2:
			FlxG.save.data.gfChar = songs[curSelected];
		}
	}
}