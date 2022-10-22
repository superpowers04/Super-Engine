package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flash.display.BitmapData;

using StringTools; 

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text(default,set):String = "";

	public function set_text(repl:String = ""):String{
		if(members.length > 0){
			var e:FlxSprite;
			while (members.length > 0){
				e = remove(members[0],true);
				if(e != null) e.destroy();
			}
		}
		if(listOAlphabets != null && listOAlphabets.length > 0){
			var e:FlxSprite;
			while (listOAlphabets.length > 0){
				e = listOAlphabets.pop();
				if(e != null && e.destroy != null) e.destroy();
			}
		}
		xPos = 0;
		lastSprite = null;
		lastWasSpace = false;
		
		_finalText = text = repl;
		setup();
		return text;
	}
	var _finalText:String = "";
	var _curText:String = "";
	public static var sprite:FlxSprite;
	public static var Frames(get,set):FlxFramesCollection;
	public static function get_Frames():FlxFramesCollection{
		return sprite.frames;
	}
	public static function set_Frames(vari:FlxFramesCollection):FlxFramesCollection{
		return sprite.frames = vari;
	}

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;


	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;
	public var textObj:FlxText;

	var listOAlphabets:List<AlphaCharacter>;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	public var xOffset:Float = 70;
	public var yOffset:Float = 0;
	public var useAlphabet:Bool = true;
	public var selected:Bool = false;
	public var moveX:Bool = true;
	public var adjustAlpha:Bool = true;
	public var persist:Bool = false;
	public var removeDashes = true;
	// public var bounce=true;
	public var bounceTween:FlxTween;
	public function bounce(){
		scale.x = scale.y = 1.1;
		if(bounceTween != null)bounceTween.destroy();
		bounceTween = FlxTween.tween(scale,{x:1,y:1},0.2,{ease:FlxEase.expoOut});
	}
	public override function destroy(){
		if(!persist){
			if(timer != null)timer.destroy();
			super.destroy();
		}else{visible = false;}
	}

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, dontMoveX:Bool = false,?xOffset:Float = 70,?useAlphabet:Bool = true)
	{
		super(x, y);

		_finalText = text;
		isBold = bold;
		this.xOffset = xOffset;
		if(FlxG.save.data.useFontEverywhere) this.useAlphabet = useAlphabet = false;
		this.moveX = !dontMoveX;
		this.useAlphabet = useAlphabet;
		if(sprite == null || Frames == null){
			sprite = new FlxSprite();
			trace('Loading alphabet sprites');
			if(FileSystem.exists("mods/alphabet.png") && FileSystem.exists("mods/alphabet.xml")){
				try{
					Frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/alphabet.png')),File.getContent('mods/alphabet.xml'));
				}catch(e){
					Frames = Paths.getSparrowAtlas('alphabet');
				}
			}else{
				Frames = Paths.getSparrowAtlas('alphabet');

			}
		}
		this.text = text;
	}
	inline function setup(){
		if (text != "" && useAlphabet)
		{
			listOAlphabets = new List<AlphaCharacter>();
			addText();

		}else if (text != "" && !useAlphabet){
			textObj = new FlxText(0, 0, FlxG.width, text, 48);
			textObj.scrollFactor.set();
			textObj.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			textObj.borderSize = 3;
			textObj.borderQuality = 1;
			add(textObj);
		}
	}

	var xPos:Float = 0;
	public function addText(bounce:Bool = false)
	{
		splitWords = _finalText.split("");
		var _X = -xOffset;
		var _Y = y;
		x = y = 0;

		for (character in splitWords) {addLetter(character,bounce);}

		x=_X;
		y=_Y;
	}
	var currentLetter = 0;
	var timer:FlxTimer;
	public function startTyping(secsBetweenLetters:Float = 0.3,max:Float = 0,?callback:AlphaCharacter -> Void){
		// showLetter(0,secsBetweenLetters);
		for (i in members){if(i != null) i.visible = false;}
		if(max > 0){
			secsBetweenLetters = max / members.length;
			// trace(secsBetweenLetters);
		}
		timer = new FlxTimer().start(secsBetweenLetters,function(_){
			var mem:AlphaCharacter = cast (members[currentLetter],AlphaCharacter);
			if(mem != null){
				mem.visible = true;
				if(callback != null){
					callback(cast mem);
				}
			}
			currentLetter++;
		},length);
	}
	function addLetter(character:String,bounce:Bool = false){
		if (character == " " || removeDashes && ( character == "-" || character == "_"))
		{ 
			lastWasSpace = true;
			return;
		}

		// if (AlphaCharacter.acceptedChars.contains(character.toLowerCase()))
			// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
		// {
			if (lastSprite != null)
			{
				xPos = lastSprite.x + lastSprite.width;
			}

			if (lastWasSpace)
			{
				xPos += 40;
				lastWasSpace = false;
			}

			// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
			var letter:AlphaCharacter = new AlphaCharacter(xPos, 0,removeDashes);
			listOAlphabets.add(letter);
			if (isBold) letter.createBold(character);
			else letter.createLetter(character);
			add(letter);
			lastSprite = letter;
			if(bounce) {
				letter.scale.x = letter.scale.y = 1.1;
				FlxTween.tween(letter.scale,{x:1,y:1},0.5,{ease:FlxEase.quadInOut});
			}
		// }
	}


	public var personTalking:String = 'gf';

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48) + yOffset,10 * elapsed);
			if(moveX)x = FlxMath.lerp(x, xOffset, 10 * elapsed);
		}
		if(visible) super.update(elapsed);

	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var acceptedChars:String = "abcdefghijklmnopqrstuvwxyz1234567890~#$%()*+:;<=>@[]^.,'!?/";
	public static var alphabetMap:Map<String,String> = [
		","=>"-comma-",
		'.'=>"-period-",
		'?'=>"-question-",
		'\''=>"-apostraphie-",
		">"=>"-left arrow-",
		"<"=>"-right arrow-",
		"*"=>"-multiply x-",
		"\""=>"-end quote-",
		"/"=>"-forward slash-",
		"\\"=>"-back slash-",
	];

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? /";

	public var row:Int = 0;
	public var showDashes = false;

	public function new(x:Float, y:Float,?allowDashes:Bool = false)
	{
		super(x, y);
		var tex = Alphabet.Frames;
		frames = tex;
		showDashes = allowDashes;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		// animation.play(letter);

		if(animation.exists(letter)){
			animation.play(letter);
			updateHitbox();
		}else{
			// createLetter(letter.toUpperCase());
			useFLXTEXT(letter,true);
		}
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = (if (letter.toLowerCase() == letter) "lowercase" else 'capital');
		if (symbols.contains(letter)){
			createSymbol(letter);
		}else if (alphabet.contains(letter)){
			animation.addByPrefix(letter, letter + " " + letterCase, 24); // Backwards compat
			animation.addByPrefix(letter, letter, 24);
		}else{
			animation.addByPrefix(letter, letter, 24);
			

		}
		
		if(animation.exists(letter)){
			animation.play(letter);
			updateHitbox();
		}else{
			useFLXTEXT(letter);
		}

		if (alphabet.contains(letter)){y = (110 - height);y += row * 60;}
	}

	public function createNumber(letter:String,bold:Bool = false):Void
	{
		animation.addByPrefix(letter, letter, 24);
		updateHitbox();
	}
	inline function useFLXTEXT(letter:String,bold:Bool = false){
		var txt = new FlxText(-10000,0,letter,48);
		if(bold){
			txt.color = 0xFFFFFF;
			txt.setBorderStyle(OUTLINE,0xff000000,5);
			txt.draw();
		}else{
			txt.color = 0xff000000;
			txt.draw();

		}
		graphic = txt.graphic;
		frames = txt.frames;
		txt.destroy();
	}

	public function createSymbol(letter:String)
	{
		if(alphabetMap[letter] != null){
			animation.addByPrefix(letter, alphabetMap[letter], 24);
			if(animation.exists(letter)){
				animation.play(letter);
				updateHitbox();
				return;
			}
		}
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			// case '_':
			// 	animation.addByPrefix(letter, '_', 24);
			// 	animation.play(letter);
			// 	y += 50;
			case "#":
				animation.addByPrefix(letter, '#', 24);
				animation.play(letter);
			case "$":
				animation.addByPrefix(letter, '$', 24);
				animation.play(letter);
			case "%":
				animation.addByPrefix(letter, '%', 24);
				animation.play(letter);
			case "&":
				animation.addByPrefix(letter, '&', 24);
				animation.play(letter);
			case "(":
				animation.addByPrefix(letter, '(', 24);
				animation.play(letter);
			case ")":
				animation.addByPrefix(letter, ')', 24);
				animation.play(letter);
			case "+":
				animation.addByPrefix(letter, '+', 24);
				animation.play(letter);
			// case "-":
			// 	animation.addByPrefix(letter, '-', 24);
			// 	animation.play(letter);
			case '"':
				animation.addByPrefix(letter, '"', 24);
				animation.play(letter);
				y -= 0;
			case '@':
				animation.addByPrefix(letter, '@', 24);
				animation.play(letter);
			case "^":
				animation.addByPrefix(letter, '^', 24);
				animation.play(letter);
				y -= 0;
			case ' ':
				animation.addByPrefix(letter, 'space', 24);
				animation.play(letter);
			case '/':
				animation.addByPrefix(letter, 'forward slash', 24);
				animation.play(letter);
			default:
				
				// animation.addByPrefix(letter, '#', 24);
				animation.addByPrefix(letter, letter, 24);
				
				if(animation.exists(letter)){
					animation.play(letter);
					updateHitbox();
				}else{
					useFLXTEXT(letter);
				};
		}
	}
}
