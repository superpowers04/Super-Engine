package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.text.FlxText;

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

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

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

	public override function destroy(){
		if(!persist){super.destroy();}else{visible = false;}
	}

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, dontMoveX:Bool = false,?xOffset:Float = 70,?useAlphabet:Bool = true)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;
		this.xOffset = xOffset;
		if(FlxG.save.data.useFontEverywhere) this.useAlphabet = useAlphabet = false;
		this.moveX = !dontMoveX;
		this.useAlphabet = useAlphabet;
		if (text != "" && useAlphabet)
		{
			listOAlphabets = new List<AlphaCharacter>();
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}

		}else if (text != "" && !useAlphabet){
			textObj = new FlxText(0, 0, FlxG.width, text, 48);
			textObj.scrollFactor.set();
			textObj.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			textObj.borderSize = 3;
			textObj.borderQuality = 1;
			// textObj.borderStyle = OUTLINE_FAST;
			add(textObj);
		}
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.acceptedChars.contains(character.toLowerCase()))
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
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
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
				listOAlphabets.add(letter);

				if (isBold && AlphaCharacter.alphabet.contains(character.toLowerCase()))
					letter.createBold(character);
				else
				{
					letter.createLetter(character);
				}

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				listOAlphabets.add(letter);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					// if (isNumber)
					// {
					// 	letter.createNumber(splitWords[loopNum]);
					// }
					// else if (isSymbol)
					// {
					// 	letter.createSymbol(splitWords[loopNum]);
					// }
					// else
					// {
					letter.createLetter(splitWords[loopNum]);
					// }

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48) + yOffset,10 * elapsed);
			if(moveX)x = FlxMath.lerp(x, xOffset, 10 * elapsed);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var acceptedChars:String = "abcdefghijklmnopqrstuvwxyz1234567890~#$%()*+:;<=>@[]^.,'!?/";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? /";

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = (if (letter.toLowerCase() == letter) "lowercase" else 'capital');
		if (symbols.contains(letter)){
			createSymbol(letter);
		}else if (alphabet.contains(letter)){
			animation.addByPrefix(letter, letter + " " + letterCase, 24);
		}else{
			animation.addByPrefix(letter, letter, 24);
			

		}
		animation.play(letter);
		updateHitbox();

		if (alphabet.contains(letter)){y = (110 - height);
		y += row * 60;}
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
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
				animation.addByPrefix(letter, '#', 24);
				animation.addByPrefix(letter, letter, 24);
				animation.play(letter);
		}
	}
}
