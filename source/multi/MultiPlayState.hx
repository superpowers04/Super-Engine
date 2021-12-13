package multi;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;

import Section.SwagSection;

class MultiPlayState extends onlinemod.OfflinePlayState
{

	public static var voicesFile = "";
  public static var instFile = "";
  public static var scriptLoc= "";
  // public static var playlistMode = false;
  // override function new(?plMode:Bool = false){ // This should be reset by the next song
  //   playlistMode = plMode;
  // }
  override function loadSongs(){
    {try{

    if (voicesFile != ""){loadedVoices = new FlxSound().loadEmbedded(Sound.fromFile(voicesFile));}else loadedVoices = new FlxSound();
    loadedInst = Sound.fromFile(instFile);
  }catch(e){MainMenuState.handleError('Caught "loadSongs" crash: ${e.message}');}}
  }
  override function create()
    {try{
    if (scriptLoc != "" ) PlayState.songScript = File.getContent(scriptLoc); else PlayState.songScript = "";
    if(!PlayState.isStoryMode) stateType=4;
    shouldLoadSongs = false;
    loadSongs();
  	super.create();

  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}}
}
