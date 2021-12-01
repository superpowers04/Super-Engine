
package;

// Code from https://github.com/Tr1NgleBoss/Funkin-0.2.8.0-Port/
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;


using StringTools;

class NoteSplash extends FlxSprite
{  
	static var fram:FlxFramesCollection;
	override public function new()
	{
		try{

			super();
			frames = Paths.getSparrowAtlas("noteSplashes");
			animation.addByPrefix("blue", "splash blue", 24, false);
			animation.addByPrefix("green", "splash green", 24, false);
			animation.addByPrefix("purple", "splash purple", 24, false);
			animation.addByPrefix("red", "splash red", 24, false);
			animation.addByPrefix("white", "splash white", 24, false);
		}catch(e){
			MainMenuState.handleError('Error while loading NoteSplashes ${e.message}');
		}
		

	}

	public function setupNoteSplash(xPos:Float, yPos:Float,?note:Int = 0)
	{
		x = xPos;
		y = yPos;
		alpha = 0.6;
		animation.play(Note.noteNames[note], true);
		animation.finishCallback = finished;
		animation.curAnim.frameRate = 24;
		updateHitbox();
		// Stolen from psych but whatever
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		offset.set(10, 10);
		// offset.set(0.3 * width, 0.3 * height);
	}
	function finished(name:String){
		kill();
	}
}