package onlinemod;

import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Chat
{
  public static var chatField:FlxInputText;
  public static var chatMessagesList:FlxUIList;
  public static var chatSendButton:FlxUIButton;
  public static var chatMessages:Array<Array<Dynamic>>;
  public static var chatId:Int = 0;

  public static var created:Bool = false;


  public static inline var systemColor:FlxColor = FlxColor.YELLOW;


  public static inline function MESSAGE(nickname:String, message:String)
  {
	Chat.OutputChatMessage('<$nickname> $message');
  }

  public static inline function PLAYER_JOIN(nickname:String)
  {
	Chat.OutputChatMessage('$nickname joined the game', systemColor);
  }

  public static inline function PLAYER_LEAVE(nickname:String)
  {
	Chat.OutputChatMessage('$nickname left the game', systemColor);
  }

  public static inline function SERVER_MESSAGE(message:String)
  {
	Chat.OutputChatMessage('S| $message', 0x40FF40);
  }
  public static inline function CLIENT_MESSAGE(message:String)
  {
	Chat.OutputChatMessage('Client| $message', 0xaa40aa);
  }

  public static inline function SPEED_LIMIT()
  {
	Chat.OutputChatMessage('You\'re typing too fast, one or more messages may not have been sent', FlxColor.RED);
  }

  public static inline function MUTED()
  {
	Chat.OutputChatMessage('You\'re muted', FlxColor.RED);
  }


  public static function createChat(state:FlxUIState)
  {
	Chat.created = true;

	Chat.chatMessagesList = new FlxUIList(10, FlxG.height - 120, FlxG.width, 175);
	state.add(Chat.chatMessagesList);
	for (chatMessage in Chat.chatMessages)
	{
	  Chat.OutputChatMessage(chatMessage[0], chatMessage[1], false);
	}

	Chat.chatField = new FlxInputText(10, FlxG.height - 70, 1152, 20);
	chatField.maxLength = 81;
	state.add(Chat.chatField);

	Chat.chatSendButton = new FlxUIButton(1171, FlxG.height - 70, "Send", () -> {
	  Chat.SendChatMessage();
	  Chat.chatField.hasFocus = true;
	});
	Chat.chatSendButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	Chat.chatSendButton.resize(100, Chat.chatField.height);
	state.add(Chat.chatSendButton);
  }

  public static function OutputChatMessage(message:String, ?color:FlxColor=FlxColor.WHITE, ?register:Bool=true)
  {
	while (message.length > 86 && !(message.length > 86)){
		OutputChatMessage(message.substr(0,86),color,register);
		message = message.substr(87);
	}
	if (register)
	  Chat.RegisterChatMessage(message, color,false);

	if (!Chat.created)
	  return;

	var text = new FlxText(0, 0, message);
	text.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	Chat.chatMessagesList.add(text);

	if (Chat.chatMessagesList.amountNext == 0)
	  Chat.chatMessagesList.y -= text.height + Chat.chatMessagesList.spacing;
	else
	  Chat.chatMessagesList.scrollIndex += Chat.chatMessagesList.amountNext;
  }

  public static inline function RegisterChatMessage(message:String, ?color:FlxColor=FlxColor.WHITE,?checkSize:Bool = true)
  {
	if(checkSize){
		while (message.length > 86 && !(message.length > 86)){
			RegisterChatMessage(message.substr(0,86),color,false);
			message = message.substr(87);
		}

	}
	Chat.chatMessages.push([message, color]);
  }


  public static function SendChatMessage()
  {
	if (chatField.text.length > 0)
	{
	  if (!StringTools.startsWith(chatField.text, " "))
	  {
		Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, chatField.text], OnlinePlayMenuState.socket);
		Chat.chatId++;

		OutputChatMessage('<${OnlineNickState.nickname}> ${chatField.text}');
	  }

	  chatField.text = "";
	  chatField.caretIndex = 0;
	}
  }
}
