package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;

import sys.FileSystem;
using StringTools;

class OnlineLobbyState extends MusicBeatState
{
  var clientTexts:Map<Int, Int> = []; // Maps a player ID to the corresponding index in clientsGroup
  var clientsGroup:FlxTypedGroup<FlxText>; // Stores all FlxText instances used to display names
  var clientCount:Int = 0; // Amount of clients in the lobby
  public static var optionsButton:FlxUIButton;

  static inline var NAMES_PER_ROW:Int = 5;
  static inline var NAMES_SIZE:Int = 32;
  static inline var NAMES_VERTICAL_SPACING:Int = 48;

  public static var clients:Map<Int, String> = []; // Maps a player ID to the corresponding nickname
  public static var clientsOrder:Array<Int> = []; // This array holds ID values in order of join time (including ID -1 for self)
  public static var receivedPrevPlayers:Bool = false;
  var quitHeld:Int = 0;
  var quitHeldBar:FlxBar;
  var quitHeldBG:FlxSprite;


  var keepClients:Bool;

  public function new(keepClients:Bool=false)
  {
    super();

    if (!keepClients)
    {
      clients = [];
      clientsOrder = [];
      receivedPrevPlayers = false;

      Chat.chatMessages = [];
    }

    this.keepClients = keepClients;
  }

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('onlinemod/online_bg0'));
		add(bg);


    var topText:FlxText = new FlxText(0, FlxG.height * 0.05, "Lobby");
    topText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    topText.screenCenter(FlxAxes.X);
    add(topText);


    clientsGroup = new FlxTypedGroup<FlxText>();
    add(clientsGroup);


    createNamesUI();


    Chat.createChat(this);


    if (!keepClients)
      Chat.PLAYER_JOIN(OnlineNickState.nickname);


    OnlinePlayMenuState.AddXieneText(this);


    FlxG.mouse.visible = true;
    FlxG.autoPause = false;


    OnlinePlayMenuState.receiver.HandleData = HandleData;
    if (!keepClients)
      Sender.SendPacket(Packets.JOINED_LOBBY, [], OnlinePlayMenuState.socket);

    optionsButton = new FlxUIButton(1100, 30, "Quick Options", () -> {
      Chat.created = false;
      FlxG.switchState(new OnlineOptionsMenu());
    });
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(160, 70);
    add(optionsButton);

    quitHeldBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar','shared'));
    quitHeldBG.screenCenter(X);
    quitHeldBG.scrollFactor.set();
    add(quitHeldBG);


    quitHeldBar = new FlxBar(quitHeldBG.x + 4, quitHeldBG.y + 4, LEFT_TO_RIGHT, Std.int(quitHeldBG.width - 8), Std.int(quitHeldBG.height - 8), this,
      'quitHeld', 0, 1000);
    quitHeldBar.numDivisions = 1000;
    quitHeldBar.scrollFactor.set();
    quitHeldBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
    add(quitHeldBar);



    super.create();
  }

  function createNamesUI()
  {
    clientsGroup.clear();
    clientTexts = [];
    clientCount = 0;

    for (i in clientsOrder)
    {
      var nick:String = i != -1 ? clients[i] : OnlineNickState.nickname;
      addPlayerUI(i, nick, i == -1 ? FlxColor.YELLOW : null);
    }
  }

  function HandleData(packetId:Int, data:Array<Dynamic>)
  {
    OnlinePlayMenuState.RespondKeepAlive(packetId);
    switch (packetId)
    {
      case Packets.BROADCAST_NEW_PLAYER:
        var id:Int = data[0];
        var nickname:String = data[1];

        addPlayerUI(id, nickname);
        addPlayer(id, nickname);
        if (receivedPrevPlayers)
          Chat.PLAYER_JOIN(nickname);
      case Packets.END_PREV_PLAYERS:
        receivedPrevPlayers = true;
        addPlayerUI(-1, OnlineNickState.nickname, FlxColor.YELLOW);
        clientsOrder.push(-1);
      case Packets.PLAYER_LEFT:
        var id:Int = data[0];
        var nickname:String = OnlineLobbyState.clients[id];
        Chat.PLAYER_LEAVE(nickname);

        removePlayer(id);
        createNamesUI();
      case Packets.GAME_START:
        var jsonInput:String = data[0];
        var folder:String = data[1];
        // var count = 0;
        // for (i in clients.keys())
        // {
        //   count++;
        // }

        StartGame(jsonInput, folder);

      case Packets.BROADCAST_CHAT_MESSAGE:
        var id:Int = data[0];
        var message:String = data[1];

        Chat.MESSAGE(OnlineLobbyState.clients[id], message);
      case Packets.REJECT_CHAT_MESSAGE:
        Chat.SPEED_LIMIT();
      case Packets.MUTED:
        Chat.MUTED();
      case Packets.SERVER_CHAT_MESSAGE:
        if(data[0] == "'ceabf544' This is a compatibility message, Ignore me!"){
          TitleState.supported = true;
          Sender.SendPacket(Packets.SUPPORTED, [], OnlinePlayMenuState.socket);
          Chat.SERVER_MESSAGE("This server is compatible with extra features!");
        }else if(StringTools.startsWith(data[0],"'32d5d167'")) handleServerCommand(data[0].toLowerCase(),0); else Chat.SERVER_MESSAGE(data[0]);

      case Packets.DISCONNECT:
        TitleState.p2canplay = false;
        FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
    }
  }

  public static function handleServerCommand(command:String,?version = 0) // Not sure if I'll ever actually use the version variable for anything
  {
    try{

      var args:Array<String> = command.split(' ');
      switch (args[1]){
        case "set":
          if (args[3] == "true" || args[3] == "on" || args[3] == "false" || args[3] == "off"){ 
            var bool = (args[3] == "true" || args[3] == "on");
            switch(args[2]){
              case "invertnotes":
                PlayState.invertedChart = bool;
              case "inputsync":
                OnlinePlayState.autoDetPlayer2 = false;
                PlayState.p2canplay = bool;
              case "p2show":
                OnlinePlayState.autoDetPlayer2 = false;
                PlayState.dadShow = bool;
              default:
                throw("Invalid option");
            }
          }else{
            switch(args[2]){
              case "player1",'bf','p1':
                OnlinePlayState.useSongChar[0] = args[3];
              case "player2",'dad','p2':
                OnlinePlayState.useSongChar[1] = args[3];
              case "gf":
                OnlinePlayState.useSongChar[2] = args[3];
              default:
                throw("Invalid option");
            }
          }
      }
      Chat.SERVER_MESSAGE('Server \'${args[1]}\' \'${args[2]}\' to \'${args[3]}\'');
    }catch(e){Chat.SERVER_MESSAGE('Server sent an invalid command ${e.message}, ${command}');} // I don't expect servers to always handle this properly, always better to have error catching
  }


  public static function StartGame(jsonInput:String, folder:String)
  {
    PlayState.isStoryMode = false;
    FlxG.switchState(new OnlineLoadState(jsonInput, folder));

    if (FlxG.sound.music != null)
      FlxG.sound.music.stop();
  }

  public static function addPlayer(id:Int, nickname:String)
  {
    OnlineLobbyState.clients[id] = nickname;
    OnlineLobbyState.clientsOrder.push(id);
  }

  function addPlayerUI(id:Int, nickname:String, ?color:FlxColor=FlxColor.WHITE)
  {
    var text:FlxText = new FlxText((clientCount % NAMES_PER_ROW) * FlxG.width/NAMES_PER_ROW, FlxG.height*0.2 + Std.int(clientCount / NAMES_PER_ROW) * NAMES_VERTICAL_SPACING, FlxG.width/NAMES_PER_ROW, nickname);
    text.setFormat(CoolUtil.font, NAMES_SIZE, color, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    clientTexts[id] = clientsGroup.length;
    clientsGroup.add(text);
    clientCount++;
  }

  public static function removePlayer(id:Int)
  {
    OnlineLobbyState.clients.remove(id);
    clientsOrder.remove(id);
  }

  function removePlayerUI(id:Int)
  {
    var n:Int = clientTexts[id];

    for (i=>k in clientTexts)
    {
      if (k > n)
      {
        clientsGroup.members[k].x = clientsGroup.members[k - 1].x;
        clientsGroup.members[k].y = clientsGroup.members[k - 1].y;
        clientTexts[i] = clientTexts[i] - 1;
      }
    }

    clientsGroup.remove(clientsGroup.members[n], true);
    clientTexts.remove(id);
    clientCount--;
  }
  function disconnect(){
      if (OnlinePlayMenuState.socket.connected)
      {
        OnlinePlayMenuState.socket.close();
      }
      FlxG.switchState(new OnlinePlayMenuState());
  }

  override function update(elapsed:Float)
  {
    if (quitHeldBar.visible && quitHeld <= 0){
      quitHeldBar.visible = false;
      quitHeldBG.visible = false;
    }
    if (!Chat.chatField.hasFocus)
    {
      OnlinePlayMenuState.SetVolumeControls(true);
    }
    else
    {
      OnlinePlayMenuState.SetVolumeControls(false);
      if (FlxG.keys.justPressed.ENTER)
      {
        Chat.SendChatMessage();
      }

    }
    if (FlxG.keys.pressed.ESCAPE)
    {
      quitHeld += 5;
      quitHeldBar.visible = true;
      quitHeldBG.visible = true;
      if (quitHeld > 1000) disconnect(); 
    }else if (quitHeld > 0){
      quitHeld -= 10;
      
    }
    super.update(elapsed);
  }
}
