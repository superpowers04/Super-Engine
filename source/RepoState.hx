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
import flixel.system.FlxSound;
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
	var unarExe = "/bin/7z";
	var repoArray:RepoJSON;
	var repoRet:String = "";
	var installing:Int = 0;
	var installingList:Array<String> = [];
	var installingText:FlxText;
	var installedText:FlxText;

	function unzip(from:String,to:String):Void{
		Sys.command(unarExe,['x','-y',from,'-o${to}']);
	}
	override function goBack(){
		if(installing<=0){super.goBack();}
	}
	override function generateList(){
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
		#if mac
			MainMenuState.handleError("This feature is not supported on mac!");
			return;
		#end
		descriptions = [];
		#if windows
			unarExe = "C:\\Program Files\\7-Zip\\7z.exe";
		#end
		if (!sys.FileSystem.exists(unarExe)) {
			MainMenuState.handleError("This feature requires 7-Zip to be installed");
			return;			
		}
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			// Get current version of Kade Engine
			
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

	}
	override public function update(elapsed:Float){
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

		installingText = new FlxText(5, 50, 0,'Installing ${installing}', 12);
		installingText.scrollFactor.set();
		installingText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installingText);
		installedText = new FlxText(FlxG.width - 60, 50, 0,'Not Installed', 12);
		installedText.scrollFactor.set();
		installedText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installedText);
		updateText();
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
			new FlxTimer().start(2, function(tmr:FlxTimer)
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

		}catch(e){
			MainMenuState.handleError('Something went wrong, ${e.message}');
			return;	
		}
	}
  	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		updateText();
	}
	function updateText(){
		installingText.text = 'Installing ${installing}';
		installedText.text = if (TitleState.choosableCharacters.contains(repoArray.characters[curSelected].name)) "Installed" else "Not Installed";
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
	}
}