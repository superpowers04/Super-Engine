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
import openfl.net.ServerSocket;
import openfl.utils.ByteArray;
import openfl.events.ServerSocketConnectEvent;
import openfl.utils.Endian;

@:structInit class ConnectedPlayer {
	public var nick:String;
	public var socket:Socket;
	public var receiver:Receiver;
	public var admin:Bool = false;
	public var afk:Bool = false;
	public var alive:Bool = true;
	public var muted:Bool = false;


}


class OnlineHostMenu extends ScriptMusicBeatState
{
	public static var instance:OnlinePlayMenuState;
	var errorText:FlxText;
	var portField:FlxInputText;
	var pwdField:FlxInputText;
	public static var socket:ServerSocket;
	public static var connectedPlayers:Array<ConnectedPlayer> = [];
	public static var clientsFromNames:Map<String,Null<Int>> = [];
	public static var serverVariables:Map<Dynamic,Dynamic>;

	public static function shutdownServer() {
		try{
			if(OnlineHostMenu.socket != null){
				OnlineHostMenu.socket.close();
				OnlineHostMenu.socket = null;
			}
		}catch(e){OnlineHostMenu.socket = null;return;} // Ignore errors, the socket should close anyways

		try{
			while(connectedPlayers.length > 0){
				var e = connectedPlayers.pop();
				if(e != null && e.socket != null) {
					try{
						e.socket.close();
					}catch(e){}
				}
			}
		}catch(e){}
		serverVariables = null;
		connectedPlayers = [];
		clientsFromNames = [];
	}
	override function create() {
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
		portField.text = "8000";
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
				var socket = new ServerSocket();
				socket.bind(Std.parseInt(portField.text));
				if(!socket.bound){
					SetErrorText('Unable to bind to port ${portField.text}. Is it already in use or too low?');
					return;
				}
				connectedPlayers = [];
				clientsFromNames = [];
				socket.addEventListener(Event.CONNECT, (e:ServerSocketConnectEvent) -> {
					var ID = connectedPlayers.length;
					connectedPlayers[ID] = {
						socket:e.socket,
						receiver:new Receiver(HandleData.bind(ID,_,_)),
						nick:"OUTDATED",
						admin:(ID == 0)
					}
					trace('New connection! ${e.socket}');
					var socket = e.socket;
					socket.endian = LITTLE_ENDIAN;
					socket.addEventListener(IOErrorEvent.IO_ERROR, OnErrorSocket.bind(ID,_));
					socket.addEventListener(Event.CLOSE, OnCloseSock.bind(ID,_));
					socket.addEventListener(ProgressEvent.SOCKET_DATA, OnData.bind(ID,_));
				});
				socket.addEventListener(IOErrorEvent.IO_ERROR, OnError);
				socket.addEventListener(Event.CLOSE, OnClose);
				// socket.addEventListener(ProgressEvent.SOCKET_DATA, OnData);
				socket.listen(12);
				OnlineHostMenu.socket = socket;
				// Literally just code from OnlinePlayMenu
				var socket = new Socket();
				socket.timeout = 10000;
				// socket.endian = LITTLE_ENDIAN;
				socket.addEventListener(Event.CONNECT, (e:Event) -> {
					Sender.SendPacket(Packets.SEND_CLIENT_TOKEN, [Tokens.clientToken], socket);
				});
				socket.addEventListener(IOErrorEvent.IO_ERROR, OnlinePlayMenuState.OnError);
				socket.addEventListener(Event.CLOSE, OnlinePlayMenuState.OnClose);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, OnlinePlayMenuState.OnData);
				var receiver = new Receiver(OnlinePlayMenuState.HandleData);
				OnlinePlayMenuState.receiver = receiver;
				OnlinePlayMenuState.socket = socket;
				OnlinePlayMenuState.password = pwdField.text;
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

	override function update(elapsed:Float) {
		if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}
		

		super.update(elapsed);
	}

	function SetErrorText(text:String, color:FlxColor=FlxColor.RED)
	{
		errorText.text = text;
		errorText.setFormat(32, color);
		errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	}
	static function OnData(ID:Int,e:ProgressEvent) {
		var data:ByteArray = new ByteArray();
		connectedPlayers[ID].socket.readBytes(data);
		// data.endian = LITTLE_ENDIAN;
		connectedPlayers[ID].receiver.OnData(data);
	}
	static function closeSocket(ID:Int,?call:Bool = true){
		if(connectedPlayers[ID] != null){
			try{
				connectedPlayers[ID].socket.close();
			}catch(e){}
			try{
				clientsFromNames[connectedPlayers[ID].nick] = null;
			}catch(e){}

		}
	}
	static function OnCloseSock(ID:Int,e:Event) {
		closeSocket(ID,false);
		trace('Socket for ${ID} closed... ${e}');
	}
	static function OnClose(e:Event) {
		shutdownServer();
		FlxG.switchState(new OnlinePlayMenuState('Closed server: ${e}'));
	}


	/* Packets, this should probably be handled elsewhere but whatever ig*/
	/* TODO: ADD SCRIPT SUPPORT */
	public static function HandleData(socketID:Int,packetId:Int, data:Array<Dynamic>) {	
		var player = connectedPlayers[socketID];
		var socket = player.socket;
		var pktName:String = 'Unknown ID ${packetId}';
		if(Packets.PacketsShit.fields[packetId] != null){
			pktName = Packets.PacketsShit.fields[packetId].name;
		}
		trace('${socketID}: Recieved ${pktName}');
		try{
			switch (packetId) {
				case Packets.SEND_CLIENT_TOKEN:
					// This will always be jumbled, Send the hosted server packet, 
					//  this'll automatically kick the client if unsupported since it's an entirely new packet :3
					Sender.SendPacket(Packets.HOSTEDSERVER, [], socket);
				case Packets.SEND_PASSWORD:
					player.nick = "Unspecified";
					if(data[0] == null) data[0] = "";
					Sender.SendPacket(Packets.PASSWORD_CONFIRM, [(if(data[0] == serverVariables["password"]) 0 else 1)], socket);
					if(data[0] != serverVariables["password"]) closeSocket(socketID);
				case Packets.SEND_NICKNAME:
					if(data[0] == "unspecified" || clientsFromNames[data[0]] != null){
						Sender.SendPacket(Packets.NICKNAME_CONFIRM, [1], socket);
						return true;
					}
					clientsFromNames[data[0]] = socketID;
					player.nick = data[0];
					trace('${socketID}: registered as ${player.nick}');
					Sender.SendPacket(Packets.NICKNAME_CONFIRM, [0], socket);
				case Packets.JOINED_LOBBY:
					Sender.SendPacket(Packets.SERVER_CHAT_MESSAGE,['Hosting is not currently finished, nothing besides chatting is implemented at the moment..'],socket);
				case Packets.SEND_CHAT_MESSAGE:{
					for (playerObject in connectedPlayers){
						if(playerObject.socket != null && playerObject != player) Sender.SendPacket(Packets.BROADCAST_CHAT_MESSAGE,data,playerObject.socket);
					}
				}
			}
		}catch(e){
			trace('Error handling packet($pktName) from $socketID:${e.message}');
		}
		return true;
	}
	static function OnErrorSocket(sockID:Int,e:IOErrorEvent) {
		// shutdownServer();
		trace('Error with socket $sockID: ${e.text}');
		// FlxG.switchState(new OnlinePlayMenuState('Socket error: ${e.text}'));
	}
	static function OnError(e:IOErrorEvent) {
		shutdownServer();
		FlxG.switchState(new OnlinePlayMenuState('Socket error: ${e.text}'));
	}
}
