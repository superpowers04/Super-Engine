package se.objects;

import flixel.FlxSprite;
import Alphabet;
import flixel.graphics.frames.FlxFrame;

using StringTools;

/* TODO MAKE LESS DEPENDANT ON ALPHABET AND BOLD TEXT*/

@:structInit @:publicFields class SESingularText extends FlxSprite{
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
	@:noCompletion private var textFrames:Array<FlxFrame> = [];
	function setTextSize(s:Float = 40){
		scale.x=s/40;
		scale.y=s/40;
		recalculate();
	}
	function new(?x:Float=0,?y:Float=0,?text:String = "",?textSize:Float = 12,?bold:Bool = true,?charWrap:Int = 0,?widthWrap:Int = 0,?spacing:Float=2){
		super(x,y);
		frames = Alphabet.Frames;
		this.bold = bold;
		this.charWrap = charWrap;
		this.widthWrap = widthWrap;
		this.spacing = spacing;
		this.text=text;
		scale.x=textSize/50;
		scale.y=textSize/50;
	}
	function recalculate(){
		width = 0;
		height = 50*scale.y;
		var x:Float = 0;
		var y:Float = 0;
		var frame:FlxFrame;
		while(textFrames.pop() != null){}

		for (curChar => char in seperatedText){
			// if(AlphaCharacter.symbols.contains(char)){
			// 	char+=(char.toLowerCase() == char ? " lowercase" : ' capital');
			// }
			final name = (bold ? char.toUpperCase() + " bold"
				 :char.toLowerCase() == char ? '$char lowercase' : '$char capital');
			seperatedText[curChar] = name;
			final anim = AlphaCharacter.alphabetAnims.get(name);
			frame = anim == null ? null : frames.frames[anim[0]];
			// trace('$anim $frame $name');
			textFrames[curChar] = frame;
			x+=((frame?.frame?.width ?? 40)*scale.x);
			if(charWrap != 0 && curChar % charWrap == 1){
				x=0;
				width+=50*scale.y;
			}
			if(widthWrap != 0 && x > widthWrap){
				x=0;
				width+=50*scale.y;
			}
			if(x > width) width=x;
		}
	}
	override function draw(){
		final baseX = x + (xAlign == 0 ? 0 : width * xAlign );
		final baseY = y + (yAlign == 0 ? 0 : height * yAlign );
		for (curChar => char in textFrames){
			curChar++;
			if(char != null){
				frame = char;
				super.draw();
			}
			x+=spacing+((frame?.frame?.width ?? 40)*scale.x);
			if(charWrap != 0 && curChar % charWrap == 1){
				x=baseX;
				y+=spacing+(50*scale.y);
			}
			if(widthWrap != 0 && x-baseX > widthWrap){
				x=baseX;
				y+=spacing+(50*scale.y);
			}
		}
		x=baseX - (xAlign == 0 ? 0 : width * xAlign );
		y=baseY - (yAlign == 0 ? 0 : height * yAlign );
		dirty=false;
	}
}
