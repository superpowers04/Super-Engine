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

class ImportMod extends DirectoryListing
{
	var curReg:EReg = ~/.+\/(.*?)\//g;
	override function create(){
		super.create();
		infotext.text = '${infotext.text}; Select the mods root folder, Example: "games/FNF" not "games/FNF/assets"';
	}
	override function ret(){
  		FlxG.switchState(new OtherMenuState());
	}
	override function selDir(sel:String){
		curReg.match(sel);
		
		FlxG.switchState(new ImportModFromFolder(sel,curReg.matched(1)));
	}
}


class ImportModFromFolder extends MusicBeatState
{
  var loadingText:FlxText;
  var progress:Float = 0;
  var existingSongs:Array<String> = [ 'tutorial', 'bopeebo', 'fresh', 'dad-battle', 'dad battle', 'dadbattle', 'spookeez', 'south', "monster", 'pico', 'philly-nice', 'philly nice', 'philly', 'phillynice', "blammed", 'satin panties','satin-panties','satinpanties', "high", "milf", 'cocoa', 'eggnog', 'winter-horrorland', 'winter horrorland', 'winterhorrorland', 'senpai', 'roses', 'thorns', 'test'];
  var songName:EReg = ~/.+\/(.*?)\//g;
  var songsImported:Int = 0;

  var name:String;
  var folder:String;
  var done:Bool = false;

  public function new (folder:String,name:String)
  {
    super();

    this.name = name;
    this.folder = folder;
  }

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('onlinemod/online_bg2'));
		add(bg);


    loadingText = new FlxText(FlxG.width/4, FlxG.height/2 - 36, FlxG.width, "Scanning for songs..");
    loadingText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(loadingText);


    super.create();
    		new FlxTimer().start(0.6, function(tmr:FlxTimer){scanSongs();});
  }
  function scanSongs(){
  	try{

	  	var assets = '${folder}assets/'; // For easy access
	  	if (!FileSystem.exists(assets)) MainMenuState.handleError('${folder} doesn\'t have a assets folder!'); //This folder is not a mod!
	  	for (directory in FileSystem.readDirectory('${assets}songs/')) {
				loadingText.text = 'Checking ${directory}...'; // Just display this text
				if(!FileSystem.isDirectory('${assets}songs/${directory}') || existingSongs.contains(directory.toLowerCase())) {continue;} // Skip if it's a file or if it's on the existing songs list
				var dir:String = '${folder}assets/songs/${directory}/';
				if(!FileSystem.exists('${dir}Inst.ogg') || !FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" or "${dir}Inst.ogg" doesnt exist');continue;}

				var outDir:String = Sys.getCwd() + 'mods/charts/${name.substr(0,5)}-${directory}/';
				try{FileSystem.createDirectory(outDir);}catch(e) MainMenuState.handleError('Error while creating folder, ${e.message}');
				
				for (i => v in ['${dir}Inst.ogg' => '${outDir}Inst.ogg',
				     			'${dir}Voices.ogg' => '${outDir}Voices.ogg']) {
					try{
						loadingText.text = 'Copying ${i}...';// Just display this text
						File.copy(i,v);
					}catch(e) trace('$i caused ${e.message}');
				}
				for (file in FileSystem.readDirectory('${assets}data/${directory}/')) {
					try{
						loadingText.text = 'Copying ${file}...';// Just display this text
						File.copy('${assets}data/${directory}/${file}','${outDir}${file}');
					}catch(e) trace('$file caused ${e.message}');

		}
		songsImported++;
  	}
  	loadingText.text = 'Imported ${songsImported} songs. Press any key to go to the main menu';
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