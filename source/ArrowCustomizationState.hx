package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUIColorSwatchSelecter;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;



import sys.io.File;
import sys.FileSystem;

// using StringTools;

class ArrowCustomizationState extends MusicBeatSubstate{
	public var playerStrums:FlxTypedGroup<StrumArrow> = new FlxTypedGroup<StrumArrow>();
	public var strumList:Array<FlxGroup> = [];
	var note:FlxSprite = null;
	// var susnote:Note = null;
	// var endnote:Note = null;

	var curSelected:Int = 0;
	var holdArray:Array<Bool> = [false,false,false,false];
	function generateStaticArrows(player:Int):Void
	{

		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumArrow = new StrumArrow(i,0, if (FlxG.save.data.downscroll) FlxG.height - 165 else 50);

			babyArrow.init();
			babyArrow.x += Note.swagWidth * i + i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();


			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			// babyArrow.ID = i;

			
			playerStrums.add(babyArrow);
			strumList[id] = new FlxGroup();
			strumList[id].add(babyArrow);
			

			babyArrow.playStatic(); 
			// Todo, clean this shitty code up
			babyArrow.x += 50;

			babyArrow.x += (FlxG.width / 4) * 1;
			babyArrow.y += 200;
			



			// strumLineNotes.add(babyArrow);
		}
	}
	override function create(){
		TitleState.loadNoteAssets(true);

		var blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		blackBox.alpha = 0.6;
		add(blackBox);
		generateStaticArrows(0);
		for (i in 0 ... strumList.length) {
			add(strumList);
			
		}
		// selector = new FlxUIColorSwatchSelecter(0,0);
		// selector.screenCenter();
		// selector.y += Std.int(FlxG.height * 0.5);
		// add(selector);
		// add(notes);
		PlayState.SONG = Song.parseJSONshit(File.getContent("assets/data/tutorial/tutorial.json"));

	}


}


