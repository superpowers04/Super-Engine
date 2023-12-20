package;

import sys.Http;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.io.Bytes;

using StringTools;

typedef RepoJSON = {
	var characters:Array<RepoCharsJSON>;
	// TODO, add support for songs too
}
typedef RepoCharsJSON = {
	var url:String;
	var name:String;
	var description:String;
	var subFolder:Bool;
}

class RepoState extends SickMenuState
{
	var repo = "https://raw.githubusercontent.com/superpowers04/FNFBR-Repo/main/characters.json";
	public static var unarExe = 
	#if windows
	"C:\\Program Files\\7-Zip\\7z.exe";
	#else
	"/bin/7z";
	#end
	var repoArray:RepoJSON;
	var repoRet:String = "";
	var installing:Int = 0;
	var installingList:Array<String> = [];
	var installingText:FlxText;
	var installedText:FlxText;
	var waiting:Bool = true;

	@:keep inline public static function unzip(from:String,to:String):Void{
		Sys.command(unarExe,['x','-y',from,'-o${to}']);
	}
	override function goBack(){
		if(installing<=0){super.goBack();}
	}
	override function generateList(?regen:Bool = false){
	    for (i in 0...repoArray.characters.length)
	    {
	      var name = repoArray.characters[i].name;
	      // if (TitleState.choosableCharacters.contains(name)){name+=" | Installed";}
	      var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
	      
	      controlLabel.isMenuItem = true;
	      controlLabel.targetY = i;
	      if (i != 0)controlLabel.alpha = 0.6;
	      grpControls.add(controlLabel);
	      descriptions.push(repoArray.characters[i].description);
	    }
	  }
	override public function create():Void
	{
		#if (linux || windows)
			grpControls = new FlxTypedGroup<Alphabet>();
			descriptions = [];
			if (!sys.FileSystem.exists(unarExe)) {
				MainMenuState.handleError("This feature requires 7-Zip to be installed");
				return;			
			}
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				
				var http = new Http(repo);
				
				http.onData = function (data:String)
				{
					repoRet += data;
					createCont();
				}
				
				http.onError = function (error) {
					MainMenuState.handleError('Something went wrong, $error');
					return;	
				}
				
				http.request();
			});
		#else
			MainMenuState.handleError('This feature is not supported on ${Sys.systemName()}!');
			return;
		#end

	}
	override public function update(elapsed:Float){
		if(waiting) return;
		super.update(elapsed);

	}
	function createCont():Void{
		if (repoRet == "") {
			MainMenuState.handleError('Something went wrong, Nothing was returned by the Repo!');
			return;	
		}
		try{
			repoArray = haxe.Json.parse(repoRet);
			if (repoArray.characters[0] == null){
				throw("Nothing returned!");
			}
		}catch(e){
			trace('Error with JSON returned: ' + e.message + "");
			MainMenuState.handleError('Something went wrong, ${e.message}');
			return;	
		}
		super.create();
		bg.color = 0x335533;

		installingText = new FlxText(FlxG.width * 0.12, 5, 0,'Installing ${installing}', 32);
		installingText.scrollFactor.set();
		installingText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installingText);
		installedText = new FlxText(FlxG.width * 0.8, 5, 0,'Not Installed', 32);
		installedText.scrollFactor.set();
		installedText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installedText);
		updateText();
		waiting = false;
	}
	override function select(sel:Int){
		var char:RepoCharsJSON = repoArray.characters[sel];
		if(installingList.contains(char.name)){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		FlxG.sound.play(Paths.sound('confirmMenu'));
		try{
			// var characterZip:Bytes;
			installing += 1;
			installingList.push(char.name);
			updateText();
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				
				var http = new Http(char.url);
				
				http.onBytes = function (data:Bytes)
				{
					finishDownload(data,char,sel);
				}
				
				http.onError = function (error) {
					MainMenuState.handleError('Something went wrong, $error');
					return;	
				}
				
				http.request();
			});

		}catch(e){MainMenuState.handleError(e,'Something went wrong, ${e.message}');
			return;	
		}
	}
  	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		updateText();
	}
	function updateText(){
		installingText.text = 'Installing ${installing} mod${if (installing != 1) 's' else '' }';
		installedText.text = if (TitleState.retChar(repoArray.characters[curSelected].name) != "") "Installed" else "Not Installed";
	}
	function finishDownload(data:Bytes,char:RepoCharsJSON,sel:Int){
		File.saveBytes(Sys.getCwd() + 'mods/characters/${char.name}.zip',data);

		var instDir = Sys.getCwd() + 'mods/characters/${char.name}/';
		if(char.subFolder){ instDir = Sys.getCwd() + 'mods/characters/';}
		unzip(Sys.getCwd() + 'mods/characters/${char.name}.zip',instDir);
		TitleState.checkCharacters();
		installingList.remove(char.name);
		installing-=1;
		updateText();

		FlxG.sound.play(Paths.sound('confirmMenu'));
	}
}