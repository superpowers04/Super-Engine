package multi;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;

import Section.SwagSection;

class MultiPlayState extends onlinemod.OfflinePlayState
{

	public static var voicesFile = "";
  public static var instFile = "";
  override function loadSongs(){
    {try{
    loadedVoices = new FlxSound().loadEmbedded(Sound.fromFile(voicesFile));
    loadedInst = Sound.fromFile(instFile);
  }catch(e){MainMenuState.handleError('Caught "loadSongs" crash: ${e.message}');}}
  }
  override function create()
    {try{
  	super.create();
  	PlayState.stateType=4;
  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}}
  override function openSubState(SubState:FlxSubState)
  {
    if (Type.getClass(SubState) == PauseSubState)
    {
      super.openSubState(new PauseSubState(PlayState.boyfriend.x,PlayState.boyfriend.y));
      return;
    }

    super.openSubState(SubState);
  }
}
