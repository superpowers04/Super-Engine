package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;

import PlayState;

using StringTools; 

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var noteID:Int = 0;
	public static var lastNoteID:Int = 0;
	public var skipXAdjust:Bool = false;
	public var updateY:Bool = true;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var shouldntBeHit:Bool = false;
	public var isPressed:Bool = false;
	// public var playerNote:Bool = false;
	public var type:Dynamic = 0; // Used for scriptable arrows 
	public var isSustainNoteEnd:Bool = false;
	public var parentNoteWidth:Float = 0;

	public var noteScore:Float = 1;
	public var inCharter:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var noteNames:Array<String> = ["purple","blue","green",'red'];
	public var skipNote:Bool = true;
	public var childNotes:Array<Note> = [];
	public var parentNote:Note = null;
	public var showNote = true;
	public var info:Array<Dynamic> = [];
	public var rawNote:Array<Dynamic> = [];
	
	// public var kill:Bool = false;
	public var rating:String = "shit";
	public var eventNote:Bool = false;
	public var aiShouldPress:Bool = true;
	var ntText:FlxText;
	public var vanillaFrames:Bool = false;
	public var noteAnimation:Null<String> = "";
	public var noteAnimationMiss:Null<String> = "";


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
		if (frames == null){
			try{
				if (shouldntBeHit && FlxG.save.data.useBadArrowTex) {frames = FlxAtlasFrames.fromSparrow(NoteAssets.badImage,NoteAssets.badXml);}
			}catch(e){trace("Couldn't load bad arrow sprites, recoloring arrows instead!");}
			try{
				if(frames == null && shouldntBeHit) {color = 0x220011;}
				if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
				vanillaFrames = true;
			}catch(e) {
				try{
					TitleState.loadNoteAssets(true);
					if(shouldntBeHit) {color = 0x220011;}
					frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
					vanillaFrames = true;
				}catch(e){
					MainMenuState.handleError("Unable to load note assets, please restart your game!");
					
				}
			}
		}
		addAnimations();

	}
	dynamic public function hit(?charID:Int = 0,note:Note){
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums
		if(noteAnimation != null){
			PlayState.charAnim(charID,(if(noteAnimation == "")noteAnims[noteData] else noteAnimation),true); // Play animation
		}
	}
	dynamic public function susHit(?charID:Int = 0,note:Note){ // Played every update instead of every time the strumnote is hit
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums

		if(noteAnimation != null){
			PlayState.charAnim(charID,(if(noteAnimation == "")noteAnims[noteData] else noteAnimation),true); // Play animation
		}
	}

	dynamic public function miss(?charID:Int = 0,?note:Null<Note> = null){
		if(noteAnimationMiss != null){
			PlayState.charAnim(charID,(if(noteAnimationMiss == "")noteAnims[noteData] + "miss" else noteAnimationMiss),true); // Play animation
		}
	}
	// Array of animations, to be used above
	public static var noteAnims:Array<String> = ['singLEFT','singDOWN','singUP','singRIGHT']; 
	public static var noteDirections:Array<String> = ['LEFT','DOWN','UP','RIGHT','NONE']; 
	public var killNote = false;


	inline function callInterp(func:String,?args:Array<Dynamic>){
		if(!inCharter && PlayState.instance != null) PlayState.instance.callInterp(func,args);
	} 

	public function new(?strumTime:Float = 0, ?_noteData:Int = 0, ?prevNote:Note, ?sustainNote:Bool = false, ?_inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
	{try{
		super();
		
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

			showNote = !(!playerNote && !FlxG.save.data.oppStrumLine);
			if((rawNote[1] == -1 || rawNote[2] == "eventNote")){ // Psych event notes, These should not be shown, and should not appear on the player's side
				if(rawNote[2] == "eventNote")rawNote.remove(2);
				shouldntBeHit = false; // Make sure it doesn't become a hurt note
				showNote = false; // Don't show the note
				this.noteData = 1; // Set it to 0, to prevent issues
				mustPress = false; // The player CANNOT recieve this note
				eventNote = true; // Just an identifier
				aiShouldPress = true;
				type =rawNote[2];
				// _update = function(elapsed:Float){if (strumTime <= Conductor.songPosition) wasGoodHit = true;};
				frames = new flixel.graphics.frames.FlxFramesCollection(FlxGraphic.fromRectangle(1,1,0x01000000,false,"blank.mp4"));
				switch (Std.string(rawNote[2]).toLowerCase()) {
					case "play animation" | "playanimation": {
						try{
							// Info can be set to anything, it's being used for storing the Animation and character
							info = [rawNote[3],
								// Psych uses different character ID's than SE, more charts will be coming from Psych than SE
								switch(Std.string(rawNote[4]).toLowerCase()){
									case "dad","opponent","0":1;
									case "gf","girlfriend","2":2;
									default:0;
								}
							]; 
						}catch(e){info = [rawNote[3],0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note){trace('Playing ${info[0]} for ${info[1]}');PlayState.charAnim(info[1],info[0],true);}; 
						trace('Animation note processed');
					}
					case "changebpm", "bgm change": {
						try{
							// Info can be set to anything, it's being used for storing the BPM
							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [120,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note){Conductor.changeBPM(info[0]);}; 
						trace('BPM note processed');
					}
					case "changescrollspeed": {
						try{
							// Info can be set to anything, it's being used for storing the BPM
							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [2,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note){PlayState.SONG.speed = info[0];}; 
						trace('BPM note processed');
					}
					default:{ // Don't trigger hit animation
						trace('Note with "${rawNote[2]}" hidden');
						hit = function(?charID:Int = 0,note){trace("hit a event note");return;};
					}
				}
			}
		}
			
			

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (this.strumTime < 0 )
			this.strumTime = 0;
		if(shouldntBeHit && PlayState.SONG != null && PlayState.SONG.inverthurtnotes) mustPress=!mustPress;

		callInterp("noteCreate",[this,rawNote]); 
		if(killNote){return;}

		if(!eventNote){
			lastNoteID++;
			noteID = lastNoteID;
			//defaults if no noteStyle was found in chart
			loadFrames();

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;
			var noteName = noteNames[noteData];
			if(eventNote) noteName = noteNames[0];


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
				parentNoteWidth = prevNote.width;

				if (prevNote.isSustainNote)
				{
					parentNoteWidth = prevNote.parentNoteWidth;
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
		}else{
			noteID = -40;
		}
		visible = false;
		callInterp("noteAdd",[this,rawNote]);
	}catch(e){MainMenuState.handleError('Caught "Note create" crash: ${e.message}');}
}

	var missedNote:Bool = false;
	override function draw(){
		if(!eventNote && showNote){
			super.draw();
		}
		// if(ntText != null){ntText.x = this.x;ntText.y = this.y;ntText.draw();}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch(inCharter){
			case true:{
				wasGoodHit = (strumTime <= Conductor.songPosition);
				alpha = (wasGoodHit ? 0.7 : 1);
				visible = true;
				skipNote = false;
			}
			case false: if ((!skipNote || isOnScreen())){ // doesn't calculate anything until they're on screen
				skipNote = false;
				visible = (!eventNote && showNote);
				callInterp("noteUpdate",[this]);

				if (mustPress && !eventNote)
				{
					// ass
					if (shouldntBeHit)
					{
						if (strumTime - Conductor.songPosition <= (45 * Conductor.timeScale) && strumTime - Conductor.songPosition >= (-45 * Conductor.timeScale))
							canBeHit = true;
						else
							canBeHit = false;
					}else{

						if ((isSustainNote && (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)) ) ||
						    strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset  )
								canBeHit = true;

						if (!wasGoodHit && strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale){
							canBeHit = false;
							tooLate = true;
							alpha = 0.3;
						}
					}
				}
				else if(eventNote){
					if (strumTime <= Conductor.songPosition){

						this.hit(1,this);
						this.destroy();
					}
				}
				else if (aiShouldPress && !PlayState.p2canplay && strumTime <= Conductor.songPosition)
				{
					wasGoodHit = true;
				}
				callInterp("noteUpdateAfter",[this]);

			}
		}
	}
}