package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flash.media.Sound;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

typedef MusicTime ={
	var file:String;
	var begin:Int;
	var end:Int;
	var color:Int;
	var wrapAround:Bool;
	var bpm:Float;
}

class SickMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var options:Array<String> = ["replace me dammit", "what are you doing, replace me"];
	var descriptions:Array<String> = ["Hello there, Please report this","Bruh"];

	var descriptionText:FlxText;
	var grpControls:FlxTypedGroup<Alphabet>;
	var bgImage:String = "menuDesat";
	var selected:Bool = false;
	var bg:FlxSprite;
	public static var menuMusic:Sound;
	public static var musicTime:Int = 8;
	public static var fading:Bool = false;
	public static var curSongTime:Float = 0;
	public static var musicFileLoc:String = "";
	public static var chgTime:Bool = false;
	public static var musicList:Array<MusicTime> = [
		{
			file: if(FileSystem.exists("mods/title-morning.ogg")) "mods/title-morning.ogg" else Paths.music("breakfast"),
			begin:6,end:10,wrapAround:false,color:0xdd9911,bpm:160
		},
		{
			file: if(FileSystem.exists("mods/title-day.ogg")) "mods/title-day.ogg" else Paths.music('freakyMenu'),
			wrapAround:false,end:100,begin:101,color:0xECD77F,bpm:204 // Uses 100 because there is no 100th hour of the day, if there is than what the hell device are you using?
		},
		{
			file: if(FileSystem.exists("mods/title-evening.ogg")) "mods/title-evening.ogg" else Paths.music("GiveaLilBitBack"),
			begin:17,end:19,wrapAround:false,color:0xdd9911,bpm:125
		},
		{
			file: if(FileSystem.exists("mods/title-night.ogg")) "mods/title-night.ogg" else Paths.music("freshChillMix"),
			begin:20,end:5,wrapAround:true,color:0x113355,bpm:117
		},
	];
	var isMainMenu:Bool = false;


	function goBack(){
		FlxG.switchState(new MainMenuState());
	}
	function generateList(?reload:Bool = false){
		if(reload){
			grpControls = new FlxTypedGroup<Alphabet>();
			add(grpControls);
		}
		grpControls.clear();
		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			if (i != 0)
				controlLabel.alpha = 0.6;
			grpControls.add(controlLabel);
		}
	}
	public static function musicHandle(?isMainMenu:Bool = false,?_bg:FlxSprite = null,?recolor:Bool = false){


			var time:Int = Date.now().getHours();
			var curMusicTime = 1;
			for (i in 0 ... SickMenuState.musicList.length) {
				var v = SickMenuState.musicList[i];
				if (!v.wrapAround && time >= v.begin && time <= v.end || (v.wrapAround && (time >= v.begin || time <= v.end))){
					curMusicTime = i;
					break;
				}
			}

			var musicTime = SickMenuState.musicTime;
			var mt:MusicTime = SickMenuState.musicList[curMusicTime];
				
			if (SickMenuState.menuMusic == null || musicTime != curMusicTime){
				
				if(FlxG.sound.music.playing){if(!SickMenuState.fading){SickMenuState.fading = true;
					var switchToColor = mt.color;
					if(isMainMenu && _bg != null){
						MainMenuState.bgcolor = switchToColor;
					}
					var col = _bg.color;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						FlxG.sound.music.volume -= 0.1;
						if((isMainMenu || recolor) && _bg != null){
							_bg.color = FlxColor.interpolate(col,switchToColor,tmr.loops * 0.1);
						}              
						if(tmr.elapsedLoops > 9){
							SickMenuState.curSongTime = FlxG.sound.music.time;
							FlxG.sound.music.stop();
							
							musicHandle(isMainMenu,_bg);
						}
					},10);
					}
					return;}
				SickMenuState.fading = false;
				SickMenuState.musicFileLoc = mt.file;
				SickMenuState.menuMusic = Sound.fromFile(SickMenuState.musicFileLoc);
				SickMenuState.musicTime = curMusicTime;
				Conductor.changeBPM(mt.bpm);

			// if (_bg != null){ }

			FlxG.sound.playMusic(SickMenuState.menuMusic);
			if (!MainMenuState.firstStart) FlxG.sound.music.time = FlxMath.wrap(Math.floor(SickMenuState.curSongTime),0,Math.floor(FlxG.sound.music.length));
			}else if (!FlxG.sound.music.playing) FlxG.sound.playMusic(SickMenuState.menuMusic);
			if(!isMainMenu && !recolor && _bg != null){
				_bg.color = FlxColor.interpolate(_bg.color,SickMenuState.musicList[musicTime].color,0.2);
			}else if(recolor && _bg != null){
				_bg.color = mt.color;
			}
	}

	override function create()
	{
		// if (ChartingState.charting) ChartingState.charting = false;
		SearchMenuState.resetVars();
		// if (FlxG.save.data.songUnload && PlayState.SONG != null) {PlayState.SONG = null;}
		// PlayState.songScript = "";PlayState.hsBrTools = null;
		if(SearchMenuState.background == null){
			SearchMenuState.background = if(FileSystem.exists("mods/bg.png")) Paths.getImageDirect("mods/bg.png"); else Paths.getImageDirect("assets/images/menuDesat.png");
			SearchMenuState.backgroundOver = if(FileSystem.exists("mods/fg.png")) Paths.getImageDirect("mods/fg.png"); else FlxGraphic.fromRectangle(0,0,0x00000000);
			SearchMenuState.background.persist = SearchMenuState.backgroundOver.persist = true;
			SearchMenuState.background.destroyOnNoUse = SearchMenuState.backgroundOver.destroyOnNoUse = false;
		}


		if(bg == null){
			
			bg = new FlxSprite().loadGraphic(SearchMenuState.background); 
			bg.color = 0xFFFF6E6E;
		}

		bg.scrollFactor.set(0.01,0.01);
		add(bg);
		var bgOver = new FlxSprite().loadGraphic(SearchMenuState.backgroundOver);
		bgOver.scrollFactor.set(0.01,0.01);
		add(bgOver);
		musicHandle(isMainMenu,bg);



		generateList(true);

		descriptionText = new FlxText(5, FlxG.height - 28, 0, descriptions[0], 12);
		descriptionText.scrollFactor.set();
		descriptionText.setFormat(CoolUtil.font, 22, FlxColor.WHITE, LEFT, NONE, FlxColor.BLACK);
		descriptionText.borderSize = 2;
		var blackBorder:FlxSprite = new FlxSprite(-30,FlxG.height - 30).makeGraphic((FlxG.width),40,FlxColor.fromString("0x220011"));
		blackBorder.alpha = 0.8;

		add(blackBorder);

		add(descriptionText);


		FlxG.mouse.visible = false;
		FlxG.autoPause = true;


		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		if (selected) return;
		if (controls.BACK)
		{
			goBack();
		}
		if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} else if (controls.UP_P){changeSelection(-1);}
		if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} else if (controls.DOWN_P){changeSelection(1);}

		if (controls.ACCEPT)
		{

			select(curSelected);
		}
	}
	var curTween:FlxTween;
	override function beatHit(){
		super.beatHit();
		if(grpControls.members[curSelected].useAlphabet){
			
			grpControls.members[curSelected].scale.set(1.2,1.2);
			if(curTween != null)curTween.cancel();
			curTween = FlxTween.tween(grpControls.members[curSelected].scale,{x:1,y:1},(60 / Conductor.bpm));
		}
	}
	function select(sel:Int){
		trace("Why wasn't this replaced?");
	}
	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;


		descriptionText.text = descriptions[curSelected];


		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = 0xdddddd;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = 0xffffff;
			}
		}

	}
}
