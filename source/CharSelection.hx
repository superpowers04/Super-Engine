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

using StringTools;

class CharSelection extends SearchMenuState
{
	var defText:String = "Use shift to scroll faster";
	var uiIcon:HealthIcon;
	override function create()
	{try{
	// searchList = TitleState.choosableCharacters;
	searchList = [];
	for (i in TitleState.choosableCharacters) {
		searchList.push(i);
	}
	if(TitleState.invalidCharacters.length > 0){
		for (i in 0 ... TitleState.invalidCharacters.length) {
			searchList.insert(0,TitleState.invalidCharacters[i]);
		}
	}
	if (Options.PlayerOption.playerEdit == 0){
		if(!searchList.contains("automatic")) searchList.insert(0,"automatic");
	} else if (searchList.contains("automatic")) searchList.remove("automatic");
	super.create();
	var title = "";
	switch (Options.PlayerOption.playerEdit){
		case 0: title="Change BF";
		case 1: title="Change Opponent";
		case 2: title="Change GF";
		default: title= "You found a secret, You should exit this menu to prevent further 'secrets'";
	}



	if (title != "") addTitleText(title);
	if (onlinemod.OnlinePlayMenuState.socket == null) defText =  "Use shift to scroll faster, Animation Debug keys: 1=bf,2=dad,3=gf";
	uiIcon = new HealthIcon("bf",Options.PlayerOption.playerEdit == 0);
	uiIcon.x = FlxG.width * 0.8;
	uiIcon.y = FlxG.height * 0.2;
	add(uiIcon);
	FlxTween.angle(uiIcon, -40, 40, 1.12, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
	FlxTween.tween(uiIcon, {"scale.x": 1.25,"scale.y": 1.25}, 1.50, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});  
	// changeSelection();
	{
		var curChar = "";
		switch (Options.PlayerOption.playerEdit){
			case 0:
				curChar = FlxG.save.data.playerChar;
			case 1:
				curChar = FlxG.save.data.opponent;
			case 2:
				curChar = FlxG.save.data.gfChar;
		}
		var charID = searchList.indexOf(curChar);
		changeSelection(if (charID >= 0) charID else 0); 
	}
	}catch(e) MainMenuState.handleError('Error with charsel "create" ${e.message}');}
	override function extraKeys(){
	if (songs[curSelected] != "automatic" && songs[curSelected] != "" && onlinemod.OnlinePlayMenuState.socket == null){
		if (FlxG.keys.justPressed.ONE){FlxG.switchState(new AnimationDebug(songs[curSelected],true,0,true));}
		if (FlxG.keys.justPressed.TWO){FlxG.switchState(new AnimationDebug(songs[curSelected],false,1,true));}
		if (FlxG.keys.justPressed.THREE){FlxG.switchState(new AnimationDebug(songs[curSelected],false,2,true));}
		}
	}
	override function changeSelection(change:Int = 0){
	super.changeSelection(change);
	retAfter = true;

		if (songs[curSelected] != "" && TitleState.invalidCharacters.contains(songs[curSelected])){
			grpSongs.members[curSelected].color = FlxColor.RED;
			updateInfoText('This character is invalid, you need to set them up in Animation Debug. To set them up now, press 1 for BF, 2 for dad, 3 for GF. If you need help please ask on my Discord, you can access it from the changelog screen');
		}else if (songs[curSelected] != "" && TitleState.characterDescriptions[songs[curSelected]] != null && TitleState.characterDescriptions[songs[curSelected]] != "" ){
			updateInfoText('${defText}; ' + TitleState.characterDescriptions[songs[curSelected]]);
		}else{
			updateInfoText('${defText}; No description for this character.');
		}
		uiIcon.changeSprite(songs[curSelected],'face',false);
	}

	override function select(sel:Int = 0){
	if(TitleState.invalidCharacters.contains(songs[curSelected])){
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