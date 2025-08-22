package se.objects;


/* An "improvement" over FlxBitmapText and others to use a single FlxSprite that's moved around a bunch instead of several hundred FlxSprites
	Originally made for Super Engine
*/

import flixel.FlxSprite;
import Alphabet;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;

using StringTools;

/* TODO - MAKE LESS DEPENDANT ON ALPHABET AND BOLD TEXT*/
/* TODO - ADD PROPER ANGLE SUPPORT*/
/* TODO - ADD MIN CHARACTER COUNT TO ALLOW LETTTER CACHING FOR LESS RAM FLUCTUATION*/
/* FIXME - X,Y VALUES ARE INCORRECT WHEN ACTUALLY RENDERING*/
@:structInit @:publicFields class SESTLetter {
	var frame:FlxFrame;
	var x:Float = 0;
	var y:Float = 0;
	var line:Int = 0;
	// var hide:Bool = false;
}

@:structInit @:publicFields class SESingularText extends FlxSprite{
	static inline var LETTERSIZE = 70;
	var spacing:Float = 2;
	var bold:Bool=false;

	var charWrap:Int = 0;
	var widthWrap:Int = 0;
	var xAlign:Float = 0;
	var yAlign:Float = 0;

	var text(default,set):String = "";
	function set_text(s){
		text = s;
		seperatedText = (s).split('');
		recalculate();
		return s;
	}
	function updateText(s):String{
		if(s == text) return text;

		return text = s;
	}
	@:noCompletion private var seperatedText:Array<String> = [];
	@:noCompletion private var textFrames:Array<SESTLetter> = [];
	@:noCompletion private var newLineWidths:Array<Float> = [];
	function setTextSize(s:Float = LETTERSIZE){
		scale.x=s/LETTERSIZE;
		scale.y=s/LETTERSIZE;
		recalculate();
	}
	function new(?x:Float=0,?y:Float=0,?text:String = "",?textSize:Float = 16,?bold:Bool = true,?charWrap:Int = 0,?widthWrap:Int = 0,?spacing:Float=2){
		super(x,y);
		frames = Alphabet.Frames;
		scale.x=textSize/LETTERSIZE;
		scale.y=textSize/LETTERSIZE;
		this.bold = bold;
		this.charWrap = charWrap;
		this.widthWrap = widthWrap;
		this.spacing = spacing;
		if(text != "") this.text=text;
		offset.set(0,0);
	}
	function recalculate(){
		width = 0;
		height = LETTERSIZE*scale.y;

		while(newLineWidths.pop() != null){}
		var x:Float = 0;
		var y:Float = 0;
		var frame:FlxFrame;
		var newLine:Int = 0;
		var chars:Int = 0;

		for (curChar => char in seperatedText){
			final name = (bold ? char.toUpperCase() + " bold"
				 :char.toLowerCase() == char ? '$char lowercase' : '$char capital');
			seperatedText[curChar] = name;
			/* TODO Make this a proper Map<String,FlxFrame> instead of relying on SE's alphabet loader*/
			final anim = AlphaCharacter.alphabetAnims.get(name);
			frame = anim == null ? null : frames.frames[anim[0]];

			if(frame != null && frame.type != FlxFrameType.EMPTY){
				if(textFrames[chars] != null){
					final textFrame = textFrames[chars];
					textFrame.x=x;
					textFrame.y=y;
					textFrame.frame=frame;
					textFrame.line=newLine;
					// textFrame.hide = false;
				}else{
					textFrames[chars] = {x:x,y:y,frame:frame,line:newLine};
				}
				x+=spacing+((frame.frame.width ?? 40)*scale.x);
				chars++;
			}else{
				x+=spacing+(40*scale.x);
			}
			newLineWidths[newLine]=x;
			if(x > width) width=x;
			if(charWrap != 0 && curChar % charWrap == 1 || char == "\n" || widthWrap != 0 && x > widthWrap){
				x=0;
				newLine++;
				y+=LETTERSIZE*scale.y;
				height+=LETTERSIZE*scale.y;
			}
		}
		while(textFrames.length > chars){textFrames.pop();}
	}
	override function draw(){
		if(!visible || alpha == 0) return;
		#if FLX_DEBUG
		FlxBasic.visibleCount++;
		#end
		final xAlign = xAlign;
		final yAlign = yAlign;
		final w = width;
		final h = height;

		final baseX = x;
		final baseY = y = y + (yAlign == 0 ? 0 : h * yAlign );
		offset.x=0;
		offset.y=0;
		// var newLine:Int = 0;
		if(xAlign != 0) x+=(newLineWidths[0] * xAlign);
		for (curChar => char in textFrames){
			frame = char.frame;

			x=baseX+(xAlign == 0 ? 0 : (newLineWidths[char.line] ?? w) * xAlign)+char.x;
			y=baseY+char.y;

			// updateHitbox();
			draw_frame();
		}
		width = w;
		height = h;
		x=baseX;
		y=baseY - (yAlign == 0 ? 0 : h * yAlign );
		dirty=false;
	}
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen.
	 */
	function draw_frame():Void {
		if(useFramePixels) calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);


		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera):Void
	{
		getScreenPosition(_point, camera);
		if (isPixelPerfectRender(camera))
			_point.floor();

		_point.copyToFlash(_flashPoint);
		camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		getScreenPosition(_point, camera);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}
	// override public function overlaps(objectOrGroup:FlxBasic, inScreenSpace:Bool = false, ?camera:FlxCamera){
	// 	if(xAlign == 0 && yAlign == 0) return overlaps(objectOrGroup,inScreenSpace,camera);
	// 	final baseX = x;
	// 	final baseY = y;
	// 	if(xAlign != 0)x+=height * xAlign;
	// 	if(yAlign != 0)y+=height * yAlign;
	// 	final ret = overlaps(objectOrGroup,inScreenSpace,camera);
	// 	x=baseX;
	// 	y=baseY;
	// 	return ret;
	// }
}
