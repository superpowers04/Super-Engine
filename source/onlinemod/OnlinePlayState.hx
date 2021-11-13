package onlinemod;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flash.media.Sound;

import Section.SwagSection;



class OnlinePlayState extends PlayState
{
	var clients:Map<Int, String> = [];
	public static var clientScores:Map<Int, Int> = [];
	public static var clientText:Map<Int, String> = [];
	public static var lastPressed:Array<Bool> = [false,false,false,false];
	public static var useSongChar:Array<String> = ["","",""];
	public static var autoDetPlayer2:Bool = true;
	var clientTexts:Map<Int, Int> = [];
	var clientsGroup:FlxTypedGroup<FlxText>;

	var clientCount:Int = 1;

	var waitingBg:FlxSprite;
	var waitingText:FlxText;

	var customSong:Bool;
	var loadedVoices:FlxSound;
	var loadedInst:Sound;

	var ready:Bool = false;

	var inPause:Bool = false;

	var originalSafeFrames:Int = FlxG.save.data.frames;

	public function new(customSong:Bool, voices:FlxSound, inst:Sound)
	{
		PlayState.stateType =3;
		super();


		this.customSong = customSong;
		this.loadedVoices = voices;
		this.loadedInst = inst;

	}

	override function create()
	{try{
		if (customSong){
			for (i => v in useSongChar) {
				if (v != ""){
					switch(i){
						case 0: PlayState.SONG.player1 = v;
						case 1: PlayState.SONG.player2 = v;
						case 2: PlayState.SONG.gfVersion = v;
					}
				}
			}
			if (useSongChar[0] != "") PlayState.SONG.player1 = FlxG.save.data.playerChar;
			
			if ((FlxG.save.data.charAuto || useSongChar[1] != "") && TitleState.retChar(PlayState.SONG.player2) != ""){ // Check is second player is a valid character
				PlayState.SONG.player2 = TitleState.retChar(PlayState.SONG.player2);
			}else{
				PlayState.SONG.player2 = FlxG.save.data.opponent;
			}
		}

		super.create();


		clients = OnlineLobbyState.clients.copy();
		clientScores = [];
		clientText = [];
		clientsGroup = new FlxTypedGroup<FlxText>();

		// Add the score UI for other players
		for (i in OnlineLobbyState.clients.keys())
		{
			clientScores[i] = 0;
			clientCount++;

			var scoreY:Float;
			if (FlxG.save.data.downscroll)
				scoreY = 10 + 28*(clientsGroup.length);
			else
				scoreY = healthBarBG.y + 30 - 28*(clientsGroup.length + 1);

			var text = new FlxText(20, scoreY, '${OnlineLobbyState.clients[i]}: 0');
			text.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set(0, 0);
			clientTexts[i] = clientsGroup.length;
			clientsGroup.add(text);
			text.cameras = [camHUD];
		}
		add(clientsGroup);
		if (autoDetPlayer2){
				if (clientCount == 2 && TitleState.supported) {
					PlayState.p2canplay = true;
				}else{
					PlayState.p2canplay = false;
				}
				if (clientCount == 1){
					PlayState.dadShow = false;
					PlayState.dad.destroy();
					PlayState.dad = new EmptyCharacter(100, 100);
				}
		}
		// Add XieneDev watermark
		var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.9 + 50, FlxG.width, "XieneDev Battle Royale", 16);
		xieneDevWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		xieneDevWatermark.scrollFactor.set();
		add(xieneDevWatermark);
		xieneDevWatermark.cameras = [camHUD];


		// The screen with 'Waiting for players (1/4)' stuff
		waitingBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		waitingBg.alpha = 0.5;
		add(waitingBg);
		waitingBg.cameras = [camHUD];

		waitingText = new FlxText(0, 0, 'Waiting for players (?/${clientCount})');
		waitingText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		waitingText.screenCenter(FlxAxes.XY);
		add(waitingText);
		waitingText.cameras = [camHUD];


		// Remove healthbar
		if (FlxG.save.data.downscroll){scoreTxt.y = 10;}
		remove(healthBarBG);
		remove(healthBar);
		remove(iconP1);
		remove(iconP2);


		OnlinePlayMenuState.receiver.HandleData = HandleData;
		new FlxTimer().start(transIn.duration, (timer:FlxTimer) -> Sender.SendPacket(Packets.GAME_READY, [], OnlinePlayMenuState.socket));



		FlxG.mouse.visible = false;
		FlxG.autoPause = false;
	}catch(e){MainMenuState.handleError('Crash in "create" caught: ${e.message}');}}

	override function startCountdown()
	{
		if (!ready)
			return;

		super.startCountdown();
	}

	override function startSong(?alrLoaded:Bool = false)
	{
		try{
		FlxG.sound.playMusic(loadedInst, 1, false);

		// We be good and actually just use an argument to not load the song instead of "pausing" the game
		super.startSong(true);
		
	}catch(e){MainMenuState.handleError('Crash in "startsong" caught: ${e.message}');}}

	override function generateSong(?dataPath:String = "")
	{
	//   // I have to code the entire code over so that I can remove the offset thing
	//   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		if (PlayState.SONG.needsVoices)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();
		super.generateSong(dataPath);

	}

		// FlxG.sound.list.add(vocals);

		// notes = new FlxTypedGroup<Note>();
		// add(notes);

		// var noteData:Array<SwagSection>;

		// // NEW SHIT
		// noteData = songData.notes;

		// var playerCounter:Int = 0;

		// // Per song offset check
		// var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		// for (section in noteData)
		// {
		// 	var coolSection:Int = Std.int(section.lengthInSteps / 4);

		// 	for (songNotes in section.sectionNotes)
		// 	{
		// 		var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
		// 		if (daStrumTime < 0)
		// 			daStrumTime = 0;
		// 		var daNoteData:Int = songNotes[1];

		// 		var gottaHitNote:Bool = section.mustHitSection;

		// 		if (songNotes[1] > 3)
		// 		{
		// 			gottaHitNote = !section.mustHitSection;
		// 		}

		// 		var oldNote:Note;
		// 		if (unspawnNotes.length > 0)
		// 			oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
		// 		else
		// 			oldNote = null;


		// 		var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,songNotes[3] == 1);
		// 		swagNote.sustainLength = songNotes[2];
		// 		swagNote.scrollFactor.set(0, 0);

		// 		var susLength:Float = swagNote.sustainLength;

		// 		susLength = susLength / Conductor.stepCrochet;
		// 		unspawnNotes.push(swagNote);

		// 		for (susNote in 0...Math.floor(susLength))
		// 		{
		// 			oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

		// 			var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,songNotes[3] == 1);
		// 			sustainNote.scrollFactor.set();
		// 			unspawnNotes.push(sustainNote);

		// 			sustainNote.mustPress = gottaHitNote;

		// 			if (sustainNote.mustPress)
		// 			{
		// 				sustainNote.x += FlxG.width / 2; // general offset
		// 			}
		// 		}

		// 		swagNote.mustPress = gottaHitNote;

		// 		if (swagNote.mustPress)
		// 		{
		// 			swagNote.x += FlxG.width / 2; // general offset
		// 		}
		// 		else
		// 		{
		// 		}
		// 	}
		// 	daBeats += 1;
		// }

		// // trace(unspawnNotes.length);
		// // playerCounter += 1;

		// unspawnNotes.sort(sortByShit);

		// generatedMusic = true;
	// }

	override function popUpScore(daNote:Note):Void
	{
		super.popUpScore(daNote);

		SendScore();
	}

	override function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		super.noteMiss(direction, daNote,forced);

		SendScore();
	}

	override function resyncVocals()
	{
		// So you can't play the game while being paused
		if (inPause)
			return;

		super.resyncVocals();
	}

	override function endSong():Void
	{
		clients[-1] = OnlineNickState.nickname;
		clientScores[-1] = PlayState.songScore;
		clientText[-1] = "S:" + PlayState.songScore+ " M:" + PlayState.misses+ " A:" + PlayState.accuracy;

		canPause = false;
		FlxG.sound.playMusic(loadedInst, 1, true);
		FlxG.sound.music.onComplete = null;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();

		Sender.SendPacket(Packets.GAME_END, [], OnlinePlayMenuState.socket);

		FlxG.switchState(new OnlineResultState(clients));
	}


	override function keyShit()
	{
		if (inPause)
			return;

		super.keyShit();
		if (PlayState.p2canplay){ // This ifstatement is weird, but tries to help with bandwidth
			if (lastPressed[0] != PlayState.p1presses[0] || lastPressed[1] != PlayState.p1presses[1] || lastPressed[2] != PlayState.p1presses[2] || lastPressed[3] != PlayState.p1presses[3]){
				// Sender.SendPacket(Packets.KEYPRESS, [this.fromBool(controls.LEFT), this.fromBool(controls.DOWN), this.fromBool(controls.UP), this.fromBool(controls.RIGHT)], OnlinePlayMenuState.socket);
				Sender.SendPacket(Packets.KEYPRESS, [getPresses()], OnlinePlayMenuState.socket);
				lastPressed = PlayState.p1presses;
			}

		}
	}
// this.fromBool([controls.LEFT_P, controls.LEFT]),
//           this.fromBool([controls.DOWN_P, controls.DOWN]),
//           this.fromBool([controls.UP_P, controls.UP]),
//           this.fromBool([controls.RIGHT_P, controls.RIGHT])
	override function openSubState(SubState:FlxSubState)
	{
		if (Type.getClass(SubState) == PauseSubState)
		{
			var realPaused:Bool = paused;
			paused = false;

			super.openSubState(new OnlinePauseSubState());
			inPause = true;

			paused = realPaused;
			persistentUpdate = true;
			
			canPause = false;

			return;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			canPause = true;
			inPause = false;
		}

		super.closeSubState();
	}
	
	function getPresses():Int {return this.fromBool(controls.LEFT_P) | this.fromBool(controls.DOWN_P) << 1 | this.fromBool(controls.UP_P) << 2 | this.fromBool(controls.RIGHT_P) << 3 | this.fromBool(controls.LEFT) | this.fromBool(controls.DOWN) << 1 | this.fromBool(controls.UP) << 2 | this.fromBool(controls.RIGHT) << 3;}

	function HandleData(packetId:Int, data:Array<Dynamic>)
	{try{
		OnlinePlayMenuState.RespondKeepAlive(packetId);
		switch (packetId)
		{
			case Packets.PLAYERS_READY:
				var count:Int = data[0];
				waitingText.text = 'Waiting for players ($count/${clientCount})';
			case Packets.EVERYONE_READY:
				var safeFrames:Int = data[0];
				waitingText.text = 'Ready!';
				ready = true;
				startCountdown();
				FlxTween.tween(waitingBg, {alpha: 0}, 0.5);
				FlxTween.tween(waitingText, {alpha: 0}, 0.5);

				FlxG.save.data.frames = safeFrames;
				Conductor.recalculateTimings();
			case Packets.BROADCAST_SCORE:
				var id:Int = data[0];
				var score:Int = data[1];

				clientScores[id] = score;
				clientText[id] = "S:" + score+ " M:n/a A:n/a";
				clientsGroup.members[clientTexts[id]].text = OnlineLobbyState.clients[id] + ": " + score;
			case Packets.BROADCAST_CURRENT_INFO:
				var id:Int = data[0];
				var score:Int = data[1];
				var misses:Int = data[2];
				var accuracy:Int = data[3];

				clientScores[id] = score;
				clientText[id] = "S:" + score+ " M:" + misses+ " A:" + accuracy;
				clientsGroup.members[clientTexts[id]].text = OnlineLobbyState.clients[id] + " Score:" + score+ " Misses:" + misses+ " Accuracy:" + accuracy;

			case Packets.PLAYER_LEFT:
				var id:Int = data[0];
				var nickname:String = OnlineLobbyState.clients[id];

				clientsGroup.members[clientTexts[id]].setFormat(24, FlxColor.RED);
				clientsGroup.members[clientTexts[id]].setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				if(clientScores[id] == null) clientsGroup.members[clientTexts[id]].text = '$nickname: left';

				OnlineLobbyState.removePlayer(id);
				Chat.PLAYER_LEAVE(nickname);
				clientCount--;

			case Packets.REJECT_CHAT_MESSAGE:
				Chat.SPEED_LIMIT();
			case Packets.SERVER_CHAT_MESSAGE:
				Chat.SERVER_MESSAGE(data[0]);

			case Packets.FORCE_GAME_END:
				FlxG.switchState(new OnlineLobbyState(true));
			case Packets.KEYPRESS:
				if (PlayState.p2canplay){
					// PlayState.p2presses = [this.fromInt(data[0]), this.fromInt(data[1]), this.fromInt(data[2]), this.fromInt(data[3])];

					PlayState.p2presses = [((data[0] >> 0) & 1 == 1),((data[0] >> 1) & 1 == 1),((data[0] >> 2) & 1 == 1),((data[0] >> 3) & 1 == 1), // Presses
					((data[0] >> 4) & 1 == 1),((data[0] >> 5) & 1 == 1),((data[0] >> 6) & 1 == 1),((data[0] >> 7) & 1 == 1) // Holds
					];

				}
			case Packets.BROADCAST_NEW_PLAYER:
				var id:Int = data[0];
				var nickname:String = data[1];

				// OnlineLobbyState.addPlayerUI(id, nickname);
				OnlineLobbyState.addPlayer(id, nickname);
				Chat.PLAYER_JOIN(nickname);
				clientCount++;
				var i:Int = id;

				var scoreY:Float;
				if (FlxG.save.data.downscroll)
					scoreY = 10 + 28*(clientsGroup.length);
				else
					scoreY = healthBarBG.y + 30 - 28*(clientsGroup.length + 1);

				var text = new FlxText(20, scoreY, '${nickname}: In lobby');
				text.setFormat(CoolUtil.font, 24, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.scrollFactor.set(0, 0);
				clientTexts[i] = clientsGroup.length;
				clientsGroup.add(text);
				text.cameras = [camHUD];
			case Packets.DISCONNECT:
				FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
		}}catch(e){
			Chat.OutputChatMessage("[Client] You had an error when receiving packet '" + '$packetId' + "':");
			Chat.OutputChatMessage(e.message);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OnlineLobbyState(true));
		}}
	

	function SendScore()
	{
		if (TitleState.supported){
			Sender.SendPacket(Packets.SEND_CURRENT_INFO, [PlayState.songScore,PlayState.misses,Std.int(PlayState.accuracy)], OnlinePlayMenuState.socket);
		}else{Sender.SendPacket(Packets.SEND_SCORE, [PlayState.songScore], OnlinePlayMenuState.socket);}

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		health = 1;

		if (!ready)
		{
			Conductor.songPosition = -5000;
			Conductor.lastSongPos = -5000;
			songTime = 0;
		}
	}

	override function destroy()
	{
		// This function is called when the State changes. For example, when exiting via the pause menu.
		FlxG.sound.music.onComplete = null;
		/*if (FlxG.sound.music != null)
			FlxG.sound.music.pause();
		if (vocals != null)
		{
			vocals.volume = 0;
			vocals.pause();
		}*/

		FlxG.save.data.frames = originalSafeFrames;
		Conductor.recalculateTimings();
		super.destroy();
	}
	override function testanimdebug(){
		return;
	}
}
