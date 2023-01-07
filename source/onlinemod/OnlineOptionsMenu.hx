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
		options = [
			new OptionCategory("Modifications", [
			new OpponentOption("Change the opponent character"),
			new PlayerOption("Change the player character"),
			new GFOption("Change the GF used"),
			// new NoteSelOption("Change the note assets used, pulled from mods/noteassets"),
			new SelStageOption("Select the stage to use, Default will use song default"),
			new SelScriptOption("Enable/Disable scripts that run withsongs"),
			new CharAutoOption("Force the opponent you've selected or allow the song to choose the opponent if you have them installed"),
			new ReloadCharlist("Refreshes list of stages, characters and scripts"),
			new AllowServerScriptsOption("Allow servers to run scripts. THIS IS DANGEROUS, ONLY ENABLE IF YOU TRUST THE SERVERS"),
		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Change the layout of the strumline."),
			new MiddlescrollOption("Move the strumline to the middle of the screen"),

			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new InputHandlerOption("Change the input engine used, only works locally. Kade is considered legacy and will not be improved")
		]),
		new OptionCategory("Modifiers", [
			new PracticeModeOption("Disables the ability to get a gameover."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			new AccurateNoteHoldOption("Adjust accuracy of note sustains"),
		]),

		new OptionCategory("Appearance", [
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamMovementOption("Toggle the camera moving"),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new AccuracyOption("Display accuracy information."),
			new SongPositionOption("Show the songs current position, name and length"),
			new CpuStrums("CPU's strumline lights up when a note hits it."),
			new SongInfoOption("Change how your performance is displayed"),
			new GUIGapOption("Change the distance between the end of the screen and text(Not used everywhere)"),
		]),
		new OptionCategory("Misc", [
			new CheckForUpdatesOption("Toggle check for updates when booting the game, useful if you're in the Discord with pings on"),
			new FPSOption("Toggle the FPS Counter"),
			new AnimDebugOption("Access animation debug in a offline session, 1=BF,2=Dad,3=GF. Also shows extra information"),
			new LogGameplayOption("Logs your game to a text file"),
			new EraseOption("Backs up your options to SEOPTIONS-BACKUP.json and then resets them"),
			new ImportOption("Import your options from SEOPTIONS.json"),
			new ExportOption("Export your options to SEOPTIONS.json to backup or to share with a bug report"),
		]),
		new OptionCategory("Performance", [
			new FPSCapOption("Cap your FPS"),
			new UseBadArrowsOption("Use custom arrow texture instead of coloring normal notes black"),
			new ShitQualityOption("Disables elements not essential to gameplay like the stage"),
			new NoteRatingOption("Toggles the rating that appears when you press a note"),
			// new UnloadSongOption("Unload the song when exiting the game"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		]),
		new OptionCategory("Visibility", [
			new FontOption("Force menus to use the built-in font or mods/font.ttf for easier reading"),
			new BackTransOption("Change underlay opacity"),
			new BackgroundSizeOption("Change underlay size"),
			new NoteSplashOption("Shows note splashes when you get a 'Sick' rating"),
			new OpponentStrumlineOption("Whether to show the opponent's notes or not"),
			new ShowP2Option("Show Opponent"),
			new ShowGFOption("Show Girlfriend"),
			new ShowP1Option("Show Player 1"),
			// new MMCharOption("**CAN PUT GAME INTO CRASH LOOP! IF STUCK, HOLD SHIFT AND DISABLE THIS OPTION. Show character on main menu"),
		]),
		new OptionCategory("Auditory", [
			new VolumeOption("Adjust the volume of the entire game","master"),
			new VolumeOption("Adjust the volume of the background music","inst"),
			new VolumeOption("Adjust the volume of the vocals","voices"),
			new VolumeOption("Adjust the volume of the hit sounds","hit"),    
			new VolumeOption("Adjust the volume of miss sounds","miss"),       
			new VolumeOption("Adjust the volume of other sounds and the default script sound volume","other"),  
			new MissSoundsOption("Play a sound when you miss"),
			new HitSoundOption("Play a click when you hit a note. Uses osu!'s sounds or your mods/hitsound.ogg"),
			new PlayVoicesOption("Plays the voices a character has when you press a note."),
		]),
	];

		super.create();
	}
  function HandleData(packetId:Int, data:Array<Dynamic>)
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