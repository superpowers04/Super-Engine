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
    options= [ // Required to prevent broken options from crashing or causing issues, everything here should work
      new OptionCategory("Customization", [
        new OpponentOption("Change the opponent character"),
        new PlayerOption("Change the player character"),
        new GFOption("Change the GF used"),
        new NoteSelOption("Change the note assets used, pulled from mods/noteassets"),
        new CharAutoOption("Allow the song to choose the opponent if you have them"),
        new ReloadCharlist("Refreshes the character list, used for if you added characters"),
        new SelStageOption("Select the stage to use, Default will use song default"),
      ]),
      new OptionCategory("Gameplay", [
        new DFJKOption(controls),
        new SixKeyMenu(controls),
        new NineKeyMenu(controls),
        new DownscrollOption("Change the layout of the strumline."),
        new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
        new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
        new FPSCapOption("Cap your FPS"),
        new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
        new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
        new HitSoundOption("Play a click when you hit a note. Uses osu!'s sounds or your mods/hitsound.ogg"),
        new Osuscore("The more combo you have the more score you get")
        // new InputHandlerOption("Change the input engine used, only works locally, Disables Kade options unless supported by engine")
      ]),
      new OptionCategory("Appearance", [
        new GUIGapOption("Change the distance between the end of the screen and text"),
        new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
        new CamMovementOption("Toggle the camera moving"),
        new NPSDisplayOption("Shows your current Notes Per Second."),
        new AccuracyOption("Display accuracy information."),
        new SongPositionOption("Show the songs current position (as a bar)"),
        new CpuStrums("CPU's strumline lights up when a note hits it."),
      ]),
      new OptionCategory("Misc", [
        new FPSOption("Toggle the FPS Counter"),
        new GUIGapOption("Change the distance between the end of the screen and text"),
        new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
        new PlayVoicesOption("Plays your character's voices when you press a note."),
      ]),
      new OptionCategory("Preformance", [
        new CheckForUpdatesOption("Check for updates when booting the game"),
        new NoteSplashOption("Shows note splashes when you get a 'Sick' rating"),
        new ShitQualityOption("Disables elements not essential to gameplay like the stage"),
        new NoteRatingOption("Toggles the rating that appears when you press a note"),
        new UnloadSongOption("Unload the song when exiting the game, can cause issues but should help with memory"),
        new UseBadArrowsOption("Use custom arrow texture instead of coloring normal notes black"),
        new ShowP2Option("Show Opponent"),
        new ShowGFOption("Show Girlfriend"),
        new ShowP1Option("Show Player 1"),
      ])
    ];
		super.create();
	}
  function HandleData(packetId:Int, data:Array<Dynamic>)
  {
    OnlinePlayMenuState.RespondKeepAlive(packetId);
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
  }
  override function goBack(){
    FlxG.switchState(new OnlineLobbyState(true));
  }
}