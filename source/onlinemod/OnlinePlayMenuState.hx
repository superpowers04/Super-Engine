package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;

import openfl.net.Socket;
import openfl.utils.ByteArray;

class OnlinePlayMenuState extends MusicBeatState
{
	var errorMessage:String;
	var errorColor:FlxColor;

	static var errorText:FlxText;
	var password:String;

	public static var socket:Socket;
	public static var receiver:Receiver;
	public static var muteKeys:Array<Int>;
	public static var volumeUpKeys:Array<Int>;
	public static var volumeDownKeys:Array<Int>;
	public static var scripts:Array<String> = [];
	public static var rawScripts:Array<Array<String>> = [];

	var ServerList:Array<Array<Dynamic>> = [];
	var AddServerButton:FlxUIButton;

	public function new(?message:String="", ?color:FlxColor=FlxColor.RED)
	{
		super();
		PlayState.invertedChart = false;
		PlayState.dadShow = true;
		OnlinePlayState.autoDetPlayer2 = true;
		OnlinePlayState.useSongChar = ["","",""];
		errorMessage = message;
		errorColor = color;
		scripts = [];
		rawScripts = [];
	}

	override function create()
	{
		TitleState.supported = false;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xFFFF6E6E;
		add(bg);

		var topText = new FlxText(0, FlxG.height * 0.05, "Connect to server");
		topText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		topText.screenCenter(FlxAxes.X);
		add(topText);

		errorText = new FlxText(0, FlxG.height * 0.175, FlxG.width, errorMessage);
		errorText.setFormat(CoolUtil.font, 32, errorColor, CENTER);
		add(errorText);
		SetErrorText(errorMessage, errorColor);

		AddServerButton = new FlxUIButton(0, 0, 'Add Server', () -> {
			FlxG.switchState(new onlinemod.OnlineAddServer());
		});
		AddServerButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
		AddServerButton.resize(200, 75);
		AddServerButton.screenCenter(FlxAxes.X);
		add(AddServerButton);

		ResetServerList();

		AddXieneText(this);

		FlxG.mouse.visible = true;
		FlxG.autoPause = true;


		muteKeys = FlxG.sound.muteKeys;
		volumeUpKeys = FlxG.sound.volumeUpKeys;
		volumeDownKeys = FlxG.sound.volumeDownKeys;

		if (socket != null && socket.connected)
			socket.close();

		socket = new Socket();
		socket.timeout = 10000;
		socket.addEventListener(Event.CONNECT, (e:Event) -> {
			Sender.SendPacket(Packets.SEND_CLIENT_TOKEN, [Tokens.clientToken], socket);
		});
		socket.addEventListener(IOErrorEvent.IO_ERROR, OnError);
		socket.addEventListener(Event.CLOSE, OnClose);
		socket.addEventListener(ProgressEvent.SOCKET_DATA, OnData);
		receiver = new Receiver(HandleData);

		super.create();
	}

	public function HandleData(packetId:Int, data:Array<Dynamic>)
	{
		switch (packetId)
		{
			case Packets.SEND_SERVER_TOKEN:
				// var serverToken:Int = data[0];
				// if (serverToken == Tokens.serverToken)
				// {
					Sender.SendPacket(Packets.SEND_PASSWORD, [password], socket);
				// }
				// else
				// {
				// 	SetErrorText("Failed to verify server. Make sure the server and client are up to date");
				// 	if (socket.connected)
				// 		socket.close();
				// }
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

	public static function OnData(e:ProgressEvent)
	{
		var data:ByteArray = new ByteArray();
		socket.readBytes(data);
		receiver.OnData(data);
	}

	public static function OnError(e:IOErrorEvent)
	{
		if (Type.getClass(FlxG.state) == OnlinePlayMenuState)
			OnlinePlayMenuState.SetErrorText('Socket error: ${e.text}');
		else
			FlxG.switchState(new OnlinePlayMenuState('Socket error: ${e.text}'));

	}

	public static function OnClose(e:Event)
	{
		if (Type.getClass(FlxG.state) == OnlinePlayMenuState)
			OnlinePlayMenuState.SetErrorText("Disconnected from server");
		else
			FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
	}

	public static function RespondKeepAlive(packetId:Int)
	{
		if (packetId == Packets.KEEP_ALIVE)
			Sender.SendPacket(Packets.KEEP_ALIVE, [], OnlinePlayMenuState.socket);
	}

	override function update(elapsed:Float)
	{
		SetVolumeControls(true);
		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
			if (socket != null)
			{
				if(socket.connected) socket.close();
				socket = null;
			}
		}
		super.update(elapsed);
	}

	static function SetErrorText(text:String, color:FlxColor=FlxColor.RED)
	{
		OnlinePlayMenuState.errorText.text = text;
		OnlinePlayMenuState.errorText.setFormat(32, color);
		OnlinePlayMenuState.errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	}

	public static function SetVolumeControls(enabled:Bool)
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

	public static function AddXieneText(state:FlxUIState)
	{
		var xieneText = new FlxText(0, FlxG.height - 30, "XieneDev");
		xieneText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		xieneText.screenCenter(FlxAxes.X);
		state.add(xieneText);
	}

	function Connect(IP:String,Port:String,?Password:String){
		try
		{ 
			socket = new Socket();
			socket.timeout = 10000;
			socket.addEventListener(Event.CONNECT, (e:Event) -> {
				Sender.SendPacket(Packets.SEND_CLIENT_TOKEN, [Tokens.clientToken], socket);
			});
			socket.addEventListener(IOErrorEvent.IO_ERROR, OnError);
			socket.addEventListener(Event.CLOSE, OnClose);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, OnData);
			receiver = new Receiver(HandleData);
			FlxG.save.data.lastServer = IP;
			FlxG.save.data.lastServerPort = Port;
			password = Password;
			socket.connect(IP, Std.parseInt(Port));
		}catch (e: Dynamic){
			trace(e);
		}
	}

	function ResetServerList()
	{
		if(ServerList != []){
				for(Array in ServerList){
					for(thing in Array){
					remove(thing);
				}
			}
		}
		ServerList = [];
		try{
		if(FlxG.save.data.Server != []){
			for(i in 0...FlxG.save.data.Server.length){
				ServerList.push([]);
				var BlackBox = new FlxSprite().makeGraphic(FlxG.width, 75, i % 2 == 0 ? 0x7F000000 : 0x7f3f3f3f);
				BlackBox.screenCenter();
				BlackBox.y += (BlackBox.height * i) - (BlackBox.height + (BlackBox.height * ((FlxG.save.data.Server.length * 0.5) - 1.5)));
				ServerList[i].push(BlackBox);
				add(BlackBox);

				var ServerIP = new FlxText(250, BlackBox.y + 5 , FlxG.width , 'Server: ${FlxG.save.data.Server[i][0]}:${FlxG.save.data.Server[i][1]}\nPassword: ' + (FlxG.save.data.Server[i][2] != null && FlxG.save.data.Server[i][2] != "" ? '******' : ''),24);
				ServerList[i].push(ServerIP);
				add(ServerIP);

				var ConnectButton = new FlxUIButton(FlxG.width - 500, BlackBox.y + 11.25, 'Connect', () -> {
					Connect(FlxG.save.data.Server[i][0],FlxG.save.data.Server[i][1],FlxG.save.data.Server[i][2]);
				});
				ConnectButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
				ConnectButton.resize(200, 50);
				ServerList[i].push(ConnectButton);
				add(ConnectButton);

				var RUSure = 0;
				var DeleteButton = new FlxUIButton(ConnectButton.x + ConnectButton.width + 25, ConnectButton.y, 'Delete Server', () -> {
					RUSure++;
					switch(RUSure){
						case 1:
							showTempmessage("Are you Sure?",FlxColor.RED,2);
							new FlxTimer().start(2, function(tmr:FlxTimer){RUSure = 0;});
						case 2:
							FlxG.save.data.Server.remove(FlxG.save.data.Server[i]);
							ResetServerList();
					}
				});
				DeleteButton.setLabelFormat(18, FlxColor.BLACK, CENTER);
				DeleteButton.resize(100, 50);
				ServerList[i].push(DeleteButton);
				add(DeleteButton);

				if(FlxG.save.data.Server[i][2] != null && FlxG.save.data.Server[i][2] != ""){
					var hide = true;
					var TogglePassword = new FlxUIButton(DeleteButton.x + DeleteButton.width + 25, ConnectButton.y, 'Toggle Password', () -> {
						hide = !hide;
						if(hide)ServerIP.text = 'Server: ${FlxG.save.data.Server[i][0]}:${FlxG.save.data.Server[i][1]}\nPassword: ******';
						else ServerIP.text = 'Server: ${FlxG.save.data.Server[i][0]}:${FlxG.save.data.Server[i][1]}\nPassword: ${FlxG.save.data.Server[i][2]}';
					});
					TogglePassword.setLabelFormat(18, FlxColor.BLACK, CENTER);
					TogglePassword.resize(100, 50);
					ServerList[i].push(TogglePassword);
					add(TogglePassword);
				}
			}
		}
		}catch(e){
			showTempmessage("Something went wrong while create a server list",FlxColor.RED);
			trace(e);
		}
		try{AddServerButton.y = ServerList[ServerList.length - 1][0].y + 100;}catch(e){AddServerButton.screenCenter(FlxAxes.Y);}// i have no idea why if isn't working
	}
}
