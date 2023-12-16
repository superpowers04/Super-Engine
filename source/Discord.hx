package;

import Sys.sleep;
#if discord_rpc
import discord_rpc.DiscordRpc;
#end
import flixel.FlxG;
using StringTools;

class DiscordClient
{
	public static var canSend:Bool = false;
	public function new()
	{
		if(!SESave.data.discordDRP) return;
		#if discord_rpc
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "845856556095373352",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		canSend = true;
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}
		canSend = false;

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if discord_rpc
		if(!canSend) return;
		DiscordRpc.shutdown();
		canSend = false;
		#end
	}
	
	static function onReady()
	{
		#if discord_rpc
		if(!canSend) return;
		DiscordRpc.presence({
			details: "Titlescreen moment",
			state: "beans",
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if discord_rpc
		if(!SESave.data.discordDRP) return;
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}
	static var _details:String = "";
	static var _state = "";
	static var _timestampStart:Float = 0;
	static var _timestampEnd:Float = 0;
	public static function updateSong(?paused:Bool = false){
		#if discord_rpc
			if(!canSend) return;
			var details = (if(paused) "Paused" else (switch(PlayState.stateType){
					case 2:"Playing a downloaded song";
					case 3:"Playing online";
					case 4:"Playing a modded/imported song";
					case 5:"Playing a OSU song";
					default:'Playing a song';
				}));
			if(paused){
				changePresence(details,'${PlayState.actualSongName}');

			}else{
				if(PlayState.isStoryMode){
					details = "Playing a week";
				}
				if(ChartingState.charting){
					details = details.replace('Play',"Chart");
				}
				changePresence(details,'${PlayState.actualSongName}',Date.now().getTime() - FlxG.sound.music.time,FlxG.sound.music.length);
			}
			/*Playing ${PlayState.SONG.song}|*/
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, startTimestamp:Float = 0, ?endTimestamp: Float = 0)
	{
		#if discord_rpc
			if(!canSend) return;
			if(details == _details && _state == state && _timestampEnd == endTimestamp && _timestampStart == startTimestamp){return;}
			_timestampStart = startTimestamp;
			_timestampEnd = endTimestamp;
			if(startTimestamp > -1 && endTimestamp > 0){
				endTimestamp = startTimestamp + endTimestamp;
			}


			DiscordRpc.presence({
				details: _details = details,
				state: _state = state,
				largeImageKey: 'icon',
				largeImageText: "Friday Night Funkin'",
				smallImageKey : smallImageKey,
				// Obtained times are in milliseconds so they are divided so Discord can use it
				startTimestamp : Std.int(startTimestamp / 1000),
	            endTimestamp : Std.int(endTimestamp / 1000)
			});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#end
	}
}