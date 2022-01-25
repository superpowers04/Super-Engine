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

typedef ChRepoJSON = {
	var charts:Array<RepoChartsJSON>;
}
typedef RepoChartsJSON = {
	var url:String;
	var name:String;

	var porter:String;
	var originalMod:String;

	var hscript:Bool;
	var description:String;
	var subFolder:Bool;
}

class ChartRepoState extends SearchMenuState
{
	var repo = "https://raw.githubusercontent.com/superpowers04/FNFBR-Repo/main/charts.json";
	#if windows
	var unarExe = "C:\\Program Files\\7-Zip\\7z.exe";
	#else
	var unarExe = "/bin/7z";
	#end
	var repoArray:ChRepoJSON;
	var repoRet:String = "";
	var installing:Int = 0;
	var installingList:Array<String> = [];
	var installingText:FlxText;
	var installedText:FlxText;

	function unzip(from:String,to:String):Void{
		Sys.command(unarExe,['x','-y',from,'-o${to}']);
	}
	override function ret(){
		if(installing<=0){FlxG.mouse.visible = false;FlxG.switchState(new MainMenuState());}else{installingText.color = FlxColor.RED;}
	}
	override function reloadList(?reload = false,?search=""){
		curSelected = 0;
		if(reload){grpSongs.destroy();}
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		songs = [];

		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing

	    for (i in 0...repoArray.charts.length)
	    {
			// var name = repoArray.charts[i].name;
			// // if (TitleState.choosableCharacters.contains(name)){name+=" | Installed";}
			// var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);

			// controlLabel.isMenuItem = true;
			// controlLabel.targetY = i;
			// if (i != 0)controlLabel.alpha = 0.6;
			// grpControls.add(controlLabel);
			// descriptions.push(repoArray.charts[i].description);

			if(search == "" || query.match(repoArray.charts[i].name.toLowerCase()) ){
				addToList(repoArray.charts[i].name,i);
			}
	    }
	  }
	override public function create():Void
	{
		retAfter = false;
		toggleables['search'] = false;
		#if mac
			MainMenuState.handleError("This feature is not supported on mac!");
			return;
		#end
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
			if (repoArray.charts[0] == null){
				throw("Nothing returned!");
			}
		}catch(e){
			trace('Error with JSON returned: ' + e.message + "");
			MainMenuState.handleError('Something went wrong, ${e.message}');
			return;	
		}
		toggleables['search'] = true;
		super.create();
		bg.color = 0x335566;

		installingText = new FlxText(FlxG.width * 0.12, 5, 0,'Installing ${installing}', 32);
		installingText.scrollFactor.set();
		installingText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installingText);
		installedText = new FlxText(FlxG.width * 0.8, 5, 0,'Not Installed', 32);
		installedText.scrollFactor.set();
		installedText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(installedText);
		changeSelection(0);
		updateText();
	}
	override function select(sel:Int = 0){
		var char:RepoChartsJSON = repoArray.charts[sel];
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
		if (songs[curSelected] != "" && repoArray.charts[curSelected].description != null && repoArray.charts[curSelected].description != ""){
		  updateInfoText('Description: ' + repoArray.charts[curSelected].description);
		}else{
		  updateInfoText('No description for this chart.');
		}
		super.changeSelection(change);
		updateText();
	}
	function updateText(){
		if(installing > 0){
			installingText.text = 'Installing ${installing} mod${if (installing != 1) 's' else '' }.';
		}else{installingText.text = 'Nothing is installing.';}
		installedText.text = if (FileSystem.exists('mods/charts/${repoArray.charts[curSelected].name}/')) "Installed" else "Not Installed";
		if (FileSystem.exists('mods/charts/${repoArray.charts[curSelected].name}/')) installedText.color = FlxColor.GREEN;
	}
	function finishDownload(data:Bytes,char:RepoChartsJSON,sel:Int){
		FileSystem.createDirectory('mods/charts/');
		File.saveBytes(Sys.getCwd() + 'mods/charts/${char.name}.zip',data);

		var instDir = Sys.getCwd() + 'mods/charts/${char.name}/';
		if(char.subFolder){ instDir = Sys.getCwd() + 'mods/charts/';}
		unzip(Sys.getCwd() + 'mods/charts/${char.name}.zip',instDir);
		installingList.remove(char.name);
		installing-=1;
		updateText();

		FlxG.sound.play(Paths.sound('confirmMenu'));
	}
}