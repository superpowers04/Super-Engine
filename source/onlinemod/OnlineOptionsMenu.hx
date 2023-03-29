package onlinemod;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OnlineOptionsMenu extends OptionsMenu
{
	public static var instance:OnlineOptionsMenu;
	override function create()
	{
		OnlinePlayMenuState.receiver.HandleData = HandleData;

		super.create();
	}
  static function HandleData(packetId:Int, data:Array<Dynamic>)
  {
	OnlinePlayMenuState.RespondKeepAlive(packetId);
	try{

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
		  OnlineLobbyState.StartGame(jsonInput, folder);

		case Packets.BROADCAST_CHAT_MESSAGE:
		  var id:Int = data[0];
		  var message:String = data[1];

		  Chat.MESSAGE(OnlineLobbyState.clients[id], message);
		case Packets.REJECT_CHAT_MESSAGE:
		  Chat.SPEED_LIMIT();
		case Packets.MUTED:
		  Chat.MUTED();
		case Packets.SERVER_CHAT_MESSAGE:
		  Chat.SERVER_MESSAGE(data[0]);
		  

		case Packets.DISCONNECT:
		  TitleState.p2canplay = false;
		  FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
	  }
	}catch(e){
	  Chat.OutputChatMessage("[Client] You had an error when receiving packet '" + '$packetId' + "':");
	  Chat.OutputChatMessage(e.message);
	  FlxG.sound.play(Paths.sound('cancelMenu'));
	  FlxG.switchState(new OnlineLobbyState(true));
	}
  }
  override function goBack(){
	FlxG.switchState(new OnlineLobbyState(true));
  }
}