package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

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
	var ipField:FlxInputText;
	var portField:FlxInputText;
  var pwdField:FlxInputText;

	public static var socket:Socket;
	public static var receiver:Receiver;

  public static var muteKeys:Array<Int>;
  public static var volumeUpKeys:Array<Int>;
  public static var volumeDownKeys:Array<Int>;

  public function new(?message:String="", ?color:FlxColor=FlxColor.RED)
  {
    super();

    errorMessage = message;
    errorColor = color;
  }

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
		add(bg);


    var topText = new FlxText(0, FlxG.height * 0.05, "Connect to server");
    topText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    topText.screenCenter(FlxAxes.X);
    add(topText);


    errorText = new FlxText(0, FlxG.height * 0.175, FlxG.width, errorMessage);
    errorText.setFormat(Paths.font("vcr.ttf"), 32, errorColor, CENTER);
    add(errorText);
    SetErrorText(errorMessage, errorColor);


    var ipText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.3 - 40, "IP Address:");
    ipText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(ipText);

		ipField = new FlxInputText(0, FlxG.height * 0.3, 700, 32);
		ipField.setFormat(32, FlxColor.BLACK, CENTER);
		ipField.screenCenter(FlxAxes.X);
		ipField.customFilterPattern = ~/[^A-Za-z0-9.-]/;
		ipField.hasFocus = true;
		add(ipField);


    var portText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.5 - 40, "Port:");
    portText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(portText);

		portField = new FlxInputText(0, FlxG.height * 0.5, 700, 32);
		portField.setFormat(32, FlxColor.BLACK, CENTER);
		portField.screenCenter(FlxAxes.X);
		portField.customFilterPattern = ~/[^0-9]/;
		portField.maxLength = 6;
		add(portField);


    var pwdText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.7 - 40, "Password:");
    pwdText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(pwdText);

		pwdField = new FlxInputText(0, FlxG.height * 0.7, 700, 32);
		pwdField.setFormat(32, FlxColor.BLACK, CENTER);
		pwdField.screenCenter(FlxAxes.X);
    pwdField.passwordMode = true;
		add(pwdField);


		var connectButton = new FlxUIButton(0, FlxG.height * 0.85, "Connect", () -> {
      try
  		{
  			socket.connect(ipField.text, Std.parseInt(portField.text));
  		}catch (e: Dynamic){
  			trace(e);
  		}
    });
		connectButton.setLabelFormat(32, FlxColor.BLACK, CENTER);
		connectButton.resize(300, FlxG.height * 0.1);
		connectButton.screenCenter(FlxAxes.X);
		add(connectButton);


    var helpButton = new FlxUIButton(FlxG.width - 170, FlxG.height * 0.925 - 20, "Help", () -> {
      #if linux
      Sys.command('/usr/bin/xdg-open', ["https://github.com/XieneDev/FunkinBattleRoyale/blob/main/HELP.md", "&"]);
      #else
      FlxG.openURL('https://github.com/XieneDev/FunkinBattleRoyale/blob/main/HELP.md');
      #end
    });
    helpButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    helpButton.resize(150, FlxG.height * 0.075);
    add(helpButton);


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

	function HandleData(packetId:Int, data:Array<Dynamic>)
	{
    switch (packetId)
    {
      case Packets.SEND_SERVER_TOKEN:
        var serverToken:Int = data[0];
        if (serverToken == Tokens.serverToken)
        {
          Sender.SendPacket(Packets.SEND_PASSWORD, [pwdField.text], socket);
        }
        else
        {
          SetErrorText("Failed to verify server. Make sure the server and client are up to date");
          if (socket.connected)
            socket.close();
        }
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

  static function OnData(e:ProgressEvent)
	{
		var data:ByteArray = new ByteArray();
		socket.readBytes(data);
		receiver.OnData(data);
	}

  static function OnError(e:IOErrorEvent)
  {
    if (Type.getClass(FlxG.state) == OnlinePlayMenuState)
      OnlinePlayMenuState.SetErrorText('Socket error: ${e.text}');
    else
      FlxG.switchState(new OnlinePlayMenuState('Socket error: ${e.text}'));
  }

  static function OnClose(e:Event)
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
		if (!(ipField.hasFocus || portField.hasFocus || pwdField.hasFocus))
		{
      SetVolumeControls(true);
      if (controls.BACK)
      {
        FlxG.switchState(new OnlineMenuState());

        if (socket.connected)
        {
          socket.close();
        }
      }
		}
    else
    {
      SetVolumeControls(false);
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
    xieneText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    xieneText.screenCenter(FlxAxes.X);
    state.add(xieneText);
  }

}
