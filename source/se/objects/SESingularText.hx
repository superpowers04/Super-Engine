package se.objects;

import flixel.FlxSprite;
import Alphabet;
import flixel.graphics.frames.FlxFrame;

using StringTools;

/* TODO MAKE LESS DEPENDANT ON ALPHABET AND BOLD TEXT*/
/* TODO ADD PROPER ALIGNMENT*/

@:structInit @:publicFields class SESTLetter {
	var frame:FlxFrame;
	var x:Float = 0;
	var y:Float = 0;
	var line:Int = 0;
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
		seperatedText = (text = s).split('');
		recalculate();
		return s;
	}
	@:noCompletion private var seperatedText:Array<String> = [];
	@:noCompletion private var textFrames:Array<SESTLetter> = [];
	@:noCompletion private var newLineWidths:Array<Float> = [];
	function setTextSize(s:Float = 40){
		scale.x=scale.y=s/LETTERSIZE;
		recalculate();
	}
	function new(?x:Float=0,?y:Float=0,?text:String = "",?textSize:Float = 12,?bold:Bool = true,?charWrap:Int = 0,?widthWrap:Int = 0,?spacing:Float=2){
		super(x,y);
		frames = Alphabet.Frames;
		scale.x=scale.y=textSize/LETTERSIZE;
		this.bold = bold;
		this.charWrap = charWrap;
		this.widthWrap = widthWrap;
		this.spacing = spacing;
		if(text != "") this.text=text;
	}
	function recalculate(){
		width = 0;
		height = 50*scale.y;
		// var lineWidth:Float = 0

		while(newLineWidths.pop() != null){}
		{
			final L = seperatedText.length;
		}
		var x:Float = 0;
		var y:Float = 0;
		var frame:FlxFrame;
		var newLine:Int = 0;
		var chars:Int = 0;

		for (curChar => char in seperatedText){
			// if(AlphaCharacter.symbols.contains(char)){
			// 	char+=(char.toLowerCase() == char ? " lowercase" : ' capital');
			// }
			final name = (bold ? char.toUpperCase() + " bold"
				 :char.toLowerCase() == char ? '$char lowercase' : '$char capital');
			seperatedText[curChar] = name;
			final anim = AlphaCharacter.alphabetAnims.get(name);
			frame = anim == null ? null : frames.frames[anim[0]];
			if(frame != null){
				if(textFrames[chars] != null){
					final textFrame = textFrames[chars];
					textFrame.x=x;
					textFrame.y=y;
					textFrame.frame=frame;
					textFrame.line=newLine;

				}else{
					textFrames[chars] = {x:x,y:y,frame:frame,line:newLine};
				}
				x+=spacing+((frame.frame.width ?? 40)*scale.x);
				chars++;
			}else{
				x+=spacing+(40*scale.x);
			}
			// textFrames[curChar] = frame;
			if(charWrap != 0 && curChar % charWrap == 1 || char == "\n" || widthWrap != 0 && x > widthWrap){
				x=0;
				newLine++;
				y+=65*scale.y;
				height+=65*scale.y;
			}
			newLineWidths[newLine]=x;
			if(x > width) width=x;
		}
		while(textFrames.length >= chars){textFrames.pop();}
	}
	override function draw(){
		final baseX = x;
		final baseY = y = y + (yAlign == 0 ? 0 : height * yAlign );
		// var newLine:Int = 0;
		if(xAlign != 0) x+=(newLineWidths[0] * xAlign);
		for (curChar => char in textFrames){
			frame = char.frame;
			x=baseX+(xAlign == 0 ? 0 : (newLineWidths[char.line] ?? width) * xAlign)+char.x;
			y=baseY+char.y;
			super.draw();
		}
		x=baseX;
		y=baseY - (yAlign == 0 ? 0 : height * yAlign );
		dirty=false;
	}
}
