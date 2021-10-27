package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	static var offscreenY:Int = 0; //+50 to prevent notes from randomly appearing

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var shouldntBeHit:Bool = false;
	// public var playerNote:Bool = false;
	public var type:Dynamic = 0; // Used for scriptable arrows 
	public var isSustainNoteEnd:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var noteNames:Array<String> = ["purple","blue","green",'red'];
	public var skipNote:Bool = true;
	public var childNotes:Array<Note> = [];
	public var parentNote:Note = null;
	var showNote = true;

	public var rating:String = "shit";


	public function loadFrames(){
		if (frames == null){
			try{
				if (shouldntBeHit && FlxG.save.data.useBadArrowTex) {frames = FlxAtlasFrames.fromSparrow(NoteAssets.badImage,NoteAssets.badXml);}
			}catch(e){trace("Couldn't load bad arrow sprites, recoloring arrows instead!");}
			try{
				if(frames == null && shouldntBeHit) {color = 0x220011;}
				if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
			}catch(e) {
				try{
					TitleState.loadNoteAssets(true);
					if(shouldntBeHit) {color = 0x220011;}
					frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
				}catch(e){
					MainMenuState.handleError("Unable to load note assets, please restart your game!");
					
				}
			}
		}

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

	public function new(strumTime:Float, _noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false,?_type:Dynamic = 0,?rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
	{try{
		super();
		

		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = playerNote; 
		type = _type;
		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();


		showNote = !(!playerNote && !FlxG.save.data.oppStrumLine);
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || (_type == 1 || _type == "hurt note" || _type == "hurt" || _type == true));
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else 
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = _noteData % 4;
		if(rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteCreate",[this,rawNote]);


		//defaults if no noteStyle was found in chart
		loadFrames();

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;
		var noteName = noteNames[noteData];



		x+= swagWidth * noteData;
		animation.play(noteName + "Scroll");

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS 
		flipY = (FlxG.save.data.downscroll && sustainNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;
			

			x += width / 2;

			animation.play(noteName + "holdend");
			isSustainNoteEnd = true;
			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(noteName + "hold");
				if (prevNote.parentNote != null){
					prevNote.parentNote.childNotes.push(this);
					this.parentNote = prevNote.parentNote;
				}else{
					prevNote.childNotes.push(this);
					this.parentNote = prevNote;
				}
				prevNote.isSustainNoteEnd = false;
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * (if(FlxG.save.data.scrollSpeed != 1) FlxG.save.data.scrollSpeed else PlayState.SONG.speed);
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		if(rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteAdd",[this,rawNote]);
		visible = false;
	}catch(e){MainMenuState.handleError('Caught "Note create" crash: ${e.message}');}}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!skipNote || isOnScreen()){ // doesn't calculate anything until they're on screen
			skipNote = false;
			visible = showNote;

			if (mustPress)
			{
				// ass
				if ((isSustainNote && (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5) && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)) ) ||
				    strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset  )
						canBeHit = true;

				if (!wasGoodHit && strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale){
					canBeHit = false;
					tooLate = true;
					alpha = 0.3;
				}
			}
			else
			{
				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}

			// if (tooLate)
			// {
			// 	if (alpha > 0.3)
			// }
		}
	}
}