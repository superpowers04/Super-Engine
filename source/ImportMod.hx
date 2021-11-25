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
	var nameLength = 5;
	var nameoffset = 0;
	var selectedLength = false;
	var chartPrefix:String = "";

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


		loadingText = new FlxText(FlxG.width/4, FlxG.height/2 - 36, FlxG.width, "empty");
		loadingText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);


		super.create();
		var valid = false;
		var assets = '${folder}assets/'; // For easy access
		if (!FileSystem.exists(assets)) {
			done = selectedLength = true;
			loadingText.text = '${folder} doesn\'t have a assets folder!';
			loadingText.color = FlxColor.RED;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		} //This folder is not a mod!
		if (folder == Sys.getCwd()) {
			done = selectedLength = true;
			loadingText.text = 'You\'re trying to import songs from me!';
			loadingText.color = FlxColor.RED;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		} //This folder is the same folder that FNFBR is running in!
		if(FileSystem.exists('${assets}songs/')){
			for (directory in FileSystem.readDirectory('${assets}songs/')) {
				if(!FileSystem.isDirectory('${assets}songs/${directory}') || (!importExisting && existingSongs.contains(directory.toLowerCase()))) continue; // Skip if it's a file or if it's on the existing songs list
				var dir:String = '${folder}assets/songs/${directory}/';
				if(!FileSystem.exists('${dir}Inst.ogg') || !FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" or "${dir}Inst.ogg" doesnt exist');continue;}
				valid = true;
			}
		}
		if(FileSystem.exists('${assets}music/')){
			for (directory in FileSystem.readDirectory('${assets}music/')) {
				if(!importExisting && existingSongs.contains(directory.toLowerCase())) {continue;} // Skip if it's on the existing songs list
				var dir:String = '${folder}assets/music/${directory}-';
				if(!FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" doesnt exist');continue;}
				valid = true;
			}
		}
		if(valid){
			updateLoadinText(false,true);
		}else{
			done = selectedLength = true;
			loadingText.color = FlxColor.RED;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			loadingText.text = '${folder} doesn\'t contain any songs!' + (if(!importExisting) "\nMaybe try allowing vanilla songs to be imported\n*(Press 1 to toggle importing vanilla songs in the list)" else "");

		}
	}
	function scanSongs(){
		try{

			var assets = '${folder}assets/'; // For easy access
			if(FileSystem.exists('${assets}songs/')){

				for (directory in FileSystem.readDirectory('${assets}songs/')) {
					loadingText.text = 'Checking ${directory}...'; // Just display this text
					draw();
					if(!FileSystem.isDirectory('${assets}songs/${directory}') || (!importExisting && existingSongs.contains(directory.toLowerCase()))) continue; // Skip if it's a file or if it's on the existing songs list
					var dir:String = '${folder}assets/songs/${directory}/';
					if(!FileSystem.exists('${dir}Inst.ogg') || !FileSystem.isDirectory('${assets}data/${directory}/') ) {trace('"${assets}data/${directory}/" or "${dir}Inst.ogg" doesnt exist');continue;}

					var outDir:String = Sys.getCwd() + 'mods/charts/${chartPrefix}${directory}/';
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

				var outDir:String = Sys.getCwd() + 'mods/charts/${chartPrefix}${directory}/';
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

			}
			songsImported++;
		}}
		loadingText.text = 'Imported ${songsImported} songs. All song names are prefixed with "${chartPrefix}" \nPress any key to go to the main menu';
		loadingText.x -= 70;
		done = true;
		}catch(e) MainMenuState.handleError('Error while trying to scan for songs, ${e.message}');
	}

	function updateLoadinText(shiftPress:Bool = false,sub:Bool = false,?skip:Bool = false){
		if(!skip){
			if(shiftPress){
				var addition = nameoffset + if(sub) -1 else 1;
				if(addition <= 0) addition = nameLength - 1; 
				if(addition > nameLength) addition = 0;
				nameoffset = addition;
			}else{
				var addition = nameLength + if(sub) -1 else 1;
				if(addition <= 0) addition = name.length; 
				if(addition > name.length) addition = 0;
				nameLength = addition;
			}
		}
		if (nameLength == 0 || name.substr(nameoffset,nameLength) == "") chartPrefix = ""; 
		else{
			chartPrefix = name.substr(nameoffset,nameLength) + '-';
		}
		loadingText.text = 'Please select a folder name length:'+
		'\n[${chartPrefix}SONG.EXT]'+
		'\n Left/Right can be used to change length'+
		"\n  Holding shift will edit the offset";

	}
	override function update(elapsed:Float)
	{
		if (done && FlxG.keys.justPressed.ANY) {
			FlxG.switchState(new OtherMenuState());
		}
		if(!selectedLength){
			if(FlxG.keys.justPressed.ENTER){
				selectedLength = true;
				loadingText.text = "Scanning for songs..\nThe game may "+ (if(Sys.systemName() == "Windows")"'not respond'" else "freeze") + " during this process";
				new FlxTimer().start(0.6, function(tmr:FlxTimer){scanSongs();}); // Make sure the text is actually printed onto the screen before doing anything
			}
			if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT){
				updateLoadinText(FlxG.keys.pressed.SHIFT,FlxG.keys.justPressed.LEFT);
			}
		}
		super.update(elapsed);
	}


}
