package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;

import sys.io.File;
import sys.FileSystem;
import flixel.math.FlxMath;

using StringTools;

class SearchMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var songs:Array<String> = []; // Is the character list, just too lazy to rename
	var grpSongs:FlxTypedGroup<Alphabet>;
	var posX:Int = Std.int(FlxG.width * 0.7);
	var posY:Int = 0;
	var searchField:FlxInputText;
	var searchButton:FlxUIButton;
	var muteKeys = FlxG.sound.muteKeys;
	var volumeUpKeys = FlxG.sound.volumeUpKeys;
	var volumeDownKeys = FlxG.sound.volumeDownKeys;
	var searchList:Array<String> = ["this should be replaced"];
	var retAfter:Bool = true;
	var bg:FlxSprite;
	var titleText:FlxText;
	var infotext:FlxText;
	var overLay:FlxGroup = new FlxTypedGroup();
	var infoTextBoxSize:Int = 2;
	var toggleables:Map<String,Bool> = [
		"search" => true
	];
	var buttonText:Map<String,String> = [
		"Find" => "Find"
	];
	var useAlphabet:Bool = true;
	

	function addTitleText(str:String = ""){
		if (titleText != null) titleText.destroy();
		if (str == "") return;
		titleText = new FlxText(FlxG.width * 0.5, 20, 0, str, 12);
		titleText.scrollFactor.set();
		titleText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titleText);
	}

	function findButton(){
			reloadList(true,searchField.text);
			searchField.hasFocus = false;
			changeSelection(0);
	}
	function orderList(list:Array<String>):Array<String>{
		haxe.ds.ArraySort.sort(list, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		return list;
	}
	function updateInfoText(str:String = ""){
		infotext.text = str;
		infotext.scrollFactor.set();
	}
	// var bgColor:FlxColor = 0xFFFF6E6E;
	override function create()
	{try{
		PlayState.songScript = "";PlayState.hsBrTools = null;
		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = bgColor;
		bg.scrollFactor.set(0.01,0.01);
		SickMenuState.musicHandle();
		add(bg);
		grpSongs = new FlxTypedGroup<Alphabet>();
		reloadList();
		add(grpSongs);
		if (toggleables['search']){
				FlxG.mouse.visible = true;
				//Searching
				searchField = new FlxInputText(10, 100, 1152, 20);
				searchField.maxLength = 81;
				add(searchField);
		
				searchButton = new FlxUIButton(10 + 1152 + 9, 100, buttonText["Find"], findButton);
				searchButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
				searchButton.resize(100, searchField.height);
				add(searchButton);
			}

		var infotexttxt:String = "Hold shift to scroll faster";
		infotext = new FlxText(5, FlxG.height - (18 * infoTextBoxSize ), FlxG.width - 100, infotexttxt, 16);
		infotext.wordWrap = true;
		infotext.scrollFactor.set();
		infotext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		var blackBorder = new FlxSprite(-30,FlxG.height - (18 * infoTextBoxSize )).makeGraphic((Std.int(FlxG.width)),(18 * infoTextBoxSize),FlxColor.BLACK);
		blackBorder.alpha = 0.5;
		overLay.add(blackBorder);
		overLay.add(infotext);
		// add(overLay);
		FlxG.autoPause = true;
		try{if(onlinemod.OnlinePlayMenuState.socket != null) onlinemod.OnlinePlayMenuState.receiver.HandleData = HandleData;}catch(e){}

		super.create();
		openfl.system.System.gc();
		
	}catch(e) MainMenuState.handleError('Error with searchmenu "create" ${e.message}');}

	function addToList(char:String,i:Int = 0){
				songs.push(char);
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false,false,useAlphabet);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				if (i != 0)
					controlLabel.alpha = 0.6;
				grpSongs.add(controlLabel);
	}
	override function draw(){
		super.draw();
		overLay.draw();
	}

	function reloadList(?reload = false,?search=""){try{
		curSelected = 0;
		if(reload){grpSongs.clear();}
		songs = [];

		var i:Int = 0;
		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		for (char in searchList){
			if(search == "" || query.match(char.toLowerCase()) ){
					addToList(char,i);
					i++;
			}
		}
	}catch(e) MainMenuState.handleError('Error with loading stage list ${e.message}');}
	override function update(elapsed:Float)
	{try{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		if (toggleables['search'] && searchField.hasFocus){SetVolumeControls(false);if (FlxG.keys.pressed.ENTER) findButton();}else{
			SetVolumeControls(true);
			handleInput();
		}
	}catch(e) MainMenuState.handleError('Error with searchmenu "update" ${e.message}');}
	function select(sel:Int = 0){
		trace("You forgot to replace the select function!");
	}
	function handleInput(){
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
			{
				ret();
			}
			if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
			if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}
			extraKeys();
			if (controls.ACCEPT && songs.length > 0)
			{
				select(curSelected);
				if(retAfter) ret();
			}
	}
	function extraKeys(){
		return;
	}
	function ret(){
		FlxG.mouse.visible = false;
		if (onlinemod.OnlinePlayMenuState.socket != null){FlxG.switchState(new onlinemod.OnlineOptionsMenu());}else{FlxG.switchState(new OptionsMenu());}
	}
	function changeSelection(change:Int = 0)
	{try{
		if (change != 0) FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		if (grpSongs.length < 2){
			return;
		}
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		if (curSelected >= grpSongs.length)
			curSelected = 0;

		var bullShit:Int = 0;


			for (item in grpSongs.members)
			{
				var onScreen = ((item.y > 0 && item.y < FlxG.height) || (bullShit - curSelected < 10 &&  bullShit - curSelected > -10));
				if (onScreen){ // If item is onscreen, then actually move and such
					if (!item.alive){
						item.revive();
						if (change < 0 ) item.y = -500; else item.y = FlxG.height + 300;
					}
					item.targetY = bullShit - curSelected;

					// item.color = 0xdddddd;
					item.alpha = 0.8;
					if (item.targetY == 0)
					{
						item.alpha = 1;
						// item.color = 0xffffff;
					}
				}else{item.kill();} // Else, try to kill it to lower the amount of sprites loaded
				bullShit++;
			}
	}catch(e) MainMenuState.handleError('Error with searchmenu "chgsel" ${e.message}');}
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
	function HandleData(packetId:Int, data:Array<Dynamic>)
	{
		onlinemod.OnlinePlayMenuState.RespondKeepAlive(packetId);
		var Chat = onlinemod.Chat;
		var Packets = onlinemod.Packets;
		var OnlineLobbyState = onlinemod.OnlineLobbyState;
		switch (packetId)
		{
			case Packets.BROADCAST_NEW_PLAYER:
				var id:Int = data[0];
				var nickname:String = data[1];

				// OnlineLobbyState.addPlayerUI(id, nickname);
				OnlineLobbyState.addPlayer(id, nickname);
				if (OnlineLobbyState.receivedPrevPlayers)
					Chat.PLAYER_JOIN(nickname);
			case Packets.PLAYER_LEFT:
				var id:Int = data[0];
				var nickname:String = OnlineLobbyState.clients[id];
				Chat.PLAYER_LEAVE(nickname);

				OnlineLobbyState.removePlayer(id);
				// createNamesUI();
			case Packets.GAME_START:
				var jsonInput:String = data[0];
				var folder:String = data[1];
				var count = 0;
				for (i in OnlineLobbyState.clients.keys())
				{
					count++;
				}
				if (count == 2 && TitleState.supported) {
					TitleState.p2canplay = true;
				}else{
					TitleState.p2canplay = false;
				}
				onlinemod.OnlineLobbyState.StartGame(jsonInput, folder);

			case Packets.BROADCAST_CHAT_MESSAGE:
				var id:Int = data[0];
				var message:String = data[1];

				Chat.MESSAGE(OnlineLobbyState.clients[id], message);
			case Packets.REJECT_CHAT_MESSAGE:
				Chat.SPEED_LIMIT();
			case Packets.MUTED:
				Chat.MUTED();
			case Packets.SERVER_CHAT_MESSAGE:
				if(StringTools.startsWith(data[0],"'32d5d167'")) OnlineLobbyState.handleServerCommand(data[0].toLowerCase(),0); else Chat.SERVER_MESSAGE(data[0]);

			case Packets.DISCONNECT:
				TitleState.p2canplay = false;
				FlxG.switchState(new onlinemod.OnlinePlayMenuState("Disconnected from server"));
		}
	}
}
