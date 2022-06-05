
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
	public var data:Int = 0;
	override public function new()
	{
		try{

			super();
			// frames = Paths.getSparrowAtlas("noteSplashes");
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.splashImage,NoteAssets.splashXml);
			// Psych styled
			animation.addByPrefix("note1-0", "note splash blue 1", 24, false);
			animation.addByPrefix("note2-0", "note splash green 1", 24, false);
			animation.addByPrefix("note0-0", "note splash purple 1", 24, false);
			animation.addByPrefix("note3-0", "note splash red 1", 24, false);

			animation.addByPrefix("note1-1", "note splash blue 2", 24, false);
			animation.addByPrefix("note2-1", "note splash green 2", 24, false);
			animation.addByPrefix("note0-1", "note splash purple 2", 24, false);
			animation.addByPrefix("note3-1", "note splash red 2", 24, false);
			// Vanilla
			animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
			animation.addByPrefix("note1-0", "note impact 1 blue", 24, false);
			animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
			animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
			animation.addByPrefix("note3-0", "note impact 1 red", 24, false);
			animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
			animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
			animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
			animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
		}catch(e){MainMenuState.handleError(e,'Error while loading NoteSplashes ${e.message}');
		}
		

	}

	public function setupNoteSplash(xPos:Float, yPos:Float,?note:Int = 0)
	{
		try{
			x = xPos;
			y = yPos;
			alpha = 0.6;
			animation.play("note" + note + "-" + FlxG.random.int(0, 1), true);
			animation.finishCallback = finished;
			if(animation.curAnim == null){
				animation.play("note" + note + "-0", true);

			}
			animation.curAnim.frameRate = 24;
			data = note;
			updateHitbox();
			switch (NoteAssets.splashType) {
				case "psych":
					setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
					offset.set(10, 10);
				case "vanilla": // From DotEngine
					offset.set(width * 0.3, height * 0.3);
				case "custom":
					// Do nothing
				default:
					setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
					offset.set(-40, -40);
			}
		}catch(e){MainMenuState.handleError(e,'Error while setting up a NoteSplash ${e.message}');
		}
		// offset.set(-0.5 * -width, 0.5 * -height);
	}
	function finished(name:String){
		kill();
	}
}