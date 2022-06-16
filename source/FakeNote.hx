// package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import tjson.Json;
import sys.FileSystem;
import flash.display.BitmapData;
import flixel.math.FlxPoint;
import sys.io.File;


using StringTools; 

// Note without any code for updating it's state and such

class FakeNote extends FlxSkewedSprite
{
	public var strumTime:Float = 0;
	public var noteID:Int = 0;
	// public var skipXAdjust:Bool = false;

	public var noteData:Int = 0;
	public var prevNote:Dynamic;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var shouldntBeHit:Bool = false;
	public var isPressed:Bool = false;
	// public var playerNote:Bool = false;
	public var type:Dynamic = 0; // Used for scriptable arrows 
	public var isSustainNoteEnd:Bool = false;
	public var parentNoteWidth:Float = 0;

	public var inCharter:Bool = false;

	public static var swagWidth:Float = 112;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var noteNames:Array<String> = ["purple","blue","green",'red'];
	public var skipNote:Bool = true;
	public var parentNote:Dynamic = null;
	public var showNote = true;
	public var rawNote:Array<Dynamic> = [];
	public var vanillaFrames:Bool = false;
	public var childNotes:Array<Dynamic> = [];
	// public var frames(set,get):FlxFramesCollection;
	// public var _Frames:FlxFramesCollection;


	public function toJson(){
		return Json.stringify({
			type:"Note",
			strumTime:strumTime,
			noteData:noteData,
			noteType:type
		});
	}
	public override function toString(){
		return toJson();
	}
	public function changeSprite(?name:String = "default",?_frames:FlxAtlasFrames,?_anim:String = "",?setFrames:Bool = true,path_:String = "mods/noteassets"){
		try{
			var curAnim = if(_anim == "" && animation.curAnim != null) animation.curAnim.name else if(_anim != "") _anim else anim;
			if(setFrames && (_frames != null || name != "")){
				if(_frames == null){
					if(name == "skin"){
						frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
					}else if (name == 'default' || (!FileSystem.exists('${path_}/${name}.png') || !FileSystem.exists('${path_}/${name}.xml'))){
						frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets.png')),File.getContent("assets/shared/images/NOTE_assets.xml"));
					}else{
						frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path_}/${name}.png')),File.getContent('${path_}/${name}.xml'));
					}
				}else{
					frames = _frames;
				}
			}
			frames = frames.addBorder(new FlxPoint(1,1));
				setGraphicSize(Std.int(width * 0.7));
			if(anim.contains("hold") && !anim.contains("end")){
				scale.y = 1.5;
			}
			antialiasing = true;
			updateHitbox();
			addAnimations();
			animation.play(curAnim);
			centerOffsets();
			offset.x = frameWidth * 0.5;
		}catch(e){MainMenuState.handleError(e,'Error while changing sprite for arrow:\n ${e.message}');
		}
	}
	public function addAnimations(){
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');
		// animation.addByPrefix('${noteNames[noteData]}Scroll','${noteNames[noteData]}0');
		// animation.addByPrefix('${noteNames[noteData]}hold','${noteNames[noteData]} hold piece');
		// animation.addByPrefix('${noteNames[noteData]}holdend','${noteNames[noteData]} end hold');
		// // Kade support, I guess
		// animation.addByPrefix('${noteNames[noteData]}Scroll','${noteNames[noteData]} alone');
		// animation.addByPrefix('${noteNames[noteData]}hold','${noteNames[noteData]} hold');
		// animation.addByPrefix('${noteNames[noteData]}holdend','${noteNames[noteData]} tail'); 



		animation.addByPrefix('purpleholdend', 'pruple end hold'); // Fucking default names
		animation.addByPrefix('purpleholdend', 'purple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');
	}

	public function loadFrames(){
		if(type == 2){
			color = 0xFFFFFF;
			frames = Paths.getSparrowAtlas("EVENTNOTE");
		}
		if (frames == null){
			try{
				if (shouldntBeHit && FlxG.save.data.useBadArrowTex) {frames = FlxAtlasFrames.fromSparrow(NoteAssets.badImage,NoteAssets.badXml);}
			}catch(e){}
			try{
				if(frames == null && shouldntBeHit) {color = 0x220011;}
				if (frames == null) frames = NoteAssets.frames;
				// frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
				vanillaFrames = true;
			}catch(e) {
				try{
					TitleState.loadNoteAssets(true);
					if(shouldntBeHit) {color = 0x220011;}
					frames = NoteAssets.frames;
					vanillaFrames = true;
				}catch(e){MainMenuState.handleError(e,"Unable to load note assets, please restart your game!");}
			}
		}
		addAnimations();

	}
	// Array of animations, to be used above
	public static var noteAnims:Array<String> = ['singLEFT','singDOWN','singUP','singRIGHT']; 
	public static var noteDirections:Array<String> = ['LEFT','DOWN','UP','RIGHT','NONE']; 
	public var killNote = false;
	public var anim:String = "";


	public function new(?strumTime:Float = 0, ?_noteData:Int = 0, ?prevNote:Dynamic, ?sustainNote:Bool = false,?_type:Dynamic = 0)
	{try{
		super();
		
		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		type = _type;


		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();


		this.noteData = _noteData % 4; 
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || (_type == 1 || _type == "hurt note" || _type == "hurt" || _type == true));
		this.strumTime = strumTime;
		showNote = true;

			
			



		//defaults if no noteStyle was found in chart
		loadFrames();

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;
		var noteName = noteNames[noteData];
		if(noteName == null || noteName == "") noteName = noteNames[0];


		// x+= swagWidth * noteData;
		animation.play(noteName + "Scroll");
		anim = noteName + "Scroll";

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS 
		

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			// Funni downscroll flip when sussy note
			flipY = (FlxG.save.data.downscroll);
			

			// x += width / 2;

			animation.play(noteName + "holdend");
			anim = noteName + "holdend";
			isSustainNoteEnd = true;
			updateHitbox();

			// x -= width / 2;


			parentNoteWidth = prevNote.width;

			if (prevNote.isSustainNote)
			{
				parentNoteWidth = prevNote.parentNoteWidth;
				prevNote.anim = noteName + "hold";
				prevNote.animation.play(noteName + "hold");
				if (prevNote.parentNote != null){
					prevNote.parentNote.childNotes.push(this);
					this.parentNote = prevNote.parentNote;
				}else{
					prevNote.childNotes.push(this);
					this.parentNote = prevNote;
				}
				prevNote.isSustainNoteEnd = false;
				prevNote.scale.y *= 1.5;
				prevNote.updateHitbox();

				prevNote.offset.x = prevNote.frameWidth * 0.5;
				// prevNote.setGraphicSize();
			}
		}
		
		updateHitbox();
		// centerOrigin();
		// centerOffsets();
		// offset.y = 0;
		// origin.y=0;
	}catch(e){MainMenuState.handleError(e,'Caught "Fake Note create" crash: ${e.message}\n${e.stack}');}}

}