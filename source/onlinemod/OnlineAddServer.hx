package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;

import openfl.net.Socket;
import openfl.utils.ByteArray;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

#if windows
import Discord.DiscordClient;
#end
class OnlineAddServer extends MusicBeatSubstate
{
	static var errorText:FlxText;
	var ipField:FlxInputText;
	var portField:FlxInputText;
	var pwdField:FlxInputText;
	public static var muteKeys:Array<Int>;
	public static var volumeUpKeys:Array<Int>;
	public static var volumeDownKeys:Array<Int>;

	var ServerList:Array<Array<Dynamic>> = [];
	var SaveButton:FlxUIButton;

	public function new(?color:FlxColor=FlxColor.RED) {
		super();
	}
	inline function saveServer(){
		SESave.data.savedServers.push([ipField.text,portField.text,pwdField.text]);
		SEFlxSaveWrapper.save();
	}
	override function create() {
		TitleState.supported = false;
		var bg:FlxSprite = new FlxSprite(0,-FlxG.height * 0.25).loadGraphic(FlxGraphic.fromRectangle(FlxG.width,Std.int(FlxG.height * 1.5),0xff000000));
		bg.alpha = 0.7;
		add(bg);

		var topText = new FlxText(0, FlxG.height * 0.05, "Add server");
		topText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		topText.screenCenter(FlxAxes.X);
		add(topText);


		var ipText:FlxText = new FlxText(290, FlxG.height * 0.3 - 40, "IP Address:");
		ipText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(ipText);

		ipField = new FlxInputText(0,FlxG.height * 0.3, 700,32);
		ipField.setFormat(32, FlxColor.BLACK, CENTER);
		ipField.screenCenter(FlxAxes.X);
		ipField.customFilterPattern = ~/[^A-Za-z0-9.-]/;
		ipField.hasFocus = true;
		add(ipField);

		var portText:FlxText = new FlxText(290, FlxG.height * 0.5 - 40, "Port:");
		portText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(portText);

		portField = new FlxInputText(0,FlxG.height * 0.5, 700,32);
		portField.setFormat(32, FlxColor.BLACK, CENTER);
		portField.screenCenter(FlxAxes.X);
		portField.customFilterPattern = ~/[^0-9]/;
		portField.maxLength = 6;
		add(portField);

		var pwdText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.7 - 40, "Password:");
		pwdText.setFormat(CoolUtil.font, 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pwdText);

		pwdField = new FlxInputText(0, FlxG.height * 0.7, 700, 32);
		pwdField.setFormat(32, FlxColor.BLACK, CENTER);
		pwdField.screenCenter(FlxAxes.X);
		// pwdField.passwordMode = true;
		add(pwdField);

		var ConnectButton = new FlxUIButton(0, FlxG.height * 0.85, "Connect", () -> {
			OnlinePlayMenuState.Connect(ipField.text,portField.text,pwdField.text);
		});
		ConnectButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
		ConnectButton.resize(200, 50);
		ConnectButton.screenCenter(FlxAxes.X);
		ConnectButton.x -= 375;
		add(ConnectButton);

		var ConnectSaveButton = new FlxUIButton(0, FlxG.height * 0.85, "Save & Connect", () -> {
			saveServer();
			OnlinePlayMenuState.Connect(ipField.text,portField.text,pwdField.text);
		});
		ConnectSaveButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
		ConnectSaveButton.resize(200, 50);
		ConnectSaveButton.screenCenter(FlxAxes.X);
		ConnectSaveButton.x -= 125;
		add(ConnectSaveButton);

		var SaveButton = new FlxUIButton(0, FlxG.height * 0.85, "Save", () -> {
			saveServer();
			close();
		});
		SaveButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
		SaveButton.resize(200, 50);
		SaveButton.screenCenter(FlxAxes.X);
		SaveButton.x += 125;
		add(SaveButton);

		var BackButton = new FlxUIButton(0, FlxG.height * 0.85, "Go Back", close);
		BackButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
		BackButton.resize(200, 50);
		BackButton.screenCenter(FlxAxes.X);
		BackButton.x += 375;
		add(BackButton);

		AddXieneText(this);

		FlxG.mouse.visible = true;
		FlxG.autoPause = true;


		muteKeys = FlxG.sound.muteKeys;
		volumeUpKeys = FlxG.sound.volumeUpKeys;
		volumeDownKeys = FlxG.sound.volumeDownKeys;
		for (i in members){

			var i = cast (i,FlxSprite);
			if(i != null){
				var _y = i.y;
				var _a = i.alpha;
				i.y -= FlxG.height * 0.24;
				i.alpha = 0;
				FlxTween.tween(i,{alpha:_a,y:_y},0.5,{ease:FlxEase.quadInOut});
			}
		}




		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!(ipField.hasFocus || portField.hasFocus || pwdField.hasFocus))
		{
			SetVolumeControls(true);
			if (controls.BACK) close();
		}
		else
		{
			SetVolumeControls(false);
		}
		super.update(elapsed);
	}

	static function SetErrorText(text:String, color:FlxColor=FlxColor.RED)
	{
		OnlineAddServer.errorText.text = text;
		OnlineAddServer.errorText.setFormat(32, color);
		OnlineAddServer.errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	}

	public static function SetVolumeControls(enabled:Bool)
	{
		if (enabled)
		{
			FlxG.sound.muteKeys = muteKeys;
			FlxG.sound.volumeUpKeys = volumeUpKeys;
			FlxG.sound.volumeDownKeys = volumeDownKeys;
		}
		else
		{
			FlxG.sound.muteKeys = null;
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
		}
	}

	public static function AddXieneText(state:FlxState)
	{
		var xieneText = new FlxText(0, FlxG.height - 30, "XieneDev - BR Online");
		xieneText.setFormat(CoolUtil.font, 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		xieneText.screenCenter(FlxAxes.X);
		state.add(xieneText);
	}

}