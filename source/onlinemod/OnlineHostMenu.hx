package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;

import openfl.net.Socket;
import openfl.utils.ByteArray;

typedef ConnectedPlayer = {
	var nick:String;

}


class OnlineHostMenu extends MusicBeatState
{
	var errorText:FlxText;
	var portField:FlxInputText;
	var pwdField:FlxInputText;
	public static var socket:Socket;
	public static var receiver:Receiver;
	public static var serverVariables:Map<Dynamic,Dynamic>;

	public static function shutdownServer(){
		try{if(OnlineHostMenu.socket != null){
			OnlineHostMenu.socket.close();
			OnlineHostMenu.socket = null;

		}}catch(e){OnlineHostMenu.socket = null;return;} // Ignore errors, the socket should close anyways
		serverVariables = null;
	}
	@:access(openfl.net.Socket.__socket)
	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xFFea71fd;
		add(bg);


		var topText = new FlxText(0, FlxG.height * 0.15, "Host server");
		topText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		topText.screenCenter(FlxAxes.X);
		add(topText);


		errorText = new FlxText(0, FlxG.height * 0.275, FlxG.width, "");
		errorText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, CENTER);
		add(errorText);


		var portText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.4 - 40, "Port:");
		portText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(portText);

		portField = new FlxInputText(0, FlxG.height * 0.4, 700, 32);
		portField.setFormat(32, FlxColor.BLACK, CENTER);
		portField.screenCenter(FlxAxes.X);
		portField.customFilterPattern = ~/[^0-9]/;
		portField.maxLength = 6;
		portField.hasFocus = true;
		add(portField);


		var pwdText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.6 - 40, "Password:");
		pwdText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pwdText);

		pwdField = new FlxInputText(0, FlxG.height * 0.6, 700, 32);
		pwdField.setFormat(32, FlxColor.BLACK, CENTER);
		pwdField.screenCenter(FlxAxes.X);
		pwdField.passwordMode = false;
		add(pwdField);


		var hostButton = new FlxUIButton(0, FlxG.height * 0.75, "Host", () -> {
			try{
				serverVariables = new Map<Dynamic,Dynamic>();
				serverVariables["password"] = pwdField.text;
				var socket = new Socket();
				socket.__socket.bind(new sys.net.Host("0.0.0.0"),Std.parseInt(portField.text));
		        socket.timeout = 10000;
		        socket.addEventListener(Event.CONNECT, (e:Event) -> {
		          Sender.SendPacket(Packets.SEND_SERVER_TOKEN, [Tokens.serverToken], socket);
		        });
		        socket.addEventListener(IOErrorEvent.IO_ERROR, OnError);
		        socket.addEventListener(Event.CLOSE, OnClose);
		        socket.addEventListener(ProgressEvent.SOCKET_DATA, OnData);
				socket.__socket.listen(12);
				OnlineHostMenu.socket = socket;
				// Literally just code from OnlinePlayMenu
				var socket = new Socket();
				socket.timeout = 10000;
				socket.addEventListener(Event.CONNECT, (e:Event) -> {
					Sender.SendPacket(Packets.SEND_CLIENT_TOKEN, [Tokens.clientToken], socket);
				});
				socket.addEventListener(IOErrorEvent.IO_ERROR, OnlinePlayMenuState.OnError);
				socket.addEventListener(Event.CLOSE, OnlinePlayMenuState.OnClose);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, OnlinePlayMenuState.OnData);
				var receiver = new Receiver(clientHandleData);
				OnlinePlayMenuState.receiver = receiver;
				OnlinePlayMenuState.socket = socket;
				socket.connect("localhost", Std.parseInt(portField.text));

			}catch(e){
				shutdownServer();
				SetErrorText("Error occurred while creating socket! " + e.message);
			}
		});
		hostButton.setLabelFormat(32, FlxColor.BLACK, CENTER);
		hostButton.resize(300, FlxG.height * 0.1);
		hostButton.screenCenter(FlxAxes.X);
		add(hostButton);


		FlxG.mouse.visible = true;


		super.create();
	}

	function clientHandleData(packetId:Int, data:Array<Dynamic>)
	{
		switch (packetId)
		{
			case Packets.SEND_SERVER_TOKEN:
				Sender.SendPacket(Packets.SEND_PASSWORD, [pwdField.text], socket);
			case Packets.PASSWORD_CONFIRM:
				switch (data[0])
				{
					case 0:
						SetErrorText("Correct password", FlxColor.LIME);
						FlxG.switchState(new OnlineNickState());
					case 1:
						SetErrorText("Game already in progress");
					case 2:
						SetErrorText("Wrong password");
					case 3:
						SetErrorText("Game is already full");
				}
		}
	}

	override function update(elapsed:Float)
	{
		if (!(portField.hasFocus || pwdField.hasFocus))
		{
			if (controls.BACK)
			{
				FlxG.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	function SetErrorText(text:String, color:FlxColor=FlxColor.RED)
	{
		errorText.text = text;
		errorText.setFormat(32, color);
		errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	}
	static function OnData(e:ProgressEvent)
	{
		var data:ByteArray = new ByteArray();
		socket.readBytes(data);
		receiver.OnData(data);
	}
	static function OnClose(e:Event)
	{
		FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
	}
	function HandleData(packetId:Int, data:Array<Dynamic>)
	{
		switch (packetId)
		{
			case Packets.SEND_CLIENT_TOKEN:
				var serverToken:Int = data[0];
				if (serverToken == Tokens.serverToken)
				{
					Sender.SendPacket(Packets.SEND_SERVER_TOKEN, [], socket);
				}
				else
				{
					SetErrorText("Failed to verify server. Make sure the server and client are up to date");
					if (socket.connected)
						socket.close();
				}
			case Packets.SEND_PASSWORD:
				
				Sender.SendPacket(Packets.PASSWORD_CONFIRM, [(if(data[0] == serverVariables["password"]) 0 else 1)], socket);
			case Packets.SEND_NICKNAME:
				
				Sender.SendPacket(Packets.PASSWORD_CONFIRM, [(if(data[0] == serverVariables["password"]) 0 else 1)], socket);
		}
	}
	static function OnError(e:IOErrorEvent)
	{
		shutdownServer();
		FlxG.switchState(new OnlinePlayMenuState('Socket error: ${e.text}'));
	}
}
