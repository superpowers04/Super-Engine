package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import Note;
import flixel.addons.display.FlxSliceSprite;

import PlayState;

using StringTools; 

class HoldNote extends Note
{
	var subSprite:FlxSliceSprite;

	public function new(?strumTime:Float = 0, ?_noteData:Int = 0, ?prevNote:Note, ?sustainNote:Bool = false, ?_inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false,?ret:Bool = false)
	{try{
		super([],true);
		
		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = playerNote; 
		type = _type;
		this.inCharter = _inCharter;
		if(_rawNote == null){
			this.rawNote = [strumTime,_noteData,0];
		}else{
			this.rawNote = _rawNote;

		}


		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();


		this.noteData = _noteData % 4; 
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || (_type == 1 || _type == "hurt note" || _type == "hurt" || _type == true));
		if(inCharter){
			this.strumTime = strumTime;
			showNote = true;
		}else{
			this.strumTime = Math.round(strumTime);
		}
			
			

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (this.strumTime < 0 )
			this.strumTime = 0;
		if(shouldntBeHit && PlayState.SONG != null && PlayState.SONG.inverthurtnotes) mustPress=!mustPress;

		callInterp("noteCreate",[this,rawNote]); 
		if(killNote){return;}

		
		Note.lastNoteID++;
		noteID = Note.lastNoteID;
		//defaults if no noteStyle was found in chart
		loadFrames();

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;
		var noteName = Note.noteNames[noteData];
		if(eventNote || noteName == null || noteName == "") noteName = Note.noteNames[0];


		x+= Note.swagWidth * noteData;
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
			updateHitbox();

			x -= width / 2;
			parentNoteWidth = prevNote.width;
			
			animation.play(noteName + "hold");
			prevNote.childNotes.push(this);
			this.parentNote = prevNote;
			// prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * (if(FlxG.save.data.scrollSpeed != 1) FlxG.save.data.scrollSpeed else PlayState.SONG.speed);
			prevNote.updateHitbox();
			subSprite = new FlxSliceSprite(graphic,spliceRect,width,height,frame.uv);
			subSprite.fillCenter=true;
		}
		
		visible = true;
		callInterp("noteAdd",[this,rawNote]);
	}catch(e){MainMenuState.handleError(e,'Caught "Note create" crash: ${e.message}');}}
	var spliceRect:FlxRect = new FlxRect(0,0,30,30);
	override function draw(){
		if(subSprite != null){
			subSprite.cameras = cameras;
			subSprite.draw();
		}else super.draw();
	}

	override function update(elapsed:Float)
	{
		updateSuper(elapsed);

		callInterp("noteUpdate",[this]);

		if (mustPress)
		{
			// ass
			if (shouldntBeHit)
			{
				if (strumTime - Conductor.songPosition <= (45 * Conductor.timeScale) && strumTime - Conductor.songPosition >= (-45 * Conductor.timeScale))
					canBeHit = true;
				else
					canBeHit = false;
			}else{

				if (parentNote == null){
					canBeHit = true;
					if(!isSustainNoteEnd && clip && PlayState.instance.playerStrums.members[noteData] != null){
						spliceRect.x = endNote.x;
						spliceRect.width = endNote.width;
						spliceRect.y = endNote.y;
						spliceRect.height = PlayState.instance.playerStrums.members[noteData].y - spliceRect.y;

					}
				}else if(parentNote.tooLate){
					// canBeHit = false;
					tooLate = true;
					alpha = 0.3;

				}else{
					if(!isSustainNoteEnd && endNote != null){
						spliceRect.x = endNote.x;
						spliceRect.width = endNote.width;
						spliceRect.y = endNote.y;
						spliceRect.height = parentNote.y - spliceRect.y;
					}
				}

				// if (canBeHit && !wasGoodHit && strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale){
				// 	canBeHit = false;
				// 	tooLate = true;
				// 	alpha = 0.3;
				// }
			}
		}
		else if (aiShouldPress && !PlayState.p2canplay && strumTime <= Conductor.songPosition)
		{
			wasGoodHit = true;
		}
		callInterp("noteUpdateAfter",[this]);

			
		
	}
}