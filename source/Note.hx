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
	public var type:Int = 0; // Used for scriptable arrows 
	public var isSustainNoteEnd:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var noteNames:Array<String> = ["purple","blue","green",'red'];
	public var skipNote:Bool = true;
	var showNote = true;

	public var rating:String = "shit";



	public function new(strumTime:Float, _noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false,?_shouldntBeHit:Bool = false,?rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
	{try{
		super();
		

		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = playerNote; 

		showNote = !(!playerNote && !FlxG.save.data.oppStrumLine);
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || _shouldntBeHit);

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
		if (frames == null){
			try{
				if (shouldntBeHit && FlxG.save.data.useBadArrowTex) {frames = FlxAtlasFrames.fromSparrow(NoteAssets.badImage,NoteAssets.badXml);}
			}catch(e){trace("Couldn't load bad arrow sprites, recoloring arrows instead!");}
			try{
				if(frames == null && shouldntBeHit) {color = 0x220011;}
				if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
			}catch(e) throw("Unable to load arrow sprites!");
		}

		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

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
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

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
				animation.play(noteName + "hold");

				prevNote.isSustainNoteEnd = false;

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
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
					else
						canBeHit = false;

				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
					tooLate = true;
			}
			else
			{
				canBeHit = false;

				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}

			if (tooLate)
			{
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}
	}
}