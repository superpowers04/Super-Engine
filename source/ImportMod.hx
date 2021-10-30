package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flash.media.Sound;
import lime.media.AudioBuffer;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;

import haxe.io.Bytes;
import openfl.utils.ByteArray;
import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;

using StringTools;

class ImportMod extends DirectoryListing
{
	var importExisting = false;
	var curReg:EReg = ~/.+\/(.*?)\//g;
	override function create(){
		infoTextBoxSize = 3;
		super.create();
		infotext.text = '${infotext.text}\nPress 1 to toggle importing vanilla songs(Disabled by default to prevent clutter)\nSelect the mods root folder, Example: "games/FNF" not "games/FNF/assets"';
	
	}
	override function ret(){
  		FlxG.switchState(new OtherMenuState());
	}
	override function handleInput(){
		super.handleInput();
		if (FlxG.keys.justPressed.ONE) {
			importExisting = !importExisting;
			showTempmessage(if(importExisting)"Importing vanilla songs enabled" else "importing vanilla songs disabled");
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		}
	}
	override function selDir(sel:String){
		curReg.match(sel);
		
		FlxG.switchState(new ImportModFromFolder(sel,curReg.matched(1),importExisting));
	}
}


class ImportModFromFolder extends MusicBeatState
{
  var loadingText:FlxText;
  var progress:Float = 0;
  static var existingSongs:Array<String> = ["offsettest", 'tutorial', 'bopeebo', 'fresh', 'dad-battle', 'dad battle', 'dadbattle', 'spookeez', 'south', "monster", 'pico', 'philly-nice', 'philly nice', 'philly', 'phillynice', "blammed", 'satin panties','satin-panties','satinpanties', "high", "milf", 'cocoa', 'eggnog', 'winter-horrorland', 'winter horrorland', 'winterhorrorland', 'senpai', 'roses', 'thorns', 'test'];
  var songName:EReg = ~/.+\/(.*?)\//g;
  var songsImported:Int = 0;
  var importExisting:Bool = false;

  var name:String;
  var folder:String;
  var done:Bool = false;

  public function new (folder:String,name:String,?importExisting:Bool = false)
  {
    super();

    this.name = name;
    this.folder = folder;
    this.importExisting = importExisting;
  }

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('onlinemod/online_bg2'));
		add(bg);


    loadingText = new FlxText(FlxG.width/4, FlxG.height/2 - 36, FlxG.width, "Scanning for songs..\nThe game may "+ (if(Sys.systemName() == "Windows")"'not respond'" else "freeze") + " during this process");
    loadingText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(loadingText);


    super.create();
    		new FlxTimer().start(0.6, function(tmr:FlxTimer){scanSongs();});
  }
  function scanSongs(){
  	try{

	  	var assets = '${folder}assets/'; // For easy access
	  	if (!FileSystem.exists(assets)) {MainMenuState.handleError('${folder} doesn\'t have a assets folder!');return;} //This folder is not a mod!
	  	if (folder == Sys.getCwd()) {MainMenuState.handleError('You\'re trying to import songs from me!'); return;} //This folder is the same folder that FNFBR is running in!
	  	if(FileSystem.exists('${assets}songs/')){

		  	for (directory in FileSystem.readDirectory('${assets}songs/')) {
					loadingText.text = 'Checking ${directory}...'; // Just display this text
					draw();
					if(!FileSystem.isDirectory('${assets}songs/${directory}') || (!importExisting && existingSongs.contains(directory.toLowerCase()))) continue; // Skip if it's a file or if it's on the existing songs list
					var dir:String = '${folder}assets/songs/${directory}/';
					if(!FileSystem.exists('${dir}Inst.ogg') || !FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" or "${dir}Inst.ogg" doesnt exist');continue;}

					var outDir:String = Sys.getCwd() + 'mods/charts/${name.substr(0,5)}-${directory}/';
					try{FileSystem.createDirectory(outDir);}catch(e) MainMenuState.handleError('Error while creating folder, ${e.message}');
					
					for (i => v in ['${dir}Inst.ogg' => '${outDir}Inst.ogg','${dir}Voices.ogg' => '${outDir}Voices.ogg']) {
						try{
							loadingText.text = 'Copying ${i}...';// Just display this text
					draw();
							File.copy(i,v);
						}catch(e) trace('$i caused ${e.message}');
					}
					for (file in FileSystem.readDirectory('${assets}data/${directory}/')) {
						try{
							loadingText.text = 'Copying ${file}...';// Just display this text
					draw();
							File.copy('${assets}data/${directory}/${file}','${outDir}${file}');
						}catch(e) trace('$file caused ${e.message}');

				}songsImported++;}
	  	}
	  if(FileSystem.exists('${assets}music/')){
		  	for (directory in FileSystem.readDirectory('${assets}music/')) {
		  		if (!directory.endsWith("inst.ogg")) continue;
		  		directory = directory.substr(0,-8);
					loadingText.text = 'Checking ${directory}...'; // Just display this text
					draw();
					if(!importExisting && existingSongs.contains(directory.toLowerCase())) {continue;} // Skip if it's on the existing songs list
					var dir:String = '${folder}assets/music/${directory}-';
					if(!FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" doesnt exist');continue;}

					var outDir:String = Sys.getCwd() + 'mods/charts/${name.substr(0,5)}-${directory}/';
					try{FileSystem.createDirectory(outDir);}catch(e) MainMenuState.handleError('Error while creating folder, ${e.message}');
					
					for (i => v in ['${dir}Inst.ogg' => '${outDir}Inst.ogg',
					     			'${dir}Voices.ogg' => '${outDir}Voices.ogg']) {
						try{
							loadingText.text = 'Copying ${i}...';// Just display this text
					draw();
							File.copy(i,v);
						}catch(e) trace('$i caused ${e.message}');
					}
					for (file in FileSystem.readDirectory('${assets}data/${directory}/')) {
						try{
							loadingText.text = 'Copying ${file}...';// Just display this text
					draw();
							File.copy('${assets}data/${directory}/${file}','${outDir}${file}');
						}catch(e) trace('$file caused ${e.message}');

				} songsImported++;}
		}
  	loadingText.text = 'Imported ${songsImported} songs. All song names are prefixed with "${name.substr(0,5)}-" \nPress any key to go to the main menu';
  	loadingText -= 50
  	done = true;
  	}catch(e) MainMenuState.handleError('Error while trying to scan for songs, ${e.message}');
  }
  override function update(elapsed:Float)
  {
  	if (done && FlxG.keys.justPressed.ANY) {
  		FlxG.switchState(new OtherMenuState());
  	}
    super.update(elapsed);
  }


}
